
// Objects
Mesh mesh;
int mWidth = 100, mHeight = 100;  // heightmap array size
int meshSizeX = 400, meshSizeY = 400;  // mesh size in px
float maxHeight = 255.0;
int incrementor = 0;


void setup() {
  size(1280, 640, P3D);
  //fullScreen(2);
  
  mesh = new Mesh(mWidth, mHeight, meshSizeX, meshSizeY, maxHeight);
  
}

void draw(){
  background(255);
  
  pushMatrix();
    //camera(width/2.0, height, 0.35*(height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0, 0, 1, 0);
    translate(width/2, height/2);
    
    // "Camera Rotations"
    rotateX(map(mouseY, 0, height, 0, HALF_PI));
    rotateZ(map(mouseX, 0, width, -PI, PI));
    //rotateX(QUARTER_PI);
    //rotateZ(0.8*QUARTER_PI + incrementor*PI*5.0/180.0);
    
    mesh.display();
    
  popMatrix();
  
  incrementor++;
}
