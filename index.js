require('dotenv').config() //module to pull Twitter credentials from another file
let chokidar = require('chokidar'); //folder watching module
let Twitter = require('twitter'); //Twitter module
const fs = require('fs'); //access the file system
const path = require('path'); //write path names when moving folders
const rateLimiter = require('limiter').RateLimiter; //rate limiter module
let limiter = new rateLimiter(15, 900000, true); //limit tweets to 15 per 15-minute window

let client = new Twitter({ //Twitter credentials
  consumer_key: process.env.CONSUMER_KEY,
  consumer_secret: process.env.CONSUMER_SECRET,
  access_token_key: process.env.ACCESS_TOKEN,
  access_token_secret: process.env.ACCESS_TOKEN_SECRET
});

//set the folder to be watched to 'pics/awaiting/', only look for png files
let watcher = chokidar.watch('pics/awaiting/*.png', {
  ignored: /(^|[\/\\])\../,
  persistent: true,
  ignoreInitial: false
});

//Start the Twitter posting process when a new image is added
watcher.on('add', imagePath => {
  limiter.removeTokens(1, function(err, remaining) {
    console.log(`${remaining} rate limit tokens remaining`); //log number of remaining API calls
    startPostingProcess(imagePath); //begin process to post to Twitter
  });
});

//function to read image file name and pass it to another function
function startPostingProcess(imagePath) {
  let data = fs.readFileSync(imagePath); //read the image from its location
  console.log(`Found a new file: ${imagePath}`); //log new image location
  twitterUpload(imagePath, data);
}

//function to post the image as a Twitter media object
function twitterUpload(imagePath, data) {
  console.log(`Creating media string`);
  let media = { //create media object with the image file
    media: data
  };
  let status;
  //post media object to Twitter (not in the timeline)
  client.post('media/upload', media, function(error, media, response) {
    if (!error) {
      console.log(`Media string successful`)
      //status message for the tweet
      status = {
        //status: '#grayareashowcase', // Hashtag
        media_ids: media.media_id_string // Pass the media id string
      };
      twitterPost(imagePath, status); //call function to post image to timeline
    } else {
      console.log("Media string response: ", response.body);
      //startPostingProcess(imagePath); //try again because of the error
    }
  });
}

//function to post the image to the Emergence Art account
function twitterPost(imagePath, status) {
  console.log(`Posting to Twitter`);
  //let err, responseCode;
  setTimeout(function() {
    client.post('statuses/update', status, function(error, tweet, response) {
      //responseCode = response.statusCode;
      if (!error) {
        console.log(`Success posting to Twitter: ${response.statusCode}`);
        moveImage(imagePath, error, response.statusCode); //call funtion to move image file
      } else {
        console.log(`Error posting to Twitter: ${response.body}`); //log error code of failed attempt
        //startPostingProcess(imagePath); //try again because of the error
      }
    }, 2000);
  });
}

//function to move image from the 'awaiting' folder to 'sent' folder
function moveImage(imagePath, err, responseCode) {
  console.log(`Moving to sent folder`);
  const imageBaseName = path.basename(imagePath); //base file name
  const newImagePath = path.join('pics', 'sent', imageBaseName); //join base file name with folder path

  fs.rename(imagePath, newImagePath, (err) => { //move image to new folder
    if (err) throw err;
    console.log(`${imagePath} => ${newImagePath}`);
    console.log('****************************************');
  });
}