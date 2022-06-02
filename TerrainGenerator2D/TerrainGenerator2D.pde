// Colour palette from: https://lospec.com/palette-list/dr-20
color dark_water = #243447;
color water = #6dbce3;
color sand = #fad882;
color grass = #a8db60;
color forest = #428764;
color stone = #738078;
color snow = #fffbf2;
color contour = #573b31;

// Biome threshold based on height (upper-limit)
float water_thres_pcnt = 0.5;
float sand_thres_pcnt = 0.55;
float grass_thres_pcnt = 0.6;
float forest_thres_pcnt = 0.7;
float stone_thres_pcnt = 0.8;

// Global Variables
PImage color_map_, height_map_;
PGraphics contour_lines_;

float noise_increment = 0.01;  // for Perlin noise generation
int step_size = 10;  // marching squares cell size
float man_contour_height = 0.35;  // for thresholding with marching squares
boolean draw_contour = false;  // for some user control
boolean interpolate_contours = false;  // for some user control


void setup() {
  size(1280, 640);
  //fullScreen();
  
  // Create empty images and graphics objects
  color_map_ = createImage(width, height, RGB);
  height_map_ = createImage(width, height, ALPHA);
  contour_lines_ = createGraphics(width, height);
  
  // Load pixel buffers and create maps
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
      
      // Biome colour assignment
      color pixel_col = #000000;
      float rand = random(-0.125,0.125);  // random used to add noise for artistic purposes
      if (h_val < water_thres_pcnt ) {
        float rnd_depth = round(map(h_val, 0,water_thres_pcnt, 0.5,1.0)*10);
        pixel_col = lerpColor(dark_water, water, rnd_depth/10.0);
      } else if (h_val < sand_thres_pcnt) {
        //pixel_col = sand;
        pixel_col = (rand<0) ? lerpColor(sand, #000000, -rand*noise(xoff,yoff)) : lerpColor(sand, #FFFFFF, rand*noise(xoff,yoff));
      } else if (h_val < grass_thres_pcnt) {
        //pixel_col = grass;
        pixel_col = (rand<0) ? lerpColor(grass, #000000, -rand*noise(xoff,yoff)) : lerpColor(grass, #FFFFFF, rand*noise(xoff,yoff));
      } else if (h_val < forest_thres_pcnt) {
        //pixel_col = forest;
        pixel_col = (rand<0) ? lerpColor(forest, #000000, -rand*noise(xoff,yoff)) : lerpColor(forest, #FFFFFF, rand*noise(xoff,yoff));
      } else if (h_val < stone_thres_pcnt) {
        //pixel_col = stone;
        pixel_col = (rand<0) ? lerpColor(stone, #000000, -rand*noise(xoff,yoff)) : lerpColor(stone, #FFFFFF, rand*noise(xoff,yoff));
      } else {
        //pixel_col = snow;
        pixel_col = (rand<0) ? lerpColor(snow, #000000, -rand*noise(xoff,yoff)) : lerpColor(snow, #FFFFFF, rand*noise(xoff,yoff));
      }

      //pixels[x+y*width] = pixel_col;
      color_map_.pixels[x+y*width] = pixel_col;
    }
  }
  //updatePixels();
  color_map_.updatePixels();
  height_map_.updatePixels();
  
  // Create contour line graphics
  contour_lines_.beginDraw();
  
  // Draw contour lines at specified intervals
  int contour_size = 2;
  for (int x = 0; x < width-contour_size; x+=contour_size) {
    for (int y = 0; y < height-contour_size; y+=contour_size) {
        // Plot contour lines at 10% intervals
        contour_lines_.stroke(contour, 50);
        contour_lines_.pushMatrix();
          contour_lines_.translate(x, y);
          for (float i=0.5; i<1.0; i+=10.0/255) {
            contour_lines_ = print_interpolated_contours(height_map_.pixels[x+y*width], height_map_.pixels[(x+contour_size)+y*width], height_map_.pixels[x+(y+contour_size)*width], height_map_.pixels[(x+contour_size)+(y+contour_size)*width], i*255, contour_size, contour_lines_);
          }
        contour_lines_.popMatrix();
    }
  }
  contour_lines_.endDraw();
  
}


void draw() {
  // Print the colour map as a background
  image(color_map_, 0, 0);
  image(contour_lines_, 0, 0);
  height_map_.loadPixels();
  
  PGraphics contour_line_man = createGraphics(width, height);
  
  
  // Draw user specified contour line
  if (draw_contour) {
    // calculate marching square cell size and countour height from mouse position
    step_size = (int) map(mouseY, 0, height, 2, 40);
    man_contour_height = map(mouseX, 0, width, 0, 255);
    contour_line_man.beginDraw();
    
    for (int x = 0; x < width-step_size; x+=step_size) {
      for (int y = 0; y < height-step_size; y+=step_size) {
        // This is based on the lookup table here: https://en.wikipedia.org/wiki/Marching_squares
        // Contours are printed in local space to minimise parameters to send to the respective functions
        
        if (interpolate_contours) {
          contour_line_man.pushMatrix();
            contour_line_man.translate(x, y);
            contour_line_man.stroke(contour);
            contour_line_man = print_interpolated_contours(height_map_.pixels[x+y*width], height_map_.pixels[(x+step_size)+y*width], height_map_.pixels[x+(y+step_size)*width], height_map_.pixels[(x+step_size)+(y+step_size)*width], man_contour_height, step_size, contour_line_man);
          contour_line_man.popMatrix();
        } else {
          pushMatrix();
            translate(x, y);
            int lookup_val = 0;
            if (height_map_.pixels[x+y*width] > man_contour_height) { lookup_val += 8; }  // top-left
            if (height_map_.pixels[(x+step_size)+y*width] > man_contour_height) { lookup_val += 4; }  // top-right
            if (height_map_.pixels[x+(y+step_size)*width] > man_contour_height) { lookup_val += 1; }  // bottom-left
            if (height_map_.pixels[(x+step_size)+(y+step_size)*width] > man_contour_height) { lookup_val += 2; }  // bottom-right
            
            stroke(contour);
            if ( (lookup_val!=0) && (lookup_val!=15) ){ print_uninterpolated_contour(lookup_val, step_size); }
          popMatrix();
        }
      }      
    }
    contour_line_man.endDraw();
    image(contour_line_man, 0,0);
    
    // Some misc info
    fill(0);
    text("Marching Squares Cell Size: " + str(step_size), 20, 20);
    text("Contour Height: " + str(round(man_contour_height-255*water_thres_pcnt)), 20, 40);
    text("Linear Interpolation: " + str(interpolate_contours), 20, 60);
  }
}

void keyPressed() {
  if (key == 'c') {
    draw_contour = !draw_contour;
  }
  if (key == 'i') {
    interpolate_contours = !interpolate_contours;
  }
}

PGraphics print_interpolated_contours(int t_l_height, int t_r_height, int b_l_height, int b_r_height, float contour_height, int contour_size, PGraphics contour_lines ) {
  // t=top, b=bottom, l=left, r=right
  int contour_val = 0;
  if (t_l_height > contour_height) { contour_val += 8; }  // top-left
  if (t_r_height > contour_height) { contour_val += 4; }  // top-right
  if (b_l_height > contour_height) { contour_val += 1; }  // bottom-left
  if (b_r_height > contour_height) { contour_val += 2; }  // bottom-right
  
  if ( (contour_val == 1) || (contour_val == 14) ) {
    float p1 = map(contour_height, t_l_height, b_l_height, 0, contour_size);
    float p2 = map(contour_height, b_l_height, b_r_height, 0, contour_size);
    contour_lines.line(0, p1, p2, contour_size);
  } else if ( (contour_val == 2) || (contour_val == 13) ) {
    float p1 = map(contour_height, t_r_height, b_r_height, 0, contour_size);
    float p2 = map(contour_height, b_l_height, b_r_height, 0, contour_size);
    contour_lines.line(contour_size, p1, p2, contour_size);
  } else if ( (contour_val == 3) || (contour_val == 12) ) {
    float p1 = map(contour_height, t_l_height, b_l_height, 0, contour_size);
    float p2 = map(contour_height, t_r_height, b_r_height, 0, contour_size);
    contour_lines.line(0, p1, contour_size, p2);
  } else if ( (contour_val == 4) || (contour_val == 11) ) {
    float p1 = map(contour_height, t_l_height, t_r_height, 0, contour_size);
    float p2 = map(contour_height, t_r_height, b_r_height, 0, contour_size);
    contour_lines.line(p1, 0, contour_size, p2);
  } else if (contour_val == 5) {
    // Same as case 7 or 8
    float p1 = map(contour_height, t_l_height, t_r_height, 0, contour_size);
    float p2 = map(contour_height, t_l_height, b_l_height, 0, contour_size);
    contour_lines.line(p1, 0, 0, p2);
    // Same as case 2 or 13
    float p3 = map(contour_height, t_r_height, b_r_height, 0, contour_size);
    float p4 = map(contour_height, b_l_height, b_r_height, 0, contour_size);
    contour_lines.line(contour_size, p3, p4, contour_size);
  } else if ( (contour_val == 6) || (contour_val == 9) ) {
    float p1 = map(contour_height, t_l_height, t_r_height, 0, contour_size);
    float p2 = map(contour_height, b_l_height, b_r_height, 0, contour_size);
    contour_lines.line(p1, 0, p2, contour_size);
  } else if ( (contour_val == 7) || (contour_val == 8)) {
    float p1 = map(contour_height, t_l_height, t_r_height, 0, contour_size);
    float p2 = map(contour_height, t_l_height, b_l_height, 0, contour_size);
    contour_lines.line(p1, 0, 0, p2);
  } else if (contour_val == 10) {
    // Same as case 1 or 14
    float p1 = map(contour_height, t_l_height, b_l_height, 0, contour_size);
    float p2 = map(contour_height, b_l_height, b_r_height, 0, contour_size);
    contour_lines.line(0, p1, p2, contour_size);
    // Same as case 4 or 11
    float p3 = map(contour_height, t_l_height, t_r_height, 0, contour_size);
    float p4 = map(contour_height, t_r_height, b_r_height, 0, contour_size);
    contour_lines.line(p3, 0, contour_size, p4);
  }
  
  return contour_lines;
}


void print_uninterpolated_contour(int contour_val, int contour_size) {
  // This is based on the lookup table here: https://en.wikipedia.org/wiki/Marching_squares
  if (contour_val == 1) {
    line(0, contour_size/2, contour_size/2, contour_size);
  } else if (contour_val == 2) {
    line(contour_size, contour_size/2, contour_size/2, contour_size);
  } else if (contour_val == 3) {
    line(0, contour_size/2, contour_size, contour_size/2);
  } else if (contour_val == 4) {
    line(contour_size/2, 0, contour_size, contour_size/2);
  } else if (contour_val == 5) {
    line(0, step_size/2, step_size/2, 0);
    line(contour_size, contour_size/2, contour_size/2, contour_size);
  } else if (contour_val == 6) {
    line(contour_size/2, 0, contour_size/2, contour_size);
  } else if (contour_val == 7) {
    line(0, contour_size/2, contour_size/2, 0);
  } else if (contour_val == 8) {
    line(0, contour_size/2, contour_size/2, 0);
  } else if (contour_val == 9) {
    line(contour_size/2, 0, contour_size/2, contour_size);
  } else if (contour_val == 10) {
    line(0, contour_size/2, contour_size/2, contour_size);
    line(contour_size/2, 0, contour_size, contour_size/2);
  } else if (contour_val == 11) {
    line(contour_size/2, 0, contour_size, contour_size/2);
  } else if (contour_val == 12) {
    line(0, contour_size/2, contour_size, contour_size/2);
  } else if (contour_val == 13) {
    line(contour_size, contour_size/2, contour_size/2, contour_size);
  } else if (contour_val == 14) {
    line(0, contour_size/2, contour_size/2, contour_size);
  }
}