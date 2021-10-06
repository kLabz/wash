# Haxe + wasp-os

[wasp-os](https://github.com/daniel-thompson/wasp-os) userland code, ported to Haxe and then modified to my taste.

This is **hugely** WIP material.

## Roadmap

* [x] Rewrite a simple app in Haxe, include it in wasp-os
* [ ] Full extern API for:
	* [ ] wasp.watch
	* [ ] wasp.system
	* [ ] wasp itself (?)
	* [ ] widgets
	* [ ] steplogger
* [ ] Port wasp and wasp.Manager to Haxe
* [ ] Port other apps to Haxe:
	* [ ] launcher
	* [ ] settings
	* [ ] software
	* [ ] user apps
* [ ] Port steplogger to Haxe
* [ ] Port gadgetbridge integration to Haxe
* [ ] Include images as bytes with a compile-time macro
	* [x] Generate bytes literal from Haxe
	* [ ] Load images from aseprite file(s) directly
	* [ ] Rework theming
	* [ ] Apply theme in generated images
