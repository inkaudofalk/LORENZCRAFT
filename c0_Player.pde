public static class pConst {
  public static final float defaultHeadHeight = 1.5;
  public static final float sneakHeadHeight = 1.2;
  public static final float walkSpeed = 4.317;
  public static final float sprintSpeed = 5.612;
  public static final float sneakSpeed = 1.31;
  public static final float gravity = -30;
  public static final float terminalVelocity = -89.5;
  public static final float defaultJumpForce = 9.5;
  
  public static final float offsetToGroundBlock= 0.501;
  
  public static final float reach = 4.5;
  
  public static final float radius = .1;
  
  //effect
  public static final float smoothMotionAmount = 52;
  public static final float headInWaterCheckOffset = .18;
  
  //ui hilfsvariablen
  public static final float slotSizeX = 60;
  public static final float slotSizeY = 66;  
  public static final float nunit = .7f;
  public static final float noff = -slotSizeX/2+10;
  public static final float n2 = 27f*nunit;
  public static final float n3 = 34f*nunit+pConst.n2;
  public static final float n1 = 13.5*nunit;
}




class Player {
  
  final float hotbarY = halfheight-50;
  //---
  
  boolean showDetails = false;
  boolean debug = false;
  
  byte[][] inventory = {
    {0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0},
    {0,0,0,0,0,0,0,0,0},
    {1,2,3,4,5,6,7,12,10},
  };
  byte activeSlot = 0;
  
    
  
  
  float headHeight, appliedJumpForce, appliedMoveSpeed;
  boolean sneaking, sprinting;
  
  float smoothHeadY;
  
  
  PVector position, headPosition, velocity, center, vInput, chunkPos;
  intVector myChunk;  
  float rotationAngle, elevationAngle;
  
  boolean[] input; // w87 s83 a65 d68 space32 strg17 shift16
  
  boolean grounded = true;
  float floorY;
  int floorX;
  int floorZ;
  
  boolean underWater = false;
  boolean inWater = false;

  
  Player(PVector startPosition) {
    position = startPosition;
    smoothHeadY = position.y;
    headPosition = new PVector();
    velocity = new PVector();
    center = new PVector();
    vInput = new PVector();
    input = new boolean[5];
    //
    setSneaking(false);
    appliedJumpForce = pConst.defaultJumpForce;
  }
  
  void setSneaking(boolean state) {
    sneaking = state;
    headHeight = state? pConst.sneakHeadHeight:pConst.defaultHeadHeight;
    appliedMoveSpeed = state? pConst.sneakSpeed:pConst.walkSpeed;
    if(sprinting) setSprinting(true);
  }
  
  void setSprinting(boolean state) {
    sprinting = state;
    headHeight = pConst.defaultHeadHeight;
    appliedMoveSpeed = state? pConst.sprintSpeed:pConst.walkSpeed;
    //if(state) perspective(PI/3.0 *1.1, float(width)/float(height) *1.1, .01, ((height/2.0)/tan(PI*60.0/360.0))*10.0);
    //else perspective(PI/3.0, float(width)/float(height), .01, ((height/2.0)/tan(PI*60.0/360.0))*10.0);
    if(sneaking) setSneaking(true);
  }
  
