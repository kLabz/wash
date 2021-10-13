package wasp;

import python.Bytes;

@:pythonImport('fonts')
extern class Fonts {
	static var sans18:Bytes;
	static var sans24:Bytes;
	static var sans28:Bytes;
	static var sans36:Bytes;

	static function width(font:Bytes, str:String):Int;
}
