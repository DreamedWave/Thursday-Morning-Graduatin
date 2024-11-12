package;

import Song.SwagSong;
//import flixel.FlxG;
//guh
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

using StringTools;

/**
 * ...
 * @author
 */

typedef BPMChangeEvent =
{
	var stepTime:Int;
	var songTime:Float;
	var bpm:Float;
	@:optional var type:String;
	@:optional var stepCrochet:Float;
}

class Conductor
{
	public static var bpm:Float = 100;
	public static var crochet:Float = ((60 / bpm) * 1000); // beats in milliseconds
	public static var stepCrochet:Float = crochet / 4; // steps in milliseconds
	public static var songPosition:Float = 0;
	public static var lastSongPos:Float;
	public static var offset:Float = 0;

	public static var safeFrames:Int = 10;
	public static var safeZoneOffset:Float = Math.floor((safeFrames / 60) * 1000); // is calculated in create(), is safeFrames in milliseconds
	public static var timeScale:Float = Conductor.safeZoneOffset / 166;

	public static var bpmChangeMap:Array<BPMChangeEvent> = [];

	public function new()
	{
	}

	public static function recalculateTimings()
	{
		Conductor.safeFrames = FlxG.save.data.frames;
		Conductor.safeZoneOffset = Math.floor((Conductor.safeFrames / 60) * 1000);
		Conductor.timeScale = Conductor.safeZoneOffset / 166;
	}

	public static function mapBPMChanges(song:SwagSong)
	{
		bpmChangeMap = [];

		if (song.eventObjects != null && song.eventObjects.length != 0)
		{
			//BPM TWEENS ARE FUCKING BROKEN FOR NOW
			//I will eventually figure out how to change them but as of right now, we die
			for (i in song.eventObjects)
			{
				if (i.type == "BPM Change" && i.value != bpm)
				{
					trace('bpm change');
					var event:BPMChangeEvent = {
						stepTime: Math.floor(i.position * 4),
						songTime: Conductor.crochet * i.position,
						bpm: i.value
					};
					bpmChangeMap.push(event);
				}
				else if (i.type == "BPM Tween")
				{
					trace('bpm tween');
					//from my understanding, stepTime is the step at which the event starts, and songTime is the time that will be compared with Conductor.songPosition
					var event:BPMChangeEvent = {
						type: 'tween',
						stepTime: Math.floor(i.position * 4),
						songTime: i.value[0],
						bpm: i.value[1]
					};
					bpmChangeMap.push(event);
				}
			}
		}
		trace("new BPM map BUDDY " + bpmChangeMap);
	}

	public static function recalculateTimingStruct(SONG:Song)
	{
		for(i in SONG.eventObjects)
		{
			//nada
		}
	}

	public static function changeBPM(newBpm:Float, ?recalcCrochet:Bool = true)
	{
		bpm = newBpm;

		if (recalcCrochet)
		{
			crochet = ((60 / bpm) * 1000);
			stepCrochet = crochet / 4;
		}
	}

	public static function getBPMFromSeconds(time:Float)
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: bpm,
			stepCrochet: stepCrochet
		}

		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (time >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		return lastChange;
	}
}