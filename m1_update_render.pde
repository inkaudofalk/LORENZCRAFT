float timeScale = 1f;
float deltaTime = 1f;

GLWindow r;
int offsetX=0;
int offsetY=0;    
boolean Active = true;

PVector virtualMouse;
//PVector smoothVirtualMouse;
//float mouseSmoothingFaktor = 0.0001;
//float mouseSmoothing;

//draw--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
void draw() {
  deltaTime = timeScale/frameRate;
  
  virtualMouse.x+=(mouseX-offsetX-halfwidth)*Settings.Sensitivity.x*timeScale; 
  virtualMouse.y= clamp(virtualMouse.y+(mouseY-offsetY-halfheight)*Settings.Sensitivity.y*timeScale, 0, height-1);
  
  //mouseSmoothing = frameRate*mouseSmoothingFaktor;
  //smoothVirtualMouse.set(lerp(virtualMouse.x,virtualMouse.x,mouseSmoothing), lerp(virtualMouse.y,virtualMouse.y, mouseSmoothing));
  
  PGL pgl = beginPGL();
  pgl.enable(PGL.CULL_FACE);
  background(cWorld.skyColor);
  //pointLight(255,255,255,player.position.x,player.position.y+1,player.position.z);
  displayChunks();
  player.Update();
  pushMatrix();
  translate(player.position.x+1000,player.position.y+1000,player.position.z+1000);
  fill(255,255,200);
  box(130);
  popMatrix();
  endPGL();
  player.drawUI();
  
  if(Active) {
    r.warpPointer(halfwidth,halfheight);
    if(!focused) pause(true);
  }
  else pauseMenu_draw();
}

//displayChunks--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
void displayChunks() {
  for(int i=0; i<chunks.length; i++)
  for(int j=0; j<chunks[i].length; j++) {
    chunks[i][j].render();
  }
  
  for(int i=0; i<chunks.length; i++)
  for(int j=0; j<chunks[i].length; j++) {
    chunks[i][j].render2();
  }
}
