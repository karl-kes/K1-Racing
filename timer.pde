class Timer {
  // Logic
  static final float finishLineRange = 25f;
  boolean gameStarted;
  
  // Per-player finish line tracking
  boolean[] crossedFinishLine = new boolean[2];
  boolean[] farFromFinishLine = new boolean[2];
  int[] lapCount = new int[2];
  float[] lapStartTime = new float[2];
  float[] currentLapTime = new float[2];
  float[] bestLapTime = new float[2];
  float[] lastLapTime = new float[2];
  
  // Visuals
  static final int TEXT_COLOUR_WHITE = 0xFFFFFFFF;
  static final int TEXT_COLOUR_BLACK = 0xFF000000;
  static final int TEXT_COLOUR_RED = 0xFFFF0000;
  static final int TEXT_COLOUR_BLUE = 0xFF0000FF;
  static final int TEXT_SIZE_LARGE = 40;
  static final int TEXT_SIZE_MEDIUM = 30;
  static final int TEXT_SIZE_SMALL = 20;
  static final int TEXT_MARGIN = 20;
  static final int TEXT_LINE_HEIGHT = 30;
  static final float CONVERT_TO_KMH = 5.4f;
  
  Timer() {
    gameStarted = false;
    for (int i = 0; i < 2; i++) {
      crossedFinishLine[i] = false;
      farFromFinishLine[i] = false;
      lapStartTime[i] = 0;
      currentLapTime[i] = 0;
      bestLapTime[i] = Float.MAX_VALUE;
      lastLapTime[i] = 0;
      lapCount[i] = 0;
    }
  }
  
  void initializeTimers() {
    gameStarted = false;
    for (int i = 0; i < 2; i++) {
      crossedFinishLine[i] = false;
      farFromFinishLine[i] = false;
      currentLapTime[i] = 0;
      bestLapTime[i] = Float.MAX_VALUE;
      lastLapTime[i] = 0;
      lapCount[i] = 0;
    }
  }
  
  void startGame() {
    float startTime = millis();
    for (int i = 0; i < 2; i++) {
      lapStartTime[i] = startTime;
    }
    gameStarted = true;
  }
  
  private boolean isAtFinishLine(Kart kart) {
    return (kart.position.x >= -Track.SQUARE_SIZE - finishLineRange &&
            kart.position.x <= -Track.SQUARE_SIZE + finishLineRange &&
            kart.position.z >= Track.INNER_HEIGHT/2 &&
            kart.position.z <= Track.OUTER_HEIGHT/2);
  }
  
  private boolean isAwayFromFinishLine(Kart kart) {
    return (kart.position.x >= -Track.SQUARE_SIZE - finishLineRange && 
            kart.position.x <= -Track.SQUARE_SIZE + finishLineRange && 
            kart.position.z >= -Track.OUTER_HEIGHT/2 && 
            kart.position.z <= -Track.INNER_HEIGHT/2);
  }
  
  void checkFinishLine(Kart kart, int playerNum) {
    int playerIndex = playerNum - 1;
    boolean finishLine = isAtFinishLine(kart);
    boolean awayPoint = isAwayFromFinishLine(kart);
                          
    if (finishLine && !crossedFinishLine[playerIndex]) {
      crossedFinishLine[playerIndex] = true;
      farFromFinishLine[playerIndex] = false;
    }
    
    if (crossedFinishLine[playerIndex] && !farFromFinishLine[playerIndex] && awayPoint) {
      farFromFinishLine[playerIndex] = true;
    }
     
    if (crossedFinishLine[playerIndex] && farFromFinishLine[playerIndex] && finishLine) {
      float currentTime = millis();
      currentLapTime[playerIndex] = (currentTime - lapStartTime[playerIndex]) / 1000;
      lapCount[playerIndex]++;
      lastLapTime[playerIndex] = currentLapTime[playerIndex];
       
      if (currentLapTime[playerIndex] < bestLapTime[playerIndex]) {
        bestLapTime[playerIndex] = currentLapTime[playerIndex];
      }
      
      // Reset for next lap
      lapStartTime[playerIndex] = currentTime;
      crossedFinishLine[playerIndex] = false;
      farFromFinishLine[playerIndex] = false;
    }
  }
  
  void displayTimers() {
    // Save current camera state
    pushMatrix();
   
    // Switch to default 2D camera for text overlay.
    camera();
    hint(DISABLE_DEPTH_TEST);
    noLights();
    
    // Before game starts.
    if(!gameStarted) {
      fill(TEXT_COLOUR_WHITE);
      textAlign(CENTER);
      textSize(TEXT_SIZE_LARGE);
      text("SPACE to START!", width/2, height/3);
      textSize(TEXT_SIZE_MEDIUM);
      text("Player 1 (Red): WASD + SPACE to drift", width/2, height/2);
      text("Player 2 (Blue): Arrow Keys + SHIFT to drift", width/2, height/2 + TEXT_LINE_HEIGHT + 10);
      textAlign(RIGHT);
      textSize(TEXT_SIZE_SMALL);
      text("R to Reset", width - TEXT_MARGIN, height - TEXT_LINE_HEIGHT);
    } else {
      // Player 1 stats (left side)
      fill(TEXT_COLOUR_WHITE);
      textAlign(LEFT);
      textSize(TEXT_SIZE_SMALL);
      
      float ongoingTime1 = (millis() - lapStartTime[0]) / 1000.0;
      text("P1 - Red Kart", TEXT_MARGIN, TEXT_LINE_HEIGHT);
      text("Speed: " + nf((player1Kart.speed * CONVERT_TO_KMH), 1, 2) + " KM/H", TEXT_MARGIN, TEXT_LINE_HEIGHT * 2);
      text("Current: " + nf(ongoingTime1, 1, 2) + "s", TEXT_MARGIN, TEXT_LINE_HEIGHT * 3);
      text("Laps: " + lapCount[0], TEXT_MARGIN, TEXT_LINE_HEIGHT * 4);

      if (lastLapTime[0] > 0) {
        text("Last: " + nf(lastLapTime[0], 1, 2) + "s", TEXT_MARGIN, TEXT_LINE_HEIGHT * 5); 
      }
       
      if (bestLapTime[0] < Float.MAX_VALUE) {
        text("Best: " + nf(bestLapTime[0], 1, 2) + "s", TEXT_MARGIN, TEXT_LINE_HEIGHT * 6);
      }
      
      // Player 2 stats (right side)
      fill(TEXT_COLOUR_WHITE);
      textAlign(RIGHT);
      
      float ongoingTime2 = (millis() - lapStartTime[1]) / 1000.0;
      text("P2 - Blue Kart", width - TEXT_MARGIN, TEXT_LINE_HEIGHT);
      text("Speed: " + nf((player2Kart.speed * CONVERT_TO_KMH), 1, 2) + " KM/H", width - TEXT_MARGIN, TEXT_LINE_HEIGHT * 2);
      text("Current: " + nf(ongoingTime2, 1, 2) + "s", width - TEXT_MARGIN, TEXT_LINE_HEIGHT * 3);
      text("Laps: " + lapCount[1], width - TEXT_MARGIN, TEXT_LINE_HEIGHT * 4);

      if (lastLapTime[1] > 0) {
        text("Last: " + nf(lastLapTime[1], 1, 2) + "s", width - TEXT_MARGIN, TEXT_LINE_HEIGHT * 5); 
      }
       
      if (bestLapTime[1] < Float.MAX_VALUE) {
        text("Best: " + nf(bestLapTime[1], 1, 2) + "s", width - TEXT_MARGIN, TEXT_LINE_HEIGHT * 6);
      }
      
      // Split line
      fill(TEXT_COLOUR_WHITE);
      stroke(TEXT_COLOUR_WHITE);
      line(width/2, 0, width/2, height);
      noStroke();
    }
    
    lights();
    hint(ENABLE_DEPTH_TEST);
    popMatrix();
  }
}
