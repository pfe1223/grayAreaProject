let chokidar = require('chokidar');
let Twitter = require('twitter');
const fs = require('fs');
const path = require('path');

let client = new Twitter({
  consumer_key: 'fe96NGOMvwBKK07S5MT7iVaMT',
  consumer_secret: 'rVvk3di9K9r2i8DKmSFIdOC4pdyu8zUe3mtdJPDAOAox4MlgF6',
  access_token_key: '763439881141878784-0z27OGXe37Fl0sxGyiDPSQQSvHXGmUm',
  access_token_secret: '2ceQdt0cbDK7Rwz0rQXmPuocds6QrXwXs5EL1byilfrMl'
});

let watcher = chokidar.watch('pics/awaiting/', {
  ignored: /(^|[\/\\])\../,
  persistent: true,
  ignoreInitial: false
});

function postToTwitter(imagePath) {
  let data = fs.readFileSync(imagePath); //read the image from its location
  console.log(`Found a new file: ${imagePath}`); //log new image location
  twitterUpload(imagePath, data); //upload image to twitter
}

function twitterUpload(imagePath, data) {
  console.log(`Creating media string`);
  let media = {
    media: data
  };
  let status;
  client.post('media/upload', media, function(error, media, response) {
    if (!error) {
      console.log(`Media string successful`)
      // Status message for the tweet
      status = {
        status: '#GrayAreaImmersive', // Hashtag
        media_ids: media.media_id_string // Pass the media id string
      };
      twitterPost(imagePath, status);
    } else {
      console.log(`Media string response: ${response.statusCode}`);
    }
  });
}

function twitterPost(imagePath, status) {
  console.log(`Posting to Twitter`)
  let err, responseCode;
  client.post('statuses/update', status, function(error, tweet, response) {
    if (!error) {
      responseCode = response.statusCode;
      console.log(`Posting response: ${responseCode}`);
    }
  });
  moveImage(imagePath, err, responseCode);
}

function moveImage(imagePath, err, responseCode) {
  console.log(`Moving to sent folder`);
  const imageBaseName = path.basename(imagePath);
  const newImagePath = path.join('pics', 'sent', imageBaseName);

  fs.rename(imagePath, newImagePath, (err) => {
    if (err) throw err;
    console.log(`${imagePath} => ${newImagePath}`);
  });
}

function tryAgain() {

}

watcher.on('add', imagePath => {
  postToTwitter(imagePath);
});