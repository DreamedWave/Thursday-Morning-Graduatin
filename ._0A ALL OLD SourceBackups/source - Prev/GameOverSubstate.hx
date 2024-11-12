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
import flixel.math.FlxMath;
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxSprite;

using StringTools;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	private var cameraAnchor:FlxObject;
	private var cameraAnchorXAdditive:Int = -20;
	var playedDeathNoise:Bool = false;
	var deathSound:FlxSound = new FlxSound();
	var retrySound:FlxSound = new FlxSound();
	var retryFade:FlxTween;
	var gameOverTimer:FlxTimer;
	var gameOverFrameRandomizer:Int = 0;

	var defaultZoom:Float = FlxG.camera.zoom;
	var prevDefaultZoom:Float = FlxG.camera.zoom;

	var gameOver1:FlxSprite;
	var gameOver2:FlxSprite;
	var gameOver1Tween:FlxTween;
	var gameOver2Tween:FlxTween;

	private var camMain:FlxCamera;
	private var camOverlay:FlxCamera;

	var sinShit:Float = 0;

	public function new(x:Float, y:Float)
	{
		camMain = new FlxCamera();
		camOverlay = new FlxCamera();
		camOverlay.bgColor.alpha = 0;
		FlxG.cameras.reset(camMain);
		FlxG.cameras.add(camOverlay);
		FlxCamera.defaultCameras = [camMain];

		camMain.followLerp = 0.055;
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
					{
						daBf = 'guy-default';
						cameraAnchorXAdditive = -15;
					}
			}

		super();

		Conductor.songPosition = 0;

		gameOver1 = new FlxSprite(0, 0).loadGraphic(Paths.image('Gameover_0'));
		gameOver1.setGraphicSize(Std.int(gameOver1.width * 0.75));
		gameOver1.updateHitbox();
		//gameOver1.scrollFactor.set();
		gameOver1.x -= gameOver1.width * 2;
		gameOver1.y -= 50;
		gameOver1.alpha = 0;
		if(FlxG.save.data.antialiasing)
			gameOver1.antialiasing = true;
		gameOver1.cameras = [camOverlay];
		add(gameOver1);

		gameOver2 = new FlxSprite(FlxG.width, 0).loadGraphic(Paths.image('Gameover_1'));
		gameOver2.setGraphicSize(Std.int(gameOver2.width  * 0.75));
		gameOver2.updateHitbox();
		//gameOver2.y -= gameOver1.height - 10;
		//gameOver2.scrollFactor.set();
		gameOver2.x += camOverlay.width + gameOver2.width; 
		gameOver2.y -= 50;
		gameOver2.alpha = 0;
		if(FlxG.save.data.antialiasing)
			gameOver2.antialiasing = true;
		gameOver2.cameras = [camOverlay];
		add(gameOver2);

		
		bf = new Boyfriend(x, y, daBf);
		add(bf);

		cameraAnchor = new FlxObject(bf.getGraphicMidpoint().x + cameraAnchorXAdditive, bf.getGraphicMidpoint().y, 1, 1);
		add(cameraAnchor);

		Conductor.changeBPM(100);

		camMain.scroll.set();
		camMain.target = null;

		PlayState.instance.clear();
		//Loading it here again cuz I can't do the custom flxsound shit if I don't (hopefully haxeflixel doesn't add it to the cache again-)
		FlxG.sound.music.looped = true;
		retrySound = new FlxSound().loadEmbedded(Paths.music('gameOver' + PlayState.stageSuffix + '_End'));
		bf.playAnim('firstDeath');
	}

	var gameOverX:Float = 0;
	var pressedConfirm:Bool = false;
	//Var to prevent pressing enter then going back to menu, I'm pretty sure this fixes a very rare crash that happens when the game loads and exits to the story menu at the same time but idk

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!isEnding)
			camMain.zoom = FlxMath.lerp(defaultZoom, camMain.zoom, 0.95);

		if (controls.ACCEPT || (FlxG.keys.justPressed.R && FlxG.save.data.resetButton))
		{
			pressedConfirm = true;
			endBullshit();
			FlxG.log.add('ended bullshit');
		}

		if (controls.BACK && !pressedConfirm)
		{
			FlxTransitionableState.skipNextTransOut = false;
			FlxTransitionableState.skipNextTransIn = false;
			FlxG.sound.music.fadeOut(0.2);
			deathSound.fadeOut(0.3);

			PauseSubState.randomMusicTime = false;

			PlayState.startTime = 0;
			PlayState.deaths = 0;
			PlayState.hasReset = false;
			PlayState.showedLoadingIcon = false;

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

			if (gameOverCheckShit >= 2)
			{
				gameOver1Tween.cancel();
				gameOver2Tween.cancel();
				gameOver1Tween = FlxTween.tween(gameOver1, {alpha: 0, x: -gameOver1.width}, 0.3, {type: ONESHOT, ease: FlxEase.sineIn});
				gameOver2Tween = FlxTween.tween(gameOver2, {alpha: 0, x: camOverlay.width}, 0.3, {type: ONESHOT, ease: FlxEase.sineIn});
			}
			camOverlay.fade(FlxColor.BLACK, 0.25, false);
			camMain.fade(FlxColor.BLACK, 0.3, false, function()
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

		if (bf.animation.curAnim.name == 'firstDeath' && !isEnding)
		{
			if (bf.animation.curAnim.curFrame > 3)
			{
				if (PlayState.SONG.song.toLowerCase() != "mic test")
					defaultZoom = 1.1;
				else
					defaultZoom = 0.985;
			}
			else
				camMain.follow(cameraAnchor, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath')
		{
			if (bf.animation.curAnim.curFrame == 20 && gameOverCheckShit <= 0)
			{
				gameOverCheckShit++;
				gameOverX = (camOverlay.x + (camOverlay.width - (gameOver1.width + gameOver2.width) * gameOver1.scale.x - 85) / 2) - 20;
				gameOver1Tween = FlxTween.tween(gameOver1, {alpha: 1, x: gameOverX - 15, y: gameOver1.height * gameOver1.scale.y / 3}, 1.5, {type: ONESHOT, ease: FlxEase.expoInOut});
				gameOver2Tween = FlxTween.tween(gameOver2, {alpha: 1, x: gameOverX + gameOver2.width + 30, y: gameOver2.height * gameOver2.scale.y / 3}, 1.5, {type: ONESHOT, ease: FlxEase.expoInOut});
			}
			else if (bf.animation.curAnim.curFrame == 25 && gameOverCheckShit <= 1)
			{
				gameOverCheckShit++;
				cameraAnchor.y -= 90;
			}
			else if (bf.animation.curAnim.finished)
			{
				if (PlayState.SONG.song.toLowerCase() == "mic test")
				{
					FlxG.sound.playMusic(Paths.music('gameOver' + PlayState.stageSuffix), 0.1);
					FlxG.sound.music.fadeIn(8, 0.1, 1);
				}
				else
					FlxG.sound.playMusic(Paths.music('gameOver' + PlayState.stageSuffix));

				prevDefaultZoom = defaultZoom;
				trace('started vibin');
			}
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	var gameOverCheckShit:Int = 0;
	
	override function beatHit()
	{
		super.beatHit();
		
		if (!isEnding)
		{
			if (PlayState.SONG.player1 == "selfsert-default")
			{
				gameOverFrameRandomizer = FlxG.random.int(0, 30);
				if (curBeat % 2 == 0)
					camMain.zoom += 0.01;
			}
			if (FlxG.sound.music.playing)
				bf.playAnim('deathLoop', true, false, gameOverFrameRandomizer);
		}
	}

	var isEnding:Bool = false;

	function endBullshit():Void
	{
		if (!isEnding)
		{
			PlayState.startTime = 0;
			if (gameOverCheckShit >= 2)
			{
				cameraAnchor.y += 90;
				gameOver1Tween.cancel();
				gameOver2Tween.cancel();
				gameOver1Tween = FlxTween.tween(gameOver1, {alpha: 0, x: -gameOver1.width, y: -50}, 0.8, {type: ONESHOT, ease: FlxEase.expoIn});
				gameOver2Tween = FlxTween.tween(gameOver2, {alpha: 0, x: camOverlay.width, y: -50}, 0.8, {type: ONESHOT, ease: FlxEase.expoIn});
			}
			//isEnding Ending Fx
			if (PlayState.SONG.song.toLowerCase() == "mic test")// || PlayState.SONG.player1 == "selfsert-default")
			{
				cameraAnchor.y -= 150;
				FlxTween.tween(camMain, {zoom: 1.7}, 0.5, {type: ONESHOT, ease: FlxEase.elasticOut});
				FlxTween.tween(camMain, {x: camera.x - 1000, y: camera.y - 800}, 1, {type: ONESHOT, ease: FlxEase.expoIn, startDelay: 2});
				FlxTween.tween(camOverlay, {zoom: 1.7}, 0.5, {type: ONESHOT, ease: FlxEase.elasticOut});
				FlxTween.tween(camOverlay, {x: camera.x - 1000, y: camera.y - 800}, 1, {type: ONESHOT, ease: FlxEase.expoIn, startDelay: 2});
			}
			else
			{
				switch (PlayState.SONG.player1)
				{
					case "selfsert-default":
						cameraAnchor.y -= 160;
						FlxTween.tween(camMain, {zoom: 1.7}, 0.6, {type: ONESHOT, ease: FlxEase.elasticOut});
						FlxTween.tween(camMain, {zoom: 0.5, alpha: 0}, 2, {type: ONESHOT, ease: FlxEase.expoIn, startDelay: 2});
						FlxTween.tween(camOverlay, {zoom: 1.7}, 0.6, {type: ONESHOT, ease: FlxEase.elasticOut});
						FlxTween.tween(camOverlay, {zoom: 0.5, alpha: 0}, 2, {type: ONESHOT, ease: FlxEase.expoIn, startDelay: 2});
					default:
						FlxTween.tween(camMain, {zoom: camMain.zoom + 0.1}, 0.5, {ease: FlxEase.elasticOut});
						FlxTween.tween(camMain, {y: camera.y + 800}, 1, {type: ONESHOT, ease: FlxEase.expoIn, startDelay: 2});
						FlxTween.tween(camOverlay, {zoom: camMain.zoom + 0.1}, 0.5, {ease: FlxEase.elasticOut});
						FlxTween.tween(camOverlay, {y: camera.y + 800}, 1, {type: ONESHOT, ease: FlxEase.expoIn, startDelay: 2});
				}
			}
			camMain.follow(cameraAnchor, LOCKON, 0.01);
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			retrySound.play(true);
			retrySound.persist = true;
			retrySound.autoDestroy = true;
			FlxG.sound.music.pause();
			defaultZoom = prevDefaultZoom;
			FlxTransitionableState.skipNextTransOut = true;
			gameOverTimer = new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				camOverlay.fade(FlxColor.BLACK, 3.5, false);
				camMain.fade(FlxColor.BLACK, 3.5, false, function()
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
