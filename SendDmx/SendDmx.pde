import ddf.minim.*;
import ddf.minim.analysis.*;
import hypermedia.net.*;

import java.awt.Color;

import themidibus.*;

import controlP5.*;

MidiBus myBus;

ControlP5 controlP5;

// network setup
UDP udp; // define the UDP object
int port = 8888; // the destination port    

//String ip       = "192.168.1.178";	// the remote IP address
//String[] ip_addresses = {"192.168.1.178", "192.168.1.177"};
String[] ip_addresses = {"192.168.1.178"};

// assume each power supply has 160 leds
int num_leds = 160 * ip_addresses.length;
byte[] bytes = new byte[num_leds*3];
LED[] leds = new LED[num_leds];

// light show state
int light_show = 0;
int current_default_color = 0;  // 0 = r, 1 = g, 2 = b
int current_r = 255;
int current_g = 0;
int current_b = 0;

// light shows
LightShow[] shows = new LightShow[6];

// fft vars
Minim minim;
AudioInput in;
FFT fft;
float amp = 0.0;
int specSize;
int specHeight = 200;

int show_0_midi = 0;
int show_1_midi = 1;
int show_2_midi = 2;
int show_3_midi = 3;
int show_4_midi = 4;
int show_5_midi = 5;

// variables for midi knobs and p5 controls
float rainbow_speed = 0.01; // rainbow speed
Numberbox rainbow_speed_c;
int rainbow_speed_midi;

float hue1_degree = 0.0; // first hue for modes where color is user controlled
Numberbox hue1_degree_c;
int hue1_degree_midi;

float hue2_degree = 0.5; // second hue for modes where color is user controlled
Numberbox hue2_degree_c;
int hue2_degree_midi;

int fft_band_1 = 10; // second fft band
Numberbox fft_band_1_c;
int fft_band_1_midi;

int fft_band_2 = 100; // first fft band
Numberbox fft_band_2_c;
int fft_band_2_midi;

float filter_1 = 0.3; // how much amplitude is filtered/how bright depending on mode
Numberbox filter_1_c;
int filter_1_midi;

float filter_2 = 0.3; // how much amplitude is filtered/how bright depending on mode
Numberbox filter_2_c;
int filter_2_midi;

float amp_threshold = 0; // amplitude threshold for switching between colors

void setup() {
  // Choose controls for MIDI from properties file
  Properties myProps = new Properties();
  FileInputStream inputStream;
  try {
    inputStream = new FileInputStream(sketchPath("config.properties"));
    myProps.load(inputStream);
    show_0_midi = int(myProps.getProperty("show_0_midi"));
    show_1_midi = int(myProps.getProperty("show_1_midi"));
    show_2_midi = int(myProps.getProperty("show_2_midi"));
    show_3_midi = int(myProps.getProperty("show_3_midi"));
    show_4_midi = int(myProps.getProperty("show_4_midi"));
    show_5_midi = int(myProps.getProperty("show_5_midi"));
    rainbow_speed_midi = int(myProps.getProperty("rainbow_speed_midi"));
    hue1_degree_midi = int(myProps.getProperty("hue1_degree_midi"));
    hue2_degree_midi = int(myProps.getProperty("hue2_degree_midi"));
    fft_band_1_midi = int(myProps.getProperty("fft_band_1_midi"));
    fft_band_2_midi = int(myProps.getProperty("fft_band_2_midi"));
    filter_1_midi = int(myProps.getProperty("filter_1_midi"));
    filter_2_midi = int(myProps.getProperty("filter_2_midi"));
    inputStream.close();
  } catch (IOException e) {
    e.printStackTrace();
  }

  
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 512);
  fft = new FFT(in.bufferSize(), in.sampleRate());
  specSize = fft.specSize();
  
  size(specSize + 60, 250);
  frameRate(30);
  
  controlP5 = new ControlP5(this);  
  rainbow_speed_c = setControl(rainbow_speed_c, "speed", rainbow_speed, 0, 210, 40, 14, 0.0, 1.0, 0.01, 1);
  hue1_degree_c = setControl(hue1_degree_c, "hue1", hue1_degree, 45, 210, 40, 14, 0.0, 1.0, 0.01, 2);
  hue2_degree_c = setControl(hue1_degree_c, "hue2", hue1_degree, 90, 210, 40, 14, 0.0, 1.0, 0.01, 3);
  fft_band_1_c = setControl(fft_band_1_c, "band1", fft_band_1, 135, 210, 40, 14, 0.0, specSize, 1.0, 4);
  fft_band_2_c = setControl(fft_band_2_c, "band2", fft_band_2, 180, 210, 40, 14, 0.0, specSize, 1.0, 5);
  filter_1_c = setControl(filter_1_c, "filter1", filter_1, 225, 210, 40, 14, 0.0, 1.0, 1.0, 6);
  filter_2_c = setControl(filter_2_c, "filter2", filter_2, 270, 210, 40, 14, 0.0, 1.0, 1.0, 7);
  
  udp = new UDP( this, 6000 );  // create a new datagram connection on port 6000
  //udp.log( true ); 		// <-- printout the connection activity
  udp.listen( true );           // and wait for incoming message
  
  for (int i=0; i < num_leds; i++) {
    leds[i] = new LED();
  }
  
  //myBus = new MidiBus(this, "SLIDER/KNOB", "CTRL");
  myBus = new MidiBus(this, 0, 0);
  
  shows[0] = new OffShow(0, 0, 0);
  shows[1] = new SingleColorShow(0, 0, 0);
  shows[2] = new RainbowShow(0, 0, 0);
  shows[3] = new SoundReactiveRainbowShow(0, 0, 0);
  shows[4] = new SoundReactiveSingleHueShow(0, 0, 0);
  shows[5] = new SoundReactiveDoubleHueShow(0, 0, 0);
  //shows[5] = new InterimDescriptorShow(0, 0, 0);
}

