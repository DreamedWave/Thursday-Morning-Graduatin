package flixel.system.ui;

#if FLX_SOUND_SYSTEM
import flixel.FlxG;
import flixel.system.FlxAssets;
import flixel.util.FlxColor;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import openfl.Lib;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.Sprite;
import openfl.text.TextField;
import openfl.text.TextFormat;
import openfl.text.TextFormatAlign;
#if flash
import flash.text.AntiAliasType;
import flash.text.GridFitType;
#end



/**
 * The flixel sound tray, the little volume meter that pops down sometimes.
 * Accessed via `FlxG.game.soundTray` or `FlxG.sound.soundTray`.
 * Customized for TMG by AmieeWuzHere!
 */
class FlxSoundTray extends Sprite
{
	/**
	 * Because reading any data from DisplayObject is insanely expensive in hxcpp, keep track of whether we need to update it or not.
	 */
	public var active:Bool;

	/**
	 * Helps us auto-hide the sound tray after a volume change.
	 */
	var _timer:Float;

	/**
	 * Tweens the sound tray.
	 */
	var trayTween:FlxTween;

	/**
	 * Helps display the volume bars on the sound tray.
	 */
	var _bars:Array<Bitmap>;

	/**
	 * How wide the sound tray background is.
	 */
	var _width:Int = 80;

	var _defaultScale:Float = 2.0;

	/**The sound used when increasing the volume.**/
	public var volumeUpSound:String = "assets/sounds/soundtray/volumeUp";

	/**The sound used when decreasing the volume.**/
	public var volumeDownSound:String = 'assets/sounds/soundtray/volumeDown';

	/**Whether or not changing the volume should make noise.**/
	public var silent:Bool = false;

	/**A bool to temporarily disable the soundtray from working**/
	public var tempDisable:Bool = false;

	var text:TextField = new TextField();

	/**
	 * Sets up the "sound tray", the little volume meter that pops down sometimes.
	 */
	@:keep
	public function new()
	{
		super();

		alpha = 0;
		visible = false;
		scaleX = _defaultScale;
		scaleY = _defaultScale;
		var tmp:Bitmap = new Bitmap(new BitmapData(_width, 30, true, 0x7F000000));
		screenCenter();
		addChild(tmp);

		text.width = tmp.width;
		text.height = tmp.height;
		text.multiline = true;
		text.wordWrap = true;
		text.selectable = false;

		#if flash
		text.embedFonts = true;
		text.antiAliasType = AntiAliasType.NORMAL;
		text.gridFitType = GridFitType.PIXEL;
		#else
		#end
		var dtf:TextFormat = new TextFormat('Monsterrat', 10, 0xffffff);
		dtf.align = TextFormatAlign.CENTER;
		text.defaultTextFormat = dtf;
		text.text = "- VOLUME +";
		text.y = 16;
		addChild(text);

		var bx:Int = 10;
		var by:Int = 14;
		_bars = new Array();

		for (i in 0...10)
		{
			tmp = new Bitmap(new BitmapData(4, i + 1, false, FlxColor.WHITE));
			tmp.x = bx;
			tmp.y = by;
			addChild(tmp);
			_bars.push(tmp);
			bx += 6;
			by--;
		}

		y = -height;
		visible = false;
	}

	/**
	 * This function just updates the soundtray object.
	 */
	 public function update(elapsedMS:Float):Void
	{
		if (FlxG.sound.volume > 0 && globalVolume != 0 && !FlxG.sound.muted)
		{
			if (_timer > 0)
			{
				_timer -= elapsedMS / 1000;
			}
			else 
			{
				if (!isRetreating)
				{
					if (trayTween != null)
						trayTween.cancel();

					isRetreating = true;
					trayTween = FlxTween.tween(this, {y: -60, alpha: 0}, 0.5, 
						{
							ease: FlxEase.cubeIn,
							onComplete: function(twn:FlxTween)
							{
								trayTween = null;
								visible = false;
								active = false;
						
								// Save sound preferences
								if (FlxG.save.isBound)
								{
									FlxG.save.data.mute = FlxG.sound.muted;
									FlxG.save.data.volume = FlxG.sound.volume;
									FlxG.save.flush();
								}
							}
						});
				}
				else if (visible && !trayTween.active)
				{
					trayTween = FlxTween.tween(this, {y: -60, alpha: 0}, 0.35, 
						{
							ease: FlxEase.linear,
							onComplete: function(twn:FlxTween)
							{
								trayTween = null;
								visible = false;
								active = false;
						
								// Save sound preferences
								if (FlxG.save.isBound)
								{
									FlxG.save.data.mute = FlxG.sound.muted;
									FlxG.save.data.volume = FlxG.sound.volume;
									FlxG.save.flush();
								}
							}
						});
				}
			}
		}
	}

	var globalVolume:Int = Math.round(FlxG.sound.logToLinear(FlxG.sound.volume) * 10);
	var isRetreating:Bool = true;

	/**
	 * Makes the little volume tray slide out.
	 *
	 * @param	up Whether the volume is increasing.
	 */
	public function show(up:Bool = false):Void
	{
		if (!tempDisable)
		{
			if (!silent)
			{
				var sound;
				if (!FlxG.sound.muted && text.text != "0  MUTE  0")
					sound = FlxAssets.getSound(up ? volumeUpSound : volumeDownSound);
				else
					sound = FlxAssets.getSound("assets/sounds/soundtray/volumeUnmute");

				if (sound != null)
					FlxG.sound.load(sound).play();
			}

			_timer = 1.5; //in seconds

			//Only tween if shit is about to hide, otherwise, nothing happens
			if (isRetreating)
			{
				//Cancel any tween that might be happening right meow
				if (trayTween != null)
					trayTween.cancel();

				isRetreating = false;
				visible = true;
				active = true;

				trayTween = FlxTween.tween(this, {y: 0, alpha: 1}, 0.75, 
					{
						ease: FlxEase.elasticOut, 
						onComplete: function(twn:FlxTween)
						{
							trayTween = null;
						}
					});
			}

			globalVolume = Math.round(FlxG.sound.logToLinear(FlxG.sound.volume) * 10);

			if (FlxG.sound.muted)
			{
				globalVolume = 0;
				if (text.text != "0  MUTE  0")
					text.text = "0  MUTE  0";
			}
			else
				text.text = "- VOLUME +";

			trace('Global Volume: ' + globalVolume);

			for (i in 0..._bars.length)
			{
				if (i < globalVolume)
				{
					_bars[i].alpha = 1;
				}
				else
				{
					_bars[i].alpha = 0.5;
				}
			}
		}
	}

	var defaultX:Float = 0;

	public function screenCenter():Void
	{
		scaleX = _defaultScale;
		scaleY = _defaultScale;

		x = (0.5 * (Lib.current.stage.stageWidth - _width * _defaultScale) - FlxG.game.x);
		defaultX = x;
	}
}
#end
