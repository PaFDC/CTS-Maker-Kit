import processing.serial.*;
import javax.swing.*; //for serial port prompt

boolean setup = true;
// toggle prompt for choosing serial port

int lf = 10;  // linefeed in ASCII
String myString = null; //raw serial data
float[] data = new float[2]; //serial data split in 2 numbers
Serial myPort;  // serial port

float margin, headerHeight, rectsHeight, barsHeight, graphHeight;

int rgb[][] = {
  { 200, 55, 110 }, //0: left axis
  {  20, 85, 140 }
}; //1: right axis
color bg = color(242);
color light = color(245, 195, 215); //light pressure
color dark = color(200, 55, 110); //heavy pressure 
color header = color(255); //header text
color stroke = color(190);
color subtitleBG = color(20, 85, 140);
color subtitle = color(255);
color rectsFill = color(230, 245, 255);

int numRects = 16; // number of sensor rectangles
int maxRects = 40; // max number of sensor rectangles
int rectInc = 2; // sensitivity increment
float[][] rects = new float[maxRects][4]; // coordinates for each rect


float[][] readings = new float[4][2000]; // all readings
// 0: left readings
// 1: right readings
// 2: raw n value
// 3: n-normalized

float[][] plot = new float[2][2000]; // scaled left-right readings

float time[] = new float[2000];
float startingLine = 0.9; // how far across the screen the current data point is drawn

volatile int vIdx = 1300;
int idx = 1300;

volatile boolean vRunning = true;
boolean running = true;
boolean console = false;
boolean mousePause = false;
boolean mouseReset = false;
boolean mouseConsole = false;

float sensitivity[][] = { { 10.0, 40.0 }, { 20.0, 40.0 }, { 15.0, 20.0 }, {10.0, 15.0 } };
int sidx = 0; // Sensitivity index
float pLower = sensitivity[sidx][0]; // Default to first lower pressure sensitivity
float pUpper = sensitivity[sidx][1]; // Default to first upper pressure sensitivity

int inc = 30; // arrow increment

PImage logo, pause, play, reset, settings;
PFont font, fontBold;
int headFontSize = 28; //header title
int subFontSize = 14; //

float mainWidth, frameWidth;

//also adjust default values in reset() function
float maxLeft = 45.0;
float maxRight = 45.0;
float max = 45.0;

String delim = " ";

void setup() {

  //size(displayWidth, displayHeight);
  size(850, 650);
  surface.setResizable(true); // allow the canvas to be resized
  pixelDensity(displayDensity()); // renders hq if retina display

  background(bg);
  logo = loadImage("logo.png");
  pause = loadImage("pause.png");
  play = loadImage("play.png");
  reset = loadImage("reset.png");
  settings = loadImage("list.png");

  font = loadFont("Helvetica-16.vlw");
  fontBold = loadFont("Helvetica-Bold-30.vlw");


  println((Object)Serial.list()); //print available serial ports to console


  if (!setup) {
    //if setup is turned off, default to using this port
    myPort = new Serial(this, "/dev/cu.usbmodem1421", 115200);

    myPort.clear(); // throw out the first reading, in case we started reading in the middle of a string from the sender
    myString = myPort.readStringUntil(lf);
    myString = null;
    xScale();
    yScale();
  } else
  {
    try {
      Object selection;
      String port = "";
      int i = Serial.list().length;

      if (i > 0) {
        //if there are multiple ports available, ask which one to use
        selection = JOptionPane.showInputDialog(frame, "Select serial port number to use:\n", "Setup", JOptionPane.PLAIN_MESSAGE, null, Serial.list(), Serial.list()[0]);
        if (selection == null) exit();

        println(selection);
        port = selection.toString();
        println(port);
        myPort = new Serial(this, port, 115200);

        myPort.clear(); // throw out the first reading, in case we started reading in the middle of a string from the sender
        myString = myPort.readStringUntil(lf);
        myString = null;
        xScale();
        yScale();
        //println(time);
      } else {
        JOptionPane.showMessageDialog(frame, "Device is not connected to the PC");
        exit();
      }
    }
    catch (Exception e)
    { //Print the type of error
      JOptionPane.showMessageDialog(frame, "COM port is not available (may\nbe in use by another program)");
      println("Error:", e);
      exit();
    }
  }//end if(showSetup)
}//end setup



