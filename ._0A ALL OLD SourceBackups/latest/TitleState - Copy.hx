package;

#if sys
import smTools.SMFile;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
//import flixel.addons.transition.FlxTransitionSprite.GraphicTransTiletransitionSprite;
import flixel.addons.transition.FlxTransitionableState;
//import flixel.addons.transition.TransitionData;
//import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.FlxCamera;
//import flixel.math.FlxPoint;
//import flixel.math.FlxRect;
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
	static var changedMenu:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ptSpr:FlxSprite;
	var jkSpr:FlxSprite;

	var curWacky:Array<String> = [];
	var chosenWacky:String;
	var allowChosenWacky:Bool = false;
	var wackyImage:FlxSprite;
	var wackyXtraText:FlxText;

	private var bruh:FlxSound;
	private var splat:FlxSound;
	private var sus:FlxSound;
	private var shid:FlxSound;
	private var vine:FlxSound;

	var logoAngleTween:FlxTween;
	var beatTimer:Float = 0;
	var closebuttonTween:FlxTween;
	var transitionTimer:FlxTimer;

	public static var weekAdderThingy:String = "";

	override public function create():Void
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Title Screen", null);
		#end

		//trace("Sound List MaxSize = " + FlxG.sound.list.maxSize);
		//Week dependent BgColours
		switch (FlxG.save.data.weekUnlocked)
		{
			case 1:
				bgColor = 0xFF000000;
				weekAdderThingy = "";
			case 2:
				bgColor = 0xFF120005;
				weekAdderThingy = "-glitchy";
			case 3:
				bgColor = 0xFF0b0d1d;
				weekAdderThingy = "-city";
			default:
				bgColor = 0xFF051c31;
		}

		if (!changedMenu)
		{
			#if polymod
			polymod.Polymod.init({modRoot: "mods", dirs: ['introMod']});
			#end
			
			#if sys
			if (!sys.FileSystem.exists(Sys.getCwd() + "/assets/temp"))
				sys.FileSystem.createDirectory(Sys.getCwd() + "/assets/temp");
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
		}

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
		if (!changedMenu)
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				startIntro();
			});
		else
			startNoIntro();
		#else
		if (!changedMenu)
			startIntro();
		else
			startNoIntro();
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
		trace ("Started Intro");
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
		logoBl.angle = -4;

		gfDance = new FlxSprite(FlxG.width * 0.3, FlxG.height * 0.08);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20], "", 28, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 0, 1, 2, 3, 4], "", 28, false);
		gfDance.animation.addByPrefix('disappear', "gfGone", 12, false);
		gfDance.animation.addByPrefix('confirm', "gfConfirm", 18, false);
		if(FlxG.save.data.antialiasing)
			{
				gfDance.antialiasing = true;
			}
		add(logoBl);
		add(gfDance);

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

		wackyXtraText = new FlxText (jkSpr.x, jkSpr.y, FlxG.width, "", 32);
		wackyXtraText.setFormat("Playtime With Hot Toddies", 32, FlxColor.fromRGB(255, 255, 255), CENTER);
		wackyXtraText.borderColor = FlxColor.fromRGB(0, 5, 25);
		wackyXtraText.borderSize = 3;
		wackyXtraText.borderStyle = FlxTextBorderStyle.OUTLINE;
		wackyXtraText.screenCenter();
		wackyXtraText.visible = false;
		if (FlxG.save.data.antialiasing)
		{
			wackyXtraText.antialiasing = true;
		}
		add(wackyXtraText);

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		//FlxG.mouse.visible = false;

		if (!initialized)
		{
			/*var transitionSprite:FlxGraphic = FlxGraphic.fromAssetKey(Paths.image('transition'));
			transitionSprite.persist = true;
			transitionSprite.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(TILES, FlxColor.BLACK, 0.5, new FlxPoint(0, 1), {asset: transitionSprite, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(TILES, FlxColor.BLACK, 0.5, new FlxPoint(0, 1),
				{asset: transitionSprite, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;*/

			initialized = true;

			if(Caching.cacheMusic.exists && Caching.cacheMusic.playing)
				Caching.cacheMusic.destroy();
			else if(Caching.disclaimerMusic.exists && Caching.disclaimerMusic.playing)
				Caching.disclaimerMusic.destroy();

			//Week dependent menu Music
			switch (FlxG.save.data.weekUnlocked)
			{
				case 1:
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.2);
					Conductor.changeBPM(102);
				case 2:
					FlxG.sound.playMusic(Paths.music('glitchyMenu'), 0.2);
					Conductor.changeBPM(102);
				case 3:
					FlxG.sound.playMusic(Paths.music('cityMenu'), 0.2);
					Conductor.changeBPM(102);
				default:
					FlxG.sound.playMusic(Paths.music('peacefulMenu'), 0.2);
					Conductor.changeBPM(102);
			}

			bruh = FlxG.sound.load(Paths.sound('intro_bruh'));
			splat = FlxG.sound.load(Paths.sound('intro_schplat'));
			sus = FlxG.sound.load(Paths.sound('intro_sus'));
			shid = FlxG.sound.load(Paths.sound('intro_shid'));
			vine = FlxG.sound.load(Paths.sound('intro_vine'));

			FlxG.sound.music.fadeIn(5, 0.2, 0.7);
			FlxG.camera.fade(FlxColor.BLACK, 0.5, true);
		}

		beatTimer = (Conductor.crochet / 1000) * 4 - 0.01;
	}

	function startNoIntro():Void
	{
		trace ("startted w/o intro");
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
		logoBl.angle = -4;

		gfDance = new FlxSprite(FlxG.width * 0.3, FlxG.height * 0.08);
		gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle');
		gfDance.animation.addByIndices('danceLeft', 'gfDance', [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20], "", 28, false);
		gfDance.animation.addByIndices('danceRight', 'gfDance', [21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 0, 1, 2, 3, 4], "", 28, false);
		gfDance.animation.addByPrefix('disappear', "gfGone", 12, false);
		gfDance.animation.addByPrefix('confirm', "gfConfirm", 18, false);
		if(FlxG.save.data.antialiasing)
			{
				gfDance.antialiasing = true;
			}
		add(logoBl);
		add(gfDance);

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

		//FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		//FlxG.mouse.visible = false;

		skipIntro();
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
	var doCamZooming:Bool = true;

	override function update(elapsed:Float)
	{
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

		if (pressedEnter && skippedIntro)
		{
			//Go to Main Menu
			pressedAnything(1);
		}
		else if(pressedBackspace && !transitioning && skippedIntro)
		{
			//Exit
			pressedAnything(2);
		}

		else if (pressedEnter && !skippedIntro && initialized)
		{
			//SkipIntro
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
		if (allowChosenWacky)
			chosenWacky = text;
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
			if (curBeat % 8 == 0)
				logoAngleTween = FlxTween.angle(logoBl, logoBl.angle, 4, beatTimer, {ease: FlxEase.quadInOut});
			if (curBeat % 8 == 4)
				logoAngleTween = FlxTween.angle(logoBl, logoBl.angle, -4, beatTimer, {ease: FlxEase.quadInOut});

			if (FlxG.save.data.camzoom && doCamZooming)
			{
				if (!skippedIntro && !changedMenu)
				{
					FlxG.camera.zoom += 0.01;
				}
				else
				{
					doCamZooming = false;
				}
			}
			danceLeft = !danceLeft;

			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}
		//FlxG.log.add(curBeat);

		if (!skippedIntro && !changedMenu)
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
					allowChosenWacky = true;
				case 11:
					addMoreText(curWacky[1]);
					doSpecialWacky();
				case 12:
					deleteCoolText();
					if (!doCamZooming)
						doCamZooming = true;
					wackyXtraText.visible = false;
					allowChosenWacky = false;
					bruh.volume = 0;
					splat.volume = 0;
					sus.volume = 0;
					shid.volume = 0;
					vine.volume = 0;
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

	function doSpecialWacky():Void
	{
		//AHM GETTIN' UPSET, JEREMY!!
		//you do not have any idea how much pain this has caused me
		//literally almost a scrapped feature bruih
		var wackySwitch:String = StringTools.trim(chosenWacky).toLowerCase();
		wackySwitch = StringTools.replace(wackySwitch, " ", "").toString();
		trace("Okay so " + chosenWacky + " is = " + wackySwitch);
		//trace(chosenWacky);
		//trace(wackySwitch);
		switch (wackySwitch)
		{
			case 'fightmemihoyo':
				wackyXtraText.text = '(For legal reasons, this is a joke!)';
				wackyXtraText.visible = true;
				FlxG.log.add('WackyText');
			case 'unfunny':
				wackyXtraText.text = '(PICO FUNNY!!!)';
				wackyXtraText.visible = true;
				FlxG.log.add('WackyText');
			case 'thefreepornwebsi':
				wackyXtraText.text = 'FBI OPEN UP!';
				wackyXtraText.visible = true;
				FlxG.log.add('WackyText');
			case 'pleasebecomefunny' | 'lmaoodeadchanneldead' | 'thedreamedwavechannel' | 'bruh' | 'bruuuhhh':
				bruh.volume = 0.5;
				bruh.play();
				FlxG.log.add('Bruh Sound');
			case 'theyarrive' | 'thecomezone' | 'youregonnacum':
				splat.volume = 0.3;
				splat.play();
				FlxG.log.add('Splat Sound');		
			case 'likeimposterfromamoger' | 'amongusjokes' | 'anentiregeneration' | 'susnotestoosus':
				sus.volume = 0.7;
				sus.play();
			case 'haha' | 'shitsaggressively' | 'bwap' | 'aggressiveshitting':
				doCamZooming = false;
				FlxG.camera.zoom -= 0.03;
				shid.volume = 0.5;
				shid.play();
				FlxG.log.add('BRAAPPP');
			case 'urmomhahagottem' | 'theymademeanegg' | 'afamily' | 'x':
				FlxG.camera.zoom += 0.015;
				vine.volume = 0.6;
				vine.play();
				FlxG.log.add('Vine Thud');
			default:
				FlxG.log.add('did the default do');
				trace("no wack");
		}
		trace("wackyFunction");
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{	
			if (!changedMenu)
			{
				jkSpr.destroy();
				ptSpr.destroy();
				wackyXtraText.destroy();
				credGroup.destroy();
			}

			if (FlxG.save.data.flashing && !changedMenu)
			{
				FlxG.camera.flash(FlxColor.WHITE, 4);
			}

			FlxTween.tween(logoBl,{y: -100}, 1.4, {ease: FlxEase.expoInOut});
			closebuttonTween = FlxTween.tween(closeButton,{y: 10}, 1.4, {ease: FlxEase.expoInOut});
			if (!transitioning)
				closebuttonTween = FlxTween.tween(closeButton,{alpha: 0.25}, 1, {ease: FlxEase.expoInOut, startDelay: 5});

			skippedIntro = true;
		}
	}

	function pressedAnything(pressedWhat:Int)
	{
		switch (pressedWhat)
		{
			case 1:
				if (!transitioning)
				{
					#if !switch
					NGio.unlockMedal(60960);
		
					// If it's Friday according to da clock
					if (Date.now().getDay() == 5)
						NGio.unlockMedal(61034);
					#end
		
					closebuttonTween.cancel();
					closeButton.alpha = 0.15;
					closebuttonTween = FlxTween.tween(closeButton,{y: -500}, 1.5, {ease: FlxEase.expoInOut, startDelay: 0.5});
		
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
					changedMenu = true;
		
					transitionTimer = new FlxTimer().start(1.76, function(tmr:FlxTimer)
					{
						FlxG.switchState(new MainMenuState());
					});
				}
				else
				{
					transitionTimer.active = false;
					FlxG.switchState(new MainMenuState());
				}

			case 2:
				transitioning = true;

				if (logoAngleTween != null)
					logoAngleTween.cancel();
				logoAngleTween = FlxTween.angle(logoBl, logoBl.angle, 0, 1, {ease: FlxEase.quadOut});
				closebuttonTween.cancel();
				closeButton.y = 10;
				closebuttonTween = FlxTween.tween(closeButton,{alpha: 1}, 0.15, {ease: FlxEase.cubeOut});
				closeButton.animation.play('press');
				gfDance.animation.play('disappear');
				FlxTween.tween(titleText,{y: 1000, alpha: 0}, 1.5, {ease: FlxEase.expoInOut, startDelay: 0.5});
	
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
						closebuttonTween = FlxTween.tween(closeButton, {alpha: 0}, 1, {ease: FlxEase.sineInOut, startDelay: 0.5});
						logoAngleTween = FlxTween.tween(logoBl, {y: -1000}, 1.4, {ease: FlxEase.expoInOut, startDelay: 1});
					});
					FlxG.camera.fade(FlxColor.BLACK, 6, false, function()
					{
						trace ('Goodbye');
						/*if (FlxG.save.data.showPresence)
						{
							DiscordRpc.shutdown();
						}*/
						System.exit(0);
					}, true);
				});

			default:
				skipIntro();
				FlxG.sound.play(Paths.sound('skipIntro'), 0.9);
		}
	}
}
