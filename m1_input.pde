void keyPressed() {
  if(keyCode == Settings.keyBinds[9]) {
    key = 0;
    pause(Active);
  }
  if(Active) player.OnButton(keyCode, true);
}

void keyReleased() {
  if(Active) player.OnButton(keyCode, false);
}

void mousePressed() {
  if(Active) player.OnMouse(mouseButton);
  else pauseMenu_mouseClick(mouseButton);
}

void mouseWheel(MouseEvent event) {
  if(Active) player.OnMouseWheel(event.getCount());
}
