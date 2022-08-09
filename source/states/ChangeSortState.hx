package states;

import flixel.math.FlxRect;
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

class ChangeSortState extends FlxTransitionableState {

	var coinsToSpawn:Int = 4;

	var bins:Map<Int, FlxSprite> = [];

	var binXs = [
		0 => 0,
		1 => Std.int(FlxG.width * .25),
		2 => Std.int(FlxG.width * .5),
		3 => Std.int(FlxG.width * .75),
	];

	var coins:Array<FlxSprite> = [];

	var changeArea = FlxRect.get(0, 0, FlxG.width, FlxG.height * .75);

	var coinColors = [
		0 => FlxColor.RED,
		1 => FlxColor.YELLOW,
		2 => FlxColor.BLUE,
		3 => FlxColor.GRAY,
	];

	var coinTypes = 4;

	var coinSizes = [
		0 => 10,
		1 => 8,
		2 => 6,
		3 => 5,
	];

	public function new() {
		super();
	}

	override public function create() {
		super.create();

		if (FlxG.plugins.get(FlxMouseControl) == null) {
			FlxG.plugins.add(new FlxMouseControl());
		}

		FlxG.camera.pixelPerfectRender = true;


		makeBin(0);
		makeBin(1);
		makeBin(2);
		makeBin(3);

		for (i in 0...coinsToSpawn) {
			makeCoin();
		}
	}


	function makeBin(type:Int) {
		var bin = new FlxSprite();
		bin.makeGraphic(Std.int(FlxG.width / coinTypes), Std.int(FlxG.height / 4), coinColors[type]);
		bin.x = binXs[type];
		bin.y = FlxG.height - bin.height;
		add(bin);

		bins[type] = bin;
	}

	function makeCoin() {
		var type = FlxG.random.int(0, 3);
		trace("spawning coin of type: " + type);

		var size = Std.int(coinSizes[type]);
		var coin = new FlxExtendedSprite(FlxG.random.int(0, Std.int(FlxG.width - size)), FlxG.random.int(0, Std.int(FlxG.height * .75 - size)));
		coin.makeGraphic(Std.int(coinSizes[type]), Std.int(coinSizes[type]), coinColors[type].getDarkened());
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
			trace('stop dragged');

			if (FlxG.overlap(c, bins[type])) {
				c.kill();
				coins.remove(c);

				if (coins.length == 0) {
					FlxG.switchState(new MainMenuState());
				}
			} else {
			// } else if (c.y > ) {
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
