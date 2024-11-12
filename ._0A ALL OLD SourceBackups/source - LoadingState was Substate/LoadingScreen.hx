package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;

class LoadingScreen extends FlxSpriteGroup
{
	public var toDo:Int = 0;
	public var done:Int = 0;

	var loadProgressBar:FlxSprite;
	var loadingIcon:FlxSprite;

    public function new(instantShow:Bool = false, inPlayState:Bool = false)
    {
        super();

		loadProgressBar = new FlxSprite();
		add(loadProgressBar);

		//ripped from PlayState 2
		loadingIcon = new FlxSprite();
		loadingIcon.loadGraphic(Paths.image('loadingNextSong'), 'preload');
		loadingIcon.setGraphicSize(Std.int(loadingIcon.width * 0.5));
		//loadingIcon.screenCenter();
		loadingIcon.x = FlxG.width - loadingIcon.width / 2;
		loadingIcon.y = FlxG.height - loadingIcon.height / 2;
		loadingIcon.updateHitbox();
		loadingIcon.antialiasing = FlxG.save.data.antialiasing;
		loadingIcon.alpha = 0;
		//loadingIcon.screenCenter();
		add(loadingIcon);
		if (!instantShow)
		{
			var fadeInTime:Float = 0.5;
			if (inPlayState)
				fadeInTime = 0.25;
			FlxTween.tween(loadingIcon, {alpha: 1}, fadeInTime, {type: ONESHOT, ease: FlxEase.smootherStepIn});
		}
		else
			loadingIcon.alpha = 1;

		loadProgressBar.makeGraphic(1, 1, 0xFFFFFFFF);
		loadProgressBar.updateHitbox();
		loadProgressBar.origin.set();
		loadProgressBar.scale.set(0, loadingIcon.height / 5);
		loadProgressBar.alpha = 0.3;
		loadProgressBar.y = FlxG.height - (10 + loadProgressBar.height * 2);
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

		var lerpTarget:Float = FlxG.width * (done / toDo);
		loadProgressBar.scale.x = FlxMath.lerp(loadProgressBar.scale.x, lerpTarget, elapsed * 10);
    }
}