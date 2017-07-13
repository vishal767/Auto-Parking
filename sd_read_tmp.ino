#include <SPI.h>
#include <SD.h>

File myFile;

void setup()
{
  // Open serial communications and wait for port to open:
  Serial.begin(9600);
  while (!Serial) {
    ; // wait for serial port to connect. Needed for Leonardo only
  }


  Serial.print("Initializing SD card...");

  if (!SD.begin(98)) {
    Serial.println("initialization failed!");
    return;
  }
  Serial.println("initialization done.");

  // re-open the file for reading:
  myFile = SD.open("DATA001.CSV");
  if (myFile) {
    Serial.println("test.txt:");

    // read from the file until there's nothing else in it:
    while (myFile.available()) {
      String a="";
      for(int i=0;i<9;++i)
      {
      int j;
       char temp=myFile.read();
        if(temp!=','&&temp!='\n')
      { //a=temp;
        a+=temp;}
      else if(temp==','||temp=='\n'){
        j=a.toInt();
     // Serial.println(a);
      Serial.println(j);
      break;}
     
        }
      
    }
    // close the file:
    myFile.close();
  } else {
    // if the file didn't open, print an error:
    Serial.println("error opening test.txt");
  }
}

void loop()
{
  // nothing happens after setup
}



