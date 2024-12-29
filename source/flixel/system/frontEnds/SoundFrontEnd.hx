package flixel.system.frontEnds;

#if FLX_SOUND_SYSTEM
import flixel.FlxG;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.system.FlxAssets.FlxSoundAsset;
import flixel.system.FlxSound;
import flixel.system.FlxSoundGroup;
import flixel.system.ui.FlxSoundTray;
import flixel.util.FlxSignal;
import openfl.Assets;
import openfl.media.Sound;
#if (openfl >= "8.0.0")
import openfl.utils.AssetType;
#end

/**
 * Accessed via `FlxG.sound`.
 */
@:allow(flixel.FlxG)
class SoundFrontEnd
{
	/**
	 * A handy container for a background music object.
	 */
	public var music:FlxSound;

	/**
	 * Whether or not the game sounds are muted.
	 */
	public var muted:Bool = false;

	/**
	 * Set this hook to get a callback whenever the volume changes.
	 * Function should take the form myVolumeHandler(volume:Float).
	 */
	@:deprecated("volumeHandler is deprecated, use onVolumeChange, instead")
	public var volumeHandler:Float->Void;
 
	/**
	 * A signal that gets dispatched whenever the volume changes.
	 */
	 public var onVolumeChange(default, null):FlxTypedSignal<Float->Void> = new FlxTypedSignal<Float->Void>();

	#if FLX_KEYBOARD
	/**
	 * The key codes used to increase volume (see FlxG.keys for the keys available).
	 * Default keys: + (and numpad +). Set to null to deactivate.
	 */
	public var volumeUpKeys:Array<FlxKey> = [PLUS, NUMPADPLUS];

	/**
	 * The keys to decrease volume (see FlxG.keys for the keys available).
	 * Default keys: - (and numpad -). Set to null to deactivate.
	 */
	public var volumeDownKeys:Array<FlxKey> = [MINUS, NUMPADMINUS];

	/**
	 * The keys used to mute / unmute the game (see FlxG.keys for the keys available).
	 * Default keys: 0 (and numpad 0). Set to null to deactivate.
	 */
	public var muteKeys:Array<FlxKey> = [ZERO, NUMPADZERO];
	#end

	/**
	 * Whether or not the soundTray should be shown when any of the
	 * volumeUp-, volumeDown- or muteKeys is pressed.
	 */
	public var soundTrayEnabled:Bool = true;
	
	#if FLX_SOUND_TRAY
	/**
	 * The sound tray display container.
	 * A getter for `FlxG.game.soundTray`.
	 */
	public var soundTray(get, never):FlxSoundTray;
	
	inline function get_soundTray()
	{
		return FlxG.game.soundTray;
	}
	#end

	/**
	 * The group sounds played via playMusic() are added to unless specified otherwise.
	 */
	public var defaultMusicGroup:FlxSoundGroup = new FlxSoundGroup();

	/**
	 * The group sounds in load() / play() / stream() are added to unless specified otherwise.
	 */
	public var defaultSoundGroup:FlxSoundGroup = new FlxSoundGroup();

	/**
	 * A list of all the sounds being played in the game.
	 */
	public var list(default, null):FlxTypedGroup<FlxSound> = new FlxTypedGroup<FlxSound>();

	/**
	 * Set this to a number between 0 and 1 to change the global volume.
	 */
	public var volume(default, set):Float = 1;

	/**
	 * Set up and play a looping background soundtrack.
	 *
	 * @param   embeddedMusic  The sound file you want to loop in the background.
	 * @param   volume         How loud the sound should be, from 0 to 1.
	 * @param   looped         Whether to loop this music.
	 * @param   group          The group to add this sound to.
	 */
	public function playMusic(?embeddedMusic:FlxSoundAsset, ?volume = 1.0, ?looped = true, ?group:FlxSoundGroup):Void
	{
		if (!queuedUpMusic)
		{
			if (embeddedMusic == null)
			{
				trace("You didn't specify a music path!");
				FlxG.log.warn("[playMusic() SoundFrontEnd.hx] You didn't specify a music path!");
				return;
			}

			//trace('loaded music in playMusic()');
			loadMusic(embeddedMusic, volume, looped, group, false);
		}
		else
			queuedUpMusic = false;
		//trace('playin music: ' + music);
		music.play();
		//trace('is music playng? = ' + music.playing);

	}

