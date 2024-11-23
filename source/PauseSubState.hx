package;

import flixel.input.gamepad.FlxGamepad;
import openfl.Lib;
import Controls.Control;
//import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.math.FlxMath;

class PauseSubState extends MusicBeatSubstate
{
	public static var skippedSong:Bool = false;
	public static var resyncToLastPos:Bool = false;
	public static var randomMusicTime:Bool = false;

	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Toggle Practice Mode', 'Skip Song', 'Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	//var oldPauseVolume:Float = 0;
	#if cpp
	#if debug
	var perSongOffset:FlxText;
	var blackBorder:FlxSprite;
	#end
	#end
	
	var offsetChanged:Bool = false;

	//Declared Here for changeable purposus
	var practiceModeText:FlxText;
	var runValidityText:FlxText;

	var doFancyCountdownShit:Bool = false;

	var resumeTimer:FlxTimer;

	var bg:FlxSprite;
	var levelInfo:FlxText;
	var levelDifficulty:FlxText;
	var failCount:FlxText;

	var pauseSound:FlxSound;

	var blurTweenGoBrr:FlxTween = null;
	var funnyBlur:Float;

	var antiHoverRect:FlxObject;

	public function new(x:Float, y:Float)
	{
		super();
		PlayState.instance.camGame.filtersEnabled = true;

		//Blur Tween cuz cool
		if (blurTweenGoBrr != null)
			blurTweenGoBrr.cancel();

		blurTweenGoBrr = FlxTween.tween(this, {funnyBlur: 3}, 1, {ease: FlxEase.cubeOut,
			onUpdate: function(twn:FlxTween) 
			{
				PlayState.instance.pauseBlurLol.blurX = funnyBlur;
				PlayState.instance.pauseBlurLol.blurY = funnyBlur;
			},
			
			onComplete: function(twn:FlxTween) 
			{
				blurTweenGoBrr = null;
			}
		});

		doFancyCountdownShit = false;
		//FlxG.game.soundTray.silent = true;

		/*if (PlayState.instance.useVideo)
		{
			menuItems.remove("Resume");
			if (GlobalVideo.get().playing)
				GlobalVideo.get().pause();
		}*/

		if (!PlayState.isStoryMode || PlayState.SONG.song.toLowerCase() == "mic test")
			menuItems.remove("Skip Song");
		if (PlayStateChangeables.botPlay || PlayState.SONG.song.toLowerCase() == "mic test")
			menuItems.remove("Toggle Practice Mode");

		pauseMusic = new FlxSound().loadEmbedded(Paths.music(PlayState.pauseMusicName), true, true);
		if (PlayState.pauseMusicName != 'pause_screen/holy_shit_the_stalemate_is_on_fire')
			pauseMusic.volume = 0;
		else
			pauseMusic.volume = 0.3;
		
		if(randomMusicTime)
			pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
		else
		{
			if (!FlxG.random.bool(50))
				pauseMusic.play(false);
			else
				pauseMusic.play(false, Std.int(pauseMusic.length / 2));
		}

		FlxG.sound.list.add(pauseMusic);

		bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		levelInfo = new FlxText(20, 15, 0, "");
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("playtime.ttf"), 32);
		levelInfo.updateHitbox();
		levelInfo.alpha = 0;
		levelInfo.antialiasing = true;
		add(levelInfo);

