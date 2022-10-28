_build-glfw:
	cmake -S vendor/glfw -B vendor/glfw/_build
	cd vendor/glfw/_build && make

_build-epoxy:
	mkdir -p vendor/libepoxy/_build
	cd vendor/libepoxy/_build && meson && ninja && sudo ninja install

build-deps: _build-epoxy _build-glfw

pull-deps:
	git submodule update --init --recursive --remote

clean-deps:
	rm -rf vendor/libepoxy/_build
	rm -rf vendor/glfw/_build

install-deps: clean-deps pull-deps build-deps
