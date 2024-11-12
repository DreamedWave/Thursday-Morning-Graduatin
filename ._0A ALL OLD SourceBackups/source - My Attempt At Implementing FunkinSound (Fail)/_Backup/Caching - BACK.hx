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
import sys.thread.Thread;
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

class Caching extends MusicBeatMenu
{
	var toBeDone:Int = 0;
	var done:Int = 0;

	var loaded = false;

	var text:FlxText;
	var targetText:String = '';
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

		text = new FlxText(0, 0, "Loading...");
		text.size = 34;
		text.y = kadeLogo.y + kadeLogo.height - 80;
		text.alignment = FlxTextAlign.CENTER;

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

		#if cpp
		if (!FlxG.save.data.cacheImages && !FlxG.save.data.cacheMusic)
		{
			FlxG.camera.fade(FlxColor.BLACK, 1, true);
			text.text = "<<Press  ENTER>>";
			text.screenCenter(X);
		}
		else
		{
			FlxG.camera.fade(FlxColor.BLACK, 5, true);
			if (FlxG.save.data.cacheImages)
			{
				//Char Assets
				for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/characters")))
				{
					if (!i.endsWith(".png"))
						continue;
					else
						i = 'characters/' + StringTools.replace(i, ".png", "");
					images.push(i);
				}

				//Char HP-Bar Icons
				for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/images/icons")))
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
				//trace("caching music...");

				for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/songs")))
				{
					music.push(i);
				}
			}

			toBeDone = Lambda.count(images) + Lambda.count(music);

			Thread.create(() -> 
			{
				for (i in images)
				{
					Paths.image(i, '', true);
					done++;
				}

				for (i in music)
				{
					Paths.inst(i, true);
					if (Paths.fileExists(Paths.voicesString(i), SOUND))
						Paths.voices(i, true);
					if (Paths.fileExists(Paths.miscsString(i), SOUND))
						Paths.miscs(i, true);
					if (Paths.fileExists(Paths.adaptiveMusString(i), SOUND))
						Paths.adaptiveMus(i, true);
					done++;
				}

				finishCaching();
			});
		}
		#else
		FlxG.camera.fade(FlxColor.BLACK, 1, true);
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
		else
			cacheMusic.fadeIn(5, 0, 0.5);
	}

	var targetAlpha:Float = 0;
	var tweenedAlready:Bool = false;

	override function update(elapsed)
	{
		super.update(elapsed);

		if (!FlxG.save.data.cacheMusic && !FlxG.save.data.cacheImages)
		{
			if ((controls.ACCEPT || FlxG.mouse.justPressed) && !goForTheMilk)
			{
				goForTheMilk = true;
				finishCaching();
			}
		}
		else
		{
			if (toBeDone != 0)
			{
				if (done > toBeDone)
					done = toBeDone;
				if (text != null)
				{
					text.text = "Loading... (" + (done) + "/" + toBeDone + ")";
					text.screenCenter(X);
				}
			}
			if (!tweenedAlready && Main.isFocused && (FlxG.keys.justPressed.ANY || FlxG.mouse.justPressed || FlxG.mouse.justPressedMiddle || FlxG.mouse.justPressedRight))
			{
				FlxTween.tween(tipText, {alpha: 1}, 0.5, {type: ONESHOT, ease: FlxEase.quadOut});
				tweenedAlready = true;
			}
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