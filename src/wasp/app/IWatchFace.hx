package wasp.app;

@:dce @:remove
interface IWatchFace extends IApplication {
	public function preview():Void;
}
