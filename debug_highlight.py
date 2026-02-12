import json
import re

def clean_meal(meal):
    # Dart regex: RegExp(r'\[\w+:\d+.*?\]')
    # Python equiv: r'\[\w+:\d+.*?\]'
    return re.sub(r'\[\w+:\d+.*?\]', '', meal)

def highlight_simulation(text, query):
    lower_text = text.lower()
    lower_query = query.lower()
    start = 0
    spans = []
    
    while True:
        try:
            index = lower_text.index(lower_query, start)
        except ValueError:
            spans.append(f"NORMAL: '{text[start:]}'")
            break
            
        if index > start:
            spans.append(f"NORMAL: '{text[start:index]}'")
        
        spans.append(f"HIGHLIGHT: '{text[index:index+len(query)]}'")
        start = index + len(query)
    
    return spans

with open('assets/json/quran_full.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Find Bakara 3 or any containing 'namaz'
print("Searching for 'namaz' examples...")
for sure in data:
    if 'verses' in sure:
        for verse in sure['verses']:
            meal = verse.get('meal', '')
            cleaned = clean_meal(meal)
            if 'namaz' in cleaned.lower():
                print(f"\n--- {sure['sureadi']} {verse['ayetno']} ---")
                print(f"Original: {meal}")
                print(f"Cleaned: '{cleaned}'")
                print("Simulation with query 'namaz':")
                print(highlight_simulation(cleaned, 'namaz'))
                
                # Check for 'amaz' highlight issue
                print("Simulation with query 'amaz':")
                print(highlight_simulation(cleaned, 'amaz'))
                
                # First 3 examples only
                break
