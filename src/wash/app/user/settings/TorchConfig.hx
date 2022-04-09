package wash.app.user.settings;

import python.Bytearray;
import python.Syntax;
import python.lib.io.BufferedReader;
import python.lib.io.BufferedWriter;

import wash.app.ISettingsApplication;
import wash.event.TouchEvent;
import wash.widgets.Checkbox;
import wasp.Fonts;
import wasp.Watch;

@:keep
@:access(wash.app.user.Torch)
@:python('dotpath(wash.app.user.settings.TorchConfig)')
@:native('wash.app.user.settings.torchconfig.TorchConfig')
class TorchConfig extends BaseApplication implements ISettingsApplication {
	var initialState:Checkbox;
	var redLight:Checkbox;

	public function new(_) {
		super();
		NAME = "Torch App";

		initialState = new Checkbox(6, 90, "Initial state ON");
		redLight = new Checkbox(6, 140, "Use red light");
	}

	override public function touch(event:TouchEvent):Void {
		if (initialState.touch(event)) Torch.initialState = initialState.state;
		if (redLight.touch(event)) Torch.redLight = redLight.state;
	}

	public function draw():Void {
		var draw = Watch.drawable;
		draw.set_color(Wash.system.theme.highlight);
		draw.set_font(Fonts.sans24);
		draw.string(NAME, 0, 6, 240);

		initialState.state = Torch.initialState;
		redLight.state = Torch.redLight;

		initialState.draw();
		redLight.draw();
	}

	public function update():Void {}

	public static function serialize(f:BufferedWriter):Void {
		var bytes = new Bytearray(4);
		var i = 0;

		bytes[i++] = F_InitState;
		bytes[i++] = Torch.initialState ? 0x01 : 0x00;

		bytes[i++] = F_RedLight;
		bytes[i++] = Torch.redLight ? 0x01 : 0x00;

		f.write(bytes);
		bytes = null;
		Syntax.delete(bytes);
	}

	public static function deserialize(f:BufferedReader):Void {
		while (true) {
			var next = f.read(1);
			if (next == null) break;

			switch (next.get(0)) {
				case F_InitState:
					Torch.initialState = f.read(1).get(0) == 0x01;

				case F_RedLight:
					Torch.redLight = f.read(1).get(0) == 0x01;

				case 0x00:
					break;
			}
		}
	}
}

private enum abstract Field(Int) to Int {
	var F_InitState = 0x01;
	var F_RedLight = 0x02;
}
