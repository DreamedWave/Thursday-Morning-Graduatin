package;

import Conductor.BPMChangeEvent;
import flixel.FlxCamera;
import flixel.math.FlxRect;
import Song.SwagSong;
import Section.SwagSection;
import flixel.system.FlxSound;
import flixel.input.gamepad.FlxGamepad;
import flixel.util.FlxAxes;
import flixel.FlxSubState;
import Options.Option;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxSort;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import lime.utils.Assets;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.input.FlxKeyManager;

using StringTools;

//Functional (to the point that it dont crash no mo!) but scrapped (until otherwise) feature!!
class DiffOverview extends MusicBeatSubstate
{
	public static var instance:DiffOverview;

	var blackBox:FlxSprite;

	var handOne:Array<Float>;
	var handTwo:Array<Float>;

	var giantText:FlxText;

	var SONG:SwagSong;
	var strumLine:FlxSprite;
    var camHUD:FlxCamera;
	var camGame:FlxCamera;

	public var curScroll:Float = 1;
	var defaultScroll:Float = 1;
	var prevScroll:Float = 1;
	var prevScrollCheck:Bool = false;
	var newScroll:Float = 1;
	var diffSpeedMult:Float = 1;
	var fakeCrochet:Float;

	public static var lastSongPlayed:String = '';
	var resetToStart:Bool = false;

	var playerStrums:FlxTypedGroup<FlxSprite> = null;

	override function create()
	{
		instance = this;
        
		camGame = new FlxCamera();
        camHUD = new FlxCamera();
        camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

        playerStrums = new FlxTypedGroup<FlxSprite>();

		SONG = FreeplayState.songData.get(FreeplayState.songs[FreeplayState.curSelected].songName)[FreeplayState.curDifficulty];

		if (SONG.song != lastSongPlayed)
		{
			lastSongPlayed = SONG.song;
			Conductor.songPosition = 0;
			Conductor.lastSongPos = 0;
			resetToStart = true;
		}

		strumLine = new FlxSprite(0, (FlxG.height / 2) - 295).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		blackBox = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        blackBox.alpha = 0;
		add(blackBox);
		
		handOne = DiffCalc.lastDiffHandOne;
		handTwo = DiffCalc.lastDiffHandTwo;
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(58, strumLine.y + -10);

			babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets','shared');
			babyArrow.animation.addByPrefix('green', 'arrowUP');
			babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
			babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
			babyArrow.animation.addByPrefix('red', 'arrowRIGHT');
			if(FlxG.save.data.antialiasing)
				{
					babyArrow.antialiasing = true;
				}
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

			switch (Math.abs(i))
			{
				case 2:
					babyArrow.x += DiffOverviewNote.swagWidth * 2;
					babyArrow.animation.addByPrefix('static', 'arrowUP');
					babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
				case 3:
					babyArrow.x += DiffOverviewNote.swagWidth * 3;
					babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
					babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
				case 1:
					babyArrow.x += DiffOverviewNote.swagWidth * 1;
					babyArrow.animation.addByPrefix('static', 'arrowDOWN');
					babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
				case 0:
					babyArrow.x += DiffOverviewNote.swagWidth * 0;
					babyArrow.animation.addByPrefix('static', 'arrowLEFT');
					babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
					babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.ID = i;

			babyArrow.alpha = 0;

			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.circOut, startDelay: Conductor.crochet / 1000 + (0.2 * i)});

