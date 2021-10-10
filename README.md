# Haxe + wasp-os

[wasp-os](https://github.com/daniel-thompson/wasp-os) userland code, ported to Haxe and then modified to my taste.

This is **hugely** WIP material.

## Roadmap

* [x] Rewrite a simple app in Haxe, include it in wasp-os
* [-] Full extern API for:
	* [-] wasp.watch
	* [-] wasp.system
	* [ ] steplogger
* [-] Port widgets to Haxe
	* [x] ScrollIndicator
	* [x] Clock
	* [x] StatusBar
	* [x] BatteryMeter
	* [x] NotificationBar
	* [x] Button
	* [x] ToggleButton
	* [ ] Checkbox
	* [ ] GfxButton
	* [ ] Slider
	* [ ] Spinner
	* [ ] Stopwatch
	* [ ] ConfirmationView
* [ ] Port wasp.Manager to Haxe
* [-] Port other apps to Haxe:
	* [-] system apps
		* [x] launcher
		* [ ] settings
		* [ ] software
		* [ ] pager
		* [ ] NotificationApp (from pager module)
		* [ ] CrashApp (from pager module)
	* [-] user apps
		* [x] flashlight
		* [ ] alarm
		* [ ] calc
		* [ ] faces
		* [ ] heart
		* [ ] musicplayer
		* [ ] steps
		* [ ] stopwatch
		* [ ] timer
		* [ ] weather
	* [ ] watchfaces
		* [ ] klabz watchface
		* [ ] clock
		* [ ] dual_clock
		* [ ] chrono
		* [ ] fibonacci_clock (disabled)
		* [ ] word_clock (disabled)

* [ ] Transpile everything as `wasp.py`
* [ ] Integrate comments from wasp-os into Haxe versions
* [ ] Remove haxe things from wasp-os, use generated `wasp.py`

* [ ] Port steplogger to Haxe
* [ ] Port gadgetbridge integration to Haxe
* [ ] Port missing widgets
* [ ] Port missing apps

=> Start using hxwasp o/

### HxWasp improvements

* [ ] Include images as bytes with a compile-time macro
	* [x] Generate bytes literal from Haxe
	* [ ] Load images from aseprite file(s) directly
	* [ ] Rework theming
	* [ ] Apply theme in generated images

### Haxe changes

Needed Haxe changes to get a better output (which is needed for micropython):

* [x] Bytes literal
* [x] `//` operator
* [x] Array access without overhead
* [x] Do not generate `__slots__` (until supported by micropython)
* [ ] Skip generating empty classes/interfaces (should be fine with dce enabled?)

See https://github.com/kLabz/haxe/tree/feature/micropython-utils
