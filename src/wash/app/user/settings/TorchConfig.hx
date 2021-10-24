package wash.app.user.settings;

import wash.app.IApplication.ISettingsApplication;
import wash.event.TouchEvent;
import wash.widgets.Checkbox;

@:access(wash.app.user.Torch)
class TorchConfig extends BaseApplication implements ISettingsApplication {
	var initialState:Checkbox;
	var redLight:Checkbox;

	public function new(_) {
		NAME = "Torch App";

		initialState = new Checkbox(6, 90, "Initial state ON");
		redLight = new Checkbox(6, 140, "Use red light");
	}

	override public function touch(event:TouchEvent):Void {
		if (initialState.touch(event)) Torch.initialState = initialState.state;
		if (redLight.touch(event)) Torch.redLight = redLight.state;
	}

	public function draw():Void {
		initialState.state = Torch.initialState;
		redLight.state = Torch.redLight;

		initialState.draw();
		redLight.draw();
	}

	public function update():Void {}
}