void draw() {
  //since window is resizable, the height of each element is based on
  //a fraction of the height of the window (using the 'margin' as a base unit).
  margin = height / 26.0;
  headerHeight = margin * 4.0;
  rectsHeight = margin * 5.0;
  barsHeight = margin * 5.0;
  graphHeight = margin * 5.0;

  //frameWidth is the width of the window containing the main program elements
  //when the console is on, the program takes up less of the window so the console can show on the side
  if (console) frameWidth = width * 0.7;
  else frameWidth = width;
  mainWidth = frameWidth - margin * 2.0;


  while (myPort.available() > 0) {
    myString = myPort.readStringUntil(lf);
  }
  if (myString != null) {
    data = float(split(myString, delim)); //split raw data into 2 numbers
    println(data);

    if (data[0] > maxLeft) maxLeft = data[0];
    if (data[1] > maxRight) maxRight = data[1];
    if (maxLeft > maxRight) max = maxLeft;
    else max = maxRight;
    //update max reading values as you go

    if (running)
    {
      readings[0][readings[0].length-1] = (-1) * data[0];
      readings[1][readings[1].length-1] = (-1) * data[1];

      // Map the element so it fits in our graph
      plot[0][plot[0].length-1] = map(readings[0][readings[0].length-1], 0, max, 0, graphHeight);
      plot[1][plot[1].length-1] = map(readings[1][readings[1].length-1], 0, max, 0, graphHeight);


      for (int j = 0; j < 2; j++)
      {
        for (int i = idx; i < time.length - 1; i++)
        {
          readings[j][i] = readings[j][i + 1]; // Shift the readings to the left so can put the newest reading in
          plot[j][i] = plot[j][i + 1];
        }
      }
    }//end if(running)
  }//end if(myString != null)

  background(bg);

  if (width < 540 || height < 400) {  
    headFontSize = 14; 
    subFontSize = 10;
  } else { 
    headFontSize = 28; 
    subFontSize = 14;
  }

  //draw header
  noStroke();
  fill(header);
  rect(0, 0, width, headerHeight);
  textFont(fontBold, headFontSize);
  fill(10, 40, 75);
  text("Fabric Touch Sensor Visualizer", margin, headerHeight/2.0 + (headFontSize/2.0));
  fill(stroke);
  rect(0, headerHeight, width, 2);
  if (width > 650 && height > 400) image(logo, width-200-margin, headerHeight/2.0 - 28, 200, 56);

  touchLocation();
  sensitivityBars();
  sensitivityGraph();
  if (console) console();
  drawButtons();
}//end draw

void sensitivityBars()
{
  float offset = headerHeight + rectsHeight + margin * 3.25;

  //  draw title
  fill(subtitleBG);
  noStroke();
  rect(margin, offset, mainWidth, margin);
  fill(subtitle);
  textFont(font, subFontSize);
  float textWidth = textWidth("SENSITIVITY MONITORS");
  text("SENSITIVITY MONITORS", frameWidth/2.0 - textWidth/2.0, offset + margin * 0.75);

  // draw container
  fill(255);
  stroke(stroke);
  strokeWeight(1);
  rect(margin, offset + margin*1.25, mainWidth, barsHeight);

  float center = offset + margin * 2.25; //top y-coord for rectangles to center vertically in container

  // scale raw data from 0 to edge of box
  float wLeft = map((-1)*readings[0][readings[0].length-1], 0, max, 0, (mainWidth/2.0 - margin/4.0));
  float wRight = map((-1)*readings[1][readings[1].length-1], 0, max, 0, (mainWidth/2.0 - margin/4.0));

  //draw bars for left and right
  noStroke();
  fill(rgb[0][0], rgb[0][1], rgb[0][2]);
  rect(frameWidth/2.0 - wLeft, center, wLeft, margin*2.5);

  fill(rgb[1][0], rgb[1][1], rgb[1][2]);
  rect(frameWidth/2.0, center, wRight, margin*2.5);


  //current value
  textFont(fontBold, subFontSize);
  textAlign(RIGHT);
  fill(rgb[0][0], rgb[0][1], rgb[0][2]);
  text(round((-1)*readings[0][readings[0].length-1]), frameWidth/2.0 - margin/4.0, center - margin/4.0);

  textAlign(LEFT);
  fill(rgb[1][0], rgb[1][1], rgb[1][2]);
  text(round((-1)*readings[1][readings[1].length-1]), frameWidth/2.0+ margin/2.0, center - margin/4.0);

  //separation axis
  //  fill(10, 40, 75); //header color
  fill(0);
  rect(frameWidth/2.0, center-margin*0.75, margin/4.0, margin * 4.5);
  textFont(font, subFontSize);

  //axis labels (0 to max)
  textAlign(RIGHT);
  text(round(max), frameWidth - margin * 1.5, offset + margin*1.25 + barsHeight - margin/2.0);
  text(0, frameWidth/2.0 - margin/4.0, offset + margin*1.25 + barsHeight - margin/2.0);

  textAlign(LEFT);
  text(round(max), margin * 1.5, offset + margin*1.25 + barsHeight - margin/2.0);
  text(0, frameWidth/2.0 + margin/2.0, offset + margin*1.25 + barsHeight - margin/2.0);

  arrow(frameWidth/2.0-margin, offset + barsHeight+margin/2.0, margin*3.0, offset + barsHeight + margin/2.0);
  arrow(frameWidth/2.0+margin, offset + barsHeight+margin/2.0, frameWidth-margin*3.0, offset + barsHeight + margin/2.0);
}//end sensitivity bars

