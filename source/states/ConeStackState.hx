package states;

import entities.games.conestack.IceCreamBall;
import haxe.Timer;
import flixel.FlxSubState;
import flixel.FlxState;
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

class ConeStackState extends FlxSubState {
	var flavor:IceCreamFlavor;

	var cone:FlxSprite;
	var scoop:FlxSprite;
	var iceCreamBall:IceCreamBall;
	var coneTween:FlxTween;

	var dropTriggered = false;
	var plopOccurred = false;

	var returnState:FlxState;

	var splats = [
		IceCreamFlavor.Chocolate => AssetPaths.chocolate_plop__png,
		IceCreamFlavor.Vanilla => AssetPaths.vanilla_plop__png,
		IceCreamFlavor.Strawberry => AssetPaths.strawberry_plop__png,
	];

	public function new(returnState:FlxState, flavor:IceCreamFlavor) {
		super();

		this.flavor = flavor;
		this.returnState = returnState;
		bgColor = FlxColor.fromRGB(30, 30, 30, 128);

	}

	override public function create() {
		super.create();

		if (FlxG.plugins.get(FlxMouseControl) == null) {
			FlxG.plugins.add(new FlxMouseControl());
		}

		FlxG.camera.pixelPerfectRender = true;

		cone = new FlxSprite(5, 15, AssetPaths.cake_cone__png);
		add(cone);

		coneTween = FlxTween.linearPath(cone, [
			new FlxPoint(0, FlxG.height - cone.height),
			new FlxPoint(FlxG.width-cone.width+1, FlxG.height - cone.height)
		], 1, true, {
			type: FlxTweenType.PINGPONG,
			ease: FlxEase.sineInOut,
		});

		iceCreamBall = new IceCreamBall(flavor);
		add(iceCreamBall);

		scoop = new FlxSprite();
		scoop.loadGraphic(AssetPaths.big_scoop_1__png, true, 43, 22);
		scoop.animation.add('idle', [0]);
		scoop.animation.add('flip', [1, 2], false);
		scoop.animation.play('idle');
		scoop.x = FlxG.width - scoop.width;
		scoop.y = 3;
		add(scoop);

		// ice cream needs to align with the scoop
		iceCreamBall.x = scoop.x + iceCreamBall.offset.x;
		iceCreamBall.y = scoop.y + iceCreamBall.offset.y - 3;
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (!dropTriggered && FlxG.mouse.justPressed) {
			dropTriggered = true;
			scoop.animation.play('flip');
			iceCreamBall.acceleration.y = 120;
		}

		if (!iceCreamBall.plopped) {
			FlxG.collide(cone, iceCreamBall, handleFinish);
		}

		if (iceCreamBall.y  > FlxG.height) {
			trace("you failed");
			close();
			returnState.openSubState(new ChangeSortState(returnState, 2));
		}

		if (plopOccurred && !iceCreamBall.plopped) {
			coneTween.cancel();

			iceCreamBall.velocity.set(0, 0);
			iceCreamBall.acceleration.set(0, 0);
			iceCreamBall.plop(cone);

			trace("nice plopper");

			// TODO: animations and rating, etc, before closing. Make this cleaner
			Timer.delay(()-> {
				close();
				returnState.openSubState(new ChangeSortState(returnState, 4));
			}, 2000);
		}
	}

	function handleFinish(c:FlxSprite, i:IceCreamBall) {
		plopOccurred = true;
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
