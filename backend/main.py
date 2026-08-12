from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from PyPDF2 import PdfReader
from langchain_text_splitters import RecursiveCharacterTextSplitter
from dotenv import load_dotenv
from openai import OpenAI
from reportlab.platypus import SimpleDocTemplate, Paragraph
from reportlab.lib.styles import getSampleStyleSheet

import io
import os
import json
import base64

load_dotenv()

client = OpenAI(
    api_key=os.getenv("GROQ_API_KEY"),
    base_url="https://api.groq.com/openai/v1"
)

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def home():
    return {"message": "QuizWhiz AI Backend Running"}


def extract_text_from_pdf(contents, start_page, end_page):

    reader = PdfReader(io.BytesIO(contents))

    total_pages = len(reader.pages)

    start_page = max(1, start_page)
    end_page = min(end_page, total_pages)

    text = ""

    for page in reader.pages[start_page - 1:end_page]:
        text += page.extract_text() or ""

    splitter = RecursiveCharacterTextSplitter(
        chunk_size=4000,
        chunk_overlap=500
    )

    chunks = splitter.split_text(text)

    return chunks[0]

def generate_resources(text):

    prompt = f"""
Based on the following study material, recommend 10 high-quality learning resources.

Rules:
1. Return ONLY valid JSON.
2. Include title and URL.
3. Prefer trusted sources:
   - GeeksforGeeks
   - Wikipedia
   - Microsoft Learn
   - AWS Documentation
   - Stanford
   - MIT OpenCourseWare
   - NPTEL
   - Coursera
   - Khan Academy
   - Official Documentation

Format:

[
  {{
    "title":"Resource Name",
    "url":"https://example.com"
  }}
]

Content:

{text}
"""

    response = client.chat.completions.create(
        model="llama-3.3-70b-versatile",
        messages=[
            {
                "role": "user",
                "content": prompt
            }
        ],
        temperature=0.3
    )

    return json.loads(
        response.choices[0].message.content
    )

def create_pdf(
    questions,
    filename,
    is_fill=False,
    resources=None
):

    from reportlab.platypus import (
        SimpleDocTemplate,
        Paragraph,
        Spacer,
        HRFlowable,
        PageBreak
    )
    from reportlab.lib.styles import getSampleStyleSheet
    from reportlab.lib.enums import TA_CENTER, TA_LEFT
    from reportlab.lib.colors import HexColor

    pdf_buffer = io.BytesIO()

    doc = SimpleDocTemplate(
        pdf_buffer,
        leftMargin=45,
        rightMargin=45,
        topMargin=45,
        bottomMargin=45,
    )

    styles = getSampleStyleSheet()

    # ---------------- Styles ----------------

    titleStyle = styles["Title"]
    titleStyle.alignment = TA_CENTER
    titleStyle.textColor = HexColor("#00A651")
    titleStyle.fontSize = 26
    titleStyle.spaceAfter = 10

    subTitleStyle = styles["Heading2"]
    subTitleStyle.alignment = TA_CENTER
    subTitleStyle.textColor = HexColor("#003366")
    subTitleStyle.spaceAfter = 8

    infoStyle = styles["Normal"]
    infoStyle.alignment = TA_CENTER
    infoStyle.textColor = HexColor("#666666")
    infoStyle.fontSize = 10

    questionStyle = styles["Heading2"]
    questionStyle.alignment = TA_LEFT
    questionStyle.textColor = HexColor("#003366")
    questionStyle.spaceAfter = 8

    normalStyle = styles["Normal"]
    normalStyle.alignment = TA_LEFT
    normalStyle.fontSize = 12
    normalStyle.leading = 22

    answerStyle = styles["Heading2"]
    answerStyle.alignment = TA_LEFT
    answerStyle.textColor = HexColor("#00A651")

    story = []

    # ---------------- Header ----------------

    story.append(
        Paragraph(
            "<b>QuizWhiz AI</b>",
            titleStyle,
        )
    )

    story.append(
        Paragraph(
            "<b>AI Generated Question Paper</b>",
            subTitleStyle,
        )
    )

    story.append(
        Paragraph(
            f"Total Questions : {len(questions)}",
            infoStyle,
        )
    )

    story.append(Spacer(1, 15))

    story.append(
        HRFlowable(
            width="100%",
            thickness=2,
            color=HexColor("#00A651"),
        )
    )

    story.append(Spacer(1, 20))

    # ---------------- Questions ----------------

    for i, q in enumerate(questions, start=1):

        story.append(
            Paragraph(
                f"<b>Question {i}</b>",
                questionStyle,
            )
        )

        story.append(
            Paragraph(
                q["question"],
                normalStyle,
            )
        )

        story.append(Spacer(1, 10))

        if not is_fill:

            for option in q["options"]:

                story.append(
                    Paragraph(
                        f"○ {option}",
                        normalStyle,
                    )
                )

                story.append(Spacer(1, 4))

        else:

            story.append(
                Paragraph(
                    "______________________________________________",
                    normalStyle,
                )
            )

        story.append(Spacer(1, 15))

        story.append(
            HRFlowable(
                width="100%",
                thickness=0.5,
                color=HexColor("#DDDDDD"),
            )
        )

        story.append(Spacer(1, 18))

    # ---------------- Answer Key ----------------

    story.append(PageBreak())

    story.append(
        Paragraph(
            "<b>Answer Key</b>",
            titleStyle,
        )
    )

    story.append(Spacer(1, 10))

    story.append(
        HRFlowable(
            width="100%",
            thickness=2,
            color=HexColor("#00A651"),
        )
    )

    story.append(Spacer(1, 20))

    for i, q in enumerate(questions, start=1):

        story.append(
            Paragraph(
                f"<b>Question {i}</b>",
                answerStyle,
            )
        )

        story.append(
            Paragraph(
                q["answer"],
                normalStyle,
            )
        )

        story.append(Spacer(1, 12))

        # ---------------- Study Resources ----------------

    if resources:

        story.append(PageBreak())

        story.append(
            Paragraph(
                "<b>Recommended Study Resources</b>",
                titleStyle,
            )
        )

        story.append(Spacer(1, 15))

        for i, resource in enumerate(resources, start=1):

            story.append(
                Paragraph(
                    f"<b>{i}. {resource['title']}</b>",
                    questionStyle,
                )
            )

            story.append(
                Paragraph(
                    resource["url"],
                    normalStyle,
                )
            )

            story.append(Spacer(1, 10))
    # ---------------- Footer ----------------

    story.append(Spacer(1, 20))

    story.append(
        HRFlowable(
            width="100%",
            thickness=1,
            color=HexColor("#CCCCCC"),
        )
    )

    story.append(Spacer(1, 8))

    story.append(
        Paragraph(
            "<para align='center'><font color='#777777' size='9'>Generated by QuizWhiz AI</font></para>",
            infoStyle,
        )
    )

    doc.build(story)

    pdf_bytes = pdf_buffer.getvalue()

    pdf_base64 = base64.b64encode(pdf_bytes).decode("utf-8")

    return {
        "questions": questions,
        "pdf_base64": pdf_base64,
        "filename": filename,
    }


