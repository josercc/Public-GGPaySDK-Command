prefix ?= /usr/local
bindir = $(prefix)/bin
libdir = $(prefix)/lib

build:
	swift build -c release --disable-sandbox

install: build
	install ".build/release/Public-GGPaySDK" "$(bindir)"
	install ".build/release/libSwiftSyntax.dylib" "$(libdir)"
	install_name_tool -change \
		".build/x86_64-apple-macosx10.10/release/libSwiftSyntax.dylib" \
		"$(libdir)/libSwiftSyntax.dylib" \
		"$(bindir)/Public-GGPaySDK"

uninstall:
	rm -rf "$(bindir)/Public-GGPaySDK"
	rm -rf "$(libdir)/libSwiftSyntax.dylib"

clean:
	rm -rf .build

.PHONY: build install uninstall clean

