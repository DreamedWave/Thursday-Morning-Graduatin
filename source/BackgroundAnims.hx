package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class TheBorderPeople extends FlxSprite
{
	public function new(x:Float, y:Float)
	{
		super(x, y);

		frames =  Paths.getSparrowAtlas('theborder_people', 'week2');
		animation.addByPrefix('static', 'Static', 18, false);
		animation.addByPrefix('idle', 'Idle', 18, true);
		animation.addByPrefix('dance', 'Bop', 24, false);
		scrollFactor.set(0.9, 0.9);
		animation.play("static");
		updateHitbox();
	}

	public function dance(allowBopping:Bool = false):Void
	{
		if (!allowBopping && animation.curAnim.name != "idle")
			animation.play('idle', true);
		else
			animation.play('dance', true);
	}
}
