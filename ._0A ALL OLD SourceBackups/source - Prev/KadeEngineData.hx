import flixel.input.gamepad.FlxGamepad;
import openfl.Lib;
import flixel.FlxG;

class KadeEngineData 
{
    public static function initSave():Void
    {
        if (FlxG.save.data.weekUnlocked == null)
			FlxG.save.data.weekUnlocked = 1;

		if (FlxG.save.data.downscroll == null)
			FlxG.save.data.downscroll = false;

		if (FlxG.save.data.antialiasing == null)
			FlxG.save.data.antialiasing = true;

		if (FlxG.save.data.missSounds == null)
			FlxG.save.data.missSounds = true;

		if (FlxG.save.data.notesplash == null)
			FlxG.save.data.notesplash = true;

		if (FlxG.save.data.hqnotesploosh == null)
			FlxG.save.data.hqnotesploosh = false;

		if (FlxG.save.data.lagCompensation == null)
			FlxG.save.data.lagCompensation = true;

		if (FlxG.save.data.notesfx == null)
			FlxG.save.data.notesfx = true;

		if (FlxG.save.data.notesfxVol == null)
			FlxG.save.data.notesfxVol = 40;

		if (FlxG.save.data.notesfxType == null)
			FlxG.save.data.notesfxType = "default";

		if (FlxG.save.data.subtitles == null)
			FlxG.save.data.subtitles = true;

		if (FlxG.save.data.centersubtitles == null)
			FlxG.save.data.centersubtitles = true;
			
		if (FlxG.save.data.accuracyDisplay == null)
			FlxG.save.data.accuracyDisplay = true;

		if (FlxG.save.data.offset == null)
			FlxG.save.data.offset = 0;

		if (FlxG.save.data.songPosition == null)
			FlxG.save.data.songPosition = true;

		if (FlxG.save.data.fps == null)
			FlxG.save.data.fps = false;

		if (FlxG.save.data.changedHit == null || FlxG.save.data.changedHit == false || FlxG.save.data.changedHitX == null || FlxG.save.data.changedHitY == null)
		{
			FlxG.save.data.changedHit = false;
			
			FlxG.save.data.changedHitX = 540;
			if (!FlxG.save.data.optimize)
			{
				if (!FlxG.save.data.downscroll)
					FlxG.save.data.changedHitY = 60;
				else
					FlxG.save.data.changedHitY = 560;
			}
			else
				FlxG.save.data.changedHitY = 250;
		}

		if (FlxG.save.data.fpsRain == null)
			FlxG.save.data.fpsRain = false;
		
		if (FlxG.save.data.fullscreen == null)
			FlxG.save.data.fullscreen = false;

		if (FlxG.save.data.fpsCap == null || FlxG.save.data.fpsCap > 285 || FlxG.save.data.fpsCap < 60)
			FlxG.save.data.fpsCap = 120; // baby proof so you can't hard lock ur copy of kade engine

		if (FlxG.save.data.scrollSpeed == null)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.npsDisplay == null)
			FlxG.save.data.npsDisplay = false;

		if (FlxG.save.data.frames == null)
			FlxG.save.data.frames = 10;

		if (FlxG.save.data.accuracyMod == null)
			FlxG.save.data.accuracyMod = 1;

		if (FlxG.save.data.watermark == null)
			FlxG.save.data.watermark = true;

		if (FlxG.save.data.ghost == null)
			FlxG.save.data.ghost = true;

		if (FlxG.save.data.distractions == null)
			FlxG.save.data.distractions = true;

		if (FlxG.save.data.flashing == null)
			FlxG.save.data.flashing = true;

		if (FlxG.save.data.resetButton == null)
			FlxG.save.data.resetButton = true;
		
		if (FlxG.save.data.botplay == null)
			FlxG.save.data.botplay = false;

		if (FlxG.save.data.cpuStrums == null)
			FlxG.save.data.cpuStrums = false;

		if (FlxG.save.data.strumline == null)
			FlxG.save.data.strumline = true;

		if (FlxG.save.data.camzoom == null)
			FlxG.save.data.camzoom = true;

		if (FlxG.save.data.scoreScreen == null)
			FlxG.save.data.scoreScreen = true;

		if (FlxG.save.data.inputShow == null)
			FlxG.save.data.inputShow = false;

		if (FlxG.save.data.optimize == null)
			FlxG.save.data.optimize = false;
		
		if (FlxG.save.data.cacheMusic == null)
			FlxG.save.data.cacheMusic = true;

		if (FlxG.save.data.cacheImages == null)
			FlxG.save.data.cacheImages = false;

		if (FlxG.save.data.pauseOnUnfocus == null)
			FlxG.save.data.pauseOnUnfocus = true;

