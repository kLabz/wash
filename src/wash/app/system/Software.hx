package wash.app.system;

import python.Syntax.bytes;
import python.Syntax.delete;
import python.Syntax.tuple;
import python.Tuple;

import wasp.Watch;
import wash.app.user.AlarmApp;
// import wash.app.user.Calc;
import wash.app.user.HeartApp;
// import wash.app.user.StepCounter;
// import wash.app.user.Stopclock;
// import wash.app.user.Timer;
import wash.event.EventMask;
import wash.event.TouchEvent;
import wash.widgets.Checkbox;
import wash.widgets.ScrollIndicator;

@:native('SoftwareApp')
class Software extends BaseApplication {
	static inline var PAGE_LEN:Int = 6;

	var db:Array<AppEntry>;
	var scroll:ScrollIndicator;
	var page:Int;

	public function new() {
		super();

		NAME = "Apps";
		ICON = bytes(
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
	}

	override public function foreground():Void {
		var y = -40;
		function nextY():Int {
			y += 40;
			if (y > 200) y = 0;
			return y;
		}

		db = [];
		db.push(AppEntry.make(AlarmApp, "Alarms", nextY(), Wash.system.hasApplication(AlarmApp)));
		// db.push(AppEntry.make(Calc, "Calc", nextY(), Wash.system.hasApplication(Calc)));
		db.push(AppEntry.make(HeartApp, "Heart", nextY(), Wash.system.hasApplication(HeartApp)));
		// db.push(AppEntry.make(StepCounter, "Step counter", nextY(), Wash.system.hasApplication(StepCounter)));
		// db.push(AppEntry.make(Stopclock, "Stopwatch", nextY(), Wash.system.hasApplication(Stopclock)));
		// db.push(AppEntry.make(Timer, "Timer", nextY(), Wash.system.hasApplication(Timer)));
		// TODO: other apps

		// TODO: user-loaded applications

		var pages = opCeilDiv(db.length, PAGE_LEN) - 1;
		scroll = new ScrollIndicator(null, 0, pages, 0);
		page = 0;

		draw();
		Wash.system.requestEvent(EventMask.TOUCH | EventMask.SWIPE_UPDOWN);
	}

	override public function background():Void {
		DataVault.save();

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
				if (p.checkbox.state) Wash.system.register(p.cls);
				else Wash.system.unregister(p.cls);
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
	static inline function make(
		cls:Class<IApplication>, label:String, y:Int, checked:Bool
	):AppEntry {
		var checkbox = new Checkbox(2, y + 2, label);
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
