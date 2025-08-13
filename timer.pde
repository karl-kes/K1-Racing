class Timer {
  // Logic
  static final float finishLineRange = 25f;
  boolean gameStarted;
  boolean crossedFinishLine;
  boolean farFromFinishLine;
  int lapCount;
  
  // Timers
  float lapStartTime;
  float currentLapTime;
  float bestLapTime;
  float lastLapTime;
  
  // Visuals
  static final int TEXT_COLOUR_WHITE = 0xFFFFFFFF;
  static final int TEXT_COLOUR_BLACK = 0xFF000000;
  static final int TEXT_SIZE_LARGE = 40;
  static final int TEXT_SIZE_SMALL = 20;
  static final int TEXT_MARGIN = 20;
  static final int TEXT_LINE_HEIGHT = 30;
  static final float CONVERT_TO_KMH = 5.4f;
  
  Timer() {
    gameStarted = false;
    crossedFinishLine = false;
    farFromFinishLine = false;
    lapStartTime = 0;
    currentLapTime = 0;
    bestLapTime = Float.MAX_VALUE;
    lastLapTime = 0;
    lapCount = 0;
  }
  
  void initializeTimers() {
    crossedFinishLine = false;
    farFromFinishLine = false;
    gameStarted = false;
    currentLapTime = 0;
    bestLapTime = Float.MAX_VALUE;
    lastLapTime = 0;
    lapCount = 0;
  }
  
  void startGame() {
    lapStartTime = millis();
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
  
  void checkFinishLine(Kart kart) {
    boolean finishLine = isAtFinishLine(kart);
    boolean awayPoint = isAwayFromFinishLine(kart);
                          
    if (finishLine && !crossedFinishLine) {
      crossedFinishLine = true;
      farFromFinishLine = false;
    }
    
    if (crossedFinishLine && !farFromFinishLine && awayPoint) {
      farFromFinishLine = true;
    }
     
    if (crossedFinishLine && farFromFinishLine && finishLine) {
      float currentTime = millis();
      currentLapTime = (currentTime - lapStartTime) / 1000;
      lapCount++;
      lastLapTime = currentLapTime;
       
      if (currentLapTime < bestLapTime) {
        bestLapTime = currentLapTime;
      }
      
      // Reset for next lap
      lapStartTime = currentTime;
      crossedFinishLine = false;
      farFromFinishLine = false;
    }
  }
  
  void displayTimers() {
    // Save current camera state
    pushMatrix();
   
    // Switch to default 2D camera for text overlay.
    camera();
    hint(DISABLE_DEPTH_TEST);
    noLights();
    
    // Before game stars.
    if(!gameStarted) {
      fill(TEXT_COLOUR_WHITE);
      textAlign(CENTER);
      textSize(TEXT_SIZE_LARGE);
      text("SPACE to START!", width/2, height/4);
      textAlign(RIGHT);
      textSize(TEXT_SIZE_SMALL);
      text("Hint: Hold W/UP before pressing SPACE!", width - TEXT_MARGIN, height - TEXT_LINE_HEIGHT);
    } else { // When game starts; display timers/text.
      fill(TEXT_COLOUR_BLACK);
      textAlign(LEFT);
      textSize(TEXT_SIZE_SMALL);
      
      float ongoingTime = (millis() - lapStartTime) / 1000.0;
      
      text("Speed: " + nf((playerKart.speed * CONVERT_TO_KMH), 1, 2) + " KM/H", TEXT_SIZE_SMALL, TEXT_LINE_HEIGHT);
      text("Current Lap: " + nf(ongoingTime, 1, 2) + "s", TEXT_MARGIN, TEXT_LINE_HEIGHT + TEXT_MARGIN);
      text("Laps: " + lapCount, TEXT_SIZE_SMALL, TEXT_LINE_HEIGHT + 2*TEXT_MARGIN);

      if (lastLapTime > 0) {
        text("Last Lap: " + nf(lastLapTime, 1, 2) + "s", TEXT_MARGIN, TEXT_LINE_HEIGHT + 3*TEXT_MARGIN); 
      }
       
      if (bestLapTime < Float.MAX_VALUE) {
        text("Best Lap: " + nf(bestLapTime, 1, 2) + "s", TEXT_MARGIN, TEXT_LINE_HEIGHT + 4*TEXT_MARGIN);
      }
    }
    
    fill(TEXT_COLOUR_WHITE);
    textAlign(LEFT);
    textSize(TEXT_SIZE_SMALL);
    text("Controls: WASD/Arrow Keys, SPACE to Drift, R to Reset", TEXT_MARGIN, height - TEXT_LINE_HEIGHT);
    lights();
    hint(ENABLE_DEPTH_TEST);
    popMatrix();
  }
}
