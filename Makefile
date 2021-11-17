# TODO: haxe executable path as variable
# TODO: factorize apps

all: apps core

core:
	./haxe/haxe build-core.hxml

alarmApp:
	./haxe/haxe --cwd apps/alarm build.hxml

softwareApp:
	./haxe/haxe --cwd apps/software build.hxml

apps: alarmApp softwareApp
