package wasp;

@:pythonImport('gc')
@:native('gc')
extern class Gc {
	static function collect():Void;

	#if simulator
	static inline function mem_free():Int return 4242;
	#else
	static function mem_free():Int;
	#end
}
