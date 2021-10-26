# Watch Application System in Haxe

[wasp-os](https://github.com/daniel-thompson/wasp-os) userland code, ported to Haxe and then modified to my taste.

This is **hugely** WIP material.

What it currently does:
* Run on simulator or on a [pinetime watch](https://www.pine64.org/pinetime/)
* Display date / time / battery level
* Display notifications

Available apps:
* Alarms
* Calculator
* Flashlight/Torch app
* StopWatch
* Timer

## Haxe changes

Needed Haxe changes to get a better output (which is needed for micropython):

* [x] Bytes literal
* [x] `//` operator
* [x] Array access without overhead
* [x] Do not generate `__slots__` (until supported by micropython)
* [x] `NativeArrayTools.nativeSort()`
* [x] Add `@micropython.native` runtime metadata (undocumented `@:python("micropython.native")`)
* [-] Implement @:selfCall for python
* [ ] Skip all the unneeded code when doing `try / catch (e:SomeException)`
* [ ] Skip generating empty classes/interfaces
* [ ] Avoid iterator mess more easily

See https://github.com/kLabz/haxe/tree/feature/micropython-utils or [`haxe` submodule](./haxe).

