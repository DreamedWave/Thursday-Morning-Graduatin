package;

import lime.app.Application;
import openfl.display.BlendMode;
import openfl.text.TextFormat;
import flixel.util.FlxColor;
//import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxState;
import flixel.tweens.FlxTween;
import openfl.Assets;
import openfl.Lib;
import openfl.display.FPS;
import openfl.display.Sprite;
import openfl.events.Event;
import openfl.events.UncaughtErrorEvent;
import haxe.CallStack;
import haxe.io.Path;
import lime.system.System;
import sys.FileSystem;
import sys.io.File;

class Main extends Sprite
{
	var gameWidth:Int = 1280; // Width of the game in pixels (might be less / more in actual pixels depending on your zoom).
	var gameHeight:Int = 720; // Height of the game in pixels (might be less / more in actual pixels depending on your zoom).
	public static var gameVer:String = "";
	var game:FlxGame;
	var initialState:Class<FlxState> = FunnySplash; // The FlxState the game starts with.
	var zoom:Float = -1; // If -1, zoom is automatically calculated to fit the window dimensions.
	var framerate:Int = 120; // How many frames per second the game should run at.
	var skipSplash:Bool = true; // Whether to skip the flixel splash screen that appears in release mode.

	public static var fpsCounter:FPS;
	//var startFullscreen:Bool = false; // Whether to start the game in fullscreen on desktop targets

	public static var watermarks = true; // Whether to put Kade Engine literally anywhere
	public static var nightMode:Bool = false; //NIGHT MODE !!!!
	public static var aprilFools:Bool = false; //mmm
	public static var todayIsSunday:Bool = false; //I didn't know it was now 1 AM -- actually nvm delete this soon i dont like it anymore

	//Time Shit!
	//Don't judge me im - ok ifkADMKBSNF
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
	public static var focusVolumeTween:FlxTween;
	public static var staticVol:Float = 1.0;
	var oldVol:Float = 1.0;
	var newVol:Float = 0.3;

	public static var crashSound:FlxSound;

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
			init();
		else
			addEventListener(Event.ADDED_TO_STAGE, init);
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
		//Bind Save before we create the game
		// Use a customised save path that doesn't follow Project.xml bcuz we cool like that :3
		//Format:      .SOL filename            .SOL location
		//It still makes a new folder for some reason???
		//FlxG.save.bind('saveData', "AmieeMakesGames/Thursday-Morning-Graduatin");

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

		
		#if FLX_SOUND_TRAY
		FlxG.game.soundTray.tempDisable = true;
		#end


		//Moved Save.Bind to Modified FlxG
		PlayerSettings.init();
		SaveData.initSave();


		//Date and Time shit
		nightMode = FlxG.save.data.nightmode;
		curMonthString = monthList[Date.now().getMonth()];
		curMonthInt = Date.now().getMonth();
		curDayString = dayList[Date.now().getDay()];
		curDayInt = Date.now().getDay();
		curHourString = hoursList[Date.now().getHours()];
		curHourInt = Date.now().getHours();

		trace(curMonthString + ', ' + curDayString + ', ' + curHourString);
		trace(curMonthInt + ', ' + curDayInt + ', ' + curHourInt);

		if ((curHourInt < 6 || curHourInt > 23) && FlxG.save.data.autoNightmode)
			nightMode = true;

		//add get utc date in main
		if (Date.now().getUTCDate() <= 3 && curMonthString == "April")
			aprilFools = true;

		if (curDayString == 'Sunday' && FlxG.random.bool(10))
			todayIsSunday = true;

		
		#if windows
		if (FlxG.save.data.showPresence)
			DiscordClient.initialize();
		#end

		Application.current.onExit.add (function (exitCode)
		{
			#if windows
			DiscordClient.shutdown();
			OptionsMenu.discordClientStarted = false;
			#end
			ResultsScreen.CleanUpAfterYoself('assets/temp');
			ChartingState.CleanUpAfterMeself(true);

			switch (exitCode)
			{
				case 1:
					trace('game crashed!');
				default:
					trace('exited game');
			}
		});

		#if !mobile
		fpsCounter = new FPS(0, 5, 0xD2EEEE);
		addChild(fpsCounter);
		toggleFPS(false);
		#end

		crashSound = new FlxSound().loadEmbedded(Paths.sound('_oops', '', true));
		crashSound.volume = 0.5;

		gameVer = Lib.application.meta["version"];

		Application.current.window.onFocusOut.add(onWindowFocusOut);
		Application.current.window.onFocusIn.add(onWindowFocusIn);

