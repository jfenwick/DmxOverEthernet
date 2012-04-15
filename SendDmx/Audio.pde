import ddf.minim.*;
import ddf.minim.analysis.*;

Minim minim;
AudioInput in;
FFT fft;
float amp = 0.0;
int specSize;
int specHeight = 200;

void setupAudio() {
  minim = new Minim(this);
  in = minim.getLineIn(Minim.STEREO, 512);
  fft = new FFT(in.bufferSize(), in.sampleRate());
  specSize = fft.specSize();
}

void stopAudio() {
  in.close();
  minim.stop();
  super.stop();
}
