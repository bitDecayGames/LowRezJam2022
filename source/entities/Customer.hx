package entities;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.addons.display.FlxExtendedSprite;

class Customer extends FlxExtendedSprite {
	public var spacingVariance:Int = 0;
	public var linePosition:Int = 0;
	public var lineNum:Int = 0;
	public var settled = false;

	public function new() {
		super(
			x = FlxG.random.bool() ? -32 : FlxG.width,
			y = FlxG.random.int(0, 20)
		);
		makeGraphic(16, 32, FlxColor.fromRGBFloat(FlxG.random.float(.5, 1), FlxG.random.float(.5, 1), FlxG.random.float(.5, 1)));
	}
}