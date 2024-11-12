package;

import lime.app.Application;
import lime.media.openal.AL;
import openfl.Lib;

//import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSubState;
import flixel.math.FlxPoint;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.system.FlxSound;
import flixel.text.FlxText;
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
	private var cameraAnchorYAdditive:Int = 20;
	var deathSound:FlxSound = new FlxSound();
	var retrySound:FlxSound = new FlxSound();
	var retryFade:FlxTween;
	var gameOverTimer:FlxTimer;
	var gameOverFrameRandomizer:Int = 0;

	var defaultZoom:Float = FlxG.camera.zoom;
	var prevDefaultZoom:Float = FlxG.camera.zoom;
	var defaultOverlayZoom:Float = 1.05;

	var gameOver1:FlxSprite;
	var gameOver2:FlxSprite;
	var gameOver1Tween:FlxTween;
	var gameOver2Tween:FlxTween;

	var tipText:FlxText;
	var doLoreTips:Bool = false;
	var doCorruptTips:Bool = false;

	private var camMain:FlxCamera; //For main stuff like guy or BG
	private var camOverlay:FlxCamera; //For effects
	private var camHUD:FlxCamera; //For UI

	var sinShit:Float = 0;

	var tipTween:FlxTween;

	public function new(x:Float, y:Float)
	{
		if (FlxG.sound.music != null && FlxG.sound.music.playing)
			FlxG.sound.music.stop();

		camMain = new FlxCamera();
		camOverlay = new FlxCamera();
		camOverlay.bgColor.alpha = 0;
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camMain);
		FlxG.cameras.add(camOverlay);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camMain];

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
						cameraAnchorXAdditive = 5;
						cameraAnchorYAdditive = -20;
					}
			}

		super();

		Conductor.songPosition = 0;

		switch (PlayState.instance.causeOfDeath)
		{
			case 'ate-bullet':	
				var painOverlay:FlxSprite = new FlxSprite().loadGraphic(Paths.image('lowHPOverlay'));
				painOverlay.scale.x *= 0.71;
				painOverlay.scale.y *= 0.71;
				painOverlay.scrollFactor.set();
				painOverlay.updateHitbox();
				if(FlxG.save.data.antialiasing)
					painOverlay.antialiasing = true;
				painOverlay.cameras = [camHUD];
				painOverlay.screenCenter();
				painOverlay.alpha = 0.75;
				add(painOverlay);
				
				camMain.shake(0.025, 1, true, true);
				FlxTween.tween(painOverlay, {alpha: 0}, 1);
			case 'ate-many-bullets':
				var painOverlay:FlxSprite = new FlxSprite().loadGraphic(Paths.image('lowHPOverlay'));
				painOverlay.scale.x *= 0.68;
				painOverlay.scale.y *= 0.68;
				painOverlay.scrollFactor.set();
				painOverlay.updateHitbox();
				if(FlxG.save.data.antialiasing)
					painOverlay.antialiasing = true;
				painOverlay.cameras = [camHUD];
				painOverlay.screenCenter();
				add(painOverlay);
				
				camMain.shake(0.05, 1.3, true, true);
				FlxTween.tween(painOverlay, {alpha: 0}, 2);
			default:
				camMain.shake(0.015, 0.7, true, true);
		}

		gameOver1 = new FlxSprite(0, 0).loadGraphic(Paths.image('Gameover_0'));
		gameOver1.setGraphicSize(Std.int(gameOver1.width * 0.75));
		gameOver1.updateHitbox();
		//gameOver1.scrollFactor.set();
		gameOver1.x -= gameOver1.width;
		gameOver1.y -= 80;
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
		gameOver2.y = -80;
		gameOver2.alpha = 0;
		if(FlxG.save.data.antialiasing)
			gameOver2.antialiasing = true;
		gameOver2.cameras = [camOverlay];
		add(gameOver2);
		
		bf = new Boyfriend(x, y, daBf);
		add(bf);

		cameraAnchor = new FlxObject(bf.getGraphicMidpoint().x + cameraAnchorXAdditive, bf.getGraphicMidpoint().y + cameraAnchorYAdditive, 1, 1);
		add(cameraAnchor);

		//Tips
		if ((StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase() == 'retaliation'))
		{
			if (FlxG.random.bool(30))
				doLoreTips = true;
			else
				doCorruptTips = true;
		}
		else if (FlxG.random.bool(0.5))
			doLoreTips = true;

		tipText = new FlxText(0, FlxG.height, Std.int(FlxG.width), '', 12);
		tipText.alpha = 0;
		tipText.scrollFactor.set();
		tipText.antialiasing = true;
		tipText.setFormat("VCR OSD Mono", 18, FlxColor.WHITE, CENTER);
		tipText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3, 1);
		
		var textLol:String = getTips(PlayState.storyWeek, PlayState.naturalDeaths, PlayState.instance.causeOfDeath) + '^[ESC] or [R. CLICK] - Exit.' + '                                                   ' + '[ENTER] or [L. CLICK] - Retry.^';
		var tip:FlxTextFormat = new FlxTextFormat("VCR OSD Mono", 23, FlxColor.YELLOW, true, false);
		var lore:FlxTextFormat = new FlxTextFormat("Times New Roman", 20, 0x000000, true, true, 0xFF740D55);
		var corrupt:FlxTextFormat = new FlxTextFormat("Monsterrat", 25, 0xFFFF0000, true, false);
		var input:FlxTextFormat = new FlxTextFormat("VCR OSD Mono", 18, FlxColor.WHITE, false, false);
		tipText.applyMarkup(textLol, [new FlxTextFormatMarkerPair(tip, "#"), new FlxTextFormatMarkerPair(lore, "&"), new FlxTextFormatMarkerPair(corrupt, "*"), new FlxTextFormatMarkerPair(input, "^")]);

		tipText.updateHitbox();
		tipText.screenCenter(X);
		tipText.cameras = [camHUD];

		add(tipText);

		Conductor.changeBPM(100);

		camMain.scroll.set();
		camMain.target = null;

		bf.playAnim('firstDeath');
		deathSound = FlxG.sound.play(Paths.sound('deathsound' + PlayState.stageSuffix));
		if (PlayState.songsCheatedOn != null && !PlayState.songsCheatedOn.contains(true))
			PlayState.toggledPracticeMode = false;
	}

	var gameOverX:Float = 0;
	//Var to prevent pressing enter then going back to menu, I'm pretty sure this fixes a very rare crash that happens when the game loads and exits to the story menu at the same time but idk
	var pressedConfirm:Bool = false;
	var sineShit:Float = 0;

	override function update(elapsed:Float)
	{
		sineShit += 0.0025;
		//NaN prevention-?
		if (sineShit >= 1000000)
			sineShit = 0;

		super.update(elapsed);

		if (!isEnding)
		{
			if (FlxG.sound.music.playing)
			{
				defaultZoom += 0.000025 * Math.sin(sineShit);
				defaultOverlayZoom += 0.000055 * Math.sin(sineShit);
			}
			camMain.zoom = FlxMath.lerp(defaultZoom, camMain.zoom, CoolUtil.boundTo(1 - (elapsed * 3), 0, 1));
			camOverlay.zoom = FlxMath.lerp(defaultOverlayZoom, camOverlay.zoom, CoolUtil.boundTo(1 - (elapsed * 2.5), 0, 1));
		}

		if ((controls.ACCEPT || (FlxG.mouse.justPressed && Main.isFocused)) || (FlxG.keys.justPressed.R && FlxG.save.data.resetButton))
		{
			pressedConfirm = true;
			endBullshit();
			FlxG.log.add('ended bullshit');
		}

		if ((controls.BACK || (FlxG.mouse.justPressedRight && Main.isFocused)) && !pressedConfirm)
		{
			FlxTransitionableState.skipNextTransOut = false;
			FlxTransitionableState.skipNextTransIn = false;
			FlxG.sound.music.fadeOut(0.2);
			deathSound.fadeOut(0.3);

			if (gameOverCheckShit >= 2)
			{
				gameOver1Tween.cancel();
				gameOver2Tween.cancel();
				gameOver1Tween = FlxTween.tween(gameOver1, {alpha: 0, x: -gameOver1.width}, 0.3, {type: ONESHOT, ease: FlxEase.sineIn});
				gameOver2Tween = FlxTween.tween(gameOver2, {alpha: 0, x: camOverlay.width}, 0.3, {type: ONESHOT, ease: FlxEase.sineIn});
			}
			if (tipTween != null)
				tipTween.cancel();
			tipTween = FlxTween.tween(tipText,{alpha: 0, y: FlxG.height}, 0.5,{ease: FlxEase.smoothStepOut});
			camOverlay.fade(FlxColor.BLACK, 0.25, false);
			camMain.fade(FlxColor.BLACK, 0.3, false, function()
			{
				FlxG.sound.music.stop();
				FlxG.bitmap.clearCache();
				if (PlayState.isStoryMode)
				{
					Conductor.changeBPM(102);
					PlayState.instance.clear();
					FlxG.switchState(new StoryMenuState());
					//FlxG.sound.playMusic(Paths.music('freakyMenu'));
				}
				else
				{
					PlayState.instance.clear();
					FlxG.switchState(new FreeplayState());
				}
			});
        }

		if (bf.animation.curAnim.name == 'firstDeath' && !isEnding)
		{
			if (bf.animation.curAnim.curFrame > 3)
			{
				if (PlayState.SONG.song.toLowerCase() != "mic test")
					defaultZoom = 1.1;
				else if (PlayState.SONG.player1 == "selfsert-default")
					defaultZoom = 0.95;
				else
					defaultZoom = 1.25;
			}
			else
				camMain.follow(cameraAnchor, LOCKON, 2);
		}

		if (bf.animation.curAnim.name == 'firstDeath')
		{
			//where everything tweens in
			if (bf.animation.curAnim.curFrame == 15 && gameOverCheckShit <= 0)
			{
				gameOverCheckShit++;
				gameOverX = (camOverlay.x + (camOverlay.width - (gameOver1.width + gameOver2.width) * gameOver1.scale.x - 85) / 2) - 20;
				gameOver1Tween = FlxTween.tween(gameOver1, {alpha: 1, x: (gameOverX - 15) -15, y: (gameOver1.height - 30) * gameOver1.scale.y / 3}, 1.5, {type: ONESHOT, ease: FlxEase.expoInOut});
				gameOver2Tween = FlxTween.tween(gameOver2, {alpha: 1, x: (gameOverX + gameOver2.width + 30) - 15, y: (gameOver2.height - 30) * gameOver2.scale.y / 3}, 1.5, {type: ONESHOT, ease: FlxEase.expoInOut});

				camMain.followLerp = 1.5;

				if ((!doCorruptTips && !doLoreTips || PlayState.naturalDeaths < 3))
				{
					tipTween = FlxTween.tween(tipText,{alpha: 1, y: FlxG.height - tipText.height - 4}, 1.25,{ease: FlxEase.smoothStepOut, onComplete:
						function (twn:FlxTween)
						{
							tipTween = null;
						}
					});
				}
				else
				{
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						tipText.alpha = 1;
						tipText.y = FlxG.height - tipText.height - 4;
						new FlxTimer().start(0.05, function(tmr:FlxTimer)
						{
							tipText.visible = !tipText.visible;
						}, 6);
					});
				}
			}
			else if (bf.animation.curAnim.curFrame == 25 && gameOverCheckShit <= 1)
			{
				gameOverCheckShit++;
				cameraAnchor.y -= 50;
			}
			else if (bf.animation.curAnim.finished)
			{
				if (!doLoreTips && !doCorruptTips)
				{
					playGameoverMusic();

					if (PlayState.SONG.song.toLowerCase() == "mic test")
						FlxG.sound.music.fadeIn(8, 0.1, 1);
					else
						FlxG.sound.music.volume = 1;

					prevDefaultZoom = defaultZoom;

					beatHit();
				}
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
			if (FlxG.save.data.camzoom && curBeat % 4 == 0 && (curBeat >= 64 || PlayState.SONG.song.toLowerCase() != "mic test"))
			{
				camMain.zoom += 0.01;
				camOverlay.zoom += 0.02;
			}

			if (PlayState.SONG.player1 == "selfsert-default")
			{
				gameOverFrameRandomizer = FlxG.random.int(0, 30);
			}

			if (FlxG.sound.music.playing)
				bf.playAnim('deathLoop', true, false, gameOverFrameRandomizer);
		}
	}

	var isEnding:Bool = false;
	
	//again, sticks and ductape but like :3
	var playedIntro:Bool = false;
	function playGameoverMusic():Void
	{
		//grAHH more sticks and ductabe but trust me this is better than just writing the gaeovers with intro cuz it allows for adaptablility idfkj sKBCKFSSDH
		var doIntroCheck:Bool = false;
		for (i in PlayState.gameOversWithIntros)
			if (PlayState.stageSuffix == i)
				doIntroCheck = true;

		if (!playedIntro && doIntroCheck)
		{
			playedIntro = true;
			FlxG.sound.playMusic(Paths.music('lose_screen/gameOver' + PlayState.stageSuffix + "_Intro"), 0);
			//thinking if this should just be silence or not
			FlxG.sound.music.looped = false;
			//wOH GAWD THIS IS ATROCIOUS BUT LIKE LISTEN TO ME - THE FlxG.sound.music.onComplete FUNCTION IS ASS SO IM DOING WHAT I CAN TO MAKE THE MUSIC SEAMLESSLY PLAY- DONT JUDGE ME!!!
			new FlxTimer().start(FlxG.sound.music.length / 1000, function(wasteOfSpaceLmao:FlxTimer)
			{
				//Did not have the courage to call playGameoverMusic again - considering I already have to make this function regardless anyways-
				FlxG.sound.playMusic(Paths.music('lose_screen/gameOver' + PlayState.stageSuffix), 1);
				FlxG.sound.music.looped = true;
			});
		}	
		else
		{
			var startingVolume:Float = 0;
			if (playedIntro)
				startingVolume = 1;

			FlxG.sound.playMusic(Paths.music('lose_screen/gameOver' + PlayState.stageSuffix), startingVolume);
			FlxG.sound.music.looped = true;
		}
	}

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
						FlxTween.tween(camMain, {zoom: 0.5}, 2, {type: ONESHOT, ease: FlxEase.expoIn, startDelay: 1.8});
						FlxTween.tween(camMain, {alpha: 0}, 2, {type: ONESHOT, ease: FlxEase.smootherStepIn, startDelay: 2});
						FlxTween.tween(camOverlay, {zoom: 1.7}, 0.6, {type: ONESHOT, ease: FlxEase.elasticOut});
					default:
						FlxTween.tween(camMain, {zoom: camMain.zoom + 0.1}, 0.5, {ease: FlxEase.elasticOut});
						FlxTween.tween(camMain, {y: camera.y - 800}, 1, {type: ONESHOT, ease: FlxEase.expoIn, startDelay: 2});
						FlxTween.tween(camOverlay, {zoom: camMain.zoom + 0.1}, 0.5, {ease: FlxEase.elasticOut});
				}
			}

			if (tipTween != null)
				tipTween.cancel();
			tipTween = FlxTween.tween(tipText,{alpha: 0, y: FlxG.height}, 0.5,{ease: FlxEase.smoothStepOut});

			camMain.follow(cameraAnchor, LOCKON, 2);
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			retrySound = FlxG.sound.play(Paths.music('lose_screen/gameOver' + PlayState.stageSuffix + '_End'));
			retrySound.persist = true;
			FlxG.sound.music.pause();
			defaultZoom = prevDefaultZoom;
			FlxTransitionableState.skipNextTransOut = true;
			gameOverTimer = new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				camOverlay.fade(FlxColor.BLACK, 3.5, false);
				camMain.fade(FlxColor.BLACK, 3.5, false, function()
				{
					PlayState.instance.nextStateIsPlayState = true;
					PlayState.forceCoolIntro = true;
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
			PlayState.instance.nextStateIsPlayState = true;
			PlayState.forceCoolIntro = true;
			LoadingState.loadAndSwitchState(new PlayState());
		}
	}

	function getTips(week:Int, deaths:Int, deathCause:String):String
	{
		var tip:String = '';
		
		if (deaths >= 2)
		{
			tip = '#Tip: ';
			
			trace(deathCause);
			if (doLoreTips)
			{
				tip = '&';
				tip += loreTips[FlxG.random.int(0, 19)];
				tip += '&\n\n';
				return tip;
			}
			else if (doCorruptTips)
			{			
				var rand:Int = FlxG.random.int(0, 19);
				if (rand == 18 && FlxG.random.bool(50))
					rand = FlxG.random.int(0, 19);
				tip = '*';
				tip += corruptedTips[rand];
				tip += '*\n\n';
				if (rand == 18)
				{
					var fakeCrashErr:Array<String> = [
						"im so hungry",
						"someone please help me",
						"dad doesnt want me to leave my room",
						"inside my room i am safe",
						"i can't sleep",
						"i see anguished faces in the walls",
						"dad doesnt want me around",
						"it hurts",
						"when dad gets mad, he hits me with a bat",
						"when dad gets mad, he hits me",
						"when dad gets mad, he makes me bleed",
						"the pain",
						"i miss her",
						"she's gone",
						"he's drunk again",
						"the house is in disarray",
						"if he sees me out here, i'm as good as dead",
						"it can't be helped",
						"it hurts so much when i cry",
						"if i cant handle it i sleep"
					];
					var fakeCrashEnd:Array<String> = [
						"it's been days.",
						"someone please...",
						"inside my room i am safe.",
						"no food nor water in sight.",
						"it's been weeks.",
						"i hear screaming in my head.",
						"if he sees me, i get hurt.",
						"so much.",
						"it wasn't my fault.",
						"why does he blame me.",
						"sometimes i wish i'd never bleed again.",
						"it hurts.",
						"why did she have to go.",
						"no one will see her again.",
						"and he's calling my name.",
						"nobody left to fix it.",
						"sometimes i wish i was to begin with.",
						"life just ended up this way.",
						"i can't afford to lose any more water.",
						"sometimes i wish i'd never wake up ever again."
					];
					rand = FlxG.random.int(0, 19);
					var lineRand:Int = FlxG.random.int(0, 5000);
					var numLol:Int = 0;
					var fakeErr:String = "Thursday Morning Graduatin' has crashed!\n(and nobody is coming to help.):\n\n";
					fakeErr += "TMG Version: 0.1.04 (Early 2018 Build)\n";
					for (i in 0...5)
					{
						numLol = i + lineRand;
						fakeErr += "     " + fakeCrashErr[rand] + " (line " + numLol + ")\n";
					}
					fakeErr += "\nUncaught Error: " + fakeCrashEnd[rand] + "\n[not enough time not enough time not enough time not enough]\n\nPlease send the obituary to the father!";
					fakeErr += "\n(a version of this can't be found. You will never see her again.)";
					new FlxTimer().start(1.75, function(tmr:FlxTimer)
					{
						if (!pressedConfirm)
						{
							Main.crashSound.play();
							Application.current.window.alert(fakeErr, "Oh no!");
						}
					});
				}
				return tip;
			}

			switch (deathCause)
			{
				case 'skill-issue':
					switch (week)
					{
						case 0 | 1:
							tip += regularTips[FlxG.random.int(0, 9)];
						default:
							tip += laterTips[FlxG.random.int(0, 9)];
					}

				case 'intentional-reset':
					tip = '#(';
					tip += resettingTips[FlxG.random.int(0, 9)] + ')';

				case 'ate-bullet':
					if (week != 3)
						tip += 'Cool! You discovered the chart editor LMAO!';
					else
						tip += bulletTips[FlxG.random.int(0, 4)];
				case 'ate-many-bullets':
					if (week != 3)
						tip = 'Cool! You discovered the chart editor LMAO!';
					else
						tip += bulletTips[FlxG.random.int(4, 9)];
				case 'note-spam' | 'no-ghost-tapping':
					tip += mashingTips[FlxG.random.int(0, 9)];
				default:
					tip = '';
					return tip;
			}

			tip += '#\n\n';
		}

		return tip;
	}

	//For tutorial - week 1
	var regularTips:Array<String> = [
		"Press the arrows on-time with the beat!",
		"Follow the melody, press the arrows accordingly!",
		"Your timing matters, press with the rhythm~!",
		"Listen to the rhythm, press the arrows with the melody!",
		"Press the arrows when it's your turn to sing!",
		"When the camera moves to you, it's your turn to sing!",
		"Watch your health! If it gets too low, you lose!",
		"Having a hard time..? Enable 'Practice Mode' in the Pause Menu!",
		"Is the game too distracting..? Turn on 'Reduced Distractions' in 'Options > Accessibility'!",
		"Wanna practice this song? Enable 'Practice Mode' in the Pause Menu!"
	];

	//For the later weeks
	var laterTips:Array<String> = [
		"Press the arrows on-time with the beat!",
		"Watch your accuracy! The lower it is, the less health you gain!",
		"Your timing matters, press with the rhythm~!",
		"Does your setup have latency? Adjust your offset within the Options Menu!",
		"Sensitive to flashing lights? Check 'Options > Accessibility'!",
		"Keep an eye on your arrows!",
		"Is your game lagging? Check 'Options > Performance'!",
		"Having a hard time..? Enable 'Practice Mode' in the Pause Menu!",
		"Is the game too distracting..? Turn on 'Reduced Distractions' in 'Options > Accessibility'!",
		"Wanna practice this song? Enable 'Practice Mode' in the Pause Menu!"
	];

	//For a small 5% chance of recieving LORE?!?!?!?!?! (unless you playing retaliation, in which case, it's a 30%!)
	var loreTips:Array<String> = [
		"C-can you hear me..? Please don't give up on me now...",
		"...I love you too. Promise you'll take care of him for me, ok?",
		"...All your mother wanted was to give us cheer...",
		"D-dad are you... drunk? Wh-what are you holding-?",
		"Promise you'll stay strong... for me... for us...",
		"it's been days since i ate nor drank anything.",
		"i'm safe where he can't get to.",
		"it's only a matter of time before i starve to death.",
		"i can't think. it hurts to do anything.",
		"my life's at risk beyond this door, but at this point, what do i even have to lose?",
		"You can't give up on me like this..! Please, get up!",
		"Please, you can't leave us now... don't give up on us!",
		"Hang in there, don't leave us... please...",
		"Everything is going dark...",
		"My time is running out...",
		"I'm sorry, my dear Eddy... I promise I'll wait for you in heaven, ok?",
		"...Nobody expected that we'd end up here.",
		"i won't ever forget you... after what you've done for me...",
		"...I will always be proud of you no matter what, I want you to remember that.",
		"it's been months since she left... i miss her more every single day."
	];

	//error ior something
	var corruptedTips:Array<String> = [
		"nullObjectReference. Variable 'tipText' has not been found!",
		"null",
		"Missing font: 'VCR OSD Mono'. Make sure you have the correct fonts installed.",
		"______________________________________________________________________",
		"The program has experienced an unknown error. Please close the Please close the Pleas",
		"Invalid data retrieved!",
		"Corrupt 'Project.xml' file! Please delete the Please delete the Please",
		"Missing asset, wrong data retrieved!",
		"Invalid character!",
		"%%%%%",
		"('testText')",
		"Invalid untilization of 'systemExit' function! Exit command denied.",
		"Fatal error in GC!",
		"Misallocation of RAM! Please close the program. Please close the program now. Please.",
		"Date and Time error! Please restart your computer.",
		"Critical error! Please exit the program",
		"YOU ARE BEING WATCHED.",
		"you can't hide forever",
		"...did i get you?",
		"hide while you still can."
	];

	//For Week 3's bullet mechanic
	var bulletTips:Array<String> = [
		"Keep an eye on the arrows!",
		"You'll hear him reloading before he shoots!",
		"You got shot! You can do a clutch by gaining health before your health reaches 0!",
		"You got shot! You have a small window of time to gain health!",
		"Press the cool blue arrows, Avoid the red dangerous ones!",

		"You have a limited amount of clutches, so tread lightly!",
		"Getting shot too much kills you... Probably from all the blood loss!",
		"Getting shot doesn't instakill, but do it too much times and you die-",
		"Don't get shot too much times or you die!",
		"Easy now, try not to get shot TOO much!"
	];

	//for intentional resets
	var resettingTips:Array<String> = [
		"You can do it, take as many tries as you need!",
		"I believe in you! One more try!!",
		"C'mon, you got this!",
		"You can do this! I believe in you!",
		"You have as much tries as you need!",
		"Take your time, you'll get there eventually!",
		"Every failure is a step closer to success~!",
		"If you need a breather, you can always try again later!",
		"Take it easy, you're always free to take a break-!",
		"Breathe and relax... Take a break whenever you need!"
	];

	//For mashing-related injuries
	var mashingTips:Array<String> = [
		"Calm down you're gonna hurt all yer fingies-",
		"T-that's not how you play rhythm games-!!!",
		"BRO STOP MASHING-",
		"Error, unknown command: 'DDFJKDFJDKJFDJFDKJFKJFJKDKJFDKJFDKJFJKKJFDKJDKJDFKJDFKJD'.",
		"9/10 Doctors recommend to stop mashing!",
		"Try pressing the arrows to the rhythm of the song-! You can do it!",
		"Try not to mash! It is a rhythm game after all!",
		"Try not to mash the funny arrows",
		"Spamming the arrows punish you- (sorry)!",
		"Great energy!.. But maybe tone it down a little!"
	];

}