void draw()
{
  fill(255);
  shows[light_show].showFrame(current_r, current_g, current_b);
  stroke(255);
  text(shows[light_show].name, 1, 30);

  bytes = getBytes(leds);
  
  byte[] bytesPiece = new byte[480];
  
  for (int i=0; i<ip_addresses.length; i++) {
    arrayCopy(bytes, i*480, bytesPiece, 0, 480);
    udp.send(bytesPiece, ip_addresses[i], port);
  }
}

void stop()
{
  in.close();
  minim.stop();
  super.stop();
}

void keyPressed() 
{
  if (keyCode == LEFT) 
  {
    light_show = mod(light_show - 1, shows.length);
    for (int i=0; i<shows.length; i++) {
      shows[i].resetShow();
    }
  }
  else if (keyCode == RIGHT)
  {
    light_show = mod(light_show + 1, shows.length);
    for (int i=0; i<shows.length; i++) {
      shows[i].resetShow();
    }
  }
  else if (keyCode == DOWN) 
  {
    current_default_color = mod(current_default_color + 1, 3);
    switch(current_default_color) {
      case 0:
        current_r = 255;
        current_g = 0;
        current_b = 0;
        break;
      case 1:
        current_r = 0;
        current_g = 255;
        current_b = 0;
        break;
      case 2:
        current_r = 0;
        current_g = 0;
        current_b = 255;
        break;
    }
  }
  else if (keyCode == UP)
  {
    current_default_color = mod(current_default_color - 1, 3);
    switch(current_default_color) {
      case 0:
        current_r = 255;
        current_g = 0;
        current_b = 0;
        break;
      case 1:
        current_r = 0;
        current_g = 255;
        current_b = 0;
        break;
      case 2:
        current_r = 0;
        current_g = 0;
        current_b = 255;
        break;
    }
  }
}

class LED {
  int r;
  int g;
  int b; 
  
  LED() {
    this.r = 0;
    this.g = 0;
    this.b = 0;
  }
  
  LED(int r, int g, int b) {
    this.r = r;
    this.g = g;
    this.b = b;
  }
}

byte[] getBytes(LED[] leds) {
  for (int i=0; i < num_leds; i++) {
    bytes[i * 3] = byte(leds[i].r);
    bytes[i * 3 + 1] = byte(leds[i].g);
    bytes[i * 3 + 2] = byte(leds[i].b);
  }
  return bytes;
}

