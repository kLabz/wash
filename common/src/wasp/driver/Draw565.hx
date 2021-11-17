package wasp.driver;

import python.Bytes;

import wash.Wash;
import wash.util.PointTuple;

// TODO: double check default values
extern class Draw565 {
	var _display:Display;

	function reset():Void;

	inline function fill(
		?color:Null<Int> = null, ?x:Int = 0, ?y:Int = 0, ?w:Null<Int> = null, ?h:Null<Int> = null
	):Void _fill(color, x, y, w, h);
	@:native('fill') private function _fill(color:Null<Int>, x:Int, y:Int, w:Null<Int>, h:Null<Int>):Void;

	inline function blit(
		image:Bytes, x:Int, y:Int, ?fg:Int = 0xffff, ?c1:Int = 0x4a69, ?c2:Int = 0x7bef, ?forceRecolor:Bool = false
	):Void _blit(image, x, y, fg, c1, c2, forceRecolor);
	@:native('blit') private function _blit(image:Bytes, x:Int, y:Int, fg:Int, c1:Int, c2:Int, forceRecolor:Bool):Void;

	inline function recolor(image:Bytes, x:Int, y:Int):Void
		_blit(
			image,
			x,
			y,
			Wash.system.theme.highlight,
			Wash.system.theme.secondary,
			Wash.system.theme.primary,
			true
		);

	// TODO: rleblit()
	function set_color(color:Int, bg:Int = 0):Void;
	function set_font(font:Bytes):Void;
	function string(s:String, x:Int, y:Int, width:Int = 0, right:Bool = false):Void;
	function bounding_box(s:String):PointTuple;
	// TODO: wrap()
	function wrap(s:String, width:Int):Array<Int>; // TODO: check return type
	function line(x0:Int, y0:Int, x1:Int, y1:Int, width:Int = 0, color:Int = 0):Void;
	// TODO: polar
	function lighten(color:Int, step:Int = 0):Int;
	function darken(color:Int, step:Int = 0):Int;
}

extern class Display {
	var linebuffer:Bytes;

	function quick_start():Void;
	function quick_end():Void;
	function quick_write(buf:Bytes):Void;
	function set_window(x:Int, y:Int, w:Int, h:Int):Void;
}

@:pythonImport('draw565', '_fill')
extern class Fill {
	@:selfCall
	static function fill(b:Bytes, color:Int, count:Int, offset:Int):Void;
}
