package states;

import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import haxefmod.flixel.FmodFlxUtilities;

using extensions.FlxStateExt;

class CreditsState extends FlxTransitionableState {
	private var backgroundColor = FlxColor.CYAN.getLightened();
	var transitioning = false;

	override public function create():Void {
		super.create();
		bgColor = backgroundColor;
		camera.pixelPerfectRender = true;

		var bgImg = new FlxSprite(AssetPaths.credit_names__png);
		add(bgImg);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		if (FlxG.mouse.pressed && !transitioning) {
			clickMainMenu();
		}
	}

	function clickMainMenu():Void {
		transitioning = true;
		FmodFlxUtilities.TransitionToState(new MainMenuState());
	}

	override public function onFocusLost() {
		super.onFocusLost();
		this.handleFocusLost();
	}

	override public function onFocus() {
		super.onFocus();
		this.handleFocus();
	}
}