@app.post("/generate-mcq")
async def generate_mcq(
    pdf: UploadFile = File(...),
    num_questions: int = Form(...),
    difficulty: str = Form(...),
    co_level: str = Form(...),
    start_page: int = Form(...),
    end_page: int = Form(...)
):

    bloom_mapping = {
        "CO1": "Remember",
        "CO2": "Understand",
        "CO3": "Apply",
        "CO4": "Analyze"
    }

    bloom_level = bloom_mapping.get(
        co_level,
        "Remember"
    )

    contents = await pdf.read()

    text = extract_text_from_pdf(
        contents,
        start_page,
        end_page
    )

    resources = generate_resources(text)

    prompt = f"""
Generate exactly {num_questions} {difficulty} multiple choice questions.

Bloom's Taxonomy Level:
{co_level} - {bloom_level}

Rules:
1. Return ONLY valid JSON.
2. Exactly 4 options.
3. "answer" MUST be exactly one of the options.

Bloom Level Guidelines:

CO1 (Remember):
- Recall facts
- Definitions
- Terminology
- Direct memory questions

CO2 (Understand):
- Explain concepts
- Interpret ideas
- Compare concepts
- Demonstrate understanding

CO3 (Apply):
- Apply concepts to situations
- Problem-solving questions
- Use formulas or methods
- Scenario based questions

CO4 (Analyze):
- Analyze situations
- Identify relationships
- Compare alternatives
- Higher-order thinking

Format:

[
  {{
    "question":"Question",
    "options":[
      "Option 1",
      "Option 2",
      "Option 3",
      "Option 4"
    ],
    "answer":"Correct Option"
  }}
]

Text:

{text}
"""

    response = client.chat.completions.create(
        model="llama-3.3-70b-versatile",
        messages=[
            {
                "role": "user",
                "content": prompt
            }
        ],
        temperature=0.7
    )

    questions = json.loads(
        response.choices[0].message.content
    )

    return create_pdf(
    questions,
    "QuizWhiz_MCQ_Questions.pdf",
    False,
    resources
)


@app.post("/generate-fill")
async def generate_fill(
    pdf: UploadFile = File(...),
    num_questions: int = Form(...),
    difficulty: str = Form(...),
    co_level: str = Form(...),
    start_page: int = Form(...),
    end_page: int = Form(...)
):

    bloom_mapping = {
        "CO1": "Remember",
        "CO2": "Understand",
        "CO3": "Apply",
        "CO4": "Analyze"
    }

    bloom_level = bloom_mapping.get(
        co_level,
        "Remember"
    )

    contents = await pdf.read()

    text = extract_text_from_pdf(
        contents,
        start_page,
        end_page
    )

    resources = generate_resources(text)

    prompt = f"""
Generate exactly {num_questions} {difficulty} fill in the blank questions.

Bloom's Taxonomy Level:
{co_level} - {bloom_level}

Rules:
1. Return ONLY valid JSON.
2. Replace ONE important word with ________.
3. Keep questions short and clear.

Bloom Level Guidelines:

CO1:
- Fact recall

CO2:
- Understanding concepts

CO3:
- Application based blanks

CO4:
- Analytical blanks

Format:

[
  {{
    "question":"The CPU is known as the ________ of the computer.",
    "answer":"brain"
  }}
]

Text:

{text}
"""

    response = client.chat.completions.create(
        model="llama-3.3-70b-versatile",
        messages=[
            {
                "role": "user",
                "content": prompt
            }
        ],
        temperature=0.7
    )

    questions = json.loads(
        response.choices[0].message.content
    )

    return create_pdf(
    questions,
    "QuizWhiz_Fill_Questions.pdf",
    True,
    resources
)