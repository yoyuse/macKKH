all: install

app:
	xcodebuild

install: app
	-killall MacKKIM
	rm -Rf ~/Library/Input\ Methods/MacKKIM.app
	cp -Rp build/Release/MacKKIM.app ~/Library/Input\ Methods
