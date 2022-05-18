// A class to store triangle data

class Quad {
  PShape triangle1_, triangle2_;
  color quad_col;
  PVector draw_pos;
  
  
  //  0--1
  //  | /|
  //  |/ |
  //  2--3
  Quad(PVector heights01, PVector heights23, PVector position, PVector size) {
    /*PVector pos0, pos1, pos2, pos3;
    pos0 = new PVector(     0,      0, heights01.x);
    pos1 = new PVector(size.x,      1, heights01.y);
    pos2 = new PVector(     0, size.y, heights23.x);
    pos3 = new PVector(size.x, size.y, heights23.y);*/
    
    draw_pos = position;
    
    // Generate 0-1-2 triangle
    triangle1_ = createShape();
    triangle1_ = createShape();
    triangle1_.beginShape();
      triangle1_.fill(200);
      triangle1_.stroke(0);
      triangle1_.strokeWeight(1);
      /*triangle1_.vertex(pos0.x, pos0.y, pos0.z);
      triangle1_.vertex(pos1.x, pos1.y, pos1.z);
      triangle1_.vertex(pos2.x, pos2.y, pos2.z);*/
      triangle1_.vertex(     0,      0, heights01.x);  // vertex 0
      triangle1_.vertex(size.x,      0, heights01.y);  // vertex 1
      triangle1_.vertex(     0, size.y, heights23.x);  // vertex 2
    triangle1_.endShape(CLOSE);
    
    // Generate 1-2-3 triangle
    triangle2_ = createShape();
    triangle2_ = createShape();
    triangle2_.beginShape();
      triangle2_.fill(200);
      triangle2_.stroke(0);
      triangle2_.strokeWeight(1);
      /*triangle2_.vertex(pos1.x, pos1.y, pos1.z);
      triangle2_.vertex(pos2.x, pos2.y, pos2.z);
      triangle2_.vertex(pos3.x, pos3.y, pos3.z);*/
      triangle2_.vertex(size.x,      0, heights01.y);  // vertex 1
      triangle2_.vertex(     0, size.y, heights23.x);  // vertex 2
      triangle2_.vertex(size.x, size.y, heights23.y);  // vertex 3
    triangle2_.endShape(CLOSE);
  }
  
  void enableWireMesh() {
    triangle1_.setStroke(0);
    triangle2_.setStroke(0);
  }
  void disableWireMesh() {
    triangle1_.setStroke(quad_col);
    triangle2_.setStroke(quad_col);
  }
  
  void setQuadColour(color c) {
    quad_col = c;
    triangle1_.setFill(c);
    triangle2_.setFill(c);
  }
  
  void display() {
    pushMatrix();
      translate(draw_pos.x, draw_pos.y);
      shape(triangle1_);
      shape(triangle2_);
    popMatrix();
  }
}
