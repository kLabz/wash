package wash.app.system;

import python.Bytes;
import python.Syntax.bytes;
import python.Syntax.delete;
import python.Syntax.tuple;
import python.Syntax.opFloorDiv;
import python.Tuple;

import wasp.Watch;
import wash.app.user.Calc;
import wash.app.user.Stopclock;
import wash.app.user.Timer;
import wash.event.EventMask;
import wash.event.TouchEvent;
import wash.widgets.Checkbox;
import wash.widgets.ScrollIndicator;

@:native('SoftwareApp')
class Software extends BaseApplication {
	static var icon:Bytes = bytes(
		'\\x02',
		'@@',
		'?\\xff\\x8b\\x8a\\x08\\x8a"\\x8e\\x04\\x8e\\n\\xc2\\x14\\x8e\\x04\\x8e',
		'\\t\\xc4\\x12\\x90\\x02\\x90\\x08\\xc4\\x12\\x90\\x02\\x90\\x08\\xc4\\x12\\x90',
		'\\x02\\x90\\x08\\xc4\\x12\\x90\\x02\\x90\\x04\\xcc\\x0e\\x90\\x02\\x90\\x03\\xce',
		'\\r\\x90\\x02\\x90\\x03\\xce\\r\\x90\\x02\\x90\\x04\\xcc\\x0e\\x90\\x02\\x90',
		'\\x08\\xc4\\x12\\x90\\x02\\x90\\x08\\xc4\\x12\\x90\\x02\\x90\\x08\\xc4\\x13\\x8e',
		'\\x04\\x8e\\t\\xc4\\x13\\x8e\\x04\\x8e\\n\\xc2\\x16\\x8a\\x08\\x8a?e',
		'@\\xacJ\\x08\\x8a\\x08\\x8a\\x10N\\x04\\x8e\\x04\\x8e\\x0eN\\x04',
		'\\x8e\\x04\\x8e\\rP\\x02\\x90\\x02\\x90\\x0cP\\x02\\x90\\x02\\x90\\x0c',
		'P\\x02\\x90\\x02\\x90\\x0cP\\x02\\x90\\x02\\x90\\x0cP\\x02\\x90\\x02',
		'\\x90\\x0cP\\x02\\x90\\x02\\x90\\x0cP\\x02\\x90\\x02\\x90\\x0cP\\x02',
		'\\x90\\x02\\x90\\x0cP\\x02\\x90\\x02\\x90\\x0cP\\x02\\x90\\x02\\x90\\r',
		'N\\x04\\x8e\\x04\\x8e\\x0eN\\x04\\x8e\\x04\\x8e\\x10J\\x08\\x8a\\x08',
		'\\x8a?SJ\\x08J\\x08\\x8a\\x10N\\x04N\\x04\\x8e\\x0eN',
		'\\x04N\\x04\\x8e\\rP\\x02P\\x02\\x90\\x0cP\\x02P\\x02\\x90',
		'\\x0cP\\x02P\\x02\\x90\\x0cP\\x02P\\x02\\x90\\x0cP\\x02P',
		'\\x02\\x90\\x0cP\\x02P\\x02\\x90\\x0cP\\x02P\\x02\\x90\\x0cP',
		'\\x02P\\x02\\x90\\x0cP\\x02P\\x02\\x90\\x0cP\\x02P\\x02\\x90',
		'\\rN\\x04N\\x04\\x8e\\x0eN\\x04N\\x04\\x8e\\x10J\\x08J',
		'\\x08\\x8a?\\xff\\x0b'
	);

	var db:Array<AppEntry>;
	var scroll:ScrollIndicator;
	var page:Int;

	public function new() {
		NAME = "Apps";
		ICON = icon;
	}

	override public function foreground():Void {
		var y = -40;
		function nextY():Int {
			y += 40;
			if (y > 160) y = 0;
			return y;
		}

		db = [];
		db.push(AppEntry.make(Calc, "Calc", nextY(), Wash.system.hasApplication(Calc)));
		db.push(AppEntry.make(Stopclock, "Stopwatch", nextY(), Wash.system.hasApplication(Stopclock)));
		db.push(AppEntry.make(Timer, "Timer", nextY(), Wash.system.hasApplication(Timer)));
		// TODO: other apps

		scroll = new ScrollIndicator();
		page = 0;

		draw();
		Wash.system.requestEvent(EventMask.TOUCH | EventMask.SWIPE_UPDOWN);
	}

	override public function background():Void {
		scroll = null;
		delete(scroll);

		page = null;
		delete(page);

		db = null;
		delete(db);
	}

	function getPage():Array<AppEntry> return db.slice(page*5, page*5+5);

	override public function swipe(event:TouchEvent):Bool {
		var pages = opFloorDiv(db.length - 1, 5);

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
				if (p.checkbox.state) Wash.system.register(p.cls);
				else Wash.system.unregister(p.cls);
				break;
			}
		}
	}

	function draw():Void {
		Watch.drawable.fill();
		scroll.draw();
		for (p in getPage()) p.checkbox.draw();
	}
}

@:native("tuple")
extern class AppEntry extends Tuple<Dynamic> {
	static inline function make(
		cls:Class<IApplication>, label:String, y:Int, checked:Bool
	):AppEntry {
		var checkbox = new Checkbox(0, y, label);
		checkbox.state = checked;
		return tuple(cls, label, checkbox);
	}

	var cls(get, null):Class<IApplication>;
	inline function get_cls():Class<IApplication> return this[0];

	var label(get, null):String;
	inline function get_label():String return this[1];

	var checkbox(get, null):Checkbox;
	inline function get_checkbox():Checkbox return this[2];
}
