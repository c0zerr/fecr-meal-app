import argparse
import json
import re
import ssl
import sys
import urllib.parse
import urllib.request
from pathlib import Path


TANZIL_DOWNLOAD_URL = "https://tanzil.net/pub/download/v1.0/download.php"
BASMALA_SIMPLE = "بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ"

DEFAULT_DIYANET_JSON = "assets/json/quran_full_ydk_31mart26.json"


ARABIC_INDIC_DIGITS = str.maketrans(
    {
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
)


def to_arabic_indic_number(n: int) -> str:
    return str(n).translate(ARABIC_INDIC_DIGITS)


def parse_a_tag(meal: str) -> list[int] | None:
    if not meal:
        return None
    m = re.search(r"\[a:([^\]]+)\]", meal)
    if not m:
        return None

    spec = m.group(1).strip()
    parts = [p.strip() for p in spec.split(",") if p.strip()]
    out: list[int] = []
    for p in parts:
        if "-" in p:
            a, b = [x.strip() for x in p.split("-", 1)]
            if not a.isdigit() or not b.isdigit():
                return None
            start = int(a)
            end = int(b)
            if start <= 0 or end <= 0 or end < start:
                return None
            out.extend(list(range(start, end + 1)))
        else:
            if not p.isdigit():
                return None
            out.append(int(p))
    return out or None


def load_diyanet_id_map_from_json(diyanet_data) -> dict[int, str]:
    out: dict[int, str] = {}
    if not isinstance(diyanet_data, list):
        return out
    for sura_obj in diyanet_data:
        if not isinstance(sura_obj, dict):
            continue
        verses = sura_obj.get("verses", [])
        if not isinstance(verses, list):
            continue
        for v in verses:
            if not isinstance(v, dict):
                continue
            ayetno = int(v.get("ayetno") or 0)
            if ayetno == 0:
                continue
            vid = v.get("id")
            if not isinstance(vid, int):
                continue
            metin = v.get("metin")
            if metin is None:
                continue
            out[vid] = str(metin)
    return out


def download_tanzil_txt2(
    *,
    quran_type: str,
    marks: bool,
    sajdah: bool,
    rub: bool,
    alef: bool,
) -> str:
    ssl._create_default_https_context = ssl._create_unverified_context
    payload = {
        "quranType": quran_type,
        "outType": "txt-2",
        "agree": "true",
        "marks": "true" if marks else "false",
        "sajdah": "true" if sajdah else "false",
        "rub": "true" if rub else "false",
        "alef": "true" if alef else "false",
    }
    data = urllib.parse.urlencode(payload).encode("utf-8")
    req = urllib.request.Request(
        TANZIL_DOWNLOAD_URL,
        data=data,
        headers={
            "Content-Type": "application/x-www-form-urlencoded",
            "User-Agent": "Mozilla/5.0",
        },
    )
    with urllib.request.urlopen(req, timeout=120) as r:
        return r.read().decode("utf-8", errors="replace")


def load_tanzil_map_from_txt2(raw: str) -> dict[tuple[int, int], str]:
    lines = [l for l in raw.splitlines() if l and not l.startswith("#")]
    out: dict[tuple[int, int], str] = {}

    for line in lines:
        parts = line.split("|", 2)
        if len(parts) != 3:
            continue
        s_raw, a_raw, text = parts
        if not s_raw.isdigit() or not a_raw.isdigit():
            continue
        sura = int(s_raw)
        ayah = int(a_raw)
        text = text.strip()

        if sura == 1:
            if ayah == 1 and text == BASMALA_SIMPLE:
                continue
            if ayah >= 2:
                out[(1, ayah - 1)] = text
            continue

        if sura != 9 and ayah == 1:
            if text == BASMALA_SIMPLE:
                out[(sura, ayah)] = ""
                continue
            if text.startswith(BASMALA_SIMPLE + " "):
                out[(sura, ayah)] = text[len(BASMALA_SIMPLE) :].strip()
                continue
        out[(sura, ayah)] = text

    return out


def build_metin(
    *,
    sura: int,
    ayah_numbers: list[int],
    tanzil_map: dict[tuple[int, int], str],
) -> str:
    chunks: list[str] = []
    for ayah in ayah_numbers:
        txt = tanzil_map.get((sura, ayah))
        if txt is None:
            raise KeyError(f"Missing tanzil text for {sura}:{ayah}")
        if txt == "":
            continue
        chunks.append(f"{txt} ﴿ {to_arabic_indic_number(ayah)} ﴾")
    return " ".join(chunks)


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument(
        "--quran-json",
        default="assets/json/quran_full.json",
        help="Path to quran_full.json",
    )
    ap.add_argument(
        "--source",
        default="diyanet-json",
        choices=["diyanet-json", "tanzil"],
        help="Arabic text source",
    )
    ap.add_argument(
        "--diyanet-json",
        default=DEFAULT_DIYANET_JSON,
        help="Path to Diyanet/YDK quran JSON (source for metin)",
    )
    ap.add_argument(
        "--tanzil-type",
        default="simple",
        help="Tanzil quranType (simple, uthmani, etc.)",
    )
    ap.add_argument("--no-marks", action="store_true")
    ap.add_argument("--no-sajdah", action="store_true")
    ap.add_argument("--no-rub", action="store_true")
    ap.add_argument("--no-alef", action="store_true")
    ap.add_argument(
        "--source-txt2",
        default="",
        help="Optional local txt-2 file. If omitted, script downloads from tanzil.",
    )
    ap.add_argument("--dry-run", action="store_true")
    args = ap.parse_args()

    quran_json_path = Path(args.quran_json).resolve()
    if not quran_json_path.exists():
        print(f"File not found: {quran_json_path}", file=sys.stderr)
        return 2

    data = json.loads(quran_json_path.read_text(encoding="utf-8"))
    changed = 0
    total = 0

    if args.source == "diyanet-json":
        diyanet_path = Path(args.diyanet_json).resolve()
        if not diyanet_path.exists():
            print(f"File not found: {diyanet_path}", file=sys.stderr)
            return 2
        diyanet_data = json.loads(diyanet_path.read_text(encoding="utf-8"))
        diyanet_id_map = load_diyanet_id_map_from_json(diyanet_data)
        if len(diyanet_id_map) < 6000:
            print("Diyanet/YDK mapping looks incomplete; aborting.", file=sys.stderr)
            return 3

        missing_ids: list[int] = []

        for sura_obj in data:
            verses = sura_obj.get("verses", [])
            for v in verses:
                if not isinstance(v, dict):
                    continue
                total += 1
                ayetno = int(v.get("ayetno") or 0)
                if ayetno == 0:
                    continue
                vid = v.get("id")
                if not isinstance(vid, int):
                    continue
                new_metin = diyanet_id_map.get(vid)
                if new_metin is None:
                    missing_ids.append(vid)
                    continue
                if v.get("metin") != new_metin:
                    v["metin"] = new_metin
                    changed += 1

        if missing_ids:
            missing_ids.sort()
            sample = ", ".join(str(x) for x in missing_ids[:10])
            print(
                f"Missing {len(missing_ids)} verse ids in Diyanet/YDK source. Sample: {sample}",
                file=sys.stderr,
            )
            return 4
    else:
        if args.source_txt2:
            raw = Path(args.source_txt2).read_text(encoding="utf-8", errors="replace")
        else:
            raw = download_tanzil_txt2(
                quran_type=args.tanzil_type,
                marks=not args.no_marks,
                sajdah=not args.no_sajdah,
                rub=not args.no_rub,
                alef=not args.no_alef,
            )

        tanzil_map = load_tanzil_map_from_txt2(raw)
        if (1, 1) not in tanzil_map or (2, 1) not in tanzil_map:
            print("Tanzil mapping looks incomplete; aborting.", file=sys.stderr)
            return 3

        for sura_obj in data:
            verses = sura_obj.get("verses", [])
            for v in verses:
                if not isinstance(v, dict):
                    continue
                total += 1
                sura = int(v.get("idsure") or sura_obj.get("idsureler") or 0)
                ayetno = int(v.get("ayetno") or 0)
                if ayetno == 0:
                    continue
                ayahs = parse_a_tag(v.get("meal", "")) or [ayetno]
                new_metin = build_metin(
                    sura=sura, ayah_numbers=ayahs, tanzil_map=tanzil_map
                )
                if v.get("metin") != new_metin:
                    v["metin"] = new_metin
                    changed += 1

    if args.dry_run:
        print(f"Would update {changed} / {total} verse records.")
        return 0

    quran_json_path.write_text(
        json.dumps(data, ensure_ascii=False, indent=2) + "\n", encoding="utf-8"
    )
    print(f"Updated {changed} / {total} verse records in {quran_json_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
