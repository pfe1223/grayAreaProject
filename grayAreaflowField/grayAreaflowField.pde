import processing.serial.*; //library to use the serial port

import gohai.simpletweet.*; //library to post to Twitter

//think about changing the "rules of the game"
//stronger connection to incentives in the piece
//think about what the particle should be
//maybe the "rules" change over time
//AvenirNext Bold for the title
//AvenirNext Regular for the instructions

Serial myPort;
SimpleTweet simpletweet;
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
  titleFont = loadFont("AvenirNext-Bold-48.vlw");
  bodyFont = loadFont("AvenirNext-Medium-36.vlw");

  for (int i = 0; i < 10000; i++) {
    particles.add(new Particle(lineColor));
  }

  println(Serial.list());
  myPort = new Serial(this, Serial.list()[1], 115200);
  myPort.bufferUntil('\n');

  simpletweet = new SimpleTweet(this); //Twitter variable
  
  //Twitter credentials
  simpletweet.setOAuthConsumerKey("fe96NGOMvwBKK07S5MT7iVaMT");
  simpletweet.setOAuthConsumerSecret("rVvk3di9K9r2i8DKmSFIdOC4pdyu8zUe3mtdJPDAOAox4MlgF6");
  simpletweet.setOAuthAccessToken("763439881141878784-0z27OGXe37Fl0sxGyiDPSQQSvHXGmUm");
  simpletweet.setOAuthAccessTokenSecret("2ceQdt0cbDK7Rwz0rQXmPuocds6QrXwXs5EL1byilfrMl");

  background(255);
}

//read data from the serial port
void serialEvent(Serial myPort) {
  //read until the '\n' character
  String inString = myPort.readStringUntil('\n');

  if (inString != null) { //only do something if data came across serial port
    inString = trim(inString); //remove white space
    println(inString); //write to console
    if (inString.equals("L") || inString.equals("R")) { //check for L/R gesture
      changeZoff(); //change flow field pattern
      changeLineColor(); //change particle color
    } else if (inString.equals("D")) { //check for down gesture
      println("down swipe");
      downSwipe();
    }
  }
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

  float yoff = 0;
  for (int y = 0; y < rows; y++) {
    float xoff = 0;
    for (int x = 0; x < cols; x++) {
      float angle = noise(xoff, yoff, zoff) * TWO_PI * 3;
      PVector v = PVector.fromAngle(angle);
      v.setMag(0.5);
      flowfield[y][x] = v;
      xoff += inc;
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
    yoff += inc;
  }

  for (Particle part : particles) {
    part.follow(flowfield);
    part.update();
    part.edges();
    part.show();
    part.updateColor(colorPalette[colorIndex]);
  }
}

void changeZoff() {
  zoff += random(0.005, 1);
}

//change the color of the lines
void changeLineColor() {
  colorIndex++;
  if (colorIndex > colorPalette.length - 1) {
    colorIndex = 0;
  }
  //color c = colorPalette[colorIndex];
  //for (Particle part : particles) {
  //  part.updateColor(c);
  //}
}

void keyPressed() {
  if (showInstructions) {
    if (keyCode == LEFT || keyCode == RIGHT || keyCode == UP || keyCode == DOWN) {
      removeInstructions();
    }
  } else if (keyCode == LEFT || keyCode == RIGHT) {
    sideSwipe();
  } else if (keyCode == UP) {
    upSwipe();
  } else if (keyCode == DOWN) {
    downSwipe();
  }
}

//remove instructions from the screen
void removeInstructions() {
  background(255);
  showInstructions = false;
}

//change color of the particles on a left/right gesture
void sideSwipe() {
  changeZoff();
  changeLineColor();
}

//show instructions on an up gesture
void upSwipe() {
  background(255);
  showInstructions = true;
}

//clear canvas, send tweet, and change color on a down gesture
void downSwipe() {
  String tweet = simpletweet.tweetImage(get(), "#GrayAreaSpringImmersive2018");
  println("Posted " + tweet);
  background(255);
  colorNum++;
  if (colorNum > 6) {
    colorNum = 1;
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
