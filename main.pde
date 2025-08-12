/*
  * K1 Racing
*/

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
