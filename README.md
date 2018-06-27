# Emergence

## About
This project is the culmination of my time at the Gray Area 2018 Spring Immersive.

## What
Emergence examines how changes to external incentives affect individual and group behavior. Mounted on the box is a gesture sensor. Swipe your hand to interact with "Emergence". 
* Swipe up for instructions. 
* Swipe your hand left or right to alter the incentives. 
* Swipe down to send the image your incentives created to Twitter. 
* You can find these images at @emergence_art or #grayareashowcase.

## Hardware
* [ESP32 microcontroller](https://www.adafruit.com/product/3591)
* [APDS9960 Gesture Sensor](https://www.adafruit.com/product/3595)
* [Wooden Box](https://www.woodcraft.com/products/walnut-hollow-basswood-box-3-98in-x-5-83in-x-3-94in) drilled to accomodate the gesture sensor and the microcontroller
* Micro USB cable
* Computer to run the software

## Software
* Adruino - reads the gesture sensor and sends a message ("L", "R", "U", or "D") to Processing via the serial port
* Processing - creates a flow field for particles
