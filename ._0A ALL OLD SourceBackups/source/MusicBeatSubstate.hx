package;

import Conductor.BPMChangeEvent;
import flixel.FlxG;
import flixel.FlxSubState;

class MusicBeatSubstate extends FlxSubState
{
	public function new()
	{
		super();
	}

	//private var lastBeat:Float = 0;
	//private var lastStep:Float = 0;

	private var curStep:Int = 0;
	private var curBeat:Int = 0;

	private var controls(get, never):Controls;

	inline function get_controls():Controls
		return PlayerSettings.player1.controls;

	private var prevStep:Int = -1;
	private var nextStep:Int;

	override function update(elapsed:Float)
	{	
		if (!FlxG.save.data.fullscreen && FlxG.fullscreen)
			FlxG.fullscreen = false;
		else if (FlxG.save.data.fullscreen && !FlxG.fullscreen)
			FlxG.fullscreen= true;

		nextStep = updateCurStep();

		if (prevStep != curStep && nextStep > -1)
		{
			if (nextStep > curStep)
			{
				//Compensation for time skips
				for (i in curStep...nextStep)
				{
					prevStep = curStep;
					curStep++;
					updateBeat();
					stepHit();
				}
			}
			else if (nextStep < curStep)
			{
				//Song reset?
				prevStep = nextStep - 1;
				curStep = nextStep;
				updateBeat();
				stepHit();
			}
		}

		super.update(elapsed);
	}

	private function updateBeat():Void
	{
		curBeat = Math.floor(curStep / 4);
	}

	private function updateCurStep():Int
	{
		var lastChange:BPMChangeEvent = 
		{
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (Conductor.songPosition >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		return lastChange.stepTime + Math.floor(((Conductor.songPosition - FlxG.save.data.offset) - lastChange.songTime) / Conductor.stepCrochet);
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
}
