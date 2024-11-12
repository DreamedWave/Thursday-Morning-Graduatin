package;

import flixel.*;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.app.Application;
import flixel.addons.transition.FlxTransitionableState;
//import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

class DisclaimerScreen extends MusicBeatState
{
	public static var leftState:Bool = false;
	public static var wentOptions:Bool = false;

	var txt:FlxText;

	override function create()
	{
		/*if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('disclaimerScreen'));
		}*/

		FlxG.camera.fade(FlxColor.BLACK, 0.8, true);

		super.create();
		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('DisclaimerScreen', 'preload'));
		bg.scale.x *= 1;
		bg.scale.y *= 1;
		bg.alpha = 0;
		bg.screenCenter();
		if(FlxG.save.data.antialiasing)
			{
				bg.antialiasing = true;
			}
		add(bg);
		
		var kadeLogo:FlxSprite = new FlxSprite(FlxG.width, 0).loadGraphic(Paths.image('KadeEngineLogo'));
		kadeLogo.scale.y = 0.3;
		kadeLogo.scale.x = 0.3;
		kadeLogo.x -= kadeLogo.frameHeight;
		kadeLogo.y -= 500;
		kadeLogo.alpha = 0.8;
		if(FlxG.save.data.antialiasing)
			{
				kadeLogo.antialiasing = true;
			}
		add(kadeLogo);
		
		txt = new FlxText(0, 0, FlxG.width,
			"DISCLAIMER!"
			+ "\nThis mod is originally created for close friends only and is"
			+ "\nnot meant to be shared publically. Please refrain from publishing"
			+ "\nor sharing this AT ALL COSTS for it might break DATA PRIVACY ACT OF"
			+ "\n2012 [R.A. 10173] because this uses images of people without their"
			+ "\nproper consent (which is fine for a silly joke within a closed group,"
			+ "\nbut not for a publically available Friday Night Funkin' Mod). The"
			+ "\nidentities of the people in the images used does not have any"
			+ "\nthing to do with the mod itself, and should be treated as something"
			+ "\ncompletely separate. This is purely made in the name of GOOD FUN."
			+ "\nNow with that out of the way..."
			+ "\n\nPress ENTER/SPACE to continue (or ESC to open settings/remove flashy lights)",
			32);
		
		txt.setFormat("Century Gothic", 32, FlxColor.fromRGB(255, 255, 255), CENTER);
		txt.borderColor = FlxColor.fromRGB(0, 5, 25);
		txt.borderSize = 3;
		txt.borderStyle = FlxTextBorderStyle.OUTLINE;
		txt.screenCenter();
		add(txt);
		
