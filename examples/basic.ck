// basic.ck
Blit b => Gain g => dac;

// Create a hydra config object and initialize it.
Hydra cfg("configs", "basic");
// Hydra cfg();
// Initialize cfg with our config.yaml
// First arg: the directory where the config is stored
// Second arg: the config file name (don't include .yaml)
// true => cfg.debug;
// cfg.help();
// cfg.init("configs", "basic");

<<<"poop", cfg >>>;

// Grab the gain value
cfg.getFloat("gain") => g.gain;
<<< "gain", cfg.getFloat("gain") >>>;
// 'blit' has two sub-components: freq and harmonics
<<< "is config", cfg.get("blit").isConfig() >>>;
<<< "getfreq", cfg.get("blit").get("freq").getFloat() >>>;
cfg.get("blit").getFloat("freq") => b.freq;

<<< "freq", cfg.get("blit").getFloat("freq") >>>;
cfg.get("blit").getInt("harmonics") => b.harmonics;

<<<"poop">>>;

eon => now;
