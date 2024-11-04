package;

import flixel.input.gamepad.FlxGamepad;
import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.system.FlxSound;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;

#if windows
import Discord.DiscordClient;
#end
import flixel.addons.transition.FlxTransitionableState;

using StringTools;

class FreeplaySelectionState extends MusicBeatMenu
{
	public static var isOrange:Bool = false;
	
	public static var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;
	var menuTips:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['blue', 'orange'];
	#else
	var optionShit:Array<String> = ['blue', 'orange'];
	#end

	var newGaming:FlxText;
	var newGaming2:FlxText;
	public static var firstStart:Bool = true;
	var movedBack:Bool = false;
	public static var nightly:String = "";

	var alternatebg:FlxSprite;
	public static var finishedFunnyMove:Bool = false;

	var camFollow:FlxObject;

	override function create()
	{
		confirmSound = new FlxSound();

		//Week-dependent Menu theme and BG colours
		switch (FlxG.save.data.weekUnlocked)
		{
			case 0 | 1:
				if (FlxG.sound.music != null)
					if (!FlxG.sound.music.playing)
						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.65);
				bgColor = 0xFF000000;
				TitleState.weekAdderThingy = "";
			case 2:
				if (FlxG.sound.music != null)
					if (!FlxG.sound.music.playing)
						FlxG.sound.playMusic(Paths.music('glitchyMenu'), 0.65);
				bgColor = 0xFF120005;
				TitleState.weekAdderThingy = "-glitchy";
			case 3:
				if (FlxG.sound.music != null)
					if (!FlxG.sound.music.playing)
						FlxG.sound.playMusic(Paths.music('cityMenu'), 0.65);
				bgColor = 0xFF0b0d1d;
				TitleState.weekAdderThingy = "-city";
			case 4:
				if (FlxG.sound.music != null)
					if (!FlxG.sound.music.playing)
						FlxG.sound.playMusic(Paths.music('villageMenu'), 0.65);
				bgColor = 0xff00171c;
				TitleState.weekAdderThingy = "-village";
			default:
				if (FlxG.sound.music != null)
					if (!FlxG.sound.music.playing)
						FlxG.sound.playMusic(Paths.music('peacefulMenu'), 0.65);
				bgColor = 0xFF051c31;
		}

