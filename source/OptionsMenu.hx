package;

import flixel.input.gamepad.FlxGamepad;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import openfl.Lib;
import Options;
import Controls.Control;
import flash.text.TextField;
//import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.utils.Assets;
import flixel.addons.transition.FlxTransitionableState;

using StringTools;

class OptionsMenu extends MusicBeatMenu
{
	public static var instance:OptionsMenu;

	public static var discordClientStarted:Bool = true;

	var selector:FlxText;
	var curSelected:Int = 0;
	var catSelected:Int = 0;
	var bgColorTween:FlxTween;

	var options:Array<OptionCategory> = [
		new OptionCategory("Gameplay and Input", [
			new DFJKOption(controls, "Change the controls of the game."),
			new GhostTapOption("If on, pressing an input with no note doesn't give you a penalty."),
			new Judgement("Change the amount of frames it takes before the note counts as a 'MISS'.\n([←] / [→] to change   |   [SHIFT] + [←] / [→] to speed up)"),
			//new ShitBreaksCombo("If on, getting a 'SLIP' rating causes a miss and counts as a combo break."),
			new ScrollSpeedOption("Change the chart's scroll speed multiplier.\n(0.5 is 50% speed, 2 is 200% speed, etc.)\n([←] / [→] to change   |   [SHIFT] + [←] / [→] to speed up)"),
			new AccuracyDOption("Change how accuracy is calculated.\n(Simple: Rating-Based, Complex: Milisecond-Based)"),
			new DownscrollOption("If on, notes will scroll DOWN rather than UP."),
			new ShowStrumLine("Toggle the background for your strumline in-game."),
			new PauseOnLostFocus("If on, auto-pauses the game when you switch to a different window."),
			new ResetButtonOption("If on, pressing [R] twice will trigger a gameover."),
			new CustomizeGameplay("Customize how the gameplay elements are arranged.")
		]),

		new OptionCategory("Accessibility", [
			new FlashingLightsOption("Toggle flashing lights that can cause epileptic seizures and strain."),
			new DistractionsAndEffectsOption("Toggle in-game events and/or animations that may be too distracting."),
			new Optimization("Simplifies gameplay by removing everything except your strumline and a stage-themed background image."),
			new CamZoomOption("Toggle the camera zooming on the beat of the song."),
			new SubtitlesOption("Toggle in-game and in-cutscene subtitles."),
			new SubtitlesCenteredOption("Compact - subtitles scale to fit in 1 line and stay above the healthbar.\nStatic - subtitles don't scale nor avoid overlapping with the healthbar."),
			new NightModeOption("Darkens UI and gameplay to prevent eye strain during night."),
			new AutoNightModeOption("If on, dark-mode triggers automatically based the time of day."),
			new PauseOnLostFocus("Pause the game when you switch to a different window."),
			new ShowStrumLine("Toggle the background for your strumline in-game."),
			//add noDeathOption for disabled players
		]),

		new OptionCategory("Graphics and Video", [
			new AntialiasingOption("Smoothens image edges to make them look better at the cost of a little performance."),
			new HighQualityNoteSplash("Toggle antialiasing of the in-game VFX. \n(OFF if you favour performance, ON if you want some quality.)"),
			new FullscreenOption("Toggle fullscreen mode. May cause issues..?"),
			new NightModeOption("Darkens UI and gameplay to prevent eye strain during night."),
			new AutoNightModeOption("If on, dark-mode triggers automatically based the time of day."),
			new NoteSplashingEffectsOption("Toggle the splashes when you hit a 'SICK!!' or miss a note."),
			new CpuStrums("If on, the opponent's strumline will light up whenever the opponent hits a note."),
			new CamZoomOption("Toggle the camera zooming on-beat with the song."),
			#if desktop
			new FPSCapOption("Change your FPS Cap.")
			#end
		]),

		new OptionCategory("Sounds and Music", [
			new MusVolOption("Change the volume of the in-game music.\n([←] / [→] to change   |   [SHIFT] + [←] / [→] to speed up)"),
			new VocVolOption("Change the volume of the in-game vocals.\n([←] / [→] to change   |   [SHIFT] + [←] / [→] to speed up)"),
			new SFXVolOption("Change the volume of the in-game sound effects (misses, styles, etc.).\n([←] / [→] to change   |   [SHIFT] + [←] / [→] to speed up)"),
			new MissSoundsOption("If on, sounds will play whenever you MISS a note."),
			new NoteHitSFXOption("If on, sounds will play whenever you HIT a note."),
			new HitSFXTypeOption("Change how you want your note hit sounds to sound like.\n([←] / [→] to choose   |   [SHIFT] + [←] / [→] to speed up)"),
			new HitSFXVolOption("Change the volume of note hit sounds.\n([←] / [→] to change   |   [SHIFT] + [←] / [→] to speed up)"), //Remove this and replace with SFX Volume
			new SubtitlesOption("Toggle in-game and in-cutscene subtitles."),
			new SubtitlesCenteredOption("Compact - subtitles scale to fit in 1 line and stay above the healthbar.\nStatic - subtitles don't scale nor avoid overlapping with the healthbar."),
			new SongPositionOption("If on, will show the song's current progress as a scrolling bar.")
		]),

		new OptionCategory("Saves and Data", [
			new WatermarkOption("Toggle if you want to hide the faces of people (such as Guy or Priest.)\nThis DOES NOT work yet though! LMAO!"),
			#if desktop
			new ShowPresenceOption("Toggle the 'NOW PLAYING' stuff on discord. (Selected changes will apply when you press [ESC].)"),
			//new ReplayOption("View saved song replays."),
			#end
			new ResetScoreOption("Reset your scores on all songs and weeks.\n(This is irreversible!)"),
			new LockWeeksOption("Reset your story mode progress.\n(This is irreversible!)"),
			new ResetSettings("Reset ALL your settings.\n(This is irreversible!)")
		]),
		
		new OptionCategory("Miscellaneous", [
			new LagCompensation("If on, will attempt to prevent you from taking damage or missing when your game freezes or lags."),
			new ScoreScreen("If on, will show a score screen after the end of a freeplay song."),
			new AccuracyOption("If on, will show your current Accuracy on the info bar."),
			new NPSDisplayOption("If on, will show your current Notes Per Second on the info bar."),
			new ShowInput("Whether to display every single input on the score screen."),
			new BotPlay("While on, any song will have it's chart automatically played.\n(Scores and progress won't be saved while this is enabled.)"),
			new FPSOption("Toggle the FPS Counter."),
			new RainbowFPSOption("If on, will make the FPS Counter flicker through rainbow colors.")
		])
		
	];

