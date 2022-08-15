package states;

import flixel.FlxSubState;
import flixel.FlxState;
import entities.ScoopCursor;
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

class ScoopState extends FlxSubState {
	var desired:IceCreamFlavor;

	var chocolate:FlxExtendedSprite;
	var vanilla:FlxExtendedSprite;
	var strawberry:FlxExtendedSprite;

	var returnState:TruckState;

	public function new(returnState:TruckState, desired:IceCreamFlavor) {
		super();

		this.desired = desired;

		this.returnState = returnState;
		bgColor = FlxColor.fromRGB(30, 30, 30, 128);
	}

	override public function create() {
		super.create();

		FlxG.camera.pixelPerfectRender = true;

		chocolate = new FlxExtendedSprite(10, 10, AssetPaths.chocolate_bin__png);
		// chocolate.makeGraphic(10, 10, FlxColor.BROWN);
		chocolate.x = 0;
		chocolate.y = FlxG.height - chocolate.height;
		chocolate.enableMouseClicks(false, true);
		chocolate.mousePressedCallback = onIceCreamClick(IceCreamFlavor.Chocolate);
		add(chocolate);

		vanilla = new FlxExtendedSprite(10, 10, AssetPaths.vanilla_bin__png);
		// vanilla.makeGraphic(10, 10, FlxColor.WHITE);
		vanilla.x = chocolate.x + chocolate.width + 5;
		vanilla.y = FlxG.height - vanilla.height;
		vanilla.enableMouseClicks(false, true);
		vanilla.mousePressedCallback = onIceCreamClick(IceCreamFlavor.Vanilla);
		add(vanilla);

		strawberry = new FlxExtendedSprite(10, 10, AssetPaths.strawberry_bin__png);
		// strawberry.makeGraphic(10, 10, FlxColor.PINK.getDarkened());
		strawberry.x = vanilla.x + vanilla.width + 5;
		strawberry.y = FlxG.height - strawberry.height;
		strawberry.enableMouseClicks(false, true);
		strawberry.mousePressedCallback = onIceCreamClick(IceCreamFlavor.Strawberry);
		add(strawberry);

		// Add cursor last so it is on top
		add(new ScoopCursor());
	}

	private function onIceCreamClick(key:IceCreamFlavor):FlxExtendedSprite->Int->Int->Void {
		return function(spr:FlxExtendedSprite, x:Int, y:Int) {
			trace('Ya dun clikd ${key}');
			// TODO: Need a transition here of some sort (swipe out?)
			close();
			returnState.openSubState(new ConeStackState(returnState, key, desired == key));
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
