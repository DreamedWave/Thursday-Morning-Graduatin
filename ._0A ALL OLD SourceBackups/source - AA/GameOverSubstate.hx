package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.addons.transition.FlxTransitionableState;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	private var cameraAnchor:FlxObject;
	var playedDeathNoise:Bool = false;
	private var cameraAnchorXAdditive:Int = -20;
	var deathSound:FlxSound = new FlxSound();
	var retrySound:FlxSound = new FlxSound();
	var retryFade:FlxTween;
	var gameOverTimer:FlxTimer;

	public function new(x:Float, y:Float)
	{
		FlxG.camera.followLerp = 0.055;
		var daStage = PlayState.curStage;
		var daBf:String = '';
			switch (PlayState.stageSuffix)
			{
				case '-pixel':
					daBf = 'bf-pixel-dead';
				case '-selfsert':
					daBf = 'selfsert-default';
				default:
					if (PlayState.SONG.song.toLowerCase() == "mic test")
					{
						daBf = 'guy-fail';
						cameraAnchorXAdditive = -50;
					}
					else
						daBf = 'guy-default';
			}

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		cameraAnchor = new FlxObject(bf.getGraphicMidpoint().x + cameraAnchorXAdditive, bf.getGraphicMidpoint().y, 1, 1);
		add(cameraAnchor);

		Conductor.changeBPM(100);

		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		PlayState.instance.clear();
		//Loading it here again cuz I can't do the custom flxsound shit if I don't (hopefully haxeflixel doesn't add it to the cache again-)
		FlxG.sound.music.looped = true;
		retrySound = new FlxSound().loadEmbedded(Paths.music('gameOverEnd' + PlayState.stageSuffix));
		bf.playAnim('firstDeath');
	}

	var startVibin:Bool = false;
	var pressedConfirm:Bool = false;
	//Var to prevent pressing enter then going back to menu, I'm pretty sure this fixes a very rare crash that happens when the game loads and exits to the story menu at the same time but idk

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT || (FlxG.keys.justPressed.R && FlxG.save.data.resetButton))
		{
			pressedConfirm = true;
			endBullshit();
			FlxG.log.add('ended bullshit');
		}

		if (controls.BACK && !pressedConfirm)
		{
			FlxG.sound.music.fadeOut(0.2);
			deathSound.fadeOut(0.3);

			PauseSubState.randomMusicTime = false;

			PlayState.startTime = 0;
			PlayState.deaths = 0;
			PlayState.hasReset = false;

			PlayState.cannotDie = false;
			PlayState.toggledPracticeMode = false;

			if (PlayState.playedCutscene)
				PlayState.playedCutscene = false;

			/*if (PlayState.instance.useVideo)
			{
				GlobalVideo.get().stop();
				PlayState.instance.remove(PlayState.instance.videoSprite);
				PlayState.instance.removedVideo = true;
			}*/
            PlayState.rep = null;

			var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");
			switch (songHighscore) {
				case 'Philly-Nice': songHighscore = 'Philly';
			}

			#if windows
			if (PlayState.luaModchart != null)
			{
				PlayState.luaModchart.die();
				PlayState.luaModchart = null;
			}
			#end
			FlxG.camera.fade(FlxColor.BLACK, 0.3, false, function()
			{
				FlxG.sound.music.stop();
				FlxG.bitmap.clearCache();
				if (PlayState.isStoryMode)
				{
					Conductor.changeBPM(102);
					FlxG.switchState(new StoryMenuState());
					//FlxG.sound.playMusic(Paths.music('freakyMenu'));
				}
				else
				{
					FlxG.switchState(new FreeplayState());
				}
			});
        }

		if (!playedDeathNoise)
		{	
			playedDeathNoise = true;
			deathSound = FlxG.sound.play(Paths.sound('deathsound' + PlayState.stageSuffix));
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 10 && !isEnding)
		{
			FlxG.camera.follow(cameraAnchor, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			if (PlayState.SONG.song.toLowerCase() == "mic test")
			{
				FlxG.sound.playMusic(Paths.music('gameOver' + PlayState.stageSuffix), 0);
				FlxG.sound.music.fadeIn(10, 0.4, 1);
			}
			else
				FlxG.sound.playMusic(Paths.music('gameOver' + PlayState.stageSuffix), 1);
			
			startVibin = true;
			trace('started vibin');
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}
	
	override function beatHit()
	{
		super.beatHit();
		
		if (startVibin && !isEnding)
		{
			bf.playAnim('deathLoop', true);
		}
		FlxG.log.add('beat');
	}	

/*	override function stepHit()
	{
		super.stepHit();

		//Add Shit Here If You want Idk
	}	*/

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			PlayState.startTime = 0;
			//isEnding Ending Fx
			if (PlayState.SONG.song.toLowerCase() == "mic test")
			{
				cameraAnchor.y -= 150;
				FlxTween.tween(FlxG.camera, {zoom: 1.7}, 0.5, {ease: FlxEase.elasticOut});
				FlxTween.tween(FlxG.camera, {x: camera.x - 1000, y: camera.y - 800}, 1, {ease: FlxEase.expoIn, startDelay: 2});
			}
			else
			{
				FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.1}, 0.5, {ease: FlxEase.elasticOut});
				FlxTween.tween(FlxG.camera, {y: camera.y + 800}, 1, {ease: FlxEase.expoIn, startDelay: 2});
			}
			FlxG.camera.follow(cameraAnchor, LOCKON, 0.01);
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			retrySound.play(true);
			FlxG.sound.music.fadeOut(0.03);
			FlxTransitionableState.skipNextTransOut = true;
			gameOverTimer = new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 3.5, false, function()
				{
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
		else
		{
			FlxTransitionableState.skipNextTransOut = false;
			gameOverTimer.cancel();
			retrySound.fadeOut(0.2);
			deathSound.fadeOut(0.3);
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}
}