		levelDifficulty = new FlxText(20, 15 + 32, 0, "");
		levelDifficulty.text += CoolUtil.difficultyFromInt(PlayState.storyDifficulty).toUpperCase();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font("playtime.ttf"), 32);
		levelDifficulty.updateHitbox();
		levelDifficulty.alpha = 0;
		levelDifficulty.antialiasing = true;
		add(levelDifficulty);

		failCount = new FlxText(20, 15 + 64, 0, "");
		failCount.text += "Fail Count: " + PlayState.campaignDeaths;
		failCount.scrollFactor.set();
		failCount.setFormat(Paths.font("playtime.ttf"), 32);
		failCount.updateHitbox();
		failCount.alpha = 0;
		failCount.antialiasing = true;
		add(failCount);

		practiceModeText = new FlxText(20, 15 + 96, 0, "");
		practiceModeText.text = "Practice Mode: " + (!PlayState.cannotDie? "Off" : "On");
		practiceModeText.scrollFactor.set();
		practiceModeText.setFormat(Paths.font("playtime.ttf"), 32, RIGHT);
		practiceModeText.updateHitbox();
		practiceModeText.alpha = 0;
		practiceModeText.antialiasing = true;
		add(practiceModeText);

		runValidityText = new FlxText(20, 15 + 128, 0, "");
		runValidityText.text = "Is A Valid Run: " + (!PlayState.toggledPracticeMode ? "Yes" : "No");
		runValidityText.scrollFactor.set();
		runValidityText.setFormat(Paths.font("playtime.ttf"), 32);
		runValidityText.updateHitbox();
		runValidityText.alpha = 0;
		runValidityText.antialiasing = true;
		add(runValidityText);

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		failCount.x = FlxG.width - (failCount.width + 20);
		practiceModeText.x = FlxG.width - (practiceModeText.width + 20);
		runValidityText.x = FlxG.width - (runValidityText.width + 20);

		FlxTween.tween(bg, {alpha: 0.75}, 0.75, {type: ONESHOT, ease: FlxEase.expoOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {type: ONESHOT, ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {type: ONESHOT, ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(failCount, {alpha: 1, y: failCount.y + 5}, 0.4, {type: ONESHOT, ease: FlxEase.quartInOut, startDelay: 0.7});
		FlxTween.tween(practiceModeText, {alpha: 1, y: practiceModeText.y + 5}, 0.4, {type: ONESHOT, ease: FlxEase.quartInOut, startDelay: 0.9});
		FlxTween.tween(runValidityText, {alpha: 1, y: runValidityText.y + 5}, 0.4, {type: ONESHOT, ease: FlxEase.quartInOut, startDelay: 1.1});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);
		#if cpp
		#if debug
		perSongOffset = new FlxText(5, FlxG.height, 0, "Additive Offset (Left, Right): " + PlayState.songOffset + " - Description - " + 'Adds song-dependent milisecond offset.', 12);
		perSongOffset.scrollFactor.set();
		perSongOffset.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		blackBorder = new FlxSprite(-30, FlxG.height).makeGraphic((Std.int(FlxG.width + 100)),Std.int(perSongOffset.height * 2),FlxColor.BLACK);
		blackBorder.alpha = 0.6;

		add(blackBorder);
		add(perSongOffset);

		FlxTween.tween(perSongOffset, {y: FlxG.height - 21}, 0.9, {type: ONESHOT, ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder, {y: FlxG.height - 20}, 0.8, {type: ONESHOT, ease: FlxEase.elasticInOut});
		#end
		#end

		for (i in 0...menuItems.length)
		{
			var item = new Alphabet(90, 360, menuItems[i], true, true, 1.25, 50);
			item.distancePerItem.set(30, 200);
			item.y *= i;
			item.targetY = i;
			item.ID = i;
			grpMenuShit.add(item);
		}

		antiHoverRect = new FlxObject(FlxG.width / 2, 0, FlxG.width / 2, FlxG.height * 4);
		antiHoverRect.screenCenter(Y);
		add(antiHoverRect);

		if (!didCountdownShit)
			changeSelection();

		cameras = [PlayState.instance.camEXT];

		FlxG.mouse.visible = true;
		pauseSound = new FlxSound().loadEmbedded(Paths.sound('pauseMenu'));
		FlxG.sound.list.add(pauseSound);
		pauseSound.volume = 0.7;
		pauseSound.play();

		new FlxTimer().start(2, function(swagTimer:FlxTimer)
		{
			doFancyCountdownShit = true;
		});
		mouseTimer = new FlxTimer().start(0.5, function(swagTimer:FlxTimer)
		{
			mouseActive = true;
		});
	}

	var mouseActive:Bool = false;
	var mouseTimer:FlxTimer;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (!didCountdownShit)
		{
			if (pauseMusic.volume <= 0.8)
				pauseMusic.volume = FlxMath.lerp(0.8, pauseMusic.volume, CoolUtil.boundToInverted(1 - (elapsed / 24), 0, 1));				
		}

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		var upPcontroller:Bool = false;
		var downPcontroller:Bool = false;
		var leftPcontroller:Bool = false;
		var rightPcontroller:Bool = false;
		var oldOffset:Float = 0;

		if (gamepad != null && KeyBinds.gamepad)
		{
			upPcontroller = gamepad.justPressed.DPAD_UP;
			downPcontroller = gamepad.justPressed.DPAD_DOWN;
			leftPcontroller = gamepad.justPressed.DPAD_LEFT;
			rightPcontroller = gamepad.justPressed.DPAD_RIGHT;
		}

		// pre lowercasing the song name (update)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		var songPath = 'assets/data/' + songLowercase + '/';

		if (!didCountdownShit)
		{
			if (mouseActive && FlxG.mouse.justMoved && Main.isFocused && !FlxG.mouse.overlaps(antiHoverRect))
			{
				for (item in grpMenuShit.members)
				{
					if (FlxG.mouse.overlaps(item) && curSelected != item.ID)
					{
						var change:Int = (item.ID - curSelected);
						changeSelection(change);
						mouseActive = false;
						mouseTimer = new FlxTimer().start(0.1, function(tmr:FlxTimer)
						{
							mouseActive = true;
						});
					}
				}
			}
			else
			{
				if (FlxG.keys.justPressed.UP || upPcontroller)
				{
					changeSelection(-1);
					mouseActive = false;
					if (mouseTimer.active)
						mouseTimer.cancel();
					mouseTimer = new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						mouseActive = true;
					});
				}
				if (FlxG.keys.justPressed.DOWN || downPcontroller)
				{
					changeSelection(1);
					mouseActive = false;
					if (mouseTimer.active)
						mouseTimer.cancel();
					mouseTimer = new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						mouseActive = true;
					});
				}
			}
			#if cpp
			#if debug
			if ((controls.LEFT_P || leftPcontroller))
			{
				oldOffset = PlayState.songOffset;
				PlayState.songOffset -= 1;
				sys.FileSystem.rename(songPath + oldOffset + '.offset', songPath + PlayState.songOffset + '.offset');
				perSongOffset.text = "Additive Offset (Left, Right): " + PlayState.songOffset + " - Description - " + 'Adds value to global offset, per song.';

				// Prevent loop from happening every single time the offset changes
				if(!offsetChanged)
				{
					grpMenuShit.clear();

					menuItems = ['Restart Song', 'Toggle Practice Mode', 'Exit to menu'];

					for (i in 0...menuItems.length)
					{
						var item = new Alphabet(90, 360, menuItems[i], true, true, 1.25, 50);
						item.distancePerItem.set(30, 200);
						item.y *= i;
						item.targetY = i;
						item.ID = i;
						grpMenuShit.add(item);
					}

					changeSelection();

					cameras = [PlayState.instance.camEXT];
					offsetChanged = true;
				}
			} 
			else if ((controls.RIGHT_P || rightPcontroller))
			{
				oldOffset = PlayState.songOffset;
				PlayState.songOffset += 1;
				sys.FileSystem.rename(songPath + oldOffset + '.offset', songPath + PlayState.songOffset + '.offset');
				perSongOffset.text = "Additive Offset (Left, Right): " + PlayState.songOffset + " - Description - " + 'Adds value to global offset, per song.';
				if(!offsetChanged)
				{
					grpMenuShit.clear();

					menuItems = ['Restart Song', 'Toggle Practice Mode', 'Exit to menu'];

					for (i in 0...menuItems.length)
					{
						var item = new Alphabet(90, 360, menuItems[i], true, true, 1.25, 50);
						item.distancePerItem.set(30, 200);
						item.y *= i;
						item.targetY = i;
						item.ID = i;
						grpMenuShit.add(item);
					}

					changeSelection();

					cameras = [PlayState.instance.camEXT];
					offsetChanged = true;
				}
			}
			#end
			#end
			

			if (controls.ACCEPT || FlxG.mouse.justPressed)
			{
				var daSelected:String = menuItems[curSelected];

				switch (daSelected)
				{
					case "Resume":
						//FlxG.game.soundTray.silent = true;
						randomMusicTime = true;
						resyncToLastPos = true;
						if (doFancyCountdownShit && PlayState.songStarted) //(FlxG.save.data.pauseCountdown)
						{
							//Blur Tween cuz cool electric boogaloo
							if (blurTweenGoBrr != null)
								blurTweenGoBrr.cancel();

							blurTweenGoBrr = FlxTween.tween(this, {funnyBlur: 0}, Conductor.crochet * 4 / 1000, {ease: FlxEase.smootherStepInOut,
								onUpdate: function(twn:FlxTween) 
								{
									PlayState.instance.pauseBlurLol.blurX = funnyBlur;
									PlayState.instance.pauseBlurLol.blurY = funnyBlur;
								},
								
								onComplete: function(twn:FlxTween) 
								{
									PlayState.instance.camGame.filtersEnabled = false;
									blurTweenGoBrr = null;
								}
							});

							doCountdownShit();
						}
						else
							close();
					case "Restart Song":
						PlayState.instance.subtitleText.visible = false;
						PlayState.instance.subtitleBackground.visible = false;
						
						if (blurTweenGoBrr != null)
							blurTweenGoBrr.cancel();
						PlayState.instance.camGame.filtersEnabled = false;

						//FlxG.game.soundTray.silent = true;
						randomMusicTime = true;
						PlayState.hasReset = true;
						PlayState.startTime = 0;
						PlayState.instance.nextStateIsPlayState = true;

						//Testing if this doesn't increase RAM
						PlayState.instance.clear();
						FlxG.resetState();
						Paths.clearUnusedMemory();
						FlxTransitionableState.skipNextTransOut = true;
						if (!PlayState.songsCheatedOn.contains(true))
							PlayState.toggledPracticeMode = false;
					case "Toggle Practice Mode":
						PlayState.cannotDie = !PlayState.cannotDie;
						if (!PlayState.cannotDie)
						{
							for (item in grpMenuShit.members)
								if (item.text == "Toggle Practice Mode")
									item.color = 0xFFFFFFFF;
							FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.7);
							practiceModeText.text = "Practice Mode: Off";
							PlayState.instance.safeVignette.visible = false;
							if (!PlayState.toggledPracticeMode)
							{
								runValidityText.text = "Is A Valid Run: Yes";
								FlxTween.tween(runValidityText, {color: FlxColor.WHITE, x: FlxG.width - (runValidityText.width + 20)}, 0.1, {type: ONESHOT, ease: FlxEase.quartInOut});
							}
						}
						else
						{
							for (item in grpMenuShit.members)
								if (item.text == "Toggle Practice Mode")
									item.color = 0xFFBEFFC5;
							FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.7);
							practiceModeText.text = "Practice Mode: On";
							PlayState.instance.safeVignette.visible = true;
							if (!PlayState.toggledPracticeMode)
							{
								runValidityText.text = "Is A Valid Run: No";
								runValidityText.color = FlxColor.RED;
								FlxTween.tween(runValidityText, {color: FlxColor.RED, x: FlxG.width - (runValidityText.width + 20)}, 0.1, {type: ONESHOT, ease: FlxEase.quartInOut});
							}
						}
						FlxTween.tween(practiceModeText, {x: FlxG.width - (practiceModeText.width + 20)}, 0.1, {type: ONESHOT, ease: FlxEase.quartInOut});
					case "Skip Song":
						//FlxG.game.soundTray.silent = true;
						PlayState.instance.subtitleText.visible = false;
						PlayState.instance.subtitleBackground.visible = false;
						randomMusicTime = true;
						if (PlayState.storyPlaylist.length > 1 && FlxG.save.data.weekUnlocked >= PlayState.storyWeek + 1)
						{
							FlxG.sound.play(Paths.sound('returnMenu'));
							PlayState.startTime = 0;
							/*if (PlayState.instance.useVideo)
							{
								GlobalVideo.get().stop();
								PlayState.instance.remove(PlayState.instance.videoSprite);
								PlayState.instance.removedVideo = true;
							}*/
							FlxTransitionableState.skipNextTransOut = true;
							skippedSong = true;
							trace("Skipped song");
							PlayState.instance.camGame.alpha = 0;
							PlayState.instance.camHUD.alpha = 0;
							FlxG.sound.music.volume = 0;
							FlxG.sound.music.pause();
							PlayState.instance.vocals.volume = 0;
							PlayState.instance.miscs.volume = 0;
							PlayState.instance.musicGroup.volume = 0;
							PlayState.instance.vocals.stop();
							PlayState.instance.miscs.stop();
							PlayState.instance.musicGroup.stop();
							close();
						}
						else
						{
							FlxG.sound.play(Paths.sound('scrollMenuFail'), 0.7);
							trace("Cannot Skip");
							skippedSong = false;
						}
					case "Exit to menu":
						PlayState.instance.subtitleText.visible = false;
						PlayState.instance.subtitleBackground.visible = false;
						randomMusicTime = false;

						if (PlayState.isStoryMode)
							FlxG.switchState(new StoryMenuState());
						else
							FlxG.switchState(new FreeplayState());
				}
			}
		}

		/*if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}*/
	}

	var didCountdownShit:Bool = false;
	
	function doCountdownShit():Void
	{
		FlxG.sound.play(Paths.sound('returnMenu'));
		
		var unpauseCounter:Int = 0;
		didCountdownShit = true;

		FlxTween.tween(bg, {alpha: 0}, Conductor.crochet * 4 / 1000, {type: ONESHOT, ease: FlxEase.expoIn});
		#if cpp
		#if debug
		FlxTween.tween(perSongOffset, {y: FlxG.height + 21}, 0.9, {type: ONESHOT, ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder, {y: FlxG.height + 20}, 0.8, {type: ONESHOT, ease: FlxEase.elasticInOut});
		#end
		#end
		for (item in grpMenuShit.members)
		{
			item.isMenuItem = false;
			FlxTween.tween(item, {alpha: 0, y: item.y + 500}, Conductor.crochet * 4 / 1000, {type: ONESHOT, ease: FlxEase.expoIn});
		}
		pauseMusic.fadeOut(Conductor.crochet / 1000);

		new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			unpauseCounter += 1;
			switch (unpauseCounter)
			{
				case 1:
					FlxTween.tween(runValidityText, {alpha: 0, y: runValidityText.y - 5}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.quartInOut});

					var three:FlxSprite = new FlxSprite(0, 300).loadGraphic(Paths.image("countdown/3"));
					if(FlxG.save.data.antialiasing)
						three.antialiasing = true;		

					three.screenCenter();
					add(three);
					FlxTween.tween(three, {y: three.y + 5, alpha: 0}, Conductor.crochet / 1000, {type: ONESHOT, 
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							three.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('GitarooHover'), 0.6);
				case 2:
					FlxTween.tween(practiceModeText, {alpha: 0, y: practiceModeText.y - 5}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.quartInOut});

					var two:FlxSprite = new FlxSprite(0, 300).loadGraphic(Paths.image("countdown/2"));
					if(FlxG.save.data.antialiasing)
						two.antialiasing = true;		

					two.screenCenter();
					add(two);
					FlxTween.tween(two, {y: two.y + 5, alpha: 0}, Conductor.crochet / 1000, {type: ONESHOT, 
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							two.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('GitarooHover'), 0.6);
				case 3:
					FlxTween.tween(failCount, {alpha: 0, y: failCount.y - 5}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.quartInOut});

					var one:FlxSprite = new FlxSprite(0, 300).loadGraphic(Paths.image("countdown/1"));
					if(FlxG.save.data.antialiasing)
						one.antialiasing = true;	
					one.screenCenter();
					add(one);
					FlxTween.tween(one, {y: one.y + 5, alpha: 0}, Conductor.crochet / 1000, {type: ONESHOT, 
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							one.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('GitarooHover'), 0.6);
				case 4:
					FlxTween.tween(levelInfo, {alpha: 0, y: 0}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.quartInOut});
					FlxTween.tween(levelDifficulty, {alpha: 0, y: levelDifficulty.y - 5}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.quartInOut});

					var go:FlxSprite = new FlxSprite(0, 150).loadGraphic(Paths.image("countdown/go_pause"));
					if(FlxG.save.data.antialiasing)
						go.antialiasing = true;
					go.screenCenter();
					add(go);
					FlxTween.tween(go.scale, {x: 1.05, y: 1.05}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.sineOut});
					FlxTween.tween(go, {alpha: 0}, Conductor.crochet / 1000, {type: ONESHOT, 
						ease: FlxEase.quartInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('GitarooPress'), 0.75);
				case 5:
					close();
			}
		}, 5);
	}

	override function destroy()
	{
		FlxG.mouse.visible = false;
		if (pauseSound.playing)
			pauseSound.stop();
		if (!doFancyCountdownShit && !skippedSong)
			FlxG.sound.play(Paths.sound('returnMenu'));
		if (PlayState.cannotDie)
			PlayState.toggledPracticeMode = true;
		pauseMusic.destroy();

		if (blurTweenGoBrr != null)
			blurTweenGoBrr.cancel();
		PlayState.instance.pauseBlurLol.blurX = 0;
		PlayState.instance.pauseBlurLol.blurY = 0;
		PlayState.instance.camGame.filtersEnabled = false;
		PlayState.instance.camHUD.filtersEnabled = false;

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;
		
		if (change != 0)
			FlxG.sound.play(Paths.sound('scrollMenu'), 0.7);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.3;

			if (item.text == "Skip Song" && (PlayState.storyPlaylist.length <= 1 || FlxG.save.data.weekUnlocked < PlayState.storyWeek + 1))
				item.color = 0xFFC77070;

			if (item.text == "Toggle Practice Mode" && PlayState.cannotDie)
				item.color = 0xFFBEFFC5;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
				item.alpha = 1;
		}
	}
}
