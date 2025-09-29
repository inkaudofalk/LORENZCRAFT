public static class block {
  public static byte lastLiquid = 2;
  public static byte lastTransparent = 6;
  
  public static byte AIR = 0;
  
  public static byte WATER = 1;
  public static byte LAVA = 2;
  
  public static byte GLASS = 3;
  public static byte LEAF = 4;
  public static byte ICE = 5;
  public static byte SLIME = 6;
  
  public static byte BEDROCK = 7;
  public static byte COBBLESTONE = 8;
  public static byte DIRT = 9;
  public static byte GRASS = 10;
  public static byte STONE = 11;
  public static byte SAND = 12;
  public static byte GRAVEL = 13;
  public static byte LOG = 14;
  public static byte PLANK = 15;
}

public static class Settings {
  public static final String[] kbN = {
    //player movement
    "up",
    "down",
    "left",
    "right",
    "jump",
    "sneak",
    "sprint",
    //mouse
    "break block",
    "placeBlock",
    
    //other
    "pause",
    "details"
  };
  public static int[] keyBinds = {
    87,  //0 up
    83,  //1 down
    65,  //2 l
    68,  //3 r
    32,  //4 jump
    17,  //5 sneak
    16,  //6 sprint
    
    37,  //7 bb
    39,  //8 pb
    
    ESC, //9 pause
    99   //10 details
  };
  public static PVector Sensitivity = new PVector(1f, .5f);
}

public static class cWorld {
  public static intVector[] sideOffset = {new intVector(), new intVector(1,0,0), new intVector(-1,0,0), new intVector(0,1,0), new intVector(0,-1,0), new intVector(0,0,1), new intVector(0,0,-1)};
   
  public static final int chunksX = 25;
  public static final int chunksZ = 25;
  public static final int heightLimit = 256;
  public static final color skyColor = #79A6FF;
  public static final float seaLevel = 21f;
}
