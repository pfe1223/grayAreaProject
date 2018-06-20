//fs rename to move, don't need Sync version
//

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

watcher.on('add', imagePath => {
  //read the image from its location
  let data = fs.readFileSync(imagePath);

  console.log(`Found a new file: ${imagePath}`);

  //post the image to Twitter
  client.post('media/upload', {
    media: data
  }, function(error, media, response) {

    if (!error) {

      // If successful, a media object will be returned.
      //console.log(media);

      // Lets tweet it
      let status = {
        status: '#GrayAreaImmersive',
        media_ids: media.media_id_string // Pass the media id string
      }

      client.post('statuses/update', status, function(error, tweet, response) {
        if (!error) {
          //console.log(tweet);
          console.log("Twitter response status: " + response.statusCode);
          if (response.statusCode === 200) {
            //move tweeted image to sent folder
            // console.log(`path: ${imagePath}`);
            const imageBaseName = path.basename(imagePath);
            const newImagePath = path.join('pics', 'sent', imageBaseName);

            fs.rename(imagePath, newImagePath, (err) => {
              if (err) throw err;
              console.log(`${imagePath} => ${newImagePath}`);
            });
          }
        }
      });

    } else {
      console.log(`There is an error: ${error}`);
    }
  });
});