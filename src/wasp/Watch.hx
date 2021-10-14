package wasp;

import wasp.driver.Draw565;
import wasp.driver.ST7789;
import wasp.event.TouchEvent;
import wasp.util.TimeTuple;

@:pythonImport('watch')
extern class Watch {
	static var drawable:Draw565;
	static var display:ST7789;
	static var vibrator:Vibrator;
	static var rtc:RTC;
	static var battery:Battery;
	static var backlight:Backlight;
	static var accel:Accelerometer;
	static var button:Button;
	static var touch:Touch;
	static var free:Int;

	dynamic static function schedule():Void;

	static function connected():Bool;
	static function nop():Void;
	#if simulator static function print_exception(e:python.Exceptions.BaseException):Void; #end
}

// TODO: move to own module, add missing methods
extern class Vibrator {
	function pulse():Void;
}

// TODO: move to own module, add missing methods
extern class RTC {
	var uptime:Int;
	function update():Bool; // TODO: check type
	function get_localtime():TimeTuple;
	function get_uptime_ms():Int; // TODO: check if Int or Float
	function set_localtime(time:TimeTuple):Void;
}

// TODO: move to own module, add missing methods
extern class Battery {
	function charging():Bool;
	function level():Int;
}

// TODO: move to own module, add missing methods
extern class Backlight {
	function set(level:Int):Void;
}

// TODO: move to own module, add missing methods
extern class Touch {
	function sleep():Void;
	function wake():Void;
	function get_event():Null<TouchEvent>;
	function reset_touch_data():Void;
}

// TODO: move to own module, add missing methods
extern class Button {
	function value():Null<Bool>;
}

// TODO: move to own module, add missing methods
extern class Accelerometer {
	var steps:Int;
}
