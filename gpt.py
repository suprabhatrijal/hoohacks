import openai
import re

openai.api_key = "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"

def extract_text(text):
  text = re.sub(r'http\S+', '', text) # Remove URLs
  text = re.sub(r'[^\w\s]', '', text) # Remove punctuation
  text = text.split(' ', 1)[1]
  return str(text)

def get_openai_response(text):
  text = extract_text(text)
  hehe = "Give me just the name of the food (not the classification) from the description: " + text
  response = openai.Completion.create(
      model="text-davinci-003",
      prompt=hehe,
      temperature=0,
      max_tokens=100
  )
  return response.choices[0].text

test = 'Food , Fruit, Natural foods, Apple, Seedless fruit, Superfood, Produce, Flowering plant, Rose family, Plant'
print(get_openai_response(test))