void arrow(float x1, float y1, float x2, float y2) {
  strokeWeight(1);
  stroke(0);
  line(x1, y1, x2, y2);
  pushMatrix();
  translate(x2, y2);
  float a = atan2(x1-x2, y2-y1);
  rotate(a);
  line(0, 0, -3, -3);
  line(0, 0, 3, -3);
  popMatrix();
} 

void sensitivityGraph() {
  idx = vIdx; // Set the index equal to the volatile index to prevent overwriting during the loop
  running = vRunning; // Set the running flag equal to the volatile running flag
  xScale();
  yScale();
  //xScale and yScale remap the readings in case the window size has changed

  //draw graph container
  float offset = headerHeight + rectsHeight + barsHeight + margin * 4.75;
  strokeWeight(1);
  stroke(stroke);
  fill(255);
  rect(margin, offset, mainWidth, graphHeight);

  // plot all the points
  for (int j = 0; j < 2; j++)
  {
    for (int i = idx; i < time.length - 1; i++)
    {
      stroke(rgb[j][0], rgb[j][1], rgb[j][2], map(i, idx, time.length, 0, 255));
      strokeWeight(2);
      line(time[i], plot[j][i], time[i+1], plot[j][i+1]);
    }
    fill(rgb[j][0], rgb[j][1], rgb[j][2]);
    ellipse(time[time.length-1], plot[j][plot[j].length-1], 5, 5);
  }

  //draw axis
  fill(0);
  text(0, margin*2.5, offset+graphHeight-margin/2.0);
  text(round(max), margin*2.5, offset+margin);

  arrow(margin*2.0, offset+graphHeight-margin/2.0, margin*2.0, offset+margin*0.75);

  textAlign(LEFT);
  strokeWeight(1);
}//end sensitivity graph

void xScale()
{
  for (int i = idx; i < time.length; i++)
  {
    time[i] = map(i, idx, time.length-1, margin, startingLine*mainWidth);
  }
}//end xScale

void yScale()
{
  for (int i = 0; i < time.length; i++)
  {
    plot[0][i] = headerHeight + rectsHeight + barsHeight + graphHeight + margin * 4.75 + map(readings[0][i], 0, max, 0, graphHeight-margin/4.0);
    plot[1][i] = headerHeight + rectsHeight + barsHeight + graphHeight + margin * 4.75 + map(readings[1][i], 0, max, 0, graphHeight-margin/4.0);
  }
}//end yScale


void touchLocation() {
  //draw title
  float offset = headerHeight + margin;
  fill(subtitleBG);
  noStroke();
  rect(margin, offset, mainWidth, margin);
  fill(subtitle);
  textFont(font, subFontSize);
  text("TOUCH LOCATION", frameWidth/2.0 - textWidth("TOUCH LOCATION")/2.0, offset + margin *0.75);

  //draw container
  fill(255);
  stroke(stroke);
  rect(margin, offset + margin*1.25, mainWidth, rectsHeight);

  float pWidth = 0.7; // percentage of the width of each segment
  float pHeight = 1.0; //
  
  float x = margin + (mainWidth/(2.0*numRects))*(1.0 - pWidth); // x position
  float y = offset + margin*1.25; // y position
  float w = pWidth*mainWidth/numRects; // rectangle width
  float h = rectsHeight; // rectangle height

  stroke(stroke);
  strokeWeight(1);
  fill(rectsFill);
  //draw rectangles numbered numRects to 0 (j) and store their coordinates in the rects[j][] array
  for (int j = numRects-1; j >= 0; j--) {
    rect(x, y, w, h);
    rects[j][0] = x;
    rects[j][1] = y;
    rects[j][2] = w;
    rects[j][3] = h;

    x += mainWidth/numRects;
  }//end for

  float[] temp = new float[2];
  temp = positionPressure((-1)*readings[0][readings[0].length-1], (-1)*readings[1][readings[1].length-1]);
  updateLocation(temp[0], temp[1]);
}//end touchLocation


