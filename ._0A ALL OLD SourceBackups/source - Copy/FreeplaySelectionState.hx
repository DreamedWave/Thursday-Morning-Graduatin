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
import io.newgrounds.NG;
import lime.app.Application;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class FreeplaySelectionState extends MusicBeatState
{
	public static var isOrange:Bool = false;
	
	var curSelected:Int = 0;

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
	var camFollow:FlxObject;
	public static var finishedFunnyMove:Bool = false;

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
			{
				switch (FlxG.save.data.weekUnlocked)
				{
					case 1:
						FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.7);
					case 2:
						FlxG.sound.playMusic(Paths.music('glitchyMenu'), 0.7);
					case 3:
						FlxG.sound.playMusic(Paths.music('cityMenu'), 0.7);
					default:
						FlxG.sound.playMusic(Paths.music('peacefulMenu'), 0.7);
				}
			}
		}

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('menuDesat'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.10;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		if(FlxG.save.data.antialiasing)
			{
				bg.antialiasing = true;
			}
		bg.color = 0xFFe4ffcb;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		alternatebg = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		alternatebg.scrollFactor.x = 0;
		alternatebg.scrollFactor.y = 0.10;
		alternatebg.setGraphicSize(Std.int(alternatebg.width * 1.1));
		alternatebg.updateHitbox();
		alternatebg.screenCenter();
		alternatebg.visible = false;
		if(FlxG.save.data.antialiasing)
			{
				alternatebg.antialiasing = true;
			}
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
			menuItem.scrollFactor.set();
			if(FlxG.save.data.antialiasing)
				{
					menuItem.antialiasing = true;
				}
			if (firstStart)
				FlxTween.tween(menuItem,{y: 80 + (i * 180)},1 + (i * 0.25) ,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
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
			menuTip.scrollFactor.set();
			if(FlxG.save.data.antialiasing)
				{
					menuTip.antialiasing = true;
				}
			if (firstStart)
				FlxTween.tween(menuTip,{y: 400 + (i * 0)},1 + (i * 0) ,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
					{ 
						finishedFunnyMove = true; 
						changeItem();
					}});
			else
				menuTip.y = 400 + (i * 0);
		}

		firstStart = false;

		FlxG.camera.follow(camFollow, null, 0.60 * (60 / FlxG.save.data.fpsCap));

		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

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

			if (controls.BACK && !movedBack)
			{
				movedBack = true;
				switch (FlxG.save.data.weekUnlocked)
				{
					case 2:
						FlxG.sound.play(Paths.sound('cancelMenu'));
					case 3:
						FlxG.sound.play(Paths.sound('cancelMenu'));
					case 6:
						FlxG.sound.play(Paths.sound('cancelMenu' + MainMenuState.curKey));
					default:
						if (!FreeplayState.freeplayMusicPlaying)
							FlxG.sound.play(Paths.sound('cancelMenu' + MainMenuState.curKey));
						else
							FlxG.sound.play(Paths.sound('cancelMenu'));
				}
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					FlxG.switchState(new MainMenuState());
				});
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'blue')
				{
					isOrange = false;
					selectedSomethin = true;
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
					alternatebg.color = 0xFFd9dfff;
					
					if (FlxG.save.data.flashing)
						FlxFlicker.flicker(alternatebg, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 1.3, {
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
								new FlxTimer().start(0.5, function(tmr:FlxTimer)
								{
									goToState();
								});
							}
						}
					});
				}
				else
				{
					isOrange = true;
					selectedSomethin = true;
					if (!FreeplayState.freeplayMusicPlaying)
					{
						FlxG.sound.play(Paths.sound('confirmMenuOrange' + TitleState.weekAdderThingy));
						new FlxTimer().start(0.04, function(tmr:FlxTimer)
						{
							FlxG.sound.music.stop();
						});
					}
					else
					{
						FlxG.sound.play(Paths.sound('confirmMenu'));
					}
				//	alternatebg.color = 0xFFffe6d6;
					alternatebg.color = 0xFFffdac7;
											
					if (FlxG.save.data.flashing)
						FlxFlicker.flicker(alternatebg, 1.1, 0.15, false);

					menuItems.forEach(function(spr:FlxSprite)
					{
						if (curSelected != spr.ID)
						{
							FlxTween.tween(spr, {alpha: 0}, 1.3, {
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
