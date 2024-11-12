package;

/*#if sys
import smTools.SMFile;
#end*/
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
//import flixel.addons.transition.FlxTransitionSprite.GraphicTransTiletransitionSprite;
//import flixel.addons.transition.FlxTransitionableState;
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
	var textGroup:FlxGroup;
	var ptSpr:FlxSprite;
	var jkSpr:FlxSprite;

	var curWacky:Array<String> = [];
	var chosenWacky:String;
	var allowChosenWacky:Bool = false;
	var wackyImage:FlxSprite;
	var wackyXtraText:FlxText;

	var logoTween:FlxTween;
	var beatTimer:Float = 0;
	var closebuttonTween:FlxTween;
	var transitionTimer:FlxTimer;
	
	var logoBl:FlxSprite;
	var menuEyeCandy:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var closeButton:FlxSprite;
	
	var transitioning:Bool = false;
	var failSafeAugh:Bool = false;
	var doCamZooming:Bool = true;
	var skippedIntro:Bool = false;

	public static var weekAdderThingy:String = "";

	override public function create()
	{
		Paths.clearStoredMemory();
		Paths.clearUnusedMemory();

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

		persistentUpdate = true;
		persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('titleBG'));
		bg.antialiasing = true;
		bg.updateHitbox();
		add(bg);

		if (Main.watermarks) 
		{
			logoBl = new FlxSprite(-145, 1500);
			logoBl.frames = Paths.getSparrowAtlas('KadeEngineLogoBumpin');
		} else 
		{
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

		menuEyeCandy = new FlxSprite(FlxG.width * 0.3, FlxG.height * 0.08);
		menuEyeCandy.frames = Paths.getSparrowAtlas('menuMetronomeTitle');
		menuEyeCandy.animation.addByIndices('danceLeft', 'gfDance', [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20], "", 28, false);
		menuEyeCandy.animation.addByIndices('danceRight', 'gfDance', [21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 0, 1, 2, 3, 4], "", 28, false);
		menuEyeCandy.animation.addByPrefix('disappear', "gfGone", 12, false);
		menuEyeCandy.animation.addByPrefix('confirm', "gfConfirm", 18, false);
		if(FlxG.save.data.antialiasing)
			menuEyeCandy.antialiasing = true;
		add(logoBl);
		add(menuEyeCandy);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.animation.addByPrefix('press-static', "ENTER PRESSED STATIC", 24);
		if(FlxG.save.data.antialiasing)
			titleText.antialiasing = true;
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

		if (!changedMenu)
		{
			credGroup = new FlxGroup();
			add(credGroup);
			textGroup = new FlxGroup();

			blackScreen = new FlxSprite(-FlxG.width/2, -FlxG.height/2).makeGraphic(FlxG.width*2, FlxG.height*2, bgColor);
			credGroup.add(blackScreen);
		}

		if (!changedMenu)
		{
			#if sys
			if (!sys.FileSystem.exists(Sys.getCwd() + "/assets/temp"))
				sys.FileSystem.createDirectory(Sys.getCwd() + "/assets/temp");
			#end
			
			#if !cpp
			FlxG.save.bind('graduatin', 'dreamedwave');

			PlayerSettings.init();

			KadeEngineData.initSave();
			#end

			FlxG.camera.zoom = 1;
					
			Highscore.load();

			curWacky = FlxG.random.getObject(getIntroTextShit());

			trace('Hello There!');
		}

		FlxG.mouse.visible = true;
		
		super.create();

		beatTimer = (Conductor.crochet / 1000) * 4 - 0.01;

		new FlxTimer().start(Conductor.crochet * 2 / 1000, function(tmr:FlxTimer)
		{
			doLogoTweening = true;
		});

		#if !cpp
		if (!changedMenu)
		{
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				startIntro();
			});
		}
		else
			skipIntro();
		#else
		if (!changedMenu)
			startIntro();
		else
			skipIntro();
		#end
	}

	function startIntro()
	{
		ptSpr = new FlxSprite(0, FlxG.height * 0.51).loadGraphic(Paths.image('point_logo'));
		ptSpr.setGraphicSize(Std.int(ptSpr.width * 0.8));
		ptSpr.updateHitbox();
		ptSpr.screenCenter(X);
		ptSpr.y -= 10;
		if(FlxG.save.data.antialiasing)
			ptSpr.antialiasing = true;
		add(ptSpr);
		ptSpr.visible = false;

		jkSpr = new FlxSprite(0, FlxG.height * 0.475).loadGraphic(Paths.image('joke_logo'));
		jkSpr.setGraphicSize(Std.int(jkSpr.width * 0.9));
		jkSpr.updateHitbox();
		jkSpr.screenCenter(X);
		jkSpr.y -= 10;
		if(FlxG.save.data.antialiasing)
			jkSpr.antialiasing = true;
		jkSpr.visible = false;
		add(jkSpr);

		wackyXtraText = new FlxText (jkSpr.x, FlxG.height * 0.51, FlxG.width, "", 32);
		wackyXtraText.setFormat("Playtime With Hot Toddies", 32, FlxColor.fromRGB(255, 255, 255), CENTER);
		wackyXtraText.borderColor = FlxColor.fromRGB(0, 5, 25);
		wackyXtraText.borderSize = 3;
		wackyXtraText.borderStyle = FlxTextBorderStyle.OUTLINE;
		wackyXtraText.screenCenter();
		if (FlxG.save.data.antialiasing)
			wackyXtraText.antialiasing = true;
		wackyXtraText.visible = false;
		add(wackyXtraText);

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
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0.5);
					Conductor.changeBPM(102);
				case 2:
					FlxG.sound.playMusic(Paths.music('glitchyMenu'), 0.5);
					Conductor.changeBPM(102);
				case 3:
					FlxG.sound.playMusic(Paths.music('cityMenu'), 0.5);
					Conductor.changeBPM(102);
				default:
					FlxG.sound.playMusic(Paths.music('peacefulMenu'), 0.5);
					Conductor.changeBPM(102);
			}

			FlxG.sound.music.fadeIn(5, 0.5, 0.65);
			FlxG.camera.fade(FlxColor.BLACK, 0.8, true);
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

	override function update(elapsed:Float)
	{
		FlxG.camera.zoom = FlxMath.lerp(1, FlxG.camera.zoom, CoolUtil.boundTo(1 - (elapsed * 5), 0, 1));
		if (FlxG.sound.music.volume < 0.65 && changedMenu)
			FlxG.sound.music.volume = 0.65;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		var pressedEnter:Bool = controls.ACCEPT;
		var pressedBackspace:Bool = controls.BACK;

		super.update(elapsed);

		if (curBeat != 8 && !skippedIntro)
			ptSpr.visible = false;

		if (pressedEnter && !pressedBackspace && skippedIntro)
		{
			//Go to Main Menu
			pressedAnything(1);
		}
		else if(pressedBackspace && !pressedEnter && !transitioning && skippedIntro)
		{
			//Exit
			pressedAnything(2);
		}
		else if (pressedEnter && !skippedIntro && initialized)
		{
			//SkipIntro
			pressedAnything(0);
		}

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

	var doLogoTweening:Bool = false;
	
	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump', true);
		if (!transitioning)
		{
			if (doLogoTweening)
			{
				if (curBeat % 8 == 0)
					logoTween = FlxTween.angle(logoBl, logoBl.angle, 4, beatTimer, {type: ONESHOT, ease: FlxEase.quadInOut});
				if (curBeat % 8 == 4)
					logoTween = FlxTween.angle(logoBl, logoBl.angle, -4, beatTimer, {type: ONESHOT, ease: FlxEase.quadInOut});
			}

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
				menuEyeCandy.animation.play('danceRight');
			else
				menuEyeCandy.animation.play('danceLeft');
		}
		//FlxG.log.add(curBeat);

		if (!skippedIntro && !changedMenu)
		{
			switch (curBeat)
			{
				case 0 | 1:
					if (Main.watermarks)
						jkSpr.visible = false;
					else
						ptSpr.visible = false;
					deleteCoolText();
					createCoolText(["The FUNKIN' crew", 'KadeDev', 'and DreamedWave']);
				case 3:
					addMoreText('present');
				case 4:
					deleteCoolText();
				case 5:
					if (Main.watermarks)
						createCoolText(['A thing caused by']);
					else
						createCoolText(['With special thanks ', 'to']);
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
					if (Main.watermarks)
						jkSpr.visible = false;
					else
						ptSpr.visible = false;
				case 9:
					createCoolText([curWacky[0]]);
					allowChosenWacky = true;

				case 11:
					addMoreText(curWacky[1]);
					doSpecialWacky();
				case 12:
					if (FlxG.sound.music.volume >= 0)
						FlxG.sound.music.volume = 1;
					deleteCoolText();
					if (!doCamZooming)
						doCamZooming = true;
					wackyXtraText.visible = false;
					allowChosenWacky = false;
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
		//trace("Okay so " + chosenWacky + " is = " + wackySwitch);
		//trace(chosenWacky);
		//trace(wackySwitch);
		switch (wackySwitch)
		{
			case 'suckmydick' | 'fuckittohell':
				wackyXtraText.text = '(not in a sex way)';
				wackyXtraText.visible = true;
				FlxG.log.add('WackyText');
			case 'idunno':
				wackyXtraText.text = '(oh actually today is a ' + Main.curDayString + "!!)";
				wackyXtraText.visible = true;
				FlxG.log.add('WackyText');
			case 'asunday' | 'amonday' | 'wereturntoclass':
				if (Main.curDayString == 'Sunday')
					wackyXtraText.text = '(yep)';
				else
					wackyXtraText.text = '(no it is not-)';
				wackyXtraText.visible = true;
				FlxG.log.add('WackyText');
			case 'wasnow1am':
				if(Main.curHourString == "1 AM")
					wackyXtraText.text = '(you should go to sleep-)';
				else
					wackyXtraText.text = '(bro it is literally ' + Main.curHourString + '-)';
				wackyXtraText.visible = true;
				FlxG.log.add('WackyText');
			case 'lets gooooooo' | 'thatwasayearago' | 'aaaaaaaaaa' | 'orelseillscream':
				wackyXtraText.text = '(AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA)';
				wackyXtraText.visible = true;
				FlxG.log.add('WackyText');
			case 'buyassetsforkidney':
				wackyXtraText.text = 'EA moment';
				wackyXtraText.visible = true;
				FlxG.log.add('WackyText');
			case 'ayearago':
				wackyXtraText.text = 'holy shit wow--';
				wackyXtraText.visible = true;
				FlxG.log.add('WackyText');
			case 'willbeeasy' | 'nahimjustkidding':
				wackyXtraText.text = 'probably...';
				wackyXtraText.visible = true;
				FlxG.log.add('WackyText');
			case 'superiorcarcolour':
				wackyXtraText.text = 'I MEAN CAR COLOUR. NOTHING ELSE.';
				wackyXtraText.visible = true;
				FlxG.log.add('WackyText');
			case 'fightmemihoyo' | 'theschool' | 'twodosesoflean':
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
				FlxG.sound.play(Paths.sound('intro_bruh'), 0.55);
				FlxG.log.add('Bruh Sound');
			case 'theyarrive' | 'thecomezone' | 'youregonnacum' | 'broimcreaming':
				FlxG.sound.play(Paths.sound('intro_schplat'), 0.45);
				FlxG.log.add('Splat Sound');		
			case 'imposterfromamoger' | 'amongusjokes' | 'anentiregeneration' | 'theyweretoosus':
				FlxG.sound.play(Paths.sound('intro_sus'), 0.75);
			case 'haha' | 'shitsaggressively' | 'bwap' | 'aggressiveshitting' | 'goneinaninstant':
				doCamZooming = false;
				FlxG.camera.zoom -= 0.03;
				FlxG.sound.play(Paths.sound('intro_shid'), 0.55);
				FlxG.log.add('BRAAPPP');
			case 'urmomhahagottem' | 'theymademeanegg' | 'afamily' | 'x':
				FlxG.camera.zoom += 0.015;
				FlxG.sound.play(Paths.sound('intro_vine'), 0.7);
				FlxG.log.add('Vine Thud');
			case 'notsafe':
				FlxG.sound.music.volume = 0;
			default:
				FlxG.log.add('did the default do');
				trace("no wack");
		}
		trace("wackyFunction");
	}

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

				FlxG.camera.flash(DisclaimerScreen.flashColor, Conductor.crochet * 4 / 1000);
			}

			FlxTween.tween(logoBl,{y: -100}, 1.4, {ease: FlxEase.expoInOut});
			closebuttonTween = FlxTween.tween(closeButton,{y: 10}, 1.4, {type: ONESHOT, ease: FlxEase.expoInOut});
			if (!transitioning)
				closebuttonTween = FlxTween.tween(closeButton,{alpha: 0.25}, 1, {type: ONESHOT, ease: FlxEase.expoInOut, startDelay: 5});

			skippedIntro = true;
		}
	}

	function pressedAnything(pressedWhat:Int)
	{
		switch (pressedWhat)
		{
			case 1:
				if (!transitioning && !failSafeAugh)
				{
					//this is dummy code, achievements are not confirmed for TMG
					//if (Main.curDayString == 'Thursday') doAchienvementshit()
		
					if (closebuttonTween.active)
						closebuttonTween.cancel();
					if(!closeButton.isOnScreen(FlxG.cameras.list[0]))
					{
						closeButton.alpha = 0;
						closeButton.active = false;
					}
					else
					{
						closeButton.alpha = 0.15;
						closebuttonTween = FlxTween.tween(closeButton,{y: -500}, 1.5, {type: ONESHOT, ease: FlxEase.expoInOut, startDelay: 0.5});
					}

					if (FlxG.save.data.flashing)
					{
						FlxG.camera.stopFX('flash');
						FlxG.camera.flash(DisclaimerScreen.flashColor, 1);
						titleText.animation.play('press');
					}
					else
						titleText.animation.play('press-static');
		
					if (FlxG.save.data.camzoom)
					{
						FlxG.camera.zoom += 0.02;
					}
		
					menuEyeCandy.animation.play('confirm');
					FlxG.sound.play(Paths.sound('confirmMenu' + weekAdderThingy), 0.7);
		
					transitioning = true;
					changedMenu = true;
		
					transitionTimer = new FlxTimer().start(1.76, function(tmr:FlxTimer)
					{
						Main.updateTimeStuffs();
						FlxG.switchState(new MainMenuState());
					});
				}
				else
				{
					if (!failSafeAugh)
					{
						transitionTimer.active = false;
						Main.updateTimeStuffs();
						FlxG.switchState(new MainMenuState());
					}
				}

			case 2:
				failSafeAugh = true;
				transitioning = true;
				closeButton.y = 10;
				if (doLogoTweening && logoTween.active)
					logoTween.cancel();
				logoBl.angle = 0;
				logoBl.animation.play('bump', true);
				closeButton.animation.play('press');
				menuEyeCandy.animation.play('disappear');
				titleText.visible = false;
				//FlxTween.tween(titleText,{y: 1000, alpha: 0}, 1.5, {type: ONESHOT, ease: FlxEase.expoInOut, startDelay: 0.5});
	
				trace ('Closing Game...');
	
				var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.BLACK);
				black.scrollFactor.set();
				black.alpha = 0;
				add(black);
	
				FlxG.sound.play(Paths.sound('exitMenu' + weekAdderThingy), 1);
	
				if (closebuttonTween.active) //CJANGE THIS SHIT TO THE ONE PLAYSYAYE HAS (oncomplete: tween = null)
					closebuttonTween.cancel();
				closeButton.y = 10;
				
				new FlxTimer().start(0.04, function(tmr:FlxTimer)
				{
					closeButton.alpha = 1;
					if (FlxG.save.data.camzoom)
					{
						FlxG.camera.zoom -= 0.01;
					}
					FlxG.sound.music.stop();
					new FlxTimer().start(2, function(tmr:FlxTimer)
					{
						closebuttonTween = FlxTween.tween(closeButton, {alpha: 0}, 1, {type: ONESHOT, ease: FlxEase.sineInOut, startDelay: 0.5});
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							logoTween = FlxTween.tween(logoBl, {y: -1000}, 1.4, {type: ONESHOT, ease: FlxEase.expoInOut});
						});
					});
					FlxG.camera.fade(FlxColor.BLACK, 5, false, function()
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
