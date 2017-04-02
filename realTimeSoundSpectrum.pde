import ddf.minim.analysis.*;
import ddf.minim.*;
import ddf.minim.signals.*;
import oscP5.*;
import netP5.*;
import processing.serial.*;
import controlP5.*;
import java.util.*;
import processing.core.*; // registerMethod
import java.lang.reflect.*;

Minim minim;
AudioPlayer jingle;
AudioOutput out;
FFT fft;
String windowName;

int loudness=0;
int loudnessTreshold=10;

NetAddress dest;

AudioInput in;
int numberOfRanges=250;

float fftAvg[];

SerialInterface shybo;
WekInterface wek;

Handler hand;

int visualizationWidth=600;
int sideBarWidth=300;

float bandWidth;

PFont f;

String inString;  // Input string from serial port




void setup()
{
  f = createFont("RobotoMono-Bold", 18);
  textFont(f); 

  hand = new Handler(this);

  fftAvg= new float[numberOfRanges];
  size(820, 400);
  minim = new Minim(this);
  out = minim.getLineOut(Minim.STEREO, 2048);
  in = minim.getLineIn();
  fft = new FFT(in.bufferSize(), in.sampleRate());
  fft.linAverages( numberOfRanges );

  wek= new WekInterface(this, hand, 20);
  shybo= new SerialInterface(this, hand);
}


void draw() {
  background(0);
  stroke(255);
  fft.forward(in.mix); 
  float specSize=fft.specSize();
  bandWidth=visualizationWidth/specSize;
  for (int i = 0; i < fft.specSize(); i++) {
    stroke(255);
    line(i*bandWidth, height/2, i*bandWidth, height/2 - fft.getBand(i)*10);
  }

  int w = int( visualizationWidth/fft.avgSize() );
  loudness=0;
  for (int i = 0; i < fft.avgSize(); i++) {
    fill(255);
    rect(i*w, 200, i*w + w, 200 - fft.getAvg(i)*10);    
    fftAvg[i]=fft.getAvg(i);
    loudness+=fft.getAvg(i);
  }

  //for (int i = 0; i < fft.specSize(); i++) {
  //  if (i%10==0) {
  //    stroke(100, 100, 100);
  //    line(i*bandWidth, height, i*bandWidth, height);
  //  }
  //}

  fill(100, 100, 100);
  rect(visualizationWidth, 0, sideBarWidth, height);
  wek.run(fftAvg); //pass to the run class the data you want to send/analayze with wekinator

  updateLoudness();
}


void updateLoudness() {
  
  int mappedLoudness=(int)map(loudness,0,500,0,200);
   int mappedLoudnessTreshold=(int)map(loudnessTreshold,0,500,0,200);

  if (loudness>loudnessTreshold){
    fill(10, 200, 50);
  }else{
    fill(200, 200, 200);
  }
  rect(610, 300, mappedLoudness+5, 20);
  fill(255);
  rect(610 +mappedLoudnessTreshold, 300, 5, 20);

  shybo.sendLoudness(loudness);
}

void stop()
{
  // always close Minim audio classes when you finish with them
  out.close();
  minim.stop();
  super.stop();
}

void serialDataReceived(SerialInterface e) { 
  println( e.getString() );
}

void wekDataReceived(WekInterface e) { 
  shybo.sendClass(e.getcurrentClass());
}

void serialEvent(Serial p) { 
  inString = p.readString();
  if (inString.charAt(0)=='#') {
    int classe=0;
    try {
      classe = Integer.parseInt(inString.substring(1).trim());
      println ("changed class:"+ classe );
    } 
    catch (Exception e) {
      println(e);
    }
    wek.changeSelection(classe);
  } else if (inString.charAt(0)=='C') {
    if (inString.charAt(1)=='R') {
      wek.startWekRecording();
    } else if (inString.charAt(1)=='S') {
      wek.stopWekinator();
    } else if (inString.charAt(1)=='P') {
      wek.train();
      delay (500);
      wek.startRunning();
    }
  }
}