package;

import flixel.input.gamepad.FlxGamepad;
import Controls.KeyboardScheme;
//import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxObject;
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

class MainMenuState extends MusicBeatMenu
{
	static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<MenuItem.MainMenuItem>;
	var menuBG:FlxSprite;
	var menuIcon:FlxSprite;
	var menuArrow:FlxSprite;

	#if !switch
	var optionShit:Array<String> = ['campaign', 'freeplay', 'options', 'extras'];
	#else
	var optionShit:Array<String> = ['campaign', 'freeplay'];
	#end

	var newGaming:FlxText;
	var newGaming2:FlxText;
	static var firstStart:Bool = true;

	var bg:FlxSprite;
	var magenta:FlxSprite;
	var bgGroup:FlxTypedGroup<FlxSprite> = null;
	var bgGroupTargetY:Float = 0;

	var camFollow:FlxObject;

	var finishedFunnyMove:Bool = false;
	var arrowTween:FlxTween;

	var movedBack:Bool = false;

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		if (FlxG.save.data.showPresence)
			DiscordClient.changePresence("In the Main Menu", null);
		#end

		confirmSound = new FlxSound();

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
			{
				switch (FlxG.save.data.weekUnlocked)
				{
					case 1:
						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.65);
						TitleState.weekAdderThingy = "";
						bgColor = 0xFF000000;
					case 2:
						FlxG.sound.playMusic(Paths.music('glitchyMenu'), 0.65);
						TitleState.weekAdderThingy = "-glitchy";
						bgColor = 0xFF120005;
					case 3:
						FlxG.sound.playMusic(Paths.music('cityMenu'), 0.65);
						TitleState.weekAdderThingy = "-city";
						bgColor = 0xFF0b0d1d;
					case 4:
						FlxG.sound.playMusic(Paths.music('villageMenu'), 0.65);
						if (FlxG.random.bool(40))
							FlxG.sound.music.time = 122355;
						TitleState.weekAdderThingy = "-village";
						bgColor = 0xff00171c;
					default:
						FlxG.sound.playMusic(Paths.music('peacefulMenu'), 0.65);
						bgColor = 0xFF051c31;
				}
			}
		}

		if (!FreeplayState.freeplayMusicPlaying)
			Conductor.changeBPM(102);

		persistentUpdate = true;
		persistentDraw = true;

		bgGroup = new FlxTypedGroup<FlxSprite>();
		add(bgGroup);

		bg = new FlxSprite(-100).loadGraphic(Paths.image('menuBG'));
		//bg.scrollFactor.set();
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = FlxG.save.data.antialiasing;
		if (!Main.nightMode && !FlxG.save.data.nightmode)
			bg.alpha = 1;
		else
			bg.alpha = 0.65;
		bgGroup.add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.screenCenter();
		add(camFollow);

		magenta = new FlxSprite(0, 0).loadGraphic(Paths.image('menuBGMagenta'));
		//magenta.scrollFactor.set();
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = FlxG.save.data.antialiasing;
		if (!Main.nightMode && !FlxG.save.data.nightmode)
			magenta.alpha = 1;
		else
			magenta.alpha = 0.35;
		bgGroup.add(magenta);

		menuBG = new FlxSprite(0, -7).loadGraphic(Paths.image('MainMenu_buttonsBG'));
		//menuBG.scrollFactor.set();
		if (!Main.nightMode && !FlxG.save.data.nightmode)
			menuBG.alpha = 0.75;
		else
			menuBG.alpha = 0.85;
		menuBG.antialiasing = FlxG.save.data.antialiasing;
		menuBG.scale.set(1, 0.95);
		menuBG.updateHitbox();
		menuBG.screenCenter(Y);
		menuBG.x = -menuBG.width;
		menuBG.y -= 22;
		add(menuBG);

		menuIcon = new FlxSprite().loadGraphic(Paths.image('MainMenu_placeholderICO'));
		//menuIcon.scrollFactor.set();
		menuIcon.alpha = 0;
		menuIcon.antialiasing = FlxG.save.data.antialiasing;
		menuIcon.setGraphicSize(Std.int(menuIcon.width * 0.9));
		menuIcon.updateHitbox();
		menuIcon.screenCenter(Y);
		menuIcon.x = FlxG.width - (menuIcon.width - 230);
		menuIcon.y -= 30;
		add(menuIcon);

		menuItems = new FlxTypedGroup<MenuItem.MainMenuItem>();
		add(menuItems);

		menuArrow = new FlxSprite(0, 215).loadGraphic(Paths.image('MainMenu_arrow'));
		//menuArrow.scrollFactor.set();
		menuArrow.antialiasing = FlxG.save.data.antialiasing;
		menuArrow.setGraphicSize(Std.int(menuArrow.width * 0.9));
		menuArrow.updateHitbox();
		menuArrow.visible = false;
		add(menuArrow);

		for (i in 0...optionShit.length)
		{
			trace ('adding menu item ' + i);
			var menuItem:MenuItem.MainMenuItem = new MenuItem.MainMenuItem(-40, FlxG.height * 1.6, optionShit[i], i);
			menuItem.visible = false;
			menuItem.scale.set(0.9, 0.9);
			menuItem.updateHitbox();
			menuItems.add(menuItem);
			menuArrow.x = -menuArrow.width * 1.5;
			menuArrow.visible = true;

			if (firstStart)
			{
				menuItem.visible = true;
				menuItem.intTween = FlxTween.tween(menuItem,{y: 80 + (i * 135)}, 1 + (i * 0.15) ,{type: ONESHOT, ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
					{ 
						menuItem.intTween = null;
						changeItem(0, false);
					}
				});
				
				if (i == 0)
				{
					arrowTween = FlxTween.tween(menuArrow, {x: 0}, 1 + (curSelected * 0.15), {type: ONESHOT, ease: FlxEase.expoOut, startDelay: 1 + (curSelected * 0.15), onComplete: function(flxTween:FlxTween)
						{
							arrowTween = null;
						}
					});
				}
			}
			else
			{
				menuItem.x = -menuItem.width;
				menuItem.y = 80 + (i * 135);
				menuItem.allowInternalTween = false;
				menuItem.visible = true;

				var tweenToX:Int = -40;

				if (i == curSelected)
				{
					menuArrow.y = menuItem.y;
					menuItem.animation.play('selected');
					tweenToX = 45;
				}

				if (i == 0)
				{
					arrowTween = FlxTween.tween(menuArrow, {x: 0}, 1, {type: ONESHOT, ease: FlxEase.expoOut, startDelay: 0.45 + (curSelected * 0.1), onComplete: function(flxTween:FlxTween)
						{
							arrowTween = null;
						}
					});
				}

				menuItem.intTween = FlxTween.tween(menuItem,{x: tweenToX}, 1 + (i * 0.15), {type: ONESHOT, ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween)  
				{ 
					menuItem.intTween = null;
					menuItem.allowInternalTween = true;
					changeItem(0, false);
				}});
			}
		}

		new FlxTimer().start(1 + (optionShit.length * 0.15), function(tmr:FlxTimer)
		{
			//More accurate finishedfunnymove
			finishedFunnyMove = true;
		});

		FlxTween.tween(menuBG, {x: 0}, 1, {type: ONESHOT, ease: FlxEase.expoOut});
		FlxTween.tween(menuIcon, {alpha: 0.8, x: menuIcon.x - 275}, 1, {type: ONESHOT, ease: FlxEase.expoOut});

		firstStart = false;

		controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		super.create();

		setUpTips('MainMenu');

		mouseTimer = new FlxTimer().start(0.5, function(swagTimer:FlxTimer)
		{
			mouseActive = true;
		});
	}

	var selectedSomethin:Bool = false;
	var allowSpeedrunSkip:Bool = false;
	var transitionTimer:FlxTimer;

	//for jokejumpscare, remove once done
	var dummyBlackScreen:FlxSprite;
	var jumpscareSprite:FlxSprite;
	var startMovingJumpscareSprite:Bool = false;
	var boolIDidntWannaAddButFuckItAnywaysLMAO:Bool = false;
	var anotherFuckingVariableAUGH:Bool = false;
	var preventMusicVolumeFixing:Bool = false;

	var gamepad:FlxGamepad;

	var mouseActive:Bool = false;
	var mouseTimer:FlxTimer;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.65 && !preventMusicVolumeFixing && !FreeplayState.freeplayMusicPlaying)
			FlxG.sound.music.volume = 0.65;

		//FlxG.watch.addQuick("Did mouse just move?? ", FlxG.mouse.justMoved);

		if (!selectedSomethin)
		{
			gamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP && (finishedFunnyMove || !firstStart))
					changeItem(-1);
				else if (gamepad.justPressed.DPAD_DOWN && (finishedFunnyMove || !firstStart))
					changeItem(1);
			}
			else
			{
				if (mouseActive && FlxG.mouse.justMoved && Main.isFocused)
				{
					for (spr in menuItems)
					{
						if (FlxG.mouse.overlaps(spr) && curSelected != spr.ID)
						{
							var change:Int = spr.ID - curSelected;
							changeItem(change);
							mouseActive = false;
							mouseTimer = new FlxTimer().start(0.025, function(tmr:FlxTimer)
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
						changeItem(-1);
						if (mouseTimer.active)
							mouseTimer.cancel();
						mouseActive = false;
						mouseTimer = new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							mouseActive = true;
						});
					}
					else if (FlxG.keys.justPressed.DOWN)
					{
						changeItem(1);
						if (mouseTimer.active)
							mouseTimer.cancel();
						mouseActive = false;
						mouseTimer = new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							mouseActive = true;
						});
					}
				}
			}

			if (controls.BACK || FlxG.mouse.justPressedRight && Main.isFocused)
			{
				if (!movedBack)
				{
					movedBack = true;
					switch (FlxG.save.data.weekUnlocked)
					{
						case 2 | 3:
							FlxG.sound.play(Paths.sound('cancelMenu'));
						case 6:
							FlxG.sound.play(Paths.sound('cancelMenu' + curKey));
						default:
							if (!FreeplayState.freeplayMusicPlaying)
								FlxG.sound.play(Paths.sound('cancelMenu' + curKey));
							else
								FlxG.sound.play(Paths.sound('cancelMenu'));
					}
					transitionTimer = new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						transitionTimer.destroy();
						Main.updateTimeStuffs();
						FlxG.switchState(new TitleState());
					});
				}
				else
				{
					transitionTimer.cancel();
					Main.updateTimeStuffs();
					FlxG.switchState(new TitleState());
				}
			}
			else if ((controls.ACCEPT || FlxG.mouse.justPressed && FlxG.mouse.overlaps(menuItems) && Main.isFocused) && !movedBack)
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
				for (spr in menuItems)
				{
					if (spr.intTween != null)
					{
						spr.intTween.cancel();
						spr.allowInternalTween = true;
					}
				}
				menuItems.members[curSelected].animation.play('selected');
				menuItems.members[curSelected].x = 80;
				menuItems.members[curSelected].targetX = 50;
				menuItems.members[curSelected].y = 80 + (menuItems.members[curSelected].ID * 135);
				if (arrowTween != null)
				{
					arrowTween.cancel();
					menuArrow.x = 0;
					menuArrow.y = menuItems.members[curSelected].y;
				}
				FlxTween.tween(menuBG, {x: -menuBG.width}, 1.25, {type: ONESHOT, ease: FlxEase.expoIn});
				FlxTween.tween(menuIcon, {alpha: 0, x: menuIcon.x + 275}, 1.25, {type: ONESHOT, ease: FlxEase.expoIn});
				FlxTween.tween(menuArrow, {x: -menuArrow.width}, 0.5, {type: ONESHOT, ease: FlxEase.expoIn, startDelay: 0.5});
				FlxTween.tween(menuItems.members[curSelected], {x: -menuItems.members[curSelected].width}, 1, {type: ONESHOT, ease: FlxEase.expoIn, startDelay: 0.5});
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					menuItems.members[curSelected].allowInternalTween = false;
				});

				switch(optionShit[curSelected])
				{
					case 'freeplay':
						switch (FlxG.save.data.weekUnlocked)
						{
							case 6:
								confirmSound = FlxG.sound.play(Paths.sound('confirmMenu'));
							default:
								if (!FreeplayState.freeplayMusicPlaying)
								{
									confirmSound = FlxG.sound.play(Paths.sound('confirmMenuBlue' + TitleState.weekAdderThingy));
									FlxG.sound.music.stop();
								}
								else
									confirmSound = FlxG.sound.play(Paths.sound('confirmMenu' + TitleState.weekAdderThingy));
						}
					case 'extras':
						preventMusicVolumeFixing = true;
						FlxG.sound.music.volume = 0;
						confirmSound = FlxG.sound.play(Paths.sound('confirmMenuOrange' + TitleState.weekAdderThingy));
						
						//for joke jumpscare lol
						dummyBlackScreen = new FlxSprite(-FlxG.width,
							-FlxG.height).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
						dummyBlackScreen.scrollFactor.set();
						dummyBlackScreen.visible = false;
						add(dummyBlackScreen);
					
						jumpscareSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('jumpscare'));
						jumpscareSprite.angle = -6;
						jumpscareSprite.antialiasing = FlxG.save.data.antialiasing;
						jumpscareSprite.setGraphicSize(Std.int(jumpscareSprite.width * 0.1));
						//jumpscareSprite.scrollFactor.set(1, 1);
						jumpscareSprite.updateHitbox();
						jumpscareSprite.screenCenter();
						jumpscareSprite.visible = false;
						add(jumpscareSprite);
					default:
						confirmSound = FlxG.sound.play(Paths.sound('confirmMenu' + TitleState.weekAdderThingy));
				}
				confirmSound.persist = true;
				confirmSound.autoDestroy = true;
				FlxG.camera.shake(0.01, 1, true, true);
					
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
			else if (FlxG.keys.justPressed.P)
			{
				LoadingState.target = new lore_minigames.MinigameState();
				FlxG.switchState(new LoadingState());
			}
			else if (FlxG.keys.justPressed.T)
			{
				FlxG.switchState(new TestState());
			}
		}
		else if (controls.ACCEPT && optionShit[curSelected] != 'extras' && (optionShit[curSelected] != 'freeplay' || FlxG.save.data.weekUnlocked >= 6) && allowSpeedrunSkip)
		{	
			FlxG.camera.stopFX('shake');
			trace("Speedrun SKIP");
			allowSpeedrunSkip = false;
			confirmSound.persist = false;
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
						confirmSound.stop();
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
								FlxG.sound.play(Paths.sound('cancelMenu' + curKey));
							default:
								if (!FreeplayState.freeplayMusicPlaying)
									FlxG.sound.play(Paths.sound('cancelMenu' + curKey));
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
				var mult2:Float = FlxMath.lerp(7, jumpscareSprite.angle, CoolUtil.boundTo(1 - (elapsed * 2.5), 0, 1));
				jumpscareSprite.scale.set(mult1, mult1);
				jumpscareSprite.angle = mult2;
				jumpscareSprite.updateHitbox();
				jumpscareSprite.screenCenter();
			}
		}

		super.update(elapsed);

		for (bgElem in bgGroup)
			bgElem.y = FlxMath.lerp(bgGroupTargetY, bgElem.y, CoolUtil.boundTo(1 - (elapsed * 10), 0, 1));
	}
	
	function goToState()
	{
		var daChoice:String = optionShit[curSelected];

		switch (daChoice)
		{
			case 'campaign':
				Main.updateTimeStuffs();
				FlxG.switchState(new StoryMenuState());
				trace("Campaign Selected");
			case 'freeplay':
				#if !debug
				if (FlxG.save.data.weekUnlocked >= 6)
				{
					Main.updateTimeStuffs();
					FlxG.switchState(new FreeplaySelectionState());
					trace("Freeplay Selection Menu Selected");
				}
				else
				{
					FreeplaySelectionState.isOrange = false;
					Main.updateTimeStuffs();
					FlxG.switchState(new FreeplayState());
					trace("Freeplay Menu Selected");
				}
				#else
				Main.updateTimeStuffs();
				FlxG.switchState(new FreeplaySelectionState());
				#end
			case 'options':
				Main.updateTimeStuffs();
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
								camFollow.screenCenter();
								FlxG.camera.focusOn(camFollow.getPosition());
								FlxG.camera.follow(camFollow, LOCKON);
								FlxG.camera.shake(0.05, FlxG.sound.music.length, true);
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

	var canculed:Bool = false;
	function changeItem(huh:Int = 0, makeSound:Bool = true)
	{
		curSelected += huh;

		if (curSelected >= menuItems.length)
			curSelected = 0;
		if (curSelected < 0)
			curSelected = menuItems.length - 1;

		for (spr in menuItems)
		{
			if (spr.ID == curSelected)
			{
				if (spr.intTween != null)
				{
					spr.intTween.cancel();
					spr.y = 80 + (spr.ID * 135);
					spr.allowInternalTween = true;
				}
				
				menuArrow.y = spr.y;

				if (spr.x < 35 && !firstStart)
					spr.x = 35;
				spr.targetX = 45;
				spr.animation.play('selected');
				spr.updateHitbox();

				if (finishedFunnyMove || canculed)
					bgGroupTargetY = -20 * spr.ID;
			}
			else
			{
				spr.animation.play('idle');
				spr.updateHitbox();
				spr.targetX = -40;
				if (!finishedFunnyMove && huh != 0)
				{	
					if (spr.intTween != null)
						spr.intTween.cancel();
					spr.y = 80 + (spr.ID * 135);
					if (spr.x <= -60 + (spr.ID * -20))
						spr.x = -60 + (spr.ID * -20);
					spr.allowInternalTween = true;
					trace('canculed ' + spr.ID);

					if (arrowTween != null)
					{
						arrowTween.cancel();
						menuArrow.x = 0;
					}

					canculed = true;
				}
			}
		}

		if (makeSound)
		{
			switch (FlxG.save.data.weekUnlocked)
			{
				case 2:
					FlxG.sound.play(Paths.sound('scrollMenu'));
				case 3:
					FlxG.sound.play(Paths.sound('scrollMenu'));
				case 6:
					FlxG.sound.play(Paths.sound('scrollMenu' + curKey));
				default:
					if (!FreeplayState.freeplayMusicPlaying)
						FlxG.sound.play(Paths.sound('scrollMenu' + curKey));
					else
						FlxG.sound.play(Paths.sound('scrollMenu'));
			}
		}
	}
}
