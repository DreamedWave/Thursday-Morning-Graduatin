package;

import flixel.input.gamepad.FlxGamepad;
import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.math.FlxMath;
import flash.system.System;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<MenuItem.MainMenuItem>;

	#if !switch
	var optionShit:Array<String> = ['campaign', 'freeplay', 'options', 'extras'];
	#else
	var optionShit:Array<String> = ['campaign', 'freeplay'];
	#end

	var newGaming:FlxText;
	var newGaming2:FlxText;
	static var firstStart:Bool = true;

	public static var nightly:String = "";
	public static var gameVer:String = "0.3.2";

	var bg:FlxSprite;
	var magenta:FlxSprite;
	var camFollow:FlxObject;
	public static var finishedFunnyMove:Bool = false;

	public static var curKey:Int = 1;
	var movedBack:Bool = false;

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Main Menu", null);
		#end

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
			{
				switch (FlxG.save.data.weekUnlocked)
				{
					case 1:
						if (FlxG.sound.music != null)
							if (!FlxG.sound.music.playing)
								FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.65);
						TitleState.weekAdderThingy = "";
					case 2:
						if (FlxG.sound.music != null)
							if (!FlxG.sound.music.playing)
								FlxG.sound.playMusic(Paths.music('glitchyMenu'), 0.65);
						TitleState.weekAdderThingy = "-glitchy";
					case 3:
						if (FlxG.sound.music != null)
							if (!FlxG.sound.music.playing)
								FlxG.sound.playMusic(Paths.music('cityMenu'), 0.65);
						TitleState.weekAdderThingy = "-city";
					default:
						if (FlxG.sound.music != null)
							if (!FlxG.sound.music.playing)
								FlxG.sound.playMusic(Paths.music('peacefulMenu'), 0.65);
				}
			}
		}

		persistentUpdate = true;
		persistentDraw = true;

		bg = new FlxSprite(-100).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.set(0, 0.1);
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		if(FlxG.save.data.antialiasing)
			{
				bg.antialiasing = true;
			}
		if (!Main.nightMode && !FlxG.save.data.nightmode)
			bg.alpha = 1;
		else
			bg.alpha = 0.65;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuBGMagenta'));
//		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.set(0, 0.1);
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		if(FlxG.save.data.antialiasing)
			{
				magenta.antialiasing = true;
			}
		if (!Main.nightMode && !FlxG.save.data.nightmode)
			magenta.alpha = 1;
		else
			magenta.alpha = 0.35;
