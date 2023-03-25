import requests, json

def call_API(foodName, apiKey):
    url = f'https://api.nal.usda.gov/fdc/v1/foods/search?api_key={apiKey}&query={foodName}'
    r = requests.get(url)
    if r.status_code == 200:
        print("nice 1")
    return r.json()

def extract_food_data(foodName, api_key):
    nutrient_data = dict()
    ans = call_API("apples", api_key)
    if not ans:
        print("no such food exists")
        return None
    food = ans['foods'][0]  
    
    for nutrient in food['foodNutrients']:
        nutrient_data[nutrient['nutrientName']] = nutrient['value']
    return food['description'], nutrient_data

def main():
    # set API key
    api_key = "gt1BCwZRdKisVBhmCB0WcYKW6jy7T8dzPSwdJOJO"
    foodName = "apple"

    food_actual, data = extract_food_data(foodName, api_key)
    print(f"\nFood's name: {food_actual}")
    print(data)

if __name__ == '__main__':
    main()