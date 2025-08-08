/*
 * Title: K1 Racing
 * Description: Formula 1 inspired racing game.
 * Date Created: April 22, 2025
 * Date Last Modified: June 8, 2025
*/

// Class for the track.
class Track
{
  PVector position;
  int outerTrackWidth;
  int outerTrackHeight;
  int innerTrackWidth;
  int innerTrackHeight;
  int trackY;
  float bounceBackVelocity;
  float bounceBackSpeed;
  
  // Constructor method.
  Track(float x, float y, float z)
  {
    position = new PVector(x, y, z);
    outerTrackWidth = 6000;
    outerTrackHeight = 3000;
    innerTrackWidth = outerTrackWidth - 1000;
    innerTrackHeight = outerTrackHeight - 1000;
    bounceBackVelocity = -0.45;
    bounceBackSpeed = -1.1;
    trackY = 5;
  }
  
  // Displays the track.
  void displayTrack()
  {
    // Outer ellipse; the track colour of the ellipse.
    pushMatrix();
    translate(0, trackY + 3, 0);
    rotateX(PI/2);
    strokeWeight(6);
    stroke(255);
    fill(#575756);
    ellipse(0, 0, outerTrackWidth, outerTrackHeight);
    stroke(25);
    
    // Wow this is ugly. Adds the extra grey lines in the track.
    ellipse(0, 0, outerTrackWidth - (outerTrackWidth - innerTrackWidth) / 2, outerTrackHeight - (outerTrackHeight - innerTrackHeight) / 2);
    ellipse(0, 0, outerTrackWidth - (outerTrackWidth - innerTrackWidth) / 4, outerTrackHeight - (outerTrackHeight - innerTrackHeight) / 4);
    ellipse(0, 0, (outerTrackWidth - 3*(outerTrackWidth - innerTrackWidth) / 4), (outerTrackHeight - 3*(outerTrackHeight - innerTrackHeight) / 4));
    popMatrix();
    
    // Inner ellipse; colours inside of the outer ellipse ground colour.
    pushMatrix();
    translate(0, trackY + 2, 0);
    rotateX(PI/2);
    stroke(255);
    fill(#99EDC3);
    ellipse(0, 0, innerTrackWidth, innerTrackHeight);
    popMatrix();
    
    // Variables for the finish line.
    int squareSize = 50;
    int squareNum = ((outerTrackHeight - innerTrackHeight) / (2*squareSize));
    
    // Draw the finish line for the track: ROW 1.
    pushMatrix();
    noLights();
    translate(-50, trackY + 2, outerTrackHeight/2);
    noStroke();
    strokeWeight(2);
    rotateX(PI / 2);
    
    // Draws the appropriate number of boxes and splits the gaps for alternating black and white.
    for(int i = 1; i <= squareNum; i++)
    {
      // White box.
      if (i % 2 == 0)
      {
        fill(#FFFFFF);
        rect(0, (-squareSize)*i, squareSize, squareSize);
      }
      
      // Black box.
      else
      {
        fill(#000000);
        rect(0, (-squareSize)*i, squareSize, squareSize);
      }
    }
    lights();
    popMatrix();
    
    // Draw the finish line for the track: ROW 2.
    pushMatrix();
    translate(-100, trackY + 2, outerTrackHeight/2);
    rotateX(PI / 2);
    noLights();
    
    // Draws the appropriate number of boxes and splits the gaps for alternating black and white; flips order to make checkered pattern.
    for(int i = 1; i <= squareNum; i++)
    {
      // Black box.
      if (i % 2 == 0)
      {
        fill(#000000);
        rect(0, (-squareSize)*i, squareSize, squareSize);
      }
      
      // White box.
      else
      {
        fill(#FFFFFF);
        rect(0, (-squareSize)*i, squareSize, squareSize);
      }
    }
    lights();
    popMatrix();
  }
  
  // Displays the F1 style walls.
  void displayWalls()
  {
    int barrierHeight = 35;
    
    // Outer barrier; red and white striped like F1
    for (int angle = 0; angle < 360; angle += 5)
    {
      // Current and next variables.
      float angleRad = radians(angle);
      float x = cos(angleRad) * (outerTrackWidth/2 + 25);
      float z = sin(angleRad) * (outerTrackHeight/2 + 25);
      float nextAngle = radians(angle + 5);
      float nextX = cos(nextAngle) * (outerTrackWidth/2 + 25);
      float nextZ = sin(nextAngle) * (outerTrackHeight/2 + 25);
      
      pushMatrix(); 
      translate((x + nextX)/2, trackY - barrierHeight/2, (z + nextZ)/2);
      
      // Alternate red and white sections
      if ((angle / 5) % 2 == 0)
      {
        fill(255, 0, 0);
      }
      
      else 
      {
        fill(255, 255, 255);
      }
      
      noStroke();
      float barrierLength = dist(x, z, nextX, nextZ);
      rotateY(atan2(nextX - x, nextZ - z));
      box(20, barrierHeight, barrierLength);
      popMatrix();
    }
    
    // Inner barrier; stacked tires.
    for (int angle = 0; angle < 360; angle += 1)
    {
      float radians = radians(angle);
      float x = cos(radians) * (innerTrackWidth/2 - 25);
      float z = sin(radians) * (innerTrackHeight/2 - 25);
      
      // Simple stacked tire boxes
      for (int i = 0; i < 2; i++)
      {
        pushMatrix();
        translate(x, trackY + (i * 15) - 10, z);
        fill(40, 40, 40);
        noStroke();
        box(25, 13, 25);
        popMatrix();
      }
    }
  }
  
  // Checks to see whether or not the kart collides with the track borders.
  void checkWallCollision(Kart kart)
  {
    // Checks user equation of an ellipse.
    float outerCheck = sq(kart.position.x / (gameTrack.outerTrackWidth / 2)) + sq(kart.position.z / (gameTrack.outerTrackHeight / 2));
    float innerCheck = sq(kart.position.x / (gameTrack.innerTrackWidth / 2)) + sq(kart.position.z / (gameTrack.innerTrackHeight / 2));
    
    // If the equation of the outer ellipse is greater than 1, it brings the kart back by bouncing it in.
    if (outerCheck >= 0.9875)
    {
      kart.velocity.mult(bounceBackVelocity);
      kart.speed *= bounceBackSpeed;
    }
    
    // If equation of the inner ellipse is less than 1, it brings the kart back by bouncing it in.
    if (innerCheck <= 1.0125)
    {
      kart.velocity.mult(bounceBackVelocity);
      kart.position.add(kart.velocity);
      kart.speed *= bounceBackSpeed;
    }
  }
  
  // Draws the ground for the map.
  void displayGround()
  {
    int groundSize = 8000;
    
    pushMatrix();
    translate(0, trackY + 5, 0);
    fill(#99EDC3);
    noStroke();
    rotateX(PI/2);
    ellipse(0, 0, groundSize, groundSize/2);
    popMatrix(); 
  }
  
  // Draws the bleachers.
  void displayStadium()
  {
    int bleacherRows = 8;
    int bleacherHeight = 35;
    int bleacherDepth = 65;
    float stadiumRadius = outerTrackWidth/2 + 500; // Distance from track center
    
    // Create bleachers in sections around the track - smaller angle increment for continuous connection
    for (int angle = 0; angle < 360; angle += 1)
    {
      float radians = radians(angle);
      
      // Create multiple rows of bleachers
      for (int row = 0; row < bleacherRows; row++)
      {
        pushMatrix();
        
        // Position each row further back and higher up
        float rowOffset = row * bleacherDepth * 0.8;
        float rowHeight = row * bleacherHeight * 0.7;
        
        // Calculate position for this row
        float rowX = cos(radians) * (stadiumRadius + rowOffset);
        float rowZ = sin(radians) * ((stadiumRadius + rowOffset) * (outerTrackHeight / (float)outerTrackWidth));
        
        translate(rowX, trackY - rowHeight, rowZ);
        
        // Alternate colors for visual interest
        if (row % 2 == 0)
        {
          fill(200, 200, 200); // Light gray
        }
        else
        {
          fill(180, 180, 180); // Darker gray
        }
        
        // Rotate to face the track center
        rotateY(atan2(-rowX, -rowZ));
        
        noStroke();
        // Make boxes wider to ensure complete connection
        box(45, bleacherHeight, bleacherDepth);
        popMatrix();
      }
    }
  }
}

// Class of the kart with all of the variables.
class Kart
{
  // Different components of class kart. Details given below.
  PVector position;            // Position of the kart.
  PVector velocity;            // Current velocity vector.
  float speed;                 // Current speed.
  float maxSpeed;              // Maximum speed.
  float acceleration;          // Acceleration of kart.
  float friction;              // Friction to slow the kart.
  float rotation;              // Direction the kart is facing. 
  float turnSpeed;             // How quickly the kart can turn.

  // Kart dimensions
  float kartLength;
  float kartWidth;
  float kartHeight;
  
  // Constructor method.
  Kart(float x, float y, float z)
  { 
    position = new PVector(x, y, z);          // Position of kart is input.
    velocity = new PVector(0, 0, 0);          // Velocity of kart begins at rest.
    speed = 0;                                // Speed begins at 0.
    friction = 0.98;                          // Friction slows kart down when not pressing gas.
    maxSpeed = (30 / friction);               // Set max speed.
    acceleration = (0.4 / friction);           // Acceleration of kart set.
    rotation = (-PI / 2);                     // Kart begins facing 90 degrees.
    turnSpeed = 0.015;                        // Turn speed of kart.

    
    // Set dimensions 
    kartHeight = 10;
    kartWidth = 25;
    kartLength = 70;
  }   
  
  // Updates values for the kart.
  void update()
  {
    // Apply friction to speed
    speed *= friction;
    
    // Calculate where the kart wants to go based on its current direction
    PVector intendedDirection = new PVector(sin(rotation), 0, cos(rotation));
    PVector intendedVelocity = PVector.mult(intendedDirection, speed);
    
    // If not drifting, snap velocity to intended direction (strong grip)
    if (!keySpace)
    {
      velocity = intendedVelocity.copy();
    }
    else
    {
      // If drifting, blend between current velocity and intended velocity
      velocity.lerp(intendedVelocity, 0.015); // 0.1 = drift amount (lower = more drift)
    }
    
    // Update position
    position.add(velocity);
  }
  
  // Acceleration applies until current speed equals the maximum speed.
  void accelerate()
  {
    speed += acceleration;
    if (speed > (maxSpeed / 2))
    {
       speed += 0.35*acceleration;
    }
    
    if (speed > maxSpeed)
    {
      speed = maxSpeed;
    }
  }
  
  // Decreases the speed at the rate of accleration but only until quarter of max speed.
  void brake()
  {
    speed -= acceleration;
    if (speed < -maxSpeed/4)
    {
      speed = -maxSpeed/4;
    }
  }
  
  // Increases the angle of rotation, turning the kart counter-clockwise (left).
  void turnLeft()
  {
    rotation += turnSpeed;
    if (keySpace == true)
    {
      rotation += turnSpeed/1.5;
      speed *= 0.99;
    }
  }

  // Decreases the angle of rotation, turning the kart clockwise (right).
  void turnRight()
  {
    rotation -= turnSpeed;
    if (keySpace == true)
    {
      rotation -= turnSpeed/1.5;
      speed *= 0.99;
    }
  }
  
  // Sets the colour, position, shape, and size.
  void display()
  {
    pushMatrix();
    translate(position.x, position.y, position.z);
    rotateY(rotation);
    
    // Make the car bigger overall
    float carLength = kartLength + 30;
    float sectionLength = carLength / 5;
    
    // Very narrow nose section
    fill(255, 0, 0);
    noStroke();
    strokeWeight(1);
    pushMatrix();
    translate(0, 2, carLength/2 - sectionLength/2);
    box(kartWidth - 8, kartHeight - 2, sectionLength);
    popMatrix();
    
    // Section 2 (slightly wider)
    pushMatrix();
    translate(0, 2, carLength/2 - sectionLength * 1.5);
    box(kartWidth - 4, kartHeight - 2, sectionLength);
    popMatrix();
    
    // Section 3 (medium width)
    pushMatrix();
    translate(0, 2, carLength/2 - sectionLength * 2.5);
    box(kartWidth, kartHeight - 2, sectionLength);
    popMatrix();
    
    // Section 4 (getting wider)
    pushMatrix();
    translate(0, 2, carLength/2 - sectionLength * 3.5);
    box(kartWidth + 4, kartHeight - 2, sectionLength);
    popMatrix();
    
    // Section 5 (widest rear)
    pushMatrix();
    translate(0, 2, carLength/2 - sectionLength * 4.5);
    box(kartWidth + 8, kartHeight - 2, sectionLength);
    popMatrix();
  
    // Simple front wing
    fill(100, 100, 100);
    pushMatrix();
    translate(0, 8, carLength/2 + 5);
    box(kartWidth + 5, 2, 4);
    popMatrix();
  
    // Simple rear wing
    pushMatrix();
    translate(0, -6, -carLength/2 - 5);
    box(kartWidth + 10, 3, 5);
    popMatrix();
  
    // Tires - positioned for the bigger car
    fill(0);
  
    // Front tires
    pushMatrix();
    translate(-kartWidth/2 - 2, kartHeight/2 + 2, carLength/3);
    box(12, 15, 18);
    popMatrix();
  
    pushMatrix();
    translate(kartWidth/2 + 2, kartHeight/2 + 2, carLength/3);
    box(12, 15, 18);
    popMatrix();
  
    // Rear tires (wider spacing)
    pushMatrix();
    translate(-kartWidth/2 - 6, kartHeight/2 + 2, -carLength/3);
    box(15, 15, 22);
    popMatrix();
  
    pushMatrix();
    translate(kartWidth/2 + 6, kartHeight/2 + 2, -carLength/3);
    box(15, 15, 22);
    popMatrix();
    
    // While car is drifting
    if (keySpace == true && speed > 15)
    {
      fill(255, 92, 0);
      
      // Front tires
      pushMatrix();
      translate(-kartWidth/2 - 2, kartHeight/2 + 2, carLength/3);
      box(13, 2, 19);
      popMatrix();
    
      pushMatrix();
      translate(kartWidth/2 + 2, kartHeight/2 + 2, carLength/3);
      box(13, 2, 19);
      popMatrix();
    
      // Rear tires (wider spacing)
      pushMatrix();
      translate(-kartWidth/2 - 6, kartHeight/2 + 2, -carLength/3);
      box(16, 2, 23);
      popMatrix();
    
      pushMatrix();
      translate(kartWidth/2 + 6, kartHeight/2 + 2, -carLength/3);
      box(16, 2, 23);
      popMatrix();
    }
  
    // Driver helmet area
    fill(0, 100, 200);
    pushMatrix();
    translate(0, -2, 5);
    box(10, 6, 30);
    popMatrix();
    
    popMatrix();
  }
}

// Class for the timers.
class Timer
{
  boolean gameStarted;
  boolean crossedFinishLine;
  boolean farFromFinishLine;
  float lapStartTime;
  float currentLapTime;
  float bestLapTime;
  float lastLapTime;
  int lapCount;
  
  // Constructor method.
  Timer()
  {
    gameStarted = false;
    crossedFinishLine = false;
    farFromFinishLine = false;
    lapStartTime = 0;
    currentLapTime = 0;
    bestLapTime = Float.MAX_VALUE;
    lastLapTime = 0;
    lapCount = 0;
  }
  
  // Initializes timers.
  void initializeTimers()
  {
    crossedFinishLine = false;
    farFromFinishLine = false;
    currentLapTime = 0;
    bestLapTime = Float.MAX_VALUE;
    lastLapTime = 0;
    lapCount = 0;
  }
  
  void startGame()
  {
    lapStartTime = millis();
  }
  
  // Checks to see if kart has past finish line.
  void checkFinishLine(Kart kart)
  {
    // X and Z range of values that determine the finish line.
    boolean finishLineX = (kart.position.x >= -75 && kart.position.x <= -25);
    boolean finishLineZ = (kart.position.z <= 3*(gameTrack.outerTrackHeight - gameTrack.innerTrackHeight)/2 && kart.position.z >= (gameTrack.outerTrackHeight - gameTrack.innerTrackHeight));
     
    // Checks if user has crossed the finish line.
    if (finishLineX && finishLineZ && !crossedFinishLine)
    {
      crossedFinishLine = true;
      farFromFinishLine = false;
    }
    
    // Check if kart has moved far enough from finish line to reset 
    if (crossedFinishLine && !farFromFinishLine)
    {
      // The distance is the opposite side of the track from the finish line.
      if (kart.position.x >= -75 && kart.position.x <= -25 && kart.position.z >= -(gameTrack.outerTrackHeight / 2) && kart.position.z <= -(gameTrack.innerTrackHeight / 2))
      {
        farFromFinishLine = true;
      }
    }
     
    // Complete a lap when crossing finish line after being far away 
    if (crossedFinishLine && farFromFinishLine && finishLineX && finishLineZ)
    {
      // Calculate lap time
      float currentTime = millis();
      currentLapTime = (currentTime - lapStartTime) / 1000;
       
      // Update lap count and times
      lapCount++;
      lastLapTime = currentLapTime;
       
      // Update best time if this lap was faster
      if (currentLapTime < bestLapTime)
      {
        bestLapTime = currentLapTime;
      }
      
      // Reset for next lap
      lapStartTime = currentTime;
      crossedFinishLine = false;
      farFromFinishLine = false;
      
      // Print lap info to console; more for early stage debugging.
      println("Lap " + lapCount + " completed in " + nf(currentLapTime, 1, 2) + " seconds");
      if (currentLapTime == bestLapTime)
      {
        println("New best time!");
      }
    }
  }
  
  // Displays the timers.
  void displayTimers()
  {         
    // Save current camera state  
    pushMatrix(); 
   
    // Switch to default 2D camera for text overlay  
    camera();  
    hint(DISABLE_DEPTH_TEST);
    noLights();
    
    // Displays the messages before the game has started such as space to start and a hint.
    if(!gameStarted)
    {
      fill(255);  
      textAlign(CENTER);  
      textSize(40);
      text("SPACE to START!", width/2, height/4);
      textAlign(RIGHT);
      textSize(16);
      text("Hint: Hold W/UP before pressing SPACE!", width - 20, height - 30);
    }
    
    // When the game starts, display all the timers.
    else
    {
      // Set up text properties  
      fill(0);  
      textAlign(LEFT);  
      textSize(16);
      
      // Calculate current ongoing lap time  
      float ongoingTime = (millis() - lapStartTime) / 1000.0;
      
      // Speedometer
      float MPS_TO_KMH = 3.6;
      text("Speed: " + nf((playerKart.speed * MPS_TO_KMH), 1, 2) + " KM/H", 20, 30);
     
      // Display current lap time  
      text("Current Lap: " + nf(ongoingTime, 1, 2) + "s", 20, 50); 
     
      // Display lap count  
      text("Laps: " + lapCount, 20, 70); 
     
      // Display last lap time if available  
      if (lastLapTime > 0)  
      {  
        text("Last Lap: " + nf(lastLapTime, 1, 2) + "s", 20, 90);  
      } 
       
      // Display best lap time if available  
      if (bestLapTime < Float.MAX_VALUE)  
      { 
        text("Best Lap: " + nf(bestLapTime, 1, 2) + "s", 20, 110);  
      }
    }
    
    // Display controls; subtle at bottom left.
    fill(255);
    textAlign(LEFT);  
    textSize(16);
    text("Controls: WASD/Arrow Keys, SPACE to Drift, R to Reset", 20, height - 30); 
    lights();
    hint(ENABLE_DEPTH_TEST);  
    popMatrix();  
  }
}

// Variables to handle the inputs.
boolean keyUp;
boolean keyDown;
boolean keyRight;
boolean keyLeft;
boolean keySpace;
  
// If the specific key is pressed, turns the bool true to move the kart in that direction.
void keyPressed()
{
  if (key == 'w' || key == 'W' || keyCode == UP)
  {
    keyUp = true;
  } 
  
  if (key == 's' || key == 'S' || keyCode == DOWN)
  {
    keyDown = true;
  }
  
  if (key == 'a' || key == 'A' || keyCode == LEFT)
  {
    keyLeft = true;
  }
  
  if (key == 'd' || key == 'D' || keyCode == RIGHT)
  {
    keyRight = true;
  }
  
  if (key == ' ')
  {
    keySpace = true;
  }
}

// If the specific key is released, turns the bool false to prevent acceleration in that direction.
void keyReleased()
{
  if (key == 'w' || key == 'W' || keyCode == UP)
  {
    keyUp = false;
  } 
  
  if (key == 's' || key == 'S' || keyCode == DOWN)
  {
    keyDown = false;
  }
  
  if (key == 'a' || key == 'A' || keyCode == LEFT)
  {
    keyLeft = false;
  }
  
  if (key == 'd' || key == 'D' || keyCode == RIGHT)
  {
    keyRight = false;
  }
  
  if (key == ' ')
  {
    keySpace = false;
  }
  
  // If space is pressed, start the game.
  if (key == ' ' && !gameTimer.gameStarted)
  {
    gameTimer.gameStarted = true;
    gameTimer.startGame();
  }
  
  // Restarts the game; moves kart to original position and resets timers.
  if (key == 'r' || key == 'R')
  {
    resetGame();
    gameTimer.initializeTimers();
    gameTimer.gameStarted = false;
  }
}

// Handles the user input for the kart.
void playerInput()
{
  // If "w" or up arrow, accelerate kart forward.
  if (keyUp == true && gameTimer.gameStarted)
  {
    playerKart.accelerate();
  }
  
  // If "s" or down arrow, reverse acceleration of kart and move backwards.
  if (keyDown == true && gameTimer.gameStarted)
  {
    playerKart.brake();
  }
  
  // If "a" or left arrow, rotate the kart to the left.
  if (keyLeft == true && gameTimer.gameStarted)
  {
    playerKart.turnLeft();
  }
  
  // If "d" or right arrow, rotate the kart to the right.
  if (keyRight == true && gameTimer.gameStarted)
  {
    playerKart.turnRight();
  }
}

Track gameTrack;
Timer gameTimer;
Kart playerKart;

// Resets the game: kart position, speed, etc.
void resetGame()
{
  // Sets position of the kart to starting position.
  playerKart.position = new PVector(0, 0, ((gameTrack.outerTrackHeight / 2) - ((gameTrack.outerTrackHeight - gameTrack.innerTrackHeight) / 4)));
  
  // Sets speed of the kart to 0.
  playerKart.velocity = new PVector(0, 0, 0);
  playerKart.speed = 0;
  
  // Sets rotation in proper direction.
  playerKart.rotation = (-PI/2);
}

void setup()
{
  // Sets up game size, classes, and timers.
  fullScreen(P3D, 1);
  gameTrack = new Track(0, 0, 0);
  playerKart = new Kart(0, 0, ((gameTrack.outerTrackHeight / 2) - ((gameTrack.outerTrackHeight - gameTrack.innerTrackHeight) / 4)));
  gameTimer = new Timer();
  gameTimer.initializeTimers();
}

void draw()
{
  // Allows control of the camera distance/height from the kart.
  float cameraHeight = height * 0.0868;
  float cameraDistance = width * 0.117;
  
  // Sets the background colour.
  background(#C3EEFA);
  
  // Sets up lighting for the frame.
  lights();
  
  // Draws the ground.
  gameTrack.displayGround();
  
  // Draws the track.
  gameTrack.displayTrack();
  
  gameTrack.displayStadium();
  
  // Draws the walls/barriers/tires
  gameTrack.displayWalls();
  
  // Sets up the camera; acts like a circle with radius "cameraDistance" and a height "cameraHeight" centered on the karts positions.
  camera((playerKart.position.x - (cameraDistance * sin(playerKart.rotation))),   // x position of camera.
         (playerKart.position.y - cameraHeight),                                  // y position of camera.
         (playerKart.position.z - (cameraDistance * cos(playerKart.rotation))),   // z position of camera.
         (playerKart.position.x),                                                 // x position camera looks at.
         (playerKart.position.y),                                                 // y position camera looks at.
         (playerKart.position.z),                                                 // z position camera looks at.
         0, 1, 0);
  
  // Handles the user input for the kart.
  playerInput();
  
  // Displays the kart.
  playerKart.display();
  
  // Updates the kart using the user inputs.
  playerKart.update();
  
  // Checks to see if the kart is going off the track.
  gameTrack.checkWallCollision(playerKart);
  
  // Checks to see if user has crossed the finish line.
  gameTimer.checkFinishLine(playerKart);
  
  // Displays the current, last, and best lap times.
  gameTimer.displayTimers();
}