float nMin = 1.0;
float nMax = 1.0;
//you may need to adjust default max/min as necessary
//also adjust default values in reset() function

float[] positionPressure(float r1, float r2)
{
  float rl = r1-0;
  if (rl < 1.0)
  {
      rl = 1.0;
  }
  
  float rr = r2-0;
  if (rr < 1.0)
  {
      rr = 1.0;
  }
  float n = log(rl) - log(rr);
  if (n < nMin) nMin = n;
  else if (n > nMax) nMax = n;
  //update max/min n-value with each calculation

  float nNormal = map(n, nMin, nMax, 0, 1); //map n-value to standard 0-1 scale for easy analysis
  float p = (r1 + r2) / 2.0 - 17.0; //avg pressure between left/right

  if (running) {
    readings[2][readings[2].length-1] = n;
    readings[3][readings[3].length-1] = nNormal;
    //store n and n-normal in readings array

    for (int i = idx; i < time.length - 1; i++)
    {
      readings[2][i] = readings[2][i + 1]; // Shift the readings to the left so can put the newest reading in
      readings[3][i] = readings[3][i + 1];
    }
  }//end if(running)

  return new float[] {nNormal, p};
}//end positionPressure


void updateLocation(float n, float p) {
  int index;
  float lowerThreshold = 30.0;
  float upperThreshold = 40.0;
  //for touch location-
  //pale color fills in when avg pressure is at lower threshold;
  //darker color fills past upper threshold

  index = round(map(n, 0, 1, 0, numRects-1)); //map n to nearest rectangle index (0-11)

  //upper & lower pressure threshold for coloring the rectangles
  //if (p > lowerThreshold && p < upperThreshold) fill(light);
  //else if (p >= upperThreshold) fill(dark);
  //else fill(rectsFill);
  
  int Sscale = 255;
  
  //float pLower = 20.0;
  //float pUpper = 60.0;
  
  int s = (int)(Sscale * (p - pLower) / (pUpper - pLower));
  if (s < 0) {
      s = 0;
  }else if (s > Sscale) {
      s = Sscale;
  }
  
  fill(color(255, 0, 0, s));
  

  //use index to pull coordinates from corresponding rects[][] array to fill in the correct rectangle
  float x = rects[index][0];
  float y = rects[index][1];
  float w = rects[index][2];
  float h = rects[index][3];
  rect(x, y, w, h);
}//end updateLocation

void console()
{

  float yOffset = headerHeight + margin;
  float xOffset = frameWidth;
  float consoleWidth = width * 0.3 - margin;

  //draw title
  fill(subtitleBG);
  stroke(stroke);
  rect(xOffset, yOffset, consoleWidth, margin);
  fill(subtitle);
  textFont(font, subFontSize);
  float textWidth = textWidth("RAW SENSITIVITY DATA");
  text("RAW SENSITIVITY DATA", frameWidth + (consoleWidth/2.0 - textWidth/2.0), yOffset + margin * 0.75);

  //draw container
  stroke(stroke);
  rect(xOffset, yOffset + margin*1.25, consoleWidth, height - headerHeight - margin*3.25);

  //draw labels
  fill(bg);

  rect(xOffset, yOffset+margin*1.25, consoleWidth, margin);
  rect(xOffset, yOffset+margin*2.25, consoleWidth, margin);

  float textY = yOffset + margin * 2.0;
  float textX = frameWidth + margin/2.0;
  fill(0);
  textFont(font, subFontSize);
  text("N-min: ", textX, textY);
  text(nMin, textX+textWidth("N-min: "), textY);
  text("N-max: ", textX+textWidth("N-min:0000__|__"), textY);
  text(nMax, textX+textWidth("N-min:0000___N-max:__"), textY);
  textY += margin;
  textFont(font, subFontSize);
  text("L", frameWidth+margin/2.0, textY);
  text("R", frameWidth + margin*2.5, textY);
  text("N", frameWidth + margin*4.75, textY);
  text("N-n", frameWidth+margin*6.75, textY);
  textFont(font, subFontSize);
  textY += margin;


  //number of data points to show at a time
  //shorter list for shorter window heights
  //(could be more refined)
  int numData = 20;
  if (height < 500) numData = 10;



  //print 20 most recent values from readings[][] array
  //[0][] = left, [1][] = right
  //[2][] = raw n-value, [3][] = n-normal
  for (int i = 0; i < 4; i++)
  {
    for (int j = time.length-1; j > time.length-numData; j--)
    {
      if (i < 2) text(round((-1)*readings[i][j]), textX, textY);
      else text(readings[i][j], textX, textY);
      textY += subFontSize*1.5;
    }

    textY = yOffset + margin*4.0;
    if (i == 1) textX += margin*1.5;
    else if (i == 2) textX += margin*2.5;
    else textX += margin*2.0;
  }
}//end console()

