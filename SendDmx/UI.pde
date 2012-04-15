import controlP5.*;

ControlP5 controlP5;

Numberbox rainbow_speed_c;
Numberbox hue1_degree_c;
Numberbox hue2_degree_c;
Numberbox fft_band_1_c;
Numberbox fft_band_2_c;
Numberbox filter_1_c;
Numberbox filter_2_c;

void setupUI() {
  controlP5 = new ControlP5(this);  
  rainbow_speed_c = setControl(rainbow_speed_c, "speed", rainbow_speed, 0, 210, 40, 14, 0.0, 1.0, 0.01, 1);
  hue1_degree_c = setControl(hue1_degree_c, "hue1", hue1_degree, 45, 210, 40, 14, 0.0, 1.0, 0.01, 2);
  hue2_degree_c = setControl(hue1_degree_c, "hue2", hue1_degree, 90, 210, 40, 14, 0.0, 1.0, 0.01, 3);
  fft_band_1_c = setControl(fft_band_1_c, "band1", fft_band_1, 135, 210, 40, 14, 0.0, specSize, 1.0, 4);
  fft_band_2_c = setControl(fft_band_2_c, "band2", fft_band_2, 180, 210, 40, 14, 0.0, specSize, 1.0, 5);
  filter_1_c = setControl(filter_1_c, "filter1", filter_1, 225, 210, 40, 14, 0.0, 1.0, 0.01, 6);
  filter_2_c = setControl(filter_2_c, "filter2", filter_2, 270, 210, 40, 14, 0.0, 1.0, 0.01, 7);
}

Numberbox setControl(Numberbox nb, String name, float val, int x, int y, int w, int h, float mi, float ma, float mul, int id) {
  nb =controlP5.addNumberbox(name, val, x, y, w, h);
  nb.setMin(mi);
  nb.setMax(ma);
  nb.setMultiplier(mul);
  nb.setId(id);
  return nb;
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
