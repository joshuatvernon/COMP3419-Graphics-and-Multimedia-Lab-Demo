// COMP3419 Lab Demo
// @Author: Joshua Vernon 
// For your assignment option 1, 
// it is cozy to play the video in the 'draw()'
// and draw your objects at each frame
// After drawing all the objects just call 'saveFrame()'
// Use 'Tools->Movie Maker' to combine all the saved frames

import processing.video.*; 
Movie m;

// K must be odd
int K = 9;
int radius = 3;

float threshold = 500;

PImage current_frame;
PImage next_frame;

int phase = 1;
int framenumber = 0;
int m_frames = 0;

void setup() { 
  // Just large enough to see what is happening
  size(720, 576);
  // fill colour
  fill(252, 30, 69);
  stroke(252, 30, 69);
  //create a Movie object. 
  m = new Movie(this, sketchPath("videos/monkey.avi")); 
  // slow down framerate
  m.frameRate(25);
  // Play the movie one time, no looping
  m.play();
} 

void draw() {
  float time = m.time();
  float duration = m.duration();
  
  if (time >= duration) {
    if (phase == 1) {
      m = new Movie(this, sketchPath("videos/monkey.avi"));
      m.frameRate(25); // Play your movie faster
      m.play();
      phase = 2;
      m_frames = framenumber;
      framenumber = 0;
    } else if (phase == 2) {
      exit();
    }
  }
  
  if (m.available()) {
    
    if (phase == 1) {
      m.read();
      m.save(sketchPath("") + "BG/" + nf(framenumber, 4) + ".tif");
      image(m, 0, 0);
    } else if (phase == 2) {
      m.read();
      if (framenumber <= m_frames) {
        current_frame = loadImage(sketchPath("") + "BG/"+nf(framenumber, 4) + ".tif");
        next_frame = loadImage(sketchPath("") + "BG/"+nf(framenumber + 1, 4) + ".tif");
        
        image(current_frame, 0, 0);
        
        // Loop through current_frame -- move search space
        for (int fx = 0; fx < current_frame.width; fx += K) {
          for (int fy = 0; fy < current_frame.height; fy += K) {
            
            // get the colours in the current block
            color[] b_current = get_block(current_frame, fx, fy);
            
            int min_ssd_x = 0;
            int min_ssd_y = 0;
            float min_ssd = 999999.99;
            
            // Loop through search space -- move block
            for (int sx = fx - (K * radius); sx < fx + (K * radius); sx += K) {
              for (int sy = fy - (K * radius); sy < fy + (K * radius); sy += K) {
                
                // get the colours in the b_prime block
                color[] b_prime = get_block(next_frame, sx, sy);
                
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
            if (min_ssd_x != fx && min_ssd_y != fy && min_ssd > threshold) {
              drawDot(current_frame, min_ssd_x, min_ssd_y);
            }
          }
        } // end loop through current_frame
        
        current_frame.updatePixels();
        
        //current_frame.save(sketchPath("") + "composite/"+nf(framenumber, 4) + ".tif");
        saveFrame(sketchPath("") + "composite/"+nf(framenumber, 4) + ".tif");
      } else {
        phase = 2; 
      }
    } // end if (m.available())
    
    framenumber++;
  }
}


// Loop through block and return an array of the pixel's colors
color[] get_block(PImage frame, int x, int y) {
  color[] block = new color[K * K];
  
  // Loop through block
  int idx = 0;
  for (int bx = x; bx < x + K; bx++) {
    for (int by = y; by < y + K; by++) {
      // find the colour of the pixel, store it in the array index
      int loc = loc(bx, by);
      if (loc >= 0) {
        // location is valid
        color c = frame.pixels[loc];
        block[idx] = c;
      }
      idx++;
    }
  } // end loop through block
  
  return block;
}


// Called every time a new frame is available to read 
void movieEvent(Movie m) {
  //m.read();
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
void drawDot(PImage frame, int x, int y) {
  int loc = loc(x + ((K-1)/2), y + ((K-1)/2));
  if (loc >= 0) {
    //frame.pixels[loc] = -1;
    ellipse(x + ((K-1)/2), y + ((K-1)/2),2,2);
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