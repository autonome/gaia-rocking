BASE_URL=http://ftp.mozilla.org/pub/mozilla.org/b2g/nightly/2012-07-21-03-06-00-mozilla-central
SYS=$(shell uname -s)
ARCH?=$(shell uname -m)
DMG=b2g-16.0a1.en-US.mac64.dmg
OSX=$(BASE_URL)/$(DMG)

CWD=`pwd`
MOUNTPOINT=/Volumes/B2G
APP=B2G.app
DMG_APP_PATH=$(MOUNTPOINT)/$(APP)
APP_PATH=$(CWD)/bin/$(APP)

# installation of the B2G.app on OS X
get_dmg:
	echo "Downloading latest B2G desktop build."
	mkdir -p ./tmp && rm -fr ./tmp/* && cd ./tmp && curl -O $(OSX)

mount_dmg:
	echo "Mounting disk image"
	cd ./tmp && hdiutil mount $(DMG)

install_app: get_dmg mount_dmg
	echo "Moving B2G app to the bin dir"
	cp -r $(DMG_APP_PATH) $(APP_PATH) && hdiutil unmount $(MOUNTPOINT)

install_xulrunner:
	cd $(CWD)/gaia && make install-xulrunner-sdk

setup: install_app install_xulrunner clean

# for running B2G
generate_profile:
	cd $(CWD)/gaia && DEBUG=1 GAIA_PORT=:7999 make
	# cd $(CWD)/gaia && make

run: generate_profile
	$(APP_PATH)/Contents/MacOS/b2g -profile $(CWD)/gaia/profile &
	sleep 1 && osascript -e 'tell app "B2G" to activate'

# utility 
clean:
	rm -fr ./tmp/*

cleaner: clean
	rm -fr ./bin/$(APP)

update:
	git submodule update

update_app: cleaner install_app
