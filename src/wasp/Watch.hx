/*
	Using real wasp-os (for now?). Needed (extern) fields:

	os.uname()
	button
	touch.sleep()
	touch.wake()
	touch.get_event()
	touch.reset_touch_data()
	backlight.set()
	rtc.update
	rtc.uptime
	rtc.time
	rtc.get_uptime_ms
	free
	vibrator.pulse()
	print_exception
	schedule
*/
package wasp;

import wasp.driver.Draw565;
import wasp.driver.ST7789;

import wasp.util.TimeTuple;

@:native('wasp.watch')
extern class Watch {
	static var drawable:Draw565;
	static var display:ST7789;
	static var vibrator:Vibrator;
	static var rtc:RTC;
	static var battery:Battery;

	static function connected():Bool;
	static function nop():Void;
}

// TODO: move to own module, add missing methods
extern class Vibrator {
	function pulse():Void;
}

// TODO: move to own module, add missing methods
extern class RTC {
	function get_localtime():TimeTuple;
	function get_uptime_ms():Int; // TODO: check if Int or Float
}

// TODO: move to own module, add missing methods
extern class Battery {
	function charging():Bool;
	function level():Int;
}
