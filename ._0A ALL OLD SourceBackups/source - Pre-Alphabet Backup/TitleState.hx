package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.FlxCamera;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flash.system.System;
import lime.app.Application;
import openfl.Lib;

#if windows
import Discord.DiscordClient;
import discord_rpc.DiscordRpc;
#end

#if cpp
import sys.thread.Thread;
#end

using StringTools;

class TitleState extends MusicBeatMenu
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
	var wackyImage:FlxSprite;
	var wackyXtraText:FlxText;

	var logoTween:FlxTween;
	var beatTimer:Float = 0;
	var closeButtonTween:FlxTween;
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

		//to avoid that weird blendmode bug thing hhhh
		camUI = new FlxCamera();
		camLoad = new FlxCamera();

		camLoad.bgColor.alpha = 0;
		
		FlxG.cameras.reset(camUI);
		FlxG.cameras.add(camLoad);
		
		FlxCamera.defaultCameras = [camUI];

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
			closeButton.antialiasing = true;
		closeButton.animation.play('static');
		closeButton.updateHitbox();
		closeButton.alpha = 0.5;
		add(closeButton);

		var versionShit:FlxText = new FlxText(3, FlxG.height - 19, 0, "TMG " + Main.gameVer + (Main.watermarks ? " | KE 1.6" : ""), 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, 0xFFC5F5FF, LEFT, FlxTextBorderStyle.OUTLINE, 0xFF1E0045);
		versionShit.alpha = 0.3;
		versionShit.blend = ADD;
		add(versionShit);

		if (!changedMenu)
		{
			credGroup = new FlxGroup();
			add(credGroup);
			textGroup = new FlxGroup();
			textGroup.visible = false;

			blackScreen = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width*2, FlxG.height*2, bgColor);
			credGroup.add(blackScreen);

			#if sys
			if (!sys.FileSystem.exists(Sys.getCwd() + "/assets/temp"))
				sys.FileSystem.createDirectory(Sys.getCwd() + "/assets/temp");
			#end
			
			#if !cpp
			FlxG.save.bind('graduatin', 'dreamedwave');

			PlayerSettings.init();
			KadeEngineData.initSave();
			#end

			camUI.zoom = 1;
					
			Highscore.load();

			curWacky = FlxG.random.getObject(splitTextIntoArray(Paths.txt('data/introText')));

			trace('Hello There!');
		}

		FlxG.mouse.visible = true;
		
		super.create();

		beatTimer = (Conductor.crochet / 1000) * 4 - 0.01;
		FlxTween.tween(versionShit, {alpha: 0.5}, Conductor.crochet * 4 / 1000, {type: PINGPONG, ease: FlxEase.sineInOut});

		new FlxTimer().start(Conductor.crochet * 2 / 1000, function(tmr:FlxTimer)
		{
			doLogoTweening = true;
		});

		if (!changedMenu)
		{
			(cast (Lib.current.getChildAt(0), Main)).toggleFPS(FlxG.save.data.fps);
			startIntro();
		}
		else
			skipIntro();
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

		jkSpr = new FlxSprite(0, FlxG.height * 0.465).loadGraphic(Paths.image('joke_logo'));
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

		if (!initialized)
		{
			initialized = true;

			if(Caching.cacheMusic.exists && Caching.cacheMusic.playing)
				Caching.cacheMusic.destroy();
			else if(Caching.disclaimerMusic.exists && Caching.disclaimerMusic.playing)
				Caching.disclaimerMusic.destroy();

			//Week dependent menu Music
			switch (FlxG.save.data.weekUnlocked)
			{
				case 1:
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 0);
					Conductor.changeBPM(102);
				case 2:
					FlxG.sound.playMusic(Paths.music('glitchyMenu'), 0);
					Conductor.changeBPM(102);
				case 3:
					FlxG.sound.playMusic(Paths.music('cityMenu'), 0);
					Conductor.changeBPM(102);
				default:
					FlxG.sound.playMusic(Paths.music('villageMenu'), 0);
					Conductor.changeBPM(102);
			}

			FlxG.sound.music.fadeIn(5, 0.5, 0.65);
			camLoad.fade(FlxColor.BLACK, 0.8, true);
		}
	}

	var isHovering:Bool = false;

	override function update(elapsed:Float)
	{
		camUI.zoom = FlxMath.lerp(1, camUI.zoom, CoolUtil.boundTo(1 - (elapsed * 5), 0, 1));
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

		if ((pressedEnter || !FlxG.mouse.overlaps(closeButton) && FlxG.mouse.justPressed && !FlxG.mouse.justPressedRight && Main.isFocused) && !pressedBackspace && skippedIntro)
		{
			//Go to Main Menu
			pressedAnything(1);
		}
		else if((pressedBackspace || (FlxG.mouse.overlaps(closeButton) && FlxG.mouse.justPressed || FlxG.mouse.justPressedRight) && Main.isFocused) && !pressedEnter && !transitioning && skippedIntro)
		{
			//Exit
			pressedAnything(2);
		}
		else if ((pressedEnter || FlxG.mouse.justPressed && Main.isFocused) && !skippedIntro && initialized)
		{
			//SkipIntro
			pressedAnything(0);
		}

		if (!transitioning && !failSafeAugh && closeButton.y == 10)
		{
			//trace('doin your mom');
			if (FlxG.mouse.overlaps(closeButton) && Main.isFocused && !isHovering)
			{
				isHovering = true;
				if (closeButtonTween != null)
					closeButtonTween.cancel();
				closeButton.alpha = 0.4;
			}
			else if (isHovering)
			{
				isHovering = false;
				if (closeButtonTween != null)
					closeButtonTween.cancel();
				closeButtonTween = FlxTween.tween(closeButton,{alpha: 0.25}, 0.5, {type: ONESHOT, ease: FlxEase.expoOut, onComplete:
					function(twn:FlxTween) 
					{
						closeButtonTween = null;
					}
				});
			}
		}
	}

	var createdCoolText:Bool = false;

	function createCoolText(textArray:Array<String>)
	{
		deleteCoolText();
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
		createdCoolText = true;
		trace ('created Text (' + curBeat + "<- CurBeat)");
	}

	function addMoreText(text:String = '')
	{
		if (createdCoolText)
		{
			trace ('added More Text (' + curBeat + "<- CurBeat)");
			var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
			coolText.screenCenter(X);
			coolText.y += (textGroup.length * 60) + 200;
			credGroup.add(coolText);
			textGroup.add(coolText);
		}
	}

	function deleteCoolText()
	{
		if (textGroup.members.length > 0)
		{
			trace ('deleted Text (' + curBeat + "<- CurBeat)");
			createdCoolText = false;
			while (textGroup.members.length > 0)
			{
				credGroup.remove(textGroup.members[0], true);
				textGroup.remove(textGroup.members[0], true);
			}
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
					camUI.zoom += 0.01;
				}
				else if (doCamZooming)
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

		if (!skippedIntro && !changedMenu)
		{
			switch (curBeat)
			{
				case 0:
					if (Main.watermarks)
						jkSpr.visible = false;
					else
						ptSpr.visible = false;
				case 1:
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
				case 11:
					addMoreText(curWacky[1]);
					chosenWacky = curWacky[1];
					doSpecialWacky();
				case 12:
					if (FlxG.sound.music.volume >= 0)
						FlxG.sound.music.volume = 1;
					deleteCoolText();
					if (!doCamZooming)
						doCamZooming = true;
					wackyXtraText.visible = false;
				case 13:
					createCoolText(['Thursday']);
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
					wackyXtraText.text = '(yep!)';
				else
					wackyXtraText.text = "(bro wdym, it's a " + Main.curDayString + "-)";
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
			case 'men':
				wackyXtraText.text = 'I MEAN MEN- I- I MEAN- MEN- I MEAN-';
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
			case 'gethead':
				wackyXtraText.text = '...phones';
				wackyXtraText.visible = true;
				FlxG.log.add('WackyText');
			case 'slmclclveiwerr':
				wackyXtraText.text = '? ?!?!? !';
				wackyXtraText.visible = true;
				FlxG.log.add('WackyText');
			case 'ki kinda nic e yea':
				wackyXtraText.text = '(for no particular reason mhm yep)';
				wackyXtraText.visible = true;
				FlxG.log.add('WackyText');
			case 'hopeyouhavefuh':
				wackyXtraText.text = '!!!';
				wackyXtraText.visible = true;
				FlxG.log.add('WackyText');
			case 'pleasebecomefunny' | 'lmaoodeadchanneldead' | 'thedreamedwavechannel' | 'bruh' | 'bruuuhhh':
				FlxG.sound.play(Paths.sound('intro_bruh'), 0.55);
				FlxG.log.add('Bruh Sound');
			case 'theyarrive' | 'thecomezone' | 'youregonnacum' | 'broimcreaming':
				FlxG.sound.play(Paths.sound('intro_schplat'), 0.45);
				FlxG.log.add('Splat Sound');		
			case 'imposterfromamoger' | 'amongusjokes' | 'anentiregeneration' | 'theyweretoosus':
				FlxG.sound.play(Paths.sound('intro_sus'), 0.55);
			case 'haha' | 'shitsaggressively' | 'bwap' | 'aggressiveshitting' | 'goneinaninstant':
				doCamZooming = false;
				camUI.zoom -= 0.03;
				FlxG.sound.play(Paths.sound('intro_shid'), 0.55);
				FlxG.log.add('BRAAPPP');
			case 'urmomhahagottem' | 'theymademeanegg' | 'afamily' | 'x':
				camUI.zoom += 0.015;
				FlxG.sound.play(Paths.sound('intro_vine'), 0.6);
				FlxG.log.add('Vine Thud');
			case 'notsafe':
				FlxG.sound.music.volume = 0;
				FlxG.log.add('R U N');
			case 'ewrjoqjmovkvjwbtjmwmgkgkmxcmrm':
				var screamCounter:Int = 0;
				new FlxTimer().start(Conductor.stepCrochet / 2 / 1000, function(tmr:FlxTimer)
				{
					screamCounter++;
					switch(screamCounter)
					{
						case 1:
							addMoreText('owovmkwmomkomdkockosmcxkmoasko');
						case 3:
							addMoreText('mxkcmogregotyamogusgmoerjmorjb');
						case 4:
							addMoreText('rjkbfreddiwbnyoudidnthavetofuc');
						case 5:
							addMoreText('makitlikeitnevehappenenawewuno');
						case 6:
							addMoreText('mmdsmisimpforfaiththeycoolakdf');
						case 7:
							addMoreText('idkijustlikethemtheyrecuteands');
						case 8:
							addMoreText('hitskdgksgkkssssskskkksdksaaaa');
					}
				}, 8);
				FlxG.log.add('Fnaf Lore');
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

				camLoad.flash(DisclaimerScreen.flashColor, Conductor.crochet * 4 / 1000);
			}

			FlxTween.tween(logoBl,{y: -100}, 1.4, {ease: FlxEase.expoInOut});
			closeButtonTween = FlxTween.tween(closeButton,{y: 10}, 1.4, {type: ONESHOT, ease: FlxEase.expoInOut, onComplete:
				function(twn:FlxTween) 
				{
					closeButtonTween = null;
				}
			});

			if (!transitioning)
			{
				closeButtonTween = FlxTween.tween(closeButton,{alpha: 0.25}, 1, {type: ONESHOT, ease: FlxEase.expoInOut, startDelay: 5, onComplete:
					function(twn:FlxTween) 
					{
						closeButtonTween = null;
					}
				});
			}

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
		
					if (closeButtonTween != null)
						closeButtonTween.cancel();
					if(!closeButton.isOnScreen(FlxG.cameras.list[0]))
					{
						closeButton.alpha = 0;
						closeButton.active = false;
					}
					else
					{
						closeButton.alpha = 0.15;
						if (closeButtonTween != null)
							closeButtonTween.cancel();
						closeButtonTween = FlxTween.tween(closeButton,{y: -500}, 1.5, {type: ONESHOT, ease: FlxEase.expoInOut, startDelay: 0.5, onComplete:
							function(twn:FlxTween) 
							{
								closeButtonTween = null;
							}
						});
					}

					if (FlxG.save.data.flashing)
					{
						camLoad.stopFX('flash');
						camLoad.flash(DisclaimerScreen.flashColor, 1);
						titleText.animation.play('press');
					}
					else
						titleText.animation.play('press-static');
		
					if (FlxG.save.data.camzoom)
					{
						camUI.zoom += 0.02;
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
				if (doLogoTweening && logoTween != null)
					logoTween.cancel();
				logoBl.angle = 0;
				logoBl.animation.play('bump', true);
				closeButton.animation.play('press');
				menuEyeCandy.animation.play('disappear');
				titleText.alpha = 0.25;
				titleText.animation.play('press-static');
				FlxTween.tween(titleText,{y: 720, alpha: 0}, 0.25, {type: ONESHOT, ease: FlxEase.expoInOut});
	
				trace ('Closing Game...');
	
				var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.BLACK);
				black.scrollFactor.set();
				black.alpha = 0;
				add(black);
	
				FlxG.sound.play(Paths.sound('exitMenu' + weekAdderThingy), 1);
	
				if (closeButtonTween != null)
					closeButtonTween.cancel();
				closeButton.y = 10;
				
				new FlxTimer().start(0.04, function(tmr:FlxTimer)
				{
					closeButton.alpha = 1;
					if (FlxG.save.data.camzoom)
					{
						camUI.zoom -= 0.01;
					}
					FlxG.sound.music.stop();
					new FlxTimer().start(2, function(tmr:FlxTimer)
					{
						closeButtonTween = FlxTween.tween(closeButton, {alpha: 0}, 1, {type: ONESHOT, ease: FlxEase.sineInOut, startDelay: 0.5});
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							logoTween = FlxTween.tween(logoBl, {y: -1000}, 1.4, {type: ONESHOT, ease: FlxEase.expoInOut});
						});
					});
					camLoad.fade(FlxColor.BLACK, 5, false, function()
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