//		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<MenuItem.MainMenuItem>();
		add(menuItems);

		for (i in 0...optionShit.length)
		{
			var menuItem:MenuItem.MainMenuItem = new MenuItem.MainMenuItem(0, FlxG.height * 1.6, optionShit[i], i);
			menuItems.add(menuItem);

			if (firstStart)
				FlxTween.tween(menuItem,{y: 60 + (i * 160)}, 1 + (i * 0.15) ,{type: ONESHOT, ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
				{ 
					finishedFunnyMove = true; 
					changeItem();
				}});
			else
			{
				finishedFunnyMove = true;
				menuItem.y = 60 + (i * 160);
			}
		}

		firstStart = false;

		FlxG.camera.follow(camFollow, null, 0.06);

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, "TMG " + gameVer + (Main.watermarks ? " | KE 1.6" : ""), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();


		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;
	var allowSpeedrunSkip:Bool = false;
	var transitionTimer:FlxTimer;

	//for jokejumpscare, remove once done
	var dummyBlackScreen:FlxSprite;
	var jumpscareSprite:FlxSprite;
	var startMovingJumpscareSprite:Bool = false;
	var boolIDidntWannaAddButFuckItAnywaysLMAO:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.65 && !boolIDidntWannaAddButFuckItAnywaysLMAO)
			FlxG.sound.music.volume = 0.65;

		if (!selectedSomethin)
		{
			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP && finishedFunnyMove)
				{
					switch (FlxG.save.data.weekUnlocked)
					{
						case 2:
							FlxG.sound.play(Paths.sound('scrollMenu'));
						case 3:
							FlxG.sound.play(Paths.sound('scrollMenu'));
						case 6:
							FlxG.sound.play(Paths.sound('scrollMenu' + MainMenuState.curKey));
						default:
							if (!FreeplayState.freeplayMusicPlaying)
								FlxG.sound.play(Paths.sound('scrollMenu' + MainMenuState.curKey));
							else
								FlxG.sound.play(Paths.sound('scrollMenu'));
					}
					changeItem(-1);
				}
				else if (gamepad.justPressed.DPAD_DOWN && finishedFunnyMove)
				{
					switch (FlxG.save.data.weekUnlocked)
					{
						case 2:
							FlxG.sound.play(Paths.sound('scrollMenu'));
						case 3:
							FlxG.sound.play(Paths.sound('scrollMenu'));
						case 6:
							FlxG.sound.play(Paths.sound('scrollMenu' + MainMenuState.curKey));
						default:
							if (!FreeplayState.freeplayMusicPlaying)
								FlxG.sound.play(Paths.sound('scrollMenu' + MainMenuState.curKey));
							else
								FlxG.sound.play(Paths.sound('scrollMenu'));
					}
					changeItem(1);
				}
			}

			else if (FlxG.keys.justPressed.UP && finishedFunnyMove)
			{
				switch (FlxG.save.data.weekUnlocked)
				{
					case 2:
						FlxG.sound.play(Paths.sound('scrollMenu'));
					case 3:
						FlxG.sound.play(Paths.sound('scrollMenu'));
					case 6:
						FlxG.sound.play(Paths.sound('scrollMenu' + MainMenuState.curKey));
					default:
						if (!FreeplayState.freeplayMusicPlaying)
							FlxG.sound.play(Paths.sound('scrollMenu' + MainMenuState.curKey));
						else
							FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				changeItem(-1);
			}

			else if (FlxG.keys.justPressed.DOWN && finishedFunnyMove)
			{
				switch (FlxG.save.data.weekUnlocked)
				{
					case 2:
						FlxG.sound.play(Paths.sound('scrollMenu'));
					case 3:
						FlxG.sound.play(Paths.sound('scrollMenu'));
					case 6:
						FlxG.sound.play(Paths.sound('scrollMenu' + MainMenuState.curKey));
					default:
						if (!FreeplayState.freeplayMusicPlaying)
							FlxG.sound.play(Paths.sound('scrollMenu' + MainMenuState.curKey));
						else
							FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				changeItem(1);
			}

			else if (controls.BACK)
			{
				if (!movedBack)
				{
					movedBack = true;
					switch (FlxG.save.data.weekUnlocked)
					{
						case 2 | 3:
							FlxG.sound.play(Paths.sound('cancelMenu'));
						case 6:
							FlxG.sound.play(Paths.sound('cancelMenu' + MainMenuState.curKey));
						default:
							if (!FreeplayState.freeplayMusicPlaying)
								FlxG.sound.play(Paths.sound('cancelMenu' + MainMenuState.curKey));
							else
								FlxG.sound.play(Paths.sound('cancelMenu'));
					}
					transitionTimer = new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						transitionTimer.destroy();
						FlxG.switchState(new TitleState());
					});
				}
				else
				{
					transitionTimer.cancel();
					FlxG.switchState(new TitleState());
				}
			}

			else if (controls.ACCEPT && !movedBack)
			{
				/*if (optionShit[curSelected] == 'extras')
				{
					#if !debug
					fancyOpenURL("https://4364.bandcamp.com/");
					#else
					FlxG.switchState(new MinigameState());
					#end
				}*/
				//else
				//{
					selectedSomethin = true;
					switch(optionShit[curSelected])
					{
						case 'freeplay':
							switch (FlxG.save.data.weekUnlocked)
							{
								case 6:
									FlxG.sound.play(Paths.sound('confirmMenu'));
								default:
									if (!FreeplayState.freeplayMusicPlaying)
									{
										FlxG.sound.play(Paths.sound('confirmMenuBlue' + TitleState.weekAdderThingy));
										new FlxTimer().start(0.04, function(tmr:FlxTimer)
										{
											FlxG.sound.music.stop();
										});
									}
									else
									{
										FlxG.sound.play(Paths.sound('confirmMenu' + TitleState.weekAdderThingy));
									}
							}
						case 'extras':
							boolIDidntWannaAddButFuckItAnywaysLMAO = true;
							FlxG.sound.music.volume = 0;
							FlxG.sound.play(Paths.sound('confirmMenuOrange' + TitleState.weekAdderThingy));
							
							//for joke jumpscare lol
							dummyBlackScreen = new FlxSprite(-FlxG.width,
								-FlxG.height).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
							dummyBlackScreen.scrollFactor.set();
							dummyBlackScreen.visible = false;
							add(dummyBlackScreen);
						
							jumpscareSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('jumpscare'));
							jumpscareSprite.angle = -6;
							jumpscareSprite.antialiasing = true;
							jumpscareSprite.setGraphicSize(Std.int(jumpscareSprite.width * 0.1));
							jumpscareSprite.updateHitbox();
							jumpscareSprite.screenCenter();
							jumpscareSprite.visible = false;
							add(jumpscareSprite);
						default:
							FlxG.sound.play(Paths.sound('confirmMenu' + TitleState.weekAdderThingy));
					}
					
					if (FlxG.save.data.flashing)
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);

					menuItems.forEach(function(spr:MenuItem.MainMenuItem)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 0.8, {type: ONESHOT, 
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							allowSpeedrunSkip = true;
							if (FlxG.save.data.flashing)
							{
								FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
								{
									goToState();
								});
							}
							else
							{
								new FlxTimer().start(1, function(tmr:FlxTimer)
								{
									goToState();
								});
							}
						}
					});
				//}
			}
		}
		else if (controls.ACCEPT && optionShit[curSelected] != 'extras' && (optionShit[curSelected] != 'freeplay' || FlxG.save.data.weekUnlocked >= 6) && allowSpeedrunSkip)
		{	
			trace("Speedrun SKIP");
			allowSpeedrunSkip = false;
			goToState();
		}
		else if (optionShit[curSelected] == 'extras')
		{
			//For joke jumpscare, remove pls lol
			if (!startMovingJumpscareSprite)
			{
				if (controls.BACK)
				{
					if (!movedBack)
					{
						if (anotherFuckingVariableAUGH)
						{
							finishTransOut();
							dummyBlackScreen.visible = true;
						}
						movedBack = true;
						boolIDidntWannaAddButFuckItAnywaysLMAO = false;
						switch (FlxG.save.data.weekUnlocked)
						{
							case 2 | 3:
								FlxG.sound.play(Paths.sound('cancelMenu'));
							case 6:
								FlxG.sound.play(Paths.sound('cancelMenu' + MainMenuState.curKey));
							default:
								if (!FreeplayState.freeplayMusicPlaying)
									FlxG.sound.play(Paths.sound('cancelMenu' + MainMenuState.curKey));
								else
									FlxG.sound.play(Paths.sound('cancelMenu'));
						}
						new FlxTimer().start(0.1, function(tmr:FlxTimer)
						{
							FlxG.switchState(new TitleState());
						});
					}
				}
			}
			else
			{
				var mult1:Float = FlxMath.lerp(1, jumpscareSprite.scale.x, 0.9);
				var mult2:Float = FlxMath.lerp(7, jumpscareSprite.angle, PlayStateHelpers.calculateLerpTime(elapsed * 3.5, 1, 0, 1));
				jumpscareSprite.scale.set(mult1, mult1);
				jumpscareSprite.angle = mult2;
				jumpscareSprite.updateHitbox();
				jumpscareSprite.screenCenter();
			}
		}

		super.update(elapsed);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (curKey > 4 || curKey < 1)
			curKey = 1;
	}

	var anotherFuckingVariableAUGH:Bool = false;
	
	function goToState()
	{
		var daChoice:String = optionShit[curSelected];

		switch (daChoice)
		{
			case 'campaign':
				FlxG.switchState(new StoryMenuState());
				trace("Campaign Selected");
			case 'freeplay':
				if (FlxG.save.data.weekUnlocked >= 6)
				{
					FlxG.switchState(new FreeplaySelectionState());
					trace("Freeplay Selection Menu Selected");
				}
				else
				{
					FreeplaySelectionState.isOrange = false;
					FlxG.switchState(new FreeplayState());
					trace("Freeplay Menu Selected");
				}
			case 'options':
				FlxG.switchState(new OptionsMenu());
			case 'extras':
				transitionTimer = new FlxTimer().start(0.85, function(tmr:FlxTimer)
				{
					//TEMP CODE FOR JUMPSCARE LMAO
					if (!movedBack)
					{
						transitionOut();
						anotherFuckingVariableAUGH = true;
					}
					transitionTimer = new FlxTimer().start(0.4, function(tmr:FlxTimer)
					{
						dummyBlackScreen.visible = true;
						transitionTimer = new FlxTimer().start(0.5, function(tmr:FlxTimer)
						{
							if (!movedBack)
							{
								finishTransOut();
							
								FlxG.sound.music.stop();
								FlxG.sound.playMusic(Paths.sound('boh'), 1, false);
								FlxG.sound.music.onComplete = endJumpscare;
								FlxG.camera.shake(0.1, FlxG.sound.music.length, true);
								camFollow.screenCenter();
								FlxG.camera.focusOn(camFollow.getPosition());
								FlxG.camera.follow(camFollow, LOCKON, 60);
								jumpscareSprite.visible = true;
								startMovingJumpscareSprite = true;
							}
						});
					});
				});
		}
	}

	private function endJumpscare():Void
	{
		FlxG.sound.music.stop();
		jumpscareSprite.visible = false;
		System.exit(0);
	}

	function changeItem(huh:Int = 0)
	{
		if (finishedFunnyMove)
		{
			curSelected += huh;

			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
		}
		menuItems.forEach(function(spr:MenuItem.MainMenuItem)
		{
			spr.animation.play('idle');
			spr.targetX = 0;

			if (spr.ID == curSelected && finishedFunnyMove)
			{
				spr.targetX = 25;
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}
			spr.updateHitbox();
		});
	}

	override function beatHit()
	{
		super.beatHit();
		
		if (FlxG.sound.music.playing && FlxG.save.data.weekUnlocked == 1 && !FreeplayState.freeplayMusicPlaying)
		{
			if (curBeat % 4 == 0)
				curKey += 1;
		}
	}
}
