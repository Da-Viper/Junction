.PHONY: build run-host flatpak bundle test

build:
	# meson --reconfigure --prefix $(shell pwd)/install build
	meson --prefix $(shell pwd)/install build
	ninja -C build install

run-host:
	make clean
	make build
	GSETTINGS_SCHEMA_DIR=./data ./install/bin/re.sonny.Junction

flatpak:
	flatpak-builder --user  --force-clean --repo=repo --install-deps-from=flathub flatpak re.sonny.Junction.yaml
	flatpak --user remote-add --no-gpg-verify --if-not-exists Junction repo
	flatpak --user install --reinstall --assumeyes Junction re.sonny.Junction
	flatpak run re.sonny.Junction

bundle:
	flatpak-builder --user  --force-clean --repo=repo --install-deps-from=flathub flatpak re.sonny.Junction.yaml
	flatpak build-bundle repo Junction.flatpak re.sonny.Junction --runtime-repo=https://flathub.org/repo/flathub.flatpakrepo

test:
	./node_modules/.bin/eslint --cache .
	flatpak run org.freedesktop.appstream-glib validate data/re.sonny.Junction.appdata.xml
	desktop-file-validate --no-hints data/re.sonny.Junction.desktop
	# gtk-builder-tool validate src/*.ui
	gjs -m test/*.test.js

clean:
	rm -rf build install .eslintcache
