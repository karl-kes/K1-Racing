/*
  * K1 Racing
*/

// Game mode selection
int gameMode = 0; // 0 = selection screen, 1 = casual (single player), 2 = VS mode (split screen)
boolean modeSelected = false;

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
boolean keyUp, keyDown, keyRight, keyLeft, keyV;
boolean arrowUp, arrowDown, arrowRight, arrowLeft, keySlash;

void updateKey(int keyCodeValue, char keyValue, boolean pressed) {
  // Player 1 controls (WASD + V for casual, or Arrow keys + / for casual alternative)
  if (gameMode == 1) {
    // In casual mode, accept both WASD and Arrow keys
    if (keyValue == 'w' || keyValue == 'W' || keyCodeValue == UP) {
      keyUp = pressed;
      arrowUp = pressed;
    }
    if (keyValue == 's' || keyValue == 'S' || keyCodeValue == DOWN) {
      keyDown = pressed;
      arrowDown = pressed;
    }
    if (keyValue == 'a' || keyValue == 'A' || keyCodeValue == LEFT) {
      keyLeft = pressed;
      arrowLeft = pressed;
    }
    if (keyValue == 'd' || keyValue == 'D' || keyCodeValue == RIGHT) {
      keyRight = pressed;
      arrowRight = pressed;
    }
    if (keyValue == 'v' || keyValue == 'V' || keyValue == '/') {
      keyV = pressed;
      keySlash = pressed;
    }
  } else if (gameMode == 2) {
    // VS Mode - separate controls with independent tracking
    // Player 1 controls (WASD + V)
    if (keyValue == 'w' || keyValue == 'W') keyUp = pressed;
    if (keyValue == 's' || keyValue == 'S') keyDown = pressed;
    if (keyValue == 'a' || keyValue == 'A') keyLeft = pressed;
    if (keyValue == 'd' || keyValue == 'D') keyRight = pressed;
    if (keyValue == 'v' || keyValue == 'V') keyV = pressed;
    
    // Player 2 controls (Arrow keys + /)
    // Use keyCodeValue to avoid conflicts
    if (keyCodeValue == UP) arrowUp = pressed;
    if (keyCodeValue == DOWN) arrowDown = pressed;
    if (keyCodeValue == LEFT) arrowLeft = pressed;
    if (keyCodeValue == RIGHT) arrowRight = pressed;
    if (keyValue == '/') keySlash = pressed;
  }
}

void keyPressed() {
  if (gameMode == 0) {
    // Mode selection
    if (key == '1') {
      gameMode = 1; // Casual mode
      modeSelected = true;
      initializeGame();
    } else if (key == '2') {
      gameMode = 2; // VS mode
      modeSelected = true;
      initializeGame();
    }
  } else {
    updateKey(keyCode, key, true);
  }
}

void keyReleased() {
  if (gameMode != 0) {
    updateKey(keyCode, key, false);
    
    if (key == ' ' && !gameTimer.gameStarted) {
      gameTimer.gameStarted = true;
      gameTimer.startGame();
    }
    
    if (key == 'r' || key == 'R') {
      resetGame();
      gameTimer.initializeTimers();
    }
    
    if (key == 'm' || key == 'M') {
      // Return to menu
      gameMode = 0;
      modeSelected = false;
      gameTimer.gameStarted = false;
    }
  }
}

Track gameTrack;
Timer gameTimer;
Kart player1Kart;
Kart player2Kart;

void initializeGame() {
  // Create appropriate graphics buffers based on mode
  if (gameMode == 1) {
    // Casual mode - full screen
    player1View = createGraphics(width, height, P3D);
  } else if (gameMode == 2) {
    // VS mode - split screen
    player1View = createGraphics(width/2, height, P3D);
    player2View = createGraphics(width/2, height, P3D);
  }
  
  gameTrack = new Track(0, 0, 0);
  player1Kart = new Kart(KART_STARTING_POSITION_X, KART_STARTING_POSITION_Y, KART_STARTING_POSITION_Z - (gameMode == 2 ? STARTING_OFFSET_Z : 0));
  if (gameMode == 2) {
    player2Kart = new Kart(KART_STARTING_POSITION_X, KART_STARTING_POSITION_Y, KART_STARTING_POSITION_Z + STARTING_OFFSET_Z);
  }
  gameTimer = new Timer();
  gameTimer.initializeTimers();
}

