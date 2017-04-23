// Example for COMP3615 WEEK06 TASK 1
// @Author : Siqi
// For your assignment option 1, 
// it is cozy to play the video in the 'draw()'
// and draw your objects at each frame
// After drawing all the objects just call 'saveFrame()'
// Use 'Tools->Movie Maker' to combine all the saved frames

import processing.video.*; 
Movie m; 

int framenumber = 1;
int phase = 1; // The phase for precessing pipeline : 1, saving frames of background; 2. overwrite the background frames with 
int bgctr = 1; // The total number of background frames
int BLUE = 120; // I did not tune this much, keep tunning
                // Also try to include Red and Green in your 
                // criteria to achieve better segmentation
PImage bg;
PImage monkeyframe;

void setup() { 
    size(1280, 720); //Just large enough to see what is happening
  frameRate(120); // Make your draw function run faster
  //create a Movie object. 
  m = new Movie(this, sketchPath("videos/star_trails.mov")); 
  m.frameRate(120); // Play your movie faster

  framenumber = 0; 
  fill(255, 255, 0); // Make the drawing colour yellow

  //play the movie one time, no looping 
  m.play(); 
} 
 
void draw() { 
  // Clear the background with black colour
  float time = m.time();
  float duration = m.duration();
  float whereweare = time / duration;

  if( time >= duration ) { 
    if (phase == 1) {
      m = new Movie(this, sketchPath("videos/monkey.avi"));
      m.frameRate(120); // Play your movie faster
      m.play();
      phase = 2;
      bgctr = framenumber;
      framenumber = 1;
    }
    else if (phase == 2){
            exit(); // End the program when the second movie finishes
    }
  }

    if (m.available()){
    background(0, 0, 0);
    m.read(); 
      
      if (phase == 1){
      image(m, 0, 0);
      m.save(sketchPath("") + "BG/"+nf(framenumber, 4) + ".tif"); // They say tiff is faster to save, but larger in disks 
      }
      else if (phase == 2) {
        monkeyframe = removeBackground(m);
          bg = loadImage(sketchPath("") + "BG/"+nf(framenumber % bgctr, 4) + ".tif");

          // Overwrite the background 
          for (int x = 0; x < monkeyframe.width; x++)
            for (int y = 0; y < monkeyframe.height; y++){
              int mloc = x + y * monkeyframe.width;
                  color mc = monkeyframe.pixels[mloc];

                  if (mc != -1) {
                        // To control where you draw the monkey
                        // You can tweak the destination position of the monkey like
                        int bgx = constrain(x + 500, 0, bg.width);
                        int bgy = constrain(y + 60, 0, bg.height);
                int bgloc = bgx + bgy * bg.width;
                      bg.pixels[bgloc] = mc;
                  }
            }

        bg.updatePixels();
      image(bg, 0, 0);
      float ex = whereweare * bg.width;
      float ey = whereweare * bg.height;
      ellipse( ex, ey, 10, 10);

      textSize(10);
      text(String.format("I am at : (%.1f, %.1f)", ex, ey), ex + 10, ey + 5);

      // In the second phase, we just saveframe, since we would like to include the objects we drew
      // I am drawing some thing at the same time.
      saveFrame(sketchPath("") + "/composite/" + nf(framenumber, 4) + ".tif");
      }

    textSize(20);
    text(String.format("Phase - %d - %.2f%%", phase, 100 * time / duration), 100, 80); // Display the text to show where you are in the pipeline

    System.out.printf("Phase: %d - Frame %d\n", phase, framenumber);
    framenumber++; 
    }

} 
 
// Called every time a new frame is available to read 
void movieEvent(Movie m) { 
} 

PImage removeBackground(PImage frame) {
  for (int x = 0; x < frame.width; x ++)
    for (int y = 0; y < frame.height; y ++) {
      int loc = x + y * frame.width;
      color c = frame.pixels[loc];
      if ( blue(c) > BLUE){ 
                frame.pixels[loc] = -1; 
      }
    }

  frame.updatePixels();

  return frame;
}