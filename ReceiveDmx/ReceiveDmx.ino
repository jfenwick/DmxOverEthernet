/* Welcome to DmxSimple. This library allows you to control DMX stage and
 ** architectural lighting and visual effects easily from Arduino. DmxSimple
 ** is compatible with the Tinker.it! DMX shield and all known DIY Arduino
 ** DMX control circuits.
 **
 ** DmxSimple is available from: http://code.google.com/p/tinkerit/
 ** Help and support: http://groups.google.com/group/dmxsimple       */

/* To use DmxSimple, you will need the following line. Arduino will
 ** auto-insert it if you select Sketch > Import Library > DmxSimple. */

#include <DmxSimple.h>

/*
  UDPSendReceive.pde:
 This sketch receives UDP message strings, prints them to the serial port
 and sends an "acknowledge" string back to the sender
 
 A Processing sketch is included at the end of file that can be used to send 
 and received messages for testing with a computer.
 
 created 21 Aug 2010
 by Michael Margolis
 
 This code is in the public domain.
 */


#include <SPI.h>         // needed for Arduino versions later than 0018
#include <Ethernet.h>
#include <EthernetUdp.h>         // UDP library from: bjoern@cs.stanford.edu 12/30/2008

// Enter a MAC address and IP address for your controller below.
// The IP address will be dependent on your local network:
//byte mac[] = {  
//  0xDE, 0xAD, 0xBE, 0xEF, 0xFE, 0xED };
byte mac[] = {  
  0xDE, 0xAB, 0xBE, 0xEF, 0xFE, 0xED };
IPAddress ip(192, 168, 0, 178);

unsigned int localPort = 8888;      // local port to listen on

EthernetUDP Udp;

char vals[480]; //buffer to hold incoming packet

void setup() {
  /* The most common pin for DMX output is pin 3, which DmxSimple
   ** uses by default. If you need to change that, do it here. */
  DmxSimple.usePin(3);

  /* DMX devices typically need to receive a complete set of channels
   ** even if you only need to adjust the first channel. You can
   ** easily change the number of channels sent here. If you don't
   ** do this, DmxSimple will set the maximum channel number to the
   ** highest channel you DmxSimple.write() to. */
  DmxSimple.maxChannel(4);

  // start the Ethernet and UDP:
  Ethernet.begin(mac,ip);
  Udp.begin(localPort);
}

void loop() {
  // if there's data available, read a packet
  int packetSize = Udp.parsePacket();
  if(packetSize)
  {
    //Serial.print("Received packet of size ");
    //Serial.println(packetSize);

    // read the packet into packetBufffer and get the senders IP addr and port number
    //Udp.readPacket(packetBuffer,UDP_TX_PACKET_MAX_SIZE, remoteIp, remotePort);
    //Udp.readPacket(packetBuffer,480, remoteIp, remotePort);
    Udp.read(vals,480);
  }

  for (int i=0; i<480; i++)
  {
    DmxSimple.write(i + 1, vals[i]);
  }  
  
  //int brightness;
  /* Simple loop to ramp up brightness */
  //for (brightness = 0; brightness <= 255; brightness++) {

  /* Update DMX channel 1 to new brightness */
  //  DmxSimple.write(1, brightness);
  //  DmxSimple.write(2, brightness);

  /* Small delay to slow down the ramping */
  //  delay(10);
  //}

}

