static class intVector {
  public int x,y,z;
  
  intVector(int newx, int newy, int newz) {
    x = newx;
    y = newy;
    z = newz;
  }
  
  intVector(int newx, int newy) {
    x = newx;
    y = newy;
    z = 0;
  }
  
  intVector(PVector v) {
    x = int(v.x);
    y = int(v.y);
    z = int(v.z);
  }
  
  intVector() {
    x = 0;
    y = 0;
    z = 0;
  }
  
  void add(intVector v) {
    x += v.x;
    y += v.y;
    z += v.z;
  }
  
  public static intVector add(intVector v0, intVector v1) {
    return new intVector(
    v1.x + v0.x,
    v1.y + v0.y,
    v1.z + v0.z
    );
  }
  
  public static intVector roundV(PVector v) {
    return new intVector(
    round(v.x),
    round(v.y),
    round(v.z)
    );
  }
  
  void println() {
    print("["+x+", "+y+", "+z+"]");
  }
  
  public intVector minV2d(intVector v) {
    return(new intVector(min(x,v.x),min(y,v.y),0 ));
  }
  
  public intVector maxV2d(intVector v) {
    return(new intVector(max(x,v.x),max(y,v.y),0 ));
  }
}



class Ray {
  boolean hit;
  int type;
  intVector index, intPosition;
  PVector position;
  
  byte side;
  intVector chunk;
  
  void onUpdateIntPos() {
    position = null;
    index = new intVector(chunkify(intPosition.x, intPosition.y, intPosition.z));
    chunk = getChunk(intPosition.x, intPosition.z);
    type = chunks[chunk.x][chunk.z].blocks[index.x][index.y][index.z];
  }
  
  Ray() {
    type = -1;
    side = -1;
  }
  
  Ray(PVector p, intVector nintHitPos, intVector pChunk, intVector setChunk, byte ntype, byte nside) {
    hit = true;
    intPosition = nintHitPos;
    index = pChunk;
    position = p;
    type = ntype;
    side = nside;
    chunk = setChunk;
  }
}
