package wasp.driver;

import wash.util.TimeTuple;
import wash.util.DateTimeTuple;

extern class NRFRTC {
	var uptime:Int;
	function update():Bool;
	function set_localtime(time:DateTimeTuple):Void;
	function get_localtime():DateTimeTuple;
	function get_time():TimeTuple;
	function time():Int; // Seconds
	function get_uptime_ms():Int;
}
