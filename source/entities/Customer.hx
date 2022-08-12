package entities;

import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.addons.display.FlxExtendedSprite;

class Customer extends FlxExtendedSprite {
	public var spacingVariance:Int = 0;
	public var linePosition:Int = 0;
	public var lineNum:Int = 0;
	public var settled = false;

	public var ticket:OrderTicket;

	private static final assets = [
		AssetPaths.blackBoy__png,
		AssetPaths.blackGirl__png,
		AssetPaths.brownBoy__png,
		AssetPaths.brownGirl__png,
		AssetPaths.yellowBoy__png,
		AssetPaths.yellowGirl__png,
		AssetPaths.whiteBoy__png,
		AssetPaths.whiteGirl__png,
	];

	public function new() {
		super(
			x = FlxG.random.bool() ? -32 : FlxG.width,
			y = FlxG.random.int(0, 20),
			assets[FlxG.random.int(0, assets.length-1)]
		);
	}
}