class LightShow
{
  int this_r = 0;
  int this_g = 0;
  int this_b = 0;
  String name = "LightShow";
  
  LightShow(int in_r, int in_g, int in_b)
  {
    this_r = in_r;
    this_g = in_g;
    this_b = in_b;
  }
  
  void showFrame(int in_r, int in_g, int in_b) {
  }
  
  void resetShow() {
  }
}

class OffShow extends LightShow
{
  OffShow(int in_r, int in_g, int in_b)
  {
    super(in_r, in_g, in_b);
    name = "Off";
  }
  
  void showFrame(int this_r, int this_g, int this_b) {
    background(0, 0, 0);
    leds[0].r = 0;
    leds[0].g = 0;
    leds[0].b = 0;
  }
  
  void resetShow() {
  }
}

class SingleColorShow extends LightShow
{
  float c_hue = 0.0;
  float c_sat = 1.0;
  float c_bri = 1.0;

  SingleColorShow(int in_r, int in_g, int in_b)
  {
    super(in_r, in_g, in_b);
    name = "Single Color";
  }
  
  void showFrame(int this_r, int this_g, int this_b) {
    background(0, 0, 0);
    // scale brightness
    c_hue = hue1_degree;
    c_bri = filter_1;
    Color sRGB = new Color(Color.HSBtoRGB(c_hue, c_sat, c_bri));
    leds[0].r = sRGB.getRed();
    leds[0].g = sRGB.getGreen();
    leds[0].b = sRGB.getBlue();
    background(leds[0].r, leds[0].g, leds[0].b);
  }
  
  void resetShow() {
  }
}

class SoundReactiveSingleHueShow extends LightShow
{
  float c_hue = 0.0;
  float c_sat = 1.0;
  float c_bri = 1.0;

  SoundReactiveSingleHueShow(int in_r, int in_g, int in_b)
  {
    super(in_r, in_g, in_b);
    name = "Sound Reactive Single Hue";
  }
  
  void showFrame(int this_r, int this_g, int this_b) {
    background(0, 0, 0);
    fft.forward(in.mix);
    
    // scale filter to deal with audio being too loud
    float filter_x = map(filter_1, 0.0, 1.0, 2.0, 100.0);
    // min is because processing doesn't deal with values going outside upper bound well
    amp = map(min(fft.getBand(fft_band_1), filter_x), 0.0, filter_x, 0.0, 1.0);
    c_hue = hue1_degree;
    c_bri = amp;
    Color sRGB = new Color(Color.HSBtoRGB(c_hue, c_sat, c_bri));
    leds[0].r = sRGB.getRed();
    leds[0].g = sRGB.getGreen();
    leds[0].b = sRGB.getBlue();
    background(leds[0].r, leds[0].g, leds[0].b);
    Color hue1_RGB = new Color(Color.HSBtoRGB(hue1_degree, 1.0, 1.0));
    stroke(hue1_RGB.getRed(), hue1_RGB.getGreen(), hue1_RGB.getBlue());
    line(fft_band_1, specHeight, fft_band_1, 0);
    stroke(255);
    for (int i=0; i < fft.specSize(); i++)
    {
      line(i, specHeight, i, specHeight - fft.getBand(i)*4);
    }
  }
  
  void resetShow() {
  }
}

class SoundReactiveDoubleHueShow extends LightShow
{
  float c_hue = 0.0;
  float c_sat = 1.0;
  float c_bri = 1.0;

  SoundReactiveDoubleHueShow(int in_r, int in_g, int in_b)
  {
    super(in_r, in_g, in_b);
    name = "Sound Reactive Double Hue";
  }
  
