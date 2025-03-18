@import "Chumpinate"

// Our package version
"1.0.0" => string version;

<<< "Generating Chumpinate package version " >>>;

// instantiate a Chumpinate package
Package pkg("Hydra");

// Add our metadata...
"Nick Shaheed" => pkg.authors;

"https://github.com/nshaheed/hydra-chugin" => pkg.homepage;
"https://github.com/nshaheed/hydra-chugin" => pkg.repository;

"MIT" => pkg.license;
"A wrapper for the Python configuration framework Hydra" => pkg.description;

["configs", "python"] => pkg.keywords;

// generate a package-definition.json
// This will be stored in "Chumpinate/package.json"
"./" => pkg.generatePackageDefinition;

<<< "Defining version " + version >>>;;

// Now we need to define a specific PackageVersion for test-pkg
PackageVersion ver("Hydra", version);

"10.2" => ver.apiVersion;

"1.5.5.0" => ver.languageVersionMin;

"windows" => ver.os;
"x86_64" => ver.arch;

// The chugin file
ver.addFile("./Hydra.chug");

// These build files are examples as well
ver.addExampleFile("examples/basic.ck");
ver.addExampleFile("examples/basic_args.ck");
ver.addExampleFile("examples/modal_config.ck");
ver.addExampleFile("examples/configs/basic.yaml", "configs");
ver.addExampleFile("examples/configs/modal.yaml", "configs");
ver.addExampleFile("examples/configs/modal/preset1.yaml", "configs/modal");
ver.addExampleFile("examples/configs/modal/preset2.yaml", "configs/modal");

// The version path
"chugins/Hydra/" + ver.version() + "/" + ver.os() + "/Hydra.zip" => string path;

<<< path >>>;

// wrap up all our files into a zip file, and tell Chumpinate what URL
// this zip file will be located at.
ver.generateVersion("./", "Hydra_win", "https://ccrma.stanford.edu/~nshaheed/" + path);

chout <= "Use the following commands to upload the package to CCRMA's servers:" <= IO.newline();
chout <= "ssh nshaheed@ccrma-gate.stanford.edu \"mkdir -p ~/Library/Web/chugins/Hydra/"
      <= ver.version() <= "/" <= ver.os() <= "\"" <= IO.newline();
chout <= "scp Hydra_win.zip nshaheed@ccrma-gate.stanford.edu:~/Library/Web/" <= path <= IO.newline();

// Generate a version definition json file, stores this in "chumpinate/<VerNo>/Chumpinate_win.json"
ver.generateVersionDefinition("Hydra_win", "./" );
