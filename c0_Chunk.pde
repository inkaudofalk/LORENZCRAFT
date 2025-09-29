class Chunk {
  byte[][][] blocks;
  int posx,posz;
  
  
  PShape mesh;
  PShape tmesh;
  
  int[] ind;
  
  
  Chunk(int indX, int indZ) {
    blocks = new byte[16][cWorld.heightLimit][16];
    
    ind = new int[] {indX, indZ};
    
    posx = indX *16;
    posz = indZ *16;
    
    generate();
  }
  
  void generate() {
    noiseSeed(treeSeed);
    float[][] treeMap = new float[16][16];
    for(int x=0; x<16; x++)
      for(int z=0; z<16; z++) {
        treeMap[x][z] = noise((x+posx),(z+posz));
      }
      
    noiseSeed(worldSeed);
    float[][] hMap = new float[16][16];
    for(int x=0; x<16; x++)
      for(int z=0; z<16; z++) {
        hMap[x][z] = noise((x+posx)*multx*.1,(z+posz)*multz*.1)*multy;
      }
      
    noiseSeed(worldSeed+1);
    for(int x=0; x<16; x++) {
      for(int z=0; z<16; z++) {        
        int y = round(noise((x+posx)*multx,(z+posz)*multz)*multy+hMap[x][z])+addy;
        
        //grass / water
        if(y < cWorld.seaLevel) {
          blocks[x][y][z] = block.SAND;
          for(int wy=round(cWorld.seaLevel)-1; wy>y; wy--) blocks[x][wy][z] = block.WATER;
        }
        else blocks[x][y][z] = block.GRASS;
        //bedrock
        blocks[x][0][z] = block.BEDROCK;
        //dirt and stone
        for(int l=y-1; l>0; l--) {
          byte setTypeTo = l>y-4? (byte)block.DIRT:(byte)block.STONE;
          blocks[x][l][z] = setTypeTo;
        }
        
        if(treeMap[x][z] >= .85 && y >= cWorld.seaLevel) {
          blocks[x][y+1][z] = block.LOG;
          blocks[x][y+2][z] = block.LOG;
          blocks[x][y+3][z] = block.LOG;
          blocks[x][y+4][z] = block.LOG;
          blocks[x][y+5][z] = block.LEAF;
        }
      }
    }
  }
  
  void  render() {
    shape(mesh);
  }
  
  void  render2() {
    shape(tmesh);
  }
  
  void generateMesh() {
    noFill();
    mesh = createShape();
    mesh.beginShape(QUADS);
    mesh.texture(atlas);
    
    tmesh = createShape();
    tmesh.beginShape(QUADS);
    tmesh.texture(atlas);
    for(int x=0; x<16; x++) {
      for(int z=0; z<16; z++) {
        for(int y=0; y<256; y++) {
          if(blocks[x][y][z] != 0) {
            createBlock(x,y,z,blocks[x][y][z]);
          }
        }
      }
    }
    mesh.endShape();
    tmesh.endShape();
  }
  
 void createBlock(int x, int y, int z, byte type) {
    int baseU = (type-1)*textureSize+type*2-1;
    int baseV = 1;
    int increment = textureSize+2;
    //float topOffset = .5;
    //int pixOffset = 0;
    //if(blocks[x][y][z] == block.WATER) {
    //  topOffset = .4375;
    //  pixOffset = -1;
    //}
    if(type > block.lastTransparent) {   
      if(y==0 || blocks[x][y-1][z] <= block.lastTransparent) {
        //bottom -y
        mesh.vertex(posx+x+.5,y-.5,posz+z-.5,baseU+textureSize,baseV+increment);  
        mesh.vertex(posx+x+.5,y-.5,posz+z+.5,baseU+textureSize,baseV+increment+textureSize);
        mesh.vertex(posx+x-.5,y-.5,posz+z+.5,baseU,baseV+increment+textureSize);
        mesh.vertex(posx+x-.5,y-.5,posz+z-.5,baseU,baseV+increment);     
      }
      if(y==255 || blocks[x][y+1][z] <= block.lastTransparent) {
        //top y
        mesh.vertex(posx+x-.5,y+.5,posz+z-.5,baseU+textureSize,baseV);
        mesh.vertex(posx+x-.5,y+.5,posz+z+.5,baseU+textureSize,baseV+textureSize);
        mesh.vertex(posx+x+.5,y+.5,posz+z+.5,baseU,baseV+textureSize);
        mesh.vertex(posx+x+.5,y+.5,posz+z-.5,baseU,baseV);
      }
      if(x==15 && ind[0]+1 < cWorld.chunksX && chunks[ind[0]+1][ind[1]].blocks[0][y][z] <= block.lastTransparent
         || x!=15 && blocks[x+1][y][z] <= block.lastTransparent) {
        //East x
        mesh.vertex(posx+x+.5,y+.5,posz+z-.5,baseU+textureSize,baseV+textureSize+increment*2);
        mesh.vertex(posx+x+.5,y+.5,posz+z+.5,baseU,baseV+textureSize+increment*2);
        mesh.vertex(posx+x+.5,y-.5,posz+z+.5,baseU,baseV+increment*2);
        mesh.vertex(posx+x+.5,y-.5,posz+z-.5,baseU+textureSize,baseV+increment*2);
      }
      if(x==0 && ind[0]-1 >= 0      && chunks[ind[0]-1][ind[1]].blocks[15][y][z] <= block.lastTransparent
         || x!=0 && blocks[x-1][y][z] <= block.lastTransparent) {
        //West -x
        mesh.vertex(posx+x-.5,y-.5,posz+z-.5,baseU,baseV+increment*2);
        mesh.vertex(posx+x-.5,y-.5,posz+z+.5,baseU+textureSize,baseV+increment*2);
        mesh.vertex(posx+x-.5,y+.5,posz+z+.5,baseU+textureSize,baseV+textureSize+increment*2);
        mesh.vertex(posx+x-.5,y+.5,posz+z-.5,baseU,baseV+textureSize+increment*2);
      }
      if(z==15 && ind[1]+1 < cWorld.chunksZ && chunks[ind[0]][ind[1]+1].blocks[x][y][0] <= block.lastTransparent
         || z!=15 && blocks[x][y][z+1] <= block.lastTransparent) {
        //south z
        mesh.vertex(posx+x-.5,y-.5,posz+z+.5,baseU,baseV+increment*2);
        mesh.vertex(posx+x+.5,y-.5,posz+z+.5,baseU+textureSize,baseV+increment*2);
        mesh.vertex(posx+x+.5,y+.5,posz+z+.5,baseU+textureSize,baseV+textureSize+increment*2);
        mesh.vertex(posx+x-.5,y+.5,posz+z+.5,baseU,baseV+textureSize+increment*2);
      }
      if(z==0 && ind[1]-1 >= 0      && chunks[ind[0]][ind[1]-1].blocks[x][y][15] <= block.lastTransparent
         || z!=0 && blocks[x][y][z-1] <= block.lastTransparent) {
        //north -z
        mesh.vertex(posx+x-.5,y+.5,posz+z-.5,baseU+textureSize,baseV+textureSize+increment*2);
        mesh.vertex(posx+x+.5,y+.5,posz+z-.5,baseU,baseV+textureSize+increment*2);
        mesh.vertex(posx+x+.5,y-.5,posz+z-.5,baseU,baseV+increment*2);
        mesh.vertex(posx+x-.5,y-.5,posz+z-.5,baseU+textureSize,baseV+increment*2);
      }
      return;
    }
    
    
    byte nbType;
    byte cNbType;
    nbType = blocks[x][y-1][z];
    if(y==0 || nbType != type && nbType <= block.lastTransparent) {
      //bottom -y
      tmesh.vertex(posx+x+.5,y-.5,posz+z-.5,baseU+textureSize,baseV+increment);  
      tmesh.vertex(posx+x+.5,y-.5,posz+z+.5,baseU+textureSize,baseV+increment+textureSize);
      tmesh.vertex(posx+x-.5,y-.5,posz+z+.5,baseU,baseV+increment+textureSize);
      tmesh.vertex(posx+x-.5,y-.5,posz+z-.5,baseU,baseV+increment);          
    }
    nbType = blocks[x][y+1][z];
    if(y==255 || nbType != type && nbType <= block.lastTransparent) {
      //top y
      tmesh.vertex(posx+x-.5,y+.5,posz+z-.5,baseU+textureSize,baseV);
      tmesh.vertex(posx+x-.5,y+.5,posz+z+.5,baseU+textureSize,baseV+textureSize);
      tmesh.vertex(posx+x+.5,y+.5,posz+z+.5,baseU,baseV+textureSize);
      tmesh.vertex(posx+x+.5,y+.5,posz+z-.5,baseU,baseV);
    }
    nbType = x!=15 ? blocks[x+1][y][z]:type;
    cNbType = x==15 && ind[0]+1 < cWorld.chunksX ? chunks[ind[0]+1][ind[1]].blocks[0][y][z]:type;
    if( cNbType != type && cNbType <= block.lastTransparent
       || nbType != type && nbType <= block.lastTransparent) {
      //East x
      tmesh.vertex(posx+x+.5,y+.5,posz+z-.5,baseU+textureSize,baseV+textureSize+increment*2);
      tmesh.vertex(posx+x+.5,y+.5,posz+z+.5,baseU,baseV+textureSize+increment*2);
      tmesh.vertex(posx+x+.5,y-.5,posz+z+.5,baseU,baseV+increment*2);
      tmesh.vertex(posx+x+.5,y-.5,posz+z-.5,baseU+textureSize,baseV+increment*2);
    }
    nbType = x!=0 ? blocks[x-1][y][z]:type;
    cNbType = x==0 && ind[0]-1 >= 0 ? chunks[ind[0]-1][ind[1]].blocks[15][y][z]:type;
    if(cNbType != type && cNbType <= block.lastTransparent
       || nbType != type && nbType <= block.lastTransparent) {
      //West -x
      tmesh.vertex(posx+x-.5,y-.5,posz+z-.5,baseU,baseV+increment*2);
      tmesh.vertex(posx+x-.5,y-.5,posz+z+.5,baseU+textureSize,baseV+increment*2);
      tmesh.vertex(posx+x-.5,y+.5,posz+z+.5,baseU+textureSize,baseV+textureSize+increment*2);
      tmesh.vertex(posx+x-.5,y+.5,posz+z-.5,baseU,baseV+textureSize+increment*2);
    }
    nbType = z!=15 ? blocks[x][y][z+1]:type;
    cNbType = z==15 && ind[1]+1 < cWorld.chunksZ ? chunks[ind[0]][ind[1]+1].blocks[x][y][0]:type;
    if( cNbType != type
       || nbType != type && nbType <= block.lastTransparent) {
      //south z
      tmesh.vertex(posx+x-.5,y-.5,posz+z+.5,baseU,baseV+increment*2);
      tmesh.vertex(posx+x+.5,y-.5,posz+z+.5,baseU+textureSize,baseV+increment*2);
      tmesh.vertex(posx+x+.5,y+.5,posz+z+.5,baseU+textureSize,baseV+textureSize+increment*2);
      tmesh.vertex(posx+x-.5,y+.5,posz+z+.5,baseU,baseV+textureSize+increment*2);
    }
    nbType = z!=0 ? blocks[x][y][z-1]:type;
    cNbType = z==0 && ind[1]-1 >= 0 ? chunks[ind[0]][ind[1]-1].blocks[x][y][15]:type;
    if( cNbType != type && cNbType <= block.lastTransparent
       || nbType != type && nbType <= block.lastTransparent) {
      //north -z
      tmesh.vertex(posx+x-.5,y+.5,posz+z-.5,baseU+textureSize,baseV+textureSize+increment*2);
      tmesh.vertex(posx+x+.5,y+.5,posz+z-.5,baseU,baseV+textureSize+increment*2);
      tmesh.vertex(posx+x+.5,y-.5,posz+z-.5,baseU,baseV+increment*2);
      tmesh.vertex(posx+x-.5,y-.5,posz+z-.5,baseU+textureSize,baseV+increment*2);
    }
  }
  
  
  int getFloor(float fx, float y, float fz) {
    int x = round(fx);
    int z = round(fz);
    if(y > 255) y = cWorld.heightLimit-1;
    int floorY = -30;
    for(int i=0; i<=y; i++) {
      if(blocks[x][i][z] > block.lastLiquid) floorY = i;
    }
    
    return floorY;
  }
}
