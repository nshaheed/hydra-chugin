
# chugin name
CHUGIN_NAME=Hydra

# all of the c/cpp files that compose this chugin
C_MODULES=
CXX_MODULES=Hydra.cpp

# where the chuck headers are
CK_SRC_PATH?=../chuck/include/


# default target: print usage message and quit
current: 
	@echo "[chuck build]: please use one of the following configurations:"
	@echo "   make linux, make osx, or make win32"

setup-mac:
	cmake . -S . -B build -DCMAKE_BUILD_TYPE=Release
mac: setup-mac
	cmake --build build
	cp build/Hydra.chug .

setup-linux:
	cmake . -S . -B build -DCMAKE_BUILD_TYPE=Release
linux: setup-linux
	cmake --build build
	cp build/Hydra.chug .

setup-win:
	cmake . -S . -B build -DCMAKE_BUILD_TYPE=Release -G "Visual Studio 17 2022" -A "x64"
win:
	cmake --build . --config Release
	cp build/Hydra.chug .

clean: 
	rm -rf $(C_OBJECTS) $(CXX_OBJECTS) $(CHUG) Release Debug build Hydra.chug




