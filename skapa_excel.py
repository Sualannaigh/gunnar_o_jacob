from openpyxl import Workbook


input_file = "/home/jacob/gunnar_o_jacob/swe_kal-text-250910/oöversatta.txt"
output_file = "/home/jacob/gunnar_o_jacob/orduppslag_rickard/ordlista.xlsx"

wb = Workbook()
ws = wb.active
ws.title = "Ordlista"

with open(input_file, "r", encoding="utf-8") as f:
    for line in f:
        if line.startswith("#01"):
            # Ta bort "#01 " i början
            word = line.replace("#01", "", 1).strip()

            ws.append([word, ""])

wb.save(output_file)
print(f"Excel-fil sparad som {output_file}")