	/**
	 * CUSTOM for TMG
	 * Set up a looping background soundtrack. Separated from play() to allow the music to be "queued up"
	 * Pls no judge i am beginner programmer :<
	 *
	 * @param   embeddedMusic  The sound file you want to loop in the background.
	 * @param   volume         How loud the sound should be, from 0 to 1.
	 * @param   looped         Whether to loop this music.
	 * @param   group          The group to add this sound to.
	 * @param	calledStandalone	internal function that determines if this funct was called on it's own rather than thru playMusic.
	 */
	public var queuedUpMusic:Bool = false;
	public function loadMusic(embeddedMusic:FlxSoundAsset, volume = 1.0, looped = true, ?group:FlxSoundGroup, ?calledStandalone:Bool = true):Void
	{
		if (embeddedMusic == null)
		{
			trace("You didn't specify a music path!");
			FlxG.log.warn("[playMusic() SoundFrontEnd.hx] You didn't specify a music path!");
			return;
		}

		if (music == null)
			music = new FlxSound();
		else if (music.active)
		//{
			music.stop();
			//trace('stoppedMusic');
		//}

		music.loadEmbedded(embeddedMusic, looped);
		music.volume = volume;
		music.persist = true;
		music.group = (group == null) ? defaultMusicGroup : group;
		queuedUpMusic = calledStandalone;
		//if (calledStandalone)
			//trace("loaded standalone: " + music);
	}

	/**
	 * Creates a new FlxSound object.
	 *
	 * @param   embeddedSound   The embedded sound resource you want to play.  To stream, use the optional URL parameter instead.
	 * @param   volume          How loud to play it (0 to 1).
	 * @param   looped          Whether to loop this sound.
	 * @param   group           The group to add this sound to.
	 * @param   autoDestroy     Whether to destroy this sound when it finishes playing.
	 *                          Leave this value set to "false" if you want to re-use this FlxSound instance.
	 * @param   autoPlay        Whether to play the sound.
	 * @param   url             Load a sound from an external web resource instead.  Only used if EmbeddedSound = null.
	 * @param   onComplete      Called when the sound finished playing.
	 * @param   onLoad          Called when the sound finished loading.  Called immediately for succesfully loaded embedded sounds.
	 * @return  A FlxSound object.
	 */
	public function load(?embeddedSound:FlxSoundAsset, volume = 1.0, looped = false, ?group:FlxSoundGroup, autoDestroy = false, autoPlay = false, ?url:String,
			?onComplete:Void->Void, ?onLoad:Void->Void):FlxSound
	{
		if ((embeddedSound == null) && (url == null))
		{
			FlxG.log.warn("FlxG.sound.load() requires either\nan embedded sound or a URL to work.");
			return null;
		}

		var sound:FlxSound = list.recycle(FlxSound);

		if (embeddedSound != null)
		{
			sound.loadEmbedded(embeddedSound, looped, autoDestroy, onComplete);
			loadHelper(sound, volume, group, autoPlay);
			// Call OnlLoad() because the sound already loaded
			if (onLoad != null && sound._sound != null)
				onLoad();
		}
		else
		{
			var loadCallback = onLoad;
			if (autoPlay)
			{
				// Auto play the sound when it's done loading
				loadCallback = function()
				{
					sound.play();

					if (onLoad != null)
						onLoad();
				}
			}

			sound.loadStream(url, looped, autoDestroy, onComplete, loadCallback);
			loadHelper(sound, volume, group);
		}

		return sound;
	}

	function loadHelper(sound:FlxSound, volume:Float, group:FlxSoundGroup, autoPlay = false):FlxSound
	{
		sound.volume = volume;

		if (autoPlay)
		{
			sound.play();
		}

		sound.group = (group == null) ? defaultSoundGroup : group;
		return sound;
	}

	/**
	 * Method for sound caching (especially useful on mobile targets). The game may freeze
	 * for some time the first time you try to play a sound if you don't use this method.
	 *
	 * @param   embeddedSound  Name of sound assets specified in your .xml project file
	 * @return  Cached Sound object
	 */
	public inline function cache(embeddedSound:String):Sound
	{
		// load the sound into the OpenFL assets cache
		if (Assets.exists(embeddedSound, AssetType.SOUND) || Assets.exists(embeddedSound, AssetType.MUSIC))
			return Assets.getSound(embeddedSound, true);
		FlxG.log.error('Could not find a Sound asset with an ID of \'$embeddedSound\'.');
		return null;
	}