  void Update() {
    applyInput();
    updatePosition();
    //
    Ray ray = rayCast(headPosition, PVector.add(center, headPosition), pConst.reach);
    if(ray.hit) {
      if(debug) {
        lights();
        pushMatrix();
        translate(ray.position.x,ray.position.y,ray.position.z);
        sphere(.05);
        popMatrix();
        
        pushMatrix();
        translate(ray.intPosition.x,ray.intPosition.y,ray.intPosition.z);
        translate((float)cWorld.sideOffset[ray.side].x * .5f, (float)cWorld.sideOffset[ray.side].y * .5f, (float)cWorld.sideOffset[ray.side].z * .5f);
        box(.5);
        popMatrix();
        noLights();
      }
      stroke(#000000);
      noFill();
      pushMatrix();
      translate(ray.intPosition.x,ray.intPosition.y,ray.intPosition.z);
      box(1);
      popMatrix();
      noStroke();
    }
    //
    updateCamera();
  }
  
  void OnMouse(int context) {   
    if(context == Settings.keyBinds[7]) {
      changeBlock(block.AIR);
    }
    else if(context == Settings.keyBinds[8]) { //right
      changeBlock(inventory[3][activeSlot]);
    }
  }
  
  void OnMouseWheel(int context) {
    activeSlot += context;
    if(activeSlot >8) activeSlot -= 9;
    if(activeSlot <0) activeSlot += 9;
  }
  
  void OnButton(int context, boolean state) {
    for(int i=0; i<input.length; i++) {
      if(context == Settings.keyBinds[i]) {
        input[i] = state;
        updateInputInteraction();
        return;
      }
    }
    if(context == Settings.keyBinds[5]) setSneaking(state);
    else if(context == Settings.keyBinds[6]) setSprinting(state);
    else if(context == Settings.keyBinds[10] && state)  showDetails = !showDetails;
  }
  
  void changeBlock(byte type) {
    Ray ray = rayCast(headPosition, PVector.add(center, headPosition), pConst.reach);
    if(!ray.hit) return;
    
    if(type == block.AIR) {
      if(ray.type == block.BEDROCK) return;  
      chunks[ray.chunk.x][ray.chunk.z].blocks[ray.index.x][ray.index.y][ray.index.z] = type;
    }
    else {
      if(ray.side == 0) return; // if in block
      //update target pos
      ray.intPosition.add(cWorld.sideOffset[ray.side]);
      ray.onUpdateIntPos();
      
      if(
        ray.type != block.AIR
        || round(position.x) == ray.intPosition.x && round(position.z) == ray.intPosition.z && (int(position.y+.5f) == ray.intPosition.y || int(position.y+headHeight) == ray.intPosition.y)
      ) return;    
      chunks[ray.chunk.x][ray.chunk.z].blocks[ray.index.x][ray.index.y][ray.index.z] = type;
    }
    
    //updateMesh
    chunks[ray.chunk.x][ray.chunk.z].generateMesh();
    if(ray.index.x == 0) chunks[ray.chunk.x-1][ray.chunk.z].generateMesh();
    else if(ray.index.x == 15) chunks[ray.chunk.x+1][ray.chunk.z].generateMesh();   
    if(ray.index.z == 0) chunks[ray.chunk.x][ray.chunk.z-1].generateMesh();
    else if(ray.index.z == 15) chunks[ray.chunk.x][ray.chunk.z+1].generateMesh();
  }
  
  void updateInputInteraction() {
    vInput.set(int(input[2])-int(input[3]), 0, int(input[0])-int(input[1])).normalize();
    updatePosition();
  }
  
  void applyInput() {
    rotationAngle = map(virtualMouse.x, 0, width, 0, -TWO_PI);
    elevationAngle = map(virtualMouse.y, 0, height, 0.001, PI);
    
    velocity.x += appliedMoveSpeed*vInput.z*cos(rotationAngle) + appliedMoveSpeed*vInput.x*sin(-rotationAngle);
    velocity.z += appliedMoveSpeed*vInput.z*sin(rotationAngle) + appliedMoveSpeed*vInput.x*cos(-rotationAngle);    
    
    if(input[4] == true && (grounded||inWater)) {
      if(!inWater) grounded = false;
      velocity.y += inWater&&velocity.y>=-4.5? appliedJumpForce*.001:appliedJumpForce;
    }
  }
  
  void updatePosition() {
    //if vel == 0 return
    
    //add gravity
    float multiplier = inWater? .3:1;
    if(velocity.y > pConst.terminalVelocity) velocity.y += pConst.gravity*multiplier * deltaTime;
    
    //get new position (without accounting for collision)
    PVector newPosition = PVector.add(position, PVector.mult(velocity,deltaTime));  
    
    //get floor
    myChunk = getChunk(position.x, position.z);
    chunkPos = chunkify(position.x, position.y, position.z);
    floorY = chunks[myChunk.x][myChunk.z].getFloor(chunkPos.x,chunkPos.y,chunkPos.z)+pConst.offsetToGroundBlock;
    
    //floor collision
    if(newPosition.y < floorY)  { newPosition.y = floorY; velocity.y = 0;}
    
    //ceiling collision
    headPosition.set(position.x,position.y+headHeight,position.z);
    if(headPosition.y > floorY+1.95 
       && chunks[myChunk.x][myChunk.z].blocks[round(chunkPos.x)][round(chunkPos.y)+2][round(chunkPos.z)] > block.lastLiquid
       )  { velocity.y = 0; newPosition.y = position.y+(floorY+1.95-headPosition.y); }
    
    //is underwater?----------------------------
    if(chunks[myChunk.x][myChunk.z].blocks[round(chunkPos.x)][round(chunkPos.y+headHeight-pConst.headInWaterCheckOffset)][round(chunkPos.z)] == block.WATER) { underWater = true; inWater = true; }
    else { underWater = false; inWater = false;}
    if(chunks[myChunk.x][myChunk.z].blocks[round(chunkPos.x)][round(chunkPos.y+.5)][round(chunkPos.z)] == block.WATER) { inWater = true; }
    else inWater = false;
    
    //x z collision-------------------------------------------------------------------------
    intVector currentCell = new intVector(round(position.x),round(position.z));
    intVector targetCell = new intVector(round(newPosition.x),round(newPosition.z));
    
    intVector areaTL = currentCell.minV2d(targetCell);
    intVector areaBR = currentCell.maxV2d(targetCell);
    
    //test Area
    for(int x = areaTL.x-1; x<= areaBR.x+1; x++) {
      for(int y = areaTL.y-1; y<= areaBR.y+1; y++) {
        intVector checkChunk = getChunk(x,y);
        intVector cChechPos = new intVector(chunkify(x,0,y));
        
        if(chunks[checkChunk.x][checkChunk.z].blocks[cChechPos.x][round(newPosition.y+0.5)][cChechPos.z] > block.lastLiquid
        || chunks[checkChunk.x][checkChunk.z].blocks[cChechPos.x][round(newPosition.y+headHeight)][cChechPos.z] > block.lastLiquid
          ) {
          PVector nearestPoint = new PVector(constrain(newPosition.x,x-.5,x+.5),newPosition.y,constrain(newPosition.z,y-.5,y+.5));
          
          PVector difference = PVector.sub(nearestPoint, newPosition);
          float overlap = pConst.radius - difference.mag();
          
          if(overlap > 0) newPosition.sub(difference.normalize().mult(overlap));
          
        }
      }
    }
    
    
    //reset x z velocity
    velocity.x = 0;
    velocity.z = 0;
    
    //apply new position
    position = newPosition;
    
    //is grounded
    grounded = position.y == floorY;
  }
  
  void updateCamera() {
    center.set(
      cos(rotationAngle) * sin(elevationAngle), 
      cos(elevationAngle), 
      sin(rotationAngle) * sin(elevationAngle)
    );
    smoothHeadY = lerp(smoothHeadY, headPosition.y, pConst.smoothMotionAmount*deltaTime);
    
    camera(headPosition.x,smoothHeadY,headPosition.z,
           headPosition.x+center.x,smoothHeadY+center.y,headPosition.z+center.z, 
           0,-1,0
           );
  }
  
  void drawUI() {
    fill(255);
    if(showDetails) {
      pushMatrix();
      translate(headPosition.x+center.x*2, headPosition.y+center.y*2, headPosition.z+center.z*2);
      //rotate horizontal
      rotateY(-rotationAngle+ PI/2);
      //rotate vertical
      rotateX(elevationAngle+PI/2);
      rect(0,0,.03,.03);
      popMatrix();
    }
      
    beginHUD();
    if(underWater) image(uiImage[6],0,0, width,height);
    if(showDetails) {
      text("FPS "+frameRate +" *"+timeScale,10-halfwidth,20-halfheight);
      text("position "+position,10-halfwidth,50-halfheight);
      text("chunkPos "+chunkPos,10-halfwidth,80-halfheight);;
      text("chunk "+myChunk.x+" "+myChunk.z,10-halfwidth,110-halfheight);
      //text("r "+rotationAngle/PI,-.1,-.041);
      //text("pOff "+pOffset,-.1,-.038);
      text("v  "+velocity,10-halfwidth,140-halfheight);
    }
    rect(0,0,5,5);
    
    image(uiImage[0],0,hotbarY,pConst.slotSizeY*9,pConst.slotSizeY);
    
    image(uiImage[1],(activeSlot-4)*pConst.slotSizeX,hotbarY,pConst.slotSizeY,pConst.slotSizeY);
    
    pushMatrix();
    translate(0,pConst.noff);
    beginShape(QUADS);
    for(int i=-4; i<=4; i++) {
      byte type = inventory[3][i+4];
      int baseU = (type-1)*textureSize+type*2-1;
      int baseV = 1;
      int increment = textureSize+2;
      //text(inventory[3][i+4],slotSize*i-10, hotbarY);
      //top
      texture(atlas);
      vertex(pConst.slotSizeX*i,hotbarY,  baseU+textureSize,baseV);
      vertex(pConst.slotSizeX*i+pConst.n2,hotbarY+pConst.n1,  baseU+textureSize,baseV+textureSize);
      vertex(pConst.slotSizeX*i,hotbarY+pConst.n2,  baseU,baseV+textureSize);
      vertex(pConst.slotSizeX*i-pConst.n2,hotbarY+pConst.n1,  baseU,baseV);
      //left
      vertex(pConst.slotSizeX*i-pConst.n2,hotbarY+pConst.n1,  baseU+textureSize,baseV+textureSize+increment*2);
      vertex(pConst.slotSizeX*i,hotbarY+pConst.n2,  baseU,baseV+textureSize+increment*2);
      vertex(pConst.slotSizeX*i,hotbarY+pConst.n3,  baseU,baseV+increment*2);
      vertex(pConst.slotSizeX*i-pConst.n2,hotbarY+pConst.n3-pConst.n1,  baseU+textureSize,baseV+increment*2);
      //right
      vertex(pConst.slotSizeX*i+pConst.n2,hotbarY+pConst.n1,  baseU,baseV+textureSize+increment*2);
      vertex(pConst.slotSizeX*i,hotbarY+pConst.n2,  baseU+textureSize,baseV+textureSize+increment*2);
      vertex(pConst.slotSizeX*i,hotbarY+pConst.n3,  baseU+textureSize,baseV+increment*2);
      vertex(pConst.slotSizeX*i+pConst.n2,hotbarY+pConst.n3-pConst.n1,  baseU,baseV+increment*2);
    }
    endShape();
    popMatrix();
    endHUD();
  }
}
