package states;

import misc.Constants;
import flixel.util.FlxAxes;
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
	var hand:FlxSprite;
	var scoop:FlxSprite;
	var iceCreamBall:IceCreamBall;
	var iceCreamGravity = 300;

	var coneTween:FlxTween;

	var dropTriggered = false;
	var plopOccurred = false;

	var returnState:TruckState;

	var attachPointX = -1.0;

	var accuracyPercentage = 0.0;

	public function new(returnState:TruckState, flavor:IceCreamFlavor) {
		super();

		this.flavor = flavor;
		this.returnState = returnState;
		bgColor = FlxColor.fromRGB(30, 30, 30, 128);
	}

	override public function create() {
		super.create();

		FlxG.camera.pixelPerfectRender = true;

		hand = new FlxSprite(AssetPaths.kidsHand__png);
		hand.setPosition(FlxG.width - hand.width + 4, FlxG.height - hand.height - 2);
		add(hand);

		cone = new FlxSprite(5, 15, AssetPaths.cake_cone__png);
		cone.setPosition(0, FlxG.height - cone.height);
		add(cone);

		Timer.delay(function() {
			coneTween = FlxTween.linearPath(cone, [
				new FlxPoint(0, FlxG.height - cone.height),
				new FlxPoint(FlxG.width-cone.width - 2, FlxG.height - cone.height)
			], FlxG.random.float(.75, 1.5), true, {
				type: FlxTweenType.ONESHOT,
				ease: FlxEase.quadIn,
				onComplete: function(t:FlxTween) {
					rateCone();
					FlxG.camera.shake(Constants.SHAKE_AMOUNT, 0.05, FlxAxes.X);
					// TODO: Slap SFX
				}
			});
			FlxTween.globalManager.update(0);
		}, FlxG.random.int(500, 1500));

		scoop = new FlxSprite();
		scoop.loadGraphic(AssetPaths.big_scoop_1__png, true, 43, 22);
		scoop.animation.add('idle', [0]);
		scoop.animation.add('flip', [1, 2], 15, false);
		scoop.animation.play('idle');
		scoop.x = FlxG.width - scoop.width;
		scoop.y = 3;
		add(scoop);

		iceCreamBall = new IceCreamBall(flavor);
		add(iceCreamBall);

		// ice cream needs to align with the scoop
		iceCreamBall.x = scoop.x + iceCreamBall.offset.x;
		iceCreamBall.y = scoop.y + iceCreamBall.offset.y - 8;
	}

	override public function update(elapsed:Float) {
		super.update(elapsed);

		if (!dropTriggered && FlxG.mouse.justPressed) {
			dropTriggered = true;
			iceCreamBall.fall();
			scoop.animation.play('flip');
			iceCreamBall.acceleration.y = iceCreamGravity;
		}

		if (!iceCreamBall.plopped) {
			if (FlxG.collide(cone, iceCreamBall)) {
				attachPointX = Math.round(cone.x - iceCreamBall.x);
				iceCreamBall.velocity.set(0, 0);
				iceCreamBall.acceleration.set(0, 0);
				accuracyPercentage = Math.abs(iceCreamBall.plop(cone));

				// TODO: Slap SFX For ice cream hitting cone. Maybe different depending on how centered?
				FlxG.camera.shake(Constants.SHAKE_AMOUNT, 0.05, FlxAxes.Y);
			}
		}

		if (attachPointX != -1.0) {
			iceCreamBall.x = cone.x - attachPointX;
		}
	}

	function rateCone() {
		trace("RATING PENDING");
		Timer.delay(()-> {
			// TODO: Play SFX
			close();
			returnState.dismissCustomer(4, accuracyPercentage);
			// returnState.openSubState(new ChangeSortState(returnState, 4));
		}, 750);
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
