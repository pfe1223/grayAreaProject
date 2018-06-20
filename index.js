//fs 

let chokidar = require('chokidar');
let Twitter = require('twitter');
const WebSocket = require('ws');
const wss = new WebSocket.Server({
  port: 3000
});

let client = new Twitter({
  consumer_key: 'fe96NGOMvwBKK07S5MT7iVaMT',
  consumer_secret: 'rVvk3di9K9r2i8DKmSFIdOC4pdyu8zUe3mtdJPDAOAox4MlgF6',
  access_token_key: '763439881141878784-0z27OGXe37Fl0sxGyiDPSQQSvHXGmUm',
  access_token_secret: '2ceQdt0cbDK7Rwz0rQXmPuocds6QrXwXs5EL1byilfrMl'
});

wss.on('connection', function connection(ws) {
  ws.on('message', function incoming(message) {
    console.log('callback received: %s', message)
    if (message[0] === "." && message[1] === ".") { //check to see if image path was sent
      console.log("got an image path");
      let path = message.substring(3); //remove the '../' from image file name
      let data = require('fs').readFileSync(path); //read the image file
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
              console.log("Twitter response status: " + response.statusCode); //log status code of tweet
              if (response.statusCode === 200) {
                ws.send("Node sent a tweet"); //tweet confirmation
              }
            }
          });

        } else {
          console.log(`There is an error: ${error}`); //log Twitter posting error(s)
        }
      });
    }
  });
  ws.send('Connected to websockets'); //initial websocket connection message
});

// let watcher = chokidar.watch('pics/', {
//   ignored: /(^|[\/\\])\../,
//   persistent: true
// });

// watcher.on('change', path => {
//   //read the image from its location
//   let data = require('fs').readFileSync(path);
//
//   //post the image to Twitter
//   client.post('media/upload', {
//     media: data
//   }, function(error, media, response) {
//
//     if (!error) {
//
//       // If successful, a media object will be returned.
//       //console.log(media);
//
//       // Lets tweet it
//       let status = {
//         status: '#GrayAreaImmersive',
//         media_ids: media.media_id_string // Pass the media id string
//       }
//
//       client.post('statuses/update', status, function(error, tweet, response) {
//         if (!error) {
//           //console.log(tweet);
//           console.log("Twitter response status: " + response.statusCode);
//           // wbs.send("successful tweet", function() {
//           //   console.log("Sent websockets message")
//           // });
//         }
//       });
//
//     } else {
//       console.log(`There is an error: ${error}`);
//     }
//   });
// });