	public var acceptInput:Bool = true;

	private var currentDescription:String = "";
	private var grpControls:FlxTypedGroup<Alphabet>;
	var offsetNumberShit:FlxText;
	var descriptionShit:FlxText;
	var blackBorder1:FlxSprite;
	var tweenedOffsetBorder:Bool = false;
	var blackBorder2:FlxSprite;
	var descTextTween:FlxTween;
	var descBGTween:FlxTween;

	var currentSelectedCat:OptionCategory;

	var movedBack:Bool = false;

	var titleText:Alphabet;
	var menuBG:FlxSprite;

	var musicVolumeTween:FlxTween;

	override function create()
	{
		instance = this;
		menuBG = new FlxSprite().loadGraphic(Paths.image("menuDesat"));

		if (!FlxG.mouse.visible)
			FlxG.mouse.visible = true;

		menuBG.color = 0xFF0D5080;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		if (!Main.nightMode && !FlxG.save.data.nightmode)
			menuBG.alpha = 1;
		else
			menuBG.alpha = 0.5;
		if(FlxG.save.data.antialiasing)
			{
				menuBG.antialiasing = true;
			}
		add(menuBG);

		grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...options.length)
		{
			var controlLabel = new Alphabet(90, 320, options[i].getName(), true, true);
			controlLabel.y += 70 * i;
			controlLabel.distancePerItem.set(20, 170);
			controlLabel.targetY = i;
			controlLabel.ID = i;
			grpControls.add(controlLabel);
		}

