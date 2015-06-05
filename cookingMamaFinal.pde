import ddf.minim.spi.*;
import ddf.minim.signals.*;
import ddf.minim.*;
import ddf.minim.analysis.*;
import ddf.minim.ugens.*;
import ddf.minim.effects.*;

// main audio controller
Minim minim;


// audio files
AudioPlayer player;
AudioPlayer failSound; 
AudioPlayer passSound; 


// live video libraries
import processing.video.*;

// AR library - find the 'NyAR4psg' folder that came with today's downloadable
// code package and put it into the 'libraries' folder of your Processing sketchbook
import jp.nyatla.nyar4psg.*;

// video object
Capture video;

// AR marker object - this keeps track of all of the patterns you wish to look for
MultiMarker augmentedRealityMarkers;

//images
PImage title;
PImage eggTitle;
PImage honeyTitle;
PImage butterTitle;
PImage batterTitle;
PImage bowl;
PImage whisk;
PImage egg;
PImage crackedEgg;
PImage Tablespoon;
PImage Tablespoon2;
PImage honey_drop;
PImage bee;
PImage knife;
PImage butter;

PImage backgroundImage; 
PImage backgroundFail;
PImage backgroundPass;
PImage outside;
PImage cuttingBoard;
PImage kitchenBackground;
PImage finalCake;
PImage fail; 
PImage pass; 

HoneyDrop[] honey = new HoneyDrop[6];
BumbleBee[] theBee = new BumbleBee[3];

int inBowlCount = 0; 
int eggCount = 0;
float gameState = 0.0;
int honeyPoints = 0;
int wb; //width of butter
int cutCount = 0;
int timer = 0;

int timerHoney = 0;

int timerButter = 0;

int failCount = 0;

void setup() 
{
  // make sure to render your sketch using a 3D renderer.  OPENGL or P3D will both work.
  size(640, 480, OPENGL);
  smooth();

  // set up Minim
  minim = new Minim(this);

  // load in our audio file
  player = minim.loadFile("soundtrack.mp3");
  failSound = minim.loadFile("cookingmama-fail.mp3");
  passSound = minim.loadFile("cookingmama-pass.mp3");
  // create our video object
  video = new Capture(this, 640, 480);
  video.start();

  player.loop();

  hint(DISABLE_DEPTH_TEST);

  // create a new AR marker object
  // note that "camera_para.dat" has to be in the data folder of your sketch
  // this is used to correct for distortions in your webcam
  augmentedRealityMarkers = new MultiMarker(this, width, height, "camera_para.dat", NyAR4PsgConfig.CONFIG_PSG);

  // the first marker will be referred to as marker #0
  augmentedRealityMarkers.addARMarker("patt.hiro", 80);

  // and the second marker will be referred to as marker #1
  augmentedRealityMarkers.addARMarker("patt.kanji", 80);

  //marker #2
  augmentedRealityMarkers.addARMarker(loadImage("pika_fiducial.png"), 16, 25, 80);

  //marker #3 - egg 3
  augmentedRealityMarkers.addARMarker(loadImage("egg3.gif"), 16, 25, 80);

  title = loadImage("TitleScreen.jpg");
  eggTitle = loadImage("eggTitle.jpg");
  honeyTitle = loadImage("honeyTitle.jpg");
  butterTitle = loadImage("butterTitle.jpg");
  batterTitle = loadImage("batterTitle.jpg");

  bowl = loadImage("mixingbowl.png");
  whisk = loadImage("whisk.png");

  egg = loadImage("egg-2.png");
  crackedEgg = loadImage("crackedegg-2.png");

  kitchenBackground = loadImage("kitchenBackground.jpg");
  outside = loadImage("outside.png");
  cuttingBoard = loadImage("cuttingBoard.jpg");
  backgroundImage = loadImage("checkeredbackground.jpg");
  backgroundFail = loadImage("checkeredbackgroundFail.jpg");
  backgroundPass = loadImage("checkeredbackgroundPass.jpg");
  fail = loadImage("cookingmama-fail.png");
  pass = loadImage("cookingmama-happy.png");
  finalCake = loadImage("finalCake.jpg");

  knife = loadImage("knife.png");
  butter = loadImage("butter.png");

  // load artwork for honey drop
  Tablespoon = loadImage("Tablespoon.png");
  Tablespoon2 = loadImage("Tablespoon.png");
  honey_drop = loadImage("HoneyDrop.png");
  bee = loadImage("bee.png");

  wb = 604;

  for (int i = 0; i < theBee.length; i++)
  {
    theBee[i] = new BumbleBee(random(50, width-50), random(-500, 0));
  }

  for (int i = 0; i < honey.length; i++)
  {
    honey[i] = new HoneyDrop(random(50, width-50), random(-500, 0));
  }
}

