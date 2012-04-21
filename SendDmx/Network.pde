import hypermedia.net.*;

UDP udp; // define the UDP object  
ArrayList endpoints_list = new ArrayList();
Endpoint[] endpoints;


void setupNetwork() {
  udp = new UDP( this );  // create a new datagram connection
  //udp.log( true ); 		// <-- printout the connection activity
  udp.listen( true );           // and wait for incoming message
}

public abstract class Endpoint {
  String ip;
  int port;
  int num_leds;
  int start_index;
  
  void sendPacket() {
  }
}

public class Pds150Endpoint extends Endpoint {
  public byte[] header = new byte[21];
  
  Pds150Endpoint(String ip) {
    this.ip = ip;
    port = 6038;
    num_leds = 510; //FIXME: looks like number of channels
    this.start_index = total_num_leds;
    total_num_leds += num_leds; //FIXME: but here we're adding what should be channels/3
    
    //{4,1,220,74,1,0,1,1,0,0,0,0,0,0,0,0,255,255,255,255,0}
    header[00] = 0x04;
    header[01] = 0x01;
    header[02] = byte(0xdc);
    header[03] = byte(0x4a);
    header[04] = 0x01;
    header[06] = 0x01;
    header[07] = 0x01;
    
    header[16] = byte(0xff);
    header[17] = byte(0xff);
    header[18] = byte(0xff);
    header[19] = byte(0xff);
    header[20] = 0x00;
  }
    
  byte[] getBytes(LED[] leds) {
    //FIXME: here the iteration treats it like it's channels
    for (int i=start_index; i < (start_index + num_leds/3); i++) {
      bytes[i * 3] = byte(leds[i].r);
      bytes[i * 3 + 1] = byte(leds[i].g);
      bytes[i * 3 + 2] = byte(leds[i].b);
    }
    return bytes;
  }

  void sendPacket() {
    bytes = getBytes(leds);
    byte[] bytesPiece = new byte[num_leds+header.length]; //FIXME: channels
    arrayCopy(header, 0, bytesPiece, 0, header.length);
    // arraycopy(Object src, int srcPos, Object dest, int destPos, int length)
    arrayCopy(bytes, 0, bytesPiece, header.length, num_leds); //FIXME: channels
    udp.send(bytesPiece, ip, port);
  }
}

public class Ws2801Endpoint extends Endpoint {  
  Ws2801Endpoint(String ip) {
    this.ip = ip;
    port = 8888;
    num_leds = 480;
    this.start_index = total_num_leds;
    total_num_leds += num_leds;
  }
  
  byte[] getBytes(LED[] leds) {
    for (int i=start_index; i < (start_index + num_leds/3); i++) {
      bytes[i * 3] = byte(leds[i].b);
      bytes[i * 3 + 1] = byte(leds[i].g);
      bytes[i * 3 + 2] = byte(leds[i].r);
    }
    return bytes;
  }

  void sendPacket() {
    bytes = getBytes(leds);
    byte[] bytesPiece = new byte[num_leds];
    arrayCopy(bytes, 0, bytesPiece, 0, num_leds);
    udp.send(bytesPiece, ip, port);
  }
}

public class DmxEndpoint extends Endpoint { 
  DmxEndpoint(String ip, int start_index) {
    this.ip = ip;
    port = 8888;
    num_leds = 510;
    this.start_index = total_num_leds;
    total_num_leds += num_leds;
  }
  
  byte[] getBytes(LED[] leds) {
    for (int i=start_index; i < (start_index + num_leds/3); i++) {
      bytes[i * 3] = byte(leds[i].b);
      bytes[i * 3 + 1] = byte(leds[i].g);
      bytes[i * 3 + 2] = byte(leds[i].r);
    }
    return bytes;
  }

  void sendPacket() {
    bytes = getBytes(leds);
    byte[] bytesPiece = new byte[num_leds];
    arrayCopy(bytes, 0, bytesPiece, 0, num_leds);
    udp.send(bytesPiece, ip, port);
  }
}
