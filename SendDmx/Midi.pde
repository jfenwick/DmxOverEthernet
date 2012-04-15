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

int rainbow_speed_midi;
int hue1_degree_midi;
int hue2_degree_midi;
int fft_band_1_midi;
int fft_band_2_midi;
int filter_1_midi;
int filter_2_midi;

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
    rainbow_speed_midi = int(myProps.getProperty("rainbow_speed_midi"));
    hue1_degree_midi = int(myProps.getProperty("hue1_degree_midi"));
    hue2_degree_midi = int(myProps.getProperty("hue2_degree_midi"));
    fft_band_1_midi = int(myProps.getProperty("fft_band_1_midi"));
    fft_band_2_midi = int(myProps.getProperty("fft_band_2_midi"));
    filter_1_midi = int(myProps.getProperty("filter_1_midi"));
    filter_2_midi = int(myProps.getProperty("filter_2_midi"));
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
  if (number == show_0_midi) {
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
