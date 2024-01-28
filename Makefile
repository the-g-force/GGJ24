name=wildlife
godot=godot

all: windows linux zip

clean:
	rm -rf build

windows:
	mkdir -p build/linux
	$(godot) -v --export-release --headless "Linux/X11" ../build/linux/$(name).x86_64 project/project.godot

linux:
	mkdir -p build/windows
	$(godot) -v --export-release --headless "Windows Desktop" ../build/windows/$(name).exe project/project.godot

zip: windows linux
	mkdir -p build/zip
	mkdir -p build/zip/src
	rsync -av --progress project build/zip/src --exclude .godot
	echo "This project was built using [Godot Engine](https://godotengine.org)." > build/zip/src/README.md
	mkdir -p build/zip/release/linux
	mkdir -p build/zip/release/windows
	cp -r build/windows/* build/zip/release/windows
	cp -r build/linux/* build/zip/release/linux
	cp LICENSE build/zip
	mkdir -p build/zip/press
	cp press/*png build/zip/press
	cd build/zip;	zip $(name).zip -r .