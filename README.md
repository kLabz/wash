# Haxe + wasp-os

[wasp-os](https://github.com/daniel-thompson/wasp-os) userland code, ported to Haxe and then modified to my taste.

This is **hugely** WIP material.

## Roadmap

* [x] Rewrite a simple app in Haxe, include it in wasp-os
* [-] Full extern API for:
	* [-] wasp.watch
	* [-] wasp.system
	* [ ] steplogger
* [x] Port widgets to Haxe
	* [x] ScrollIndicator
	* [x] Clock
	* [x] StatusBar
	* [x] BatteryMeter
	* [x] NotificationBar
	* [x] Button
	* [x] ToggleButton
	* [x] Checkbox
	* [x] GfxButton
	* [x] Slider
	* [x] Spinner
	* [x] Stopwatch
	* [x] ConfirmationView
* [-] Port wasp.Manager to Haxe
	* [x] MVP wasp.py generated via Haxe, running apps in simulator
	* [x] Notifications handling (untested)
	* [ ] Adjustement to work on real watch
* [-] Port other apps to Haxe:
	* [x] system apps
		* [x] launcher
		* [x] settings
		* [x] software
		* [x] PagerApp
		* [x] NotificationApp (from pager module)
		* [x] CrashApp (from pager module)
	* [-] user apps
		* [x] flashlight
		* [x] stopwatch
		* [x] timer
		* [ ] alarm
		* [ ] calc
		* [ ] heart
		* [ ] musicplayer
		* [ ] weather
		* [ ] steps
		* [ ] faces
	* [-] watchfaces
		* [x] BatTri watchface
		* [ ] clock
		* [ ] dual_clock
		* [ ] chrono
		* [ ] fibonacci_clock (disabled)
		* [ ] word_clock (disabled)

* [x] Transpile everything as `wasp.py`
* [ ] Integrate comments from wasp-os into Haxe versions

* [ ] Port steplogger to Haxe
* [ ] Port gadgetbridge integration to Haxe
* [x] Port missing widgets
* [ ] Port missing apps

=> Start using hxwasp o/

### HxWasp improvements

* [ ] Include images as bytes with a compile-time macro
	* [x] Generate bytes literal from Haxe
	* [ ] Generate bytes literal from image files at compile time
	* [ ] Load images from aseprite file(s) directly
	* [ ] Rework theming (started in wasp-os fork)
	* [x] Apply theme in generated images

### Haxe changes

Needed Haxe changes to get a better output (which is needed for micropython):

* [x] Bytes literal
* [x] `//` operator
* [x] Array access without overhead
* [x] Do not generate `__slots__` (until supported by micropython)
* [x] `NativeArrayTools.nativeSort()`
* [-] Implement @:selfCall for python
* [ ] Add `@micropython.native` runtime metadata
* [ ] Skip all the unneeded code when doing `try / catch (e:SomeException)`
* [ ] Skip generating empty classes/interfaces

See https://github.com/kLabz/haxe/tree/feature/micropython-utils
