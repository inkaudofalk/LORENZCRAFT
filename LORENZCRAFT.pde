import com.jogamp.newt.opengl.GLWindow;

//texture
int textureSize;
int atlasSize;
PImage atlas;
PImage[] uiImage;

//font
PFont uiFont;

int halfwidth,halfheight;


Player player;
Chunk[][] chunks;

float multx = .03;
float multz = .03;
float multy = 20;
int addy = 6;

int worldSeed, treeSeed;



//setup--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
void setup() {
  r=(GLWindow)surface.getNative(); 
  r.confinePointer(true);
  r.setPointerVisible(false);
  //size(1600, 1000, P3D);
  fullScreen(P3D);
  halfwidth = width/2;
  halfheight = height/2;
  
  virtualMouse = new PVector(halfwidth,height);
  //smoothVirtualMouse = virtualMouse.copy();
  
  perspective(PI/3.0, float(width)/float(height), .01, ((height/2.0)/tan(PI*60.0/360.0))*10.0);
  noStroke();
  rectMode(CENTER);
  noSmooth();
  ((PGraphicsOpenGL)g).textureSampling(3);
  
  uiFont = createFont("fonts/minecraft_font.ttf",120, false);
  textFont(uiFont,20);
  textAlign(LEFT,CENTER);
  imageMode(CENTER);
  setupTextures();
  
  setupWorld(); 
  player = new Player(new PVector(cWorld.chunksX*16/2,50,cWorld.chunksZ*16/2));
  frameRate(1000);
  //PJOGL pgl = (PJOGL)beginPGL();
  //pgl.gl.setSwapInterval(1);
  //endPGL();
}

//setupTextures--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
void setupTextures() {
  atlas = loadImage("atlas.png");  
  uiImage = new PImage[] {
    loadImage("ui/hotbar.png"),
    loadImage("ui/hbPointer.png"),
    loadImage("ui/options_background.png"),
    createImage(5,5, RGB),
    loadImage("ui/button.png"),
    loadImage("ui/button_select.png"),
    loadImage("ui/underwater.png")
  };
  atlasSize = atlas.width;
  textureSize = atlas.height/3-2;
}

//setupWorld--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
void setupWorld() {
  worldSeed = 5;//int(random(2560));
  treeSeed = int(random(2560));
  
  chunks = new Chunk[cWorld.chunksX][cWorld.chunksZ];
  for(int i=0; i<chunks.length; i++)
  for(int j=0; j<chunks[i].length; j++) {
    chunks[i][j] = new Chunk(i,j);
  }
  // generate mesh
  for(int i=0; i<chunks.length; i++)
  for(int j=0; j<chunks[i].length; j++) {
    chunks[i][j].generateMesh();
  }
}