void resetGame() {
  if (gameMode == 1) {
    player1Kart.position.set(KART_STARTING_POSITION_X, KART_STARTING_POSITION_Y, KART_STARTING_POSITION_Z);
  } else {
    player1Kart.position.set(KART_STARTING_POSITION_X, KART_STARTING_POSITION_Y, KART_STARTING_POSITION_Z - STARTING_OFFSET_Z);
  }
  player1Kart.velocity.set(0, 0, 0);
  player1Kart.speed = 0;
  player1Kart.rotation = KART_STARTING_DIRECTION;
  
  if (gameMode == 2 && player2Kart != null) {
    player2Kart.position.set(KART_STARTING_POSITION_X, KART_STARTING_POSITION_Y, KART_STARTING_POSITION_Z + STARTING_OFFSET_Z);
    player2Kart.velocity.set(0, 0, 0);
    player2Kart.speed = 0;
    player2Kart.rotation = KART_STARTING_DIRECTION;
  }
}

void setup() {
  size(1720, 1000, P3D);
  CAMERA_HEIGHT = height * CAMERA_HEIGHT_RATIO;
  CAMERA_DISTANCE = width * CAMERA_DISTANCE_RATIO;
}

void drawModeSelection() {
  background(0x2F2F2F);
  
  // Title
  fill(0xFFFFFFFF);
  textAlign(CENTER);
  textSize(80);
  text("K1 RACING", width/2, height/4);
  
  // Mode selection boxes
  float boxWidth = 400;
  float boxHeight = 200;
  float boxY = height/2;
  float spacing = 100;
  
  // Casual Mode Box
  float casual_x = width/2 - boxWidth/2 - spacing;
  pushMatrix();
  translate(casual_x, boxY, 0);
  
  // Hover effect
  if (mouseX > casual_x - boxWidth/2 && mouseX < casual_x + boxWidth/2 &&
      mouseY > boxY - boxHeight/2 && mouseY < boxY + boxHeight/2) {
    fill(0xFF3A3A3A);
    stroke(0xFFFF0000);
  } else {
    fill(0xFF2A2A2A);
    stroke(0xFF888888);
  }
  
  strokeWeight(3);
  rectMode(CENTER);
  rect(0, 0, boxWidth, boxHeight, 10);
  
  // Text for Casual Mode
  fill(0xFFFF0000);
  textSize(40);
  text("CASUAL", 0, -20);
  fill(0xFFCCCCCC);
  textSize(20);
  text("Single Player", 0, 20);
  text("Full Screen", 0, 45);
  text("Press 1", 0, 75);
  popMatrix();
  
  // VS Mode Box
  float vs_x = width/2 + boxWidth/2 + spacing;
  pushMatrix();
  translate(vs_x, boxY, 0);
  
  // Hover effect
  if (mouseX > vs_x - boxWidth/2 && mouseX < vs_x + boxWidth/2 &&
      mouseY > boxY - boxHeight/2 && mouseY < boxY + boxHeight/2) {
    fill(0xFF3A3A3A);
    stroke(0xFF0000FF);
  } else {
    fill(0xFF2A2A2A);
    stroke(0xFF888888);
  }
  
  strokeWeight(3);
  rect(0, 0, boxWidth, boxHeight, 10);
  
  // Text for VS Mode
  fill(0xFF0000FF);
  textSize(40);
  text("VS MODE", 0, -20);
  fill(0xFFCCCCCC);
  textSize(20);
  text("Two Players", 0, 20);
  text("Split Screen", 0, 45);
  text("Press 2", 0, 75);
  popMatrix();
  
  // Instructions
  fill(0xFFAAAAAA);
  textSize(18);
  textAlign(CENTER);
  text("Choose your game mode", width/2, height - 150);
  
  // Controls hint
  textSize(16);
  text("Casual: WASD/Arrows + V or / to drift", width/2, height - 80);
  text("VS Mode: P1: WASD + V to drift | P2: Arrows + / to drift", width/2, height - 50);
}

void draw() {
  if (gameMode == 0) {
    // Show mode selection screen
    drawModeSelection();
  } else if (gameMode == 1) {
    // Casual mode - single player, full screen
    player1Kart.playerInput(1);
    player1Kart.update();
    
    gameTrack.checkWallCollision(player1Kart);
    gameTimer.checkFinishLine(player1Kart, 1);
    
    // Full screen view
    player1View.beginDraw();
    player1View.background(BACKGROUND_COLOUR);
    player1View.lights();
    setupCameraFor(player1View, player1Kart);
    
    gameTrack.displayTrack(player1View);
    player1Kart.display(player1View, Kart.KART_BODY_COLOUR);
    
    player1View.endDraw();
    
    // Draw full screen
    image(player1View, 0, 0);
    
    // Draw UI
    gameTimer.displayTimersCasual();
    
  } else if (gameMode == 2) {
    // VS mode - split screen
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
}
