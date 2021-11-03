# Watch Application System in Haxe

[wasp-os](https://github.com/daniel-thompson/wasp-os) userland code, ported to Haxe and then modified to my taste.

This is **hugely** WIP material. See [#20](/../../issues/20) for some screenshots.

What it currently does:
* Run on simulator or on a [pinetime watch](https://www.pine64.org/pinetime/)
* Display date / time / battery level
* Display notifications
* Count steps (logging still missing, see [#13](/../../issues/13))
* Monitor heart rate (background monitoring still WIP, see [#24](/../../issues/24))

Available apps:
* Alarms
* Calculator
* Flashlight/Torch app
* Heart rate monitoring
* Night mode switcher
* Steps counter
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
* [-] Add support for positional arguments, sometimes mandatory with micropython
* [ ] Skip all the unneeded code when doing `try / catch (e:SomeException)`
* [ ] Skip generating empty classes/interfaces
* [ ] Avoid iterator mess more easily

See https://github.com/kLabz/haxe/tree/feature/micropython-utils or [`haxe` submodule](./haxe).