		titleText = new Alphabet(10, 40, '', true);
		titleText.scaleX = 0.75;
		titleText.scaleY = 0.75;
		titleText.color = 0xff7095bd;
		titleText.alpha = 0.8;
		add(titleText);

		currentDescription = "--";

		//FIX THIS SO THAT IT IS ON TOP INSTEAD OF THE BOTTOM OF THE SCREEN
		offsetNumberShit = new FlxText(5, -40, FlxG.width - 5, "Offset ([←] / [→], [SHIFT] to slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + '${FlxMath.getDecimals(HelperFunctions.truncateFloat(FlxG.save.data.offset, 2)) != 0 ? '' : '.0'} ms');
		offsetNumberShit.scrollFactor.set();
		offsetNumberShit.setFormat("VCR OSD Mono", 25, FlxColor.WHITE, LEFT);
		offsetNumberShit.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 1);
		offsetNumberShit.updateHitbox();

		blackBorder1 = new FlxSprite(-30, -40).makeGraphic((Std.int(FlxG.width + 100)), Std.int(offsetNumberShit.height + 5), FlxColor.BLACK);
		blackBorder1.alpha = 0.7;
		blackBorder1.updateHitbox();
		descriptionShit = new FlxText(5, FlxG.height, FlxG.width - 40, currentDescription, 12);
		descriptionShit.scrollFactor.set();
		descriptionShit.setFormat("VCR OSD Mono", 25, FlxColor.WHITE, CENTER);
		descriptionShit.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 1);
		descriptionShit.updateHitbox();
		descriptionShit.screenCenter(X);

		blackBorder2 = new FlxSprite(-30, FlxG.height).makeGraphic((Std.int(FlxG.width - 30)), Std.int(descriptionShit.height * 5),FlxColor.BLACK);
		blackBorder2.alpha = 0.7;
		blackBorder2.screenCenter(X);


		add(blackBorder1);
		add(offsetNumberShit);
		add(blackBorder2);
		add(descriptionShit);

		FlxTween.tween(offsetNumberShit,{y: 5}, 1.1 ,{ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder1,{y: 0}, 1 , {ease: FlxEase.elasticInOut, onComplete:
			function (twn:FlxTween)
			{
				tweenedOffsetBorder = true;
			}
		});
		descTextTween = FlxTween.tween(descriptionShit,{y: FlxG.height - descriptionShit.height - 5}, 1.1 ,{ease: FlxEase.elasticInOut, onComplete:
			function (twn:FlxTween)
			{
				descTextTween = null;
			}
		});
		descBGTween = FlxTween.tween(blackBorder2,{y: blackBorder2.y - descriptionShit.height - 10}, 1 , {ease: FlxEase.elasticInOut, onComplete:
			function (twn:FlxTween)
			{
				descBGTween = null;
			}
		});

		changeSelection();

		super.create();

		if (musicVolumeTween != null)
			musicVolumeTween.cancel();

		if (!FreeplayState.freeplayMusicPlaying)
		{
			musicVolumeTween = FlxTween.tween(FlxG.sound.music, {volume: 0.6}, 0.3, {type: ONESHOT, 
				onComplete: function(been:FlxTween)
				{
					musicVolumeTween = null;
				}
			});
		}
		else
		{
			musicVolumeTween = FlxTween.tween(FlxG.sound.music, {volume: 0.7}, 0.3, {type: ONESHOT, 
				onComplete: function(been:FlxTween)
				{
					musicVolumeTween = null;
				}
			});
		}

		if (DisclaimerState.wentOptions)
			(cast (Lib.current.getChildAt(0), Main)).toggleFPS(FlxG.save.data.fps);

		mouseTimer = new FlxTimer().start(0.5, function(swagTimer:FlxTimer)
		{
			mouseActive = true;
		});
	}

	var isCat:Bool = false;
	
	var transitionTimer:FlxTimer;
	var gamepad:FlxGamepad;
	var antiSpam:Int = 6;
	var mouseActive:Bool = false;
	var mouseTimer:FlxTimer;

	//Add mouse compatabiitylyiy
	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (acceptInput)
		{
			if ((controls.BACK || FlxG.mouse.justPressedRight) && !movedBack)
			{
				if (!isCat && DisclaimerState.wentOptions)
				{
					mouseActive = false;
					FlxG.save.flush();
					movedBack = true;
					switch (FlxG.save.data.weekUnlocked)
					{
						case 2:
							FlxG.sound.play(Paths.sound('cancelMenu'));
						case 3:
							FlxG.sound.play(Paths.sound('cancelMenu'));
						case 6:
							FlxG.sound.play(Paths.sound('cancelMenu' + curKey));
						default:
							if (!FreeplayState.freeplayMusicPlaying)
								FlxG.sound.play(Paths.sound('cancelMenu' + curKey));
							else
								FlxG.sound.play(Paths.sound('cancelMenu'));
					}
					DisclaimerState.wentOptions = false;
					Main.updateTimeStuffs();
					FlxG.switchState(new TitleState());
				}
				else if (!isCat && !DisclaimerState.wentOptions)
				{
					mouseActive = false;
					movedBack = true;
					switch (FlxG.save.data.weekUnlocked)
					{
						case 2:
							FlxG.sound.play(Paths.sound('cancelMenu'));
						case 3:
							FlxG.sound.play(Paths.sound('cancelMenu'));
						case 6:
							FlxG.sound.play(Paths.sound('cancelMenu' + curKey));
						default:
							if (!FreeplayState.freeplayMusicPlaying)
								FlxG.sound.play(Paths.sound('cancelMenu' + curKey));
							else
								FlxG.sound.play(Paths.sound('cancelMenu'));
					}
					transitionTimer = new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						transitionTimer.destroy();
						//FlxTransitionableState.defaultTransIn.setStatus(NULL);
						Main.updateTimeStuffs();
						FlxG.switchState(new MainMenuState());
					});
				}
				else
				{
					#if windows
					if (!FlxG.save.data.showPresence && discordClientStarted)
					{
						DiscordClient.shutdown();
						discordClientStarted = false;
					}
					else if (FlxG.save.data.showPresence && !discordClientStarted)
					{
						DiscordClient.initialize();
						discordClientStarted = true;
					}
					#end

					FlxG.sound.play(Paths.sound('returnMenu'));
					
					//resets the 'reset story/scores/settings' options to default
					//Might seem excessive but its actually really imperative that we get this working.
					if (currentSelectedCat.getName() == 'Saves and Data')
					{
						for (leOptionne in currentSelectedCat.getOptions())
						{
							//Idk man there's no getName() and im too lazy to make one myself,,, (- ^ -)
							if (leOptionne.getDisplay().contains('Reset'))
							{
								leOptionne.resetConfirmBool();
								trace ('reset state of ' + leOptionne.getDisplay());
							}
						}
					}

					isCat = false;

					if (musicVolumeTween != null)
						musicVolumeTween.cancel();
					
					if (!FreeplayState.freeplayMusicPlaying)
					{
						musicVolumeTween = FlxTween.tween(FlxG.sound.music, {volume: 0.6}, 0.3, {type: ONESHOT, 
							onComplete: function(been:FlxTween)
							{
								musicVolumeTween = null;
							}
						});
					}
					else
					{
						musicVolumeTween = FlxTween.tween(FlxG.sound.music, {volume: 0.7}, 0.3, {type: ONESHOT, 
							onComplete: function(been:FlxTween)
							{
								musicVolumeTween = null;
							}
						});
					}

					titleText.set_text('');
					
					if (bgColorTween != null)
						bgColorTween.cancel();
					bgColorTween = FlxTween.color(menuBG, 0.5, 0xFF0B3F65, 0xFF0D5080, {onComplete:
						function (twn:FlxTween)
						{
							bgColorTween = null;
						}
					});

					grpControls.clear();
					for (i in 0...options.length)
					{
						var controlLabel = new Alphabet(90, 320, options[i].getName(), true, true);
						controlLabel.distancePerItem.set(20, 170);
						controlLabel.targetY = i;
						controlLabel.ID = i;
						grpControls.add(controlLabel);
					}
				
					changeSelection(catSelected - curSelected);

					mouseTimer = new FlxTimer().start(0.75, function(tmr:FlxTimer)
					{
						mouseActive = true;
					});
				}
			}
			else if ((controls.BACK || FlxG.mouse.justPressedRight) && movedBack && !isCat && !DisclaimerState.wentOptions)
			{
				transitionTimer.cancel();
				Main.updateTimeStuffs();
				FlxG.switchState(new MainMenuState());
			}

			gamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
					changeSelection(-1);
				if (gamepad.justPressed.DPAD_DOWN)
					changeSelection(1);
			}
			else
			{
				if (mouseActive && FlxG.mouse.justMoved && Main.isFocused)
				{
					for (option in grpControls.members)
					{
						if (FlxG.mouse.overlaps(option) && curSelected != option.ID)
						{
							var change:Int = option.ID - curSelected;
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
					if (FlxG.keys.justPressed.UP)
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
					if (FlxG.keys.justPressed.DOWN)
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
			}
			
			if (isCat)
			{
				if (currentSelectedCat.getOptions()[curSelected].checkIfSlider())
				{	
					if (currentSelectedCat.getOptions()[curSelected].canSpeedUp && FlxG.keys.pressed.SHIFT)
					{
						if (FlxG.keys.pressed.RIGHT)
						{			
							if (antiSpam > 3)
							{
								//update the option and alphabet text itself
								currentSelectedCat.getOptions()[curSelected].right();
								grpControls.members[curSelected].set_text(currentSelectedCat.getOptions()[curSelected].getDisplay());
								antiSpam = 0;
								FlxG.sound.play(Paths.sound("optionsSliderUp"), 0.5);
							}
							else
								antiSpam++;
						}
						else if (FlxG.keys.pressed.LEFT)
						{	
							if (antiSpam > 3)
							{
								//update the option and alphabet text itself
								currentSelectedCat.getOptions()[curSelected].left();
								grpControls.members[curSelected].set_text(currentSelectedCat.getOptions()[curSelected].getDisplay());
								antiSpam = 0;
								FlxG.sound.play(Paths.sound("optionsSliderDown"), 0.5);
							}
							else
								antiSpam++;
						}
					}
					else if (FlxG.keys.justPressed.RIGHT)
					{
						currentSelectedCat.getOptions()[curSelected].right();
						//update the alphabet text itself
						grpControls.members[curSelected].set_text(currentSelectedCat.getOptions()[curSelected].getDisplay());
						FlxG.sound.play(Paths.sound("optionsSliderUp"), 0.55);
					}
					else if (FlxG.keys.justPressed.LEFT)
					{
						currentSelectedCat.getOptions()[curSelected].left();
						//update the alphabet text itself
						grpControls.members[curSelected].set_text(currentSelectedCat.getOptions()[curSelected].getDisplay());
						FlxG.sound.play(Paths.sound("optionsSliderDown"), 0.55);
					}

					offsetNumberShit.text = currentSelectedCat.getOptions()[curSelected].getValue();
					descriptionShit.text = currentDescription;
				}
				else
				{
					if (FlxG.keys.pressed.SHIFT)
					{
						if (FlxG.keys.justPressed.RIGHT)
						{
							FlxG.save.data.offset += 0.1;
							FlxG.sound.play(Paths.sound("optionsSliderUp"), 0.55);
						}
						else if (FlxG.keys.justPressed.LEFT)
						{
							FlxG.save.data.offset -= 0.1;
							FlxG.sound.play(Paths.sound("optionsSliderDown"), 0.55);
						}
					}
					else if (FlxG.keys.pressed.RIGHT)
					{
						if (antiSpam > 3)
						{
							FlxG.save.data.offset += 0.1;
							antiSpam = 0;
							FlxG.sound.play(Paths.sound("optionsSliderUp"), 0.5);
						}
						else
							antiSpam++;
					}
					else if (FlxG.keys.pressed.LEFT)
					{	
						if (antiSpam > 3)
						{
							FlxG.save.data.offset -= 0.1;
							antiSpam = 0;
							FlxG.sound.play(Paths.sound("optionsSliderDown"), 0.5);
						}
						else
							antiSpam++;
					}
					
					offsetNumberShit.text = "Offset ([←] / [→], [SHIFT] to slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + '${FlxMath.getDecimals(HelperFunctions.truncateFloat(FlxG.save.data.offset, 2)) != 0 ? '' : '.0'} ms';
					descriptionShit.text = currentDescription;
				}
			}
			else
			{
				if (FlxG.keys.pressed.SHIFT)
				{
					if (FlxG.keys.justPressed.RIGHT)
					{
						FlxG.save.data.offset += 0.1;
						FlxG.sound.play(Paths.sound("optionsSliderUp"), 0.55);
					}
					else if (FlxG.keys.justPressed.LEFT)
					{
						FlxG.save.data.offset -= 0.1;
						FlxG.sound.play(Paths.sound("optionsSliderDown"), 0.55);
					}
				}
				else if (FlxG.keys.pressed.RIGHT)
				{					
					if (antiSpam > 3)
					{
						FlxG.save.data.offset += 0.1;
						antiSpam = 0;
						FlxG.sound.play(Paths.sound("optionsSliderUp"), 0.5);
					}
					else
						antiSpam++;
				}
				else if (FlxG.keys.pressed.LEFT)
				{		
					if (antiSpam > 3)
					{
						FlxG.save.data.offset -= 0.1;
						antiSpam = 0;
						FlxG.sound.play(Paths.sound("optionsSliderDown"), 0.5);
					}
					else
						antiSpam++;
				}
				
				offsetNumberShit.text = "Offset ([←] / [→], [SHIFT] to slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + '${FlxMath.getDecimals(HelperFunctions.truncateFloat(FlxG.save.data.offset, 2)) != 0 ? '' : '.0'} ms';
			}
		

			if (controls.RESET)
				FlxG.save.data.offset = 0;

			if (controls.ACCEPT || FlxG.mouse.justPressed)
			{
				if (isCat)
				{
					if (currentSelectedCat.getOptions()[curSelected].press())
					{
						FlxG.save.flush();
						grpControls.members[curSelected].set_text(currentSelectedCat.getOptions()[curSelected].getDisplay());
						//Cool Flashing Red Effect
						if (currentSelectedCat.getName() == 'Saves and Data' && currentSelectedCat.getOptions()[curSelected].getDisplay().contains('Reset'))
						{
							//Placeholder - flash this and do sum cool shit with it!
							grpControls.members[curSelected].color = 0xFFC77070;
						}
					}
				}
				else
				{
					currentSelectedCat = options[curSelected];
					catSelected = curSelected;
					isCat = true;

					if (musicVolumeTween != null)
						musicVolumeTween.cancel();
			
					if (!FreeplayState.freeplayMusicPlaying)
					{
						musicVolumeTween = FlxTween.tween(FlxG.sound.music, {volume: 0.4}, 0.3, {type: ONESHOT, 
							onComplete: function(been:FlxTween)
							{
								musicVolumeTween = null;
							}
						});
					}
					else
					{
						musicVolumeTween = FlxTween.tween(FlxG.sound.music, {volume: 0.5}, 0.3, {type: ONESHOT, 
							onComplete: function(been:FlxTween)
							{
								musicVolumeTween = null;
							}
						});
					}

					titleText.set_text(currentSelectedCat.getName());

					if (bgColorTween != null)
						bgColorTween.cancel();
					bgColorTween = FlxTween.color(menuBG, 0.5, 0xFF0D5080, 0xFF0B3F65, {ease: FlxEase.quadOut, onComplete:
						function (twn:FlxTween)
						{
							bgColorTween = null;
						}
					});

					grpControls.clear();
					for (i in 0...currentSelectedCat.getOptions().length)
					{
						var controlLabel = new Alphabet(90, 320, currentSelectedCat.getOptions()[i].getDisplay(), false, true);
						controlLabel.distancePerItem.set(5, 100);
						controlLabel.y += 70 * i;
						controlLabel.targetY = i;
						controlLabel.ID = i;
						if (currentSelectedCat.getOptions()[i].getDisplay().contains('Reset'))
						{
							if (DisclaimerState.wentOptions)
								controlLabel.color = 0xFFC77070;
						}
						grpControls.add(controlLabel);
					}
					curSelected = 0;
					FlxG.sound.play(Paths.sound("scrollMenu"));
				}
				
				changeSelection();
			}
		}
	}

	var isSettingControl:Bool = false;

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent("Fresh");
		#end

		if (isCat)
		{
			//trace('pls work;;;');
			if (currentSelectedCat.getName() == 'Saves and Data' && currentSelectedCat.getOptions()[curSelected].getDisplay().contains('|['))
			{
				//trace('omg???');
				currentSelectedCat.getOptions()[curSelected].resetConfirmBool();
				grpControls.members[curSelected].color = 0xFFFFFFFF;
			}
		}
		/*if (currentSelectedCat.getOptions()[curSelected].getDisplay().contains('Reset'))
		{
			grpControls.members[curSelected].set_text(currentSelectedCat.getOptions()[curSelected].getDisplay());
			grpControls.members[curSelected].color = 0xFFFFFFFF;
		}*/

		if (change != 0)
			FlxG.sound.play(Paths.sound("scrollMenu"));

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;
			
		if (isCat)
		{
			currentDescription = currentSelectedCat.getOptions()[curSelected].getDescription();
			if (currentSelectedCat.getOptions()[curSelected].checkIfSlider())
			{
				offsetNumberShit.text = currentSelectedCat.getOptions()[curSelected].getValue();
				descriptionShit.text = currentDescription;
			}
			else
			{
				offsetNumberShit.text = "Offset ([←] / [→], [SHIFT] to slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + '${FlxMath.getDecimals(HelperFunctions.truncateFloat(FlxG.save.data.offset, 2)) != 0 ? '' : '.0'} ms';
				descriptionShit.text = currentDescription;
			}
			descriptionShit.updateHitbox();
			descriptionShit.screenCenter(X);
			blackBorder2.scale.x = 1;
			blackBorder2.screenCenter(X);
		}
		else
		{
			currentDescription = "[Select a category]";
			descriptionShit.text = currentDescription;
			descriptionShit.updateHitbox();	
			descriptionShit.screenCenter(X);
			blackBorder2.scale.x = 0.5;
			blackBorder2.screenCenter(X);
		}

			offsetNumberShit.updateHitbox();
			blackBorder1.scale.y = (offsetNumberShit.height + 10) / 31;
			blackBorder1.updateHitbox();
			if (tweenedOffsetBorder)
				blackBorder1.y = 0;

		if (descTextTween != null)
			descTextTween.cancel();
		if (descBGTween != null)
			descBGTween.cancel();
		descTextTween = FlxTween.tween(descriptionShit,{y: FlxG.height - descriptionShit.height - 5}, 0.3,{ease: FlxEase.quadOut, onComplete:
			function (twn:FlxTween)
			{
				descTextTween = null;
			}
		});
		descBGTween = FlxTween.tween(blackBorder2,{y: FlxG.height - descriptionShit.height - 10}, 0.3, {ease: FlxEase.quadOut, onComplete:
			function (twn:FlxTween)
			{
				descBGTween = null;
			}
		});

		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;
			item.alpha = 0.3;
			//item.x - 30;
			//item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				//item.x + 30;
				//trace("item witdh = " + item.width);
				//item.setGraphicSize(Std.int(item.width * 1));
			}
		}

		/*for (i in 0...grpControls.members.length)
		{
			grpControls.members[i].x = grpControls.members[i].x;
		}*/
	}
}
