package wasp;

extern class Draw565 {
	function reset():Void;
	function fill(?color:Int, ?x:Int, ?y:Int, ?w:Int, ?h:Int):Void;
	// TODO: blit()
	// TODO: rleblit()
	// TODO: set_color()
	// TODO: set_font()
	// TODO: string()
	// TODO: bounding_box()
	// TODO: wrap()
	function line(x0:Int, y0:Int, x1:Int, y1:Int, ?width:Int, ?color:Int):Void;
	// TODO: polar
	// TODO: lighten
	// TODO: darken
}
