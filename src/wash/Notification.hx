package wash;

import python.Dict;
import python.Syntax;
import python.Tuple;

@:native("tuple")
extern class Notification extends Tuple<Dynamic> {
	static inline function make(id:Int, content:NotificationContent):Notification
		return Syntax.tuple(id, content);

	var id(get, null):Int;
	inline function get_id():Int return this[0];

	var content(get, null):NotificationContent;
	inline function get_content():NotificationContent return this[1];
}

abstract NotificationContent(Dict<String, Any>) {
	public var title(get, never):String;
	function get_title():String return this.hasKey("title") ? this.getSafe("title") : "";

	public var body(get, never):String;
	function get_body():String return this.hasKey("body") ? this.getSafe("body") : "";
}
