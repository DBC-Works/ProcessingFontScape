import java.util.stream.Stream;

import controlP5.*;

private final int HEIGHT_TOOLBAR = 40;
private final String[] fontNames = PFont.list();

private int fontSize = 24;
private String filterText = "";
private PFont[] fonts;
private float originY = 0;
private int lineHeight = 0;
private boolean sizeChanging = false;

private ControlP5 cp5;
private Textfield sampleTextfield;
private Textfield filterTextfield;

private ControlP5 setupControls() {
  cp5 = new ControlP5(this);

  var tab = cp5.getTab("default");
  tab.setLabel("Sample text");

  var font = createFont("arial", 20);

  sampleTextfield = cp5.addTextfield("sampleTextTextfiled");
  sampleTextfield.setPosition(0, tab.getHeight())
    .setSize(480, HEIGHT_TOOLBAR)
    .setFont(font)
    .setLabel("")
    .setValue("Installed font catalogue")
    .moveTo("default");

  filterTextfield = cp5.addTextfield("fontNameFilterTextfield");
  filterTextfield.setPosition(60, tab.getHeight())
    .setSize(480, HEIGHT_TOOLBAR)
    .setFont(font)
    .setLabel("")
    .setValue("")
    .moveTo("Font name filter");

  return cp5;
}

private String[] getVisibleFontNames(String filterText) {
  if (filterText.isEmpty()) {
    return fontNames;
  }

  return Stream.of(fontNames).filter(name -> name.contains(filterText)).toArray(String[]::new);
} 

private void updateFontSize(int count) {
  fontSize += count;
  fontSize = min(max(16, fontSize), 48);
  lineHeight = fontSize * 3 / 2; 
  fonts = new PFont[getVisibleFontNames(filterText).length];
}

private void updateOrigin(int count) {
  final var visibleFontNames = getVisibleFontNames(filterText);
  final var maxOriginY = (lineHeight * visibleFontNames.length * 2) - height;
  originY += count * (height / 50);
  originY = min(max(0, originY), maxOriginY);
}

void setup() {
  size(1280, 720);
  fill(#000000);
  textAlign(LEFT, BOTTOM);

  cp5 = setupControls();

  fonts = new PFont[getVisibleFontNames(filterText).length];
  lineHeight = fontSize * 3 / 2; 
}

void draw() {
  final var tab = cp5.getTab("default");
  final var text = sampleTextfield.getText();
  final var filter = filterTextfield.getText();
  final var filterdFontNames = getVisibleFontNames(filter);

  if (filterText.equals(filter) == false) {
    filterText = filter;
    fonts = new PFont[filterdFontNames.length];
    originY = 0;
  }

  background(#ffffff);
  translate(0, -originY);

  var y = fontSize + HEIGHT_TOOLBAR + tab.getHeight() + 8;
  var index = 0;
  for (String fontName : filterdFontNames) {
    if (originY <= y && y < originY + height) {
      if (fonts[index] == null) {
        fonts[index] = createFont(fontName, fontSize, true); 
      }
      textFont(fonts[index]);
      text(fontName, fontSize, y);
       y += lineHeight;
       text(text, fontSize * 4, y);
    }
    else {
      y += lineHeight;
    }
    y += lineHeight;
    ++index;
  }
}

void keyPressed() {
  switch (key) {
    case CODED:
      switch (keyCode) {
        case CONTROL:
          sizeChanging = true;
          break;
        case UP:
          updateOrigin(-lineHeight * 2 / 3);
          break;
        case DOWN:
          updateOrigin(lineHeight * 2 / 3);
          break;
        case 33:
          // pgup
          updateFontSize(-1);
          break;
        case 34:
          // pgdn
          updateFontSize(1);
          break;
        case 36:
          // home
          updateOrigin((int)-originY);
          break;
      }
      break;
  }
}

void keyReleased() {
  sizeChanging = false;
}

void mouseWheel(MouseEvent event) {
  final var count = event.getCount();
  if (sizeChanging) {
    updateFontSize(count);
  }
  else {
    updateOrigin(count);
  }
}
