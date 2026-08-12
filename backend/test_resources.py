import os
import json
from dotenv import load_dotenv
from openai import OpenAI

load_dotenv()

client = OpenAI(
    api_key=os.getenv("GROQ_API_KEY"),
    base_url="https://api.groq.com/openai/v1"
)

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
    raw_content = response.choices[0].message.content
    print("Raw Content:")
    print(raw_content)
    try:
        data = json.loads(raw_content)
        print("Success: JSON loaded")
        return data
    except Exception as e:
        print("Error decoding JSON:", e)
        return None

sample_text = "Python is a high-level, general-purpose programming language. Its design philosophy emphasizes code readability with the use of significant indentation. Python is dynamically typed and garbage-collected. It supports multiple programming paradigms, including structured, object-oriented, and functional programming."
generate_resources(sample_text)
