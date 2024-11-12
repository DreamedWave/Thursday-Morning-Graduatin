package;

import Conductor.BPMChangeEvent;
//import flixel.FlxG;
import flixel.FlxSubState;
import flixel.util.FlxColor;
import openfl.Lib;

class MusicBeatSubstate extends FlxSubState
{
	public function new()
	{
		super();
	}
	//private var lastBeat:Float = 0;
	//private var lastStep:Float = 0;
	private var curStep:Int = -4;
	private var curBeat:Int = -1;
	private var curDecimalBeat:Float = -1;
	private var curDecimalStep:Float = -4;
	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	public static var currentColor = 0;
	var skippedFrames = 0;
	var array:Array<FlxColor> = [
		FlxColor.fromRGB(148, 0, 211),
		FlxColor.fromRGB(75, 0, 130),
		FlxColor.fromRGB(0, 0, 255),
		FlxColor.fromRGB(0, 255, 0),
		FlxColor.fromRGB(255, 255, 0),
		FlxColor.fromRGB(255, 127, 0),
		FlxColor.fromRGB(255, 0 , 0)
	];

	override function update(elapsed:Float)
	{
		#if !debug
		if (!FlxG.save.data.fullscreen && FlxG.fullscreen)
			FlxG.fullscreen = false;
		else if (FlxG.save.data.fullscreen && !FlxG.fullscreen)
			FlxG.fullscreen = true;
		#else
		if (FlxG.fullscreen)
			FlxG.fullscreen = false;
		#end

		var oldStep:Int = curStep;

		updateCurStep();
		updateBeat();

		if (oldStep != curStep)
		{
			if(curStep >= 0)
				stepHit();
		}

		super.update(elapsed);

		if (FlxG.save.data.fpsRain)
		{
			if (skippedFrames >= 6)
			{
				if (currentColor >= array.length)
					currentColor = 0;
				(cast (Lib.current.getChildAt(0), Main)).changeFPSColor(array[currentColor]);
				currentColor++;
				skippedFrames = 0;
			}
			else
				skippedFrames++;
		}
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecimalBeat = curDecimalStep/4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit:Float = 0;
		if (lastChange != null && lastChange.type == 'tween')
		{
			//please lord god, please work
			//FUCK YEA BABYYYYY IT WORKS!!!!!!!
			shit = ((Conductor.songPosition - FlxG.save.data.offset) - lastChange.songTime) / Conductor.stepCrochet;
		}
		else
			shit = ((Conductor.songPosition - FlxG.save.data.offset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecimalStep = lastChange.stepTime + shit;
		curStep = lastChange.stepTime + Math.floor(shit);
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//do literally nothing dumbass
	}

	public function changeTime(time:Float = 0)
	{
		//Prevents people from misusing the function
		if (time != 0)
		{
			trace('doing time skip stuff within musicBeatState!');
			
			var oldStep:Int = curStep;
			var newStep:Int = 0;

			//Change conductor position to target time
			Conductor.songPosition = time;

			//Imitate the updateCurStep function for a different variable
			var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);
			var shit = ((Conductor.songPosition - FlxG.save.data.offset) - lastChange.songTime) / lastChange.stepCrochet;
			newStep = lastChange.stepTime + Math.floor(shit);

			//Catch up to the missed steps when you skipped time
			//manually count up steps missed to target step
			//and only strictly do this if the song skips *AHEAD* of time - the beats fix themselves if the song resets
			if (newStep > curStep)
			{
				for (i in curStep...newStep)
				{
					curStep++;
					curDecimalStep = curStep;
					updateBeat();
					if (oldStep != curStep)
					{
						if(curStep >= 0)
							stepHit();
					}
				}
			}
		}
	}
}
