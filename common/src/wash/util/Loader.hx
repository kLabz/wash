package wash.util;

import python.Syntax;

import wash.app.IApplication;

class Loader {
	public static function loadModule(path:String):Any {
		Syntax.exec('import $path as __tmp');
		var ret = Syntax.eval('__tmp');
		Syntax.exec('del __tmp');
		return ret;
	}

	public static function loadApp(path:String):IApplication {
		Syntax.exec('import $path.app as __tmp');
		var ret = Syntax.eval('__tmp.App()');
		Syntax.exec('del __tmp');
		Syntax.exec('del sys.modules["$path.app"]');
		return ret;
	}
}
