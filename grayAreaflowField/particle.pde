class Particle {
  PVector pos;
  PVector vel;
  PVector acc;
  int maxSpeed;
  PVector prevPos;
  color lineColor;

  Particle(color c) {
    pos = new PVector(random(width), random(height));
    vel = new PVector(0, 0);
    acc = new PVector(0, 0);
    maxSpeed = 2;
    prevPos = pos.copy();
    lineColor = c;
  }

  void update() {
    vel.add(acc);
    vel.limit(maxSpeed);
    pos.add(vel);
    acc.mult(0);
  }

  void applyForce(PVector force) {
    acc.add(force);
  }

  void show() {
    stroke(lineColor);
    strokeWeight(1);
    //point(pos.x, pos.y);
    line(pos.x, pos.y, prevPos.x, prevPos.y);
    updatePrev();
  }

  void updatePrev() {
    prevPos.x = pos.x;
    prevPos.y = pos.y;
  }

  void edges() {
    if (pos.x > width) {
      pos.x = 0;
      updatePrev();
    }
    if (pos.x < 0) {
      pos.x = width;
      updatePrev();
    }
    if (pos.y > height) {
      pos.y = 0;
      updatePrev();
    }
    if (pos.y < 0) {
      pos.y = height;
      updatePrev();
    }
  }

  void follow(PVector[][] field) {
    int x = floor(pos.x / scl);
    int y = floor(pos.y / scl);
    if (y == height / scl) {
      y = y - 1;
    }
    if (x == width / scl) {
      x = x - 1;
    }
    PVector force = field[y][x];
    applyForce(force);
  }

  //change the color of the line
  void updateColor(color c) {
    lineColor = c;
  }
}
