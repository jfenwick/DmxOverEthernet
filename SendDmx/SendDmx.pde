int total_num_leds = 0; // LED is made up of three channels
byte[] bytes; // three times the number of LEDs
LED[] leds;

// variables for parameters
float rainbow_speed = 0.01; // rainbow speed
float hue1_degree = 0.0; // first hue for modes where color is user controlled
float hue2_degree = 0.5; // second hue for modes where color is user controlled
int fft_band_1 = 10; // second fft band
int fft_band_2 = 100; // first fft band
float filter_1 = 0.3; // how much amplitude is filtered/how bright depending on mode
float filter_2 = 0.3; // how much amplitude is filtered/how bright depending on mode

float amp_threshold = 0; // amplitude threshold for switching between colors

void setup() {
  // add endpoints
  Endpoint next_supply;
  endpoints_list.add(new Pds150Endpoint("192.168.15.217"));
  endpoints_list.add(new Pds150Endpoint("192.168.15.218"));
  
  endpoints = new Endpoint[endpoints_list.size()];
  endpoints = (Endpoint[])endpoints_list.toArray(endpoints);
  
  bytes = new byte[total_num_leds*3];
  leds = new LED[total_num_leds];
  setupMidi();
  setupAudio();
  setupUI();
  setupNetwork();

  size(specSize + 60, 250);
  frameRate(30);

  for (int i=0; i < total_num_leds; i++) {
    leds[i] = new LED();
  }

  // add the shows
  shows_list.add(new OffShow(0, 0, 0));
  shows_list.add(new SingleColorShow(0, 0, 0));
  shows_list.add(new RainbowShow(0, 0, 0));
  shows_list.add(new SoundReactiveRainbowShow(0, 0, 0));
  shows_list.add(new SoundReactiveSingleHueShow(0, 0, 0));
  shows_list.add(new SoundReactiveDoubleHueShow(0, 0, 0));

  // convert array list to regular array for ease of use
  shows = new LightShow[shows_list.size()];
  shows = (LightShow[])shows_list.toArray(shows);
}

void draw()
{
  fill(255);
  // update led array with next step of current show
  shows[light_show].showFrame(current_r, current_g, current_b);
  stroke(255);
  text(shows[light_show].name, 1, 30);

  for (int i=0; i<endpoints.length; i++) {
    endpoints[i].sendPacket();
  }
}

void stop()
{
  stopAudio();
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

public int mod(int k, int m)
{
  k = k % m;
  if (k < 0) k+=m;
  return(k);
}