  void showFrame(int this_r, int this_g, int this_b) {
    background(0, 0, 0);
    fft.forward(in.mix);
    
    // scale filter to deal with audio being too loud
    float filter_x = map(filter_1, 0.0, 1.0, 2.0, 100.0);
    // min is because processing doesn't deal with values going outside upper bound well
    float amp1 = map(min(fft.getBand(fft_band_1), filter_x), 0.0, filter_x, 0.0, 1.0);
    
    // scale filter to deal with audio being too loud
    float filter_y = map(filter_2, 0.0, 1.0, 2.0, 100.0);
    // min is because processing doesn't deal with values going outside upper bound well
    float amp2 = map(min(fft.getBand(fft_band_2), filter_y), 0.0, filter_y, 0.0, 1.0);
    
    if (amp1 > amp2) {
      c_hue = hue1_degree;
      c_bri = amp1;
    }
    else {
      c_hue = hue2_degree;
      c_bri = amp2;
    }
    
    Color sRGB = new Color(Color.HSBtoRGB(c_hue, c_sat, c_bri));
    leds[0].r = sRGB.getRed();
    leds[0].g = sRGB.getGreen();
    leds[0].b = sRGB.getBlue();
    
    background(leds[0].r, leds[0].g, leds[0].b);
    stroke(0, 255, 0);
    Color hue1_RGB = new Color(Color.HSBtoRGB(hue1_degree, 1.0, 1.0));
    stroke(hue1_RGB.getRed(), hue1_RGB.getGreen(), hue1_RGB.getBlue());
    line(fft_band_1, specHeight, fft_band_1, 0);
    stroke(0, 0, 255);
    Color hue2_RGB = new Color(Color.HSBtoRGB(hue2_degree, 1.0, 1.0));
    stroke(hue2_RGB.getRed(), hue2_RGB.getGreen(), hue2_RGB.getBlue());
    line(fft_band_2, specHeight, fft_band_2, 0);
    stroke(255);
    for (int i=0; i < fft.specSize(); i++)
    {
      line(i, specHeight, i, specHeight - fft.getBand(i)*4);
    }
    
  }
  
  void resetShow() {
  }
}

class RainbowShow extends LightShow
{
  float c_hue = 0.0;
  float c_sat = 1.0;
  float c_bri = 1.0;
  float hue_increment = 0.001;
 
  RainbowShow(int in_r, int in_g, int in_b)
  {
    super(in_r, in_g, in_b);
    name = "Rainbow";
  }
  
  void showFrame(int in_r, int in_g, int in_b) {
    // scale brightness of rainbow
    c_bri = filter_1;

    hue_increment = map(rainbow_speed, 0.0, 1.0, 0.0, 0.1);
    c_hue = c_hue + hue_increment;
    Color sRGB = new Color(Color.HSBtoRGB(c_hue, c_sat, c_bri));
    leds[0].r = sRGB.getRed();
    leds[0].g = sRGB.getGreen();
    leds[0].b = sRGB.getBlue();
    
    if (c_hue >= 1.0) {
      c_hue = 0.0;
    }
    background(leds[0].r, leds[0].g, leds[0].b);
  }
}

class SoundReactiveRainbowShow extends LightShow
{
  float c_hue = 0.0;
  float c_sat = 1.0;
  float c_bri = 1.0;
  float hue_increment = 0.001;

  SoundReactiveRainbowShow(int in_r, int in_g, int in_b)
  {
    super(in_r, in_g, in_b);
    name = "Sound Reactive Rainbow";
  }
  
  void showFrame(int this_r, int this_g, int this_b) {
    background(0, 0, 0);
    fft.forward(in.mix);
    
    // scale filter to deal with audio being too loud    
    float filter_x = map(filter_1, 0.0, 1.0, 2.0, 100.0);
    // min is because processing doesn't deal with values going outside upper bound well
    amp = map(min(fft.getBand(fft_band_1), filter_x), 0.0, filter_x, 0.0, 1.0);
    hue_increment = map(rainbow_speed, 0.0, 1.0, 0.0, 0.1);
    c_hue = c_hue + hue_increment;
        
    c_bri = amp;
    Color sRGB = new Color(Color.HSBtoRGB(c_hue, c_sat, c_bri));
    leds[0].r = sRGB.getRed();
    leds[0].g = sRGB.getGreen();
    leds[0].b = sRGB.getBlue();
    
    if (c_hue >= 1.0) {
      c_hue = 0.0;
    }
    background(leds[0].r, leds[0].g, leds[0].b);
    stroke(0, 255, 0);
    line(fft_band_1, specHeight, fft_band_1, 0);
    stroke(255);
    for (int i=0; i < fft.specSize(); i++)
    {
      line(i, specHeight, i, specHeight - fft.getBand(i)*4);
    }
  }
  
