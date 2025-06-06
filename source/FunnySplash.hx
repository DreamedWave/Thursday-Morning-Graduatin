package;

import lime.app.Application;
import openfl.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
//import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import sys.FileSystem;
import flixel.FlxCamera;

//Trans Shit
//...
//YO I'VE JUST THOUGHT OF A REALLY FUNNY JOKE
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.CustomTransitionSprites.TransTileInvertedCircle;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

//PROFILER - REMOVE ONCE IN RELEASE!!!
//import pgr.dconsole.DC;

using StringTools;

class FunnySplash extends MusicBeatState //is musicbeatstate rather than musicbeat menu to compensate for the time jumps/lag spikes that might happen at the start
{
	var sprite:Sprite;
	var gfx:Graphics;
	var text:TextField;

	var times:Array<Float>;
	var colors:Array<Int>;
	var functions:Array<Void->Void>;
	var curPart:Int = 0;
	var lilOpeningAnim:FlxSprite;
	var removedOpeningAnim:Bool = false;

	var doRickRoll:Bool = false;

	var bitmapData:Map<String,FlxGraphic>;

	override public function create():Void
	{
		FlxG.game.soundTray.tempDisable = true;
		FlxG.autoPause = false;

		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		FlxG.mouse.visible = false;

		FlxG.worldBounds.set(0,0);

		bitmapData = new Map<String,FlxGraphic>();

		FlxG.cameras.bgColor = FlxColor.BLACK;
		FlxG.fixedTimestep = false;

		
		//Moved from TitleState -> DisclaimerScreen -> Caching -> FunnySplash
		var transitionSprite:FlxGraphic = FlxGraphic.fromClass(TransTileInvertedCircle);
		transitionSprite.persist = true;
		transitionSprite.destroyOnNoUse = false;
		//If you're gonna change this, don't forget to change the thing in Paths.hx too!

		FlxTransitionableState.defaultTransIn = new TransitionData(TILES, FlxColor.BLACK, 0.5, new FlxPoint(-0.5, -1), {width: 32, height: 32, asset: transitionSprite}, 
			new FlxRect(0, 0, FlxG.width, FlxG.height), FlxCamera.defaultCameras[FlxCamera.defaultCameras.length]);
		FlxTransitionableState.defaultTransOut = new TransitionData(TILES, FlxColor.BLACK, 0.5, new FlxPoint(-0.5, -1),
			{asset: transitionSprite, width: 32, height: 32}, new FlxRect(0, 0, FlxG.width, FlxG.height), FlxCamera.defaultCameras[FlxCamera.defaultCameras.length]);

		
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.save.data.weekUnlocked > 1)
		{
			var rickRollChance:Float = 0.1;///10% chance to rickroll LMFAO
			if (Main.aprilFools)
				rickRollChance = 0.45;
			doRickRoll = FlxG.random.bool(rickRollChance);
		}

		//Preloading of Menu Sounds - unsure if this should still be here
		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/sounds")))
		{
			if (i.endsWith(".ogg"))
			{
				i = StringTools.replace(i, ".ogg", "");
				Paths.sound(i, '', true);
			}
		}

		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/music")))
		{
			if (i.startsWith("preMusic") && i.endsWith(".ogg"))
			{
				i = StringTools.replace(i, ".ogg", "");
				Paths.music(i, '', false);
			}
		}


		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

		//Temporary! Will make my own animated version!!!
		times = [0.041, 0.184, 0.334, 0.495, 0.636];
		colors = [0x00b922, 0xffc132, 0xf5274e, 0x3641ff, 0x04cdfb];
		functions = [drawGreen, drawYellow, drawRed, drawBlue, drawLightBlue];

		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		sprite = new Sprite();
		FlxG.stage.addChild(sprite);
		gfx = sprite.graphics;

		text = new TextField();
		text.selectable = false;
		text.embedFonts = true;
		var dtf:TextFormat;
		if (!Main.todayIsSunday)
			dtf = new TextFormat('VCR OSD Mono', 16, 0xffffff);
		else
			dtf = new TextFormat('VCR OSD Mono', 16, 0xff9ed5);
		dtf.align = TextFormatAlign.CENTER;
		text.defaultTextFormat = dtf;
		FlxG.stage.addChild(text);