void draw()
{
  //title screen
  if (gameState == 0.0) {
    image(title, 0, 0, 640, 480);

    if (mousePressed) {
      gameState = 0.5;
    }
  }
  //instruction
  if (gameState == 0.5)
  {

    image(eggTitle, 0, 0, 640, 480);
    /*textSize(32);
     fill(0);
     text("Crack 3 eggs in the given amount of ", 50, 100); 
     text("time to continue to the next level...", 50, 130);
     
     fill(255, 0, 0);
     text("Press any key to continue", 50, 210); */
    if (keyPressed)
    {
      gameState = 1.0;
    }
  }

  //HIROOOOOO - egg 1
  if (gameState == 1.0) {
    // we only really want to do something if there is fresh data from the camera waiting for us
    if (video.available())
    {
      // read in the video frame and display it
      video.read();
      imageMode(CORNER);

      image(kitchenBackground, 0, 0);

      imageMode(CENTER);
      image(bowl, 320, 400, 640, 200);


      try {
        // ask the AR marker object to attempt to find our patterns in the incoming video stream
        augmentedRealityMarkers.detect(video);

        // assume these guys aren't close to one another
        boolean close = false;

        //start the timer
        timer++; 
        fill(255, 0, 0);
        textSize(25);
        text("Time Left:" + (10 - (timer/60)), 100, 50);
        if (timer == 600)
        {
          //you failed
          gameState = 1.4; 
          timer = 0;
        }

        // does pattern #1 exist in this video frame?
        if (augmentedRealityMarkers.isExistMarker(0))
        {
          // ok, now we are in business!  Test to see how far apart they are
          // first, get their position in 2D space
          PVector[] marker2 = augmentedRealityMarkers.getMarkerVertex2D(0);

          // average up the 4 points of each marker and obtain the center point, then compute the
          // distance between the two center points
          float x1 = (marker2[0].x + marker2[1].x + marker2[2].x + marker2[3].x)/4;
          float y1 = (marker2[0].y + marker2[1].y + marker2[2].y + marker2[3].y)/4;

          float distance = dist(x1, y1, 320, 400);

          println(x1 + "," + y1);


          if (distance < 200) { 
            close = true;
          }


          // if we are egg#1 close draw another bowl
          if (close) {

            inBowlCount++;
            // set the AR perspective
            augmentedRealityMarkers.setARPerspective();

            pushMatrix();

            setMatrix(augmentedRealityMarkers.getMarkerMatrix(0));

            scale(-1, -1);

            imageMode(CENTER);
            image(crackedEgg, 0, 0, 100, 120);


            perspective();

            popMatrix();

            println("here");
            image(bowl, 320, 400, 640, 200);

            //            
            //            fill(255, 0, 0);
            //            textSize(25);
            //            text("Eggs Cracked:" + eggCount, 100, 50);
            if (inBowlCount == 25) {
              gameState = 2.0;
            }
          } else {
            //inBowlCount = 0;

            // set the AR perspective
            augmentedRealityMarkers.setARPerspective();

            pushMatrix();

            setMatrix(augmentedRealityMarkers.getMarkerMatrix(0));

            scale(-1, -1);

            imageMode(CENTER);
            image(egg, 0, 0, 50, 60);


            perspective();

            popMatrix();
          }
        } //ends if
      }//ends try

      catch (Exception e) {
        println("Something went wrong with AR Tracking, skipping this frame.");
      }//ends catch
    }//ends if video avaiable
  }

  if (gameState == 1.4)
  {
    imageMode(CORNER);
    image(backgroundFail, 0, 0, 640, 480);
    image(fail, 200, 250, 177, 250);

    if (failSound.isPlaying()== false) {
      failSound.rewind();
      failSound.play();
    }
    timer++;
    if (timer == 160)
    {
      gameState = 2.0;
      timer = 0;
      failCount++;
    }
  }



  //third fiducial - egg 2
  if (gameState == 2.0) {
    // we only really want to do something if there is fresh data from the camera waiting for us
    if (video.available())
    {
      // read in the video frame and display it
      video.read();
      imageMode(CORNER);

      image(kitchenBackground, 0, 0);

      imageMode(CENTER);
      image(bowl, 320, 400, 640, 200);

      //start the timer
      timer++; 
      fill(255, 0, 0);
      textSize(25);
      text("Time Left:" + (10 - (timer/60)), 100, 50);
      if (timer == 600)
      {
        //you failed
        gameState = 2.4; 
        timer = 0;
      }


      try {
        // ask the AR marker object to attempt to find our patterns in the incoming video stream
        augmentedRealityMarkers.detect(video);

        // assume these guys aren't close to one another
        boolean close = false;


        // does pattern #1 exist in this video frame?
        if (augmentedRealityMarkers.isExistMarker(2))
        {
          // ok, now we are in business!  Test to see how far apart they are
          // first, get their position in 2D space
          PVector[] marker3 = augmentedRealityMarkers.getMarkerVertex2D(2);

          // average up the 4 points of each marker and obtain the center point, then compute the
          // distance between the two center points
          float x1 = (marker3[0].x + marker3[1].x + marker3[2].x + marker3[3].x)/4;
          float y1 = (marker3[0].y + marker3[1].y + marker3[2].y + marker3[3].y)/4;

          float distance = dist(x1, y1, 320, 400);

          println(x1 + "," + y1);


          if (distance < 200) { 
            close = true;
          }


          // if we are egg#1 close draw another bowl
          if (close) {
            inBowlCount++;
            // set the AR perspective
            augmentedRealityMarkers.setARPerspective();

            pushMatrix();

            setMatrix(augmentedRealityMarkers.getMarkerMatrix(2));

            scale(-1, -1);

            imageMode(CENTER);
            image(crackedEgg, 0, 0, 100, 120);


            perspective();
            popMatrix();

            println("here");
            image(bowl, 320, 400, 640, 200);

            //            
            //            fill(255, 0, 0);
            //            textSize(25);
            //            text("Eggs Cracked:" + eggCount, 100, 50);
            if (inBowlCount == 25) {
              gameState = 3.0;
            }
          } else {
            inBowlCount = 0;

            // set the AR perspective
            augmentedRealityMarkers.setARPerspective();

            pushMatrix();

            setMatrix(augmentedRealityMarkers.getMarkerMatrix(2));

            scale(-1, -1);

            imageMode(CENTER);
            image(egg, 0, 0, 50, 60);


            perspective();

            popMatrix();
          }
        } //ends if
      }//ends try

      catch (Exception e) {
        println("Something went wrong with AR Tracking, skipping this frame.");
      }//ends catch
    }//ends if video avaiable
  }

  if (gameState == 2.4)
  {
    imageMode(CENTER);
    image(backgroundFail, 320, 240, 640, 480);
    image(fail, 300, 350, 177, 250);
    if (failSound.isPlaying() == false) {
      failSound.rewind();
      failSound.play();
    }
    timer++;
    if (timer == 160)
    {
      gameState = 3.0;
      timer = 0;
      failCount++;
    }
  }

  //egg 3
  if (gameState == 3.0) {
    // we only really want to do something if there is fresh data from the camera waiting for us
    if (video.available())
    {
      // read in the video frame and display it
      video.read();
      imageMode(CORNER);

      image(kitchenBackground, 0, 0);

      imageMode(CENTER);
      image(bowl, 320, 400, 640, 200);


      //start the timer
      timer++; 
      fill(255, 0, 0);
      textSize(25);
      text("Time Left:" + (10 - (timer/60)), 100, 50);
      if (timer == 600)
      {
        //you failed
        gameState = 3.4; 
        timer = 0;
      }
      try {
        // ask the AR marker object to attempt to find our patterns in the incoming video stream
        augmentedRealityMarkers.detect(video);

        // assume these guys aren't close to one another
        boolean close = false;


        // does pattern #1 exist in this video frame?
        if (augmentedRealityMarkers.isExistMarker(3))
        {
          // ok, now we are in business!  Test to see how far apart they are
          // first, get their position in 2D space
          PVector[] marker4 = augmentedRealityMarkers.getMarkerVertex2D(3);

          // average up the 4 points of each marker and obtain the center point, then compute the
          // distance between the two center points
          float x1 = (marker4[0].x + marker4[1].x + marker4[2].x + marker4[3].x)/4;
          float y1 = (marker4[0].y + marker4[1].y + marker4[2].y + marker4[3].y)/4;

          float distance = dist(x1, y1, 320, 400);

          println(x1 + "," + y1);


          if (distance < 200) { 
            close = true;
          }


          // if we are egg#1 close draw another bowl
          if (close) {
            inBowlCount++;
            // set the AR perspective
            augmentedRealityMarkers.setARPerspective();

            pushMatrix();

            setMatrix(augmentedRealityMarkers.getMarkerMatrix(3));

            scale(-1, -1);

            imageMode(CENTER);
            image(crackedEgg, 0, 0, 100, 120);


            perspective();
            popMatrix();

            println("here");
            image(bowl, 320, 400, 640, 200);

            //            
            //            fill(255, 0, 0);
            //            textSize(25);
            //            text("Eggs Cracked:" + eggCount, 100, 50);
            if (inBowlCount == 25) {
              gameState = 3.5;
            }
          } else {
            inBowlCount = 0;

            // set the AR perspective
            augmentedRealityMarkers.setARPerspective();

            pushMatrix();

            setMatrix(augmentedRealityMarkers.getMarkerMatrix(3));

            scale(-1, -1);

            imageMode(CENTER);
            image(egg, 0, 0, 50, 60);


            perspective();

            popMatrix();
          }
        } //ends if
      }//ends try

      catch (Exception e) {
        println("Something went wrong with AR Tracking, skipping this frame.");
      }//ends catch
    }//ends if video avaiable
  }
  //you failed :(
  if (gameState == 3.4)
  {
    imageMode(CORNER);
    image(backgroundFail, 0, 0, 640, 480);
    image(fail, 200, 250, 177, 250);
    if (failSound.isPlaying() == false) {
      failSound.rewind();
      failSound.play();
    }
    timer++;
    if (timer == 160)
    {
      gameState = 3.6;
      timer = 0;
      failCount++;
    }
  }

  //you passed! :)
  if (gameState == 3.5)
  {
    imageMode(CORNER);
    image(backgroundPass, 0, 0, 640, 480);
    image(pass, 200, 100, 218, 384);
    if (passSound.isPlaying() == false) {
      passSound.rewind();
      passSound.play();
    }
    timer++;
    println(timer); 
    if (timer == 140)
    {
      gameState = 3.6;
      timer = 0;
    }
  }
  if (gameState == 3.6)
  {
    imageMode(CORNER);
    image(honeyTitle, 0, 0, 640, 480);

    if (keyPressed)
    {
      gameState = 4.0;
    }
  }


  //inbetween gamestate 

  //honeydrop
  if (gameState == 4.0) {

    // we only really want to do something if there is fresh data from the camera waiting for us
    if (video.available())
    {
      // read in the video frame and display it
      video.read();
      imageMode(CORNER);

      image(outside, 0, 0);

      //imageMode(CENTER);
      //image(bowl, 320, 400, 640, 200);

      // create honey drop object
      for (int i = 0; i < honey.length; i++)
      {
        //honey[i] = new HoneyDrop(random(50, width-50), random(-500, -50));
        honey[i].move();
        honey[i].display();
      }

      //creat the bees
      for (int i = 0; i < theBee.length; i++)
      {
        //theBee[i] = new BumbleBee(random(50, width-50), random(-500, 0));
        theBee[i].move();
        theBee[i].display();
      }
      fill(255);
      textSize(24);
      text("Your Honey Count: " + honeyPoints, 20, 40);

      //start the timer
      timer++; 
      text("Time Left:" + (20 - (timer/60)), 20, 60);
      if (timer == 1200)
      {
        //you failed
        gameState = 4.4; 
        timer = 0;
      }
      try {
        // ask the AR marker object to attempt to find our patterns in the incoming video stream
        augmentedRealityMarkers.detect(video);

        // assume these guys aren't close to one another
        boolean close = false;



        // does pattern #1 exist in this video frame?
        if (augmentedRealityMarkers.isExistMarker(1))
        {
          // ok, now we are in business!  Test to see how far apart they are
          // first, get their position in 2D space
          PVector[] marker1 = augmentedRealityMarkers.getMarkerVertex2D(1);

          // average up the 4 points of each marker and obtain the center point, then compute the
          // distance between the two center points
          float x1 = (marker1[0].x + marker1[1].x + marker1[2].x + marker1[3].x)/4;
          float y1 = (marker1[0].y + marker1[1].y + marker1[2].y + marker1[3].y)/4;

          float distance = dist(x1, y1, 320, 400);

          println(x1 + "," + y1);
          // set the AR perspective
          augmentedRealityMarkers.setARPerspective();

          pushMatrix();

          setMatrix(augmentedRealityMarkers.getMarkerMatrix(1));

          scale(-1, -1);

          imageMode(CENTER);
          image(Tablespoon, 0, 0, 120, 150);


          perspective();



          popMatrix();

          // draw the honey
          //          for (int i = 0; i < honey.length; i++)
          //          {
          //            
          //          }
          //draw the bee
          for (int i = 0; i < theBee.length; i++)
          {
            theBee[i].checkHit(x1, y1);
          }

          for (int i = 0; i < honey.length; i++)
          {
            honey[i].checkHit(x1, y1);
          }


          //draw the player
          imageMode(CORNER);


          //image(Tablespoon, mouseX, mouseY, 300, 115);

          if (honeyPoints==15)
          {
            gameState = 4.5;
          }
        }
      }
      catch (Exception e) {
        println("Something went wrong with AR Tracking, skipping this frame.");
      }//ends catch
    }
  }

  //failed   
  if (gameState == 4.4)
  {
    imageMode(CORNER);
    image(backgroundFail, 0, 0, 640, 480);
    image(fail, 200, 250, 177, 250);
    if (failSound.isPlaying() == false) {
      failSound.rewind();
      failSound.play();
    }
    timerHoney++;
    if (timerHoney == 160)
    {
      gameState = 4.6;
      timer = 0;
      failCount++;
    }
  }
  if (gameState == 4.5)
  {
    imageMode(CORNER);
    image(backgroundPass, 0, 0, 640, 480);
    image(pass, 200, 100, 218, 384);
    if (passSound.isPlaying() == false) {
      passSound.rewind();
      passSound.play();
    }

    timerHoney++; 
    if (timerHoney == 130)
    {
      gameState = 4.6;
      timer = 0;
    }
  }

  if (gameState == 4.6)
  {
    imageMode(CORNER);
    image(butterTitle, 0, 0, 640, 480);


    if (keyPressed)
    {
      gameState = 5.0;
    }
  }

  if (gameState == 5.0) {
    // we only really want to do something if there is fresh data from the camera waiting for us
    if (video.available())
    {
      // read in the video frame and display it
      video.read();
      imageMode(CORNER);

      image(cuttingBoard, 0, 0, 640, 480);
      image(butter, 0, 50, wb, 413, 0, 0, wb, 413);
      fill(255);
      rect(604-(120*cutCount), 50, 3, 413);

      //start the timer
      timer++; 
      text("Time Left:" + (10 - (timer/60)), 20, 60);
      if (timer == 600)
      {
        //you failed
        gameState = 5.4; 
        timer = 0;
      }

      try {
        // ask the AR marker object to attempt to find our patterns in the incoming video stream
        augmentedRealityMarkers.detect(video);

        // does pattern #1 exist in this video frame?
        if (augmentedRealityMarkers.isExistMarker(0))
        {
          //System.out.println("i see");
          // ok, now we are in business!  Test to see how far apart they are
          // first, get their position in 2D space
          PVector[] marker1 = augmentedRealityMarkers.getMarkerVertex2D(0);

          // average up the 4 points of each marker and obtain the center point, then compute the
          // distance between the two center points
          float x1 = (marker1[0].x + marker1[1].x + marker1[2].x + marker1[3].x)/4;
          float y1 = (marker1[0].y + marker1[1].y + marker1[2].y + marker1[3].y)/4;
          System.out.println(x1);
          System.out.println(y1);

          float distance = dist(x1, y1, 64-(120*cutCount), 50);

          System.out.println(x1 + "," + y1);



          // set the AR perspective
          augmentedRealityMarkers.setARPerspective();

          pushMatrix();

          setMatrix(augmentedRealityMarkers.getMarkerMatrix(0));

          if (dist(x1, y1, wb, 250) <= 50) {
            cutCount++;
            wb -= 120;
          }
          //detect a hit if the knife is within 50px of the center of the line, shortens the butter
          if (wb <= 50)
          {
            gameState = 5.5;
          }
          scale(-1, -1);

          imageMode(CENTER);
          image(knife, 0, 0, 150, 180);


          perspective();

          popMatrix();
        }//ends if
        // else System.out.println("i got nothin");
      }//ends try

      catch (Exception e) {
        println("Something went wrong with AR Tracking, skipping this frame.");
      }//ends catch
    }//ends if video avaiable
  }//ends if game state = 0

  //failed   
  if (gameState == 5.4)
  {
    imageMode(CORNER);
    image(backgroundFail, 0, 0, 640, 480);
    image(fail, 200, 250, 177, 250);
    if (failSound.isPlaying() == false) {
      failSound.rewind();
      failSound.play();
    }
    timer++;
    if (timer == 160)
    {
      gameState = 5.6;
      timer = 0;
      failCount++;
    }
  }

  if (gameState == 5.5)
  {
    imageMode(CORNER);
    image(backgroundPass, 0, 0, 640, 480);
    image(pass, 200, 100, 218, 384);
    if (passSound.isPlaying() == false) {
      passSound.rewind();
      passSound.play();
    }
    timer++; 
    println(timer);
    if (timer > 800)
    {
      gameState = 5.6;
      timer = 0;
    }
  }
  if (gameState == 5.6)
  {
    imageMode(CORNER);
    image(batterTitle, 0, 0, 640, 480);

    if (keyPressed)
    {
      gameState = 6.0;
    }
  }
  //KANJIIIIIIII
  //this level you cannot fail
  if (gameState == 6.0) {
    // we only really want to do something if there is fresh data from the camera waiting for us
    if (video.available())
    {
      // read in the video frame and display it
      video.read();
      imageMode(CORNER);

      image(kitchenBackground, 0, 0);

      imageMode(CENTER);
      image(bowl, 320, 400, 640, 200);


      try {
        // ask the AR marker object to attempt to find our patterns in the incoming video stream
        augmentedRealityMarkers.detect(video);

        // assume these guys aren't close to one another
        boolean close = false;


        // does pattern #1 exist in this video frame?
        if (augmentedRealityMarkers.isExistMarker(1))
        {
          // ok, now we are in business!  Test to see how far apart they are
          // first, get their position in 2D space
          PVector[] marker1 = augmentedRealityMarkers.getMarkerVertex2D(1);

          // average up the 4 points of each marker and obtain the center point, then compute the
          // distance between the two center points
          float x1 = (marker1[0].x + marker1[1].x + marker1[2].x + marker1[3].x)/4;
          float y1 = (marker1[0].y + marker1[1].y + marker1[2].y + marker1[3].y)/4;

          float distance = dist(x1, y1, 320, 400);

          println(x1 + "," + y1);


          if (distance < 275) { 
            close = true;
          }

          // set the AR perspective
          augmentedRealityMarkers.setARPerspective();

          pushMatrix();

          setMatrix(augmentedRealityMarkers.getMarkerMatrix(1));

          scale(-1, -1);

          imageMode(CENTER);
          image(whisk, 0, 0, 150, 180);


          perspective();

          popMatrix();


          // if we are close draw another bowl
          if (close) {
            println("here");
            image(bowl, 320, 400, 640, 200);
            inBowlCount++;

            fill(255, 0, 0);
            textSize(25);
            text("Time Left:" + (5 - (inBowlCount/60)), 100, 50);

            if (inBowlCount == 300)
            {
              gameState = 7.0;
            }
          } else {
            inBowlCount = 0;
          }
        } //ends if
      }//ends try

      catch (Exception e) {
        println("Something went wrong with AR Tracking, skipping this frame.");
      }//ends catch
    }//ends if video avaiable
  }//ends if game state = 0

  if (gameState == 7.0)
  {
    if (failCount == 3 || failCount > 3)
    {
      imageMode(CORNER);
      image(backgroundImage, 0, 0, 640, 480);
      image(fail, 320, 240, 177, 250);
      fill(0);
      textAlign(CENTER);
      textSize(42);
      text("Your cake tasted horrible", 320, 150);
    } else {
      imageMode(CORNER);
      image(finalCake, 0, 0, 640, 480);
      fill(0);
      textSize(50);
      text("You did it!", 100, 50);
    }
  }
}

