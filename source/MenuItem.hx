package;

//import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
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
		week.antialiasing = FlxG.save.data.antialiasing;
		ID = weekNum;
		add(week);
	}

	private var isFlashing:Bool = false;
	var flashTimer:FlxTimer;

	public function startFlashing():Void
	{
		isFlashing = true;
		//Ripped from flxFlicker
		//A better more consistent way across all framerates :DDD
		flashTimer = new FlxTimer().start(0.05, flashFunct, 0);
	}

	var flashBool:Bool = false;
	private function flashFunct(Timer:FlxTimer):Void
	{
		flashBool = !flashBool;
		if (flashBool)
		{
			if (FlxG.save.data.flashing)
				week.color = 0xff8cd5ff;
			else
				week.color = 0xFFadadad;
		}
		else
			week.color = 0xffffffff;
	}

	override function update(elapsed:Float)
	{
		y = FlxMath.lerp(y, (targetY * 120) + 480, CoolUtil.boundTo(elapsed * 10, 0, 1));
		super.update(elapsed);
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
		antialiasing = FlxG.save.data.antialiasing;
		if (x != targetX && targetX == 0)
			targetX = x;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (x != targetX && allowInternalTween)
			x = FlxMath.lerp(targetX, x, CoolUtil.boundTo(1 - (elapsed * 15), 0, 1));
	}
}
