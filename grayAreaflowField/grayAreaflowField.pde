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
int transparency = 5; //used to control the transparency of lines drawn on the screen

//Color Variables
int colorNum; //represents the color palette number
color[] colorPalette; //palette of colors used by the particles
int colorIndex; //position in the color palette
color lineColor; //color of the particles

//first color palette
color color1 = color(214, 35, 50, 5);
color color2 = color(17, 54, 90, 5);
color color3 = color(39, 188, 194, 5);
color color4 = color(155, 89, 182, 5); 
color color5 = color(248, 210, 0, 5);
color[] palette1 = {color1, color2, color3, color4, color5};

//second color palette
color color6 = color(213, 71, 51, transparency);
color color7 = color(14, 93, 158, transparency);
color color8 = color(58, 168, 75, transparency);
color color9 = color(236, 196, 23, transparency);
color color10 = color(232, 147, 30, transparency);
color[] palette2 = {color6, color7, color8, color9, color10};

//third color palette
color color11 = color(54, 71, 81, transparency);
color color12 = color(115, 141, 156, transparency);
color color13 = color(244, 238, 226, transparency);
color color14 = color(53, 71, 81, transparency);
color color15 = color(245, 110, 107, transparency);
color[] palette3 = {color11, color12, color13, color14, color15};

//fourth color palette
color color16 = color(60, 0, 232, transparency);
color color17 = color(245, 99, 12, transparency);
color color18 = color(255, 13, 144, transparency);
color color19 = color(13, 185, 255, transparency);
color color20 = color(0, 245, 69, transparency);
color[] palette4 = {color16, color17, color18, color19, color20};

//fifth color palette
color color21 = color(255, 0, 0, transparency);
color color22 = color(255, 102, 0, transparency);
color color23 = color(153, 204, 0, transparency);
color color24 = color(0, 128, 128, transparency);
color color25 = color(0, 51, 102, transparency);
color[] palette5 = {color21, color22, color23, color24, color25};

//sixth color palette
color color26 = color(255, 60, 110, transparency);
color color27 = color(255, 87, 34, transparency);
color color28 = color(255, 202, 44, transparency);
color color29 = color(38, 198, 218, transparency);
color color30 = color(3, 169, 244, transparency);
color[] palette6 = {color26, color27, color28, color29, color30};

void setup() {
  size(1200, 800); //set the size of the drawing
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
  clearScreen = true; //clear screen
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
