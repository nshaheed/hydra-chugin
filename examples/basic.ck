// basic.ck
Blit b => Gain g => dac;

// Create a hydra config object and initialize 
// it with our config.yaml.
// First arg: the directory where the config is stored
// Second arg: the config file name (don't include .yaml)

Hydra cfg("configs", "basic");

// View all the functions and descriptors.
// cfg.help();

// Grab the gain value
cfg.getFloat("gain") => g.gain;

// 'blit' has two sub-components: freq and harmonics
cfg.get("blit").getFloat("freq") => b.freq;
cfg.get("blit").getInt("harmonics") => b.harmonics;

eon => now;
