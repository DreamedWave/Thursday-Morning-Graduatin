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
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.system.FlxSound;
import flixel.addons.transition.FlxTransitionableState;

using StringTools;

class CachingState extends MusicBeatMenu
{
	//Depracatad - will probs get rid of this soon
	var loaded = false;

	var goForTheMilk:Bool = false;

	public static var bitmapData:Map<String,FlxGraphic>;

	//Public Static so that it can be destroyed in disclaimerscreen
	public static var cacheMusic:FlxSound;
	public static var disclaimerMusic:FlxSound;

	var images:Array<String> = [];
	var music:Array<String> = [];
	var charts:Array<String> = [];

	var screen:CachingScreen = null;

	override function create()
	{
		#if windows
		if (FlxG.save.data.showPresence)
			DiscordClient.changePresence("Loading...", null, true, "apppresence-loading");
		#end

		//ForTesting
		FlxG.save.data.cacheImages = false;
		FlxG.save.data.cacheMusic = false;

		screen = new CachingScreen();
		add(screen);

		if (FlxG.save.data.cacheImages || FlxG.save.data.cacheMusic)
		{
			tipText = new FlxText(screen.vals[0], screen.vals[1] + screen.vals[2] * 1.3, screen.vals[3] - 240, "Loading times too long? Turn off pre-caching in the 'Performance' tab within the options menu!");
			tipText.setFormat(Paths.font("playtime.ttf"), 35);
			tipText.antialiasing = true;
			tipText.color = 0xffac9200;
			tipText.alignment = FlxTextAlign.CENTER;
			tipText.alpha = 0;
			tipText.screenCenter(X);
			add(tipText);
		}

		#if cpp
		if (!FlxG.save.data.cacheImages && !FlxG.save.data.cacheMusic)
			FlxG.camera.fade(FlxColor.BLACK, 1, true);
		else
		{
			FlxG.camera.fade(FlxColor.BLACK, 5, true);

			//Preload Menu Themes
			/*var sillyMenuDeterminator:String = 'peaceful';
			switch(FlxG.save.data.weekUnlocked)
			{
				case 1:
					sillyMenuDeterminator = 'freaky';
				case 2:
					sillyMenuDeterminator = 'glitchy';
				case 3:
					sillyMenuDeterminator = 'city';
				case 4:
					sillyMenuDeterminator = 'village';
			}*/

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


			screen.toBeDone = Lambda.count(images) + Lambda.count(music);

			Thread.create(() -> 
			{
				//Preload Menu Mus and Snd
				/*for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/music")))
				{
					if (i.startsWith(sillyMenuDeterminator) && i.endsWith(".ogg"))
					{
						i = StringTools.replace(i, ".ogg", "");
						Paths.music(i, '', false);
						trace(i);
						screen.toBeDone++;
						screen.done++;
					}
				}
				for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/sound")))
				{
					if (i.endsWith(sillyMenuDeterminator + ".ogg"))
					{
						i = StringTools.replace(i, ".ogg", "");
						Paths.music(i, '', false);
						trace(i);
						screen.toBeDone++;
						screen.done++;
					}
				}*/


				for (i in images)
				{
					Paths.image(i, '');
					screen.done++;
				}

				for (i in music)
				{
					Paths.inst(i);
					if (Paths.fileExists(Paths.voicesString(i), SOUND))
						Paths.voices(i);
					if (Paths.fileExists(Paths.miscsString(i), SOUND))
						Paths.miscs(i);
					if (Paths.fileExists(Paths.adaptiveMusString(i), SOUND))
						Paths.adaptiveMus(i);
					screen.done++;
				}

				finishCaching();
			});
		}
		#else
		FlxG.camera.fade(FlxColor.BLACK, 1, true);
		#end

		//Tips for future Samuel: If sound volume is '0', it doesn't play the sound until volume is < 0
		//Maybe we can fix that by adding a "disclaimerMusic.time" thing on update or sum shit idk
		//And I did exactly that.
		//Thank you past Samuel!
		//no this is bullshit, both of y'all past samuels are dumb af
		//...all samuels are dead now- Everyone, welcome Amiee to the dev team :33
		cacheMusic = new FlxSound().loadEmbedded(Paths.music('preMusic-loading'), true, false);
		cacheMusic.volume = 0;
		//FlxG.sound.list.add(cacheMusic);
		disclaimerMusic = new FlxSound().loadEmbedded(Paths.music('preMusic-disclaimer'), true, false);
		disclaimerMusic.persist = true;
		disclaimerMusic.volume = 0;
		//FlxG.sound.list.add(disclaimerMusic);

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
			if (!tweenedAlready && Main.isFocused && (FlxG.keys.justPressed.ANY || FlxG.mouse.justPressed || FlxG.mouse.justPressedMiddle || FlxG.mouse.justPressedRight))
			{
				FlxTween.tween(tipText, {alpha: 1}, 0.5, {type: ONESHOT, ease: FlxEase.quadOut});
				tweenedAlready = true;
			}
		}
	}

	function finishCaching():Void
	{
		FlxG.sound.play(Paths.sound('returnMenu'));
		cacheMusic.fadeOut(0.35, 0);
		disclaimerMusic.fadeIn(0.35, 0, 0.5);
		loaded = true;
		new FlxTimer().start(0.35, function(tmr:FlxTimer)
		{
			FlxG.switchState(new DisclaimerState());
		});
	}
}
#end