	/**
	 * Calls FlxG.sound.cache() on all sounds that are embedded.
	 * WARNING: can lead to high memory usage.
	 */
	public function cacheAll():Void
	{
		for (id in Assets.list(AssetType.SOUND))
		{
			cache(id);
		}
	}

	/**
	 * Plays a sound from an embedded sound. Tries to recycle a cached sound first.
	 *
	 * @param   embeddedSound  The embedded sound resource you want to play.
	 * @param   volume         How loud to play it (0 to 1).
	 * @param   looped         Whether to loop this sound.
	 * @param   group          The group to add this sound to.
	 * @param   autoDestroy    Whether to destroy this sound when it finishes playing.
	 *                         Leave this value set to "false" if you want to re-use this FlxSound instance.
	 * @param   onComplete     Called when the sound finished playing
	 * @return  A FlxSound object.
	 */
	public function play(embeddedSound:FlxSoundAsset, volume = 1.0, looped = false, ?group:FlxSoundGroup, autoDestroy = true, ?onComplete:Void->Void):FlxSound
	{
		if ((embeddedSound is String))
		{
			embeddedSound = cache(embeddedSound);
		}
		var sound = list.recycle(FlxSound);
		sound.loadEmbedded(embeddedSound, looped, autoDestroy, onComplete);
		return loadHelper(sound, volume, group, true);
	}

	/**
	 * Plays a sound from a URL. Tries to recycle a cached sound first.
	 * NOTE: Just calls FlxG.sound.load() with AutoPlay == true.
	 *
	 * @param   url          Load a sound from an external web resource instead.
	 * @param   volume       How loud to play it (0 to 1).
	 * @param   looped       Whether to loop this sound.
	 * @param   group        The group to add this sound to.
	 * @param   autoDestroy  Whether to destroy this sound when it finishes playing.
	 *                       Leave this value set to "false" if you want to re-use this FlxSound instance.
	 * @param   onComplete   Called when the sound finished playing
	 * @param   onLoad       Called when the sound finished loading.
	 * @return  A FlxSound object.
	 */
	public function stream(url:String, volume = 1.0, looped = false, ?group:FlxSoundGroup, autoDestroy = true, ?onComplete:Void->Void,
			?onLoad:Void->Void):FlxSound
	{
		return load(null, volume, looped, group, autoDestroy, true, url, onComplete, onLoad);
	}

	/**
	 * Pause all sounds currently playing.
	 */
	public function pause():Void
	{
		if (music != null && music.exists && music.active)
		{
			music.pause();
		}

		for (sound in list.members)
		{
			if (sound != null && sound.exists && sound.active)
			{
				sound.pause();
			}
		}
	}

	/**
	 * Resume playing existing sounds.
	 */
	public function resume():Void
	{
		if (music != null && music.exists)
		{
			music.resume();
		}

		for (sound in list.members)
		{
			if (sound != null && sound.exists)
			{
				sound.resume();
			}
		}
	}

	/**
	 * Called by FlxGame on state changes to stop and destroy sounds.
	 *
	 * @param   forceDestroy  Kill sounds even if persist is true.
	 */
	public function destroy(forceDestroy = false):Void
	{
		if (music != null && (forceDestroy || !music.persist))
		{
			destroySound(music);
			music = null;
		}

		for (sound in list.members)
		{
			if (sound != null && (forceDestroy || !sound.persist))
			{
				destroySound(sound);
			}
		}
	}

	function destroySound(sound:FlxSound):Void
	{
		defaultMusicGroup.remove(sound);
		defaultSoundGroup.remove(sound);
		sound.destroy();
	}

	#if FLX_SOUND_TRAY
	/**
	 * Toggles muted, also activating the sound tray.
	 */
	public function toggleMuted():Void
	{
		muted = !muted;

		if (volumeHandler != null)
		{
			volumeHandler(muted ? 0 : volume);
		}

		onVolumeChange.dispatch(muted ? 0 : volume);

		showSoundTray(true);
	}

