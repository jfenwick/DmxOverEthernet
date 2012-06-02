import themidibus.*;
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
  // CHILL / slow and sexy
  // button pressed down / button released
  // blackout
  if (number == show_0_midi) {
    for (int i=0; i<shows.length; i++) {
      shows[i].resetShow();
    }
    light_show = 0;
  }
  // single color / rainbow
  else if (number == show_1_midi) {
    for (int i=0; i<shows.length; i++) {
      shows[i].resetShow();
    }
    if (velocity == 0) {
      filter_1 = 0.3;
      light_show = 2;
    }
    else {
      light_show = 1;
    }
  }
  // reverse red chase / red chase
  else if (number == show_2_midi) {
    for (int i=0; i<shows.length; i++) {
      shows[i].resetShow();
    }
    if (velocity == 0) {
      hue1_degree = 0.0;
      chase_time_step = 20;
      filter_1 = 0.3;
      light_show = 16;
    }
    else {
      hue1_degree = 0.0;
      chase_time_step = 20;
      filter_1 = 0.3;
      light_show = 16;
      reverse_chase = true;
    }
  }
  // all left / all right
  else if (number == show_3_midi) {
    for (int i=0; i<shows.length; i++) {
      shows[i].resetShow();
    }
    light_show = 12;
    filter_1 = 0.3;
    if (velocity == 0) {
      left_side = false;
    }
    else {
      left_side = true;
    }
  }
  // / reverse rainbow chase / rainbow chase
  else if (number == show_4_midi) {
    for (int i=0; i<shows.length; i++) {
      shows[i].resetShow();
    }
    if (velocity == 0) {
      light_show = 9;
      chase_time_step = 20;
      filter_1 = 0.3;
      rainbow_speed = 0.05;
    }
    else {
      light_show = 9;
      chase_time_step = 20;
      filter_1 = 0.3;
      rainbow_speed = 0.05;
      reverse_chase = true;
    }

  }
  // buildup / anticipation
  // progress bar
  else if (number == show_5_midi) {
    for (int i=0; i<shows.length; i++) {
      shows[i].resetShow();
    }
    chase_time_step = 15;
    filter_1 = 0.3;
    light_show = 10;
  }
  // rainbow progress bar
  else if (number == show_6_midi) {
    for (int i=0; i<shows.length; i++) {
      shows[i].resetShow();
    }
    chase_time_step = 15;
    filter_1 = 0.3;
    rainbow_speed = 0.05;
    light_show = 11;
  }

  // bounce from left to right
  else if (number == show_7_midi) {
    for (int i=0; i<shows.length; i++) {
      shows[i].resetShow();
    }
    light_show = 13;
    filter_1 = 0.3;
    chase_time_step = 20.0;
  } 
  // full beat / pulsing energy
  // sound reactive hue
  else if (number == show_8_midi) {
    for (int i=0; i<shows.length; i++) {
      shows[i].resetShow();
    }
    light_show = 4;
  }
  // sound reactive rainbow all
  else if (number == show_9_midi) {
    for (int i=0; i<shows.length; i++) {
      shows[i].resetShow();
    }
    light_show = 3;
  }  
  // FIXME: EMPTY
  else if (number == show_10_midi) {
    for (int i=0; i<shows.length; i++) {
      shows[i].resetShow();
    }
  }
  // FIXME: EMPTY sound reactive bounce back and forth from left to right
  else if (number == show_11_midi) {
    for (int i=0; i<shows.length; i++) {
      shows[i].resetShow();
    }
    light_show = 3;
  }
  // insane / mega-visual orgasm
  // sound reactive progress bar all
  else if (number == show_12_midi) {
    for (int i=0; i<shows.length; i++) {
      shows[i].resetShow();
    }
    filter_1 = 0.0;
    light_show = 15;
  }  
  // FIXME: EMPTY
  else if (number == show_13_midi) {
    for (int i=0; i<shows.length; i++) {
      shows[i].resetShow();
    }
    filter_1 = 0.0;
    light_show = 15;
  }
  // strobe single color  
  else if (number == show_14_midi) {
    for (int i=0; i<shows.length; i++) {
      shows[i].resetShow();
    }
    light_show = 7;
    filter_1 = 1.0;
    chase_time_step = 0.01;
  }
  // strobe rainbow
  else if (number == show_15_midi) {
    for (int i=0; i<shows.length; i++) {
      shows[i].resetShow();
    }
    light_show = 8;
    filter_1 = 1.0;
    chase_time_step = 0.01;
    rainbow_speed = 0.1;    
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