		//Opening Animation Danec
		lilOpeningAnim = new FlxSprite(0, 0);
		if (!doRickRoll)
			lilOpeningAnim.frames = Paths.getSparrowAtlas('preloadAnim');
		else
			lilOpeningAnim.frames = Paths.getSparrowAtlas('preloadAnim-secret');
		lilOpeningAnim.animation.addByPrefix('danec', "lilDance", 22, true);
		//lilOpeningAnim.setGraphicSize(Std.int(lilOpeningAnim.width));
		lilOpeningAnim.screenCenter();
		if(FlxG.save.data.antialiasing)
			lilOpeningAnim.antialiasing = true;
		add(lilOpeningAnim);
		lilOpeningAnim.animation.play('danec');
		
		super.create();

		#if windows
		if (FlxG.save.data.showPresence)
			DiscordClient.changePresence("[Hello, World!]", null, 'apppresence-dark');
		#end

		Conductor.changeBPM(98);
		var leTime:Float = Conductor.stepCrochet / 1000;
		times = [0, leTime, leTime * 2, leTime * 3, leTime * 4];
		var splashJingleKey:String = '';
		if (doRickRoll)
			splashJingleKey = 'splashScreenJingle-secret';
		else if (Main.todayIsSunday)
			splashJingleKey = 'splashScreenJingle-sunday';
		else
			splashJingleKey = 'splashScreenJingle-default';
		FlxG.sound.playMusic(Paths.music(splashJingleKey), 0.8, false);
		
