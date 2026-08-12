from main import create_pdf

questions = [
    {
        "question": "What is Python?",
        "options": ["A language", "A snake", "Both", "None"],
        "answer": "Both"
    }
]

resources = [
    {
        "title": "Python Official Documentation",
        "url": "https://docs.python.org/3/"
    },
    {
        "title": "Python (programming language) - Wikipedia",
        "url": "https://en.wikipedia.org/wiki/Python_(programming_language)"
    }
]

res = create_pdf(questions, "test.pdf", is_fill=False, resources=resources)

import base64
pdf_bytes = base64.b64decode(res["pdf_base64"])
with open("test.pdf", "wb") as f:
    f.write(pdf_bytes)

print("PDF successfully generated and saved to test.pdf")
