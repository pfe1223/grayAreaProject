import websockets.*;
import processing.serial.*; //library to use the serial port

//think about changing the "rules of the game"
//stronger connection to incentives in the piece
//think about what the particle should be
//maybe the "rules" change over time
//AvenirNext Bold for the title
//AvenirNext Regular for the instructions
//chokidar module will watch a directory and send a callback on a new file
//use Twitter module to tweet image on the above callback

Serial myPort;
WebsocketClient wsc;
PFont titleFont;
PFont bodyFont;
float inc = 0.1;
int scl = 10;
int cols, rows;
float zoff = 0;
ArrayList<Particle> particles = new ArrayList<Particle>();
PVector[][] flowfield;
boolean showInstructions = false;

//Color Variables
int colorNum; //represents the color palette number
color[] colorPalette; //palette of colors used by the particles
int colorIndex; //position in the color palette
color lineColor; //color of the particles

color color1 = color(214, 35, 50, 5);
color color2 = color(17, 54, 90, 5);
color color3 = color(39, 188, 194, 5);
color color4 = color(240, 242, 239, 5);
color color5 = color(248, 210, 0, 5);
color[] palette1 = {color1, color2, color3, color4, color5};

color color6 = color(213, 71, 51, 5);
color color7 = color(14, 93, 158, 5);
color color8 = color(58, 168, 75, 5);
color color9 = color(236, 196, 23, 5);
color color10 = color(232, 147, 30, 5);
color[] palette2 = {color6, color7, color8, color9, color10};

color color11 = color(54, 71, 81, 5);
color color12 = color(115, 141, 156, 5);
color color13 = color(244, 238, 226, 5);
color color14 = color(53, 71, 81, 5);
color color15 = color(245, 110, 107, 5);
color[] palette3 = {color11, color12, color13, color14, color15};

color color16 = color(60, 0, 232, 5);
color color17 = color(245, 99, 12, 5);
color color18 = color(255, 13, 144, 5);
color color19 = color(13, 185, 255, 5);
color color20 = color(0, 245, 69, 5);
color[] palette4 = {color16, color17, color18, color19, color20};

color color21 = color(255, 0, 0, 5);
color color22 = color(255, 102, 0, 5);
color color23 = color(153, 204, 0, 5);
color color24 = color(0, 128, 128, 5);
color color25 = color(0, 51, 102, 5);
color[] palette5 = {color21, color22, color23, color24, color25};

color color26 = color(255, 60, 110, 5);
color color27 = color(255, 87, 34, 5);
color color28 = color(255, 202, 44, 5);
color color29 = color(38, 198, 218, 5);
color color30 = color(3, 169, 244, 5);
color[] palette6 = {color26, color27, color28, color29, color30};

void setup() {
  size(1200, 800, P2D);
  cols = floor(width/scl);
  rows = floor(height/scl);
  flowfield = new PVector[rows][cols];
  colorIndex = 0; //use first color in the array
  colorNum = 1; //use the first color palette
  colorPalette = palette1;
  lineColor = colorPalette[colorIndex]; //set the particle color
  titleFont = loadFont("AvenirNext-Bold-48.vlw"); //font for title in instructions
  bodyFont = loadFont("AvenirNext-Medium-36.vlw"); //font for instructions

  //add 10,000 particles
  for (int i = 0; i < 10000; i++) {
    particles.add(new Particle(lineColor));
  }

  println(Serial.list()); //print list of available serial connections
  myPort = new Serial(this, Serial.list()[1], 115200); //connect to second serial connection
  myPort.bufferUntil('\n'); //read until an end of line character
  
  wsc= new WebsocketClient(this, "ws://localhost:3000/mysocket");

  background(255); //set the screen to white
}

//read data from the serial port
void serialEvent(Serial myPort) {
  
  String inString = myPort.readStringUntil('\n'); //read until the '\n' character

  if (inString != null) { //only do something if data came across serial port
    inString = trim(inString); //remove white space
    println(inString); //write to console
    if (inString.equals("L") || inString.equals("R")) { //check for L/R gesture
      changeZoff(); //change flow field pattern
      changeLineColor(); //change particle color
    } else if (inString.equals("D")) { //check for down gesture
      println("down swipe"); //log the down swipe
      downSwipe(); //call function to save image and start a new one
    }
  }
}

void webSocketEvent(String msg){
 println("Got a websockets message: " + msg); //print websockets message when received
}

void draw() {
  //background(255);
  if (showInstructions) {
    background(255);
    rectMode(CENTER);
    noStroke();
    fill(0, 10);
    rect(width/2, height/2, width - 40, height - 40, 10);
    textAlign(CENTER, CENTER);
    fill(0);
    textFont(titleFont);
    text("Emergence", width/2, height*0.2);
    textFont(bodyFont);
    text("Swipe left or right to change the flow field", width/2, height*0.3);
    text("Swipe down to tweet the flow field", width/2, height*0.375);
    text("Check #GrayAreaSpringImmersive2018", width/2, height*0.45);
    text("Swipe any direction to return to the flow field", width/2, height*0.525);
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
  background(255); //clear screen
  showInstructions = false; //remove instructions
}

//change color of the particles on a left/right gesture
void sideSwipe() {
  changeZoff(); //alter path of particle
  changeLineColor(); //change particle color
}

//show instructions on an up gesture
void upSwipe() {
  background(255); //clear screen
  showInstructions = true; //add the instructions
}

//clear canvas, send tweet, and change color on a down gesture
void downSwipe() {
  //save image with unique file name
  save("../pics/image-" + str(day()) + "-" + str(minute()) + "-" + str(millis()) + ".png");
  wsc.sendMessage("Processing saved an image");
  background(255); //clear screen
  colorNum++; //change color palette
  if (colorNum > 6) {
    colorNum = 1; //if at the end of the palette list, start at the beginning
  }
  if (colorNum == 1) {
    colorPalette = palette1;
  } else if (colorNum == 2) {
    colorPalette = palette2;
  } else if (colorNum == 3) {
    colorPalette = palette3;
  } else if (colorNum == 4) {
    colorPalette = palette4;
  } else if (colorNum == 5) {
    colorPalette = palette5;
  } else if (colorNum == 6) {
    colorPalette = palette6;
  }
}
