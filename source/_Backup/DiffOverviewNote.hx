package;

import flixel.addons.effects.FlxSkewedSprite;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
#if polymod
import polymod.format.ParseRules.TargetSignatureElement;
#end

using StringTools;

class DiffOverviewNote extends FlxSprite
{
	public var strumTime:Float = 0;
	public var baseStrum:Float = 0;
	
	public var rStrumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var rawNoteData:Int = 0;
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var withinCompensation:Bool = false;
	public var prevNote:DiffOverviewNote;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var isSustainTail:Bool = false;
	public var isBeforeTail:Bool = false;
	var originColor:Int = 0; // The sustain note's original note's color
	//public var noteSection:Int = 0;

	public var startSpeeding:Bool = false;
	public var speedingSustainSlip:Bool = false;

	public var forceAlpha:Bool = false;
	public var enabled:Bool = true;
	public var parentID:Int = 0;

	public var noteStyleCheck:String = 'normal';
	public var noteType:String = 'normal';

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public var rating:String = "sick";

	public var modAngle:Float = 0; // The angle set by modcharts
	public var localAngle:Float = 0; // The angle to be edited inside Note.hx

	public var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];
	public var quantityColor:Array<Int> = [RED_NOTE, 2, BLUE_NOTE, 2, PURP_NOTE, 2, BLUE_NOTE, 2];
	//public var arrowAngles:Array<Int> = [180, 90, 270, 0];

	public var isParent:Bool = false;
	public var isBehindParent:Bool = false;
	public var parent:DiffOverviewNote = null;
	public var spotInLine:Int = 0;
	public var sustainActive:Bool = true;

	public var lowPriority:Bool = false;

	//for sus note fixins
	public var scrollSpeed:Float = DiffOverview.instance.curScroll;
	var prevScrollSpeed:Float = DiffOverview.instance.curScroll;
	//public var ratio:Float = 1;
	//var prevRatio:Float = 1;
	//public var targetScale:Float = 0;
	public var baseScale:Float = 0;
	var dunDidFixinsBool:Bool = false;
	//var didInitFixins:Bool = false;

	//public var finnaBeKilled:Bool = false;
	public var delayedDeath:Bool = false;

	public var children:Array<DiffOverviewNote> = [];

	public var toggledSurpriseNote:Bool = false;
	public var triggeredNoteEvent:Bool = false;

	public var baseAlpha:Float = 1;

	var inCharter:Bool;

	public function new(strumTime:Float, noteData:Int, ?prevNote:DiffOverviewNote, ?sustainNote:Bool = false, ?inCharter = false, noteType:String = 'normal')
	{
		super();

		prevScrollSpeed = scrollSpeed;

		this.noteType = noteType;

		if (prevNote == null)
			prevNote = this;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;

		if (inCharter)
		{
			this.strumTime = strumTime;
			rStrumTime = strumTime;
		}
		else
		{
			this.strumTime = strumTime;
			rStrumTime = strumTime - (FlxG.save.data.offset);
		}

		this.inCharter = inCharter;


		if (this.strumTime < 0 )
			this.strumTime = 0;

		this.noteData = noteData;
		
		switch (noteStyleCheck)
		{
			default:
				switch(noteType)
				{
					case 'mine':
						frames = Paths.getSparrowAtlas('mineNOTE_assets', 'shared');
						for (i in 0...4)
						{
							animation.addByPrefix(dataColor[i] + 'surpriseScroll', dataColor[i] + ' camouflage'); // Camo notes
							animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' alone'); // Normal notes
							animation.addByPrefix(dataColor[i] + 'hold', dataColor[i] + ' hold'); // Hold
							animation.addByPrefix(dataColor[i] + 'holdend', dataColor[i] + ' tail'); // Tails
						}
					case 'trigger':
						frames = Paths.getSparrowAtlas('triggerNOTE_assets', 'shared');
						for (i in 0...4)
						{
							animation.addByPrefix(dataColor[i] + 'surpriseScroll', dataColor[i] + ' camouflage'); // Camo notes
							animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' alone'); // Normal notes
							animation.addByPrefix(dataColor[i] + 'hold', dataColor[i] + ' hold'); // Hold
							animation.addByPrefix(dataColor[i] + 'holdend', dataColor[i] + ' tail'); // Tails
						}
					default:
						frames = Paths.getSparrowAtlas('NOTE_assets', 'shared');
						for (i in 0...4)
						{
							animation.addByPrefix(dataColor[i] + 'SafeScroll', dataColor[i] + ' comp'); // Compensated notes
							animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' alone'); // Normal notes
							animation.addByPrefix(dataColor[i] + 'hold', dataColor[i] + ' hold'); // Hold
							animation.addByPrefix(dataColor[i] + 'holdend', dataColor[i] + ' tail'); // Tails
						}
				}

				//trace ("notescale was: " + scale);
				setGraphicSize(Std.int(width * 0.7));
				updateHitbox();
				if(FlxG.save.data.antialiasing)
					antialiasing = true;
				baseScale = scale.y;
		}

		x += swagWidth * noteData;
		
		switch(noteType)
		{
			case 'mine' | 'trigger':
				for (i in 0...4)
				{
					animation.addByPrefix(dataColor[i] + 'surpriseScroll', dataColor[i] + ' camouflage'); // Normal notes
				}
				animation.play(dataColor[noteData] + 'surpriseScroll');
			default:
				for (i in 0...4)
				{
					animation.addByPrefix(dataColor[i] + 'SafeScroll', dataColor[i] + ' comp'); // Normal notes
				}
				animation.play(dataColor[noteData] + 'Scroll');
		}

		originColor = noteData; // The note's origin color will be checked by its sustain notes

		if (FlxG.save.data.downscroll && sustainNote) 
			flipY = true;

		if (isSustainNote && prevNote != null)
		{
			//noteScore * 0.2;
			baseAlpha = 0.7;

			x += width / 2;

			originColor = prevNote.originColor; 

			animation.play(dataColor[originColor] + 'holdend'); // This works both for normal colors and quantization colors
			scale.y = 0.5 + (0.2 * scrollSpeed);
			updateHitbox();
			isSustainTail = true;
			lowPriority = true;
			x -= width / 2;

			//if (noteStyleCheck == 'pixel')
			//	x += 30;
			if (inCharter)
				x += 30;

			if (prevNote.isSustainNote)
			{				
				//IDFK A BETTER WAY LMAO
				prevNote.isSustainTail = false;
				prevNote.animation.play(dataColor[prevNote.originColor] + 'hold');
				prevNote.scale.y = 1;
				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.03;
				prevNote.baseScale = prevNote.scale.y;
				prevNote.scale.y *= prevNote.scrollSpeed;
				//prevNote.targetScale = prevNote.scale.y;
				prevNote.updateHitbox();
				prevNote.dunDidFixinsBool = true;
			}
			dunDidFixinsBool = true;
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		angle = modAngle + localAngle;

		if (isSustainNote)
			{
				if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 1.5)
					&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.5))
					canBeHit = true;
				else
					canBeHit = false;
			}
			else
			{
				if (strumTime > Conductor.songPosition - Conductor.safeZoneOffset
				&& strumTime < Conductor.songPosition + Conductor.safeZoneOffset)
					canBeHit = true;
				else
					canBeHit = false;
			}

		if (!tooLate && !toggledSurpriseNote && !isSustainNote && animation.curAnim.name.endsWith('surpriseScroll'))
			if (strumTime - 180 < Conductor.songPosition + Conductor.safeZoneOffset)
				toggledSurpriseNote = true;
		
		if (toggledSurpriseNote)
		{
			animation.play(dataColor[noteData] + 'Scroll');
			if (noteType != 'mine')
				blend = ADD;
		}
		else if (withinCompensation && color != 0xFFBDFCFF && alpha > 0.65)
		{
			color = 0xFFBDFCFF;
			baseAlpha *= 0.65;
			if (!isSustainNote && noteType != 'mine' && noteType != 'trigger')
			{
				animation.play(dataColor[noteData] + 'SafeScroll');
			}
		}

		if (scrollSpeed != prevScrollSpeed)
		{
			prevScrollSpeed = scrollSpeed;
			if (isSustainNote && dunDidFixinsBool)
			{
				if (!isSustainTail)
					scale.y = baseScale * scrollSpeed;
				else
					scale.y = 0.5 + (0.2 * scrollSpeed);
				updateHitbox();
			}
		}
	}
}
