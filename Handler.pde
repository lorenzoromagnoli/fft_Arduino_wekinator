// This class handles the serial-Event
public class Handler {
  private Method serialMethod;
  private Method wekMethod;

  protected Object parent;
  protected PApplet parentSketch;

  public Handler(PApplet parent) { // Object theObject
    this.parent = parent;
    Class myClass = parent.getClass();
    parent.registerMethod("dispose", this);

    try {
      serialMethod = myClass.getDeclaredMethod("serialDataReceived", new Class[] { SerialInterface.class } ); 
      serialMethod.setAccessible(true);
      
      wekMethod = myClass.getDeclaredMethod("wekDataReceived", new Class[] { WekInterface.class } ); 
      wekMethod.setAccessible(true);
    } 
    catch (Exception e) { 
      println(e);
    }
  }

  protected void invokeSerialEvent(SerialInterface event) {
    try {
      serialMethod.invoke( parent, new Object[] { event });
      println("Handler received event from an serialInterface-Object.");
    } 
    catch (Exception e) { 
      println(e);
    }
  }

  protected void invokeWekEvent(WekInterface event) {
    try {
      wekMethod.invoke( parent, new Object[] { event });
      println("Handler received event from an wekInterface-Object.");
    } 
    catch (Exception e) { 
      println(e);
    }
  }

  public void dispose() {  
    System.out.println("Handler says bye.");
  }
}