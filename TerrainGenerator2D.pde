// Colour palette from: https://lospec.com/palette-list/dr-20
color dark_water = #243447;
color water = #6dbce3;
color sand = #fad882;
color grass = #a8db60;
color forest = #428764;
color stone = #738078;
color snow = #fffbf2;
color contour = #573b31;

// Global Variables
PImage color_map_, height_map_;

float noise_increment = 0.01;  // for Perlin noise generation
int step_size = 10;  // marching squares cell size
float contour_height = 0.35;  // for thresholding with marching squares
boolean draw_contour = false;  // for some user control


void setup() {
  size(1280, 640);
  //fullScreen();
  color_map_ = createImage(width, height, RGB);
  height_map_ = createImage(width, height, ALPHA);
  
  //loadPixels();
  color_map_.loadPixels();
  height_map_.loadPixels();
  
  float xoff = 0.0;
  for (int x = 0; x < width; x++) {
    xoff += noise_increment;
    float yoff = 0.0;
    for(int y = 0; y < height; y++) {
      yoff += noise_increment;
      
      // Generate height map
      float h_val = noise(xoff,yoff);
        // Make island
      float bump = 1.25 - 1.25*(1 - pow((2.0*x/width - 1.0),2) ) * (1 - pow((2.0*y/height - 1.0),2));
      h_val = (h_val + (1-bump))/2;      
      height_map_.pixels[x+y*width] = (int) (h_val*255);
      
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

      //pixels[x+y*width] = pixel_col;
      color_map_.pixels[x+y*width] = pixel_col;
    }
  }
  //updatePixels();
  color_map_.updatePixels();
  height_map_.updatePixels();
}

void draw() {
  // Print the colour map as a background
  image(color_map_, 0, 0);
  
  if (draw_contour) {
    // calculate marching square cell size and countour height from mouse position
    step_size = (int) map(mouseY, 0, height, 2, 40);
    contour_height = map(mouseX, 0, width, 0, 255);
    
    height_map_.loadPixels();
    
    for (int x = 0; x < width-step_size; x+=step_size) {
      for (int y = 0; y < height-step_size; y+=step_size) {
        // This is based on the lookup table here: https://en.wikipedia.org/wiki/Marching_squares
        int lookup_val = 0;
        if (height_map_.pixels[x+y*width] > contour_height) { lookup_val += 8; }  // top-left
        if (height_map_.pixels[(x+step_size)+y*width] > contour_height) { lookup_val += 4; }  // top-right
        if (height_map_.pixels[x+(y+step_size)*width] > contour_height) { lookup_val += 1; }  // bottom-left
        if (height_map_.pixels[(x+step_size)+(y+step_size)*width] > contour_height) { lookup_val += 2; }  // bottom-right
        
        if ( (lookup_val!=0) && (lookup_val!=15) ){ print_contour(lookup_val, x, y); }
      }      
    }
    
    // Some misc info
    fill(0);
    text("Marching Squares Cell Size: " + str(step_size), 20, 20);
    text("Contour Height: " + str(round(contour_height)), 20, 40);
  }
}

void keyPressed() {
  if (key == 'c') {
    draw_contour = !draw_contour;
  }
}

void print_contour(int contour_val, int x_offset, int y_offset) {
  stroke(contour);
  // This is based on the lookup table here: https://en.wikipedia.org/wiki/Marching_squares
  // TODO: Interpolate between actual heights, rather than using midpoints
  if (contour_val == 1) {
    line(x_offset, y_offset+step_size/2, x_offset+step_size/2, y_offset+step_size);
  } else if (contour_val == 2) {
    line(x_offset+step_size, y_offset+step_size/2, x_offset+step_size/2, y_offset+step_size);
  } else if (contour_val == 3) {
    line(x_offset, y_offset+step_size/2, x_offset+step_size, y_offset+step_size/2);
  } else if (contour_val == 4) {
    line(x_offset+step_size/2, y_offset, x_offset+step_size, y_offset+step_size/2);
  } else if (contour_val == 5) {
    line(x_offset, y_offset+step_size/2, x_offset+step_size/2, y_offset);
    line(x_offset+step_size, y_offset+step_size/2, x_offset+step_size/2, y_offset+step_size);
  } else if (contour_val == 6) {
    line(x_offset+step_size/2, y_offset, x_offset+step_size/2, y_offset+step_size);
  } else if (contour_val == 7) {
    line(x_offset, y_offset+step_size/2, x_offset+step_size/2, y_offset);
  } else if (contour_val == 8) {
    line(x_offset, y_offset+step_size/2, x_offset+step_size/2, y_offset);
  } else if (contour_val == 9) {
    line(x_offset+step_size/2, y_offset, x_offset+step_size/2, y_offset+step_size);
  } else if (contour_val == 10) {
    line(x_offset, y_offset+step_size/2, x_offset+step_size/2, y_offset+step_size);
    line(x_offset+step_size/2, y_offset, x_offset+step_size, y_offset+step_size/2);
  } else if (contour_val == 11) {
    line(x_offset+step_size/2, y_offset, x_offset+step_size, y_offset+step_size/2);
  } else if (contour_val == 12) {
    line(x_offset, y_offset+step_size/2, x_offset+step_size, y_offset+step_size/2);
  } else if (contour_val == 13) {
    line(x_offset+step_size, y_offset+step_size/2, x_offset+step_size/2, y_offset+step_size);
  } else if (contour_val == 14) {
    line(x_offset, y_offset+step_size/2, x_offset+step_size/2, y_offset+step_size);
  }
}
