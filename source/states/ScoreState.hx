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

class ScoreState extends FlxTransitionableState {

	var delay = 1.0;

	override public function create():Void {
		super.create();

		var allDigits:Array<FlxSprite> = [];

		var hundredsDigit = Std.int(TruckState.CustomersServed / 100);
		if (hundredsDigit > 0) {
			var hundreds = getDigit(hundredsDigit);
			allDigits.push(hundreds);
		}

		var tens = Std.int(TruckState.CustomersServed / 10);
		if (tens > 0) {
			var tens = getDigit(tens);
			allDigits.push(tens);
		}

		var single = getDigit(TruckState.CustomersServed % 10);
		allDigits.push(single);

		var digitsX = FlxG.width / 2;
		digitsX -= allDigits.length * 3;

		for (d in allDigits) {
			d.y = 20;
			d.x = digitsX;
			digitsX += 6;
		}

		var served = new FlxSprite(AssetPaths.served__png);
		served.screenCenter(X);
		served.y = 30;
		add(served);
	}

	function getDigit(num:Int):FlxSprite {
		var digit = new FlxSprite();
		digit.loadGraphic(AssetPaths.digits__png, true, 6, 7);
		digit.animation.add("digits", [ for (i in 0...10) i ], 0);
		digit.animation.play("digits", true, num);
		add(digit);
		return digit;
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);
		FmodManager.Update();

		delay -= elapsed;

		if (delay <= 0 && FlxG.mouse.justPressed) {
			clickEndState();
		}
	}

	function clickEndState():Void {
		FmodFlxUtilities.TransitionToState(new FailState());
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
