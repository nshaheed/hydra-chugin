// basic.ck
Blit b => Gain g => dac;

// Create a hydra config object and initialize it.
Hydra cfg;
// Initialize cfg with our config.yaml
// First arg: the directory where the config is stored
// Second arg: the config file name (don't include .yaml)
true => cfg.debug;
// cfg.help();
cfg.init("configs", "basic");

// Grab the gain value
cfg.getFloat("gain") => g.gain;
// 'blit' has two sub-components: freq and harmonics
cfg.get("blit").getFloat("freq") => b.freq;
cfg.get("blit").getInt("harmonics") => b.harmonics;

1::eon => now;
