package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;

class StoryMenuItem extends FlxSpriteGroup
{
	public var targetY:Float = 0;
	public var week:FlxSprite;
	public var flashingInt:Int = 0;

	public function new(x:Float, y:Float, weekNum:Int = 0)
	{
		super(x, y);
		week = new FlxSprite().loadGraphic(Paths.image('storymenu/week' + weekNum));
		week.antialiasing = true;
		add(week);
	}

	private var isFlashing:Bool = false;

	public function startFlashing():Void
	{
		isFlashing = true;
	}

	// if it runs at 60fps, fake framerate will be 6
	// if it runs at 144 fps, fake framerate will be like 14, and will update the graphic every 0.016666 * 3 seconds still???
	// so it runs basically every so many seconds, not dependant on framerate??
	// I'm still learning how math works thanks whoever is reading this lol
	var fakeFramerate:Int = Math.round((1 / FlxG.elapsed) / 10);

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		y = FlxMath.lerp(y, (targetY * 120) + 480, CoolUtil.boundTo(elapsed * 10, 0, 1));

		if (isFlashing)
		{
			flashingInt += 1;

			if (flashingInt % fakeFramerate >= Math.floor(fakeFramerate / 4))
			{
				if (FlxG.save.data.flashing)
					week.color = 0xff8cd5ff;
				else
					week.color = 0xFFadadad;
			}
			else
				week.color = 0xffffffff;
		}
	}
}

class MainMenuItem extends FlxSprite
{
	public var targetX:Float = 0;
	public var allowInternalTween:Bool = true;
	public var intTween:FlxTween;

	public function new(x:Float, y:Float, optionType:String, spriteID:Int)
	{
		super(x, y);

		var tex = Paths.getSparrowAtlas('MainMenu_buttons');
		frames = tex;
		animation.addByPrefix('idle', optionType + "Normal", 9);
		animation.addByPrefix('selected', optionType + "Hover", 18);
		animation.play('idle');
		ID = spriteID;
		scrollFactor.set();
		if(FlxG.save.data.antialiasing)
			antialiasing = true;
		if (x != targetX && targetX == 0)
			targetX = x;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (x != targetX && allowInternalTween)
			x = FlxMath.lerp(targetX, x, PlayStateHelpers.calculateLerpTime(elapsed, 15, 0, 1));
	}
}
