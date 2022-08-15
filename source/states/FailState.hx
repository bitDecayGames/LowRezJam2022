package states;

import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.util.FlxColor;
import haxefmod.flixel.FmodFlxUtilities;
import helpers.UiHelpers;
import misc.FlxTextFactory;

using extensions.FlxStateExt;

class FailState extends FlxTransitionableState {

	var delay = 1.0;

	override public function create():Void {
		super.create();

		var bg = new FlxSprite();
		bg.loadGraphic(AssetPaths.gameOver__png, true, 64, 64);
		bg.animation.add("play", [ for (i in 0...9) i ], 10);
		bg.animation.play("play");
		add(bg);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		FmodManager.Update();

		delay -= elapsed;

		if (delay <= 0 && FlxG.mouse.justPressed) {
			clickMainMenu();
		}
	}

	function clickMainMenu():Void {
		FmodFlxUtilities.TransitionToState(new CreditsState());
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
