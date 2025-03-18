@import "../Hydra.chug"

// basic_args.ck
Blit b => Gain g => dac;

// Copy all args to a string array
string args[0];
for (auto i : Std.range(me.args())) {
    args << me.arg(i);
}


// Create a hydra config object and initialize it.
Hydra cfg;
// Initialize cfg with our config.yaml
// The third argument lets you pass config overrides
cfg.init(me.dir() + "configs", "basic", args);

// Grab the gain value
cfg.getFloat("gain") => g.gain;
// 'blit' has two sub-components: freq and harmonics
cfg.get("blit").getFloat("freq") => b.freq;
cfg.get("blit").getInt("harmonics") => b.harmonics;

1::eon => now;
