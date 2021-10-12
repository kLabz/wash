package wasp.driver;

import python.Bytes;

extern class Draw565 {
	function reset():Void;
	function fill(?color:Int, ?x:Int, ?y:Int, ?w:Int, ?h:Int):Void;
	function blit(image:Bytes, x:Int, y:Int, ?fg:Int, ?c1:Int, ?c2:Int, ?forceRecolor:Bool):Void;
	// TODO: rleblit()
	function set_color(color:Int, ?bg:Int):Void;
	function set_font(font:Bytes):Void;
	function string(s:String, x:Int, y:Int, ?width:Int, ?right:Bool):Void;
	// TODO: bounding_box()
	// TODO: wrap()
	function line(x0:Int, y0:Int, x1:Int, y1:Int, ?width:Int, ?color:Int):Void;
	// TODO: polar
	function lighten(color:Int, ?step:Int):Int;
	function darken(color:Int, ?step:Int):Int;
}
