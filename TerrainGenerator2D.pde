// Colors from https://lospec.com/palette-list/dr-20
color dark_water = #243447;
color water = #6dbce3;
color sand = #fad882;
color grass = #a8db60;
color forest = #428764;
color stone = #738078;
color snow = #fffbf2;

color line_col = #37333b;

//
float increment = 0.01;
int incrementor = 0;

// TODO: implement https://en.wikipedia.org/wiki/Marching_squares

void setup() {
  //size(1280, 640);
  fullScreen();
  
  loadPixels();
  
  float xoff = 0.0;
  for (int x = 0; x < width; x++) {
    xoff += increment;
    float yoff = 0.0;
    for(int y = 0; y < height; y++) {
      yoff += increment;
      
      // Generate height map
      float h_val = noise(xoff,yoff);
        // Make island
      float bump = 1.25 - 1.25*(1 - pow((2.0*x/width - 1.0),2) ) * (1 - pow((2.0*y/height - 1.0),2));
      h_val = (h_val + (1-bump))/2;      
      
      // Biomes
      color pixel_col = #000000;
      if (h_val < 0.3) {
        float rnd_depth = round(map(h_val, 0,0.3, 0.5,1.0)*10);
        pixel_col = lerpColor(dark_water, water, rnd_depth/10.0);
      } else if (h_val < 0.35) {
        pixel_col = sand;
      } else if (h_val < 0.5) {
        pixel_col = grass;
      } else if (h_val < 0.7) {
        pixel_col = forest;
      } else if (h_val < 0.8) {
        pixel_col = stone;
      } else {
        pixel_col = snow;
      }

      pixels[x+y*width] = pixel_col;
    }
  }
  updatePixels();
  
  incrementor++;
}
