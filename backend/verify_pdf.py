import sys
from PyPDF2 import PdfReader

# Reconfigure stdout to use utf-8 so Windows terminal doesn't crash on special characters
if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8')

reader = PdfReader("test.pdf")
print("Total pages in test.pdf:", len(reader.pages))

for idx, page in enumerate(reader.pages):
    print(f"\n--- Page {idx+1} ---")
    print(page.extract_text())
