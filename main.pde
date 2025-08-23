/*
  * K1 Racing
*/

// Split screen buffers
PGraphics player1View;
PGraphics player2View;

// Kart starting positions
static final float KART_STARTING_POSITION_X = 0f;
static final float KART_STARTING_POSITION_Y = 0f;
static final float KART_STARTING_POSITION_Z = (Track.OUTER_HEIGHT + Track.INNER_HEIGHT) / 4;
static final float KART_STARTING_DIRECTION = -PI/2;
static final float STARTING_OFFSET_Z = -0.02 * Track.OUTER_WIDTH;

// Camera
static final int BACKGROUND_COLOUR = 0xFFC3EEFA;
static final float CAMERA_HEIGHT_RATIO = 0.0868f;
static final float CAMERA_DISTANCE_RATIO = 0.117f;
private float CAMERA_HEIGHT;
private float CAMERA_DISTANCE;

void setupCameraFor(PGraphics buffer, Kart kart) {
  buffer.camera(
    (kart.position.x - (CAMERA_DISTANCE * sin(kart.rotation))),   // x position of camera.
    (kart.position.y - CAMERA_HEIGHT),                            // y position of camera.
    (kart.position.z - (CAMERA_DISTANCE * cos(kart.rotation))),   // z position of camera.
    (kart.position.x),                                            // x position camera looks at.
    (kart.position.y),                                            // y position camera looks at.
    (kart.position.z),                                            // z position camera looks at.
    0, 1, 0);
}

// Input handling for both players
boolean keyUp, keyDown, keyRight, keyLeft, keySpace;
boolean arrowUp, arrowDown, arrowRight, arrowLeft, keyShift;

void updateKey(boolean pressed) {
  // Player 1 controls (WASD + Space)
  if (key == 'w' || key == 'W') keyUp = pressed;
  if (key == 's' || key == 'S') keyDown = pressed;
  if (key == 'a' || key == 'A') keyLeft = pressed;
  if (key == 'd' || key == 'D') keyRight = pressed;
  if (key == ' ') keySpace = pressed;
  
  // Player 2 controls (Arrow keys + Shift)
  if (keyCode == UP) arrowUp = pressed;
  if (keyCode == DOWN) arrowDown = pressed;
  if (keyCode == LEFT) arrowLeft = pressed;
  if (keyCode == RIGHT) arrowRight = pressed;
  if (keyCode == SHIFT) keyShift = pressed;
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

Track gameTrack;
Timer gameTimer;
Kart player1Kart;
Kart player2Kart;

void resetGame() {
  player1Kart.position.set(KART_STARTING_POSITION_X, KART_STARTING_POSITION_Y, KART_STARTING_POSITION_Z - STARTING_OFFSET_Z);
  player1Kart.velocity.set(0, 0, 0);
  player1Kart.speed = 0;
  player1Kart.rotation = KART_STARTING_DIRECTION;
  
  player2Kart.position.set(KART_STARTING_POSITION_X, KART_STARTING_POSITION_Y, KART_STARTING_POSITION_Z + STARTING_OFFSET_Z);
  player2Kart.velocity.set(0, 0, 0);
  player2Kart.speed = 0;
  player2Kart.rotation = KART_STARTING_DIRECTION;
}

void setup() {
  fullScreen(P3D, 1);
  CAMERA_HEIGHT = height * CAMERA_HEIGHT_RATIO;
  CAMERA_DISTANCE = width * CAMERA_DISTANCE_RATIO;
  
  // Create split screen buffers
  player1View = createGraphics(width/2, height, P3D);
  player2View = createGraphics(width/2, height, P3D);
  
  gameTrack = new Track(0, 0, 0);
  player1Kart = new Kart(KART_STARTING_POSITION_X, KART_STARTING_POSITION_Y, KART_STARTING_POSITION_Z - STARTING_OFFSET_Z);
  player2Kart = new Kart(KART_STARTING_POSITION_X, KART_STARTING_POSITION_Y, KART_STARTING_POSITION_Z + STARTING_OFFSET_Z);
  gameTimer = new Timer();
  gameTimer.initializeTimers();
}

void draw() { 
  // Update both karts
  player1Kart.playerInput(1);
  player1Kart.update();
  player2Kart.playerInput(2);
  player2Kart.update();
  
  gameTrack.checkWallCollision(player1Kart);
  gameTrack.checkWallCollision(player2Kart);
  gameTimer.checkFinishLine(player1Kart, 1);
  gameTimer.checkFinishLine(player2Kart, 2);
  
  // Player 1 view
  player1View.beginDraw();
  player1View.background(BACKGROUND_COLOUR);
  player1View.lights();
  setupCameraFor(player1View, player1Kart);
  
  gameTrack.displayTrack(player1View);
  player1Kart.display(player1View, Kart.KART_BODY_COLOUR);
  player2Kart.display(player1View, Kart.KART_BODY_COLOUR_P2);
  
  player1View.endDraw();
  
  // Player 2 view
  player2View.beginDraw();
  player2View.background(BACKGROUND_COLOUR);
  player2View.lights();
  setupCameraFor(player2View, player2Kart);
  
  gameTrack.displayTrack(player2View);
  player1Kart.display(player2View, Kart.KART_BODY_COLOUR);
  player2Kart.display(player2View, Kart.KART_BODY_COLOUR_P2);
  
  player2View.endDraw();
  
  // Draw both player views to screen
  image(player1View, 0, 0);        // Left half
  image(player2View, width/2, 0);   // Right half
  
  // Draw UI on top
  gameTimer.displayTimers();
}