		FlxG.mouse.load('assets/images/custom_bitmaps/TMG_CustomCursor.png', 1, 3, 3);
	}

	public function toggleFPS(fpsEnabled:Bool):Void
	{
		fpsCounter.visible = fpsEnabled;
	}

	public function changeFPSColor(color:FlxColor)
	{
		fpsCounter.textColor = color;
	}

	public function setFPSCap(cap:Int)
	{
		openfl.Lib.current.stage.frameRate = cap;
		FlxG.drawFramerate = cap;
		FlxG.updateFramerate = cap;
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
		if (!FlxG.autoPause && !FlxG.game.soundTray.tempDisable && doFocusShit)
		{
			trace('huh');
			isFocused = false;
			if (Type.getClass(FlxG.state) != PlayState && Type.getClass(FlxG.state) != ChartingState && Type.getClass(FlxG.state) != lore_minigames.MinigameState && (Type.getClass(FlxG.state) != FunnySplash || !FlxG.save.data.fullscreen)) // sorry i stole this from indie cross-
			{
				if (Type.getClass(FlxG.state) != FunnySplash && Type.getClass(FlxG.state) != CachingState && Type.getClass(FlxG.state) != DisclaimerState)
					FlxG.mouse.visible = false;

				if (focusVolumeTween != null)
				{
					focusVolumeTween.cancel();
					FlxG.sound.volume = oldVol;
					staticVol = oldVol;
				}
				else
				{
					oldVol = FlxG.sound.volume;
					staticVol = oldVol;
					trace ('oldVol = ' + oldVol);
				}

				if (oldVol > 0)
				{
					newVol = oldVol * 0.45;
				}

				focusVolumeTween = FlxTween.tween(FlxG.sound, {volume: newVol}, 0.3, {type: ONESHOT, 
					onComplete: function(peen:FlxTween)
					{
						focusVolumeTween = null;
					}
				});
				
				FlxG.drawFramerate = 60;
			}
		}
		else if (Type.getClass(FlxG.state) == PlayState)
			PlayState.instance.focusFunction(1);
	}

	function onWindowFocusIn()
	{
		if (!FlxG.autoPause && !FlxG.game.soundTray.tempDisable && doFocusShit)
		{
			if (Type.getClass(FlxG.state) != PlayState && Type.getClass(FlxG.state) != ChartingState && Type.getClass(FlxG.state) != lore_minigames.MinigameState && (Type.getClass(FlxG.state) != FunnySplash || !FlxG.save.data.fullscreen))
			{
				if (Type.getClass(FlxG.state) != FunnySplash && Type.getClass(FlxG.state) != CachingState && Type.getClass(FlxG.state) != DisclaimerState)
					FlxG.mouse.visible = true;

				if (focusVolumeTween != null)
					focusVolumeTween.cancel();

				focusVolumeTween = FlxTween.tween(FlxG.sound, {volume: oldVol}, 0.25, {type: ONESHOT, 
					onComplete: function(peen:FlxTween)
					{
						focusVolumeTween = null;
						isFocused = true;
					}
				});

				FlxG.drawFramerate = FlxG.save.data.fpsCap;
			}
			else
				isFocused = true;
		}
		else
		{
			if (!isFocused)
			{
				isFocused = true;
				trace('PHUUUCK');
				if (focusVolumeTween != null)
					focusVolumeTween.cancel();
				FlxG.sound.volume = oldVol;
				FlxG.drawFramerate = FlxG.save.data.fpsCap;
			}
			if (Type.getClass(FlxG.state) == PlayState)
				PlayState.instance.focusFunction(1);
		}
	}

	//Indie Cross Crash Window
	function onCrash(e:UncaughtErrorEvent):Void
	{
		FlxG.fullscreen = false;

		#if windows
		if (FlxG.save.data.showPresence)
			DiscordClient.changePresence("Game Crashed!", "...whoops", "apppresence-crashed", "_tinyico-crash", ":skull_emoji:");
		#end
		
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
			"Well, that just washes right off doesn't it?!",
			"Kade's Fault not mine!!!",
			"Now, this is what I call BUG FREE!",
			"Technically bug free - I don't see any spiders!",
			"It's not a bug, it's a feature!",
			"This isn't a beach, this is a BATHTUB!",
			"Ugh whatever, I'm going back to roblox fnf obby.",
			"Damn, Friday Night Bloxin' won't ever do me like this,,,",
			"GOD. DAMN IT.",
			"Guys what one is your favourite?",
			"That was uhhhh- yeah that was my bad-",
			"My mistake, the gate is NOT open.",
			"damn, u didnt migrate ur tmg account on time,,,",
			"This is basically just a fancy way of saying something broke!",
			"f e c k .",
			"MY LEG!!!",
			"AAAAAAAA SORRY MY BAD",
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
			"Congrats, you won!",
			"Two quills and a   b o n g .",
			"DreamedWave4364 was obliterated by a sonically-charged shriek",
			"Gone fishin'",
			"If you were wondering what '_oops.ogg' was for, well you just heard it now!",
			"HUMAN, I SHAT MESELF"
		];

		dateNow = StringTools.replace(dateNow, " ", "_");
		dateNow = StringTools.replace(dateNow, ":", "+");

		path = "./_logs/" + "TMG-CRASH_" + dateNow + ".txt";

		errMsg = "Thursday Morning Graduatin' has crashed!\n(so here's roughly what went wrong:)\n\n";
		errMsg += "TMG Version: " + gameVer + "\n";

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

		trace('The game crashed!!! Reminding you that if you rename a sound, you also need to change it in LoadingState if its within Playstate!!!');

		System.exit(1);
	}
}