  void resetShow() {
  }
}

/*
class InterimDescriptorShow extends LightShow
{
  InterimDescriptorShow(int in_r, int in_g, int in_b)
  {
    super(in_r, in_g, in_b);
    name = "Interim Descriptor";
  }
  
  void showFrame(int this_r, int this_g, int this_b) {
    
    // scale filter to deal with audio being too loud
    float filter_y = map(filter_2, 0.0, 1.0, 2.0, 100.0);
    // min is because processing doesn't deal with values going outside upper bound well
    float amp2 = map(min(fft.getBand(fft_band_2), filter_y), 0.0, filter_y, 0.0, 1.0);    
    
    if (in.mix.level() > amp_threshold) {
      // scale filter to deal with audio being too loud
      float filter_x = map(filter_1, 0.0, 1.0, 0.0, 1.0);
      //print(in.mix.level()+"\n");
      // min is because processing doesn't deal with values going outside upper bound well
      float amp1 = map(min(in.mix.level(), filter_x), 0.0, filter_x, 0.0, 1.0);
      //print(amp1+"\n");
      Color sRGB = new Color(Color.HSBtoRGB(hue1_degree, 1.0, amp));
      leds[0].r = sRGB.getRed();
      leds[0].g = sRGB.getGreen();
      leds[0].b = sRGB.getBlue();
      background(leds[0].r, leds[0].g, leds[0].b);
      //background(255, 0, 0);
    }
    else {
      
      Color sRGB = new Color(Color.HSBtoRGB(hue2_degree, 1.0, 1.0));
      leds[0].r = sRGB.getRed();
      leds[0].g = sRGB.getGreen();
      leds[0].b = sRGB.getBlue();
      background(leds[0].r, leds[0].g, leds[0].b);
      //background(0, 255, 0);
    }

    leds[0].r = 255;
    leds[0].g = 255;
    leds[0].b = 255;
  }
  
  void resetShow() {
  }
}
*/

public int mod(int k, int m)
{
  k = k % m;
  if(k < 0) k+=m;
  return(k);
}

