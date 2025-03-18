@import "../Hydra.chug"

// An example of using Hydra to configure different 
// presets for the ModalBar UGen.

// patch
ModalBar bar => JCRev j => dac;
2 => bar.gain;

// Load up our hydra config (./configs/bandedwg.yaml)
Hydra cfg;

// chuck = 1 modal_config:modal=preset1:tempo=480:modal.hardness=1:blit=true

// You can override values in bandedwg.yaml by either
// providing values to the command line, i.e:
// chuck modal_config:tempo=110:modal.preset=3
// or you can pass an array of strings with these
// overrides directly to cfg.init. In this example
// we'll be passing along command line arguments.

// Copy all args to a string array
string args[0];
for (auto i : Std.range(me.args())) {
    args << me.arg(i);
}

// If you don't want to provide any overrides, simply call
// cfg.init(me.dir() + "configs", "modal")
// true => cfg.debug;
cfg.init(me.dir() + "configs", "modal", args); // opens up ./configs/modal.yaml

// Set the tempo
1::minute / cfg.getFloat("tempo") => dur tempo;

if (cfg.getBool("blit")) spork~ blit();

// scale
[0, 2, 4, 7, 9, 11] @=> int scale[];

// Math.random2( 0, 8 ) => int preset;
cfg.get("modal").getInt("preset") => int preset;
cfg.get("modal").getFloat("hardness") => float stickHardness;
cfg.get("modal").getFloat("position") => float strikePosition;

// infinite time loop
while( true )
{
    // ding!
    Math.random2f( 0, 128 ) => float strikePosition;
    Math.random2f( 0, 128 ) => float vibratoGain;
    Math.random2f( 0, 128 ) => float vibratoFreq;
    Math.random2f( 0, 128 ) => float volume;
    Math.random2f( 64, 128 ) => float directGain;
    Math.random2f( 64, 128 ) => float masterGain;

    bar.controlChange( 2, stickHardness );
    bar.controlChange( 4, strikePosition );
    bar.controlChange( 11, vibratoGain );
    bar.controlChange( 7, vibratoFreq );
    bar.controlChange( 1, directGain);
    bar.controlChange( 128, volume );
    bar.controlChange( 16, preset );

    <<< "---", "" >>>;
    <<< "preset:", preset >>>;
    <<< "stick hardness:", stickHardness, "/ 128.0" >>>;
    <<< "strike position:", strikePosition, "/ 128.0" >>>;
    <<< "vibrato gain:", vibratoGain, "/ 128.0" >>>;
    <<< "vibrato freq:", vibratoFreq, "/ 128.0" >>>;
    <<< "volume:", volume, "/ 128.0" >>>;
    <<< "direct gain:", directGain, "/ 128.0" >>>;
    <<< "master gain:", masterGain, "/ 128.0" >>>;

    // set frequency
    Std.mtof( 33 + Math.random2(0,3) * 12 +
        scale[Math.random2(0,scale.size()-1)] ) => bar.freq;
    // go
    .8 => bar.noteOn;

    // advance time
    tempo => now;
}


// blit!!!
fun void blit() {
    // patch
    Blit s => JCRev r => dac;
    .2 => s.gain;
    .2 => r.mix;
    0.8 => r.gain;

    // an array
    [ 0, 2, 4, 7, 9, 11 ] @=> int hi[];
    // <<< hi.size() >>>;
    // <<< hi[0], hi[1], hi[2], hi[3], hi[4], hi[5] >>>;

    10::ms => now;
    // infinite time loop
    while( true )
    {
        // frequency
        Std.mtof( 33 + Math.random2(0,3) * 12 +
            hi[Math.random2(0,hi.size()-1)] ) => s.freq;

        // harmonics
        Math.random2( 2, 5 ) => s.harmonics;

        // advance time
        tempo => now;
    }

}