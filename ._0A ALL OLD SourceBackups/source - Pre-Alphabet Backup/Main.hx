package;

import lime.app.Application;
#if windows
import Discord.DiscordClient;
import discord_rpc.DiscordRpc;
#end
import openfl.display.BlendMode;
import openfl.text.TextFormat;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 120; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
	public static var gameVer:String = "";
	//var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var watermarks = true; // Whether to put Kade Engine literally anywhere
	public static var nightMode:Bool = false; //NIGHT MODE !!!!
	public static var aprilFools:Bool = false; //mmm
	public static var todayIsSunday:Bool = false; //I didn't know it was now 1 AM

	//Time Shit!
	public static var monthList:Array<String> = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
	public static var curMonthString:String = "";
	public static var curMonthInt:Int = 0;

	public static var dayList:Array<String> = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
	public static var curDayString:String = "";
	public static var curDayInt:Int = 0;

	public static var hoursList:Array<String> = ["12 AM", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM", "9 AM", "10 AM", "11 AM", "12 PM", "1 PM", "2 PM", "3 PM", "4 PM", "5 PM", "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM"];
	public static var curHourString:String = "";
	public static var curHourInt:Int = 0;

	public static var doFocusShit:Bool = true;
	public static var isFocused:Bool = true;
	public static var focusMusicTween:FlxTween;
	var oldVol:Float = 1.0;
	var newVol:Float = 0.3;

	var crashSound:FlxSound;

	// You can pretty much ignore everything from here on - your code should go in your states.
	//uhmmm, but what if i dont heehee~

	public static function main():Void
	{
		// quick checks 
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

		Lib.current.loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, onCrash);

		if (stage != null)
		{
			init();
		}
		else
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
	}

	private function init(?E:Event):Void
	{
		if (hasEventListener(Event.ADDED_TO_STAGE))
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
		}

		setupGame();
	}

	private function setupGame():Void
	{
		var stageWidth:Int = Lib.current.stage.stageWidth;
		var stageHeight:Int = Lib.current.stage.stageHeight;

		if (zoom == -1)
		{
			var ratioX:Float = stageWidth / gameWidth;
			var ratioY:Float = stageHeight / gameHeight;
			zoom = Math.min(ratioX, ratioY);
			gameWidth = Math.ceil(stageWidth / zoom);
			gameHeight = Math.ceil(stageHeight / zoom);
		}

		initialState = FunnySplash;
		#if cpp
		game = new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, false);
		#else
		game = new FlxGame(gameWidth, gameHeight, initialState, framerate, framerate, skipSplash, false);
		#end
		addChild(game);

		#if windows
		DiscordClient.initialize();

		Application.current.onExit.add (function (exitCode) 
		{
			if (FlxG.save.data.showPresence)
			{
				DiscordClient.shutdown();
				DiscordRpc.shutdown();
			}
			trace('exited game');
		});
		#end

		#if !mobile
		fpsCounter = new FPS(0, 3, 0xD2EEEE);
		addChild(fpsCounter);
		toggleFPS(false);
		#end

		crashSound = new FlxSound().loadEmbedded(Paths.sound('_oops', '', true));
		crashSound.volume = 0.5;

		gameVer = Lib.application.meta["version"];

		Application.current.window.onFocusOut.add(onWindowFocusOut);
		Application.current.window.onFocusIn.add(onWindowFocusIn);
	}

	var game:FlxGame;

	var fpsCounter:FPS;

	public function toggleFPS(fpsEnabled:Bool):Void
	{
		fpsCounter.visible = fpsEnabled;
	}

	public function changeFPSColor(color:FlxColor)
	{
		fpsCounter.textColor = color;
	}

	public function setFPSCap(cap:Float)
	{
		openfl.Lib.current.stage.frameRate = cap;
	}

	public function getFPSCap():Float
	{
		return openfl.Lib.current.stage.frameRate;
	}

	public function getFPS():Float
	{
		return fpsCounter.currentFPS;
	}

	public static function updateTimeStuffs():Void
	{
		curMonthString = monthList[Date.now().getMonth()];
		curMonthInt = Date.now().getMonth();
		curDayString = dayList[Date.now().getDay()];
		curDayInt = Date.now().getDay();
		curHourString = hoursList[Date.now().getHours()];
		curHourInt = Date.now().getHours();

		if ((curHourInt < 6 || curHourInt > 23) && FlxG.save.data.autoNightmode)
			nightMode = true;
		else
			nightMode = false;
	}

	public static function updateNightMode():Void
	{
		if ((curHourInt < 6 || curHourInt > 23) && FlxG.save.data.autoNightmode)
			nightMode = true;
		else
			nightMode = false;
	}

	function onWindowFocusOut()
	{
		isFocused = false;
		if (doFocusShit)
		{
			if (Type.getClass(FlxG.state) != PlayState && Type.getClass(FlxG.state) != ChartingState) // sorry i stole this from indie cross-
			{
				if (focusMusicTween != null)
				{
					focusMusicTween.cancel();
					FlxG.sound.volume = oldVol;
				}
				else
				{
					oldVol = FlxG.sound.volume;
					trace ('oldVol = ' + oldVol);
				}

				if (oldVol > 0)
				{
					newVol = oldVol * 0.45;
				}

				focusMusicTween = FlxTween.tween(FlxG.sound, {volume: newVol}, 0.3, {type: ONESHOT, 
					onComplete: function(peen:FlxTween)
					{
						focusMusicTween = null;
					}
				});
				
				FlxG.drawFramerate = 60;
			}
		}
	}

	function onWindowFocusIn()
	{
		if (doFocusShit)
		{
			if (Type.getClass(FlxG.state) != PlayState && Type.getClass(FlxG.state) != ChartingState)
			{
				if (focusMusicTween != null)
					focusMusicTween.cancel();

				focusMusicTween = FlxTween.tween(FlxG.sound, {volume: oldVol}, 0.25, {type: ONESHOT, 
					onComplete: function(peen:FlxTween)
					{
						focusMusicTween = null;
						isFocused = true;
					}
				});

				FlxG.drawFramerate = FlxG.save.data.fpsCap;
			}
		}
		else
			isFocused = true;
	}

	//Indie Cross Crash Window
	function onCrash(e:UncaughtErrorEvent):Void
	{
		FlxG.fullscreen = false;
		
		var errMsg:String = "";
		var path:String;
		var callStack:Array<StackItem> = CallStack.exceptionStack(true);
		var dateNow:String = Date.now().toString();

		/** 
		* "Borrowed" from Indie Cross, who borrowed it from Izzy Engine :troll:
		* 
		*/
		var errComments:Array<String> = [
			"Just a *very* minor case of SERIOUS brain damage-",
			"Thanks for the hate crime Jer! See you in court mate.",
			"That just washes right off doesn't it?!",
			"Kade's Fault not mine!",
			"Now, this is what I call BUG FREE!",
			"Technically bug free - I don't see no spider!",
			"It's not a bug, it's a feature!",
			"This isn't a beach, this is a BATHTUB!",
			"Ugh, whatever, I'm going back to my roblox obby.",
			"Damn, Friday Night Bloxin' won't ever do me like this,,,",
			"Guys what one is your favourite?",
			"Fun detected! Removing fireflies...",
			"Fun detected! Adding phantoms...",
			"u didnt migrate ur tmg account on time,,,",
			"Basically, a fancy way of saying something broke!",
			"f e c k .",
			"MY LEG!!!",
			"'Nile is a river in Egypt' -Freddie, 2023",
			"'when i close my eyes i cant see -Brittany Broski, 2021'",
			"Addeh Facts #05: 'RED is not GREEN'!",
			"Aster's encouragement of the day!: 'You crashed? Skill issue...'",
			"Well, this is it. Pancit.",
			"Oops,,, I'm Dory,,,",
			"NAURRRR !!! FLINT LOCK WOOD !!!",
			"This is what a PhD in water-bending gets you.",
			"the_gagamboy joined the game",
			"A U G H",
			"This crash screen is NOT CANON.",
			"Not part of the script!",
			"You killed Niko.",
			"Two quills and a   b o n g .",
			"DreamedWave4364 was obliterated by a sonically-charged shriek",
			"Gone fishin'",
			"If you were wondering what '_oops.ogg' was for, well you just heard it now!"
		];

		dateNow = StringTools.replace(dateNow, " ", "_");
		dateNow = StringTools.replace(dateNow, ":", "+");

		path = "./_logs/" + "TMG-CRASH_" + dateNow + ".txt";

		errMsg = "Thursday Morning Graduatin' has crashed!\n(so here's what went wrong):\n\n";
		errMsg += "TMG Version: " + Lib.application.meta["version"] + "\n";

		for (stackItem in callStack)
		{
			switch (stackItem)
			{
				case FilePos(s, file, line, column):
					errMsg += "     " + file + " (line " + line + ")\n";
				default:
					Sys.println(stackItem);
			}
		}

		errMsg += "\nUncaught Error: " + e.error + "\n[" + errComments[Std.random(errComments.length)] + "]\n\nPlease send this error to the mod developer!";

		if (!FileSystem.exists("./_logs/"))
			FileSystem.createDirectory("./_logs/");
		File.saveContent(path, errMsg + "\n");
		Sys.println("Crash dump saved in " + Path.normalize(path));

		crashSound.play();

		errMsg += "\n(a [.txt] version of this can be found in the '_logs' folder.)";
		Application.current.window.alert(errMsg, "Whoopsie-");

		Sys.exit(1);
	}
}
