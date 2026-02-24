TARGET = macKKH
DSTDIR = ~/Library/Input\ Methods

all: install

app:
	xcodebuild

install: app
	-killall $(TARGET)
	rm -Rf $(DSTDIR)/$(TARGET).app
	cp -Rp build/Release/$(TARGET).app $(DSTDIR)/

run:
	open -a $(TARGET)

# ビルド番号を Git commits の数に設定
# バージョン番号を 1.0.<ビルド番号> に設定

buildNumber := $(shell git rev-list HEAD | wc -l | tr -d ' ')
versionNumber := 1.0.$(buildNumber)
xcodeproj := $(shell find . -name "project.pbxproj")

version:
	agvtool new-version "$(buildNumber)"
	sed -i~ -e '/MARKETING_VERSION = .*;$$/s//MARKETING_VERSION = '"$(versionNumber)"';/' "$(xcodeproj)"
	agvtool what-marketing-version -terse