		if (!FreeplayState.freeplayMusicPlaying)
			Conductor.changeBPM(102);

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('menuDesat'));
		//bg.scrollFactor.x = 0;
		//bg.scrollFactor.y = 0.10;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		if (!Main.nightMode && !FlxG.save.data.nightmode)
			bg.alpha = 1;
		else
			bg.alpha = 0.65;
		bg.antialiasing = FlxG.save.data.antialiasing;
		bg.color = 0xFFe4ffcb;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		alternatebg = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		//alternatebg.scrollFactor.x = 0;
		//alternatebg.scrollFactor.y = 0.10;
		alternatebg.setGraphicSize(Std.int(alternatebg.width * 1.1));
		alternatebg.updateHitbox();
		alternatebg.screenCenter();
		alternatebg.visible = false;
		if (!Main.nightMode && !FlxG.save.data.nightmode)
			alternatebg.alpha = 1;
		else
			alternatebg.alpha = 0.35;
		alternatebg.antialiasing = FlxG.save.data.antialiasing;
		add(alternatebg);

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('freeplay_selection_menu_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, FlxG.height * 5);
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " normal", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " hover", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			//menuItem.scrollFactor.set();
			menuItem.antialiasing = FlxG.save.data.antialiasing;
			if (firstStart)
				FlxTween.tween(menuItem,{y: 80 + (i * 180)},1 + (i * 0.25) ,{type: ONESHOT, ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
					{ 
						finishedFunnyMove = true; 
						changeItem();
					}});
			else
				menuItem.y = 60 + (i * 180);
		}

		menuTips = new FlxTypedGroup<FlxSprite>();
		add(menuTips);

		var tex = Paths.getSparrowAtlas('freeplay_selection_tips_assets');

		for (i in 0...optionShit.length)
		{
			var menuTip:FlxSprite = new FlxSprite(0, FlxG.height * 5);
			menuTip.frames = tex;
			menuTip.animation.addByPrefix('idle', optionShit[i] + " none", 24);
			menuTip.animation.addByPrefix('inform', optionShit[i] + " tip", 24);
			menuTip.animation.play('idle');
			menuTip.ID = i;
			menuTip.screenCenter(X);
			menuTip.setGraphicSize(Std.int(menuTip.width * 0.9));
			menuTips.add(menuTip);
			//menuTip.scrollFactor.set();
			menuTip.antialiasing = FlxG.save.data.antialiasing;
			if (firstStart)
				FlxTween.tween(menuTip,{y: 400 + (i * 0)},1 + (i * 0) ,{type: ONESHOT, ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
					{ 
						finishedFunnyMove = true; 
						changeItem();
					}});
			else
				menuTip.y = 400 + (i * 0);
		}

		firstStart = false;

		FlxG.camera.follow(camFollow, null, 0.06);

		controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();

		super.create();
		
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end
	}

	var selectedSomethin:Bool = false;
	var allowSpeedrunSkip:Bool = false;
	var transitionTimer:FlxTimer;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume != 0.65 && !FreeplayState.freeplayMusicPlaying)
			FlxG.sound.music.volume = 0.65;

		if (!selectedSomethin)
		{
			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
				{
					if (!FreeplayState.freeplayMusicPlaying)
					{
						FlxG.sound.play(Paths.soundRandom('scrollMenu', 1, 3));
					}
					else
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
					}
					changeItem(-1);
				}
				if (gamepad.justPressed.DPAD_DOWN)
				{
					if (!FreeplayState.freeplayMusicPlaying)
					{
						FlxG.sound.play(Paths.soundRandom('scrollMenu', 1, 3));
					}
					else
					{
						FlxG.sound.play(Paths.sound('scrollMenu'));
					}
					changeItem(1);
				}
			}

			if (FlxG.keys.justPressed.UP)
			{
				if (!FreeplayState.freeplayMusicPlaying)
				{
					FlxG.sound.play(Paths.soundRandom('scrollMenu', 1, 3));
				}
				else
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				changeItem(-1);
			}

			if (FlxG.keys.justPressed.DOWN)
			{
				if (!FreeplayState.freeplayMusicPlaying)
				{
					FlxG.sound.play(Paths.soundRandom('scrollMenu', 1, 3));
				}
				else
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
				}
				changeItem(1);
			}

			if (controls.BACK || FlxG.mouse.justPressedRight)
			{
				if (!movedBack)
				{
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
					transitionTimer = new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						transitionTimer.destroy();
						//FlxTransitionableState.defaultTransIn.setStatus(NULL);
						FlxG.switchState(new MainMenuState());
					});
				}
				else
				{
					transitionTimer.cancel();
					//FlxTransitionableState.defaultTransIn.setStatus(NULL);
					FlxG.switchState(new MainMenuState());
				}
			}

			if (controls.ACCEPT && !movedBack)
			{
				if (optionShit[curSelected] == 'blue')
				{
					isOrange = false;
					selectedSomethin = true;
					if (!FreeplayState.freeplayMusicPlaying)
					{
						confirmSound = FlxG.sound.play(Paths.sound('confirmMenuBlue' + TitleState.weekAdderThingy));
						new FlxTimer().start(0.04, function(tmr:FlxTimer)
						{
							FlxG.sound.music.stop();
						});
					}
					else
						confirmSound = FlxG.sound.play(Paths.sound('confirmMenu' + TitleState.weekAdderThingy));
					confirmSound.persist = true;
					confirmSound.autoDestroy = true;

					alternatebg.color = 0xFFd9dfff;
					
					if (FlxG.save.data.flashing)
						FlxFlicker.flicker(alternatebg, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 1.3, {type: ONESHOT, 
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
				}
				else if (controls.ACCEPT && optionShit[curSelected] != 'donate' && allowSpeedrunSkip)
				{	
					trace("Speedrun SKIP");
					confirmSound.persist = false;
					goToState();
				}
				else
				{
					isOrange = true;
					selectedSomethin = true;
					if (!FreeplayState.freeplayMusicPlaying)
					{
						confirmSound = FlxG.sound.play(Paths.sound('confirmMenuOrange' + TitleState.weekAdderThingy));
						new FlxTimer().start(0.04, function(tmr:FlxTimer)
						{
							FlxG.sound.music.stop();
						});
					}
					else
					{
						confirmSound = FlxG.sound.play(Paths.sound('confirmMenu'));
					}
					confirmSound.persist = true;
					confirmSound.autoDestroy = true;
					FlxG.camera.shake(0.01, 1, true, true);

				//	alternatebg.color = 0xFFffe6d6;
					alternatebg.color = 0xFFffdac7;
											
					if (FlxG.save.data.flashing)
						FlxFlicker.flicker(alternatebg, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 1.3, {type: ONESHOT, 
								ease: FlxEase.quadOut,
								onComplete: function(twn:FlxTween)
								{
									spr.kill();
								}
							});
						}
						else
						{
							if (FlxG.save.data.flashing)
							{
								FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
								{
									new FlxTimer().start(0.5, function(tmr:FlxTimer)
									{
										goToState();
									});
								});
							}
							else
							{
								new FlxTimer().start(1, function(tmr:FlxTimer)
								{
									new FlxTimer().start(0.5, function(tmr:FlxTimer)
									{
										goToState();
									});
								});
							}
						}
					});
				}
			}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}
	
	function goToState()
	{
		var daChoice:String = optionShit[curSelected];

		switch (daChoice)
		{
			case 'blue':
				FlxG.switchState(new FreeplayState());
				trace("Freeplay Blue Selected");

			case 'orange':
				FlxG.switchState(new FreeplayState());
				trace("Freeplay Orange Selected");
		}
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
		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected && finishedFunnyMove)
			{
				spr.animation.play('selected');
				camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			spr.updateHitbox();
		});
		menuTips.forEach(function(spr:FlxSprite)
		{
			spr.animation.play('idle');

			if (spr.ID == curSelected && finishedFunnyMove)
			{
				spr.animation.play('inform');
			}
			spr.updateHitbox();
		});
	}
}
