/*
  * K1 Racing
*/

// Kart
static final float KART_STARTING_POSITION_X = 0f;
static final float KART_STARTING_POSITION_Y = 0f;
static final float KART_STARTING_POSITION_Z = (Track.OUTER_TRACK_HEIGHT + Track.INNER_TRACK_HEIGHT) / 4;
static final float KART_STARTING_DIRECTION = -PI/2;

// Camera
static final int BACKGROUND_COLOUR = 0xFFC3EEFA;
static final float CAMERA_HEIGHT_RATIO = 0.0868f;
static final float CAMERA_DISTANCE_RATIO = 0.117f;
float CAMERA_HEIGHT;
float CAMERA_DISTANCE;

void setupCamera() {
  camera((playerKart.position.x - (CAMERA_DISTANCE * sin(playerKart.rotation))),   // x position of camera.
         (playerKart.position.y - CAMERA_HEIGHT),                                  // y position of camera.
         (playerKart.position.z - (CAMERA_DISTANCE * cos(playerKart.rotation))),   // z position of camera.
         (playerKart.position.x),                                                  // x position camera looks at.
         (playerKart.position.y),                                                  // y position camera looks at.
         (playerKart.position.z),                                                  // z position camera looks at.
         0, 1, 0);
}

// Input handling
boolean keyUp, keyDown, keyRight, keyLeft, keySpace;

void updateKey(boolean pressed) {
  if (key == 'w' || key == 'W' || keyCode == UP) keyUp = pressed;
  if (key == 's' || key == 'S' || keyCode == DOWN) keyDown = pressed;
  if (key == 'a' || key == 'A' || keyCode == LEFT) keyLeft = pressed;
  if (key == 'd' || key == 'D' || keyCode == RIGHT) keyRight = pressed;
  if (key == ' ') keySpace = pressed;
}

void keyPressed() {
  updateKey(true);
}

void keyReleased() {
  updateKey(false);
  
  if (key == ' ' && !gameTimer.gameStarted) {
    gameTimer.gameStarted = true;
    gameTimer.startGame();
  }
  
  if (key == 'r' || key == 'R') {
    resetGame();
    gameTimer.initializeTimers();
  }
}

void playerInput() {
  if (!gameTimer.gameStarted) return;
  
  if (keyUp) playerKart.accelerate();
  if (keyDown) playerKart.brake();
  if (keyLeft) playerKart.turnLeft();
  if (keyRight) playerKart.turnRight();
}

Track gameTrack;
Timer gameTimer;
Kart playerKart;

void resetGame() {
  playerKart.position = new PVector(KART_STARTING_POSITION_X, KART_STARTING_POSITION_Y, KART_STARTING_POSITION_Z);
  playerKart.velocity = new PVector(0, 0, 0);
  playerKart.speed = 0;
  playerKart.rotation = KART_STARTING_DIRECTION;
}

void setup() {
  fullScreen(P3D, 1);
  gameTrack = new Track(0, 0, 0);
  playerKart = new Kart(KART_STARTING_POSITION_X, KART_STARTING_POSITION_Y, KART_STARTING_POSITION_Z);
  gameTimer = new Timer();
  gameTimer.initializeTimers();
  CAMERA_HEIGHT = height * CAMERA_HEIGHT_RATIO;
  CAMERA_DISTANCE = width * CAMERA_DISTANCE_RATIO;
}

void draw() { 
  background(BACKGROUND_COLOUR);
  lights();
  gameTrack.displayTrack();
  setupCamera();
  playerInput();
  playerKart.display();
  playerKart.update();
  gameTrack.checkWallCollision(playerKart);
  gameTimer.checkFinishLine(playerKart);
  gameTimer.displayTimers();
}
