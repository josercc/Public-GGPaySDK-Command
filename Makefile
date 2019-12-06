prefix ?= /usr/local
bindir = $(prefix)/bin
libdir = $(prefix)/lib

build:
	swift build -c release --disable-sandbox

install: build
	install ".build/release/Public-GGPaySDK" "$(bindir)"
	install ".build/release/libswiftCore.dylib" "$(libdir)"
	install_name_tool -change \
		".build/release/libswiftCore.dylib" \
		"$(libdir)/libswiftCore.dylib" \
		"$(bindir)/Public-GGPaySDK"

uninstall:
	rm -rf "$(bindir)/Public-GGPaySDK"
	rm -rf "$(libdir)/libswiftCore.dylib"

clean:
	rm -rf .build

.PHONY: build install uninstall clean

