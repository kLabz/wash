package wasp;

@:pythonImport('micropython')
@:native('micropython')
extern class Micropython {
	static function schedule(work:Void->Void, ctx:Any):Void;
}
