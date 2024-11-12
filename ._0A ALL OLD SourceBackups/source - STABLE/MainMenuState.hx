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

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	#if !switch
	var optionShit:Array<String> = ['story mode', 'freeplay', 'donate', 'options'];
	#else
	var optionShit:Array<String> = ['story mode', 'freeplay'];
	#end

	var newGaming:FlxText;
	var newGaming2:FlxText;
	public static var firstStart:Bool = true;

	public static var nightly:String = "";

	public static var kadeEngineVer:String = "1.6" + nightly;
	public static var gameVer:String = "0.2.7.1";

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	public static var finishedFunnyMove:Bool = false;

	public static var curKey:Int = 1;
	var movedBack:Bool = false;

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
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

		var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.10;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		if(FlxG.save.data.antialiasing)
			{
				bg.antialiasing = true;
			}
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuBGMagenta'));
//		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.10;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		if(FlxG.save.data.antialiasing)
			{
				magenta.antialiasing = true;
			}
//		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, FlxG.height * 1.6);
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
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
				FlxTween.tween(menuItem,{y: 60 + (i * 160)},1 + (i * 0.25) ,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
					{ 
						finishedFunnyMove = true; 
						changeItem();
					}});
			else
				menuItem.y = 60 + (i * 160);
		}

		firstStart = false;

		FlxG.camera.follow(camFollow, null, 0.06);

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, gameVer +  (Main.watermarks ? " TMG - " + kadeEngineVer + " Kade Engine" : ""), 12);
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
				if (gamepad.justPressed.DPAD_DOWN)
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

			if (FlxG.keys.justPressed.UP)
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

			if (FlxG.keys.justPressed.DOWN)
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

			if (controls.BACK && !movedBack)
			{
				movedBack = true;
				if (!FreeplayState.freeplayMusicPlaying)
				{
					FlxG.sound.play(Paths.soundRandom('cancelMenu', 1, 3));
				}
				else
				{
					FlxG.sound.play(Paths.sound('cancelMenu'));
				}
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
			{
				if (optionShit[curSelected] == 'donate')
				{
					fancyOpenURL("https://4364.bandcamp.com/");
				}
				else
				{
					selectedSomethin = true;
					if (optionShit[curSelected] == 'freeplay')
					{
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
					}
					else
						//duplicate, i know but-- shut up LMAO
						FlxG.sound.play(Paths.sound('confirmMenu' + TitleState.weekAdderThingy));
					
					if (FlxG.save.data.flashing)
						FlxFlicker.flicker(magenta, 1.1, 0.15, false);

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
			}
		}

		super.update(elapsed);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if (curKey > 4 || curKey < 1)
			curKey = 1;

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
			case 'story mode':
				FlxG.switchState(new StoryMenuState());
				trace("Story Menu Selected");
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
	}

	override function beatHit()
	{
		super.beatHit();
		
		if (FlxG.sound.music.playing && FlxG.save.data.weekUnlocked == 1 && !FreeplayState.freeplayMusicPlaying)
		{
			if (curBeat % 4 == 0)
				curKey += 1;
		}
		trace('beat');
	}
}
