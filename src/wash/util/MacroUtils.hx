package wash.util;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

class MacroUtils {
	public static macro function importString(e:Expr) {
		switch (Context.typeof(e)) {
			case TType(_.get() => cls, []):
				var lower = cls.module.toLowerCase();
				return macro $v{lower};

			case _: throw 'Invalid use of localImport()';
		}
	}

	public static macro function localImport(e:Expr) {
		switch (Context.typeof(e)) {
			case TType(_.get() => cls, []):
				var lower = cls.module.toLowerCase();
				var mangled = mangle(cls.module);

				return macro python.Syntax.code(
					$v{
						'from ' + lower + ' import ' + mangled
						// TODO: can't get comments in generated ast, need to
						// find another way to skip auto import on
						// postprocessing...
						// + ' # Skip import ' + mangled
					}
				);

			case _: throw 'Invalid use of localImport()';
		}
	}

	public static macro function lazyLoad(e:Expr) {
		switch (Context.typeof(e)) {
			case TType(_.get() => cls, []):
				var lower = cls.module.toLowerCase();
				var mangled = mangle(cls.module);

				return macro {
					python.Syntax.code(
						$v{'from ' + lower + ' import ' + mangled + ' as _tmp'}
					);
					untyped _tmp;
				};

			case _: throw 'Invalid use of localImport()';
		}
	}

	static function mangle(s:String):String {
		return ~/[^a-zA-Z0-9_]/g.replace(s, '_');
	}
}
