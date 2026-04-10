import json
import os
import re
import ssl
import time
import urllib.error
import urllib.request
from datetime import datetime


API_BASE = "https://api.acikkuran.com"


def read_json(path: str):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def write_json(path: str, data):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def arabic_digits(n: int) -> str:
    mapping = {
        "0": "٠",
        "1": "١",
        "2": "٢",
        "3": "٣",
        "4": "٤",
        "5": "٥",
        "6": "٦",
        "7": "٧",
        "8": "٨",
        "9": "٩",
    }
    return "".join(mapping.get(ch, ch) for ch in str(n))


def parse_a_tag(text: str):
    if not text:
        return None
    m = re.search(r"\[a:([0-9,\s\-]+)\]", text)
    if not m:
        return None
    raw = m.group(1).strip()
    if not raw:
        return None
    out = []
    for part in raw.split(","):
        part = part.strip()
        if not part:
            continue
        if "-" in part:
            a, b = part.split("-", 1)
            a = a.strip()
            b = b.strip()
            if a.isdigit() and b.isdigit():
                start = int(a)
                end = int(b)
                if start <= end:
                    out.extend(list(range(start, end + 1)))
                else:
                    out.extend(list(range(end, start + 1)))
        else:
            if part.isdigit():
                out.append(int(part))
    return out or None


def http_get_json(url: str, retries: int = 4, timeout_s: int = 30):
    ssl._create_default_https_context = ssl._create_unverified_context
    last_err = None
    for attempt in range(retries):
        try:
            req = urllib.request.Request(
                url,
                headers={"User-Agent": "fecrmeal-quran-update/1.0"},
                method="GET",
            )
            with urllib.request.urlopen(req, timeout=timeout_s) as resp:
                body = resp.read().decode("utf-8")
            return json.loads(body)
        except urllib.error.HTTPError as e:
            last_err = e
            wait_s = min(8, 2 ** attempt)
            time.sleep(wait_s)
        except Exception as e:
            last_err = e
            wait_s = min(8, 2 ** attempt)
            time.sleep(wait_s)
    raise last_err


def fetch_surah_verses_map(surah_id: int):
    url = f"{API_BASE}/surah/{surah_id}"
    payload = http_get_json(url)
    data = payload.get("data") if isinstance(payload, dict) else None
    verses = (data or {}).get("verses", [])
    out = {}
    for v in verses:
        try:
            vn = int(v.get("verse_number"))
        except Exception:
            continue
        verse_text = v.get("verse") or ""
        if verse_text:
            if surah_id == 1:
                # Fatiha'da 1. ayet (Besmele) atlanacak, 2-7. ayetler 1-6. ayetlere kaydırılacak
                if vn == 1:
                    continue
                out[vn - 1] = verse_text
            else:
                out[vn] = verse_text
    return out


def main():
    repo_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    json_path = os.path.join(repo_root, "assets", "json", "quran_full.json")
    data = read_json(json_path)
    ts = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = os.path.join(repo_root, "assets", "json", f"quran_full.backup_{ts}.json")
    write_json(backup_path, data)

    api_map = {}
    for surah_id in range(1, 115):
        verses_map = fetch_surah_verses_map(surah_id)
        api_map[surah_id] = verses_map
        time.sleep(0.2)

    updated = 0
    skipped = 0
    missing = 0

    for surah in data:
        surah_id = surah.get("idsureler") or surah.get("idsure") or surah.get("id") or surah.get("idsurelercol")
        try:
            surah_id = int(surah_id)
        except Exception:
            skipped += 1
            continue

        verses = surah.get("verses", [])
        if not isinstance(verses, list):
            skipped += 1
            continue

        surah_api = api_map.get(surah_id, {})
        for verse in verses:
            ayetno = verse.get("ayetno")
            try:
                ayetno_int = int(ayetno)
            except Exception:
                skipped += 1
                continue
            if ayetno_int == 0:
                skipped += 1
                continue

            meal = verse.get("meal") or ""
            nums = parse_a_tag(meal) or [ayetno_int]
            parts = []
            ok = True
            for n in nums:
                api_text = surah_api.get(int(n))
                if not api_text:
                    ok = False
                    break
                parts.append(f"{api_text} ﴿ {arabic_digits(int(n))} ﴾")
            if not ok:
                missing += 1
                continue

            new_metin = " ".join(parts)
            if verse.get("metin") != new_metin:
                verse["metin"] = new_metin
                updated += 1
            else:
                skipped += 1

    write_json(json_path, data)

    print(
        json.dumps(
            {
                "updated": updated,
                "skipped": skipped,
                "missing": missing,
                "backup": os.path.relpath(backup_path, repo_root),
            },
            ensure_ascii=False,
            indent=2,
        )
    )


if __name__ == "__main__":
    main()
