/*
  * K1 Racing
*/

class Track {  
  // Dimensions
  static final float OUTER_TRACK_WIDTH = 6000f;
  static final float OUTER_TRACK_HEIGHT = 3000f;
  static final float INNER_TRACK_WIDTH = OUTER_TRACK_WIDTH - 1000f;
  static final float INNER_TRACK_HEIGHT = OUTER_TRACK_HEIGHT - 1000f;
  static final float SIZE_OF_GROUND = 4*OUTER_TRACK_WIDTH/3;
  static final int SQUARE_SIZE = 50;
  static final float NUMBER_OF_SQUARES = ((OUTER_TRACK_HEIGHT - INNER_TRACK_HEIGHT) / (2*SQUARE_SIZE));
  static final float BARRIER_HEIGHT = 35f;
  static final float BARRIER_THICKNESS = 30f;
  static final float TIRE_LENGTH = 25f;
  static final float TIRE_HEIGHT = 13f;
  static final float BLEACHER_ROWS = 8f;
  static final float BLEACHER_HEIGHT = 35f;
  static final float BLEACHER_DEPTH = 65f;
  static final float BLEACHER_THICKNESS = 55f;
  static final float BLEACHER_DEPTH_OFFSET_FACTOR = 0.8f;
  static final float BLEACHER_HEIGHT_OFFSET_FACTOR = 0.7f;
  
  // Physics
  static final float COLLISION_VEL_MULT = -0.45f;
  static final float COLLISION_SPEED_MULT = -1.1f;
  static final float TRACK_OUTER_BOUNDARY = 0.9875f;
  static final float TRACK_INNER_BOUNDARY = 1.0125f;
  
  // Positions
  PVector position;
  static final float ORIGIN_X = 0f;
  static final float ORIGIN_Z = 0f;
  static final float TRACK_Y = 5f;
  static final float DEG_INCREMENT = 5f;
  static final float DISTANCE_FROM_TRACK = 25f;
  static final float STADIUM_RADIUS = OUTER_TRACK_WIDTH/2 + 500;
  float offsetY = 0f;
  
  // Visuals
  static final float TRACK_STROKE_WEIGHT = 6;
  static final float MARKING_STROKE_WEIGHT = 2;
  static final int TRACK_COLOUR = 0xFF575756;
  static final int BOUNDARY_COLOUR = 0xFFFFFFFF;
  static final int BOUNDARY_COLOUR_RED = 0xFFFF0000;
  static final int LANE_MARKING_COLOUR = 0xFF191919;
  static final int GROUND_COLOUR = 0xFF99EDC3;
  static final int TIRE_COLOUR = 0xFF282828;
  static final int BLEACHER_COLOUR_LIGHT = 0xFFD2D2D2;
  static final int BLEACHER_COLOUR_DARK = 0xFFAAAAAA;
  
  Track(float x, float y, float z) {
    position = new PVector(x, y, z);
  }
  
  private void drawOuterTrack() {
    pushMatrix();
    offsetY = 3f;
    translate(ORIGIN_X, TRACK_Y + offsetY, ORIGIN_Z);
    rotateX(PI/2);
    strokeWeight(TRACK_STROKE_WEIGHT);
    stroke(BOUNDARY_COLOUR);
    fill(TRACK_COLOUR);
    ellipse(ORIGIN_X, ORIGIN_Z, OUTER_TRACK_WIDTH, OUTER_TRACK_HEIGHT);
  }
  
  private void drawLaneMarkings() {
    stroke(LANE_MARKING_COLOUR);
    ellipse(ORIGIN_X, ORIGIN_Z, (OUTER_TRACK_WIDTH + INNER_TRACK_WIDTH) / 2, (OUTER_TRACK_HEIGHT + INNER_TRACK_HEIGHT) / 2);
    ellipse(ORIGIN_X, ORIGIN_Z, (3*OUTER_TRACK_WIDTH + INNER_TRACK_WIDTH) / 4, (3*OUTER_TRACK_HEIGHT + INNER_TRACK_HEIGHT) / 4);
    ellipse(ORIGIN_X, ORIGIN_Z, (OUTER_TRACK_WIDTH + 3*INNER_TRACK_WIDTH) / 4, (OUTER_TRACK_HEIGHT + 3*INNER_TRACK_HEIGHT) / 4);
    popMatrix();
  }
  
