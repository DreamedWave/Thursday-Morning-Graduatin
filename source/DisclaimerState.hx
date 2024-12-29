package;

import flixel.*;
//import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import openfl.Lib;

class DisclaimerState extends MusicBeatMenu
{
	public static var leftState:Bool = false;
	public static var wentOptions:Bool = false;
	public static var flashColor:FlxColor = FlxColor.WHITE;

	var txt:FlxText;

	override function create()
	{
		persistentUpdate = true;
		FlxG.camera.fade(FlxColor.BLACK, 0.8, true);

		flashColor = !Main.nightMode && !FlxG.save.data.nightmode ? flashColor : 0xFFA5909C;

		super.create();

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('DisclaimerScreen', 'preload'));
		bg.scale.x *= 1;
		bg.scale.y *= 1;
		bg.alpha = 0;
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);
		
		var kadeLogo:FlxSprite = new FlxSprite(FlxG.width, 0).loadGraphic(Paths.image('KadeEngineLogo'));
		kadeLogo.scale.y = 0.3;
		kadeLogo.scale.x = 0.3;
		kadeLogo.x -= kadeLogo.frameHeight;
		kadeLogo.y -= 500;
		kadeLogo.alpha = 0.8;
		kadeLogo.antialiasing = true;
		add(kadeLogo);
		
		txt = new FlxText(0, 0, FlxG.width,
			"DISCLAIMER!\n"
			+ "\nThis mod was originally created for close friends and was"
			+ "\nnot meant to be shared publically. But this build was made for sharing"
			+ "\nand was edited to comply with the DATA PRIVACY ACT OF 2012 [R.A. 10173]"
			+ "\nbecause this used images of people that were not informed that their"
			+ "\nlikeness was used in such way. (which was fine for a silly joke within,"
			+ "\na friend group but not for something shared outside of said group). Any"
			+ "\npart of the people within said images' personal lives are not included in"
			+ "\nthis mod and it's story. The characters in this should be treated as"
			+ "\ncompletely separate from them. This is purely made in the name of GOOD FUN."
			+ "\nNow with that out of the way..."
			+ "\n\nPress [ENTER/SPACE] to continue (or [ESC] to open settings)",
			32);
		
		txt.setFormat("Century Gothic", 32, FlxColor.fromRGB(255, 255, 255), CENTER);
		txt.borderColor = FlxColor.fromRGB(0, 5, 25);
		txt.borderSize = 3;
		txt.borderStyle = FlxTextBorderStyle.OUTLINE;
		txt.antialiasing = true;
		txt.screenCenter();
		add(txt);
		
		FlxTween.tween(kadeLogo,{y: -180}, 1.4, {type: ONESHOT, ease: FlxEase.expoInOut});

		kadeLogo.angle = 6;

		new FlxTimer().start(0.0125, function(tmr:FlxTimer)
		{
			bg.alpha += 0.025;
			if (bg.alpha < 1)
			{
				tmr.reset(0.0125);
			}
			else
			{
				trace('Faded In');
			}
		});

		new FlxTimer().start(0.01, function(tmr:FlxTimer)
			{
				if(kadeLogo.angle == -6) 
					FlxTween.angle(kadeLogo, kadeLogo.angle, 6, 6, {type: ONESHOT, ease: FlxEase.quartInOut});
				if (kadeLogo.angle == 6) 
					FlxTween.angle(kadeLogo, kadeLogo.angle, -6, 6, {type: ONESHOT, ease: FlxEase.quartInOut});
			}, 0);

		super.create();

		FlxTransitionableState.skipNextTransOut = true;
		#if windows
		if (FlxG.save.data.showPresence)
			DiscordClient.changePresence("[Awaiting Input]", null, "apppresence-loading");
		#end
	}

	var spedran:Bool = false;
	var exitSound:FlxSound;
	
	function exitDisclaimerState():Void
	{
		#if windows
		if (FlxG.save.data.showPresence)
			DiscordClient.changePresence("[Have fun!]", null, "apppresence-loading");
		#end

		if (!wentOptions)
		{
			FlxTransitionableState.skipNextTransIn = true;
			if ((FlxG.save.data.weekUnlocked > 1 && FlxG.random.bool(1)) || Main.aprilFools)
			{
				remove(txt);
				txt = new FlxText(0, 0, FlxG.width,
					"Lazada!\n"
					+ "\nThis mod is not on sale on Lazada nor sponsored by Lazada but it is"
					+ "\nfunny so i'll keep saying teh funny wor d  haha  lazada lazada lazagner"
					+ "\nla-NeverShare this AT ALL COSTS for it might break DATA PRIVACY ACT OF"
					+ "\n2012 [R.A. 10173] I SWEAR TO GOD- ok anyways, lazadar lasusser, lazadada"
					+ "\nlacaca lazbaba lazboba lazdapa lazaza, lazala, lamama lazmada lazara lalala"
					+ "\nbut not for a publically available LazadaLazadaLazadaL' Mod). The"
					+ "\nLazadas of the people in the Lazada used does not have any"
					+ "\nthing to do with Shoppee itself, and should be treated as Lazanga"
					+ "\ncompletely separate. This is purely made in. China. NOT FIVENIGTSNAFAITM."
					+ "\nNow with that out of the way..."
					+ "\n\nPress [ENTER/SPACE] to Lazada (or [ESC] to open Shopee)",
					32);
				txt.setFormat("Century Gothic", 32, FlxColor.fromRGB(255, 255, 255), CENTER);
				txt.borderColor = FlxColor.fromRGB(0, 5, 25);
				txt.borderSize = 3;
				txt.borderStyle = FlxTextBorderStyle.OUTLINE;
				txt.alpha = 1;
				txt.antialiasing = true;
				txt.screenCenter();
				add(txt);
				exitSound = FlxG.sound.load(Paths.music('preMusic-disclaimer_LAZAZA'));
			}
			else
				exitSound = FlxG.sound.load(Paths.music('preMusic-disclaimer_ENTER'));
			exitSound.play(true);
			exitSound.persist = true;
			exitSound.autoDestroy = true;

			new FlxTimer().start(0.04, function(tmr:FlxTimer)
			{
				CachingState.disclaimerMusic.volume = 0;
				canSpeedrun = true;
				FlxG.camera.fade(flashColor, 4, false, function()
				{
					FlxG.camera.alpha = 0;
					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						if (!spedran)
						{
							#if windows
							if (FlxG.save.data.showPresence)
								DiscordClient.changePresence("", null, 'apppresence-dark');
							#end
							FlxG.switchState(new TitleState());
						}
					});
				}, true);
			});
		}
		else
		{
			exitSound = FlxG.sound.load(Paths.music('preMusic-disclaimer_ESCAPE'));
			exitSound.play(true);
			exitSound.persist = true;
			exitSound.autoDestroy = true;
			
			new FlxTimer().start(0.04, function(tmr:FlxTimer)
			{
				CachingState.disclaimerMusic.volume = 0;
				canSpeedrun = true;
				FlxG.camera.fade(FlxColor.BLACK, 4, false, function()
				{
					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						(cast (Lib.current.getChildAt(0), Main)).toggleFPS(FlxG.save.data.fps);
						if (!spedran)
						{
							FlxG.switchState(new OptionsMenu());
							#if windows
							if (FlxG.save.data.showPresence)
								DiscordClient.changePresence("", null, 'apppresence-dark');
							#end
						}
					});
				}, true);
			});
		}
	}

	function speedrunSkip():Void
	{
		FlxG.camera.alpha = 0;
		if(CachingState.cacheMusic.exists && CachingState.cacheMusic.playing)
			CachingState.cacheMusic.stop();
		if(CachingState.disclaimerMusic.exists && CachingState.disclaimerMusic.playing)
		{
			CachingState.disclaimerMusic.stop();
			CachingState.disclaimerMusic.persist = false;
		}

		exitSound.stop();
		exitSound = FlxG.sound.load(Paths.music('preMusic-disclaimer_SKIP'), 0.8);
		exitSound.play(true);
		exitSound.persist = true;
		exitSound.autoDestroy = true;

		//Role Exit Prevention
		new FlxTimer().start(0.1, function(tmr:FlxTimer)
		{
			#if windows
			if (FlxG.save.data.showPresence)
				DiscordClient.changePresence("", null, 'apppresence-dark');
			#end
			if (!wentOptions)
				FlxG.switchState(new TitleState());
			else
				FlxG.switchState(new OptionsMenu());
		});
	}

	var canSpeedrun:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if ((controls.ACCEPT || FlxG.mouse.justPressed) && !leftState)
		{
			leftState = true;
			exitDisclaimerState();
		}
		else if ((controls.BACK || FlxG.mouse.justPressedRight) && !leftState)
		{
			leftState = true;
			wentOptions = true;
			exitDisclaimerState();
		}
		else if ((controls.ACCEPT || controls.BACK || FlxG.mouse.justPressed || FlxG.mouse.justPressedRight) && leftState && !spedran && canSpeedrun)
		{
			spedran = true;
			speedrunSkip();
		}
	}
}
