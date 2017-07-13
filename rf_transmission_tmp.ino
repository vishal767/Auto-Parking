#include <ServoTimer2.h>

#include <VirtualWire.h>   
//#include <Servo.h>
ServoTimer2 myservo;
#undef int
#undef abs
#undef double
#undef float
#undef round
//int pos = 0;  
void setup()
{
    Serial.begin(9600); 
      myservo.attach(9);  
      myservo.write(80);  

// Initialise the IO and ISR
    vw_set_ptt_inverted(true);    // Required for RX Link Module
    vw_setup(2000);                   // Bits per sec
    vw_set_rx_pin(7);           // We will be receiving on pin 4 i.e the RX pin from the module connects to this pin. 
    vw_rx_start();                      // Start the receiver 
}

void loop()
{
    uint8_t buf[VW_MAX_MESSAGE_LEN];
    uint8_t buflen = VW_MAX_MESSAGE_LEN;

    if (vw_get_message(buf, &buflen)) // check to see if anything has been received
    {int i;
    String str="";
  for (i = 0; i < buflen; i++)
  {
      //Serial.print((char)buf[i]);
     str += (char)buf[i];
      //Serial.print(' ');
  }
 int val=str.toInt();
  Serial.println(val);
        myservo.write(-val+90);
        delay(15);
    /*for (i = 0; i < buflen; i++)
    {
       // Serial.print((char)buf[i]);                     // the received data is stored in buffer
        }
   // Serial.println("");*/
     }
}

