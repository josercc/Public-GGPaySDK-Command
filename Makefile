PREFIX?=/usr/local
PROD_NAME=PGG

build:
	swift build --disable-sandbox -c release -Xswiftc -static-stdlib
build-for-linux:
	swift build --disable-sandbox -c release
install: build
	mkdir -p "$(PREFIX)/bin"
	cp -f ".build/release/Public-GGPaySDK" "$(PREFIX)/bin/PGG"
