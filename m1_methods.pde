intVector getChunk(float x, float z) {
  x+=.5;
  z+=.5;
  return new intVector(floor(x/16),0,floor(z/16));
}

PVector chunkify(float x, float y, float z) {
  
  x = x%16;
  if(x<-.5) x = 16+x;
  else if(x>=15.5) x = -16+x;
  
  z = z%16;
  if(z<-.5) z = 16+z;
  else if(z>=15.5) z = -16+z;
  return(new PVector(x, y, z));
}

public void beginHUD() {
  g.hint(PConstants.DISABLE_DEPTH_TEST);
  g.pushMatrix();
  g.resetMatrix();
  // 3D is always GL (in processing 3), so this check is probably redundant.
  if (g.isGL() && g.is3D()) {
    PGraphicsOpenGL pgl = (PGraphicsOpenGL)g;
    //pushedLights = pgl.lights;
    pgl.lights = false;
    pgl.pushProjection();
    //g.ortho(0, viewport[2], -viewport[3], 0, -Float.MAX_VALUE, +Float.MAX_VALUE);
    g.ortho(-width/2, width/2, -height/2, height/2);
  }
}
/**
 * 
 * end screen-aligned 2D-drawing.
 * 
 */
public void endHUD() {
  if (g.isGL() && g.is3D()) {
    PGraphicsOpenGL pgl = (PGraphicsOpenGL)g;
    pgl.popProjection();
    //pgl.lights = pushedLights;
  }
  g.popMatrix();
  g.hint(PConstants.ENABLE_DEPTH_TEST);
}

public static float clamp(float val, float min, float max) {
    return Math.max(min, Math.min(max, val));
}



Ray rayCast(PVector ostart, PVector oend, float maxDist) {
  intVector chunkToCheck = getChunk(ostart.x, ostart.z);
  PVector cCheckPos = chunkify(ostart.x,ostart.y,ostart.z);
  byte type = chunks[chunkToCheck.x][chunkToCheck.z].blocks[round(cCheckPos.x)][round(cCheckPos.y)][round(cCheckPos.z)];
  if(type != block.AIR) {
    intVector oIntStart = intVector.roundV(ostart);
    return new Ray(ostart,oIntStart, new intVector(chunkify(oIntStart.x,oIntStart.y,oIntStart.z)), chunkToCheck,type,(byte)0);
  }
  
  PVector start = ostart.copy(); 
  PVector end = oend.copy();
  end.x += .5f;
  end.z += .5f;
  end.y += .5f;
  start.x += .5f;
  start.z += .5f;
  start.y += .5f;
  
  PVector dir = PVector.sub(end, start).normalize();
  PVector rayUnitStepSize = new PVector( 
    sqrt(1+(dir.y/dir.x)*(dir.y/dir.x)+(dir.z/dir.x)*(dir.z/dir.x)), 
    sqrt(1+(dir.x/dir.y)*(dir.x/dir.y)+(dir.z/dir.y)*(dir.z/dir.y)), 
    sqrt(1+(dir.y/dir.z)*(dir.y/dir.z)+(dir.x/dir.z)*(dir.x/dir.z))
  );
  
  intVector mapCheck = new intVector(start);
  PVector rayLength1D = new PVector();
  intVector step = new intVector();
  if(dir.x < 0) { 
    step.x = -1;
    rayLength1D.x = (start.x - (float)mapCheck.x) * rayUnitStepSize.x;
  }
  else { 
    step.x = 1; 
    rayLength1D.x = ((float)mapCheck.x +1f - start.x) * rayUnitStepSize.x;
  }
  if(dir.y < 0) { 
    step.y = -1; 
    rayLength1D.y = (start.y - (float)mapCheck.y) * rayUnitStepSize.y;
  }
  else { 
    step.y = 1;
    rayLength1D.y = ((float)mapCheck.y +1f - start.y) * rayUnitStepSize.y;
  }
  if(dir.z < 0) { 
    step.z = -1; 
    rayLength1D.z = (start.z - (float)mapCheck.z) * rayUnitStepSize.z;
  }
  else { 
    step.z = 1;
    rayLength1D.z = ((float)mapCheck.z +1f - start.z) * rayUnitStepSize.z;
  }
  
  boolean hit = false;
  float distance = 0.0f;
  while(!hit && distance<maxDist) {
    if(rayLength1D.x < rayLength1D.y && rayLength1D.x < rayLength1D.z) {
      mapCheck.x += step.x;
      distance = rayLength1D.x;
      rayLength1D.x += rayUnitStepSize.x;
    }
    else if(rayLength1D.y < rayLength1D.x && rayLength1D.y < rayLength1D.z) {
      mapCheck.y += step.y;
      distance = rayLength1D.y;
      rayLength1D.y += rayUnitStepSize.y;
    }
    else {
      mapCheck.z += step.z;
      distance = rayLength1D.z;
      rayLength1D.z += rayUnitStepSize.z;
    }
    
    chunkToCheck = getChunk(mapCheck.x, mapCheck.z);
    cCheckPos = chunkify(mapCheck.x,mapCheck.y,mapCheck.z);
    type = chunks[chunkToCheck.x][chunkToCheck.z].blocks[(int)cCheckPos.x][(int)cCheckPos.y][(int)cCheckPos.z];
    if(chunkToCheck.x>=0 && chunkToCheck.z>=0 && type != block.AIR) hit = true;
  }
  
  if(hit) {
    PVector hitPos = PVector.add(ostart, PVector.mult(dir, distance));
    //get hit side
    byte hitSyde = -1;
    PVector hitOffset = new PVector(hitPos.x-(float)mapCheck.x, hitPos.y-(float)mapCheck.y, hitPos.z-(float)mapCheck.z);
    boolean XgY = Math.abs(hitOffset.x)>Math.abs(hitOffset.y);
    boolean XgZ = Math.abs(hitOffset.x)>Math.abs(hitOffset.z);
    boolean ZgY = Math.abs(hitOffset.z)>Math.abs(hitOffset.y);
    //x
    if(XgY && XgZ) hitSyde = hitOffset.x>0? (byte)1:(byte)2;
    //y
    else if(!XgY && !ZgY) hitSyde = hitOffset.y>0? (byte)3:(byte)4;
    //z
    else if(ZgY && !XgZ) hitSyde = hitOffset.z>0? (byte)5:(byte)6;
    
    return new Ray(hitPos, mapCheck, new intVector(cCheckPos), chunkToCheck, type, hitSyde);
  }
  else return new Ray();
  
}
