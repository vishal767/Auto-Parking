
import processing.serial.*;
import processing.opengl.*;
import toxi.geom.*;
import toxi.processing.*;
import org.eclipse.paho.client.mqttv3.*;
import org.eclipse.paho.client.mqttv3.persist.MemoryPersistence;



ToxiclibsSupport gfx;

Serial port;                         // The serial port
char[] teapotPacket = new char[14];  // InvenSense Teapot packet
int serialCount = 0;                 // current packet byte position
int synced = 0;
int interval = 0;

float[] q = new float[4];
Quaternion quat = new Quaternion(1, 0, 0, 0);

float[] gravity = new float[3];
float[] euler = new float[3];
float[] ypr = new float[3];
String topic        = "sensorData";
String content      = "Hello CloudMQTT";
int qos             = 1;
String broker       = "tcp://m13.cloudmqtt.com:18056";
String clientId     = "ClientId";
MemoryPersistence persistence = new MemoryPersistence();
MqttMessage message = new MqttMessage(content.getBytes());

MqttClient  mqttClient;

void setup() {
  try {
    println("Entered");
    mqttClient = new MqttClient(broker, clientId, persistence);
    mqttClient.setCallback(new MqttCallback() {
      public void messageArrived(String topic, MqttMessage msg)
        throws Exception {
        interval = millis();
        println("Received:" + new String(msg.getPayload()));
        String[] data = new String(msg.getPayload()).split(";");
        float[] qvalue = new float[data.length];
        for (int i = 0; i < data.length; ++i) {
          qvalue[i] = Float.parseFloat(data[i]);
        }
        quat.set(qvalue[0], qvalue[1], qvalue[2], qvalue[3]);
      }

      public void deliveryComplete(IMqttDeliveryToken arg0) {
        println("Delivery complete");
      }

      public void connectionLost(Throwable arg0) {
        // TODO Auto-generated method stub
      }
    }
    );
    MqttConnectOptions connOpts = new MqttConnectOptions();
    connOpts.setCleanSession(true);
    connOpts.setUserName("gbnducye");
    connOpts.setPassword(new char[]{'r', 'A', 'J', '1', 'c', '9', '6', 'N', 'B', 't', 'j', 'l'});
    mqttClient.connect(connOpts);
    message.setQos(qos);     
    mqttClient.subscribe(topic, qos);
    //mqttClient.publish(topic, message);
    // client.unsubscribe("/example");
  }

  catch(MqttException me) {
    System.out.println("reason "+me.getReasonCode());
    System.out.println("msg "+me.getMessage());
    System.out.println("loc "+me.getLocalizedMessage());
    System.out.println("cause "+me.getCause());
    System.out.println("excep "+me);
    me.printStackTrace();
  }
  // 300px square viewport using OpenGL rendering
  size(300, 300, OPENGL);
  gfx = new ToxiclibsSupport(this);

  // setup lights and antialiasing
  lights();
  smooth();

 
}

void draw() {
  //println("Entered");
  if (millis() - interval > 1000) {
    // resend single character to trigger DMP init/start
    // in case the MPU is halted/reset while applet is running
    //port.write('r');
    interval = millis();
  }

  // black background
  background(6);

  // translate everything to the middle of the viewport
  pushMatrix();
  translate(width / 2, height / 2);

  
  float[] axis = quat.toAxisAngle();
  rotate(axis[0], -axis[1], axis[3], axis[2]);

  // draw main body in red
  fill(255, 0, 0, 200);
  box(10, 10, 200);

  // draw front-facing tip in blue
  fill(0, 0, 255, 200);
  pushMatrix();
  translate(0, 0, -120);
  rotateX(PI/2);
  drawCylinder(0, 20, 20, 8);
  popMatrix();

  // draw wings and tail fin in green
  fill(0, 255, 0, 200);
  beginShape(TRIANGLES);
  vertex(-100, 2, 30); 
  vertex(0, 2, -80); 
  vertex(100, 2, 30);  // wing top layer
  vertex(-100, -2, 30); 
  vertex(0, -2, -80); 
  vertex(100, -2, 30);  // wing bottom layer
  vertex(-2, 0, 98); 
  vertex(-2, -30, 98); 
  vertex(-2, 0, 70);  // tail left layer
  vertex( 2, 0, 98); 
  vertex( 2, -30, 98); 
  vertex( 2, 0, 70);  // tail right layer
  endShape();
  beginShape(QUADS);
  vertex(-100, 2, 30); 
  vertex(-100, -2, 30); 
  vertex(  0, -2, -80); 
  vertex(  0, 2, -80);
  vertex( 100, 2, 30); 
  vertex( 100, -2, 30); 
  vertex(  0, -2, -80); 
  vertex(  0, 2, -80);
  vertex(-100, 2, 30); 
  vertex(-100, -2, 30); 
  vertex(100, -2, 30); 
  vertex(100, 2, 30);
  vertex(-2, 0, 98); 
  vertex(2, 0, 98); 
  vertex(2, -30, 98); 
  vertex(-2, -30, 98);
  vertex(-2, 0, 98); 
  vertex(2, 0, 98); 
  vertex(2, 0, 70); 
  vertex(-2, 0, 70);
  vertex(-2, -30, 98); 
  vertex(2, -30, 98); 
  vertex(2, 0, 70); 
  vertex(-2, 0, 70);
  endShape();

  popMatrix();
}

