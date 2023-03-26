const path = require('path');
const express = require('express');
const morgan = require('morgan');
const vision = require('@google-cloud/vision');
const { Configuration, OpenAIApi } = require("openai");
const axios = require('axios');
const multer = require('multer');
const dotenv = require('dotenv').config();
const sharp = require('sharp');

var storage = multer.diskStorage(
  {
    destination: './uploads/',
    filename: function(req, file, cb) {
      //req.body is empty...
      //How could I get the new_file_name property sent from client here?
      cb(null, "upload" + path.extname(file.originalname));
    }
  }
);

const upload = multer({ storage: storage });
const app = express();
const port = process.env.PORT || 5000;

app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(morgan('dev'));

app.use(express.static(__dirname + '/public'));




const promptGPTName = async (foodList) => {
  const configuration = new Configuration({
    apiKey: process.env.OPEN_AI_KEY,
  });
  const openai = new OpenAIApi(configuration);

  const completion = await openai.createCompletion({
    model: "text-davinci-003",
    prompt: "Give me just the name of the food  from the list not it's category. Pick only food item if it's not a food item say that it's not edible and recommend people dont eat it" + foodList + "\n",
  });
  return completion.data.choices[0].text;


}
const getFood = (foodData) => {

  let foodList = "";
  for (let i = 0; i < foodData.length; i++) {
    foodList = foodList + " " + foodData[i].description
  }
  return foodList

}

const annotator = new vision.ImageAnnotatorClient({ keyFilename: process.env.GOOGLE_CRED })
const annotate = (req, res) => {


  let compressPath = path.join(__dirname, 'uploads', 'compressed.jpeg')
  

  sharp(req.file.path).resize(500, 500).jpeg({ quality: 100, chromaSubsampling: '4:4:4' }).toFile(compressPath)
    .then((fileInfo) => {
      annotator
        .labelDetection(compressPath)
        .then((result) => {
          const labels = result[0].labelAnnotations;
          const foodList = getFood(labels);
          promptGPTName(foodList)
            .then((foodName) => {
              const apiKey = process.env.NUTRITION_KEY;
              const url = `https://api.nal.usda.gov/fdc/v1/foods/search?api_key=${apiKey}&query=${foodName}`
              axios.get(url)
                .then((response) => {
                  const ans = response.data; 
                  const nutrientData = {};
                  if (!ans) {
                    console.error("No such food exists");
                  }
                  else {
                    const food = ans['foods'][0];
                    for (let i = 0; i < food['foodNutrients'].length; i++) {

                      const nutrient = food['foodNutrients'][i];
                      nutrientData[nutrient['nutrientName']] = nutrient['value'];

                    }

                    const stringJSON = JSON.stringify(nutrientData);


                    const configuration = new Configuration({
                      apiKey: process.env.OPEN_AI_KEY,
                    });
                    const openai = new OpenAIApi(configuration);

                    openai.createCompletion({
                      model: "text-davinci-003",
                      prompt: `Give me a short description of ${foodName} and all it's nutritional values which is listed as follows ${nutrientData}. Also tell if it is healthy or not and why?\n`,
                      max_tokens: 400
                    })
                      .then((completion) => {
                        res.send(
                          
                          {
                            name: foodName.slice(1),
                            description: completion.data.choices[0].text.slice(1)
                          }
                          


                        )
                      })
                      .catch((err) => {
                        console.error("Err", err);
                      })

                  }
                })
                .catch((err) => {
                  console.error("Err", err)
                  return null;
                })
            })
            .catch((err) => {
              console.error("Error", err)
            })

        })
        .catch((err) => {
          console.error("Error", err);
        })
    })

}
app.post('/', upload.single('image'), annotate);
;

app.listen(port, () => console.log(`Express app running on port ${port}!`));
