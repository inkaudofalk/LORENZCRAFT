float[] bt_y = {-100,0,100};
boolean[] bt_selected = new boolean[3];
String[] bt_text = {"continue","settings","quit game"};
float btLength = 600;

int pMenuLayer;

//draw--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
void pauseMenu_draw() {
  textAlign(CENTER,CENTER);
  pauseMenu_checkBt(false);
  beginHUD();
  tint(0, 100);
  image(uiImage[3],0,0, width,height);
  noTint();
  for(int i=0; i<bt_y.length; i++) {
    PImage btimage = bt_selected[i]? uiImage[5]:uiImage[4];
    image(btimage, 0, bt_y[i],btLength,btLength*.1f);
    text(bt_text[i].toUpperCase(),0,bt_y[i]);
  }
  ellipse(mouseX-halfwidth,mouseY-halfheight, 10, 10);
  endHUD();
  textAlign(LEFT,CENTER);
}

//checkBt--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
void pauseMenu_checkBt(boolean state) {
  float halfBtLength = btLength*.5;
  float halfBtHeight = btLength*.05;
  if(mouseX-halfwidth < halfBtLength && mouseX-halfwidth>-halfBtLength) {
    for(int i=0; i<bt_y.length; i++) {
      if(mouseY-halfheight>bt_y[i]-halfBtHeight && mouseY-halfheight<bt_y[i]+halfBtHeight) {bt_selected[i] = true; if(state) pauseMenu_btClick(i);}
      else bt_selected[i] = false;
    }
  } else for(int i=0; i<bt_y.length; i++) {bt_selected[i] = false;}
}

//mouseClick--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
void pauseMenu_mouseClick(int context) {
  if(context == LEFT) pauseMenu_checkBt(true);
}

//btClick--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
void pauseMenu_btClick(int index) {
  switch(index) {
    case 0:
      pause(false);
      break;
    case 1:
      
      break;
    case 2:
      exit();
      break;
  }
}


void pause(boolean state) {
  timeScale = state? 0:1;
  r.setPointerVisible(state);
  r.confinePointer(!state);
  Active = !state;
  if(state) pMenuLayer = 0;
}
