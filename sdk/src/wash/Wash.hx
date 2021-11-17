package wash;

@:native('Wasp')
@:pythonImport('wasp')
// @:pythonImport('wasp', 'Wasp')
extern class Wash {
	@:native('Wasp.system')
	public static var system(default, null):Manager;
}
