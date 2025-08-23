class Track {  
  // Dimensions
  static final float OUTER_WIDTH = 7500f;
  static final float OUTER_HEIGHT = OUTER_WIDTH/2;
  static final float TRACK_WIDTH = 1500f;
  static final float INNER_WIDTH = OUTER_WIDTH - TRACK_WIDTH;
  static final float INNER_HEIGHT = OUTER_HEIGHT - TRACK_WIDTH;
  static final float SIZE_OF_GROUND = 4*OUTER_WIDTH/3;
  static final int SQUARE_SIZE = 50;
  static final float NUMBER_OF_SQUARES = ((OUTER_HEIGHT - INNER_HEIGHT) / (2*SQUARE_SIZE));
  static final float BARRIER_HEIGHT = 35f;
  static final float BARRIER_THICKNESS = 6*BARRIER_HEIGHT/7;
  static final float TIRE_BOUNDARY_LENGTH = 5*BARRIER_HEIGHT/7;
  static final float TIRE_BOUNDARY_HEIGHT = 3*BARRIER_HEIGHT/7;
  static final float BLEACHER_HEIGHT = 35f;
  static final float BLEACHER_ROWS = 2*BLEACHER_HEIGHT/7;
  static final float BLEACHER_DEPTH = 13*BLEACHER_HEIGHT/7;
  static final float BLEACHER_THICKNESS = 11*BLEACHER_HEIGHT/7;
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
  static final float STADIUM_RADIUS = OUTER_WIDTH/2 + 500;
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
  
  private void drawOuterTrack(PGraphics pg) {
    pg.pushMatrix();
    offsetY = 3f;
    pg.translate(ORIGIN_X, TRACK_Y + offsetY, ORIGIN_Z);
    pg.rotateX(PI/2);
    pg.strokeWeight(TRACK_STROKE_WEIGHT);
    pg.stroke(BOUNDARY_COLOUR);
    pg.fill(TRACK_COLOUR);
    pg.ellipse(ORIGIN_X, ORIGIN_Z, OUTER_WIDTH, OUTER_HEIGHT);
  }
  
  private void drawLaneMarkings(PGraphics pg) {
    pg.stroke(LANE_MARKING_COLOUR);
    pg.ellipse(ORIGIN_X, ORIGIN_Z, (OUTER_WIDTH + INNER_WIDTH) / 2, (OUTER_HEIGHT + INNER_HEIGHT) / 2);
    pg.ellipse(ORIGIN_X, ORIGIN_Z, (3*OUTER_WIDTH + INNER_WIDTH) / 4, (3*OUTER_HEIGHT + INNER_HEIGHT) / 4);
    pg.ellipse(ORIGIN_X, ORIGIN_Z, (OUTER_WIDTH + 3*INNER_WIDTH) / 4, (OUTER_HEIGHT + 3*INNER_HEIGHT) / 4);
    pg.popMatrix();
  }
  
  private void drawInnerTrack(PGraphics pg) {
    pg.pushMatrix();
    pg.translate(ORIGIN_X, TRACK_Y, ORIGIN_Z);
    pg.rotateX(PI/2);
    pg.stroke(BOUNDARY_COLOUR);
    pg.fill(GROUND_COLOUR);
    pg.ellipse(ORIGIN_X, ORIGIN_Z, INNER_WIDTH, INNER_HEIGHT);
    pg.popMatrix(); 
  }
  
  private void drawGround(PGraphics pg) {    
    pg.pushMatrix();
    offsetY = 5f;
    pg.translate(ORIGIN_X, TRACK_Y + offsetY, ORIGIN_Z);
    pg.fill(GROUND_COLOUR);
    pg.noStroke();
    pg.rotateX(PI/2);
    pg.ellipse(ORIGIN_X, ORIGIN_Z, SIZE_OF_GROUND, SIZE_OF_GROUND/2);
    pg.popMatrix(); 
  }
  
  private void drawFinishLine(PGraphics pg) {
    for (int row = 1; row < 3; row++) {
      pg.pushMatrix();
      pg.noLights();
      offsetY = 1f;
      pg.translate(-row*SQUARE_SIZE, TRACK_Y + offsetY, OUTER_HEIGHT/2);
      pg.rotateX(PI/2);
      pg.noStroke();
      
      // Draws the appropriate number of boxes and splits the gaps for alternating black and white.
      for(int i = 1; i <= NUMBER_OF_SQUARES; i++) {
        if ((i + row) % 2 == 0) {
          pg.fill(#FFFFFF);
          pg.rect(0, (-SQUARE_SIZE)*i, SQUARE_SIZE, SQUARE_SIZE);
        } else { 
          pg.fill(#000000);
          pg.rect(0, (-SQUARE_SIZE)*i, SQUARE_SIZE, SQUARE_SIZE);
        }
      }
      
      pg.lights();
      pg.popMatrix();
    }
  }
  
  // Displays the F1 style walls.
  private void drawWalls(PGraphics pg) {
    // Outer barrier; red and white striped like F1
    for (int angleDeg = 0; angleDeg < 360; angleDeg += 5) {
      // Current and next variables.
      float angleRad = radians(angleDeg);
      float x = cos(angleRad) * (OUTER_WIDTH/2 + DISTANCE_FROM_TRACK);
      float z = sin(angleRad) * (OUTER_HEIGHT/2 + DISTANCE_FROM_TRACK);
      float nextAngle = radians(angleDeg + DEG_INCREMENT);
      float nextX = cos(nextAngle) * (OUTER_WIDTH/2 + DISTANCE_FROM_TRACK);
      float nextZ = sin(nextAngle) * (OUTER_HEIGHT/2 + DISTANCE_FROM_TRACK);
      
      pg.pushMatrix(); 
      pg.translate((x + nextX)/2, TRACK_Y - BARRIER_HEIGHT/2, (z + nextZ)/2);
      
      // Alternate red and white sections
      if ((angleDeg / 5) % 2 == 0) {
        pg.fill(BOUNDARY_COLOUR_RED);
      } else {
        pg.fill(BOUNDARY_COLOUR);
      }
      
      pg.noStroke();
      float barrierLength = dist(x, z, nextX, nextZ);
      pg.rotateY(atan2(nextX - x, nextZ - z));
      pg.box(BARRIER_THICKNESS, BARRIER_HEIGHT, barrierLength);
      pg.popMatrix();
    }
    
    // Inner barrier; stacked tires.
    for (int angleDeg = 0; angleDeg < 360; angleDeg += 1) {
      float angleRad = radians(angleDeg);
      float x = cos(angleRad) * (INNER_WIDTH/2 - DISTANCE_FROM_TRACK);
      float z = sin(angleRad) * (INNER_HEIGHT/2 - DISTANCE_FROM_TRACK);
      
      // Simple stacked tire boxes
      for (int i = 0; i < 2; i++) {
        pg.pushMatrix();
        pg.translate(x, TRACK_Y + (i * 15) - 15, z);
        pg.fill(TIRE_COLOUR);
        pg.noStroke();
        pg.box(TIRE_BOUNDARY_LENGTH, TIRE_BOUNDARY_HEIGHT, TIRE_BOUNDARY_LENGTH);
        pg.popMatrix();
      }
    }
  }
  
  // Draws the bleachers.
  private void drawStadium(PGraphics pg) {    
    // Create bleachers in sections around the track - smaller ANGLE increment for continuous connection
    for (int angleDeg = 0; angleDeg < 360; angleDeg += 1) {
      float angleRad = radians(angleDeg);
      
      // Create multiple rows of bleachers
      for (int row = 0; row < BLEACHER_ROWS; row++) {
        pg.pushMatrix();
        
        // Position each row further back and higher up
        float rowOffset = row * BLEACHER_DEPTH * BLEACHER_DEPTH_OFFSET_FACTOR;
        float rowHeight = row * BLEACHER_HEIGHT * BLEACHER_HEIGHT_OFFSET_FACTOR;
        
        // Calculate position for this row
        float rowX = cos(angleRad) * (STADIUM_RADIUS + rowOffset);
        float rowZ = sin(angleRad) * ((STADIUM_RADIUS + rowOffset) * (OUTER_HEIGHT / (float)OUTER_WIDTH));
        
        pg.translate(rowX, TRACK_Y - rowHeight, rowZ);
        
        // Alternate colors for visual interest
        if (row % 2 == 0) {
          pg.fill(BLEACHER_COLOUR_LIGHT);
        } else {
          pg.fill(BLEACHER_COLOUR_DARK);
        }
        
        // Rotate to face the track center
        pg.rotateY(atan2(-rowX, -rowZ));
        
        pg.noStroke();
        // Make boxes wider to ensure complete connection
        pg.box(BLEACHER_THICKNESS, BLEACHER_HEIGHT, BLEACHER_DEPTH);
        pg.popMatrix();
      }
    }
  }
  
  // Displays the track.
  void displayTrack(PGraphics pg) {
    drawOuterTrack(pg);
    drawLaneMarkings(pg);
    drawInnerTrack(pg);
    drawGround(pg);
    drawFinishLine(pg);
    drawWalls(pg);
    drawStadium(pg);
  }
  
  // Checks to see whether or not the kart collides with the track borders.
  void checkWallCollision(Kart kart) {
    // Checks user equation of an ellipse.
    float outerCheck = sq(kart.position.x / (Track.OUTER_WIDTH / 2)) + sq(kart.position.z / (Track.OUTER_HEIGHT / 2));
    float innerCheck = sq(kart.position.x / (Track.INNER_WIDTH / 2)) + sq(kart.position.z / (Track.INNER_HEIGHT / 2));
    
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
