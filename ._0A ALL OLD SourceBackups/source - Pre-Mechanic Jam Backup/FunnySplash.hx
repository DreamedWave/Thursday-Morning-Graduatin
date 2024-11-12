package;

#if windows
import Discord.DiscordClient;
#end
import lime.app.Application;
import openfl.display.BitmapData;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.Lib;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.text.TextFormatAlign;
import flixel.FlxG;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import sys.FileSystem;

//Trans Shit
import flixel.FlxCamera;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileCircleInverted;
import flixel.addons.transition.TransitionData;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

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
		//FlxG.save.bind('graduatin', 'dreamedwave');
		FlxG.save.bind('graduatin', '');

		PlayerSettings.init();

		KadeEngineData.initSave();
		
		if (FlxG.save.data.showPresence)
			DiscordClient.changePresence("", null);

		FlxG.mouse.visible = false;

		FlxG.worldBounds.set(0,0);

		bitmapData = new Map<String,FlxGraphic>();

		//Date and shit
		Main.nightMode = FlxG.save.data.nightmode;
		Main.curMonthString = Main.monthList[Date.now().getMonth()];
		Main.curMonthInt = Date.now().getMonth();
		Main.curDayString = Main.dayList[Date.now().getDay()];
		Main.curDayInt = Date.now().getDay();
		Main.curHourString = Main.hoursList[Date.now().getHours()];
		Main.curHourInt = Date.now().getHours();

		trace(Main.curMonthString + ', ' + Main.curDayString + ', ' + Main.curHourString);

		if ((Main.curHourInt < 6 || Main.curHourInt > 23) && FlxG.save.data.autoNightmode)
			Main.nightMode = true;

		FlxG.cameras.bgColor = FlxColor.BLACK;
		FlxG.fixedTimestep = false;

		if (FlxG.save.data.weekUnlocked > 1)
			doRickRoll = FlxG.random.bool(1);
		if (Main.curMonthString == "April" && Main.curDayInt <= 3)
		{
			doRickRoll = true;
			Main.aprilFools = true; 
		}
		
		if (Main.curDayString == 'Sunday' && (FlxG.random.bool(50) || Main.curHourInt <= 5))
		{
			Main.todayIsSunday = true;
			trace('Today is a Sunday!!');
		}


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
			if (i.startsWith("preMusic-discaimer") && i != "preMusic-disclaimer" && i.endsWith(".ogg"))
			{
				i = StringTools.replace(i, ".ogg", "");
				Paths.music(i, '', false);
			}
		}

		//Moved from TitleState -> DisclaimerScreen -> Caching -> FunnySplash
		var transitionSprite:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileCircleInverted);
		transitionSprite.persist = true;
		transitionSprite.destroyOnNoUse = false;
		//If you're gonna change this, don't forget to change the thing in paths too!

		FlxTransitionableState.defaultTransIn = new TransitionData(TILES, FlxColor.BLACK, 0.5, new FlxPoint(-0.5, -1), {width: 32, height: 32, asset: transitionSprite}, 
			new FlxRect(0, 0, FlxG.width, FlxG.height), FlxCamera.defaultCameras[FlxCamera.defaultCameras.length]);
		FlxTransitionableState.defaultTransOut = new TransitionData(TILES, FlxColor.BLACK, 0.5, new FlxPoint(-0.5, -1),
			{asset: transitionSprite, width: 32, height: 32}, new FlxRect(0, 0, FlxG.width, FlxG.height), FlxCamera.defaultCameras[FlxCamera.defaultCameras.length]);

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		FlxTransitionableState.skipNextTransIn = true;
		FlxTransitionableState.skipNextTransOut = true;

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

		Conductor.changeBPM(98);
		var leTime:Float = Conductor.stepCrochet / 1000;
		times = [0, leTime, leTime * 2, leTime * 3, leTime * 4];
		if (!doRickRoll)
		{
			if (!Main.todayIsSunday)
				FlxG.sound.playMusic(Paths.music('splashScreenJingle-default'), 0.8, false);
			else
				FlxG.sound.playMusic(Paths.music('splashScreenJingle-sunday'), 0.8, false);
		}
		else
			FlxG.sound.playMusic(Paths.music('splashScreenJingle-secret'), 0.8, false);
		FlxG.camera.stopFX('fade');
		FlxG.camera.fade(FlxColor.BLACK, 0.5, true);
	}

	private function buh(Timer:FlxTimer):Void
	{
		if (!doRickRoll)
			text.text = "HaxeFlixel";
		else
			if (!Main.aprilFools)
				text.text = "GOTTEM LMAOO";
			else
				text.text = "APRIL FOOLS!!";
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
			FlxG.switchState(new Caching());
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
					FlxG.switchState(new Caching());
			}});
		}
	}
}