			playerStrums.add(babyArrow);

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2));
		}

        add(playerStrums);

		generateSong();

        playerStrums.cameras = [camHUD];
        notes.cameras = [camHUD];
        blackBox.cameras = [camHUD];

        blackBox.x = playerStrums.members[0].x;
		blackBox.x -= 25;
        blackBox.y = strumLine.y;
		blackBox.y -= 10;

        camHUD.zoom = 0.6;
		camHUD.x += 295;
		camHUD.y -= 50;
        //camHUD.alpha = 0;
        //camHUD.height = 5000;
		blackBox.width = camHUD.width / 2.5;
        blackBox.scale.y *= 3;


		FlxTween.tween(blackBox, {alpha: 0.5}, 1, {ease: FlxEase.expoInOut});
		//FlxTween.tween(camHUD, {alpha: 1}, 0.5, {ease: FlxEase.expoInOut});

        trace('pog');

		super.create();

		diffSpeedMult = 1 + ((FreeplayState.curDifficulty + 1) * 0.1 - 0.3);
		trace ('difficulty mult = ' + diffSpeedMult);
		defaultScroll = (SONG.speed * diffSpeedMult) * FlxG.save.data.scrollSpeed;
		curScroll = defaultScroll;
		prevScroll = defaultScroll;
		newScroll = defaultScroll;
	}

	var songSpeedTween:FlxTween;

	private function tweenScroll():Void
	{
		if (songSpeedTween != null)
			songSpeedTween.cancel();

		songSpeedTween = FlxTween.tween(this, {curScroll: newScroll}, Conductor.crochet / 1000, {ease: FlxEase.smootherStepOut,
			onUpdate: function(twn:FlxTween) 
			{
				for (note in notes) 
				{
					note.scrollSpeed = curScroll;
				}
				for (note in unspawnNotes) 
				{
					note.scrollSpeed = curScroll;
				}
			},
			
			onComplete: function(twn:FlxTween) 
			{
				for (note in notes) 
				{
					note.scrollSpeed = newScroll;
				}
				for (note in unspawnNotes) 
				{
					note.scrollSpeed = newScroll;
				}
				curScroll = newScroll; //Failsafe
				songSpeedTween = null;
			}
		});
	}

    function endSong()
    {
        if (stopDoingShit)
            return;
		FlxG.sound.playMusic(Paths.inst(SONG.song), 1, true);
		close();
	}

    function resyncVocals():Void
        {
            vocals.pause();
    
            FlxG.sound.music.play();
            Conductor.songPosition = FlxG.sound.music.time;
            vocals.time = Conductor.songPosition;
            vocals.play();
        }

    public var stopDoingShit = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (Conductor.songPosition < FlxG.sound.music.length)
			Conductor.songPosition += FlxG.elapsed * 1000;
		else if (Conductor.songPosition != FlxG.sound.music.length)
			Conductor.songPosition = FlxG.sound.music.length;

		if (unspawnNotes[0] != null)
		{
			var time:Float = 2000;
			if(curScroll < 1) 
				time = 2000 / curScroll;
			while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
			{
				var dunceNote:DiffOverviewNote = unspawnNotes[0];
				notes.insert(0, dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		notes.sort(FlxSort.byY, FlxSort.DESCENDING);

		if (SONG.notes[Std.int(curStep / 16)] != null && !stopDoingShit)
		{
			if (FlxG.sound.music.playing)
			{				
				if (SONG.eventObjects != null && SONG.eventObjects.length != 0)
				{
					for(i in SONG.eventObjects)
					{
						switch(i.type)
						{
							case "Scroll Speed Change":
								if (i.position <= curDecimalBeat && !i.triggerCheck)
								{
									i.triggerCheck = true;
									prevScrollCheck = false;
									if (newScroll != i.value)
										trace('susChange = ' + newScroll + ' -> ' + i.value);
									prevScroll = newScroll;
									newScroll = (i.value * diffSpeedMult) * FlxG.save.data.scrollSpeed;
									tweenScroll();
								}
							case "BPM Change":
								var timingSeg = TimingStruct.getTimingAtTimestamp(Conductor.songPosition);

								if (timingSeg != null)
								{
									var timingSegBpm = timingSeg.bpm;
					
									if (timingSegBpm != Conductor.bpm)
									{
										#if debug
										trace("BPM CHANGE to " + timingSegBpm);
										#end
										Conductor.changeBPM(timingSegBpm, false);
										fakeCrochet = (60 / timingSegBpm) * 1000;		
									}

									TimingStruct.clearTimings();

									var currentIndex = 0;
									var beat:Float = i.position;
									var endBeat:Float = Math.POSITIVE_INFINITY;
			
									TimingStruct.addTiming(beat,i.value,endBeat, 0); // offset in this case = start time since we don't have a offset
									
									if (currentIndex != 0)
									{
										var data = TimingStruct.AllTimings[currentIndex - 1];
										data.endBeat = beat;
										data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
										TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
									}
			
									currentIndex++;
								}
						}
					}
				}
			}
		}

		notes.forEachAlive(function(daNote:DiffOverviewNote)
		{
			// instead of doing stupid y > FlxG.height
			// we be men and actually calculate the time :)
			if (daNote.tooLate)
			{
				if (!daNote.isOnScreen(camHUD))
				{
					daNote.active = false;
					daNote.visible = false;
				}	
			}
			else
			{
				daNote.visible = true;
				daNote.active = true;
			}

			var center:Float = playerStrums.members[daNote.noteData].y + DiffOverviewNote.swagWidth / 2;

			daNote.y = (playerStrums.members[daNote.noteData].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * daNote.scrollSpeed);

			if (daNote.isSustainNote)
			{
				//Prevents the sustain notes from beign separated from it's parents
				daNote.y -= 10.5 * (fakeCrochet / 400) * 1.5 * daNote.scrollSpeed + (46 * (daNote.scrollSpeed - 1));
				daNote.y += 46 * (1 - (fakeCrochet / 600)) * daNote.scrollSpeed;
				daNote.y -= 40;

				if (daNote.mustPress && ((daNote.parent.wasGoodHit && daNote.sustainActive)) || !daNote.mustPress)
				{
					// Clip to strumline
					if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
					{
						var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
						swagRect.y = (center - daNote.y) / daNote.scale.y;
						swagRect.height -= swagRect.y;
						swagRect.bottom = swagRect.y + daNote.height + 30; //basically playing it safe

						daNote.clipRect = swagRect;
					}
				}
			}
			
			daNote.visible = playerStrums.members[daNote.noteData].visible;
			if (daNote.x != playerStrums.members[daNote.noteData].x)
			{
				daNote.x = playerStrums.members[daNote.noteData].x;
				if (daNote.isSustainNote)
				{
					daNote.x += daNote.width / 2 + 20;
					switch (daNote.noteData)
					{
						case 0 | 1:
							daNote.x += 1;
						case 2 | 3:
							daNote.x -= 1;
					}
				}
			}

			if (daNote.sustainActive)
				daNote.alpha = daNote.baseAlpha * playerStrums.members[daNote.noteData].alpha;

            // auto hit
            if(daNote.y < strumLine.y && daNote.noteType != 'mine')
			{
				// Force good note hit regardless if it's too late to hit it or not as a fail safe
				if(!daNote.wasGoodHit)
				{
					daNote.wasGoodHit = true;
					vocals.volume = 1;
			
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			}
		});

	}

	//Functions From PsychEngine
	function clearAllNotes() 
	{
		while(notes.length > 0) 
		{
			var daNote:DiffOverviewNote = notes.members[0];
			//daNote.finnaBeKilled = true;
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
	}

	override function destroy()
	{
		clearAllNotes();
		FlxG.sound.music.onComplete = null;
		if (!FlxG.sound.music.looped)
			FlxG.sound.music.looped = true;
		stopDoingShit = true;
		vocals.fadeOut(0.3);
		camHUD.alpha = 0;
		FreeplayState.previewOpen = false;
		super.destroy();
	}

	var vocals:FlxSound;

	var notes:FlxTypedGroup<DiffOverviewNote>;
	var unspawnNotes:Array<DiffOverviewNote> = [];

	public function generateSong():Void
	{
		Conductor.changeBPM(SONG.bpm);

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(SONG.song));
		else
			vocals = new FlxSound();

		trace('loaded vocals');

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<DiffOverviewNote>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = SONG.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				//This is were the notes are created!
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var daNoteStyle:String = songNotes[3];

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:DiffOverviewNote;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				if (!gottaHitNote)
					continue;

				var swagNote:DiffOverviewNote = new DiffOverviewNote(daStrumTime, daNoteData, oldNote, false, daNoteStyle);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollSpeed = defaultScroll;

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				if (susLength > 0)
					swagNote.isParent = true;
				unspawnNotes.push(swagNote);

				var type = 0;

				//this is where sustain notes are created!
				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:DiffOverviewNote = new DiffOverviewNote(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, daNoteStyle);
					sustainNote.scrollSpeed = defaultScroll;
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;
					sustainNote.alpha = 0;
					sustainNote.baseAlpha = 0.5;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}

					sustainNote.parent = swagNote;
					swagNote.children.push(sustainNote);
					sustainNote.spotInLine = type;
					if (type == 0)
					{
						sustainNote.isBehindParent = true;
						//sustainNote.connectSusToParent();
						//sustainNote.connectToParent(strumLine.y);
					}
					type++;
					if (type == Math.floor(susLength - 1))
						sustainNote.isBeforeTail;
				}

				swagNote.mustPress = gottaHitNote;
				swagNote.alpha = 0;
				swagNote.baseAlpha = 0.9;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			daBeats += 1;
		}

		unspawnNotes.sort(sortByShit);

        Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		
		for (daNote in notes) 
		{
			if (daNote.scrollSpeed != defaultScroll)
				daNote.scrollSpeed = defaultScroll;
		}

		if (resetToStart)
		{
			FlxG.sound.playMusic(Paths.inst(SONG.song), 1, false);
			FlxG.sound.music.onComplete = endSong;
			vocals.play();
		}
		else
		{
			vocals.play();
			vocals.volume = 0;
			Conductor.songPosition = FlxG.sound.music.time;
			vocals.time = Conductor.songPosition;
			FlxG.sound.music.play();
			FlxG.sound.music.onComplete = endSong;
			vocals.volume = 1;
		}
	}

	function sortByShit(Obj1:DiffOverviewNote, Obj2:DiffOverviewNote):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}
}
