.PHONY: all install librime data update_brise update_opencc_data deps release debug clean

all: release
install: install-release

LIBRIME = lib/librime.1.dylib
BRISE = data/brise/default.yaml data/brise/symbols.yaml data/brise/essay.txt
OPENCC_DATA = data/opencc/TSCharacters.ocd data/opencc/TSPhrases.ocd data/opencc/t2s.json

DEPENDS = $(LIBRIME) $(BRISE) $(OPENCC_DATA)

LIBRIME_OUTPUT = librime/xbuild/lib/Release/librime.1.dylib
RIME_DEPLOYER_OUTPUT = librime/xbuild/bin/Release/rime_deployer
RIME_DICT_MANAGER_OUTPUT = librime/xbuild/bin/Release/rime_dict_manager
OPENCC_DATA_OUTPUT = librime/thirdparty/data/opencc/*.*
DATA_FILES = brise/default.yaml brise/symbols.yaml brise/essay.txt brise/preset/*.yaml brise/supplement/*.yaml

$(LIBRIME):
	$(MAKE) librime

$(BRISE):
	$(MAKE) update_brise

$(OPENCC_DATA):
	$(MAKE) update_opencc_data

librime:
	cd librime; make -f Makefile.xcode
	cp -L $(LIBRIME_OUTPUT) $(LIBRIME)
	cp $(RIME_DEPLOYER_OUTPUT) bin/
	cp $(RIME_DICT_MANAGER_OUTPUT) bin/

data: update_brise update_opencc_data

update_brise:
	mkdir -p data/brise
	cp $(DATA_FILES) data/brise/

update_opencc_data:
	cd librime; make -f Makefile.xcode thirdparty/opencc
	mkdir -p data/opencc
	cp $(OPENCC_DATA_OUTPUT) data/opencc/

deps: librime data

release: $(DEPENDS)
	xcodebuild -project Squirrel.xcodeproj -configuration Release build | grep -v setenv | tee build.log
	rm -f build/Squirrel.app
	cd build ; ln -s Release/Squirrel.app Squirrel.app

debug: $(DEPENDS)
	xcodebuild -project Squirrel.xcodeproj -configuration Debug build | grep -v setenv | tee build.log
	rm -f build/Squirrel.app
	cd build ; ln -s Debug/Squirrel.app Squirrel.app

SQUIRREL_APP_PATH = /Library/Input Methods/Squirrel.app

install-debug:
	rm -rf "$(SQUIRREL_APP_PATH)/Contents/Frameworks"
	rm -rf "$(SQUIRREL_APP_PATH)/Contents/MacOS"

	cp -R build/Debug/Squirrel.app "/Library/Input Methods"
	"$(SQUIRREL_APP_PATH)/Contents/Resources/postflight"

install-release:
	rm -rf "$(SQUIRREL_APP_PATH)"
	cp -R build/Release/Squirrel.app "/Library/Input Methods"
	"$(SQUIRREL_APP_PATH)/Contents/Resources/postflight"

clean:
	rm -rf build > /dev/null 2>&1 || true
	rm build.log > /dev/null 2>&1 || true
	rm bin/* > /dev/null 2>&1 || true
	rm lib/* > /dev/null 2>&1 || true
	rm data/brise/* > /dev/null 2>&1 || true
	rm data/opencc/*.ocd > /dev/null 2>&1 || true
