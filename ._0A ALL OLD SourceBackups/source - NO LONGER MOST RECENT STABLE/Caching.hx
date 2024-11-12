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
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;

using StringTools;

class Caching extends MusicBeatState
{
	var toBeDone = 0;
	var done = 0;

	var loaded = false;

	var text:FlxText;
	var tipText:FlxText;
	var kadeLogo:FlxSprite;

	var goForTheMilk:Bool = false;
	var syncedMusicTime:Bool = false;

	public static var bitmapData:Map<String,FlxGraphic>;

	//Public Static so that it can be destroyed in disclaimerscreen
	public static var cacheMusic:FlxSound;
	public static var disclaimerMusic:FlxSound;

	var images = [];
	var music = [];
	var charts = [];


	override function create()
	{
		FlxG.save.bind('graduatin', 'dreamedwave');

		PlayerSettings.init();

		KadeEngineData.initSave();
		
		if (FlxG.save.data.showPresence)
			DiscordClient.changePresence("Loading...", null, null, true);

		FlxG.mouse.visible = false;

		FlxG.worldBounds.set(0,0);

		bitmapData = new Map<String,FlxGraphic>();

		text = new FlxText(FlxG.width / 2, FlxG.height / 2 + 300,0,"Loading...");
		text.size = 34;
		text.alignment = FlxTextAlign.CENTER;
		text.alpha = 0;

		kadeLogo = new FlxSprite(FlxG.width / 2, FlxG.height / 2).loadGraphic(Paths.image('KadeEngineLogo'));
		kadeLogo.x -= kadeLogo.width / 2;
		kadeLogo.y -= kadeLogo.height / 2 + 100;
		text.y -= kadeLogo.height / 2 - 80;
		text.x -= 170;
		kadeLogo.setGraphicSize(Std.int(kadeLogo.width * 0.6));
		kadeLogo.antialiasing = true;
		
		kadeLogo.alpha = 0;

		if ((FlxG.save.data.cacheImages || FlxG.save.data.cacheMusic) && FlxG.save.data.weekUnlocked >= 2)
		{
			tipText = new FlxText(kadeLogo.x, text.y + text.height * 1.3, kadeLogo.width, "Loading times too long? Turn off pre-caching in the 'Performance' tab within the options menu!");
			tipText.setFormat(Paths.font("playtime.ttf"), 35);
			tipText.color = 0xFFffef61;
			tipText.alignment = FlxTextAlign.CENTER;
			tipText.alpha = 0;
		}

		//Tips for future Samuel: If sound volume is '0', it doesn't play the sound until volume is < 0
		//Maybe we can fix that by adding a "disclaimerMusic.time" thing on update or sum shit idk
		//And I did exactly that.
		//Thank you past Samuel!
		cacheMusic = new FlxSound().loadEmbedded(Paths.music('loadingScreen'), true, false);
		cacheMusic.volume = 0;
		FlxG.sound.list.add(cacheMusic);
		disclaimerMusic = new FlxSound().loadEmbedded(Paths.music('disclaimerScreen'), true, false);
		disclaimerMusic.persist = true;
		disclaimerMusic.volume = 0;
		FlxG.sound.list.add(disclaimerMusic);

		#if cpp
		if (FlxG.save.data.cacheImages)
		{
			trace("caching images...");

			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/characters")))
			{
				if (!i.endsWith(".png"))
					continue;
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
		#end

		if (!FlxG.save.data.cacheImages && !FlxG.save.data.cacheMusic)
		{
			FlxG.camera.fade(FlxColor.BLACK, 0.8, true);
			add(kadeLogo);
			add(text);
		}
		else
		{
			toBeDone = Lambda.count(images) + Lambda.count(music);

			add(kadeLogo);
			add(text);

			FlxTween.tween(tipText, {alpha: 1}, 1, {ease: FlxEase.quartInOut, startDelay: 5});

			trace('starting caching..');
			
			#if cpp
			// update thread

			sys.thread.Thread.create(() -> {
				while(!loaded)
				{
					if (toBeDone != 0 && done != toBeDone)
						{
							var alpha = HelperFunctions.truncateFloat(done / toBeDone * 100,2) / 100;
							kadeLogo.alpha = alpha;
							text.alpha = alpha;
							text.text = "Loading... (" + done + "/" + toBeDone + ")";
							//text.x = text.height + 100;
						}
				}
			
			});
		}

		// cache thread

		sys.thread.Thread.create(() -> {
			cache();
		});
		#end

		super.create();

		FlxG.mouse.visible = false;
		
		if(FlxG.save.data != null && FlxG.save.data.fullscreen)
		{
			FlxG.fullscreen = FlxG.save.data.fullscreen;
			//trace('LOADED FULLSCREEN SETTING!!');
		}

		cacheMusic.fadeIn(8, 0, 0.4);
	}

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
		super.update(elapsed/2);
		//Planned on putting this at finishCaching but it don't appear to work
		if (syncedMusicTime)
		{	
			disclaimerMusic.time = cacheMusic.time;
			syncedMusicTime = false;
		}
	}


	function cache()
	{
		if (!FlxG.save.data.cacheMusic && !FlxG.save.data.cacheImages)
		{
			kadeLogo.alpha = 1;
			text.alpha = 1;
			text.text = "<<Press  ENTER>>";
		}
		else
		{
			trace("LOADING: " + toBeDone + " OBJECTS.");

			for (i in images)
			{
				var replaced = i.replace(".png","");
				var data:BitmapData = BitmapData.fromFile("assets/shared/images/characters/" + i);
				trace('id ' + replaced + ' file - assets/shared/images/characters/' + i + ' ${data.width}');
				var graph = FlxGraphic.fromBitmapData(data);
				graph.persist = true;
				graph.destroyOnNoUse = false;
				bitmapData.set(replaced,graph);
				done++;
			}

			for (i in music)
			{
				FlxG.sound.cache(Paths.inst(i));
				FlxG.sound.cache(Paths.voices(i));
				trace("cached " + i);
				done++;
			}

			trace("Finished caching...");

			trace(Assets.cache.hasBitmapData('GF_assets'));

			finishCaching();
		}
	}

	function finishCaching():Void
	{
		FlxG.sound.play(Paths.sound('returnMenu'));
		cacheMusic.fadeOut(0.38, 0);
		disclaimerMusic.fadeIn(0.38, 0, 0.4);
		syncedMusicTime = true;
		FlxG.camera.fade(FlxColor.BLACK, 0.4, false, function()
		{
			loaded = true;
			kadeLogo.destroy();
			text.destroy();
			new FlxTimer().start(0.2, function(tmr:FlxTimer)
			{
				FlxG.switchState(new DisclaimerScreen());
			});
		}, true);
	}

}
#end