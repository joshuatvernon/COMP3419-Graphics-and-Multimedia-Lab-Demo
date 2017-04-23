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
int K = 5;

PImage frame;

void setup() { 
  // Just large enough to see what is happening
  size(1275, 750); 
  //create a Movie object. 
  m = new Movie(this, sketchPath("videos/iguana-vs-snakes.mp4")); 
  // Play the movie one time, no looping 
  m.play();
} 

void draw() {
  if (m.available()) {
    background(0, 0, 0);
    
    frame = m;

    // Loop through frame -- move search space
    for (int fx = 0; fx < frame.width; fx += K) {
      for (int fy = 0; fy < frame.height; fy += K) {
        
        int[] b_current = new int[K * K];
        
        // Loop through current block -- store each pixel's colour in b_current
        int c_p_count = 0;
        for (int cx = fx; cx < fx + K; cx++) {
          for (int cy = fy; cy < fy + K; cy++) {
            // find the colour of the pixel, store it in the array index
            int loc = loc(cx, cy);
            if (loc >= 0) {
              // location is valid
              b_current[c_p_count] = frame.pixels[loc];
            }
            c_p_count++;
          }
        }
        // end loop through current block 
        
        int closest_block_x = 0;
        int closest_block_y = 0;
        float closest_block_closeness = 9999.99;
        
        // Loop through search space -- move block
        for (int sx = fx - K; sx < fx + K; sx += K) {
          for (int sy = fy - K; sy < fy + K; sy += K) {
            
            int[] b_prime = new int[K * K];
            
            // Loop through prime block -- store each pixel's colour in b_prime
            int b_p_count = 0;
            for (int bx = sx; bx < sx + K; bx++) {
              for (int by = sy; by < sy + K; by++) {
                // find the colour of the pixel, store it in the array index
                int loc = loc(bx, by);
                if (loc >= 0) {
                  // location is valid
                  b_prime[b_p_count] = frame.pixels[loc];
                }
                b_p_count++;
              }
            }
            // end loop through prime block         
            
            // Call SSD
            float b_prime_closeness = SSD(b_current, b_prime);
            if (b_prime_closeness < closest_block_closeness) {
              closest_block_closeness = b_prime_closeness;
              closest_block_x = sx;
              closest_block_y = sy;
            }
          }
        }
        // end loop through search space
        
        // draw dot on block with minimum difference from the current block
        drawDot(closest_block_x, closest_block_y);
      }
    }
    // end loop through frame
    
  }
  
  frame.updatePixels();
  
  image(frame, 0, 0);
} 

// Called every time a new frame is available to read 
void movieEvent(Movie m) {
  m.read();
}

// Check if coordinate is valid and if it is return it, else return -1
int loc(int x, int y) {
  if (x >= 0 && x < frame.width && y >= 0 && y < frame.height) {
    // valid coordinate
    return x + y * frame.width;
  } else {
    return -1;
  }
}

// draw a dot in the middle of the block
void drawDot(int x, int y) {
  int loc = loc(x + ((K-1)*2), y + ((K-1)*2));
  frame.pixels[loc] = -1;
}

// 
float SSD(int[] b_current, int[] b_prime) {
  int sum = 0;
  for (int i = 0; i < b_current.length; i++) {
    sum += pow(b_current[i] - b_prime[i], 2);
  }
  return sqrt(sum);
}