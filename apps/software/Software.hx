import python.Bytes;
import python.Syntax.bytes;
import python.Syntax.delete;
import python.Syntax.tuple;
import python.Tuple;
import python.lib.Os;
import python.lib.os.Path;

import wash.Wash;
import wasp.Watch;
import wash.app.BaseApplication;
import wash.event.EventMask;
import wash.event.TouchEvent;
import wash.util.Loader;
import wash.util.Math.opCeilDiv;
import wash.util.Math.opFloorDiv;
import wash.widgets.Checkbox;
import wash.widgets.ScrollIndicator;

@:pythonImport('app.software.manifest')
extern class Manifest {
	public static var NAME(default, null):String;
	public static var ICON(default, null):Bytes;
}

@:native('App')
class Software extends BaseApplication {
	static inline var PAGE_LEN:Int = 6;

	var db:Array<AppEntry>;
	var scroll:ScrollIndicator;
	var page:Int;

	public function new() {
		super();

		NAME = Manifest.NAME;
		ICON = Manifest.ICON;
	}

	override public function foreground():Void {
		var y = -40;
		function nextY():Int {
			y += 40;
			if (y > 200) y = 0;
			return y;
		}

		db = [];

		// TODO: set ROOT somewhere to work on both simulator, watch and watch in safe mode
		var appsDir = #if simulator 'wasp/app' #else 'app' #end;
		var apps = Os.listdir(appsDir);
		for (a in apps) {
			var appDir = '$appsDir/$a';
			if (Path.isdir(appDir)) {
				// TODO: also check for application file (app.py)
				if (Path.exists('$appDir/manifest.py')) {
					var manifest:ManifestData = Loader.loadModule('app.$a.manifest');
					if (manifest.NAME != "Apps") {
						db.push(AppEntry.make(
							manifest.NAME,
							'app.$a',
							nextY(),
							Wash.system.hasApplication('app.$a')
						));
					}
					delete(manifest);
				}
			}
		}

		var pages = opCeilDiv(db.length, PAGE_LEN) - 1;
		if (pages < 0) pages = 0;
		scroll = new ScrollIndicator(null, 0, pages, 0);
		page = 0;

		draw();
		Wash.system.requestEvent(EventMask.TOUCH | EventMask.SWIPE_UPDOWN);
	}

	override public function background():Void {
		// DataVault.save();

		scroll = null;
		delete(scroll);

		page = null;
		delete(page);

		db = null;
		delete(db);
	}

	function getPage():Array<AppEntry> return db.slice(page*PAGE_LEN, page*PAGE_LEN+PAGE_LEN);

	override public function swipe(event:TouchEvent):Bool {
		var pages = opFloorDiv(db.length - 1, PAGE_LEN);

		switch (event.type) {
			case DOWN: page = page > 0 ? page - 1 : pages;
			case UP: page = page < pages ? page + 1 : 0;
			case _:
		}

		Watch.display.mute(true);
		draw();
		Watch.display.mute(false);
		return false;
	}

	override public function touch(event:TouchEvent):Void {
		for (p in getPage()) {
			if (p.checkbox.touch(event)) {
				if (p.checkbox.state) Wash.system.registerApp(p.path);
				else Wash.system.unregisterApp(p.path);
				break;
			}
		}
	}

	function draw():Void {
		Watch.drawable.fill(0);
		for (p in getPage()) p.checkbox.draw();

		scroll.value = page;
		scroll.draw();
	}
}

@:native("tuple")
extern class AppEntry extends Tuple<Dynamic> {
	static inline function make(name:String, path:String, y:Int, checked:Bool):AppEntry {
		var checkbox = new Checkbox(2, y + 2, name);
		checkbox.state = checked;
		return tuple(name, path, checkbox);
	}

	var name(get, null):String;
	inline function get_name():String return this[0];

	var path(get, null):String;
	inline function get_path():String return this[1];

	var checkbox(get, null):Checkbox;
	inline function get_checkbox():Checkbox return this[2];
}

// TODO: move to own module
typedef ManifestData = {
	var NAME(default, null):String;
	var ICON(default, null):Bytes;
}
