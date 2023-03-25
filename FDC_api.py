import requests, json

# Set API key
api_key = "gt1BCwZRdKisVBhmCB0WcYKW6jy7T8dzPSwdJOJO"

def call_API(foodName, apiKey):
    url = f'https://api.nal.usda.gov/fdc/v1/foods/search?api_key={apiKey}&query={foodName}'
    r = requests.get(url)
    if r.status_code == 200:
        print("nice 1")
    return r.json()

ans = call_API("apple", api_key)
food = ans['foods'][0]  
print(f"\nFood name: {food['description']}")
for nutrient in food['foodNutrients']:
    print(f"{nutrient['nutrientName']}: {nutrient['value']} {nutrient['unitName']}")

