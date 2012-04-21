import java.awt.Color;

ArrayList shows_list = new ArrayList();
LightShow[] shows;

// global light show state
int light_show = 0;
int current_default_color = 0;  // 0 = r, 1 = g, 2 = b
int current_r = 255;
int current_g = 0;
int current_b = 0;


abstract class LightShow
{
  int c_r = 0;
  int c_g = 0;
  int c_b = 0;
  String name = "LightShow";

  LightShow(int c_r, int c_g, int c_b)
  {
    this.c_r = c_r;
    this.c_g = c_g;
    this.c_b = c_b;
  }

  void showFrame(int c_r, int c_g, int c_b) {
  }

  void resetShow() {
  }
}

class OffShow extends LightShow
{
  OffShow(int c_r, int c_g, int c_b)
  {
    super(c_r, c_g, c_b);
    name = "Off";
  }

  void showFrame(int c_r, int c_g, int c_b) {
    background(0, 0, 0);
    for (int i=0; i<total_num_leds; i++) {
      leds[i].r = 0;
      leds[i].g = 0;
      leds[i].b = 0;
    }
  }

  void resetShow() {
  }
}

class SingleColorShow extends LightShow
{
  float c_hue = 0.0;
  float c_sat = 1.0;
  float c_bri = 1.0;

  SingleColorShow(int c_r, int c_g, int c_b)
  {
    super(c_r, c_g, c_b);
    name = "Single Color";
  }

  void showFrame(int c_r, int c_g, int c_b) {
    background(0, 0, 0);
    // scale brightness
    c_hue = hue1_degree;
    c_bri = filter_1;
    Color sRGB = new Color(Color.HSBtoRGB(c_hue, c_sat, c_bri));
    for (int i=0; i<total_num_leds; i++) {
      leds[i].r = sRGB.getRed();
      leds[i].g = sRGB.getGreen();
      leds[i].b = sRGB.getBlue();
    }
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

  SoundReactiveSingleHueShow(int c_r, int c_g, int c_b)
  {
    super(c_r, c_g, c_b);
    name = "Sound Reactive Single Hue";
  }

  void showFrame(int c_r, int c_g, int c_b) {
    background(0, 0, 0);
    fft.forward(in.mix);

    // scale filter to deal with audio being too loud
    // note: max and min are inverted
    float filter_x = map(filter_1, 1.0, 0.0, 2.0, 100.0);
    // min is because processing doesn't deal with values going outside upper bound well
    amp = map(min(fft.getBand(fft_band_1), filter_x), 0.0, filter_x, 0.0, 1.0);
    c_hue = hue1_degree;
    c_bri = amp;
    Color sRGB = new Color(Color.HSBtoRGB(c_hue, c_sat, c_bri));
    for (int i=0; i<total_num_leds; i++) {
      leds[i].r = sRGB.getRed();
      leds[i].g = sRGB.getGreen();
      leds[i].b = sRGB.getBlue();
    }
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

  SoundReactiveDoubleHueShow(int c_r, int c_g, int c_b)
  {
    super(c_r, c_g, c_b);
    name = "Sound Reactive Double Hue";
  }

  void showFrame(int c_r, int c_g, int c_b) {
    background(0, 0, 0);
    fft.forward(in.mix);

    // scale filter to deal with audio being too loud
    // note: max and min are inverted
    float filter_x = map(filter_1, 1.0, 0.0, 2.0, 100.0);
    // min is because processing doesn't deal with values going outside upper bound well
    float amp1 = map(min(fft.getBand(fft_band_1), filter_x), 0.0, filter_x, 0.0, 1.0);

    // scale filter to deal with audio being too loud
    // note: max and min are inverted
    float filter_y = map(filter_2, 1.0, 0.0, 2.0, 100.0);
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
    for (int i=0; i<total_num_leds; i++) {
      leds[i].r = sRGB.getRed();
      leds[i].g = sRGB.getGreen();
      leds[i].b = sRGB.getBlue();
    }
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

  RainbowShow(int c_r, int c_g, int c_b)
  {
    super(c_r, c_g, c_b);
    name = "Rainbow";
  }

  void showFrame(int c_r, int c_g, int c_b) {
    // scale brightness of rainbow
    c_bri = filter_1;

    hue_increment = map(rainbow_speed, 0.0, 1.0, 0.0, 0.1);
    c_hue = c_hue + hue_increment;
    Color sRGB = new Color(Color.HSBtoRGB(c_hue, c_sat, c_bri));
    for (int i=0; i<total_num_leds; i++) {
      leds[i].r = sRGB.getRed();
      leds[i].g = sRGB.getGreen();
      leds[i].b = sRGB.getBlue();
    }
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

  SoundReactiveRainbowShow(int c_r, int c_g, int c_b)
  {
    super(c_r, c_g, c_b);
    name = "Sound Reactive Rainbow";
  }

  void showFrame(int c_r, int c_g, int c_b) {
    background(0, 0, 0);
    fft.forward(in.mix);

    // scale filter to deal with audio being too loud
    // note: max and min are inverted    
    float filter_x = map(filter_1, 1.0, 0.0, 2.0, 100.0);
    // min is because processing doesn't deal with values going outside upper bound well
    amp = map(min(fft.getBand(fft_band_1), filter_x), 0.0, filter_x, 0.0, 1.0);
    hue_increment = map(rainbow_speed, 0.0, 1.0, 0.0, 0.1);
    c_hue = c_hue + hue_increment;

    c_bri = amp;
    Color sRGB = new Color(Color.HSBtoRGB(c_hue, c_sat, c_bri));
    for (int i=0; i<total_num_leds; i++) {
      leds[i].r = sRGB.getRed();
      leds[i].g = sRGB.getGreen();
      leds[i].b = sRGB.getBlue();
    }
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
 InterimDescriptorShow(int c_r, int c_g, int c_b)
 {
 super(c_r, c_g, c_b);
 name = "Interim Descriptor";
 }
 
 void showFrame(int c_r, int c_g, int c_b) {
 
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