		FlxG.camera.stopFX('fade');
		FlxG.camera.fade(FlxColor.BLACK, 0.5, true);
	}

	private function buh(Timer:FlxTimer):Void
	{
		if (!doRickRoll)
			text.text = "HaxeFlixel";
		else
			if (!Main.aprilFools)
				text.text = "HaxeFlixel\nWill Never Give You Up!";
			else
				text.text = "Haxeflixel\n(ALSO HAPPY APRIL FOOLS!!!)";
		removedOpeningAnim = true;
		remove(lilOpeningAnim);
	}
	
	override function beatHit():Void
	{
		super.beatHit();

		switch(curBeat)
		{
			case 1:
				FlxTween.tween(lilOpeningAnim, {alpha: 0}, (Conductor.crochet * 2) / 1000, {ease: FlxEase.quadOut, startDelay: (Conductor.crochet * 0.5) / 1000});
			case 3:
				new FlxTimer().start((Conductor.crochet / 1000) - (Conductor.stepCrochet / 1000), buh);
			case 4:
				for (time in times)
				{
					if (!wentForTheMilk)
						new FlxTimer().start(time, timerCallback);
				}
		}
	}

	var wentForTheMilk:Bool = false;

	override function update(elapsed)
	{
		super.update(elapsed);

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		if ((FlxG.keys.justPressed.ANY || FlxG.mouse.justPressed || FlxG.mouse.justPressedMiddle || FlxG.mouse.justPressedRight) && !FlxG.keys.justPressed.ZERO && !FlxG.keys.justPressed.PLUS && !FlxG.keys.justPressed.MINUS && !FlxG.keys.justPressed.ALT && !FlxG.keys.justPressed.TAB && !wentForTheMilk)
		{
			wentForTheMilk = true;
			finishSplash();
		}

		//trace("CurBeatAAAAA: " + curBeat);
	}
	
	override public function destroy():Void
	{
		sprite = null;
		gfx = null;
		text = null;
		times = null;
		colors = null;
		functions = null;

		FlxG.game.soundTray.tempDisable = false;
		
		super.destroy();
	}

	override public function onResize(Width:Int, Height:Int):Void
	{
		super.onResize(Width, Height);

		sprite.x = (Width / 2);
		sprite.y = (Height / 2) - 20 * FlxG.game.scaleY;

		text.width = Width / FlxG.game.scaleX;
		text.x = 0;
		text.y = sprite.y + 60 * FlxG.game.scaleY;

		sprite.scaleX = text.scaleX = FlxG.game.scaleX;
		sprite.scaleY = text.scaleY = FlxG.game.scaleY;
	}

	var spriteTween:FlxTween;
	var textTween:FlxTween;

	function timerCallback(Timer:FlxTimer):Void
	{
		functions[curPart]();
		text.textColor = colors[curPart];
		//text.text = "HaxeFlixel";
		curPart++;

		if (curPart == 5)
		{
			// Make the logo a tad bit longer, so our users fully appreciate our hard work :D
			spriteTween = FlxTween.tween(sprite, {alpha: 0}, 3.0, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween){finishSplash();}});
			textTween = FlxTween.tween(text, {alpha: 0}, 3.0, {ease: FlxEase.quadOut});
		}
	}

	function drawGreen():Void
	{
		gfx.beginFill(0x00b922);
		gfx.moveTo(0, -37);
		gfx.lineTo(1, -37);
		gfx.lineTo(37, 0);
		gfx.lineTo(37, 1);
		gfx.lineTo(1, 37);
		gfx.lineTo(0, 37);
		gfx.lineTo(-37, 1);
		gfx.lineTo(-37, 0);
		gfx.lineTo(0, -37);
		gfx.endFill();
	}

	function drawYellow():Void
	{
		gfx.beginFill(0xffc132);
		gfx.moveTo(-50, -50);
		gfx.lineTo(-25, -50);
		gfx.lineTo(0, -37);
		gfx.lineTo(-37, 0);
		gfx.lineTo(-50, -25);
		gfx.lineTo(-50, -50);
		gfx.endFill();
	}

	function drawRed():Void
	{
		gfx.beginFill(0xf5274e);
		gfx.moveTo(50, -50);
		gfx.lineTo(25, -50);
		gfx.lineTo(1, -37);
		gfx.lineTo(37, 0);
		gfx.lineTo(50, -25);
		gfx.lineTo(50, -50);
		gfx.endFill();
	}

	function drawBlue():Void
	{
		gfx.beginFill(0x3641ff);
		gfx.moveTo(-50, 50);
		gfx.lineTo(-25, 50);
		gfx.lineTo(0, 37);
		gfx.lineTo(-37, 1);
		gfx.lineTo(-50, 25);
		gfx.lineTo(-50, 50);
		gfx.endFill();
	}

	function drawLightBlue():Void
	{
		gfx.beginFill(0x04cdfb);
		gfx.moveTo(50, 50);
		gfx.lineTo(25, 50);
		gfx.lineTo(1, 37);
		gfx.lineTo(37, 1);
		gfx.lineTo(50, 25);
		gfx.lineTo(50, 50);
		gfx.endFill();
	}

	function finishSplash():Void
	{
		if (!wentForTheMilk)
		{
			if (!removedOpeningAnim)
			{
				removedOpeningAnim = true;
				remove(lilOpeningAnim);
			}
			FlxTransitionableState.skipNextTransIn = true;
			FlxG.stage.removeChild(sprite);
			FlxG.stage.removeChild(text);
			FlxG.switchState(new CachingState());
		}
		else
		{
			FlxG.sound.music.fadeOut(0.2);

			if (spriteTween != null)
				spriteTween.cancel();
			if (textTween != null)
				textTween.cancel();
			spriteTween = FlxTween.tween(sprite, {alpha: 0}, 0.2, {ease: FlxEase.quadOut});
			textTween = FlxTween.tween(text, {alpha: 0}, 0.2, {ease: FlxEase.quadOut});

			FlxTween.tween(FlxG.camera, {alpha: 0}, 0.2, {ease: FlxEase.quadOut, onComplete: function(twn:FlxTween)
			{
				if (!removedOpeningAnim)
				{
					removedOpeningAnim = true;
					remove(lilOpeningAnim);
				}
				FlxTransitionableState.skipNextTransIn = true;
				FlxG.stage.removeChild(sprite);
				FlxG.stage.removeChild(text);
				FlxG.switchState(new CachingState());
			}});
		}
	}
}
