package;

#if sys
import smTools.SMFile;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flash.system.System;
import io.newgrounds.NG;
import lime.app.Application;
import openfl.Assets;

#if windows
import Discord.DiscordClient;
import discord_rpc.DiscordRpc;
#end

#if cpp
import sys.thread.Thread;
#end

using StringTools;

class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ptSpr:FlxSprite;
	var jkSpr:FlxSprite;

	var curWacky:Array<String> = [];
	var wackyImage:FlxSprite;

	public static var weekAdderThingy:String = "";

	override public function create():Void
	{
		//Week dependent BgColours
		switch (FlxG.save.data.weekUnlocked)
		{
			case 1:
				bgColor = 0xFF000000;
				weekAdderThingy = "";
			case 2:
				bgColor = 0xFF120005;
				//weekAdderThingy = "-glitchy";
			case 3:
				bgColor = 0xFF0b0d1d;
				weekAdderThingy = "-city";
			default:
				bgColor = 0xFF0e1926;
		}

		#if polymod
		polymod.Polymod.init({modRoot: "mods", dirs: ['introMod']});
		#end
		
		#if sys
		if (!sys.FileSystem.exists(Sys.getCwd() + "/assets/replays"))
			sys.FileSystem.createDirectory(Sys.getCwd() + "/assets/replays");
		#end

		@:privateAccess
		{
			trace("Loaded " + openfl.Assets.getLibrary("default").assetsLoaded + " assets (DEFAULT)");
		}
		
		#if !cpp

		FlxG.save.bind('graduatin', 'dreamedwave');

		PlayerSettings.init();

		KadeEngineData.initSave();
		
		#end

		FlxG.camera.zoom = 1;
				
		Highscore.load();

		curWacky = FlxG.random.getObject(getIntroTextShit());

		trace('Hello There!');

		// DEBUG BULLSHIT

		super.create();

		#if ng
		var ng:NGio = new NGio(APIStuff.API, APIStuff.EncKey);
		trace('NEWGROUNDS AYY');
		#end

		#if FREEPLAY
		FlxG.switchState(new FreeplaySelectionState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		#else
		#if !cpp
		if (MainMenuState.firstStart)
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				startIntro();
			});
		else
			startIntro();
		#else
		startIntro();
		#end
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var closeButton:FlxSprite;

	function startIntro()
	{
		persistentUpdate = true;

		var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('titleBG'));
		bg.antialiasing = true;
		bg.updateHitbox();
		add(bg);

		if (Main.watermarks) {
			logoBl = new FlxSprite(-145, 1500);
			logoBl.frames = Paths.getSparrowAtlas('KadeEngineLogoBumpin');
		} else {
			logoBl = new FlxSprite(-145, -100);
			logoBl.frames = Paths.getSparrowAtlas('logoBumpin');
		}
		if(FlxG.save.data.antialiasing)
			{
				logoBl.antialiasing = true;
			}
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24, false);
		logoBl.animation.addByPrefix('static', 'logo static', 1, false);
		logoBl.updateHitbox();
		logoBl.animation.play('static');

		gfDance = new FlxSprite(FlxG.width * 0.3, FlxG.height * 0.08);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20], "", 24, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 0, 1, 2, 3, 4], "", 24, false);
		gfDance.animation.addByPrefix('disappear', "gfGone", 12, false);
		gfDance.animation.addByPrefix('confirm', "gfConfirm", 20, false);
		if(FlxG.save.data.antialiasing)
			{
				gfDance.antialiasing = true;
			}
		add(gfDance);
		add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.animation.addByPrefix('press-static', "ENTER PRESSED STATIC", 24);
		if(FlxG.save.data.antialiasing)
			{
				titleText.antialiasing = true;
			}
		titleText.animation.play('idle');
		titleText.updateHitbox();
		add(titleText);

		closeButton = new FlxSprite(985, -500);
		closeButton.frames = Paths.getSparrowAtlas('closeButton');
		closeButton.animation.addByPrefix('static', "closebutton to exit", 12);
		closeButton.animation.addByPrefix('press', "closebutton PRESSED", 24, false);
		if(FlxG.save.data.antialiasing)
			{
				titleText.antialiasing = true;
			}
		closeButton.animation.play('static');
		closeButton.updateHitbox();
		closeButton.alpha = 0.5;
		add(closeButton);

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, bgColor);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		credTextShit.screenCenter();

		credTextShit.visible = false;

		ptSpr = new FlxSprite(0, FlxG.height * 0.51).loadGraphic(Paths.image('point_logo'));
		add(ptSpr);
		ptSpr.visible = false;
		ptSpr.setGraphicSize(Std.int(ptSpr.width * 0.8));
		ptSpr.updateHitbox();
		ptSpr.screenCenter(X);
		if(FlxG.save.data.antialiasing)
			{
				ptSpr.antialiasing = true;
			}

		jkSpr = new FlxSprite(0, FlxG.height * 0.51).loadGraphic(Paths.image('joke_logo'));
		add(jkSpr);
		jkSpr.visible = false;
		jkSpr.setGraphicSize(Std.int(jkSpr.width * 0.9));
		jkSpr.updateHitbox();
		jkSpr.screenCenter(X);
		if(FlxG.save.data.antialiasing)
			{
				jkSpr.antialiasing = true;
			}

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;

		if (initialized)
			skipIntro();
		else 
		{
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			initialized = true;

			//Week dependent menu Music
			switch (FlxG.save.data.weekUnlocked)
			{
				case 1:
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.2);
				case 2:
					FlxG.sound.playMusic(Paths.music('glitchyMenu'), 0.2);
				case 3:
					FlxG.sound.playMusic(Paths.music('cityMenu'), 0.2);
				default:
					FlxG.sound.playMusic(Paths.music('peacefulMenu'), 0.2);
			}
			FlxG.sound.music.fadeIn(5, 0.2, 0.7);
			FlxG.camera.fade(FlxColor.BLACK, 0.5, true);
			Conductor.changeBPM(102);
		}

	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('data/introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, 0.95);

		var pressedEnter:Bool = controls.ACCEPT;
		var pressedBackspace:Bool = controls.BACK;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		if (pressedEnter && !transitioning && skippedIntro)
		{
			pressedAnything(1);
		}

		if(pressedBackspace && !transitioning && skippedIntro)
		{
			pressedAnything(2);
		}

		if (pressedEnter && !skippedIntro && initialized)
		{
			pressedAnything(0);
		}

		super.update(elapsed);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}
	
	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump', true);

		if (!transitioning)
		{
			if (FlxG.save.data.camzoom)
			{
				if (!skippedIntro)
				{
					FlxG.camera.zoom += 0.01;
				}
			}
			danceLeft = !danceLeft;

			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}
		//FlxG.log.add(curBeat);

		if (!skippedIntro)
		{
			switch (curBeat)
			{
				case 0:
					deleteCoolText();
				case 1:
					createCoolText(['FNF Dev Team', 'KadeDeveloper', 'and DreamedWave']);
				case 3:
					addMoreText('present');
				case 4:
					deleteCoolText();
				case 5:
					if (Main.watermarks)
						createCoolText(['With special thanks', 'to']);
					else
						createCoolText(['With special thanks', 'to']);
				case 7:
					if (Main.watermarks)
					{
						addMoreText('one silly joke');
						jkSpr.visible = true;
					}
					else
					{
						addMoreText('you, the player!');
						ptSpr.visible = true;
					}
				case 8:
					deleteCoolText();
					jkSpr.visible = false;
					ptSpr.visible = false;
				case 9:
					createCoolText([curWacky[0]]);
				case 11:
					addMoreText(curWacky[1]);
				case 12:
					deleteCoolText();
				case 13:
					addMoreText('Thursday');
				case 14:
					addMoreText('Morning');
				case 15:
					addMoreText('Graduatin');
				case 16:
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			jkSpr.destroy();
			ptSpr.destroy();

			if (FlxG.save.data.flashing)
			{
				FlxG.camera.flash(FlxColor.WHITE, 4);
			}
			
			credGroup.destroy();

			FlxTween.tween(logoBl,{y: -100}, 1.4, {ease: FlxEase.expoInOut});
			FlxTween.tween(closeButton,{y: 10}, 1.4, {ease: FlxEase.expoInOut});
			new FlxTimer().start(5, function(tmr:FlxTimer)
			{
				FlxTween.tween(closeButton,{alpha: 0.25}, 0.5, {ease: FlxEase.expoInOut});
			});

			logoBl.angle = -4;

			new FlxTimer().start(0.01, function(tmr:FlxTimer)
				{
					if(logoBl.angle == -4) 
						FlxTween.angle(logoBl, logoBl.angle, 4, 4, {ease: FlxEase.quartInOut});
					if (logoBl.angle == 4) 
						FlxTween.angle(logoBl, logoBl.angle, -4, 4, {ease: FlxEase.quartInOut});
				}, 0);

			skippedIntro = true;
		}
	}

	function pressedAnything(pressedWhat:Int)
	{
		switch (pressedWhat)
		{
			case 1:
				#if !switch
				NGio.unlockMedal(60960);
	
				// If it's Friday according to da clock
				if (Date.now().getDay() == 5)
					NGio.unlockMedal(61034);
				#end
	
				closeButton.alpha = 0.15;
				FlxTween.tween(closeButton,{y: -500}, 1.5, {ease: FlxEase.expoInOut, startDelay: 0.5});
	
				if (FlxG.save.data.flashing)
				{
					titleText.animation.play('press');
					FlxG.camera.flash(FlxColor.WHITE, 1);
				}
				else
				{
					titleText.animation.play('press-static');
				}
	
				if (FlxG.save.data.camzoom)
				{
					FlxG.camera.zoom += 0.02;
				}
	
				gfDance.animation.play('confirm');
				FlxG.sound.play(Paths.sound('confirmMenu' + weekAdderThingy), 0.7);
	
				transitioning = true;
	
				MainMenuState.firstStart = true;
				MainMenuState.finishedFunnyMove = false;
	
				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					FlxG.switchState(new MainMenuState());
				});

			case 2:
				transitioning = true;

				closeButton.alpha = 1;
				closeButton.animation.play('press');
				gfDance.animation.play('disappear');
				FlxTween.tween(titleText,{y: 1000}, 1.5, {ease: FlxEase.expoInOut, startDelay: 0.5});
				new FlxTimer().start(0.02, function(tmr:FlxTimer)
				{
					titleText.alpha -= 0.0075;
					if (titleText.alpha > 0)
					{
						tmr.reset(0.02);
					}
				});
	
				trace ('Closing Game...');
	
				var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
				black.scrollFactor.set();
				black.alpha = 0;
				add(black);
	
				FlxG.sound.play(Paths.sound('exitMenu' + weekAdderThingy), 1);
	
				new FlxTimer().start(0.04, function(tmr:FlxTimer)
				{
					if (FlxG.save.data.camzoom)
					{
						FlxG.camera.zoom -= 0.01;
					}
					FlxG.sound.music.stop();
					new FlxTimer().start(2.0, function(tmr:FlxTimer)
					{
						new FlxTimer().start(0.02, function(tmr:FlxTimer)
						{
							closeButton.alpha -= 0.0070;
							if (titleText.alpha > 0)
							{
								tmr.reset(0.02);
							}
						});
					});
					FlxG.camera.fade(FlxColor.BLACK, 6, false, function()
					{
						trace ('Goodbye');
						if (FlxG.save.data.showPresence)
						{
							DiscordRpc.shutdown();
						}
						System.exit(0);
					}, true);
				});

			default:
				skipIntro();
				FlxG.sound.play(Paths.sound('skipIntro'), 0.9);
		}
	}
}
