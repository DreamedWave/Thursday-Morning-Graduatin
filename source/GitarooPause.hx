package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxSound;
import flixel.math.FlxMath;

class GitarooPause extends MusicBeatSubstate
{
	var pauseMusic:FlxSound;

	var replayButton:FlxSprite;
	var cancelButton:FlxSprite;

	var replaySelect:Bool = false;

	public function new():Void
	{
		super();

		pauseMusic = new FlxSound().loadEmbedded(Paths.music(PlayState.pauseMusicName), true, true);
		pauseMusic.volume = 0.1;
		pauseMusic.play(false);

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('pauseAlt/pauseBG'));
		FlxG.sound.play(Paths.sound('cancelMenu'), 0.4);
		if(FlxG.save.data.antialiasing)
			{
				bg.antialiasing = true;
			}
		add(bg);

		var bf:FlxSprite = new FlxSprite(0, 30);
		bf.frames = Paths.getSparrowAtlas('pauseAlt/bfLol');
		bf.animation.addByPrefix('lol', "funnyThing", 13);
		bf.animation.play('lol');
		if(FlxG.save.data.antialiasing)
			{
				bf.antialiasing = true;
			}
		add(bf);
		bf.screenCenter(X);

		replayButton = new FlxSprite(FlxG.width * 0.28, FlxG.height * 0.7);
		replayButton.frames = Paths.getSparrowAtlas('pauseAlt/pauseUI');
		replayButton.animation.addByPrefix('selected', 'bluereplay', 0, false);
		replayButton.animation.appendByPrefix('selected', 'yellowreplay');
		replayButton.animation.play('selected');
		if(FlxG.save.data.antialiasing)
			{
				replayButton.antialiasing = true;
			}
		add(replayButton);

		cancelButton = new FlxSprite(FlxG.width * 0.58, replayButton.y);
		cancelButton.frames = Paths.getSparrowAtlas('pauseAlt/pauseUI');
		cancelButton.animation.addByPrefix('selected', 'bluecancel', 0, false);
		cancelButton.animation.appendByPrefix('selected', 'cancelyellow');
		cancelButton.animation.play('selected');
		if(FlxG.save.data.antialiasing)
			{
				cancelButton.antialiasing = true;
			}
		add(cancelButton);

		cameras = [PlayState.instance.camEXT];

		changeThing();
	}

	override function destroy()
	{
		FlxG.sound.play(Paths.sound('returnMenu'));
		pauseMusic.destroy();

		super.destroy();
	}


	override function update(elapsed:Float)
	{
		if (controls.LEFT_P || controls.RIGHT_P)
			changeThing();

		if (controls.ACCEPT)
		{
			if (replaySelect)
			{
				FlxG.sound.play(Paths.sound('GitarooPress'));
				close();
			}
			else
			{
				FlxG.sound.play(Paths.sound('GitarooFail'));
				
				if (PlayState.isStoryMode)
					FlxG.switchState(new StoryMenuState());
				else
					FlxG.switchState(new FreeplayState());
			}
		}

		super.update(elapsed);

		pauseMusic.volume = FlxMath.lerp(0.65, pauseMusic.volume, CoolUtil.boundToInverted(1 - (elapsed / 24), 0, 1));
	}

	function changeThing():Void
	{
		replaySelect = !replaySelect;

		if (replaySelect)
		{
			cancelButton.animation.curAnim.curFrame = 0;
			replayButton.animation.curAnim.curFrame = 1;
			FlxG.sound.play(Paths.sound('GitarooHover'));
		}
		else
		{
			cancelButton.animation.curAnim.curFrame = 1;
			replayButton.animation.curAnim.curFrame = 0;
			FlxG.sound.play(Paths.sound('GitarooHover'));
		}
	}
}