		FlxTween.tween(kadeLogo,{y: -180}, 1.4, {ease: FlxEase.expoInOut});

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
					FlxTween.angle(kadeLogo, kadeLogo.angle, 6, 6, {ease: FlxEase.quartInOut});
				if (kadeLogo.angle == 6) 
					FlxTween.angle(kadeLogo, kadeLogo.angle, -6, 6, {ease: FlxEase.quartInOut});
			}, 0);

		super.create();

		//Moved from titlestate
		var transitionSprite:FlxGraphic = FlxGraphic.fromAssetKey(Paths.image('transition'));
		//var transitionSprite:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
		transitionSprite.persist = true;
		transitionSprite.destroyOnNoUse = false;
		//var transitionInSprite:FlxGraphic = FlxGraphic.fromAssetKey(Paths.image('transitionIn'));
		//var transitionOutSprite:FlxGraphic = FlxGraphic.fromAssetKey(Paths.image('transitionOut'));
		//transitionInSprite.persist = true;
		//transitionOutSprite.persist = true;
		//transitionInSprite.destroyOnNoUse = false;
		//transitionOutSprite.destroyOnNoUse = false;

		#if !debug
		FlxTransitionableState.defaultTransIn = new TransitionData(TILES, FlxColor.BLACK, 0.5, new FlxPoint(-0.5, -1), {asset: transitionSprite, width: 32, height: 32}, 
			new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));
		FlxTransitionableState.defaultTransOut = new TransitionData(TILES, FlxColor.BLACK, 0.5, new FlxPoint(-0.5, -1),
			{asset: transitionSprite, width: 32, height: 32}, new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));
		#else
		FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 0.5, new FlxPoint(0, -1), {asset: transitionSprite, width: 32, height: 32}, 
		new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));
		FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.5, new FlxPoint(0, 1),
		{asset: transitionSprite, width: 32, height: 32}, new FlxRect(-300, -300, FlxG.width * 1.8, FlxG.height * 1.8));
		#end	

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		FlxTransitionableState.skipNextTransOut = true;
	}

	var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
	
	function exitDisclaimerState():Void
	{
		black.scrollFactor.set();
		if (!wentOptions)
		{
			FlxTransitionableState.skipNextTransIn = true;
			if (FlxG.random.bool(1) && FlxG.save.data.weekUnlocked > 2)
			{
				trace('HAHA FUNN Y');
				FlxG.sound.play(Paths.sound('disclaimerClickFlashLaz'));
				remove(txt);
				txt = new FlxText(0, 0, FlxG.width,
					"Lazada!"
					+ "\nThis mod is not on sale on Lazada nor sponsored by Lazada but it is"
					+ "\nfunny so i'll keep saying teh funny wor d  haha  lazada lazada lazagner"
					+ "\nlanevershare this AT ALL COSTS for it might break DATA PRIVACY ACT OF"
					+ "\n2012 [R.A. 10173] anyyways, lazadar lasudder lasusser, lazada lazadada"
					+ "\nlacaca lazbaba lazboba lazdapa laza la, lazad, lazada lazada lazada lala"
					+ "\nbut not for a publically available LazadaLazadaLazadaL' Mod). The"
					+ "\nLazadas of the people in the Lazada used does not have any"
					+ "\nthing to do with Shoppee itself, and should be treated as Lazanga"
					+ "\ncompletely separate. This is purely made in. China. NOT FIVENIGTSNAF."
					+ "\nNow with that out of the way..."
					+ "\n\nPress ENTER/SPACE to Lazada (or ESC to open Shopee)",
					32);
				txt.setFormat("Century Gothic", 32, FlxColor.fromRGB(255, 255, 255), CENTER);
				txt.borderColor = FlxColor.fromRGB(0, 5, 25);
				txt.borderSize = 3;
				txt.borderStyle = FlxTextBorderStyle.OUTLINE;
				txt.alpha = 1;
				txt.screenCenter();
				add(txt);
			}
			else
			{
				FlxG.sound.play(Paths.sound('disclaimerClickFlash'));
			}
			new FlxTimer().start(0.04, function(tmr:FlxTimer)
			{
				Caching.disclaimerMusic.destroy();
				FlxG.camera.fade(FlxColor.WHITE, 4, false, function()
				{
					add(black);
					FlxG.camera.fade(FlxColor.BLACK, 0, false, function()
					{
						FlxG.switchState(new TitleState());
					}, true);
				}, true);
			});
		}
		else
		{
			FlxG.sound.play(Paths.sound('disclaimerClick'));

			if (FlxG.save.data.flashing)
			{
				FlxG.save.data.flashing = !FlxG.save.data.flashing;
				trace("Turned off flashing lights"); 
			}

			new FlxTimer().start(0.04, function(tmr:FlxTimer)
			{
				Caching.disclaimerMusic.destroy();
				Caching.cacheMusic.destroy();
				FlxG.camera.fade(FlxColor.BLACK, 4, false, function()
				{
					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						FlxG.switchState(new OptionsMenu());
					});
				}, true);
			});
		}
	}

	function speedrunSkip():Void
	{
		FlxG.sound.play(Paths.sound('skipDisclaimerTransition'), 0.8);
		add(black);
		FlxG.camera.fade(FlxColor.BLACK, 0, false, function()
		{
			if (!wentOptions)
				FlxG.switchState(new TitleState());
			else
				FlxG.switchState(new OptionsMenu());
		}, true);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT && !leftState)
		{
			leftState = true;
			exitDisclaimerState();
		}
		else if (controls.BACK && !leftState)
		{
			leftState = true;
			wentOptions = true;
			exitDisclaimerState();
		}
		else if ((controls.ACCEPT || controls.BACK) && leftState)
		{
			speedrunSkip();
		}
	}
}
