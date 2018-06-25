import processing.serial.*; //library to use the serial port

Serial myPort; //variable for the serial port
PFont titleFont; //variable for the font used as the title in the instructions
PFont bodyFont; //variable for the font used as the body of the instructions
float inc = 0.1; //variable for amount to be incremented
int scl = 10; //variable for the scale of the grid for the flow field
int cols, rows; //variables for the number of columns and rows
float zoff = 0; //variable for the z-offset in the Perlin noise
ArrayList<Particle> particles = new ArrayList<Particle>(); //variable for the array for the particles
PVector[][] flowfield; //variable for the 2D array that holds the flow field
boolean showInstructions = false; //variable used for showing the instructions
boolean clearScreen = false; //variable used to clear the screen
int gap = 30; //gap between instruction page and the edge of the screen
boolean tweetSent = false; //used to show a message once an image has been posted to Twitter
int transparency = 5; //transparency attribute for lines drawn to the screen
int now; //number of milliseconds at the exact moment
int timer; //number of milliseconds until an event ends

void setup() {
  size(1650, 1100); //set the size of the drawing
  cols = floor(width/scl); //calculate number of columns
  rows = floor(height/scl); //calculate number of rows
  flowfield = new PVector[rows][cols]; //make 2D array with rows and columns
  colorIndex = 0; //use first color in the array
  colorNum = 1; //use the first color palette
  colorPalette = palette1;
  lineColor = colorPalette[colorIndex]; //set the particle color
  titleFont = loadFont("AvenirNext-Bold-100.vlw"); //font for title in instructions
  bodyFont = loadFont("AvenirNext-Regular-65.vlw"); //font for instructions

  //add 10,000 particles to the flow field
  for (int i = 0; i < 10000; i++) {
    particles.add(new Particle(lineColor));
  }

  println(Serial.list()); //print list of available serial connections
  myPort = new Serial(this, Serial.list()[1], 115200); //connect to second serial connection
  myPort.bufferUntil('\n'); //read until an end of line character

  background(255); //set the screen to white
}

//read data from the serial port
void serialEvent(Serial myPort) {

  String inString = myPort.readStringUntil('\n'); //read until the '\n' character

  if (inString != null) { //only do something if data came across serial port
    inString = trim(inString); //remove white space
    println("Swipe direction: " + inString); //write to console
    if (showInstructions) { //if instructions are on the page, then any gesture will remove them
      if (inString.equals("L") || inString.equals("R") || inString.equals("U") || inString.equals("D")) {
        removeInstructions(); //call function to remove the instructions
      }
    } else if (inString.equals("L") || inString.equals("R")) { //check for L/R gesture
      changeZoff(); //change flow field pattern
      changeLineColor(); //change particle color
    } else if (inString.equals("D")) { //check for down gesture
      downSwipe(); //call function to save image and start a new one
    } else if (inString.equals("U")) { //check for up swipe
      upSwipe(); //call function to show instructions
    }
  }
}

