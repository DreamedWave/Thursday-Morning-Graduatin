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
	private var curStep:Int = -4;
	private var curBeat:Int = -1;
	private var curDecimalBeat:Float = -1;
	private var curDecimalStep:Float = -4;
	private var controls(get, never):Controls;

	public static var currentColor = 0;
	var skippedFrames = 0;

	//var chillDownLol:Bool = false;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	override function create()
	{
		TimingStruct.clearTimings();

		if (Type.getClass(FlxG.state) != FunnySplash)
		{
			if (FlxG.save.data.pauseOnUnfocus && !FlxG.autoPause)
				FlxG.autoPause = true;
			if (!FlxG.save.data.pauseOnUnfocus && FlxG.autoPause)
				FlxG.autoPause = false;
		}

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

	var nextStep:Int = 0;

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

		updateCurStep(false);
		//Catch up System
		if (nextStep >= 0)
		{
			if (nextStep > curStep)
			{
				for (i in curStep...nextStep)
				{
					//trace('funky Beat:' + i);
					curStep++;
					updateBeat();
					stepHit();
				}
			}
			else if (nextStep < curStep)
			{
				//Song reset?
				//trace('song reset?');
				updateCurStep();
				updateBeat();
			}
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
		curDecimalBeat = curDecimalStep / 4;
	}

	private function updateCurStep(directUpdate:Bool = true):Void
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

		//trace(shit);

		curDecimalStep = lastChange.stepTime + shit;
		if (directUpdate)
			curStep = lastChange.stepTime + Math.floor(shit);
		else
			nextStep = lastChange.stepTime + Math.floor(shit);
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

	public function changeTime(time:Float = 0)
	{
		//Prevents people from misusing the function
		if (time != 0)
		{
			//trace('doing time skip stuff within musicBeatState!');
			
			//var oldStep:Int = curStep;
			//var newStep:Int = 0;

			//Change conductor position to target time
			Conductor.songPosition = time;

			//Imitate the updateCurStep function for a different variable
			//var lastChange = Conductor.getBPMFromSeconds(Conductor.songPosition);
			//var shit = ((Conductor.songPosition - FlxG.save.data.offset) - lastChange.songTime) / lastChange.stepCrochet;
			//newStep = lastChange.stepTime + Math.floor(shit);

			//Catch up to the missed steps when you skipped time
			//manually count up steps missed to target step
			//and only strictly do this if the song skips *AHEAD* of time - the beats fix themselves if the song resets
			/*trace ('CurStep:' + curStep + ' NewStep: ' + newStep);
			if (newStep > curStep)
			{
				trace('huh????');
				for (i in curStep...newStep)
				{
					trace (i);
					curStep++;
					curDecimalStep = curStep;
					updateBeat();
					if (oldStep != curStep)
					{
						if(curStep >= 0)
							stepHit();
					}
				}
				//chillDownLol = false;
			}*/
		}
	}

	/*public function catchUpBeats(currentTime:Float = 0, lastBeat:Int = 0):Void //Basically my fix if ever the game doesnt do beats properly 
	{
		//chillDownLol = true;
		trace('doing lag spike beat compensation in musicbeatstate!');
		Conductor.songPosition = lastBeat * Conductor.crochet;
		changeTime(currentTime);
	}*/
}
