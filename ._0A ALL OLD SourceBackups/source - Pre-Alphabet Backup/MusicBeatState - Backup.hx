package;

#if windows
import Discord.DiscordClient;
#end
import flixel.util.FlxColor;
import openfl.Lib;
import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.addons.ui.FlxUIState;
import flixel.math.FlxMath;

class MusicBeatState extends FlxUIState
{
	//private var lastBeat:Float = 0;
	//private var lastStep:Float = 0;
	private var curStep:Int = -5;
	private var oldStep:Int = -6;
	private var curBeat:Int = -2;
	private var curDecimalBeat:Float = -1;
	private var curDecimalStep:Float = -5;
	private var controls(get, never):Controls;

	public static var currentColor = 0;
	var skippedFrames = 0;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		TimingStruct.clearTimings();

		super.create();
	}


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

		oldStep = curStep;
		updateCurStep();

		super.update(elapsed);

		if (FlxG.save.data.fpsRain && skippedFrames >= 6)
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

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
		curDecimalBeat = curDecimalStep/4;
	}

	private function updateCurStep():Void
	{
		var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);

		var shit = ((Conductor.songPosition - FlxG.save.data.offset) - lastChange.songTime) / lastChange.stepCrochet;
		curDecimalStep = lastChange.stepTime + shit;
		var nextStep:Int = lastChange.stepTime + Math.floor(shit);
		if (curStep >= 0)
		{
			if (nextStep > curStep)
			{
				for (i in curStep...nextStep)
				{
					curStep++;
					updateBeat();
					if (oldStep != curStep)
					{
						if(curStep >= 0)
							stepHit();
					}
				}
			}
			else if (nextStep < curStep)
			{
				//Song reset?
				curStep = nextStep;
				updateBeat();
				stepHit();
			}
		}
		else
		{
			curStep = nextStep;
			updateBeat();
			if (oldStep != curStep)
				stepHit();
		}
	}

	public function stepHit():Void
	{
		if (curStep % 4 == 0)
			beatHit();
	}

	public function beatHit():Void
	{
		//trace(curBeat);
		//do literally nothing dumbass
	}
}
