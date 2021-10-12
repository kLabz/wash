package wasp.util;

@:pythonImport('gc')
@:native('gc')
extern class Gc {
	static function collect():Void;
	static function mem_free():Int;
}
