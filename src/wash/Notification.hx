package wash;

import python.Dict;

abstract Notification(Dict<String, Any>) {
	public var title(get, never):String;
	function get_title():String return this.getSafe("title");

	public var body(get, never):String;
	function get_body():String return this.getSafe("body");
}
