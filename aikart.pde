class AIKart extends Kart {
  // Pathfinding
  private ArrayList<PVector> racingLine;
  
  // Racing line
  static final float RACING_LINE_EDGE_FACTOR = 0.2f;
  static final float RACING_LINE_WIDTH = Track.INNER_WIDTH + (Track.OUTER_WIDTH - Track.INNER_WIDTH) * RACING_LINE_EDGE_FACTOR;
  static final float RACING_LINE_HEIGHT = Track.INNER_HEIGHT + (Track.OUTER_HEIGHT - Track.INNER_HEIGHT) * RACING_LINE_EDGE_FACTOR;
  static final int NUM_WAYPOINTS = 32;
  
  // Visuals
  static final int AIKART_BODY_COLOUR = 0xFF00FF00;
  
  AIKart(float x, float y, float z) {
    super(x, y, z);
    initializeRacingLine();
  }
  
  private void initializeRacingLine() { 
    racingLine = new ArrayList<PVector>();
  }
  
  void display() {
    super.display(AIKART_BODY_COLOUR);
  }
}
