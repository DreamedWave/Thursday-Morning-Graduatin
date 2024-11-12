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
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var initialState:Class<FlxState> = TitleState; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 120; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.
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

	// You can pretty much ignore everything from here on - your code should go in your states.

	public static function main():Void
	{
		// quick checks 
		Lib.current.addChild(new Main());
	}

	public function new()
	{
		super();

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
		toggleFPS(FlxG.save.data.fps);
		#end
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

		if (curHourInt < 6 || curHourInt > 23)
			nightMode = true;
	}
}
