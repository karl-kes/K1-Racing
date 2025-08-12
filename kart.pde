class Kart {
  // Dimensions
  static final float KART_LENGTH = 100f;
  static final float KART_WIDTH = KART_LENGTH / 4;
  static final float KART_HEIGHT = KART_LENGTH / 10;
  static final float SECTION_LENGTH = KART_LENGTH / 5;
  static final float WING_HEIGHT = KART_LENGTH/50;
  static final float WING_LENGTH = KART_LENGTH/25;
  static final float TIRE_WIDTH = 3*KART_LENGTH/20;
  static final float TIRE_HEIGHT = 3*KART_LENGTH/20;
  static final float TIRE_LENGTH = 11*KART_LENGTH/50;
  static final float COCKPIT_WIDTH = KART_LENGTH/10;
  static final float COCKPIT_HEIGHT = 3*KART_LENGTH/50;
  static final float COCKPIT_LENGTH = 3*KART_LENGTH/10;
  
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
  private PVector intendedDirection = new PVector();
  private PVector intendedVelocity = new PVector();
  
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
    intendedDirection.set(sin(rotation), 0, cos(rotation));
    intendedVelocity.set(intendedDirection).mult(speed);
    
    // If not drifting, snap velocity to intended direction (strong grip)
    if (!keySpace) {
      velocity.set(intendedVelocity);
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
      
      if (driftDuration > 2.5) {
        fill(BURNING_TIRE_COLOUR_3);
      } else if (driftDuration > 1.5) {
        fill(BURNING_TIRE_COLOUR_2);
      } else if (driftDuration > 0.5) {
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
  
  void display() {
    drawKartBody();
    drawWings();
    drawTires();
    drawCockPit();
  }
}
