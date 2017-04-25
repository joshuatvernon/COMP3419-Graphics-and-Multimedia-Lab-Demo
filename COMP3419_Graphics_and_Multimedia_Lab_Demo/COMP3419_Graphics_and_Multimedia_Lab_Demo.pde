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

PImage frame;
PImage previous_frame = null;

int phase = 1;
int frame_count = 0;
int no_of_frames = 0;

void setup() { 
  // Just large enough to see what is happening
  //size(1275, 750);
  size(720, 576);
  // fill colour
  fill(252, 30, 69);
  stroke(252, 30, 69);
  //create a Movie object. 
  m = new Movie(this, sketchPath("videos/monkey.avi")); 
  // set framerate
  m.frameRate(25);
  // Play the movie one time, no looping
  m.play();
} 

void draw() {
  float time = m.time();
  float duration = m.duration();
  
  if (phase == 1) {
    if (time >= duration) {
      // phase 1 has finished -- frames have been saved
      no_of_frames = frame_count;
      frame_count = 0;
      phase = 2;
    } else {
      frame = m;
      image(frame, 0, 0);
      m.save(sketchPath("") + "BG/"+nf(frame_count, 4) + ".tif");
    }
  } else if (phase == 2) {
    if (frame_count > no_of_frames) {
      // phase 2 has finished -- frames have been drawn on
      frame_count = 0;
      phase = 3;
    } else {
      frame = loadImage(sketchPath("") + "BG/"+nf(frame_count, 4) + ".tif");
      image(frame, 0, 0);
    
      if (previous_frame != null) {
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
                  b_current[c_p_count] = previous_frame.pixels[loc];
                }
                c_p_count++;
              }
            } // end loop through current block 
            
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
                } // end loop through prime block         
                
                // Call SSD
                float b_prime_closeness = SSD(b_current, b_prime);
                
                //
                if (b_prime_closeness < closest_block_closeness) {
                  closest_block_closeness = b_prime_closeness;
                  closest_block_x = sx;
                  closest_block_y = sy;
                }
              }
            } // end loop through search space
            
            // draw dot on block with minimum difference from the current block
            drawDot(closest_block_x, closest_block_y);
          }
        } // end loop through frame
      }
        
      frame.updatePixels();
      
      previous_frame = frame;
    }
  } else if (phase == 3) {
    // play video
    if (frame_count == 0) {
      m.jump(0);
      m.play();
    } else if (frame_count > no_of_frames) {
      phase = 4;
    } else {
      // play each frame of the new video
      frame = loadImage(sketchPath("") + "BG/"+nf(frame_count, 4) + ".tif");
      image(frame, 0, 0);
    }
  } else if (phase == 4) {
    // fin
    exit();
  }
  
  // print details to stdout and on the screen to inform of what is happening
  textSize(20);
  if (phase == 1) {
    text(String.format("Phase - %d - %.2f%%", phase, 100 * time / duration), 80, 80);
  } else {
    text(String.format("Phase - %d - %.2f%%", phase, 100 * float(frame_count) / float(no_of_frames)), 80, 80);
  }
  //System.out.printf("Phase: %d - Frame %d\n", phase, frame_count);
  frame_count++;
} 

// Called every time a new frame is available to read 
void movieEvent(Movie m) {
  m.read();
}

// Check if coordinate is valid and if it is return it, else return -1
int loc(int x, int y) {
  if (x >= 0 && x < frame.width && y >= 0 && y < frame.height) {
    // valid coordinate
    return x + (y * frame.width);
  } else {
    return -1;
  }
}

// draw a dot in the middle of the block
void drawDot(int x, int y) {
  int loc = loc(x + ((K-1)/2), y + ((K-1)/2));
  if (loc >= 0) {
    //frame.pixels[loc] = -1;
    ellipse(x + ((K-1)/2), y + ((K-1)/2), 1, 1);
  }
}

// return the level of displacement via 'sum squared displacement'
float SSD(int[] b_current, int[] b_prime) {
  if (frame_count == 2) {
    for (int j = 0; j < b_current.length; j++) {
      System.out.println(b_current[j]);
    }
  }
  int sum = 0;
  for (int i = 0; i < b_current.length; i++) {
    sum += pow((red(b_current[i]) - red(b_prime[i])), 2) +
    pow((green(b_current[i]) - green(b_prime[i])), 2) +
    pow((blue(b_current[i]) - blue(b_prime[i])), 2);
  }
  return sqrt(sum);
}