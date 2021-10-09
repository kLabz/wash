package wasp.driver;

private typedef TODO = Any;

extern class ST7789 {
	var touch:TODO;

	function init_display():Void;
	function poweroff():Void;
	function poweron():Void;
	function invert(invert:Bool):Void;
	function mute(mute:Bool):Void;
	function set_window(x:Int, y:Int, width:Int, height:Int):Void;
	// TODO: pixel buffer type
	function rawblit(buf:TODO, x:Int, y:Int, width:Int, height:Int):Void;
	function fill(bg:Int, ?x:Int, ?y:Int, ?w:Int, ?h:Int):Void;
}
