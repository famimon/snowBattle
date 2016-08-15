class Penguin {
  float tilt;             // left and right angle offset
  float scalar;           // height of the body
  float angle = PI/32;    // used to define the tilt 
  float x, y;             // x and y coordinates for the body
  float targetX, targetY;       // center of the target area
  float targetRadius;        // define radius of target area
  boolean KO = false;     // penguin is knockout
  boolean selected=false; // penguin is being controlled
  float KO_LIMIT = 10000; // number of milliseconds the penguin remains K.O.
  float timetag;          // time counter

  // create penguin with center xpos, ypos and size s 
  Penguin (int xpos, int ypos, float s) {
    x = xpos;
    y = ypos;     
    scalar = s /100.0;
    // initialize target area centered in the face
    targetX = xpos;
    targetY = ypos-70*scalar;
    targetRadius = 20*scalar;
  }

  // basic function to calculate distance in between two points
  float distance(float px, float py, float ox, float oy){
    float dx = px - ox;
    float dy = py - oy;
    return sqrt(dx*dx + dy*dy);
  }

  void wobble() {
    float dist = distance(targetX, targetY, x, y);
    if(selected && !KO) {
      // tilt angle is the input from the accelerometer
      tilt = radians(angle);
    }
    else {
      if(KO) {
        // K.O. penguin wobbles faster
        tilt= cos(angle)/16;
        angle += 0.5;
        // back to play after KO_LIMIT milliseconds
        if (millis()-timetag > KO_LIMIT) {
          KO = false;
        }
      }
      else {
        // periodic oscillation
        tilt = cos(angle)/8;
        angle += 0.1;
      }
    }
    // rotate the center of the target area
    targetX = (dist * cos(tilt-PI/2)) + x;
    targetY = (dist * sin(tilt-PI/2)) + y;
  }
  
 
  void checkTarget(float sx, float sy) {
    // if the distance in between the snowball center and the target center is smaller than the target radius the ball has hit in target
    if (distance(sx, sy, targetX, targetY) < targetRadius) {
      KO = true;
      // record the time when the penguin has been hit
      timetag = millis();
    }
  }

  void display () {
    // Display the penguin body
    noStroke();
    pushMatrix();
    translate(x,y);
    rotate(tilt);
    scale(scalar);
    // body
    if (KO) {
      fill(87,173,92);
    }
    else {
      fill(0);
    }
    beginShape();
    vertex (0,-100);
    bezierVertex (25,-100,40,-65,40,-40);
    bezierVertex (40,-15,25,0,0,0);
    bezierVertex (-25,0,-40,-15,-40,-40);
    bezierVertex (-40,-65,-25,-100,0,-100);
    endShape(); 
    // beak
    fill(254,255,5);
    beginShape();
    vertex(-10, -60);
    vertex(0, -50);
    vertex(10, -60);
    endShape();
    fill(255);
    // belly
    ellipse(0,-27,45,40);
    // eyes
    if (!KO) {
      // blink every 10 seconds
      if (second()%10 == 0) {
        fill(0);
      }
      else {
        fill(255);
      }
      ellipse(-10,-65,7,7);
      ellipse(10,-65,7,7);
    } 
    else {
      text("X", -13, -65);
      text("X", 5, -65);
    } 
    popMatrix();
// Draws target area for debugging
//    stroke(255);
//    noFill();
//    strokeWeight(2);
//    ellipse(hitX, hitY, hitRadius*2, hitRadius*2);
  }
}

