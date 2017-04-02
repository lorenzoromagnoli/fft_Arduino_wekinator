class  WekInterface {  //<>//

  PApplet mainApplet;
  ControlP5 cp5;
  Handler handler;
  OscP5 oscP5;


  boolean sendingValues=false;
  int mode=0; //0=wait; 1=record; 2=run;

  int currentClass=0;

  
  String[] channels;

  WekInterface(PApplet p, Handler theHandler, int nClasses) {


    channels=new String[nClasses];
    for (int i=0; i<channels.length; i++) {
      channels[i]=""+i;
    }

    handler = theHandler;
    cp5=new ControlP5(p);
    mainApplet =p;

    oscP5 = new OscP5(this, 12000);
    dest = new NetAddress("127.0.0.1", 6448);

    // create a new button with name 'buttonA'
    cp5.addButton("connect to wekinator")
      .setValue(0)
      .setPosition(visualizationWidth+10, 40)
      .setSize(200, 19)
      ;

    cp5.addScrollableList("#")
      .setPosition(visualizationWidth+10, 70)
      .setSize(40, 100)
      .setBarHeight(20)
      .setItemHeight(20)
      .plugTo(this)
      .setOpen(false)
      .addItems(channels)
      ;

    cp5.addButton("record")
      .setPosition(visualizationWidth+10+40+10+10, 70)
      .setSize(40, 19)
      .plugTo(this)
      ;

    cp5.addButton("play")
      .setPosition(visualizationWidth+10+40+40+10+10+10, 70)
      .setSize(40, 19)
      .plugTo(this)
      ;

    cp5.addButton("alt") // cannot call this stop otherwise it will call th stop() function and block the program execution
      .setLabel("stop")
      .setPosition(visualizationWidth+10+40+40+10+10+40+10+10, 70)
      .setSize(40, 19)
      .plugTo(this)
      ;
      
     cp5.addSlider("loudnessTreshold") // cannot call this stop otherwise it will call th stop() function and block the program execution
      .setLabel("loudness Treshold")
      .setPosition(visualizationWidth+10, 100)
      .setSize(200, 19)
      .plugTo(this)
      .setMax(500)
      ;
  }



  void controlEvent(ControlEvent theEvent) { 
    println(theEvent.getController().getName());
    switch (theEvent.getController().getName()) {
      case("#"):
      currentClass=(int)theEvent.getController().getValue();
      selectClass(currentClass);
      println("channel #"+currentClass+" was selected");
      break;

      case("play"):
      train();
      delay(2000);
      startRunning();
      println("play button was pressed");
      break;

      case("record"):
      println("record button was pressed");
      startWekRecording();
      break;

      case("alt"):
      println("stop button was pressed");
      stopWekinator();
      break;
      
      case("loudnessTreshold"):
      println("changedTreshold");
      println(loudnessTreshold);
      break;
    }
  }

  void run(float[] sounds) {
    textAlign(CENTER);

    switch (mode) {
    case 0: //waiting
      fill(200, 200, 200);
      text("wek_waiting", 710, 350);
      break;
    case 1: //recording
      fill(255, 100, 0);
      text("wek_recording", 710, 350);
      senddata(sounds);
      break;
    case 2: //play
      fill(10, 200, 20);
      text("wek_running", 710, 350);
      senddata(sounds);
      break;
    }
  }


  void senddata(float[] sounds) {
    if (loudness>loudnessTreshold){
      OscMessage msg = new OscMessage("/wek/inputs");
      //msg.add(px);
      for (int i = 0; i < sounds.length; i++) {
        msg.add(sounds[i]);
      }
      //println(msg);
      oscP5.send(msg, dest);
    }
  }

  void selectClass(int c) {
    OscMessage msg = new OscMessage("/wekinator/control/outputs");
    msg.add((float)c);
    oscP5.send(msg, dest);
    
  }
  
  
  void changeSelection(int c){
    try {
      cp5.getController("#").setValue(c);
    }catch(Exception e) {
     println(e);
    }
    currentClass=c;
  }
  
  void startWekRecording() {
    OscMessage msg = new OscMessage("/wekinator/control/startRecording");
    oscP5.send(msg, dest);
    sendingValues=true;
    mode=1;
  }

  void train() {
    OscMessage msg = new OscMessage("/wekinator/control/train");
    oscP5.send(msg, dest);
  }

  void startRunning() {
    sendingValues=true;
    OscMessage msg = new OscMessage("/wekinator/control/startRunning");
    oscP5.send(msg, dest);
    mode=2;
  }

  void stopWekinator() {
    sendingValues=false;

    if (mode==1) {
      stopWekRecording();
    } else {
      stopRunning();
    }
  }

  void stopRunning() {
    OscMessage msg = new OscMessage("/wekinator/control/stopRunning");
    oscP5.send(msg, dest);
    mode=0;
  }

  void stopWekRecording() {
    OscMessage msg = new OscMessage("/wekinator/control/stopRecording");
    oscP5.send(msg, dest);
    mode=0;
  }

  /* incoming osc message are forwarded to the oscEvent method. */
  void oscEvent(OscMessage theOscMessage) {
    int value=(int)theOscMessage.get(0).floatValue();
    cp5.getController("#").setValue(value);
    currentClass=value;
    fireEvent();
  }

  protected void fireEvent() { 
    println("WekObj fired an Event.");
    handler.invokeWekEvent(this);
  }
  int getcurrentClass() {
    return(currentClass);
  }
}