package;

import flash.Lib;
//import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.group.FlxSpriteGroup;
import flixel.addons.plugin.screengrab.FlxScreenGrab;

class LoadingScreen extends FlxSpriteGroup
{
	public var toDo:Int = 0;
	public var done:Int = 0;

	var loadProgressBar:FlxSprite;
	var loadingIcon:FlxSprite;
	var fadeInTime:Float = 1;

    public function new(instantShow:Bool = false, inPlayState:Bool = false)
    {
        super();

		var fakeScreen:FlxSprite = new FlxSprite(0, 0);

		if (LoadingState.doScreenshotShit)
		{
			LoadingState.doScreenshotShit = false;
			fakeScreen.loadGraphic(PlayState.grabbedScreen, false);
			//Calculates the scale!
			fakeScreen.setGraphicSize(Math.round(fakeScreen.width / FlxG.scaleMode.scale.x), Math.round(fakeScreen.height / FlxG.scaleMode.scale.y));
			fakeScreen.updateHitbox();
			fakeScreen.screenCenter();
			fakeScreen.antialiasing = true;
			trace('screenGrab Trick!');
		}
		else
		{
			fakeScreen.makeGraphic(FlxG.width * 4, FlxG.height * 4, 0xFF000000);
			fakeScreen.x -= FlxG.width;
			fakeScreen.y -= FlxG.height;
			trace('bleugh');
		}
		add(fakeScreen);

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

		loadProgressBar.makeGraphic(1, 1, 0xFFFFFFFF);
		loadProgressBar.updateHitbox();
		loadProgressBar.origin.set();
		loadProgressBar.scale.set(0, loadingIcon.height / 5);
		loadProgressBar.alpha = 0;
		loadProgressBar.y = FlxG.height - (10 + loadProgressBar.height * 2);

		if (!instantShow)
		{
			fadeInTime = 0.5;
			if (inPlayState)
				fadeInTime = 0.25;
			FlxTween.tween(loadingIcon, {alpha: 1}, fadeInTime, {type: ONESHOT, ease: FlxEase.smootherStepIn});
			FlxTween.tween(loadProgressBar, {alpha: 0.3}, fadeInTime, {type: ONESHOT, ease: FlxEase.smootherStepIn});
		}
		else
		{
			loadingIcon.alpha = 1;
			loadProgressBar.alpha = 0.3;
		}

    }

	public function fadeOutShits():Void
	{
		FlxTween.tween(loadingIcon, {alpha: 0}, fadeInTime, {type: ONESHOT, ease: FlxEase.smootherStepIn});
		FlxTween.tween(loadProgressBar, {alpha: 0}, fadeInTime, {type: ONESHOT, ease: FlxEase.smootherStepIn});
	}

    override function update(elapsed:Float)
    {
        super.update(elapsed);

		var lerpTarget:Float = FlxMath.roundDecimal((FlxG.width * (done / toDo)) + 3, 2);
		loadProgressBar.scale.x = FlxMath.lerp(loadProgressBar.scale.x, lerpTarget, elapsed * 15);
    }
}