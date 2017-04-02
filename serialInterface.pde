class  SerialInterface {

  int lf = 10;      // ASCII linefeed 


  Serial myPort;      // The serial port
  String[] ports=new String[10];

  PApplet mainApplet;
  Handler handler;
  int val = 0;

  ControlP5 cp5;
  SerialInterface(PApplet p, Handler theHandler) {
    handler = theHandler;

    cp5=new ControlP5(p);

    mainApplet =p;

    ports = Serial.list();

    cp5.addScrollableList("dropdown")
      .setPosition(visualizationWidth+10, 10)
      .setSize(200, 100)
      .setBarHeight(20)
      .setItemHeight(20)
      .addItems(ports)
      .plugTo(this)
      .setOpen(false)
      ;

    printArray(Serial.list());
  }

  void trigger() {
    println("serial");
  }

  void openSerial(int n) {
    println("connecting to "+ports[n]);
    myPort = new Serial(mainApplet, ports[n], 9600);
    myPort.bufferUntil(lf);
  }

  void closeSerial() {
    myPort.stop();
  }

  void drawInterface() {
  }

  void controlEvent(ControlEvent theEvent) { 
    try {
      myPort.stop();
    }
    catch (Exception e) {
      println("the port was not open yet");
    }
    int selectedPort=(int)theEvent.getController().getValue();
    openSerial(selectedPort);
    fireEvent();
  }


  protected void fireEvent() { 
    val++; // the actuall event.
    println("SerialObj fired an Event.");
    handler.invokeSerialEvent(this);
  }

  String getString() {
    return(inString);
  }
  
  void sendLoudness(int l){
    sendData("L"+l);
  }
  void sendClass(int c){
    println(c);
    sendData("#"+c);
  }
  void sendData(String msg) {
    try {
      myPort.write(msg);
      myPort.write('\n');
    }
    catch (Exception e) {
      //println(e);
    }
  }
  
  void serialEvent(Serial p) { 
  }
}