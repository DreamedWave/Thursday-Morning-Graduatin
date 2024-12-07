package;

import lime.app.Application;
import lime.system.DisplayMode;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.tweens.FlxTween;
import Controls.KeyboardScheme;
//import flixel.FlxG;
import openfl.display.FPS;
import openfl.Lib;

using StringTools;

//There's DEFINITELY a better way of doing all this
//...bUUUUTTT if it aint broke dont fix it (coping)
class OptionCategory
{
	private var _options:Array<Option> = new Array<Option>();
	public final function getOptions():Array<Option>
	{
		return _options;
	}

	public final function addOption(opt:Option)
	{
		_options.push(opt);
	}

	
	public final function removeOption(opt:Option)
	{
		_options.remove(opt);
	}

	private var _name:String = "New Category";
	public final function getName() {
		return _name;
	}

	public function new (catName:String, options:Array<Option>)
	{
		_name = catName;
		_options = options;
	}
}

class Option
{
	private var description:String = "";
	private var display:String;
	private var isSlider:Bool = false;
	public var canSpeedUp:Bool = true;

	public function new()
	{
		display = updateDisplay();
	}

	public final function getDisplay():String
	{
		return display;
	}

	public final function getDescription():String
	{
		return description;
	}

	public final function checkIfSlider():Bool
	{
		return isSlider;
	}

	public function getValue():String { return throw "stub!"; };
	public function press():Bool { return throw "stub!"; }
	private function updateDisplay():String { return throw "stub!"; }
	public function left():Bool { return throw "stub!"; }
	public function right():Bool { return throw "stub!"; }
	public function resetConfirmBool() { trace('this does nothing unless its a reset option lol'); };
}

class DFJKOption extends Option
{
	private var controls:Controls;

	public function new(controls:Controls, desc:String)
	{
		super();
		this.controls = controls;
		description = desc;
	}

	override public function press():Bool
	{
		OptionsMenu.instance.openSubState(new KeyBindMenu());
		FlxG.sound.play(Paths.sound("scrollMenu"));
		return false;
	}

	override private function updateDisplay():String
	{
		return "[Key Bindings]";
	}
}

class CpuStrums extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	override public function press():Bool
	{
		FlxG.save.data.cpuStrums = !FlxG.save.data.cpuStrums;

		if (FlxG.save.data.cpuStrums)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);
		
		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return  FlxG.save.data.cpuStrums ? "Enemy Strums: Animated" : "Enemy Strums: Static";
	}

}

class LagCompensation extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	override public function press():Bool
	{
		FlxG.save.data.lagCompensation = !FlxG.save.data.lagCompensation;

		if (FlxG.save.data.lagCompensation)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);
		
		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return  FlxG.save.data.lagCompensation ? "Lag Compensation: ON" : "Lag Compensation: OFF";
	}
}

class FullscreenOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	override public function press():Bool
	{
		FlxG.save.data.fullscreen = !FlxG.save.data.fullscreen;

		if (FlxG.save.data.fullscreen)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);
		
		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return  FlxG.save.data.fullscreen ? "Fullscreen: ON" : "Fullscreen: OFF";
	}
}

class DownscrollOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	override public function press():Bool
	{
		FlxG.save.data.downscroll = !FlxG.save.data.downscroll;
		if (FlxG.save.data.downscroll)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);
		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return FlxG.save.data.downscroll ? "Downscroll: ON" : "Downscroll: OFF";
	}
}

class GhostTapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	override public function press():Bool
	{
		FlxG.save.data.ghost = !FlxG.save.data.ghost;

		if (FlxG.save.data.ghost)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);

		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return FlxG.save.data.ghost ? "Ghost Tapping: ON" : "Ghost Tapping: OFF";
	}
}

class AccuracyOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	override public function press():Bool
	{
		FlxG.save.data.accuracyDisplay = !FlxG.save.data.accuracyDisplay;

		if (FlxG.save.data.accuracyDisplay)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);
		
		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return "Accuracy Display: " + (!FlxG.save.data.accuracyDisplay ? "OFF" : "ON");
	}
}

class SongPositionOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	override public function press():Bool
	{
		FlxG.save.data.songPosition = !FlxG.save.data.songPosition;

		if (FlxG.save.data.songPosition)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);

		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return "Song Time Bar: " + (!FlxG.save.data.songPosition ? "OFF" : "ON");
	}
}

class DistractionsAndEffectsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	override public function press():Bool
	{
		FlxG.save.data.distractions = !FlxG.save.data.distractions;

		if (FlxG.save.data.distractions)
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);

		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return "Reduced Motion: " + (!FlxG.save.data.distractions ? "ON" : "OFF");
	}
}

class NoteSplashingEffectsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	override public function press():Bool
	{
		FlxG.save.data.notesplash = !FlxG.save.data.notesplash;

		if (FlxG.save.data.notesplash)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);

		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return "Note Splashes: " + (!FlxG.save.data.notesplash ? "OFF" : "ON");
	}
}

class HighQualityNoteSplash extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	override public function press():Bool
	{
		FlxG.save.data.hqnotesploosh = !FlxG.save.data.hqnotesploosh;

		if (FlxG.save.data.hqnotesploosh)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);

		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return "VFX Antialiassing: " + (!FlxG.save.data.hqnotesploosh ? "OFF" : "ON");
	}
}

class PauseOnLostFocus extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	override public function press():Bool
	{
		FlxG.save.data.pauseOnUnfocus = !FlxG.save.data.pauseOnUnfocus;

		if (FlxG.save.data.pauseOnUnfocus)
		{
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
			FlxG.autoPause = true;
		}
		else
		{
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);
			FlxG.autoPause = false;
		}

		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return "Pause On Lost Focus: " + (!FlxG.save.data.pauseOnUnfocus ? "OFF" : "ON");
	}
}

class SubtitlesOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	override public function press():Bool
	{
		FlxG.save.data.subtitles = !FlxG.save.data.subtitles;

		if (FlxG.save.data.subtitles)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);

		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return "In-game Subtitles: " + (!FlxG.save.data.subtitles ? "OFF" : "ON");
	}
}

class SubtitlesCenteredOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	override public function press():Bool
	{
		FlxG.save.data.centersubtitles = !FlxG.save.data.centersubtitles;

		if (FlxG.save.data.centersubtitles)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);

		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return "Subtitle Style: " + (!FlxG.save.data.centersubtitles ? "Static" : "Compact");
	}
}

class MusVolOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		isSlider = true;
	}

	override public function press():Bool
	{
		return false;
	}

	override private function updateDisplay():String
	{
		FlxG.sound.defaultMusicGroup.volume = FlxG.save.data.musicVol * 0.01;
		return "Music Volume: <" + FlxG.save.data.musicVol + ">";
	}

	override function getValue():String {
		return "Current Volume: " + HelperFunctions.truncateFloat(FlxG.save.data.musicVol,1);
	}

	override function right():Bool 
	{
		FlxG.save.data.musicVol += 1;

		if (FlxG.save.data.musicVol > 100)
			FlxG.save.data.musicVol = 100;

		display = updateDisplay();
		return true;
	}

	override function left():Bool 
	{
		FlxG.save.data.musicVol -= 1;

		if (FlxG.save.data.musicVol < 1)
			FlxG.save.data.musicVol = 1;

		display = updateDisplay();
		return true;
	}
}

class VocVolOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		isSlider = true;
	}

	override public function press():Bool
	{
		return false;
	}

	override private function updateDisplay():String
	{
		return "Vocals Volume: <" + FlxG.save.data.vocalsVol + ">";
	}

	override function getValue():String {
		return "Current Volume: " + HelperFunctions.truncateFloat(FlxG.save.data.vocalsVol,1);
	}

	override function right():Bool 
	{
		FlxG.save.data.vocalsVol += 1;

		if (FlxG.save.data.vocalsVol > 100)
			FlxG.save.data.vocalsVol = 100;

		display = updateDisplay();
		return true;
	}

	override function left():Bool 
	{
		FlxG.save.data.vocalsVol -= 1;

		if (FlxG.save.data.vocalsVol < 1)
			FlxG.save.data.vocalsVol = 1;

		display = updateDisplay();
		return true;
	}
}

class SFXVolOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		isSlider = true;
	}

	override public function press():Bool
	{
		return false;
	}

	override private function updateDisplay():String
	{
		FlxG.sound.defaultSoundGroup.volume = FlxG.save.data.gamesfxVol * 0.01;
		return "Sounds Volume: <" + FlxG.save.data.gamesfxVol + ">";
	}

	override function getValue():String {
		return "Current Volume: " + HelperFunctions.truncateFloat(FlxG.save.data.gamesfxVol,1);
	}

	override function right():Bool 
	{
		FlxG.save.data.gamesfxVol += 1;

		if (FlxG.save.data.gamesfxVol > 100)
			FlxG.save.data.gamesfxVol = 100;

		display = updateDisplay();
		return true;
	}

	override function left():Bool 
	{
		FlxG.save.data.gamesfxVol -= 1;

		if (FlxG.save.data.gamesfxVol < 1)
			FlxG.save.data.gamesfxVol = 1;

		display = updateDisplay();
		return true;
	}
}

class NoteHitSFXOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	override public function press():Bool
	{
		FlxG.save.data.notesfx = !FlxG.save.data.notesfx;

		if (FlxG.save.data.notesfx)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);

		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return "Note Hit Sounds " + (!FlxG.save.data.notesfx ? "OFF" : "ON");
	}
}

class HitSFXTypeOption extends Option
{
	var hitSFXList:Int = 0;
	var notesfxType:String = FlxG.save.data.notesfxType.toUpperCase();
	
	public function new(desc:String)
	{
		super();
		description = desc;
		isSlider = true;
		canSpeedUp = false;
	}

	override private function updateDisplay():String
	{
		return "Note Hit Type: <" + notesfxType + ">";
	}

	override public function press():Bool
	{
		return false;
	}

	function changeChoice():Void
	{
		if (hitSFXList < 0)
			hitSFXList = 4;
		else if (hitSFXList > 4)
			hitSFXList = 0;

		switch(hitSFXList)
		{
			case 1:
				FlxG.save.data.notesfxType = "chill";
			case 2:
				FlxG.save.data.notesfxType = "default";
				//FlxG.save.data.notesfxType = "bubble";
			case 3:
				FlxG.save.data.notesfxType = "chill";
				//FlxG.save.data.notesfxType = "osu";
			case 4:
				FlxG.save.data.notesfxType = "default";
				//FlxG.save.data.notesfxType = "custom";
			default:
				FlxG.save.data.notesfxType = "default";
		}
		notesfxType = FlxG.save.data.notesfxType.toUpperCase();
		display = updateDisplay();
	}

	override public function right():Bool 
	{
		hitSFXList += 1;
		changeChoice();
		return true;
	}

	override public function left():Bool 
	{
		hitSFXList -= 1;
		changeChoice();
		return true;
	}

	override function getValue():String 
	{
		return "Note Hit Type: <" + FlxG.save.data.notesfxType + ">";
	}
}

class HitSFXVolOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		isSlider = true;
	}

	override public function press():Bool
	{
		return false;
	}

	override private function updateDisplay():String
	{
		return "Note Hit Volume: <" + FlxG.save.data.notesfxVol + ">";
	}

	override function getValue():String {
		return "Current Volume: " + HelperFunctions.truncateFloat(FlxG.save.data.notesfxVol,1);
	}

	override function right():Bool 
	{
		FlxG.save.data.notesfxVol += 1;

		if (FlxG.save.data.notesfxVol > 100)
			FlxG.save.data.notesfxVol = 100;

		display = updateDisplay();
		return true;
	}

	override function left():Bool 
	{
		FlxG.save.data.notesfxVol -= 1;

		if (FlxG.save.data.notesfxVol < 1)
			FlxG.save.data.notesfxVol = 1;

		display = updateDisplay();
		return true;
	}
}

class ResetButtonOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	override public function press():Bool
	{
		FlxG.save.data.resetButton = !FlxG.save.data.resetButton;

		if (FlxG.save.data.resetButton)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);

		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return "Reset Button: " + (!FlxG.save.data.resetButton ? "OFF" : "ON");
	}
}

class FlashingLightsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	override public function press():Bool
	{
		FlxG.save.data.flashing = !FlxG.save.data.flashing;

		if (FlxG.save.data.flashing)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);
	
		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return "Flashing Lights: " + (!FlxG.save.data.flashing ? "OFF" : "ON");
	}
}

class AntialiasingOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	override public function press():Bool
	{
		FlxG.save.data.antialiasing = !FlxG.save.data.antialiasing;

		if (FlxG.save.data.antialiasing)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);

		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return "Antialiasing: " + (!FlxG.save.data.antialiasing ? "OFF" : "ON");
	}
}

class MissSoundsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	override public function press():Bool
	{
		FlxG.save.data.missSounds = !FlxG.save.data.missSounds;

		if (FlxG.save.data.missSounds)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);

		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return "Note Miss Sounds " + (!FlxG.save.data.missSounds ? "OFF" : "ON");
	}
}

class ShowInput extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	override public function press():Bool
	{
		FlxG.save.data.inputShow = !FlxG.save.data.inputShow;

		if (FlxG.save.data.inputShow)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);

		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return (FlxG.save.data.inputShow ? "Score Info: Extended" : "Score Info: Minimal");
	}
}


class Judgement extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		isSlider = true;
		canSpeedUp = false;
		display = updateDisplay();
	}
	
	override public function press():Bool
	{
		return false;
	}

	override private function updateDisplay():String
	{
		return "Safe Frames: <" + FlxG.save.data.frames + ">";
	}

	override function left():Bool {

		if (Conductor.safeFrames == 1)
			return false;

		Conductor.safeFrames -= 1;
		FlxG.save.data.frames = Conductor.safeFrames;

		Conductor.recalculateTimings();
		display = updateDisplay();
		return true;
	}

	override function getValue():String {
		return "Safe Frames: " + Conductor.safeFrames +
		" - SIC: " + HelperFunctions.truncateFloat(45 * Conductor.timeScale, 0) +
		"ms | GUD: " + HelperFunctions.truncateFloat(90 * Conductor.timeScale, 0) +
		"ms | BAD: " + HelperFunctions.truncateFloat(135 * Conductor.timeScale, 0) + 
		"ms | SLP: " + HelperFunctions.truncateFloat(166 * Conductor.timeScale, 0) +
		"ms | TOTAL: " + HelperFunctions.truncateFloat(Conductor.safeZoneOffset,0) + "ms";
	}

	override function right():Bool {

		if (Conductor.safeFrames == 20)
			return false;

		Conductor.safeFrames += 1;
		FlxG.save.data.frames = Conductor.safeFrames;

		Conductor.recalculateTimings();
		display = updateDisplay();
		return true;
	}
}

class FPSOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	override public function press():Bool
	{
		FlxG.save.data.fps = !FlxG.save.data.fps;

		if (FlxG.save.data.fps)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);

		(cast (Lib.current.getChildAt(0), Main)).toggleFPS(FlxG.save.data.fps);
		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return "FPS Counter: " + (!FlxG.save.data.fps ? "OFF" : "ON");
	}
}

class ScoreScreen extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	override public function press():Bool
	{
		FlxG.save.data.scoreScreen = !FlxG.save.data.scoreScreen;

		if (FlxG.save.data.scoreScreen)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);

		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return (FlxG.save.data.scoreScreen ? "Score Screen: ON" : "Score Screen: OFF");
	}
}

class FPSCapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		isSlider = true;
		canSpeedUp = false;
	}

	override public function press():Bool
	{
		return false;
	}

	override private function updateDisplay():String
	{
		return "FPS Cap: <" + (FlxG.save.data.fpsCap == Application.current.window.displayMode.refreshRate ? "Monitor Rate (" + FlxG.save.data.fpsCap + " Hz)" : FlxG.save.data.fpsCap) + ">";
	}
	
	override function right():Bool
	{
		if (FlxG.save.data.setFpsCap >= 290)
			FlxG.save.data.setFpsCap = 290;
		else
		{
			FlxG.save.data.setFpsCap = FlxG.save.data.setFpsCap + 10;
			FlxG.save.data.fpsCap = FlxG.save.data.setFpsCap;
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		}
		display = updateDisplay();
		return true;
	}

	override function left():Bool 
	{
		if (FlxG.save.data.setFpsCap <= 60)
		{
			FlxG.save.data.setFpsCap = 50;
			FlxG.save.data.fpsCap = Application.current.window.displayMode.refreshRate;
			(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		}
		else
		{
			FlxG.save.data.setFpsCap = FlxG.save.data.setFpsCap - 10;
			if (FlxG.save.data.setFpsCap >= 60)
			{
				FlxG.save.data.fpsCap = FlxG.save.data.setFpsCap;
				(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
			}
		}
		display = updateDisplay();
		return true;
	}

	override function getValue():String
	{
		return "Current FPS Cap: " + (FlxG.save.data.fpsCap == Application.current.window.displayMode.refreshRate ? "V-SYNC (" + FlxG.save.data.fpsCap + " Hz)" : FlxG.save.data.fpsCap);
	}
}


class ScrollSpeedOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		isSlider = true;
	}

	override public function press():Bool
	{
		return false;
	}

	override private function updateDisplay():String
	{
		return "Scroll Speed Multiplier: <" + HelperFunctions.truncateFloat(FlxG.save.data.scrollSpeed,1) + ">";
	}

	override function right():Bool 
	{
		FlxG.save.data.scrollSpeed += 0.1;

		if (FlxG.save.data.scrollSpeed < 0.5)
			FlxG.save.data.scrollSpeed = 0.5;

		if (FlxG.save.data.scrollSpeed > 2)
			FlxG.save.data.scrollSpeed = 2;
		display = updateDisplay();
		return true;
	}

	override function getValue():String {
		return "Scroll Speed Multiplier: " + HelperFunctions.truncateFloat(FlxG.save.data.scrollSpeed,1);
	}

	override function left():Bool 
	{
		FlxG.save.data.scrollSpeed -= 0.1;

		if (FlxG.save.data.scrollSpeed < 0.5)
			FlxG.save.data.scrollSpeed = 0.5;

		if (FlxG.save.data.scrollSpeed > 2)
			FlxG.save.data.scrollSpeed = 2;
		display = updateDisplay();
		return true;
	}
}


class RainbowFPSOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	override public function press():Bool
	{
		FlxG.save.data.fpsRain = !FlxG.save.data.fpsRain;

		if (FlxG.save.data.fpsRain)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);

		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return "FPS Rainbow: " + (!FlxG.save.data.fpsRain ? "OFF" : "ON");
	}
}

class Optimization extends Option
{
	public function new(desc:String)
		{
			super();
			description = desc;
		}
	
		override public function press():Bool
		{
			FlxG.save.data.optimize = !FlxG.save.data.optimize;

			if (FlxG.save.data.optimize)
				FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
			else
				FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);

			display = updateDisplay();
			return true;
		}
	
		override private function updateDisplay():String
		{
			return "Focus Mode: " + (FlxG.save.data.optimize ? "ON" : "OFF");
		}
}

class NPSDisplayOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	override public function press():Bool
	{
		FlxG.save.data.npsDisplay = !FlxG.save.data.npsDisplay;

		if (FlxG.save.data.npsDisplay)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);

		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return "NPS Display: " + (!FlxG.save.data.npsDisplay ? "OFF" : "ON");
	}
}

class ShowPresenceOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	override public function press():Bool
	{
		FlxG.save.data.showPresence = !FlxG.save.data.showPresence;

		if (FlxG.save.data.showPresence)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);

		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return "Discord Presence: " + (!FlxG.save.data.showPresence ? "OFF" : "ON");
	}
}

class AccuracyDOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	override public function press():Bool
	{
		FlxG.save.data.accuracyMod = FlxG.save.data.accuracyMod == 1 ? 0 : 1;

		if (FlxG.save.data.accuracyMod == 0)
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);

		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return "Accuracy Mode: " + (FlxG.save.data.accuracyMod == 0 ? "Simple" : "Complex");
	}
}

class CustomizeGameplay extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	override public function press():Bool
	{
		trace("switch");
		FlxG.switchState(new GameplayCustomizeState());

		FlxG.sound.play(Paths.sound("scrollMenu"));
		
		return false;
	}

	override private function updateDisplay():String
	{
		return "[Customize UI Elements]";
	}
}

class WatermarkOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	override public function press():Bool
	{
		Main.watermarks = !Main.watermarks;
		FlxG.save.data.watermark = Main.watermarks;

		if (Main.watermarks)
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);

		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return "Hide Identities: " + (Main.watermarks ? "OFF" : "ON");
	}
}

class NightModeOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	override public function press():Bool
	{
		FlxG.save.data.nightmode = !FlxG.save.data.nightmode;
		if (FlxG.save.data.nightmode && !Main.nightMode)
			Main.nightMode = true;
		else if (!FlxG.save.data.nightmode && Main.nightMode)
			Main.nightMode = false;

		if (FlxG.save.data.nightmode)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);

		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return "Night Mode: " + (!FlxG.save.data.nightmode ? "OFF" : "ON");
	}
}

class AutoNightModeOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	override public function press():Bool
	{
		FlxG.save.data.autoNightmode = !FlxG.save.data.autoNightmode;
		Main.updateNightMode();
		display = updateDisplay();

		if (FlxG.save.data.autoNightmode)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);

		return true;
	}

	override private function updateDisplay():String
	{
		return "Auto Night Mode: " + (!FlxG.save.data.autoNightmode ? "OFF" : "ON");
	}
}

/*class ShitBreaksCombo extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	override public function press():Bool
	{
		FlxG.save.data.shitBreaksCombo = !FlxG.save.data.shitBreaksCombo;

		if (FlxG.save.data.shitBreaksCombo)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);

		display = updateDisplay();
		return true;
	}
	
	override private function updateDisplay():String
	{
		return "'SLIPS' Cause Miss: " + (FlxG.save.data.shitBreaksCombo ? "YES" : "NO");
	}
}*/

/*class OffsetMenu extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	override public function press():Bool
	{
		trace("switch");
		var poop:String = Highscore.formatSong("Tutorial", 1);

		PlayState.SONG = Song.loadFromJson(poop, "Tutorial");
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = 0;
		PlayState.storyWeek = 0;
		PlayState.offsetTesting = true;
		trace('CUR WEEK' + PlayState.storyWeek);
		LoadingState.loadAndSwitchState(new PlayState());
		return false;
	}

	override private function updateDisplay():String
	{
		return "Time your offset";
	}
}*/

class BotPlay extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	override public function press():Bool
	{
		FlxG.save.data.botplay = !FlxG.save.data.botplay;

		if (FlxG.save.data.botplay)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);

		trace('BotPlay : ' + FlxG.save.data.botplay);
		display = updateDisplay();
		return true;
	}
	
	override private function updateDisplay():String
	{
		return "BotPlay: " + (FlxG.save.data.botplay ? "ON" : "OFF");
	}
}

class ShowStrumLine extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	
	override public function press():Bool
	{
		FlxG.save.data.strumline = !FlxG.save.data.strumline;
		
		if (FlxG.save.data.strumline)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);

		display = updateDisplay();
		return true;
	}
	
	override private function updateDisplay():String
	{
		return "Strumline Background: " + (FlxG.save.data.strumline ? "ON" : "OFF");
	}
}

class CamZoomOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}
	override public function press():Bool
	{
		FlxG.save.data.camzoom = !FlxG.save.data.camzoom;

		if (FlxG.save.data.camzoom)
			FlxG.sound.play(Paths.sound("optionsToggleOn"), 0.8);
		else
			FlxG.sound.play(Paths.sound("optionsToggleOff"), 0.8);

		display = updateDisplay();
		return true;
	}

	override private function updateDisplay():String
	{
		return "Camera Zooming: " + (!FlxG.save.data.camzoom ? "OFF" : "ON");
	}
}

class LockWeeksOption extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		description = desc;
	}
	override public function press():Bool
	{
		if (DisclaimerState.wentOptions)
		{
			FlxG.sound.play(Paths.sound("scrollMenuFail"), 0.8);
			return false;
		}

		if(!confirm)
		{
			confirm = true;
			display = updateDisplay();
			FlxG.sound.play(Paths.sound("optionsResetPrompt"));
			return true;
		}
		FlxG.save.data.weekUnlocked = 1;
		StoryMenuState.weekUnlocked = [true, true];
		confirm = false;
		trace('Weeks Locked');
		display = updateDisplay();
		FlxG.sound.music.tapeStop(0.2, 0, function(twn:FlxTween){FlxG.sound.music.stop(); Conductor.changeBPM(102);});
		FlxG.sound.play(Paths.sound("optionsResetConfirm"));
		return true;
	}

	override public function resetConfirmBool() //a function to reset a bool?? LMAO
	{
		confirm = false;
		display = updateDisplay();
		//trace ('blah ' + confirm);
	}

	override private function updateDisplay():String
	{
		return confirm ? "|[Confirm Story Reset?]|" : "[Reset Story Progress]";
	}
}

class ResetScoreOption extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		description = desc;
	}
	override public function press():Bool
	{
		if (DisclaimerState.wentOptions)
		{
			FlxG.sound.play(Paths.sound("scrollMenuFail"), 0.8);
			return false;
		}

		if(!confirm)
		{
			confirm = true;
			display = updateDisplay();
			FlxG.sound.play(Paths.sound("optionsResetPrompt"));
			return true;
		}
		FlxG.save.data.songScores = null;
		for(key in Highscore.songScores.keys())
		{
			Highscore.songScores[key] = 0;
		}
		FlxG.save.data.songCombos = null;
		for(key in Highscore.songCombos.keys())
		{
			Highscore.songCombos[key] = '';
		}
		confirm = false;
		trace('Highscores Wiped');
		display = updateDisplay();
		FlxG.sound.play(Paths.sound("optionsResetConfirm"));
		return true;
	}

	override public function resetConfirmBool() //a function to reset a bool?? LMAO
	{
		confirm = false;
		display = updateDisplay();
		//trace ('blah ' + confirm);
	}

	override private function updateDisplay():String
	{
		return confirm ? "|[Confirm Scores Reset?]|" : "[Reset Scores]";
	}
}

class ResetSettings extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		description = desc;
	}
	override public function press():Bool
	{
		if (DisclaimerState.wentOptions)
		{
			FlxG.sound.play(Paths.sound("scrollMenuFail"), 0.8);
			return false;
		}

		if(!confirm)
		{
			confirm = true;
			display = updateDisplay();
			FlxG.sound.play(Paths.sound("optionsResetPrompt"));
			return true;
		}
		confirm = false;

		//SaveData.resetAllData();
		SaveData.resetSettingsData();
		KeyBinds.resetBinds();

		trace('All settings have been reset');
		display = updateDisplay();
		FlxG.sound.play(Paths.sound("optionsResetConfirm"));
		return true;
	}

	override public function resetConfirmBool() //a function to reset a bool?? LMAO
	{
		confirm = false;
		display = updateDisplay();
		//trace ('blah ' + confirm);
	}

	override private function updateDisplay():String
	{
		return confirm ? "|[Confirm Settings Reset?]|" : "[Reset Settings]";
	}
}