void reset()
{
  max = 45.0;
  maxLeft = 45.0;
  maxRight = 45.0;

  nMin = 1.0;
  nMax = 1.0;
  for (int i = 0; i < 2; i++) {
    for (int j = 0; j < time.length; j++)
    {
      plot[i][j] = 0;
      readings[i][j] = 0;
    }
  }

  xScale();
  yScale();
}//end reset

void drawButtons() 
{
  if (mouseY > (height-margin*1.6) && mouseY < (height-margin*0.6)) {
    if (mouseX < (frameWidth - margin *4.2 ) && mouseX > (frameWidth - margin * 5.2))
    {
      mousePause = true;
      mouseReset = false;
      mouseConsole = false;
    } else if (mouseX < (frameWidth - margin * 2.7) && mouseX > (frameWidth - margin * 3.7))
    {
      mousePause = false;
      mouseReset = true;
      mouseConsole = false;
    } else if (mouseX < frameWidth-margin && mouseX > (frameWidth - margin * 2.2))
    {
      mousePause = false;
      mouseReset = false;
      mouseConsole = true;
    } else
    {
      mousePause = false;
      mouseReset = false;
      mouseConsole = false;
    }
  }
  tint(255, 190);
  if (mousePause) tint(255, 100);
  if (running) image(pause, frameWidth-margin*5.2, height-margin*1.6, margin, margin);
  else image(play, frameWidth-margin*5.2, height-margin*1.6, margin, margin);

  tint(255, 190);
  if (mouseReset) tint(255, 100);
  image(reset, frameWidth-margin*3.7, height-margin*1.6, margin, margin);

  tint(255, 190);  
  //console button remains grey if console is open
  //switches color on hover
  if (console ^ mouseConsole) tint(255, 100); 
  image(settings, frameWidth-margin*2.2, height-margin*1.6, margin, margin);

  noTint();
}

void changeSensitivity()
{
  sidx++;
  if (sidx >= sensitivity.length)
  {
    sidx = 0;
  }
  pLower = sensitivity[sidx][0];
  pUpper = sensitivity[sidx][1];
}

void keyPressed()
{
  if (key == CODED)
  {
    if (keyCode == LEFT) {
      vIdx += inc;
      if (vIdx > time.length - inc)
      {
        vIdx = time.length - inc;
      }
    } else if (keyCode == RIGHT) {
      vIdx -= inc;
      if (vIdx < inc)
      {
        vIdx = inc;
      }
    } else if (keyCode == UP) {
        numRects += rectInc;
        if (numRects > maxRects) {
            numRects = maxRects;
        }
    } else if (keyCode == DOWN) {
        numRects -= rectInc;
        if (numRects < rectInc) {
            numRects = rectInc;
        }
    }
  } else if (key == ' ')
  {
    vRunning = !vRunning;
  } else if (key == 'r')
  {
    reset();
  } else if (key == 'd')
  {
    console = !console;
  } else if (key == 's')
  {
    changeSensitivity();
  }
  
}//end keyPressed

void mousePressed()
{
  if (mousePause) vRunning = !vRunning;
  else if (mouseReset) reset();
  else if (mouseConsole) console = !console;
}
