package flixel.sound.filters;

import flixel.util.FlxDestroyUtil;
import flixel.system.FlxSound;
import flixel.system.FlxAssets.FlxSoundAsset;
import flash.media.Sound;
import openfl.Assets;
#if (openfl >= "8.0.0")
import openfl.utils.AssetType;
#end

/**
 * A type of `FlxSound` that can have a `FlxSoundFilter` attached and automatically update it.
 */
class FlxFilteredSound extends FlxSound
{
	/**
	 * The audio filter used for this sound.
	 */
	public var filter(default, set):FlxSoundFilter;

	private function set_filter(value:FlxSoundFilter)
	{
		if (filter == value) 
			return filter; //no change

		if (filter != null) 
			filter.removeFilter(this); //remove existing filter

		if (value != null) 
			value.applyFilter(this); //apply new filter

		return filter = value;
	}

	//Same except it returns an FlxFilteredSound isntead
	override public function loadEmbedded(EmbeddedSound:FlxSoundAsset, Looped:Bool = false, AutoDestroy:Bool = true, ?OnComplete:Void->Void):FlxFilteredSound
	{
		if (EmbeddedSound == null)
			return this;

		cleanup(true);

		if ((EmbeddedSound is Sound))
		{
			_sound = EmbeddedSound;
		}
		else if ((EmbeddedSound is Class))
		{
			_sound = Type.createInstance(EmbeddedSound, []);
		}
		else if ((EmbeddedSound is String))
		{
			if (Assets.exists(EmbeddedSound, AssetType.SOUND) || Assets.exists(EmbeddedSound, AssetType.MUSIC))
				_sound = Assets.getSound(EmbeddedSound);
			else
				FlxG.log.error('Could not find a Sound asset with an ID of \'$EmbeddedSound\'.');
		}

		// NOTE: can't pull ID3 info from embedded sound currently
		return init(Looped, AutoDestroy, OnComplete);
	}

	override function init(Looped:Bool = false, AutoDestroy:Bool = true, ?OnComplete:Void->Void):FlxFilteredSound
	{
		looped = Looped;
		autoDestroy = AutoDestroy;
		updateTransform();
		exists = true;
		onComplete = OnComplete;
		#if FLX_PITCH
		pitch = 1;
		#end
		_length = (_sound == null) ? 0 : _sound.length;
		endTime = _length;
		return this;
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (filter != null)
			filter.applyFilter(this);
	}

	override public function destroy()
	{
		if (filter != null && filter.destroyWithSound)
			FlxDestroyUtil.destroy(filter);

		super.destroy();
	}
}