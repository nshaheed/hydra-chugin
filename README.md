# Hydra Chugin

This chugin is a wrapper around the python configuration framework [Hydra](https://hydra.cc/). The tl;dr here of that hydra is a really robust, composable configuration framework that lets you do a ton of things including dynamically composing config files, manage outputs, and is a generally nice workflow when you're constantly twiddling with a bunch of variables.

## Installation

Hydra is dependant on Python and the Hydra library. To install hydra run the following command in your terminal:
- `pip install hydra-core`

If you want to keep your global python install clean, you can use anaconda to 
make a separate hydra environment:
- make a conda env: `conda create -n hydra`
- activate conda env: `conda activate hydra`
- install hydra: `pip install hydra-core`

[Cmake](https://cmake.org/) also needs to be installed in order to build the chugin.

### Building Hydra
Now that you have hydra installed, you can build the chugin using cmake.
- `git clone --recurse-submodules https://github.com/nshaheed/hydra-chugin.git`
- `cd hydra-chugin`
- `cmake -S . -B build`
- `cmake --build build/ --config Release`
- This should automatically install `Hydra.chug` to the relevant directory. Now `Hydra` should show up as a class in chuck!

## Examples
See the [examples](examples/) folder for more examples. Fore a more complete
tutorial for Hydra library, checkout out Hydra's [tutorials](https://hydra.cc/docs/tutorials/intro/).

Hydra configs are just yaml files:
``` yaml
# basic.yaml
# A basic config
gain: 0.8
blit:
    freq: 440
    harmonics: 4
```

Here's how we fetch these values from files
``` chuck
// basic.ck
Blit b => Gain g => dac;

// Create a hydra config object and initialize it.
Hydra cfg;
// Initialize cfg with our config.yaml
// First arg: the directory where the config is stored
// Second arg: the config file name (don't include .yaml)
cfg.init("config_dir", "basic");

// Grab the gain value
cfg.getFloat("gain") => g.gain;
// 'blit' has two sub-components: freq and harmonics
cfg.get("blit").getFloat("freq") => b.freq;
cfg.get("blit").getInt("harmonics") => b.harmonics;

eon => now;
```

Run `chuck basic.ck` and hear the results
1

If we pass along the command line arguments, we get easy, named args:
```chuck
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
cfg.init("config_dir", "basic", args);

// Grab the gain value
cfg.getFloat("gain") => g.gain;
// 'blit' has two sub-components: freq and harmonics
cfg.get("blit").getFloat("freq") => b.freq;
cfg.get("blit").getInt("harmonics") => b.harmonics;

eon => now;

```

Now we can override the config values from the command line:

``` bash
# change the gain to 0.5
chuck basic_args.ck:gain=0.5
```

You can also modify nested values:
``` bash
chuck basic_args.ck:gain=0.5:blit.freq=220
```

## Output Directories

Every run generates an output directory in the format `./ouputs/YYYY-MM-DD/HH-MM-SS/`. You can use keep all your generated files stored the run-specific directory by using `cfg.dir()` to get the directory path.