	//Stuff from https://github.com/FunkinCrew/flixel/blob/dev-6.0.0-latest/flixel/system/frontEnds/SoundFrontEnd.hx
	//Very cool stuff y'all!! Epic!!
	/**
	 * Changes the volume by a certain amount, also activating the sound tray.
	 * Imma actually try rounding it out - idk if this will work or not
	 */
	public function changeVolume(Amount:Float):Void
	{
		muted = false;
		volume = FlxMath.roundDecimal(logToLinear(volume), 3);
		volume += Amount;
		volume = FlxMath.roundDecimal(linearToLog(volume), 3);
		showSoundTray(Amount > 0);
		trace('soundVol ACTUAL: ' + volume);
	}

	public function linearToLog(x:Float, minValue:Float = 0.001):Float
	{
		// If linear volume is 0, return 0
		if (x <= 0) return 0;

		// Ensure x is between 0 and 1
		x = Math.min(1, x);

		// Convert linear scale to logarithmic
		//trace('soundVol Lin->Log: ' + Math.exp(Math.log(minValue) * (1 - x)));
		return Math.exp(Math.log(minValue) * (1 - x));
	}

	public function logToLinear(x:Float, minValue:Float = 0.001):Float
	{
		// If logarithmic volume is 0, return 0
		if (x <= 0) return 0;

		// Ensure x is between minValue and 1
		x = Math.min(1, x);

		var toReturn:Float = 1 - (Math.log(Math.max(x, minValue)) / Math.log(minValue));
		// Convert logarithmic scale to linear
		//trace('soundVol Log->Lin: ' + toReturn);
		return toReturn;
	}

	
	/**
	 * Shows the sound tray if it is enabled.
	 * @param up Whether or not the volume is increasing.
	 */
	public function showSoundTray(up:Bool = false):Void
	{
		if (FlxG.game.soundTray != null && soundTrayEnabled)
			FlxG.game.soundTray.show(up);
	}
	#end

	function new()
	{
		loadSavedPrefs();
	}

	/**
	 * Called by the game loop to make sure the sounds get updated each frame.
	 */
	@:allow(flixel.FlxGame)
	function update(elapsed:Float):Void
	{
		if (music != null && music.active)
			music.update(elapsed);

		if (list != null && list.active)
			list.update(elapsed);

		#if FLX_KEYBOARD
		#if FLX_SOUND_TRAY
		if (!FlxG.game.soundTray.tempDisable)
		{
			if (FlxG.keys.anyJustReleased(muteKeys))
				toggleMuted();
			if(FlxG.keys.anyJustReleased(volumeUpKeys))
				changeVolume(0.1);
			else if (FlxG.keys.anyJustReleased(volumeDownKeys))
				changeVolume(-0.1);
		}
		#end
		#end

		//To show soundtray when the game starts out muted
		if (forceShowSoundtray)
		{
			forceShowSoundtray = false;
			showSoundTray(true);
		}
	}

	@:allow(flixel.FlxGame)
	function onFocusLost():Void
	{
		if (music != null)
		{
			music.onFocusLost();
		}

		for (sound in list.members)
		{
			if (sound != null)
			{
				sound.onFocusLost();
			}
		}
	}

	@:allow(flixel.FlxGame)
	function onFocus():Void
	{
		if (music != null)
		{
			music.onFocus();
		}

		for (sound in list.members)
		{
			if (sound != null)
			{
				sound.onFocus();
			}
		}
	}

	/**
	 * Loads saved sound preferences if they exist.
	 */
	var forceShowSoundtray:Bool = false; //For when the game starts out muted
	function loadSavedPrefs():Void
	{
		if (!FlxG.save.isBound)
			return;

		if (FlxG.save.data.volume != null)
		{
			volume = FlxG.save.data.volume;
		}

		if (FlxG.save.data.mute != null)
		{
			muted = FlxG.save.data.mute;
		}

		var globalVol:Float = Math.round(logToLinear(volume) * 10);
		if (globalVol <= 0 || muted)
			forceShowSoundtray = true;
	}

	@:haxe.warning("-WDeprecated")
	function set_volume(Volume:Float):Float
	{
		Volume = FlxMath.bound(Volume, 0, 1);

		if (volumeHandler != null)
		{
			volumeHandler(muted ? 0 : Volume);
		}

		onVolumeChange.dispatch(muted ? 0 : Volume);

		return volume = Volume;
	}
}
#end
