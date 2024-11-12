package;

import flixel.graphics.FlxGraphic;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.Assets;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import openfl.system.System;
#if sys
import sys.io.File;
import sys.FileSystem;
#end
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;
import haxe.Json;

import flash.media.Sound;

using StringTools;

class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static function getPath(file:String, type:AssetType, library:Null<String>)
	{
		if (library != null && library != '')
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

		return getPreloadPath(file);
	}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else if (library == "minigame") getMinigamePath(file, library); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static function getMinigamePath(file:String, library:String)
	{
		return 'assets/$library/$file';
	}

	inline static function getPreloadPath(file:String)
	{
		return 'assets/$file';
	}

	inline static public function file(file:String, ?library:String, type:AssetType = TEXT)
	{
		return getPath(file, type, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String)
	{
		return getPath('data/$key.json', TEXT, library);
	}

	inline static public function ogmo(key:String, ?library:String)
	{
		return getPath('data/$key.ogmo', TEXT, library);
	}

	inline static public function video(key:String, ?library:String)
	{
		#if debug
		trace('assets/videos/$key.mp4');
		#end
		return getPath('videos/$key.mp4', BINARY, library);
	}

	//from Psych AAAAAAAAAAAAAAAA
	//I am but a lowly thief, anyways--
	static public function videoMusic(key:String, ?library:String, ?isPersistent:Bool = false):Sound
	{
		var videoMusic:Sound = returnSound('videos', key, library, isPersistent);
		return videoMusic;
	}


	static public function sound(key:String, ?library:String, ?isPersistent:Bool = false):Sound
	{
		var sound:Sound = returnSound('sounds', key, library, isPersistent);
		return sound;
	}

	static public function soundString(key:String, ?library:String):String
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}
	
	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}


	inline static public function music(key:String, ?library:String, ?isPersistent:Bool = false):Sound
	{
		var file:Sound = returnSound('music', key, library);
		return file;
	}

	static public function musicString(key:String, ?library:String):String
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function musicRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return music(key + FlxG.random.int(min, max), library);
	}


	inline static public function voices(song:String, ?isPersistent:Bool = false):Any
	{
		#if html5
		return 'songs:assets/songs/${formatToSongPath(song)}/Voices.$SOUND_EXT';
		#else
		var songKey:String = '${formatToSongPath(song)}/Voices';
		var voices = returnSound('songs', songKey, '', isPersistent);
		return voices;
		#end
	}

	inline static public function voicesString(song:String)
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
		return 'songs:assets/songs/${songLowercase}/Voices.$SOUND_EXT';
	}


	inline static public function inst(song:String, ?isPersistent:Bool = false):Any
	{
		#if html5
		return 'songs:assets/songs/${formatToSongPath(song)}/Inst.$SOUND_EXT';
		#else
		var songKey:String = '${formatToSongPath(song)}/Inst';
		var inst = returnSound('songs', songKey, '', isPersistent);
		return inst;
		#end
	}

	inline static public function instString(song:String):String
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
		return 'songs:assets/songs/${songLowercase}/Inst.$SOUND_EXT';
	}


	inline static public function miscs(song:String, ?isPersistent:Bool = false)
	{
		#if html5
		return 'songs:assets/songs/${formatToSongPath(song)}/Miscs.$SOUND_EXT';
		#else
		var songKey:String = '${formatToSongPath(song)}/Miscs';
		var miscs = returnSound('songs', songKey, '', isPersistent);
		return miscs;
		#end
	}

	inline static public function miscsString(song:String)
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
		return 'songs:assets/songs/${songLowercase}/Miscs.$SOUND_EXT';
	}


	inline static public function adaptiveMus(song:String, ?isPersistent:Bool = false):Any
	{
		#if html5
		return 'songs:assets/songs/${formatToSongPath(song)}/LowHP.$SOUND_EXT';
		#else
		var songKey:String = '${formatToSongPath(song)}/LowHP';
		var adaptiveMus = returnSound('songs', songKey, '', isPersistent);
		return adaptiveMus;
		#end
	}
	
	inline static public function adaptiveMusString(song:String)
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
		return 'songs:assets/songs/${songLowercase}/LowHP.$SOUND_EXT';
	}
	//The string versions of these shits are for the fileExists() function
	
	inline static public function image(key:String, ?library:String, ?isPersistent:Bool = false):FlxGraphic
	{
		// streamlined the assets process more
		var returnAsset:FlxGraphic = returnGraphic(key, library, isPersistent);
		return returnAsset;
	}

	inline static public function imageString(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function formatToSongPath(path:String) 
	{
		var invalidChars = ~/[~&\\;:<>#]/;
		var hideChars = ~/[,'"%?!]/;

		var path = invalidChars.split(path.replace(' ', '-')).join("-");
		return hideChars.split(path).join("").toLowerCase();
	}

	// completely rewritten asset loading? fuck!
	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static function returnGraphic(key:String, ?library:String, ?addImageToExclusion:Bool = false) 
	{
		var path = getPath('images/$key.png', IMAGE, library);
		if (OpenFlAssets.exists(path, IMAGE)) 
		{
			if(!currentTrackedAssets.exists(path)) 
			{
				var newGraphic:FlxGraphic = FlxG.bitmap.add(path, false, path);
				newGraphic.persist = true;
				currentTrackedAssets.set(path, newGraphic);
			}
			if (addImageToExclusion)
				dumpExclusions.push(path);
			localTrackedAssets.push(path);
			return currentTrackedAssets.get(path);
		}
		else
		{
			#if debug
			trace('oh no [' + path + '] is returning null NOOOO');
			#end
			return null;
		}
	}

	public static var currentTrackedSounds:Map<String, Sound> = [];
	public static function returnSound(path:String, key:String, ?library:String, ?addSoundToExclusion:Bool = false) {
		// I hate this so god damn much
		var gottenPath:String = getPath('$path/$key.$SOUND_EXT', SOUND, library);
		gottenPath = gottenPath.substring(gottenPath.indexOf(':') + 1, gottenPath.length);
		//trace(gottenPath);
		if(!currentTrackedSounds.exists(gottenPath))
		{
			var folder:String = '';
			if(path == 'songs') 
				folder = 'songs:';

			currentTrackedSounds.set(gottenPath, OpenFlAssets.getSound(folder + getPath('$path/$key.$SOUND_EXT', SOUND, library)));
		}
		if (addSoundToExclusion)
			dumpExclusions.push(gottenPath);
		localTrackedAssets.push(gottenPath);
		return currentTrackedSounds.get(gottenPath);
	}

	//sounds to be excluded from being cleared
	public static var dumpExclusions:Array<String> = 
	[
		'assets/images/trans_circleSharp.png',
		'flixel/sounds/volumeUnmute',
		'flixel/sounds/volumeUp',
		'flixel/sounds/volumeDown'
	];

	// define the locally tracked assets
	// haya I love you for the base cache dump I took to the max
	public static var localTrackedAssets:Array<String> = [];
	public static function clearUnusedMemory():Void
	{
		//trace(dumpExclusions);
		// clear non local assets in the tracked assets list
		for (key in currentTrackedAssets.keys()) 
		{
			// if it is not currently contained within the used local assets
			if (!localTrackedAssets.contains(key)
				&& !dumpExclusions.contains(key) && !key.startsWith('flixel.addons.transition')) 
			{
				//trace('clear unused: ' + key);
				// get rid of it
				var obj = currentTrackedAssets.get(key);
				@:privateAccess
				if (obj != null) 
				{
					openfl.Assets.cache.removeBitmapData(key);
					FlxG.bitmap._cache.remove(key);
					obj.destroy();
					currentTrackedAssets.remove(key);
				}
			}
		}
		// run the garbage collector for good measure lmfao
		System.gc();
	}

	public static function clearStoredMemory(?clearExclusions:Bool = false):Void
	{
		//Clear exclusions
		if (clearExclusions)
			dumpExclusions = [];
		// clear anything not in the tracked assets list
		@:privateAccess
		for (key in FlxG.bitmap._cache.keys())
		{
			var obj = FlxG.bitmap._cache.get(key);
			if (obj != null && !currentTrackedAssets.exists(key) && !dumpExclusions.contains(key) && !key.startsWith('flixel.addons.transition')) 
			{
				//trace('clear stored?: ' + key);
				openfl.Assets.cache.removeBitmapData(key);
				FlxG.bitmap._cache.remove(key);
				obj.destroy();
			}
		}

		// clear all sounds that are cached
		for (key in currentTrackedSounds.keys()) 
		{
			if (!localTrackedAssets.contains(key)
			&& !dumpExclusions.contains(key) && !key.startsWith('flixel.addons.transition') && key != null) 
			{
				//trace('clear stored sound?: ' + key);
				//trace('test: ' + dumpExclusions, key);
				Assets.cache.clear(key);
				currentTrackedSounds.remove(key);
			}
		}
		// flags everything to be cleared out next unused memory clear
		localTrackedAssets = [];
		#if !html5 openfl.Assets.cache.clear("songs"); #end
	}

	inline static public function fileExists(key:String, type:AssetType, ?library:String)
	{
		if(OpenFlAssets.exists(getPath(key, type, library))) 
		{
			return true;
		}
		return false;
	}

	inline static public function getSparrowAtlas(key:String, ?library:String, ?isCharacter:Bool = false)
	{
		if (isCharacter)
			return FlxAtlasFrames.fromSparrow(image('characters/$key', library), file('images/characters/$key.xml', library));
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	#if cpp
	inline static public function imageCached(key:String):FlxGraphic
	{
		var data = Caching.bitmapData.get(key);
		#if debug
		trace('finding ${key} - ${data.bitmap}');
		#end
		return data;
	}
	#end
	
	inline static public function getPackerAtlas(key:String, ?library:String, ?isCharacter:Bool = false)
	{
		var usecahce = FlxG.save.data.cacheImages;
		#if !cpp
		usecahce = false;
		#end
		if (isCharacter)
			if (usecahce)
				#if cpp
				return FlxAtlasFrames.fromSpriteSheetPacker(imageCached(key), file('images/$key.txt', library));
				#else
				return null;
				#end
			else
				return FlxAtlasFrames.fromSpriteSheetPacker(image('characters/$key'), file('images/characters/$key.txt', library));
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}
}
