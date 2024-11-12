package;

import flash.Lib;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.addons.plugin.screengrab.FlxScreenGrab;

class CachingScreen extends FlxSpriteGroup
{
	public var toBeDone:Int = 0;
	public var done:Int = 0;

	public var vals:Array<Float> = [0, 0, 0, 0];

	var text:FlxText;
	var targetText:String = '';
	var kadeLogo:FlxSprite;

    public function new(instantShow:Bool = false, inPlayState:Bool = false)
    {
        super();

		kadeLogo = new FlxSprite(0, 0).loadGraphic(Paths.image('KadeEngineLogo'));
		kadeLogo.setGraphicSize(Std.int(kadeLogo.width * 0.6));
		kadeLogo.screenCenter();
		kadeLogo.y -= 70;
		kadeLogo.antialiasing = true;

		text = new FlxText(0, 0, "Loading...");
		text.size = 34;
		text.y = kadeLogo.y + kadeLogo.height - 80;
		text.y -= 30;
		text.alignment = FlxTextAlign.CENTER;

		vals[0] = kadeLogo.x;
		vals[1] = text.y;
		vals[2] = text.height;
		vals[3] = kadeLogo.width;

		add(kadeLogo);
		add(text);

		/*#if cpp
		if (!FlxG.save.data.cacheImages && !FlxG.save.data.cacheMusic)
		{
			text.text = "<<Press  ENTER>>";
			text.screenCenter(X);
		}
		#else*/
		text.text = "<<Press  ENTER>>";
		text.screenCenter(X);
		//#end
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

		if (toBeDone != 0)
		{
			if (done > toBeDone)
				done = toBeDone;
			if (text != null)
			{
				text.text = "Loading... (" + (done) + "/" + toBeDone + ")";
				text.screenCenter(X);
			}
		}
    }
}