  private void drawInnerTrack() {
    pushMatrix();
    translate(ORIGIN_X, TRACK_Y, ORIGIN_Z);
    rotateX(PI/2);
    stroke(BOUNDARY_COLOUR);
    fill(GROUND_COLOUR);
    ellipse(ORIGIN_X, ORIGIN_Z, INNER_TRACK_WIDTH, INNER_TRACK_HEIGHT);
    popMatrix(); 
  }
  
  private void drawGround() {    
    pushMatrix();
    offsetY = 5f;
    translate(ORIGIN_X, TRACK_Y + offsetY, ORIGIN_Z);
    fill(GROUND_COLOUR);
    noStroke();
    rotateX(PI/2);
    ellipse(ORIGIN_X, ORIGIN_Z, SIZE_OF_GROUND, SIZE_OF_GROUND/2);
    popMatrix(); 
  }
  
  private void drawFinishLine() {
    for (int row = 1; row < 3; row++) {
      pushMatrix();
      noLights();
      offsetY = 1f;
      translate(-row*SQUARE_SIZE, TRACK_Y + offsetY, OUTER_TRACK_HEIGHT/2);
      rotateX(PI/2);
      noStroke();
      
      // Draws the appropriate number of boxes and splits the gaps for alternating black and white.
      for(int i = 1; i <= NUMBER_OF_SQUARES; i++) {
        if ((i + row) % 2 == 0) {
          fill(#FFFFFF);
          rect(0, (-SQUARE_SIZE)*i, SQUARE_SIZE, SQUARE_SIZE);
        } else { 
          fill(#000000);
          rect(0, (-SQUARE_SIZE)*i, SQUARE_SIZE, SQUARE_SIZE);
        }
      }
      
      lights();
      popMatrix();
    }
  }
  
  // Displays the F1 style walls.
  private void drawWalls() {
    // Outer barrier; red and white striped like F1
    for (int angleDeg = 0; angleDeg < 360; angleDeg += 5) {
      // Current and next variables.
      float angleRad = radians(angleDeg);
      float x = cos(angleRad) * (OUTER_TRACK_WIDTH/2 + DISTANCE_FROM_TRACK);
      float z = sin(angleRad) * (OUTER_TRACK_HEIGHT/2 + DISTANCE_FROM_TRACK);
      float nextAngle = radians(angleDeg + DEG_INCREMENT);
      float nextX = cos(nextAngle) * (OUTER_TRACK_WIDTH/2 + DISTANCE_FROM_TRACK);
      float nextZ = sin(nextAngle) * (OUTER_TRACK_HEIGHT/2 + DISTANCE_FROM_TRACK);
      
      pushMatrix(); 
      translate((x + nextX)/2, TRACK_Y - BARRIER_HEIGHT/2, (z + nextZ)/2);
      
      // Alternate red and white sections
      if ((angleDeg / 5) % 2 == 0) {
        fill(BOUNDARY_COLOUR_RED);
      } else {
        fill(BOUNDARY_COLOUR);
      }
      
      noStroke();
      float barrierLength = dist(x, z, nextX, nextZ);
      rotateY(atan2(nextX - x, nextZ - z));
      box(BARRIER_THICKNESS, BARRIER_HEIGHT, barrierLength);
      popMatrix();
    }
    
    // Inner barrier; stacked tires.
    for (int angleDeg = 0; angleDeg < 360; angleDeg += 1) {
      float angleRad = radians(angleDeg);
      float x = cos(angleRad) * (INNER_TRACK_WIDTH/2 - DISTANCE_FROM_TRACK);
      float z = sin(angleRad) * (INNER_TRACK_HEIGHT/2 - DISTANCE_FROM_TRACK);
      
      // Simple stacked tire boxes
      for (int i = 0; i < 2; i++) {
        pushMatrix();
        translate(x, TRACK_Y + (i * 15) - 10, z);
        fill(TIRE_COLOUR);
        noStroke();
        box(TIRE_LENGTH, TIRE_HEIGHT, TIRE_LENGTH);
        popMatrix();
      }
    }
  }
  
  // Draws the bleachers.
  private void drawStadium() {    
    // Create bleachers in sections around the track - smaller ANGLE increment for continuous connection
    for (int angleDeg = 0; angleDeg < 360; angleDeg += 1) {
      float angleRad = radians(angleDeg);
      
      // Create multiple rows of bleachers
      for (int row = 0; row < BLEACHER_ROWS; row++) {
        pushMatrix();
        
        // Position each row further back and higher up
        float rowOffset = row * BLEACHER_DEPTH * BLEACHER_DEPTH_OFFSET_FACTOR;
        float rowHeight = row * BLEACHER_HEIGHT * BLEACHER_HEIGHT_OFFSET_FACTOR;
        
        // Calculate position for this row
        float rowX = cos(angleRad) * (STADIUM_RADIUS + rowOffset);
        float rowZ = sin(angleRad) * ((STADIUM_RADIUS + rowOffset) * (OUTER_TRACK_HEIGHT / (float)OUTER_TRACK_WIDTH));
        
        translate(rowX, TRACK_Y - rowHeight, rowZ);
        
        // Alternate colors for visual interest
        if (row % 2 == 0) {
          fill(BLEACHER_COLOUR_LIGHT);
        } else {
          fill(BLEACHER_COLOUR_DARK);
        }
        
        // Rotate to face the track center
        rotateY(atan2(-rowX, -rowZ));
        
        noStroke();
        // Make boxes wider to ensure complete connection
        box(BLEACHER_THICKNESS, BLEACHER_HEIGHT, BLEACHER_DEPTH);
        popMatrix();
      }
    }
  }
  
  // Displays the track.
  void displayTrack() {
    drawOuterTrack();
    drawLaneMarkings();
    drawInnerTrack();
    drawGround();
    drawFinishLine();
    drawWalls();
    drawStadium();
  }
  
  // Checks to see whether or not the kart collides with the track borders.
  void checkWallCollision(Kart kart) {
    // Checks user equation of an ellipse.
    float outerCheck = sq(kart.position.x / (Track.OUTER_TRACK_WIDTH / 2)) + sq(kart.position.z / (Track.OUTER_TRACK_HEIGHT / 2));
    float innerCheck = sq(kart.position.x / (Track.INNER_TRACK_WIDTH / 2)) + sq(kart.position.z / (Track.INNER_TRACK_HEIGHT / 2));
    
    // If the equation of the outer ellipse is slighty greater than 1, it brings the kart back by bouncing it in. If slightly less than 1 also pulls in.
    if (outerCheck >= TRACK_OUTER_BOUNDARY) {
      kart.velocity.mult(COLLISION_VEL_MULT);
      kart.speed *= COLLISION_SPEED_MULT;
    } else if (innerCheck <= TRACK_INNER_BOUNDARY) {
      kart.velocity.mult(COLLISION_VEL_MULT);
      kart.position.add(kart.velocity);
      kart.speed *= COLLISION_SPEED_MULT;
    }
  }
}

class Kart {
  // Dimensions
  static final float KART_LENGTH = 100f;
  static final float KART_WIDTH = KART_LENGTH / 4;
  static final float KART_HEIGHT = KART_LENGTH / 10;
  static final float SECTION_LENGTH = KART_LENGTH / 5;
  static final float WING_HEIGHT = 2f;
  static final float WING_LENGTH = 4f;
  static final float TIRE_WIDTH = 15f;
  static final float TIRE_HEIGHT = 15f;
  static final float TIRE_LENGTH = 22f;
  static final float COCKPIT_WIDTH = 10f;
  static final float COCKPIT_HEIGHT = 6f;
  static final float COCKPIT_LENGTH = 30f;
  
  // Physics
  PVector velocity;
  float speed;
  static final float FRICTION = 0.98f;
  static final float MAX_SPEED = (30 / FRICTION);
  static final float ACCELERATION = (0.4 / FRICTION);
  static final float BOOST_FACTOR = 0.35f;
  static final float TURN_SPEED = 0.015f;
  static final float VEL_LERP_FACTOR = 0.015f;
  static final float DRIFT_SPEED_FACTOR = 0.99f;
  static final float DRIFT_TURN_FACTOR = 1.5f;
  
  // Positions
  PVector position;
  float rotation = -PI/2;
  static final float KART_BODY_X = 0f;
  static final float KART_BODY_Z = 2f;
  static final float WING_X = 0f;
  static final float WING_Z_OFFSET = 5f;
  static final float TIRE_Y = KART_HEIGHT/2 + 2;
  static final float TIRE_Z = KART_LENGTH/3;
  static final float COCKPIT_X = 0f;
  static final float COCKPIT_Y = -2f;
  static final float COCKPIT_Z = 5f;
  
  // Visuals
  static final int KART_BODY_COLOUR = 0xFFFF0000;
  static final int KART_WING_COLOUR = 0xFF646464;
  static final int TIRE_COLOUR = 0xFF000000;
  static final int BURNING_TIRE_COLOUR_1 = 0xFF802010;
  static final int BURNING_TIRE_COLOUR_2 = 0xFFA03010;
  static final int BURNING_TIRE_COLOUR_3 = 0xFFFF4500;
  static final int COCKPIT_COLOUR = 0xFF0064C8;
  float driftStartTime = 0;
  boolean wasDrifting = false;
  
  Kart(float x, float y, float z) { 
    position = new PVector(x, y, z);
    velocity = new PVector(0, 0, 0);
    speed = 0;
  }   
  
  // Updates values for the kart.
  void update() {
    speed *= FRICTION;
    
    // Calculate where the kart wants to go based on its current direction
    PVector intendedDirection = new PVector(sin(rotation), 0, cos(rotation));
    PVector intendedVelocity = PVector.mult(intendedDirection, speed);
    
    // If not drifting, snap velocity to intended direction (strong grip)
    if (!keySpace) {
      velocity = intendedVelocity.copy();
    } else {
      // If drifting, blend between current velocity and intended velocity
      velocity.lerp(intendedVelocity, VEL_LERP_FACTOR); // (lower = more drift)
    }
    
    // Update position
    position.add(velocity);
  }
  
  // Acceleration applies until current speed equals the maximum speed.
  void accelerate() {
    speed += ACCELERATION;
    
    if (speed > (MAX_SPEED / 2)) {
       speed += BOOST_FACTOR * ACCELERATION;
    }
    
    if (speed > MAX_SPEED) {
      speed = MAX_SPEED;
    }
  }
  
  // Decreases the speed at the rate of accleration but only until quarter of max speed.
  void brake() {
    speed -= ACCELERATION;
    
    if (speed < -MAX_SPEED/4) {
      speed = -MAX_SPEED/4;
    }
  }
  
  // Increases the ANGLE of rotation, turning the kart counter-clockwise (left).
  void turnLeft() {
    rotation += TURN_SPEED;
    
    if (keySpace == true) {
      rotation += TURN_SPEED/DRIFT_TURN_FACTOR;
      speed *= DRIFT_SPEED_FACTOR;
    }
  }

  // Decreases the ANGLE of rotation, turning the kart clockwise (right).
  void turnRight() {
    rotation -= TURN_SPEED;
    
    if (keySpace == true) {
      rotation -= TURN_SPEED/DRIFT_TURN_FACTOR;
      speed *= DRIFT_SPEED_FACTOR;
    }
  }
  
  private void drawKartBody() {
    translate(position.x, position.y, position.z);
    rotateY(rotation);
    
    // Very narrow nose section
    fill(KART_BODY_COLOUR);
    noStroke();
    
    float sectionLengthOffsetFactor = 0.5f;
    float kartWidthOffsetFactor = 8f;
    
    for (int kartSection = 1; kartSection < 6; kartSection++) {
      pushMatrix();
      translate(KART_BODY_X, KART_BODY_Z, KART_LENGTH/2 - SECTION_LENGTH * sectionLengthOffsetFactor);
      box(KART_WIDTH - kartWidthOffsetFactor, KART_HEIGHT, SECTION_LENGTH);
      kartWidthOffsetFactor -= 4;
      sectionLengthOffsetFactor += 1;
      popMatrix();
    }
  }
  
  private void drawWings() {
    float wingOffsetY = 8f;
    float wingWidthOffset = 10f;
    fill(KART_WING_COLOUR);
    
    for (int i = 1; i > -2; i -= 2) {
      pushMatrix();
      translate(WING_X, wingOffsetY, i * (KART_LENGTH/2 + WING_Z_OFFSET));
      box(KART_WIDTH + wingWidthOffset, WING_HEIGHT, WING_LENGTH);
      popMatrix();
      wingWidthOffset *= 2;
      wingOffsetY = -6f;
    }
  }
  
  private void drawTires() {
    float tireOffset = 2f;
    float xFrontOrRearFactor = 1f;
    float zFrontOrRearFactor = 1f;
    
    if (keySpace == true) {
      if (wasDrifting == false) {
        driftStartTime = millis();
        wasDrifting = true;
      }
      
      float driftDuration = (millis() - driftStartTime) / 1000.0;
      
      if (driftDuration > 2.8) {
        fill(BURNING_TIRE_COLOUR_3);
      } else if (driftDuration > 1.8) {
        fill(BURNING_TIRE_COLOUR_2);
      } else if (driftDuration > 0.8) {
        fill(BURNING_TIRE_COLOUR_1);
      } else {
        fill(TIRE_COLOUR);
      }
    } else {
      fill(TIRE_COLOUR);
      wasDrifting = false;
    }
    
    for (int i = 1; i < 5; i++) {
      if (i % 2 == 0) {
        xFrontOrRearFactor *= -1;
      }
      
      if (i > 2 && i % 2 == 1) {
        zFrontOrRearFactor  *= -1;
        tireOffset = 6f;
      }
      
      pushMatrix();
      translate(xFrontOrRearFactor * (KART_WIDTH/2 + tireOffset), TIRE_Y, zFrontOrRearFactor * TIRE_Z);
      box(TIRE_WIDTH, TIRE_HEIGHT, TIRE_LENGTH);
      popMatrix();
    }
  }
  
  private void drawCockPit() {
    fill(COCKPIT_COLOUR);
    pushMatrix();
    translate(COCKPIT_X, COCKPIT_Y, COCKPIT_Z);
    box(COCKPIT_WIDTH, COCKPIT_HEIGHT, COCKPIT_LENGTH);
    popMatrix();
  }
  
  // Sets the colour, position, shape, and size.
  void display() {
    pushMatrix();
    drawKartBody();
    drawWings();
    drawTires();
    drawCockPit();
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
    boolean finishLineZ = (kart.position.z <= 3*(Track.OUTER_TRACK_HEIGHT - Track.INNER_TRACK_HEIGHT)/2 && kart.position.z >= (Track.OUTER_TRACK_HEIGHT - Track.INNER_TRACK_HEIGHT));
     
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
      if (kart.position.x >= -75 && kart.position.x <= -25 && kart.position.z >= -(Track.OUTER_TRACK_HEIGHT / 2) && kart.position.z <= -(Track.INNER_TRACK_HEIGHT / 2))
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
      final float CONVERT_TO_KMH = 5.4;
      text("Speed: " + nf((playerKart.speed * CONVERT_TO_KMH), 1, 2) + " KM/H", 20, 30);
     
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

// If the specific key is released, turns the bool false to prevent ACCELERATION in that direction.
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
  
  // If "s" or down arrow, reverse ACCELERATION of kart and move backwards.
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
  playerKart.position = new PVector(0, 0, ((Track.OUTER_TRACK_HEIGHT / 2) - ((Track.OUTER_TRACK_HEIGHT - Track.INNER_TRACK_HEIGHT) / 4)));
  
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
  playerKart = new Kart(0, 0, ((Track.OUTER_TRACK_HEIGHT / 2) - ((Track.OUTER_TRACK_HEIGHT - Track.INNER_TRACK_HEIGHT) / 4)));
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
  
  // Draws the track.
  gameTrack.displayTrack();
  
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
