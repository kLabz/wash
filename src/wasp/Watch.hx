package wasp;

import python.Bytearray;

import wash.event.TouchEvent;
import wash.util.TimeTuple;
import wasp.driver.Draw565;
import wasp.driver.ST7789;

@:pythonImport('watch')
extern class Watch {
	static var drawable:Draw565;
	static var display:ST7789;
	static var vibrator:Vibrator;
	static var hrs:HRS;
	static var rtc:RTC;
	static var battery:Battery;
	static var backlight:Backlight;
	static var accel:Accelerometer;
	static var button:WatchButton;
	static var touch:Touch;
	static var free:Int;

	dynamic static function schedule():Void;

	static function connected():Bool;
	static function nop():Void;
	#if simulator static function print_exception(e:python.Exceptions.BaseException):Void; #end
}

// TODO: move to own module, add missing methods
extern class Vibrator {
	function pulse(?duty:Int, ?ms:Int):Void;
}

// TODO: move to own module, add missing methods
extern class HRS {
	function enable():Void;
	function disable():Void;
	function read_hrs():Int;
}

// TODO: move to own module, add missing methods
@:pythonImport('ppg', 'PPG')
extern class PPG {
	var data:Bytearray;
	function new(spl:Int);
	function enable_debug():Void;
	function get_heart_rate():Int;
	function preprocess(spl:Int):Int;
}

// TODO: move to own module, add missing methods
extern class RTC {
	var uptime:Int;
	function update():Bool;
	function time():Int; // Seconds
	function get_localtime():TimeTuple;
	function get_uptime_ms():Int;
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
extern class WatchButton {
	function value():Null<Bool>;
}

// TODO: move to own module, add missing methods
extern class Accelerometer {
	var steps:Int;
}
