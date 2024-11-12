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

class GameOverSubstate extends MusicBeatSubstate
{
	var stageSuffix:String = "";
	var bf:Boyfriend;
	var camFollow:FlxObject;
	var playedDeathNoise:Bool = false;
	var camFollowXAdditive:Int = 20;
	var deathSound:FlxSound;
	var retrySound:FlxSound;
	var retryFade:FlxTween;
	var gameOverTimer:FlxTimer;

	public function new(x:Float, y:Float)
	{
		var daStage = PlayState.curStage;
		var daBf:String = '';
			switch (PlayState.SONG.player1)
			{
				case 'bf-pixel':
					stageSuffix = '-pixel';
					daBf = 'bf-pixel-dead';
				case 'selfsert-default':
					stageSuffix = '-selfsert';
					daBf = 'selfsert-default';
				default:
					if (PlayState.SONG.song.toLowerCase() == "mic test")
					{
						stageSuffix = '-tutorial';
						daBf = 'guy-fail';
						camFollowXAdditive = 30;
					}
					else
					{
						stageSuffix = "";
						daBf = 'guy-default';
					}
			}

		super();

		Conductor.songPosition = 0;

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		camFollow = new FlxObject(bf.getGraphicMidpoint().x + camFollowXAdditive, bf.getGraphicMidpoint().y, 1, 1);
		add(camFollow);

		Conductor.changeBPM(100);

		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		PlayState.instance.clear();
		retrySound = FlxG.sound.load(Paths.music('gameOverEnd' + stageSuffix));
		bf.playAnim('firstDeath');
	}

	var startVibin:Bool = false;
	var pressedConfirm:Bool = false;
	//Var to prevent pressing enter then going back to menu, I'm pretty sure this fixes a very rare crash that happens when the game loads and exits to the story menu at the same time but idk

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			pressedConfirm = true;
			endBullshit();
			FlxG.log.add('ended bullshit');
		}

		if (controls.BACK && !pressedConfirm)
		{
			FlxG.sound.music.fadeOut(0.3);
			deathSound.fadeOut(0.3);

			PlayState.startTime = 0;
			PlayState.deaths = 0;
			PlayState.hasReset = false;

			if (PlayState.playedCutscene)
				PlayState.playedCutscene = false;

			/*if (PlayState.instance.useVideo)
			{
				GlobalVideo.get().stop();
				PlayState.instance.remove(PlayState.instance.videoSprite);
				PlayState.instance.removedVideo = true;
			}*/
			if(PlayState.loadRep)
			{
				FlxG.save.data.botplay = false;
				FlxG.save.data.scrollSpeed = 1;
				FlxG.save.data.downscroll = false;
			}

            PlayState.loadRep = false;
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
			deathSound = FlxG.sound.play(Paths.sound('deathsound' + stageSuffix));
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12 && !isEnding)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			if (PlayState.SONG.song.toLowerCase() == "mic test")
			{
				FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix), 0);
				FlxG.sound.music.fadeIn(10, 0.4, 1);
			}
			else
				FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix), 1);		
			
			startVibin = true;
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
				camFollow.y -= 150;
				FlxTween.tween(FlxG.camera, {zoom: 1.7}, 0.5, {ease: FlxEase.elasticInOut});
				FlxTween.tween(FlxG.camera, {x: camFollow.x + 150, y: camFollow.y - 1000}, 1.5, {ease: FlxEase.expoInOut, startDelay: 2});
			}
			else
			{
				FlxTween.tween(FlxG.camera, {zoom: FlxG.camera.zoom + 0.1}, 0.5, {ease: FlxEase.elasticInOut});
				FlxTween.tween(FlxG.camera, {y: camFollow.y + 250}, 2, {ease: FlxEase.expoInOut, startDelay: 2});
			}
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			retrySound.play(true);
			FlxG.sound.music.fadeOut(0.03);
			deathSound.stop();
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
			gameOverTimer.cancel();
			retrySound.fadeOut(0.3);
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}
}
