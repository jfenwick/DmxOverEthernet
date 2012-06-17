vm,.mport themidibus.*;
MidiBus myBus;

// Black mode
int show_0_midi = 0;
// Single color mode
int show_1_midi = 1;
// Rainow mode
int show_2_midi = 2; 
// FFT rainbow
int show_3_midi = 3;
// FFT single color
int show_4_midi = 4;
// FFT double color
int show_5_midi = 5;
int show_6_midi = 6;
int show_7_midi = 7;
int show_8_midi = 8;
int show_9_midi = 9;
int show_10_midi = 10;
int show_11_midi = 11;
int show_12_midi = 12;
int show_13_midi = 13;
int show_14_midi = 14;
int show_15_midi = 15;

int rainbow_speed_midi;
int hue1_degree_midi;
int hue2_degree_midi;
int fft_band_1_midi;
int fft_band_2_midi;
int filter_1_midi;
int filter_2_midi;
//int chase_speed_midi;

void setupMidi() {
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
    show_6_midi = int(myProps.getProperty("show_6_midi"));
    show_7_midi = int(myProps.getProperty("show_7_midi"));
    show_8_midi = int(myProps.getProperty("show_8_midi"));
    show_9_midi = int(myProps.getProperty("show_9_midi"));
    show_10_midi = int(myProps.getProperty("show_10_midi"));
    show_11_midi = int(myProps.getProperty("show_11_midi"));
    show_12_midi = int(myProps.getProperty("show_12_midi"));
    show_13_midi = int(myProps.getProperty("show_13_midi"));
    show_14_midi = int(myProps.getProperty("show_14_midi"));
    show_15_midi = int(myProps.getProperty("show_15_midi"));
    rainbow_speed_midi = int(myProps.getProperty("rainbow_speed_midi"));
    hue1_degree_midi = int(myProps.getProperty("hue1_degree_midi"));
    hue2_degree_midi = int(myProps.getProperty("hue2_degree_midi"));
    fft_band_1_midi = int(myProps.getProperty("fft_band_1_midi"));
    fft_band_2_midi = int(myProps.getProperty("fft_band_2_midi"));
    filter_1_midi = int(myProps.getProperty("filter_1_midi"));
    filter_2_midi = int(myProps.getProperty("filter_2_midi"));
    //chase_speed_midi = int(myProps.getProperty("chase_speed_midi"));
    inputStream.close();
  } 
  catch (IOException e) {
    e.printStackTrace();
  }
  
  //myBus = new MidiBus(this, "SLIDER/KNOB", "CTRL");
  myBus = new MidiBus(this, 0, 0);
}

void noteOn(int channel, int pitch, int velocity) {
  int number = pitch;
  if (number == 49) {
    leds[0].r = int(map(velocity, 0, 127, 0, 255));
  }
  else if (number == 57) {
    leds[1].r = int(map(velocity, 0, 127, 0, 255));
  }
  else if (number == 51) {
    leds[2].r = int(map(velocity, 0, 127, 0, 255));
  }
  else if (number == 53) {
    leds[3].r = int(map(velocity, 0, 127, 0, 255));
  }
  else if (number == 56) {
    leds[4].r = int(map(velocity, 0, 127, 0, 255));
  }
  else if (number == 39) {
    leds[5].r = int(map(velocity, 0, 127, 0, 255));
  }
  else if (number == 42) {
    leds[6].r = int(map(velocity, 0, 127, 0, 255));
  }
  else if (number == 46) {
    leds[7].r = int(map(velocity, 0, 127, 0, 255));
  }
  else if (number == 50) {
    leds[8].r = int(map(velocity, 0, 127, 0, 255));
  }
  else if (number == 48) {
    leds[9].r = int(map(velocity, 0, 127, 0, 255));
  }
  else if (number == 45) {
    leds[10].r = int(map(velocity, 0, 127, 0, 255));
  }
  else if (number == 41) {
    leds[11].r = int(map(velocity, 0, 127, 0, 255));
  }
  else if (number == 36) {
    leds[12].r = int(map(velocity, 0, 127, 0, 255));
  }
  else if (number == 38) {
    leds[13].r = int(map(velocity, 0, 127, 0, 255));
  }
  else if (number == 40) {
    leds[14].r = int(map(velocity, 0, 127, 0, 255));
  }
  else if (number == 37) {
    leds[15].r = int(map(velocity, 0, 127, 0, 255));
  }
}

void controllerChange(int channel, int number, int value) {
  //print(number);
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
}
