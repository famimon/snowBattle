//     SNOW BATTLE
// Authors: Susanne Chan & David Montero
//
// Simple shoot & dodge game, shoot snow balls with one iphone while with the other player will try to avoid them using the second iphone's accelerometer
//
// *Attacker controls:
// -Use the trackpad to set the direction of the ball aiming to the penguins face, the longer the fingerstroke the more power you add to the shot, like an slingshot
// -Press "FIRE!!" button to throw the ball
//
// *Defender controls:
// -Choose one of the 3 penguins using the numbered buttons
// -Use the accelerometer to steer to left and right
//
// When a penguin is hit will remain KO for 10 seconds

import oscP5.*;
import netP5.*;
import processing.video.*;

MovieMaker mm;
OscP5 P1, P2;                     // controllers
float x, y;                       // Snowball coordinates
Ball snowball;                    // The snowball
int[] heights;                    // array of high points to create a random background
Penguin[] pingu = new Penguin[3]; // Array of penguins
int gap = 50;                     // gap between ice peaks in the background
boolean shot = false;             // Ball has been shot
boolean touched = false;          // trackpad has been touched
int select = -1;                  // selected penguin
int port = 0;                     // port for the defending controller to discriminate unneeded accxyz messages



void setup() {
  size(600,200);
  mm = new MovieMaker(this, width, height, "capture.mov", 30, MovieMaker.H263, MovieMaker.HIGH);
  // generate peaks to draw the background
  heights = new int[width/gap];
  for (int i = 0; i < heights.length; i++) {
    heights[i] = height - int(random(50, 100));
  }
  // create OSC objects for the controllers, listening in two different ports
  P1 = new OscP5(this,8000);
  P2 = new OscP5(this,8001);
  // create the penguins with random sizes
  for (int i = 0; i < pingu.length; i++) {
    pingu[i]= new Penguin(i*(width/pingu.length)+100, height,random(60,90));
  }
  smooth();
}

void draw() {
  // display the background
  drawBackground();
  // display and oscillate the penguins
  for (int i = 0; i < pingu.length; i++) {
    pingu[i].wobble();
    pingu[i].display();
  }
  // display the snowball when shot
  if (shot) {
    snowball.shoot();
    snowball.display();
    // check if the snowball hits the target
    for (int i = 0; i < pingu.length; i++) {
      pingu[i].checkTarget(snowball.x,snowball.y);
    }
  }
  mm.addFrame();
}

void drawBackground() {
  // Sky
  background(34, 41, 209);
  noStroke();
  // Ice hills
  fill(206, 220, 222);
  int j=0;
  beginShape();
  vertex(0,height);
  vertex(1,height-20);
  for (int i=gap; i < width; i+=gap) {
    vertex(i, heights[j++]);
  }
  vertex(width-1, height-30);
  vertex(width, height);
  endShape(OPEN);
}

void oscEvent(OscMessage msg) {
  String addr = msg.addrPattern();
  // Defender
  // check which penguin is selected
  if (addr.indexOf("pingu0")!=-1){
    // tag the selected penguin
    select = 0; 
    // grab the port number to capture the accxyz messages
    port = msg.port(); 
    // mark the penguin as selected and the others as not
    pingu[0].selected=true;    
    pingu[1].selected=false;    
    pingu[2].selected=false;    
  } else if (addr.indexOf("pingu1")!=-1){
    select = 1;   
    port = msg.port(); 
    pingu[0].selected=false;    
    pingu[1].selected=true;    
    pingu[2].selected=false;
  } else if (addr.indexOf("pingu2")!=-1){
    select = 2;
    port = msg.port();
    pingu[0].selected=false;    
    pingu[1].selected=false;    
    pingu[2].selected=true;
  } else if ((msg.checkAddrPattern("/accxyz")==true)&&(select >= 0)&&(msg.port()==port)) {
    // handle the selected penguin using the accelerometer, rotate it in the Y-axis
    pingu[select].angle = (msg.get(1).floatValue()*90*-1);
  
  // Attacker
  } else if (addr.indexOf("pad")!=-1) {
    // begin new shot
    shot = false;
    // update x, and y coordinates with the trackpad positions
    x = msg.get(1).floatValue() * width;
    y = msg.get(0).floatValue() * height/2;
    // if first time touched create the Ball object
    if (!touched) {
      snowball = new Ball(x, y);
      touched = true;
    }
  } else if (addr.indexOf("fire")!=-1) {
    // when shot pressed update the ball taking the creation position as origin and the current position as target
    snowball.update(x, y);
    // begin new aim
    touched = false;
    // mark as shot 
    shot = true;   
  }
}

void stop() { 
  mm.finish();
  super.stop();
}
