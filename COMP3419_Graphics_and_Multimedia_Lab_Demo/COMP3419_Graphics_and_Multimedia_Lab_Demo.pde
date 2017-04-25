// COMP3419 Lab Demo
// @Author: Joshua Vernon 
// For your assignment option 1, 
// it is cozy to play the video in the 'draw()'
// and draw your objects at each frame
// After drawing all the objects just call 'saveFrame()'
// Use 'Tools->Movie Maker' to combine all the saved frames

import processing.video.*; 
Movie m;

int framenumber = 0;

// K must be odd
int K = 9;

float lower_threshold = 100;
float threshold = 700;

PImage current_frame;
PImage previous_frame = null;

void setup() { 
  // Just large enough to see what is happening
  size(720, 576);
  // fill colour
  fill(252, 30, 69);
  stroke(252, 30, 69);
  //create a Movie object. 
  m = new Movie(this, sketchPath("videos/monkey.avi")); 
  // slow down framerate
  m.frameRate(10);
  // Play the movie one time, no looping
  m.play();
} 

void draw() {
  if (m.available()) {
    current_frame = m;
  
    image(current_frame, 0, 0);
  
    if (previous_frame != null) {
      // Loop through current_frame -- move search space
      for (int fx = 0; fx < current_frame.width; fx += K) {
        for (int fy = 0; fy < current_frame.height; fy += K) {
          
          color[] b_current = new color[K * K];
          
          // Loop through current block -- store each pixel's colour in b_current
          int c_p_count = 0;
          for (int cx = fx; cx < fx + K; cx++) {
            for (int cy = fy; cy < fy + K; cy++) {
              // find the colour of the pixel, store it in the array index
              int loc = loc(cx, cy);
              if (loc >= 0) {
                // location is valid
                color c = previous_frame.pixels[loc];
                b_current[c_p_count] = c;
              }
              c_p_count++;
            }
          } // end loop through current block 
          
          int min_ssd_x = 0;
          int min_ssd_y = 0;
          float min_ssd = 9999.99;
          
          // Loop through search space -- move block
          for (int sx = fx - (K * 2); sx < fx + (K * 2); sx += K) {
            for (int sy = fy - (K * 2); sy < fy + (K * 2); sy += K) {
              
              color[] b_prime = new color[K * K];
              
              // Loop through prime block -- store each pixel's colour in b_prime
              int b_p_count = 0;
              for (int bx = sx; bx < sx + K; bx++) {
                for (int by = sy; by < sy + K; by++) {
                  // find the colour of the pixel, store it in the array index
                  int loc = loc(bx, by);
                  if (loc >= 0) {
                    // location is valid
                    color c = current_frame.pixels[loc];
                    b_prime[b_p_count] = c;
                  }
                  b_p_count++;
                }
              } // end loop through prime block
              
              // Call SSD
              float b_prime_ssd = SSD(b_current, b_prime);
              
              //
              if (b_prime_ssd < min_ssd) {
                min_ssd = b_prime_ssd;
                min_ssd_x = sx;
                min_ssd_y = sy;
              }
            }
          } // end loop through search space
          
          // draw dot on block with minimum difference from the current block
          if (min_ssd_x != fx && min_ssd_y != fy) {
            drawDot(min_ssd_x, min_ssd_y);
          }
        }
      } // end loop through current_frame
    }
      
    current_frame.updatePixels();
    
    current_frame.save(sketchPath("") + "BG/"+nf(framenumber, 4) + ".tif");
    framenumber++;
    
    previous_frame = current_frame;
  }
}


// Called every time a new frame is available to read 
void movieEvent(Movie m) {
  m.read();
}


// Check if coordinate is valid and if it is return it, else return -1
int loc(int x, int y) {
  if (x >= 0 && x < current_frame.width && y >= 0 && y < current_frame.height) {
    // valid coordinate
    return x + (y * current_frame.width);
  } else {
    return -1;
  }
}


// draw a dot in the middle of the block
void drawDot(int x, int y) {
  int loc = loc(x + ((K-1)/2), y + ((K-1)/2));
  if (loc >= 0) {
    ellipse(x + ((K-1)/2), y + ((K-1)/2), 2, 2);
  }
}


// 
float SSD(color[] b_current, color[] b_prime) {
  float sum = 0;
  for (int i = 0; i < b_current.length; i++) {
    sum += pow((red(b_current[i]) - red(b_prime[i])), 2);
    sum += pow((green(b_current[i]) - green(b_prime[i])), 2);
    sum += pow((blue(b_current[i]) - blue(b_prime[i])), 2);
  }
  return sqrt(sum);
}