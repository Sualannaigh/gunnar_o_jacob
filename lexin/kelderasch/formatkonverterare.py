import os
import json
import re
from docx import Document

def docx_to_txt(docx_path, txt_path):
    try:
        doc = Document(docx_path)
        full_text = [para.text for para in doc.paragraphs if para.text.strip()]
        
        with open(txt_path, 'w', encoding='utf-8') as txt_file:
            for line in full_text:
                txt_file.write(line + '\n')
        
        print(f"Converted: {os.path.basename(docx_path)} -> {os.path.basename(txt_path)}")
    except Exception as e:
        print(f"Failed to convert {docx_path}: {e}")

def convert_all_docx(folder_path):
    if not os.path.isdir(folder_path):
        print("Invalid folder path.")
        return

    for filename in os.listdir(folder_path):
        if filename.lower().endswith(".docx"):
            docx_path = os.path.join(folder_path, filename)
            txt_filename = os.path.splitext(filename)[0] + ".txt"
            txt_path = os.path.join(folder_path, txt_filename)
            docx_to_txt(docx_path, txt_path)

def txt_to_json(txt_path, json_path):
    data, entry = [], {}
    pattern = re.compile(r'#(\d{2})\s*(.*)')
    with open(txt_path, 'r', encoding='utf-8') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            match = pattern.match(line)
            if match:
                key, value = f'#{match.group(1)}', match.group(2)
                if key == '#01' and entry:
                    data.append(entry)
                    entry = {}
                entry[key] = value
    if entry:
        data.append(entry)

    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    print(f"Converted: {txt_path} -> {json_path}")
def convert_all_json(folder_path):
    if not os.path.isdir(folder_path):
        print("Invalid folder path.")
        return

    for filename in os.listdir(folder_path):
        if filename.lower().endswith(".txt"):
            txt_path = os.path.join(folder_path, filename)
            json_filename = os.path.splitext(filename)[0] + ".json"
            json_path = os.path.join(folder_path, json_filename)
            txt_to_json(txt_path, json_path)
        
folder_path = "kelderasch_filer/"
convert_all_docx(folder_path)
convert_all_json(folder_path)
