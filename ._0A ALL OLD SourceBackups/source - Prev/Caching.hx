#if sys
package;

import lime.app.Application;
#if windows
import Discord.DiscordClient;
#end
import openfl.display.BitmapData;
import openfl.utils.Assets;
import haxe.Exception;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
#if cpp
import sys.FileSystem;
import sys.io.File;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.addons.transition.FlxTransitionableState;

using StringTools;

class Caching extends MusicBeatState
{
	var toBeDone = 0;
	var done = 0;

	var loaded = false;

	var text:FlxText;
	var targetText:String = '';
	var tipText:FlxText;
	var kadeLogo:FlxSprite;

	var goForTheMilk:Bool = false;

	public static var bitmapData:Map<String,FlxGraphic>;

	//Public Static so that it can be destroyed in disclaimerscreen
	public static var cacheMusic:FlxSound;
	public static var disclaimerMusic:FlxSound;

	var images = [];
	var music = [];
	var charts = [];

	//Time Shit!
	var monthList:Array<String> = ["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
	public static var curMonth:String = "";

	var dayList:Array<String> = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"];
	public static var curDay:String = "";

	var hoursList:Array<String> = ["12 AM", "1 AM", "2 AM", "3 AM", "4 AM", "5 AM", "6 AM", "7 AM", "8 AM", "9 AM", "10 AM", "11 AM", "12 PM", "1 PM", "2 PM", "3 PM", "4 PM", "5 PM", "6 PM", "7 PM", "8 PM", "9 PM", "10 PM", "11 PM"];
	public static var curHour:String = "";

	override function create()
	{
		if (FlxG.save.data.showPresence)
			DiscordClient.changePresence("Loading...", null, null, true);

		curMonth = monthList[Date.now().getMonth()];
		curDay = dayList[Date.now().getDay()];
		curHour = hoursList[Date.now().getHours()];

		bitmapData = new Map<String,FlxGraphic>();

		kadeLogo = new FlxSprite(0, 0).loadGraphic(Paths.image('KadeEngineLogo'));
		kadeLogo.setGraphicSize(Std.int(kadeLogo.width * 0.6));
		kadeLogo.screenCenter();
		kadeLogo.y -= 50;
		kadeLogo.antialiasing = true;
		kadeLogo.alpha = 0;

		text = new FlxText(0, 0, "Loading...");
		text.size = 34;
		text.y = kadeLogo.y + kadeLogo.height - 70;
		text.alignment = FlxTextAlign.CENTER;
		text.alpha = 0;

		if (FlxG.save.data.cacheImages || FlxG.save.data.cacheMusic)
		{
			tipText = new FlxText(kadeLogo.x + 120, text.y + text.height * 1.3, kadeLogo.width - 240, "Loading times too long? Turn off pre-caching in the 'Performance' tab within the options menu!");
			tipText.setFormat(Paths.font("playtime.ttf"), 35);
			tipText.color = 0xffac9200;
			tipText.alignment = FlxTextAlign.CENTER;
			tipText.alpha = 0;
			add(tipText);
		}

		add(kadeLogo);
		add(text);

		FlxG.camera.fade(FlxColor.BLACK, 1, true);
		#if cpp
		if (!FlxG.save.data.cacheImages && !FlxG.save.data.cacheMusic)
		{
			kadeLogo.alpha = 1;
			text.alpha = 1;
			text.text = "<<Press  ENTER>>";
			text.screenCenter(X);
		
		}
		else
		{
			if (FlxG.save.data.cacheImages)
			{
				trace("caching images...");

				for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/characters")))
				{
					if (!i.endsWith(".png"))
						continue;
					else
						i = 'characters/' + StringTools.replace(i, ".png", "");
					images.push(i);
				}
			}

			if (FlxG.save.data.cacheMusic)
			{
				trace("caching music...");

				for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/songs")))
				{
					music.push(i);
				}
			}

			toBeDone = Lambda.count(images) + Lambda.count(music);

			trace('starting caching..');
			
			// update thread
			sys.thread.Thread.create(() -> 
			{
				while(!loaded)
				{
					if (toBeDone != 0 && done != toBeDone)
						{
							if (done > toBeDone)
								done = toBeDone;
							targetText = "Loading... (" + (done) + "/" + toBeDone + ")";
						}
				}
			});

			// cache thread
			sys.thread.Thread.create(() -> 
			{
				cache();
			});
			FlxTween.tween(tipText, {alpha: 1}, 5, {type: ONESHOT, ease: FlxEase.smoothStepInOut, startDelay: 8});
		}
		#else
		kadeLogo.alpha = 1;
		text.alpha = 1;
		text.text = "<<Press  ENTER>>";
		text.screenCenter(X);
		#end

		//Tips for future Samuel: If sound volume is '0', it doesn't play the sound until volume is < 0
		//Maybe we can fix that by adding a "disclaimerMusic.time" thing on update or sum shit idk
		//And I did exactly that.
		//Thank you past Samuel!
		//no this is bullshit, both of y'all past samuels are dumb af
		cacheMusic = new FlxSound().loadEmbedded(Paths.music('preMusic-loading'), true, false);
		cacheMusic.volume = 0;
		FlxG.sound.list.add(cacheMusic);
		disclaimerMusic = new FlxSound().loadEmbedded(Paths.music('preMusic-disclaimer'), true, false);
		disclaimerMusic.persist = true;
		disclaimerMusic.volume = 0;
		FlxG.sound.list.add(disclaimerMusic);

		super.create();

		cacheMusic.play();
		disclaimerMusic.play();
		cacheMusic.fadeIn(5, 0, 0.5);
	}

	var targetAlpha:Float = 0;
	var calledDone = false;

	override function update(elapsed)
	{
		super.update(elapsed);
		if (!FlxG.save.data.cacheMusic && !FlxG.save.data.cacheImages)
		{
			if (controls.ACCEPT && !goForTheMilk)
			{
				goForTheMilk = true;
				finishCaching();
			}
		}

		if (targetText != text.text)
		{
			text.text = targetText;
			text.screenCenter(X);
			targetAlpha = HelperFunctions.truncateFloat(done / toBeDone * 100,2) / 100;
			kadeLogo.alpha = targetAlpha;
			text.alpha = targetAlpha;
			//text.x = text.height + 100;
		}
	}

	function cache()
	{
		trace("LOADING: " + toBeDone + " OBJECTS.");

		for (i in images)
		{
			Paths.image(i, '', true);
			done++;
		}

		for (i in music)
		{
			trace("caching " + i);
			Paths.inst(i, true);
			if (Paths.fileExists(Paths.voicesString(i), SOUND))
				Paths.voices(i, true);
			if (Paths.fileExists(Paths.miscsString(i), SOUND))
				Paths.miscs(i, true);
			if (Paths.fileExists(Paths.adaptiveMusString(i), SOUND))
				Paths.adaptiveMus(i, true);
			done++;
		}

		trace("Finished caching...");
		finishCaching();
	}

	function finishCaching():Void
	{
		#if cpp
		if (FlxG.save.data.cacheImages || FlxG.save.data.cacheMusic)
		{
			text.text = "Loading... (" + (toBeDone) + "/" + toBeDone + ")";
			text.screenCenter(X);
		}
		#end
		FlxG.sound.play(Paths.sound('returnMenu'));
		cacheMusic.fadeOut(0.35, 0);
		disclaimerMusic.fadeIn(0.35, 0, 0.5);
		loaded = true;
		new FlxTimer().start(0.35, function(tmr:FlxTimer)
		{
			FlxG.switchState(new DisclaimerScreen());
		});
	}
}
#end