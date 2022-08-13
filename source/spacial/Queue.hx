package spacial;

import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxPoint;

class Queue {
	public var frontPosition:FlxPoint;
	public var spacing:Int;
	public var lineDirection:Cardinal = Cardinal.N;
	public var verticalVariance:Int = 0;
	public var horizontalVariace:Int = 0;

	public var speed = 100.0;

	var items:Array<FlxObject> = [];
	var settled:Map<FlxObject, Bool> = [];
	var specialActions:Map<FlxObject, (Int)->Void> = [];

	public function new(start:FlxPoint, dir:Cardinal, spacing:Int, varianceH:Int=0, varianceV:Int=0) {
		frontPosition = start;
		this.spacing = spacing;
		lineDirection = dir;
		verticalVariance = varianceV;
		horizontalVariace = varianceH;
	}

	public function push(o:FlxObject, onArrive:(Int)->Void=null) {
		items.push(o);
		settled.set(o, false);
		if (onArrive != null) {
			specialActions[o] = onArrive;
		}

		moveItemToPosition(o);
	}

	public function remove(o:FlxObject) {
		var pos = items.indexOf(o);
		if (pos < 0) {
			// not in our queue
			return;
		}

		items.remove(o);

		// move all of our tickets behind this one up
		for (t in pos...items.length) {
			moveItemToPosition(items[t]);
		}
	}

	function moveItemToPosition(o:FlxObject) {
		settled[o] = false;
		var position = items.indexOf(o);
		var variance = FlxPoint.get(
			FlxG.random.int(0, horizontalVariace * 2) - horizontalVariace,
			FlxG.random.int(0, verticalVariance * 2) - verticalVariance
		);

		var target = frontPosition.copyTo(FlxPoint.get());
		if (lineDirection.horizontal()) {
			target.x += (position * spacing + variance.x) * (lineDirection == Cardinal.E ? 1 : -1);
			target.y += variance.y;
		} else {
			target.x += variance.x;
			target.y += (position * spacing + variance.y) * (lineDirection == Cardinal.S ? 1 : -1);
		}

		FlxTween.linearPath(o, [FlxPoint.get(o.x, o.y), FlxPoint.get(target.x, o.y), FlxPoint.get(target.x, target.y)], speed, false, {
			onComplete: function (t) {
				settled[o] = true;
				if (specialActions.exists(o)) {
					specialActions[o](position);
				}
			}
		});
	}
}