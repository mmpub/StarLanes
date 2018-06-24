#!/usr/bin/xcrun make -f

TEMPORARY_FOLDER?=/tmp/StarLanes.dst
XCODEFLAGS=-scheme 'starlanes' DSTROOT=$(TEMPORARY_FOLDER)

INTERNAL_PACKAGE=StarLanesApp.pkg
OUTPUT_PACKAGE=StarLanes.pkg

BINARIES_FOLDER=/usr/local/bin
DISTRIBUTION_PLIST=InstallerResources/Distribution.plist

RM=rm -f
RMD=rm -rf
SUDO=sudo

.PHONY: all clean install package uninstall

all:
	xcodebuild $(XCODEFLAGS) build

clean:
	$(RM) "$(INTERNAL_PACKAGE)"
	$(RM) "$(OUTPUT_PACKAGE)"
	$(RMD) "$(TEMPORARY_FOLDER)"
	xcodebuild $(XCODEFLAGS) clean

install: package
	$(SUDO) installer -pkg $(OUTPUT_PACKAGE) -target /

uninstall:
	$(RM) "$(BINARIES_FOLDER)/starlanes"

installables: clean
	xcodebuild $(XCODEFLAGS) install
	find /tmp/StarLanes.dst

package: installables
	pkgbuild \
      	--identifier "mmpub.starlanes" \
		--install-location "/" \
		--root "$(TEMPORARY_FOLDER)" \
		--version "1.0.0" \
		"$(INTERNAL_PACKAGE)"

	productbuild \
	--resources ./InstallerResources \
  	--distribution "$(DISTRIBUTION_PLIST)" \
  	--package-path "$(INTERNAL_PACKAGE)" \
   	"$(OUTPUT_PACKAGE)"
