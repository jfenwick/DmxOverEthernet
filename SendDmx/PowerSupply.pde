public class PowerSupply {
  import hypermedia.net.*;
  UDP udp;
  // Each UDP packet contains a 512 byte DMX universe
  // The first 21 bytes are the absolutely necessary header
  // The others I'm not sure about
  byte[] packet = new byte[536];

  PowerSupply() {  
    udp = new UDP(this, 6038);

    //{4,1,220,74,1,0,1,1,0,0,0,0,0,0,0,0,255,255,255,255,0}
    packet[00] = 0x04;
    packet[01] = 0x01;
    packet[02] = byte(0xdc);
    packet[03] = byte(0x4a);
    packet[04] = 0x01;
    packet[06] = 0x01;
    packet[07] = 0x01;
    
    packet[16] = byte(0xff);
    packet[17] = byte(0xff);
    packet[18] = byte(0xff);
    packet[19] = byte(0xff);
    packet[20] = 0x00;
  }

  void change_all_lights(int red, int green, int blue, String host){
    for (int i = 21; i < 536; i++) {
      switch (i % 3) {
        case 0:
          packet[i] = byte(red);
          break;
        case 1:
          packet[i] = byte(green);
          break;
        case 2:
          packet[i] = byte(blue);
          break;
      }
    }
    udp.send(packet, host);
  }
}
