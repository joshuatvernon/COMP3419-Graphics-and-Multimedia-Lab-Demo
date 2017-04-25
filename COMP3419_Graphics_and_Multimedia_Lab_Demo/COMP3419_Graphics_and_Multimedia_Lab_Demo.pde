// COMP3419 Lab Demo
// @Author: Joshua Vernon 

import processing.video.*; 
Movie m;

// K must be odd
int K = 9;
int radius = 3;

float threshold = 250;

PImage current_frame;
PImage next_frame;

int phase = 1;
int framenumber = 0;
int m_frames = 0;

void setup() { 
  // Just large enough to see what is happening
  size(720, 576);
  // Fill colour
  fill(252, 30, 69);
  stroke(252, 30, 69);
  // Create a Movie object. 
  m = new Movie(this, sketchPath("videos/monkey.avi")); 
  // slow down framerate
  m.frameRate(25);
  // Play the movie one time, no looping
  m.play();
} 

void draw() {
  float time = m.time();
  float duration = m.duration();
  
  // Handle phase events
  if (phase == 1 && time >= duration) {
    m.jump(0);
    phase = 2;
    m_frames = framenumber - 1;
    framenumber = 0;
  } else if (phase == 2 && framenumber >= m_frames) {
    exit();
  }
  
  if (m.available()) {
    if (phase == 1) {
      m.read();
      m.save(sketchPath("") + "BG/" + nf(framenumber, 4) + ".tif");
      image(m, 0, 0);
      textSize(20);
      text(String.format("Phase %d: %.2f%%", phase, 100 * time / duration), 50, 50);
    } else if (phase == 2) {
      // Check if framenumber is valid
      if (framenumber < m_frames) {
        current_frame = loadImage(sketchPath("") + "BG/"+nf(framenumber, 4) + ".tif");
        next_frame = loadImage(sketchPath("") + "BG/"+nf(framenumber + 1, 4) + ".tif");
        
        image(current_frame, 0, 0);
        
        // Loop through current_frame -- move search space
        for (int fx = 0; fx < current_frame.width; fx += K) {
          for (int fy = 0; fy < current_frame.height; fy += K) {
            
            // Get the colours in the current block
            color[] b_current = get_block(current_frame, fx, fy);
            
            int min_ssd_x = 0;
            int min_ssd_y = 0;
            float min_ssd = 999999999.99;
            
            // Loop through search space -- move block
            for (int sx = fx - (K * radius); sx < fx + (K * radius); sx += K) {
              for (int sy = fy - (K * radius); sy < fy + (K * radius); sy += K) {
                
                // Get the colours in the b_prime block
                color[] b_prime = get_block(next_frame, sx, sy);
                
                // Call SSD
                float b_prime_ssd = SSD(b_current, b_prime);
                
                // Update min ssd if b_prime block is closer to current block
                if (b_prime_ssd < min_ssd) {
                  min_ssd = b_prime_ssd;
                  min_ssd_x = sx + ((K - 1) / 2);
                  min_ssd_y = sy + ((K - 1) / 2);
                }
              }
            } // End loop through search space
            
            // Draw dot on block with minimum difference from the current block
            if (min_ssd_x != fx && min_ssd_y != fy && min_ssd > threshold) {
              drawArrow(fx + ((K - 1) / 2), fy + ((K - 1) / 2), min_ssd_x, min_ssd_y);
            }
          }
        } // End loop through current_frame
        
        saveFrame(sketchPath("") + "composite/"+nf(framenumber, 4) + ".tif");
        
        textSize(20);
        text(String.format("Phase %d: %.2f%%", phase, 100 * float(framenumber) / float(m_frames)), 50, 50);
      }
    } // End if (m.available())
    
    System.out.println(framenumber);
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
      // Find the colour of the pixel, store it in the array index
      int loc = loc(bx, by);
      if (loc >= 0) {
        // Location is valid
        color c = frame.pixels[loc];
        block[idx] = c;
      }
      idx++;
    }
  } // End loop through block
  
  return block;
}


// Called every time a new frame is available to read 
void movieEvent(Movie m) {
  // Pass
}


// Check if coordinate is valid and if it is return it, else return -1
int loc(int x, int y) {
  if (x >= 0 && x < current_frame.width && y >= 0 && y < current_frame.height) {
    // Valid coordinate
    return x + (y * current_frame.width);
  } else {
    return -1;
  }
}


// Draw a dot in the middle of the block
void drawDot(int x, int y) {
  int loc = loc(x, y);
  if (loc >= 0) {
    ellipse(x, y, 2, 2);
  }
}

// Draw an arrow from the current block to the displaced block
void drawArrow(int x1, int y1, int x2, int y2) {
  line(x1, y1, x2, y2);
  line(x1, y1, x2, y2);
  pushMatrix();
  translate(x2, y2);
  float a = atan2(x1 - x2, y2 - y1);
  rotate(a);
  line(0, 0, -3, -3);
  line(0, 0, 3, -3);
  popMatrix();
}


// Return the sum of squared deplacement
float SSD(color[] b_current, color[] b_prime) {
  float sum = 0;
  for (int i = 0; i < b_current.length; i++) {
    sum += pow((red(b_current[i]) - red(b_prime[i])), 2) + 
           pow((green(b_current[i]) - green(b_prime[i])), 2) + 
           pow((blue(b_current[i]) - blue(b_prime[i])), 2);
  }
  return sqrt(sum);
}