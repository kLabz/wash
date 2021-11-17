package wash.app;

@:dce @:remove
interface ISettingsApplication extends IApplication {
	public function draw():Void;
	public function update():Void;
}
