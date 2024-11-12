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
import flixel.addons.util.FlxAsyncLoop;

using StringTools;

class Caching extends MusicBeatState
{
	var cacheLoop:FlxAsyncLoop;
	var toBeDone:Int = 0;
	var done:Int = 0;

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

	var images:Array<String> = [];
	var music:Array<String> = [];
	var charts:Array<String> = [];

	override function create()
	{
		if (FlxG.save.data.showPresence)
			DiscordClient.changePresence("Loading...", null, null, true);

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

			trace('starting caching...');
			trace ('To Be Done = ' + toBeDone);

			// setup our loop
			cacheLoop = new FlxAsyncLoop(toBeDone, cache, 1);
			add(cacheLoop);

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
		if (!FlxG.save.data.cacheImages && !FlxG.save.data.cacheMusic)
			cacheMusic.fadeIn(3, 0, 0.5);
	}

	var targetAlpha:Float = 0;
	var calledDone = false;
	var okBuddyStopThat = false;

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
		else
		{			
			// If my loop hasn't started yet, start it
			if (!cacheLoop.started)
			{
				cacheLoop.start();
			}
			else
			{
				// if the loop has been started, and is finished, then we swich which groups are active
				if (cacheLoop.finished && !okBuddyStopThat)
				{
					okBuddyStopThat = true;
					// clean up our loop
					cacheLoop.kill();
					cacheLoop.destroy();
					trace("Finished caching...");
					finishCaching();
				}
			}	
		}
	}

	var imagesCount:Int = 0;
	var musicCount:Int = 0;

	function cache()
	{
		trace('cacheFunct');
		if (imagesCount < images.length && images.length != 0)
		{
			done++;
			Paths.image(images[imagesCount], '', true);
			imagesCount++;
		}
		else if (musicCount < music.length && music.length != 0)
		{
			trace("caching " + music[musicCount]);
			done++;
			Paths.inst(music[musicCount], true);
			if (Paths.fileExists(Paths.voicesString(music[musicCount]), SOUND))
				Paths.voices(music[musicCount], true);
			if (Paths.fileExists(Paths.miscsString(music[musicCount]), SOUND))
				Paths.miscs(music[imagesCount], true);
			if (Paths.fileExists(Paths.adaptiveMusString(music[musicCount]), SOUND))
				Paths.adaptiveMus(music[musicCount], true);
			musicCount++;
		}

		if (toBeDone != 0)
		{
			if (done > toBeDone)
				done = toBeDone;
			text.text = "Loading... (" + (done) + "/" + toBeDone + ")";
			targetAlpha = HelperFunctions.truncateFloat(done / toBeDone * 100,2) / 100;
			kadeLogo.alpha = targetAlpha;
			text.alpha = targetAlpha;
			text.screenCenter(X);
			cacheMusic.volume = targetAlpha * 0.5;
		}
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