void controllerChange(int channel, int number, int value){
  // knob 1: rainbow speed
  if (number == rainbow_speed_midi) {
    rainbow_speed = map(value, 0.0, 127.0, 0.0, 1.0);
    rainbow_speed_c.setValue(rainbow_speed);
  }
  // knob 2: hue 1 degree
  else if (number == hue1_degree_midi) {
    hue1_degree = map(value, 0.0, 127.0, 0.0, 1.0);
    hue1_degree_c.setValue(hue1_degree);
  }
  // knob 3: hue 2 degree
  else if (number == hue2_degree_midi) {
    hue2_degree = map(value, 0.0, 127.0, 0.0, 1.0);
    hue2_degree_c.setValue(hue2_degree);
  }
  // knob 4: fft band knob for first fft
  else if (number == fft_band_1_midi) {
    fft_band_1 = int(map(value, 0.0, 127.0, 0.0, float(specSize)));
    fft_band_1_c.setValue(fft_band_1);
  }
  // knob 5: fft band knob for second fft
  else if (number == fft_band_2_midi) {
    fft_band_2 = int(map(value, 0.0, 127.0, 0.0, float(specSize)));
    fft_band_2_c.setValue(fft_band_2);
  }
  // knob 6: filter on output from first fft
  else if (number == filter_1_midi) {
    filter_1 = map(value, 0.0, 127.0, 0.0, 1.0);
    filter_1_c.setValue(filter_1);
  }
  // knob 7: filter on output from second fft
  else if (number == filter_2_midi) {
    filter_2 = map(value, 0.0, 127.0, 0.0, 1.0);
    filter_2_c.setValue(filter_2);
  }

  else if (number == show_0_midi) {
    light_show = 0;
    for (int i=0; i<shows.length; i++) {
      shows[i].resetShow();
    }
  }
  else if (number == show_1_midi) {
    light_show = 1;
    for (int i=0; i<shows.length; i++) {
      shows[i].resetShow();
    }      
  }
  else if (number == show_2_midi) {
    light_show = 2;
    for (int i=0; i<shows.length; i++) {
      shows[i].resetShow();
    }
  }
  else if (number == show_3_midi) {
    light_show = 3;
    for (int i=0; i<shows.length; i++) {
      shows[i].resetShow();
    }
  }
  else if (number == show_4_midi) {
    light_show = 4;
    for (int i=0; i<shows.length; i++) {
      shows[i].resetShow();
    }
  }
  else if (number == show_5_midi) {
    light_show = 5;
    for (int i=0; i<shows.length; i++) {
      shows[i].resetShow();
    }
  }
/*
  switch(number) {
    // knob 1: rainbow speed
    case rainbow_speed_midi:
      rainbow_speed = map(value, 0.0, 127.0, 0.0, 1.0);
      rainbow_speed_c.setValue(rainbow_speed);
      break;
    // knob 2: hue 1 degree
    case hue1_degree_midi:
      //hue1_degree = value;
      hue1_degree = map(value, 0.0, 127.0, 0.0, 1.0);
      hue1_degree_c.setValue(hue1_degree);
      break;
    // knob 3: hue 2 degree
    case hue2_degree_midi:
      hue2_degree = map(value, 0.0, 127.0, 0.0, 1.0);
      hue2_degree_c.setValue(hue2_degree);
      break;
    // knob 4: fft band knob for first fft
    case fft_band_1_midi:
      fft_band_1 = int(map(value, 0.0, 127.0, 0.0, float(specSize)));
      fft_band_1_c.setValue(fft_band_1);
      break;
    // knob 5: fft band knob for second fft
    case fft_band_2_midi:
      fft_band_2 = int(map(value, 0.0, 127.0, 0.0, float(specSize)));
      fft_band_2_c.setValue(fft_band_2);
      break;
    // knob 6: filter on output from first fft
    case filter_1_midi:
      filter_1 = map(value, 0.0, 127.0, 0.0, 1.0);
      filter_1_c.setValue(filter_1);
      break;
    // knob 7: filter on output from second fft
    case filter_2_midi:
      filter_2 = map(value, 0.0, 127.0, 0.0, 1.0);
      filter_2_c.setValue(filter_2);
      break;
    // knob 8: amplitude threshold for interim descriptor mode
    //case 84:
    //  amp_threshold = map(value, 0.0, 127.0, 0.0, 1.0);
    //  break;
    case 0:
      light_show = 0;
      for (int i=0; i<shows.length; i++) {
        shows[i].resetShow();
      }
      break;
    case 1:
      light_show = 1;
      for (int i=0; i<shows.length; i++) {
        shows[i].resetShow();
      }      
      break;
    case 2:
      light_show = 2;
      for (int i=0; i<shows.length; i++) {
        shows[i].resetShow();
      }
      break;
    case 3:
      light_show = 3;
      for (int i=0; i<shows.length; i++) {
        shows[i].resetShow();
      }
      break;
    case 4:
      light_show = 4;
      for (int i=0; i<shows.length; i++) {
        shows[i].resetShow();
      }
      break;
    case 5:
      light_show = 5;
      for (int i=0; i<shows.length; i++) {
        shows[i].resetShow();
      }
      break;      
  }
*/
}

void controlEvent(ControlEvent theEvent) {
  //println("got a control event from controller with id "+theEvent.controller().id());
  switch(theEvent.controller().id()) {
    case(1):
      rainbow_speed = (float)(theEvent.controller().value());
      break;
    case(2):
      hue1_degree = (float)(theEvent.controller().value());
      break;
    case(3):
      hue2_degree = (float)(theEvent.controller().value());
      break;
    case(4):
      fft_band_1 = (int)(theEvent.controller().value());
      break;
    case(5):
      fft_band_2 = (int)(theEvent.controller().value());
      break;
    case(6):
      filter_1 = (float)(theEvent.controller().value());
      break;
    case(7):
      filter_2 = (float)(theEvent.controller().value());
      break;
  }
}

Numberbox setControl(Numberbox nb, String name, float val, int x, int y, int w, int h, float mi, float ma, float mul, int id) {
  nb =controlP5.addNumberbox(name,val,x,y,w,h);
  nb.setMin(mi);
  nb.setMax(ma);
  nb.setMultiplier(mul);
  nb.setId(id);
  return nb;
}
