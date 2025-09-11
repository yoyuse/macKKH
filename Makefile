all: install

app:
	xcodebuild

install: app
	-killall macKKH
	rm -Rf ~/Library/Input\ Methods/macKKH.app
	cp -Rp build/Release/macKKH.app ~/Library/Input\ Methods
