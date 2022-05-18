// A Mesh Class

// https://lospec.com/palette-list/dr-20
color dark_water = #243447;
color water = #6dbce3;
color sand = #fad882;
color grass = #a8db60;
color forest = #428764;
color stone = #738078;
color snow = #fffbf2;

color line_col = #37333b;


//
class Mesh {
  float[][] heightMap_;
  ArrayList<Quad> mesh_;
  
  Mesh(int heightMapSizeX, int heightMapSizeY, int meshSizeXpx, int meshSizeYpx, float maxHeight){
    
    mesh_ = new ArrayList<Quad>();
    GenerateHeightMap(heightMapSizeX, heightMapSizeY);
    
    int meshResX = heightMap_.length;
    int meshResY = heightMap_[0].length;
    
    float quadSizeX = (float) meshSizeXpx/meshResX;
    float quadSizeY = (float) meshSizeYpx/meshResY;
    
    for (int x = 0; x < heightMap_.length-1; x++) {
      float x_pos = -meshSizeXpx/2 + x*quadSizeX;
      for (int y = 0; y < heightMap_[0].length-1; y++) {
        float y_pos = -meshSizeYpx/2 + y*quadSizeY;
        
        // calc vertex heights
        PVector height01 = new PVector(heightMap_[x][y], heightMap_[x+1][y]);
        PVector height23 = new PVector(heightMap_[x][y+1], heightMap_[x+1][y+1]);
        height01.mult(maxHeight);
        height23.mult(maxHeight);
        
        // Create quad object
        Quad q = new Quad(height01, height23, new PVector(x_pos,y_pos), new PVector(quadSizeX, quadSizeY));
        
        // Calc quad color
        color c = returnHeightColor(heightMap_[x][y]);
        // Set quad color
        q.setQuadColour(c);
        q.disableWireMesh();
        
        // Add quad to mesh
        mesh_.add(q);
      }
    }
  }
  
  void GenerateHeightMap(int numElementsX, int numElementsY) {
    // Generate heightMap
    heightMap_ = new float[numElementsX][numElementsY];
    
    float increment = 0.05;
    float xoff = 0.0;
    for (int x = 0; x < numElementsX; x++) {
      xoff += increment;
      float yoff = 0.0;
      for(int y = 0; y < numElementsY; y++) {
        yoff += increment;
        //float h_val = noise(xoff,yoff);
        //float bump = 1.25 - 1.5*(1 - pow((2.0*x/width - 1.0),2) ) * (1 - pow((2.0*y/height - 1.0),2));
        //heightMap_[x][y] = (h_val + (1-bump))/2;
        heightMap_[x][y] = noise(xoff,yoff);
      }
    }
  }
  
  void display() {
    for(Quad q : mesh_) {
      q.display();
    }
  }
  
  color returnHeightColor(float heightVal) {
    color pixel_col = #000000;
    if (heightVal < 0.3) {
      float rnd_depth = round(map(heightVal, 0,0.3, 0.5,1.0)*10);
      pixel_col = lerpColor(dark_water, water, rnd_depth/10.0);
    } else if (heightVal < 0.35) {
      pixel_col = sand;
    } else if (heightVal < 0.5) {
      pixel_col = grass;
    } else if (heightVal < 0.7) {
      pixel_col = forest;
    } else if (heightVal < 0.8) {
      pixel_col = stone;
    } else {
      pixel_col = snow;
    }
    return pixel_col;
  }
  
}
