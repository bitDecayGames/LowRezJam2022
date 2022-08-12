package states;

import entities.HandGrabCursor;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.FlxState;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.math.FlxPoint;
import flixel.tweens.FlxTween;
import flixel.addons.plugin.FlxMouseControl;
import flixel.addons.display.FlxExtendedSprite;
import flixel.util.FlxColor;

import flixel.FlxSprite;
import flixel.FlxG;

using extensions.FlxStateExt;

class ChangeSortState extends FlxSubState {

	var coinsToSpawn:Int = 4;

	var bins:Map<Int, FlxObject> = [];

	var binLocations = [
		0 => FlxPoint.get(2, 44),
		1 => FlxPoint.get(18, 44),
		2 => FlxPoint.get(33, 44),
		3 => FlxPoint.get(48, 44),
	];

	var binSizes = [
		0 => FlxPoint.get(14, 19),
		1 => FlxPoint.get(13, 19),
		2 => FlxPoint.get(13, 19),
		3 => FlxPoint.get(14, 19),
	];

	var coins:Array<FlxSprite> = [];

	var changeArea = FlxRect.get(0, 0, FlxG.width, FlxG.height * .75);

	var coinColors = [
		0 => AssetPaths.penny__png,
		1 => AssetPaths.nickel__png,
		2 => AssetPaths.dime__png,
		3 => AssetPaths.quarter__png,
	];

	var coinTypes = 4;

	var coinSizes = [
		0 => 8,
		1 => 10,
		2 => 7,
		3 => 14,
	];

	var returnState:TruckState;


	public function new(returnState:TruckState, coinCount:Int) {
		super();
		this.returnState = returnState;
		coinsToSpawn = coinCount;
	}

	override public function create() {
		super.create();

		FlxG.camera.pixelPerfectRender = true;

		add(new FlxSprite(AssetPaths.register_bg__png));


		makeBin(0);
		makeBin(1);
		makeBin(2);
		makeBin(3);

		for (i in 0...coinsToSpawn) {
			makeCoin();
		}

		add(new HandGrabCursor());
	}


	function makeBin(type:Int) {
		var bin = new FlxObject(
			binLocations[type].x,
			binLocations[type].y,
			binSizes[type].x,
			binSizes[type].y
		);
		add(bin);

		bins[type] = bin;
	}

	function makeCoin() {
		// TODO: Coins should scatter initially
		var type = FlxG.random.int(0, 3);
		trace("spawning coin of type: " + type);

		var size = Std.int(coinSizes[type]);
		var coin = new FlxExtendedSprite(
			FlxG.random.int(0, Std.int(FlxG.width - size)),
			FlxG.random.int(0, Std.int(bins[0].y - size)),
			coinColors[type]
		);
		coin.enableMouseClicks(false, true);
		coin.draggable = true;
		coin.mouseStartDragCallback = coinDrag;
		coin.mouseStopDragCallback = stopCoinDrag(type);
		coins.push(coin);
		add(coin);
	}

	function coinDrag(c:FlxExtendedSprite, x:Int, y:Int) {
		trace('being dragged');
		c.x = x;
		c.y = y;
	}

	function stopCoinDrag(type:Int) {
		return function(c:FlxExtendedSprite, x:Int, y:Int) {
			if (FlxG.overlap(c, bins[type])) {
				c.kill();
				coins.remove(c);

				if (coins.length == 0) {
					// TODO: Done with customer, report back somehow
					returnState.dismissCustomer();
					close();
				}
			// } else {
			} else if (c.y > bins[0].y - c.height) {
				// TODO: Make this only reject coins if they place them in the wrong bin
				c.draggable = false;
				c.alpha = 0.5;
				FlxTween.linearPath(c, [
						FlxPoint.get(c.x, c.y),
						FlxPoint.get(
							FlxG.random.int(0, Std.int(FlxG.width - c.width)),
							FlxG.random.int(0, Std.int(FlxG.height * .75 - c.width))
						)
					],
					0.5,
					true,
					{
						ease: FlxEase.quadOut,
						type: FlxTweenType.ONESHOT,
						onComplete: function(t:FlxTween) {
							c.draggable = true;
							c.alpha = 1;
						}
					}
				);
				// TODO: SHOOT COIN OUT
			}
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
