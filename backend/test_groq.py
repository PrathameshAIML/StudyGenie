import os
from dotenv import load_dotenv
from openai import OpenAI

load_dotenv()

print("GROQ_API_KEY present:", bool(os.getenv("GROQ_API_KEY")))

client = OpenAI(
    api_key=os.getenv("GROQ_API_KEY"),
    base_url="https://api.groq.com/openai/v1"
)

try:
    print("Testing openai/gpt-oss-120b...")
    response = client.chat.completions.create(
        model="openai/gpt-oss-120b",
        messages=[
            {"role": "user", "content": "Hello"}
        ]
    )
    print("Response:", response.choices[0].message.content)
except Exception as e:
    print("Error calling openai/gpt-oss-120b:", e)

try:
    print("\nListing models...")
    models = client.models.list()
    for m in models.data:
        print(m.id)
except Exception as e:
    print("Error listing models:", e)
