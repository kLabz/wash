package wash.app.system;

// TODO: remove wasp. once widgets are built separately
@:native('wasp.DataVault')
// @:pythonImport('wasp', 'DataVault')
// @:pythonImport('app.system.datavault', 'DataVault')
extern class DataVault {
	static function load():Void;
	static function save():Void;
}