		if (FlxG.save.data.showPresence == null)
			FlxG.save.data.showPresence = true;

		if (FlxG.save.data.nightmode == null)
			FlxG.save.data.nightmode = false;

		if (FlxG.autoPause == true && !FlxG.save.data.pauseOnLostFocus)
			FlxG.autoPause = false;
		else if (FlxG.autoPause == false && FlxG.save.data.pauseOnLostFocus)
			FlxG.autoPause = true;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		
		KeyBinds.gamepad = gamepad != null;

		//Are you looking for controls? Check KeyBinds.hx!!

		Conductor.recalculateTimings();
		PlayerSettings.player1.controls.loadKeyBinds();
		KeyBinds.keyCheck();

		Main.watermarks = FlxG.save.data.watermark;

		(cast (Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
	}

	public static function resetAllData():Void
	{
		FlxG.save.data.weekUnlocked = null;
		FlxG.save.data.songScores = null;
		FlxG.save.data.songCombos = null;
		FlxG.save.data.downscroll = null;
		FlxG.save.data.antialiasing = null;
		FlxG.save.data.missSounds = null;
		FlxG.save.data.notesplash = null;
		FlxG.save.data.hqnotesploosh = null;
		FlxG.save.data.lagCompensation = null;
		FlxG.save.data.notesfx = null;
		FlxG.save.data.notesfxVol = null;
		FlxG.save.data.notesfxType = null;
		FlxG.save.data.subtitles = null;
		FlxG.save.data.centersubtitles = null;
		FlxG.save.data.accuracyDisplay = null;
		FlxG.save.data.offset = null;
		FlxG.save.data.songPosition = null;
		FlxG.save.data.fps = null;
		FlxG.save.data.changedHit = null;
		FlxG.save.data.fpsRain = null;
		FlxG.save.data.fullscreen = null;
		FlxG.save.data.fpsCap = null;
		FlxG.save.data.scrollSpeed = null;
		FlxG.save.data.npsDisplay = null;
		FlxG.save.data.frames = null;
		FlxG.save.data.accuracyMod = null;
		FlxG.save.data.watermark = null;
		FlxG.save.data.ghost = null;
		FlxG.save.data.flashing = null;
		FlxG.save.data.resetButton = null;
		FlxG.save.data.botplay = null;
		FlxG.save.data.cpuStrums = null;
		FlxG.save.data.strumline = null;
		FlxG.save.data.camzoom = null;
		FlxG.save.data.scoreScreen = null;
		FlxG.save.data.inputShow = null;
		FlxG.save.data.optimize = null;
		FlxG.save.data.cacheMusic = null;
		FlxG.save.data.cacheImages = null;
		FlxG.save.data.pauseOnUnfocus = null;
		FlxG.save.data.showPresence = null;
		FlxG.save.data.nightmode = null;
		initSave();
	}

	public static function resetSettingsData():Void
	{
		FlxG.save.data.downscroll = null;
		FlxG.save.data.antialiasing = null;
		FlxG.save.data.missSounds = null;
		FlxG.save.data.notesplash = null;
		FlxG.save.data.hqnotesploosh = null;
		FlxG.save.data.lagCompensation = null;
		FlxG.save.data.notesfx = null;
		FlxG.save.data.notesfxVol = null;
		FlxG.save.data.notesfxType = null;
		FlxG.save.data.subtitles = null;
		FlxG.save.data.centersubtitles = null;
		FlxG.save.data.accuracyDisplay = null;
		FlxG.save.data.offset = null;
		FlxG.save.data.songPosition = null;
		FlxG.save.data.fps = null;
		FlxG.save.data.changedHit = null;
		FlxG.save.data.fpsRain = null;
		FlxG.save.data.fullscreen = null;
		FlxG.save.data.fpsCap = null;
		FlxG.save.data.scrollSpeed = null;
		FlxG.save.data.npsDisplay = null;
		FlxG.save.data.frames = null;
		FlxG.save.data.accuracyMod = null;
		FlxG.save.data.watermark = null;
		FlxG.save.data.ghost = null;
		FlxG.save.data.flashing = null;
		FlxG.save.data.resetButton = null;
		FlxG.save.data.botplay = null;
		FlxG.save.data.cpuStrums = null;
		FlxG.save.data.strumline = null;
		FlxG.save.data.camzoom = null;
		FlxG.save.data.scoreScreen = null;
		FlxG.save.data.inputShow = null;
		FlxG.save.data.optimize = null;
		FlxG.save.data.cacheMusic = null;
		FlxG.save.data.cacheImages = null;
		FlxG.save.data.pauseOnUnfocus = null;
		FlxG.save.data.showPresence = null;
		FlxG.save.data.nightmode = null;
		initSave();
	}
}