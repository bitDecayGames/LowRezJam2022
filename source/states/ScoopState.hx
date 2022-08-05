package states;

import entities.IceCreamFlavor;
import flixel.addons.plugin.FlxMouseControl;
import flixel.addons.display.FlxExtendedSprite;
import flixel.util.FlxColor;
import achievements.Achievements;
import flixel.addons.transition.FlxTransitionableState;
import signals.Lifecycle;
import entities.Player;
import flixel.FlxSprite;
import flixel.FlxG;

using extensions.FlxStateExt;

class ScoopState extends FlxTransitionableState {
	var player:FlxSprite;

	var chocolate:FlxExtendedSprite;
	var vanilla:FlxExtendedSprite;
	var strawberry:FlxExtendedSprite;

	override public function create() {
		super.create();

		if (FlxG.plugins.get(FlxMouseControl) == null) {
			FlxG.plugins.add(new FlxMouseControl());
		}

		FlxG.camera.pixelPerfectRender = true;

		chocolate = new FlxExtendedSprite(10, 10);
		chocolate.makeGraphic(10, 10, FlxColor.BROWN);
		chocolate.x = 5;
		chocolate.y = FlxG.height - 10;
		chocolate.enableMouseClicks(false, true);
		chocolate.mousePressedCallback = onIceCreamClick(IceCreamFlavor.Chocolate);
		add(chocolate);

		vanilla = new FlxExtendedSprite(10, 10);
		vanilla.makeGraphic(10, 10, FlxColor.WHITE);
		vanilla.x = chocolate.x + chocolate.width + 5;
		vanilla.y = FlxG.height - 10;
		vanilla.enableMouseClicks(false, true);
		vanilla.mousePressedCallback = onIceCreamClick(IceCreamFlavor.Vanilla);
		add(vanilla);

		strawberry = new FlxExtendedSprite(10, 10);
		strawberry.makeGraphic(10, 10, FlxColor.PINK.getDarkened());
		strawberry.x = vanilla.x + vanilla.width + 5;
		strawberry.y = FlxG.height - 10;
		strawberry.enableMouseClicks(false, true);
		strawberry.mousePressedCallback = onIceCreamClick(IceCreamFlavor.Strawberry);
		add(strawberry);
	}

	private function onIceCreamClick(key:IceCreamFlavor):FlxExtendedSprite->Int->Int->Void {
		return function(spr:FlxExtendedSprite, x:Int, y:Int) {
			trace('Ya dun clikd ${key}');
			// TODO: Need a transition here of some sort (swipe out?)
			FlxG.switchState(new ConeStackState(key));
		}
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);
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