//void serialEvent(Serial port) {
//  interval = millis();
//  while (port.available() > 0) {
//    int ch = port.read();

//    if (synced == 0 && ch != '$') return;   // initial synchronization - also used to resync/realign if needed
//    synced = 1;
//    print ((char)ch);

//    if ((serialCount == 1 && ch != 2)
//      || (serialCount == 12 && ch != '\r')
//      || (serialCount == 13 && ch != '\n')) {
//      serialCount = 0;
//      synced = 0;
//      return;
//    }

//    if (serialCount > 0 || ch == '$') {
//      teapotPacket[serialCount++] = (char)ch;
//      if (serialCount == 14) {
//        serialCount = 0; // restart packet byte position

//        // get quaternion from data packet
//        q[0] = ((teapotPacket[2] << 8) | teapotPacket[3]) / 16384.0f;
//        q[1] = ((teapotPacket[4] << 8) | teapotPacket[5]) / 16384.0f;
//        q[2] = ((teapotPacket[6] << 8) | teapotPacket[7]) / 16384.0f;
//        q[3] = ((teapotPacket[8] << 8) | teapotPacket[9]) / 16384.0f;
//        for (int i = 0; i < 4; i++) if (q[i] >= 2) q[i] = -4 + q[i];

//        // set our toxilibs quaternion to new data
//        quat.set(q[0], q[1], q[2], q[3]);

//        /*
//                // below calculations unnecessary for orientation only using toxilibs

//         // calculate gravity vector
//         gravity[0] = 2 * (q[1]*q[3] - q[0]*q[2]);
//         gravity[1] = 2 * (q[0]*q[1] + q[2]*q[3]);
//         gravity[2] = q[0]*q[0] - q[1]*q[1] - q[2]*q[2] + q[3]*q[3];

//         // calculate Euler angles
//         euler[0] = atan2(2*q[1]*q[2] - 2*q[0]*q[3], 2*q[0]*q[0] + 2*q[1]*q[1] - 1);
//         euler[1] = -asin(2*q[1]*q[3] + 2*q[0]*q[2]);
//         euler[2] = atan2(2*q[2]*q[3] - 2*q[0]*q[1], 2*q[0]*q[0] + 2*q[3]*q[3] - 1);

//         // calculate yaw/pitch/roll angles
//         ypr[0] = atan2(2*q[1]*q[2] - 2*q[0]*q[3], 2*q[0]*q[0] + 2*q[1]*q[1] - 1);
//         ypr[1] = atan(gravity[0] / sqrt(gravity[1]*gravity[1] + gravity[2]*gravity[2]));
//         ypr[2] = atan(gravity[1] / sqrt(gravity[0]*gravity[0] + gravity[2]*gravity[2]));

//         // output various components for debugging
//         //println("q:\t" + round(q[0]*100.0f)/100.0f + "\t" + round(q[1]*100.0f)/100.0f + "\t" + round(q[2]*100.0f)/100.0f + "\t" + round(q[3]*100.0f)/100.0f);
//         //println("euler:\t" + euler[0]*180.0f/PI + "\t" + euler[1]*180.0f/PI + "\t" + euler[2]*180.0f/PI);
//         //println("ypr:\t" + ypr[0]*180.0f/PI + "\t" + ypr[1]*180.0f/PI + "\t" + ypr[2]*180.0f/PI);
//         */
//      }
//    }
//  }
//}

void drawCylinder(float topRadius, float bottomRadius, float tall, int sides) {
  float angle = 0;
  float angleIncrement = TWO_PI / sides;
  beginShape(QUAD_STRIP);
  for (int i = 0; i < sides + 1; ++i) {
    vertex(topRadius*cos(angle), 0, topRadius*sin(angle));
    vertex(bottomRadius*cos(angle), tall, bottomRadius*sin(angle));
    angle += angleIncrement;
  }
  endShape();

  // If it is not a cone, draw the circular top cap
  if (topRadius != 0) {
    angle = 0;
    beginShape(TRIANGLE_FAN);

    // Center point
    vertex(0, 0, 0);
    for (int i = 0; i < sides + 1; i++) {
      vertex(topRadius * cos(angle), 0, topRadius * sin(angle));
      angle += angleIncrement;
    }
    endShape();
  }

  // If it is not a cone, draw the circular bottom cap
  if (bottomRadius != 0) {
    angle = 0;
    beginShape(TRIANGLE_FAN);

    // Center point
    vertex(0, tall, 0);
    for (int i = 0; i < sides + 1; i++) {
      vertex(bottomRadius * cos(angle), tall, bottomRadius * sin(angle));
      angle += angleIncrement;
    }
    endShape();
  }
}