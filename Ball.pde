class Ball {
  float gravity   = 0.3; // gravity factor
  float stiffness = 0.2; // stiffness factor
  float vx, vy;          // The x and y velocities
  float x, y;            // The x and y coordinates
  float radius = 10;     // Ball's radius
 
  Ball(float xin, float yin) {
    x = xin;
    y = yin;
  } 
 
  void update(float targetX, float targetY) {
    float ax = ((targetX - x)/5) * stiffness;
    vx += ax;
    x += vx;
    float ay = ((targetY - y)/5) * stiffness + gravity;
    vy += ay;
    y += vy; 
  }
  
  void shoot() {
    vy += gravity;
    x += vx;
    y += vy;        
  }
  
  void display() {
    fill(255);
    ellipse(x, y, radius*2, radius*2);
  }
}
