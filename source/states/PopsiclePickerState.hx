package states;

import entities.HandGrabCursor;
import flixel.tweens.FlxEase;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import entities.games.popsicle.Popsicle;
import flixel.FlxSubState;
import entities.ScoopCursor;
import flixel.addons.display.FlxExtendedSprite;
import flixel.util.FlxColor;
import flixel.FlxG;

using extensions.FlxStateExt;
using extensions.FlxObjectExt;

class PopsiclePickerState extends FlxSubState {

	var returnState:TruckState;

	var popsicles = [
		AssetPaths.greenOtter__png,
		AssetPaths.purpleOtter__png,
		AssetPaths.bombpop__png,
		AssetPaths.bitDecay__png,
		AssetPaths.doublesicle__png,
		AssetPaths.dreamsicle__png,
		AssetPaths.fudgesicle__png,
		AssetPaths.goodHumor__png,
	];

	var hand:FlxSprite;
	var chest:FlxSprite;

	var desired:Int;
	var childsChoice:FlxSprite;
	var errorChoice:FlxSprite;

	public function new(returnState:TruckState) {
		super();

		this.returnState = returnState;
		bgColor = FlxColor.fromRGB(30, 30, 30, 128);
	}

	override public function create() {
		super.create();

		FlxG.camera.pixelPerfectRender = true;

		// Keep the render order fresh. Nobody should notice this little hack
		if (FlxG.random.bool()) {
			popsicles.reverse();
		}

		desired = FlxG.random.int(0, popsicles.length - 1);

		chest = new FlxSprite(AssetPaths.chest_bg__png);
		chest.width = 38;
		chest.alpha = .85;
		add(chest);

		hand = new FlxSprite(AssetPaths.kidsHand__png);
		hand.x = FlxG.width - hand.width;
		hand.y = FlxG.random.float(32, FlxG.height - hand.height);
		add(hand);

		var speechBubble = new FlxSprite(AssetPaths.speachBubble__png);
		add(speechBubble);

		childsChoice = new FlxSprite(popsicles[desired]);
		childsChoice.setPositionMidpoint(52,20);
		add(childsChoice);

		errorChoice = new FlxSprite(AssetPaths.X__png);
		errorChoice.setPositionMidpoint(52, 20);
		errorChoice.alpha = 0;
		add(errorChoice);

		for (asset in popsicles) {
			var p = new Popsicle(asset);
			p.setPosition(
				FlxG.random.float(0, 38 - p.width),
				FlxG.random.float(0, FlxG.height - p.height)
			);
			p.enableMouseClicks(true, true);
			p.draggable = true;
			p.mouseStartDragCallback = sicleDrag;
			p.mouseStopDragCallback = stopSicleDrag;
			add(p);
		}

		// Add cursor last so it is on top
		add(new HandGrabCursor());
	}

	function sicleDrag(c:FlxExtendedSprite, x:Int, y:Int) {
		c.x = x;
		c.y = y;
	}

	function stopSicleDrag(c:FlxExtendedSprite, x:Int, y:Int) {

		var popsicle = cast(c, Popsicle);

		// Collide with hand, check if type is correct
		if (FlxG.overlap(c, hand)) {
			if (popsicle.asset == popsicles[desired]) {
				close();
				returnState.dismissCustomer(3);
				// returnState.openSubState(new ChangeSortState(returnState, 3));
			} else {
				// WRONG. throw it back
				shufflePopsicle(popsicle, true);
			}
		} else if (!FlxG.overlap(c, chest)) {
			// Player didn't leave popsicle inside bin
			shufflePopsicle(popsicle, false);
		}
	}

	function shufflePopsicle(c:Popsicle, error:Bool) {
		c.draggable = false;
		c.alpha = 0.5;
		if (error) {
			childsChoice.alpha = 0;
			errorChoice.alpha = 1;
		}
		FlxTween.linearPath(c, [
				FlxPoint.get(c.x, c.y),
				FlxPoint.get(
					FlxG.random.float(0, 38),
					FlxG.random.float(0, FlxG.height - c.height)
				)
			],
			0.5,
			true,
			{
				ease: FlxEase.quadOut,
				type: FlxTweenType.ONESHOT,
				onComplete: function(t:FlxTween) {
					if (error) {
						childsChoice.alpha = 1;
						errorChoice.alpha = 0;
					}
					c.draggable = true;
					c.alpha = 1;
				}
			}
		);
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
