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
  void resetShow() {
    c_hue = 0.0;
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

class StripChase extends LightShow
{
  float c_hue = 0.0;
  float c_sat = 1.0;
  float c_bri = 1.0;
  
  int active_led = 0;
  StripChase(int c_r, int c_g, int c_b)
  {
    super(c_r, c_g, c_b);
    name = "StripChase";
  }

  void showFrame(int c_r, int c_g, int c_b) {
    background(0, 0, 0);
    
    for (int i=0; i<leds.length; i++) {
      leds[i].r = 0;
      leds[i].g = 0;
      leds[i].b = 0;
    }

    if (active_led == leds.length) {
      active_led = 0;
      current_time = 0;
    }

    // scale brightness
    c_hue = hue1_degree;
    c_bri = filter_1;
    Color sRGB = new Color(Color.HSBtoRGB(c_hue, c_sat, c_bri));
    leds[active_led].r = sRGB.getRed();
    leds[active_led].g = sRGB.getGreen();
    leds[active_led].b = sRGB.getBlue();

    active_led++;
  }

  void resetShow() {
    //current_time = 0;
  }
}

class Chase extends LightShow
{
  float c_hue = 0.0;
  float c_sat = 1.0;
  float c_bri = 1.0;
  
  //int current_time = 0;
  int[] used_leds = {0, 1, 2, 170, 171, 172, 340, 341, 510, 511};
  //int[] used_leds_reverse = reverse(used_leds);
  int active_led = 0;
  Chase(int c_r, int c_g, int c_b)
  {
    super(c_r, c_g, c_b);
    name = "Chase";
  }

  void showFrame(int c_r, int c_g, int c_b) {
    background(0, 0, 0);
    
    for (int i=0; i<used_leds.length; i++) {
      leds[used_leds[i]].r = 0;
      leds[used_leds[i]].g = 0;
      leds[used_leds[i]].b = 0;
    }

    active_led = int(current_time / chase_time_step);    
    if (reverse_chase) {
      if (active_led < 0) {
        active_led = used_leds.length - 1;
        current_time = int(chase_time_step*used_leds.length);
      }
    }
    else {
      if (active_led == used_leds.length) {
        active_led = 0;
        current_time = 0;
      }
    }

    // scale brightness
    c_hue = hue1_degree;
    c_bri = filter_1;
    Color sRGB = new Color(Color.HSBtoRGB(c_hue, c_sat, c_bri));
    leds[used_leds[active_led]].r = sRGB.getRed();
    leds[used_leds[active_led]].g = sRGB.getGreen();
    leds[used_leds[active_led]].b = sRGB.getBlue();

    if (reverse_chase) {
      current_time -= 1;
    }
    else {
      current_time += 1;
    }
  }

  void resetShow() {
    //current_time = 0;
    reverse_chase = false;
  }
}

class RedChase extends LightShow
{
  float c_hue = 0.0;
  float c_sat = 1.0;
  float c_bri = 1.0;
  
  //int current_time = 0;
  int[] used_leds = {0, 1, 2, 170, 171, 172, 340, 341, 510, 511};
  //int[] used_leds_reverse = reverse(used_leds);
  int active_led = 0;
  RedChase(int c_r, int c_g, int c_b)
  {
    super(c_r, c_g, c_b);
    name = "RedChase";
  }

  void showFrame(int c_r, int c_g, int c_b) {
    background(0, 0, 0);
    
    for (int i=0; i<used_leds.length; i++) {
      leds[used_leds[i]].r = 0;
      leds[used_leds[i]].g = 0;
      leds[used_leds[i]].b = 0;
    }

    active_led = int(current_time / chase_time_step);    
    if (reverse_chase) {
      if (active_led < 0) {
        active_led = used_leds.length - 1;
        current_time = int(chase_time_step*used_leds.length);
      }
    }
    else {
      if (active_led == used_leds.length) {
        active_led = 0;
        current_time = 0;
      }
    }

    // scale brightness
    //c_hue = hue1_degree;
    c_bri = filter_1;
    Color sRGB = new Color(Color.HSBtoRGB(c_hue, c_sat, c_bri));
    leds[used_leds[active_led]].r = sRGB.getRed();
    leds[used_leds[active_led]].g = sRGB.getGreen();
    leds[used_leds[active_led]].b = sRGB.getBlue();

    if (reverse_chase) {
      current_time -= 1;
    }
    else {
      current_time += 1;
    }
  }

  void resetShow() {
    //current_time = 0;
    reverse_chase = false;
  }
}

class RainbowChase extends LightShow
{
  float c_hue = 0.0;
  float c_sat = 1.0;
  float c_bri = 1.0;
  float hue_increment = 0.001;
  
  //int current_time = 0;
  int[] used_leds = {0, 1, 2, 170, 171, 172, 340, 341, 510, 511};

  int active_led = 0;
  RainbowChase(int c_r, int c_g, int c_b)
  {
    super(c_r, c_g, c_b);
    name = "Rainbow Chase";
  }

  void showFrame(int c_r, int c_g, int c_b) {
    background(0, 0, 0);
    
    for (int i=0; i<used_leds.length; i++) {
      leds[used_leds[i]].r = 0;
      leds[used_leds[i]].g = 0;
      leds[used_leds[i]].b = 0;
    }
    
    active_led = int(current_time / chase_time_step);    
    if (reverse_chase) {
      if (active_led < 0) {
        active_led = used_leds.length - 1;
        current_time = int(chase_time_step*used_leds.length);
      }
    }
    else {
      if (active_led == used_leds.length) {
        active_led = 0;
        current_time = 0;
      }
    }
    
    // scale brightness
    c_bri = filter_1;
    hue_increment = map(rainbow_speed, 0.0, 1.0, 0.0, 0.1);
    c_hue = c_hue + hue_increment;
    Color sRGB = new Color(Color.HSBtoRGB(c_hue, c_sat, c_bri));
    if (active_led >= used_leds.length) {
      active_led = used_leds.length - 1;
    }
    leds[used_leds[active_led]].r = sRGB.getRed();
    leds[used_leds[active_led]].g = sRGB.getGreen();
    leds[used_leds[active_led]].b = sRGB.getBlue();

    if (reverse_chase) {
      current_time -= 1;
    }
    else {
      current_time += 1;
    }
    
    if (c_hue >= 1.0) {
      c_hue = 0.0;
    }
  }

  void resetShow() {
    //current_time = 0;
    reverse_chase = false;
    //c_hue = 0.0;
    rainbow_speed = 0.01;
  }
}

class ProgressBar extends LightShow
{
  float c_hue = 0.0;
  float c_sat = 1.0;
  float c_bri = 1.0;
  
  boolean progress_reverse = false;
  
  //int current_time = 0;
  int[] used_leds = {0, 1, 2, 170, 171, 172, 340, 341, 510, 511};
  //int[] used_leds_reverse = reverse(used_leds);
  int active_led = 0;
  ProgressBar(int c_r, int c_g, int c_b)
  {
    super(c_r, c_g, c_b);
    name = "Progress Bar";
  }

  void showFrame(int c_r, int c_g, int c_b) {
    background(0, 0, 0);

    active_led = int(current_time / chase_time_step);    
    if (progress_reverse) {
      if (active_led == 0) {
        active_led = 0;
        progress_reverse = false;
      }
    }
    else {
      if (active_led == used_leds.length) {
        active_led -= 1;
        progress_reverse = true;
      }
    }

    // scale brightness
    c_hue = hue1_degree;
    c_bri = filter_1;
    Color sRGB = new Color(Color.HSBtoRGB(c_hue, c_sat, c_bri));

    // FIXME: trying to deal with weird bug that crops up when at edges of side
    if (active_led >= used_leds.length) {
      active_led = used_leds.length -1;
    }
    if (progress_reverse) {
      leds[used_leds[active_led]].r = 0;
      leds[used_leds[active_led]].g = 0;
      leds[used_leds[active_led]].b = 0;
    }
    else {
      leds[used_leds[active_led]].r = sRGB.getRed();
      leds[used_leds[active_led]].g = sRGB.getGreen();
      leds[used_leds[active_led]].b = sRGB.getBlue();
    }


    if (progress_reverse) {
      current_time -= 1;
    }
    else {
      current_time += 1;
    }
  }

  void resetShow() {
    //current_time = 0;
    progress_reverse = false;
  }
}

class RainbowProgressBar extends LightShow
{
  float c_hue = 0.0;
  float c_sat = 1.0;
  float c_bri = 1.0;
  float hue_increment = 0.001;

  boolean progress_reverse = false;
  
  //int current_time = 0;
  int[] used_leds = {0, 1, 2, 170, 171, 172, 340, 341, 510, 511};
  //int[] used_leds_reverse = reverse(used_leds);
  int active_led = 0;
  RainbowProgressBar(int c_r, int c_g, int c_b)
  {
    super(c_r, c_g, c_b);
    name = "Rainbow Progress Bar";
  }

  void showFrame(int c_r, int c_g, int c_b) {
    background(0, 0, 0);

    active_led = int(current_time / chase_time_step);    
    if (progress_reverse) {
      if (active_led == 0) {
        active_led = 0;
        progress_reverse = false;
      }
    }
    else {
      if (active_led == used_leds.length) {
        active_led -= 1;
        progress_reverse = true;
      }
    }

    // scale brightness
    c_bri = filter_1;
    hue_increment = map(rainbow_speed, 0.0, 1.0, 0.0, 0.1);
    c_hue = c_hue + hue_increment;
    Color sRGB = new Color(Color.HSBtoRGB(c_hue, c_sat, c_bri));
    if (progress_reverse) {
      leds[used_leds[active_led]].r = 0;
      leds[used_leds[active_led]].g = 0;
      leds[used_leds[active_led]].b = 0;
    }
    else {
      leds[used_leds[active_led]].r = sRGB.getRed();
      leds[used_leds[active_led]].g = sRGB.getGreen();
      leds[used_leds[active_led]].b = sRGB.getBlue();
    }


    if (progress_reverse) {
      current_time -= 1;
    }
    else {
      current_time += 1;
    }
  }

  void resetShow() {
    current_time = 0;
    progress_reverse = false;
  }
}

class Strobe extends LightShow
{
  float c_hue = 0.0;
  float c_sat = 1.0;
  float c_bri = 1.0;
  
  //int current_time = 0;
  boolean strobe_on = true;
  
  Strobe(int c_r, int c_g, int c_b)
  {
    super(c_r, c_g, c_b);
    name = "Strobe";
  }

  void showFrame(int c_r, int c_g, int c_b) {
    background(0, 0, 0);

    // scale brightness
    c_hue = hue1_degree;
    c_bri = filter_1;
    Color sRGB = new Color(Color.HSBtoRGB(c_hue, c_sat, c_bri));
    
    if (current_time > chase_time_step) {
      strobe_on = !strobe_on;
      current_time = 0;
    }
    if (strobe_on) {
      for (int i=0; i<total_num_leds; i++) {
        leds[i].r = sRGB.getRed();
        leds[i].g = sRGB.getGreen();
        leds[i].b = sRGB.getBlue();
      }
    }
    else {
      for (int i=0; i<total_num_leds; i++) {
        leds[i].r = 0;
        leds[i].g = 0;
        leds[i].b = 0;
      }
    }
    current_time += 1;
  }

  void resetShow() {
    //current_time = 0;
  }
}

class RainbowStrobe extends LightShow
{
  float c_hue = 0.0;
  float c_sat = 1.0;
  float c_bri = 1.0;
  float hue_increment = 0.001;
  
  //int current_time = 0;
  boolean strobe_on = true;
  
  RainbowStrobe(int c_r, int c_g, int c_b)
  {
    super(c_r, c_g, c_b);
    name = "Rainbow Strobe";
  }

  void showFrame(int c_r, int c_g, int c_b) {
    background(0, 0, 0);

    // scale brightness
    c_bri = filter_1;
    
    hue_increment = map(rainbow_speed, 0.0, 1.0, 0.0, 0.1);
    c_hue = c_hue + hue_increment;
    
    Color sRGB = new Color(Color.HSBtoRGB(c_hue, c_sat, c_bri));
    
    if (current_time > chase_time_step) {
      strobe_on = !strobe_on;
      current_time = 0;
    }
    if (strobe_on) {
      for (int i=0; i<total_num_leds; i++) {
        leds[i].r = sRGB.getRed();
        leds[i].g = sRGB.getGreen();
        leds[i].b = sRGB.getBlue();
      }
    }
    else {
      for (int i=0; i<total_num_leds; i++) {
        leds[i].r = 0;
        leds[i].g = 0;
        leds[i].b = 0;
      }
    }
    current_time += 1;
    if (c_hue >= 1.0) {
      c_hue = 0.0;
    }
  }

  void resetShow() {
    //current_time = 0;
    c_hue = 0.0;
    rainbow_speed = 0.01;
  }
}

class TapLeftRight extends LightShow
{
  float c_hue_1 = 0.0;
  float c_hue_2 = 0.0;
  float c_sat = 1.0;
  float c_bri = 1.0;
  
  //int current_time = 0;
  //int[] used_leds = {0, 1, 2, 170, 171, 172, 340, 341, 510, 511};
  int[] left_leds = {0, 1, 2, 170, 171, 172};
  int[] right_leds ={340, 341, 510, 511};
  //int active_led_left = 0;
  TapLeftRight(int c_r, int c_g, int c_b)
  {
    super(c_r, c_g, c_b);
    name = "All Left On or All Right On";
  }

  void showFrame(int c_r, int c_g, int c_b) {
    background(0, 0, 0);
    
    for (int i=0; i<left_leds.length; i++) {
      leds[left_leds[i]].r = 0;
      leds[left_leds[i]].g = 0;
      leds[left_leds[i]].b = 0;
    }
    for (int i=0; i<right_leds.length; i++) {
      leds[right_leds[i]].r = 0;
      leds[right_leds[i]].g = 0;
      leds[right_leds[i]].b = 0;
    }

    // scale brightness
    c_hue_1 = hue1_degree;
    c_hue_2 = hue2_degree;
    c_bri = filter_1;
    Color sRGB_left = new Color(Color.HSBtoRGB(c_hue_1, c_sat, c_bri));
    Color sRGB_right= new Color(Color.HSBtoRGB(c_hue_2, c_sat, c_bri));

    if (left_side) {
      for (int i=0; i<left_leds.length; i++) {
        leds[left_leds[i]].r = sRGB_left.getRed();
        leds[left_leds[i]].g = sRGB_left.getGreen();
        leds[left_leds[i]].b = sRGB_left.getBlue();
      }
    }
    else {
      for (int i=0; i<right_leds.length; i++) {
        leds[right_leds[i]].r = sRGB_right.getRed();
        leds[right_leds[i]].g = sRGB_right.getGreen();
        leds[right_leds[i]].b = sRGB_right.getBlue();
      }
    }
  }

  void resetShow() {
  }
}

class BounceLeftRight extends LightShow
{
  float c_hue_1 = 0.0;
  float c_hue_2 = 0.0;
  float c_sat = 1.0;
  float c_bri = 1.0;
  
  //int current_time = 0;
  //int[] used_leds = {0, 1, 2, 170, 171, 172, 340, 341, 510, 511};
  int[] left_leds = {0, 1, 2, 170, 171, 172};
  int[] right_leds ={340, 341, 510, 511};
  //int active_led_left = 0;
  BounceLeftRight(int c_r, int c_g, int c_b)
  {
    super(c_r, c_g, c_b);
    name = "Bounce from Left Side to Right Side";
  }

  void showFrame(int c_r, int c_g, int c_b) {
    background(0, 0, 0);
    
    for (int i=0; i<left_leds.length; i++) {
      leds[left_leds[i]].r = 0;
      leds[left_leds[i]].g = 0;
      leds[left_leds[i]].b = 0;
    }
    for (int i=0; i<right_leds.length; i++) {
      leds[right_leds[i]].r = 0;
      leds[right_leds[i]].g = 0;
      leds[right_leds[i]].b = 0;
    }

    // scale brightness
    c_hue_1 = hue1_degree;
    c_hue_2 = hue2_degree;
    c_bri = filter_1;
    Color sRGB_left = new Color(Color.HSBtoRGB(c_hue_1, c_sat, c_bri));
    Color sRGB_right= new Color(Color.HSBtoRGB(c_hue_2, c_sat, c_bri));

    if (left_side) {
      for (int i=0; i<left_leds.length; i++) {
        leds[left_leds[i]].r = sRGB_left.getRed();
        leds[left_leds[i]].g = sRGB_left.getGreen();
        leds[left_leds[i]].b = sRGB_left.getBlue();
      }
    }
    else {
      for (int i=0; i<right_leds.length; i++) {
        leds[right_leds[i]].r = sRGB_right.getRed();
        leds[right_leds[i]].g = sRGB_right.getGreen();
        leds[right_leds[i]].b = sRGB_right.getBlue();
      }
    }
    current_time += 1;
    if (current_time > chase_time_step) {
      current_time = 0;
      left_side = !left_side;
    }
  }

  void resetShow() {
  }
}

class SoundReactiveChase extends LightShow
{
  float c_hue = 0.0;
  float c_sat = 1.0;
  float c_bri = 1.0;
  
  //int current_time = 0;
  int[] used_leds = {0, 1, 2, 170, 171, 172, 340, 341, 510, 511};

  SoundReactiveChase(int c_r, int c_g, int c_b)
  {
    super(c_r, c_g, c_b);
    name = "Sound Reactive Chase All";
  }

  void showFrame(int c_r, int c_g, int c_b) {
    background(0, 0, 0);
    
    for (int i=0; i<used_leds.length; i++) {
      leds[used_leds[i]].r = 0;
      leds[used_leds[i]].g = 0;
      leds[used_leds[i]].b = 0;
    }

    fft.forward(in.mix);
    // scale filter to deal with audio being too loud
    // note: max and min are inverted
    float filter_x = map(filter_1, 1.0, 0.0, 2.0, 100.0);
    // min is because processing doesn't deal with values going outside upper bound well
    amp = map(min(fft.getBand(fft_band_1), filter_x), 0.0, filter_x, 0.0, float(used_leds.length));
    c_hue = hue1_degree;
    c_bri = amp;
    Color sRGB = new Color(Color.HSBtoRGB(c_hue, c_sat, c_bri));
    for (int i=0; i<used_leds.length; i++) {
      if (i == int(amp)) {
        leds[used_leds[i]].r = sRGB.getRed();
        leds[used_leds[i]].g = sRGB.getGreen();
        leds[used_leds[i]].b = sRGB.getBlue();
      }
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
    //current_time = 0;
    reverse_chase = false;
  }
}

class SoundReactiveProgressBar extends LightShow
{
  float c_hue = 0.0;
  float c_sat = 1.0;
  float c_bri = 1.0;
  
  //int current_time = 0;
  int[] used_leds = {0, 1, 2, 170, 171, 172, 340, 341, 510, 511};

  SoundReactiveProgressBar(int c_r, int c_g, int c_b)
  {
    super(c_r, c_g, c_b);
    name = "Sound Reactive Progress Bar All";
  }

  void showFrame(int c_r, int c_g, int c_b) {
    background(0, 0, 0);
    
    for (int i=0; i<used_leds.length; i++) {
      leds[used_leds[i]].r = 0;
      leds[used_leds[i]].g = 0;
      leds[used_leds[i]].b = 0;
    }

    fft.forward(in.mix);
    // scale filter to deal with audio being too loud
    // note: max and min are inverted
    float filter_x = map(filter_1, 1.0, 0.0, 2.0, 100.0);
    // min is because processing doesn't deal with values going outside upper bound well
    amp = map(min(fft.getBand(fft_band_1), filter_x), 0.0, filter_x, 0.0, float(used_leds.length));
    c_hue = hue1_degree;
    c_bri = amp;
    Color sRGB = new Color(Color.HSBtoRGB(c_hue, c_sat, c_bri));
    for (int i=0; i<used_leds.length; i++) {
      if (i <= int(amp)) {
        leds[used_leds[i]].r = sRGB.getRed();
        leds[used_leds[i]].g = sRGB.getGreen();
        leds[used_leds[i]].b = sRGB.getBlue();
      }
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
    //current_time = 0;
    reverse_chase = false;
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
