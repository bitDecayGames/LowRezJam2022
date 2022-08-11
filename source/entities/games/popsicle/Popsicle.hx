package entities.games.popsicle;

import flixel.addons.display.FlxExtendedSprite;

class Popsicle extends FlxExtendedSprite {
	public var asset:String;

	public function new(asset:String) {
		super(asset);
		this.asset = asset;
	}
}