void draw() {
  //background(255);
  if (clearScreen) { //clear the screen
    clearScreen = false;
    background(255);
  }

  if (tweetSent) {
    background(255); //clear the screen
    rectMode(CENTER); //draw rectangle from its center
    noStroke(); //turn off the stroke
    fill(0, 10); //fill with a very transparent white
    rect(width/2, height/2, width - gap, height - gap, 10); //draw a rectangle that is 40px smaller than the screen on all sides
    textAlign(CENTER, CENTER); //center the text
    fill(0); //use black for the text
    textFont(titleFont); //use the larger font for the title
    text("Tweet Sent", width/2, height*0.30); //title for the screen
    textFont(bodyFont); //switch to a smaller font for the rest of the instructions
    text("Find your image at", width/2, height*0.45); //Twitter account to find the drawing
    text("@emergence_art", width/2, height*0.55); //Twitter account to find the drawing
    if (millis() > timer) { //checks to see if the current time is great than the timer
      tweetSent = false; //set value back to default
      background(255); //remove tweet sent message
    }
  }

  if (showInstructions) { //write the instuctions to the screen
    background(255); //clear the screen
    rectMode(CENTER); //draw rectangle from its center
    noStroke(); //turn off the stroke
    fill(0, 10); //fill with a very transparent white
    rect(width/2, height/2, width - gap, height - gap, 10); //draw a rectangle that is 40px smaller than the screen on all sides
    textAlign(CENTER, CENTER); //center the text
    fill(0); //use black for the text
    textFont(titleFont); //use the larger font for the title
    text("Emergence", width/2, height*0.20); //title for the screen
    textFont(bodyFont); //switch to a smaller font for the rest of the instructions
    text("Swipe left/right to change the image", width/2, height*0.35); //how to alter the drawing
    text("Swipe down to tweet your image", width/2, height*0.50); //how to tweet the drawing
    text("Find your image at @emergence_art", width/2, height*0.65); //hashtag to find the drawing
    text("Swipe to return to the image", width/2, height*0.80); //how to return to the drawing
  }

  float yoff = 0; //set the y-offset to 0
  for (int y = 0; y < rows; y++) { //loop through the rows of the 2D array
    float xoff = 0; //set the x-offset to 0
    for (int x = 0; x < cols; x++) { //loop through colomns of the 2D array
      float angle = noise(xoff, yoff, zoff) * TWO_PI * 3; //create angle from perlin noise
      PVector v = PVector.fromAngle(angle); //create vector from the angle
      v.setMag(0.5); //set magnitude of the vector
      flowfield[y][x] = v; //assign the vector to the 2D array
      xoff += inc; //increment the x-offset
      //***************
      //draw the flow field to the canvas
      //be sure to uncomment the 'background(255)'
      //command at the top of draw to see the 
      //flow field
      //***************
      //stroke(0, 100);
      //pushMatrix();
      //translate(x*scl, y*scl);
      //rotate(v.heading());
      //strokeWeight(1);
      //line(0, 0, scl, 0);
      //popMatrix();
      //***************
      //end of drawing flow field
      //***************
    }
    yoff += inc; //increment the y-offset
  }

  //loop through particles
  for (Particle part : particles) {
    part.follow(flowfield); //get new force from vector in 2D array
    part.update(); //update position of the particle accroding to the force
    part.edges(); //move particle to opposite if off the screen
    part.show(); //draw the particle to the screen
    part.updateColor(colorPalette[colorIndex]); //set the color of the particle
  }
}

//change the path of the particle, called on left/right gesture
void changeZoff() {
  zoff += random(0.005, 1);
}

//change the color of the lines
void changeLineColor() {
  colorIndex++; //move to the next color
  if (colorIndex > colorPalette.length - 1) {
    colorIndex = 0; //go back to beginning of color palette if the index is too big
  }
}

//used in place of the gesture swipes
void keyPressed() {
  //if instructions are on the page, then any gesture will remove them
  if (showInstructions) {
    if (keyCode == LEFT || keyCode == RIGHT || keyCode == UP || keyCode == DOWN) {
      removeInstructions();
    }
  } else if (keyCode == LEFT || keyCode == RIGHT) {
    sideSwipe(); //called on left/right arrow (left/right gesture)
  } else if (keyCode == UP) {
    upSwipe(); //called on up arrow (up gesture)
  } else if (keyCode == DOWN) {
    downSwipe(); //called on down arrow (down gesture)
  }
}

//remove instructions from the screen
void removeInstructions() {
  clearScreen = true; //clear screen
  showInstructions = false; //remove instructions
}

//change color of the particles on a left/right gesture
void sideSwipe() {
  changeZoff(); //alter path of particle
  changeLineColor(); //change particle color
}

//show instructions on an up gesture
void upSwipe() {
  clearScreen = true; //clear screen
  showInstructions = true; //add the instructions
}

//clear canvas, send tweet, and change color on a down gesture
void downSwipe() {
  saveImage(); //call the function that saves the image
  changeColorPalette(); //call the function that changes the color palette
  tweetSent = true; //post message to screen that image has been tweeted
  now = millis(); //current time right now
  timer = now + 5000; //5 seconds in the future
}

//change the color palette
void changeColorPalette() {
  colorNum++; //increment variable that controls the color palette
  if (colorNum > 6) {
    colorNum = 1; //if at the end of the palette list, start at the beginning
  }
  if (colorNum == 1) {
    colorPalette = palette1; //use the first color palette
  } else if (colorNum == 2) {
    colorPalette = palette2; //use the second color palette
  } else if (colorNum == 3) {
    colorPalette = palette3; //use the third color palette
  } else if (colorNum == 4) {
    colorPalette = palette4; //use the fourth color palette
  } else if (colorNum == 5) {
    colorPalette = palette5; //use the fifth color palette
  } else if (colorNum == 6) {
    colorPalette = palette6; //use the sixth color palette
  }
}

//save the screen as an image in the 'awaiting' folder
void saveImage() {
  //create a unique file name (day-minute-milisecond) for the image
  String picName = "../pics/awaiting/image-" + str(day()) + "-" + str(minute()) + "-" + str(millis()) + ".png";
  save(picName); //save the image
}
