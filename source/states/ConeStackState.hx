package states;

import entities.IceCreamFlavor;
import flixel.util.FlxSpriteUtil;
import flixel.tweens.FlxEase;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.addons.plugin.FlxMouseControl;
import flixel.addons.display.FlxExtendedSprite;
import flixel.util.FlxColor;
import achievements.Achievements;
import flixel.addons.transition.FlxTransitionableState;

import flixel.FlxSprite;
import flixel.FlxG;

using extensions.FlxStateExt;

class ConeStackState extends FlxTransitionableState {
	var flavor:IceCreamFlavor;

	var cone:FlxSprite;
	var scoop:FlxSprite;
	var iceCreamBall:FlxSprite;
	var coneTween:FlxTween;

	var triggered = false;

	public function new(flavor:IceCreamFlavor) {
		super();

		this.flavor = flavor;
	}

	override public function create() {
		super.create();

		if (FlxG.plugins.get(FlxMouseControl) == null) {
			FlxG.plugins.add(new FlxMouseControl());
		}

		FlxG.camera.pixelPerfectRender = true;

		cone = new FlxSprite(5, 15);
		cone.x = cone.width;
		cone.y = FlxG.height - cone.height - 5;
		cone.makeGraphic(5, 15, FlxColor.BROWN.getLightened());
		add(cone);

		coneTween = FlxTween.linearPath(cone, [
			new FlxPoint(0, FlxG.height - cone.height - 5),
			new FlxPoint(FlxG.width-cone.width, FlxG.height - cone.height - 5)
		], 1, true, {
			type: FlxTweenType.PINGPONG,
			ease: FlxEase.sineInOut,
		});

		iceCreamBall = new FlxSprite(5, 5);
		iceCreamBall.makeGraphic(5, 5, switch (flavor) {
			case Chocolate:
				FlxColor.BROWN;
			case Vanilla:
				FlxColor.WHITE;
			case Strawberry:
				FlxColor.PINK.getDarkened();
		});
		iceCreamBall.x = FlxG.width / 2 - 5;
		iceCreamBall.y = 5;
		add(iceCreamBall);

		scoop = new FlxSprite(20, 5);
		scoop.makeGraphic(20, 5, FlxColor.GRAY);
		scoop.x = FlxG.width / 2;
		scoop.y = 5;
		add(scoop);
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (!triggered && FlxG.mouse.justPressed) {
			triggered = true;
			iceCreamBall.acceleration.y = 120;
		}

		FlxG.collide(cone, iceCreamBall, handleFinish);

		if (iceCreamBall.y  > FlxG.height) {
			coneTween.cancel();
			trace("you failed");
		}
	}

	function handleFinish(c:FlxSprite, i:FlxSprite) {
		coneTween.cancel();
		trace("nice plopper");
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
