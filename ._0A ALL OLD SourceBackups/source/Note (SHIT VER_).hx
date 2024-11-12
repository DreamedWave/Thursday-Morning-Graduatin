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
import PlayState;

using StringTools;

class Note extends FlxSprite
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
	public var forceMiss:Bool = false;
	public var prevNote:Note;
	//public var modifiedByLua:Bool = false;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var isSustainTail:Bool = false;
	var originColor:Int = 0; // The sustain note's original note's color
	//public var noteSection:Int = 0;

	//public var noteCharterObject:FlxSprite;

	//public var noteScore:Float = 1;

	public var noteYOff:Int = 0;

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
	public var childBehindParent:Bool = false;
	public var parent:Note = null;
	public var spotInLine:Int = 0;
	public var sustainActive:Bool = true;

	public var lowPriority:Bool = false;

	//for sus note fixins
	var targetScale:Float = 0;
	public var scrollSpeed:Float = PlayStateChangeables.scrollSpeed;
	//var sustainHeightGap:Float = 0;
	//public var sustainNoteGap:Float = 0; //The gaps between sustain notes idfk
	//public var defaultScaleX:Float = 1;
	//public var defaultScaleY:Float = 1;
	//public var prevX:Float = 0;
	//public var prevY:Float = 0;

	public var finnaBeKilled:Bool = false;

	public var children:Array<Note> = [];

	public var toggledSurpriseNote:Bool = false;
	public var triggeredNoteEvent:Bool = false;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inCharter = false, noteType:String = 'normal')
	{
		super();

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
			rStrumTime = strumTime - (FlxG.save.data.offset + PlayState.songOffset);
		}


		if (this.strumTime < 0 )
			this.strumTime = 0;

		this.noteData = noteData;

		var daStage:String = PlayState.curStage;

		//defaults if no noteStyle was found in chart
		var noteStyleCheck:String = 'normal';
		
		if (inCharter)
		{
			frames = Paths.getSparrowAtlas('charterNOTE_assets');
			for (i in 0...4)
			{
				switch(noteType)
				{
					case 'mine':
						animation.addByPrefix(dataColor[i] + 'Scroll', 'mineNote'); // Normal notes
						//animation.addByPrefix(dataColor[i] + 'mineHold', dataColor[i] + ' hold'); // Hold
						//animation.addByPrefix(dataColor[i] + 'mineHoldend', dataColor[i] + ' tail'); // Tails
					case 'trigger':
						animation.addByPrefix(dataColor[i] + 'Scroll', 'triggerNote'); // Normal notes
						//animation.addByPrefix(dataColor[i] + 'triggerHold', dataColor[i] + ' hold'); // Hold
						//animation.addByPrefix(dataColor[i] + 'triggerHoldend', dataColor[i] + ' tail'); // Tails
					default:
						animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' alone'); // Normal notes
						//animation.addByPrefix(dataColor[i] + 'hold', dataColor[i] + ' hold'); // Hold
						//animation.addByPrefix(dataColor[i] + 'holdend', dataColor[i] + ' tail'); // Tails
				}
			}

			/*for (i in 0...4)
			{
				animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' alone', 18, true); // Normal notes
				//animation.addByPrefix(dataColor[i] + 'hold', dataColor[i] + ' hold'); // Hold
				//animation.addByPrefix(dataColor[i] + 'holdend', dataColor[i] + ' tail'); // Tails
			}*/

			setGraphicSize(Std.int(width * 0.7));
			updateHitbox();
			//if(FlxG.save.data.antialiasing)
			//	antialiasing = true;

			animation.play(dataColor[noteData] + 'Scroll');
		}
		else
		{
			if (PlayState.SONG.noteStyle == null) 
			{
				switch(PlayState.storyWeek) 
				{
					case 6: noteStyleCheck = 'pixel';
				}
			} 
			else 
				noteStyleCheck = PlayState.SONG.noteStyle;
			
			switch (noteStyleCheck)
			{
				default:
					switch(noteType)
					{
						case 'mine':
							lowPriority = true;
							frames = Paths.getSparrowAtlas('mineNOTE_assets');
							for (i in 0...4)
							{
								animation.addByPrefix(dataColor[i] + 'surpriseScroll', dataColor[i] + ' camouflage'); // Camo notes
								animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' alone'); // Normal notes
								animation.addByPrefix(dataColor[i] + 'hold', dataColor[i] + ' hold'); // Hold
								animation.addByPrefix(dataColor[i] + 'holdend', dataColor[i] + ' tail'); // Tails
							}
						case 'trigger':
							frames = Paths.getSparrowAtlas('triggerNOTE_assets');
							for (i in 0...4)
							{
								animation.addByPrefix(dataColor[i] + 'surpriseScroll', dataColor[i] + ' camouflage'); // Camo notes
								animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' alone'); // Normal notes
								animation.addByPrefix(dataColor[i] + 'hold', dataColor[i] + ' hold'); // Hold
								animation.addByPrefix(dataColor[i] + 'holdend', dataColor[i] + ' tail'); // Tails
							}
						default:
							frames = Paths.getSparrowAtlas('NOTE_assets');
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
			}
		}

		x += swagWidth * noteData;
		
		if (!inCharter)
		{
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
		}
		else
			animation.play(dataColor[noteData] + 'Scroll');
		originColor = noteData; // The note's origin color will be checked by its sustain notes

		if (FlxG.save.data.downscroll && sustainNote) 
			flipY = true;

		if (isSustainNote && prevNote != null)
		{
			//noteScore * 0.2;
			//alpha = 0.6;

			x += width / 2;

			originColor = prevNote.originColor; 

			animation.play(dataColor[originColor] + 'holdend'); // This works both for normal colors and quantization colors
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
				if (prevNote.isParent)
					childBehindParent = true;
				
				//IDFK A BETTER WAY LMAO
				prevNote.isSustainTail = false;
				prevNote.animation.play(dataColor[prevNote.originColor] + 'hold');
				prevNote.scale.y *= Conductor.stepCrochet / 100 * 1.05;
				prevNote.scale.y += ((0.5 + scrollSpeed) * Math.sqrt(prevNote.scrollSpeed));
				prevNote.targetScale = prevNote.scale.y;
				prevNote.updateHitbox();
				prevNote.noteYOff = Math.round(-prevNote.offset.y);
				//noteYOff = Math.round(-offset.y);
				correctHeightGap(y, prevNote.y, prevNote.height, prevNote.frameHeight);
			}
		}
	}

	public function correctHeightGap(daY:Float, daPrevY:Float, daPrevHeight:Float, daPrevFrameHeight:Float):Void
	{
		var correctedScaleY:Float = 0;
		var heightGap:Float = daY - daPrevHeight - daPrevY;

		if (heightGap > 0 || heightGap < -5)
		{
			var sustainSum:Float = daPrevY + daPrevHeight + heightGap;
			correctedScaleY = sustainSum / daPrevFrameHeight;
			prevNote.scale.y = correctedScaleY;
			prevNote.targetScale = prevNote.scale.y;
			prevNote.updateHitbox();
			trace ('peanice');
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		angle = modAngle + localAngle;

		if (scale.y != targetScale && isSustainNote && !isSustainTail)
		{
			//DONT EVEN SAY IT I KNOW THIS SHIT HS BAD
			targetScale *= Conductor.stepCrochet / 100 * 1.05;
			targetScale += ((0.5 + scrollSpeed) * Math.sqrt(scrollSpeed));
			scale.y = FlxMath.lerp(targetScale, scale.y, CoolUtil.boundTo(1 - (elapsed * 20), 0, 1));
			updateHitbox();
			noteYOff = Math.round(-offset.y);
			//trace ("SCALE AUGH (Target: " + targetScale + ") (Current: " + scale.y + ")");
			if (prevNote != null)
				correctHeightGap(y, prevNote.y, prevNote.height, prevNote.frameHeight);
		}

		if (!sustainActive)
		{
			alpha = 0.3;
		}

		if (mustPress)
		{
			// ass
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
				{
					canBeHit = true;
					//if (alpha > 0.3)
					//	alpha = 1;
				}
				else
					canBeHit = false;
			}

			if (!tooLate && !toggledSurpriseNote && !isSustainNote && animation.curAnim.name.endsWith('surpriseScroll'))
				if (strumTime - 180 < Conductor.songPosition + Conductor.safeZoneOffset)
					toggledSurpriseNote = true;

			if ((strumTime < Conductor.songPosition - Conductor.safeZoneOffset * Conductor.timeScale && !wasGoodHit && noteType != "mine")
				 || (strumTime - 95 < Conductor.songPosition - Conductor.safeZoneOffset * Conductor.timeScale && !wasGoodHit && noteType == "mine"))
				tooLate = true;
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition && strumTime > Conductor.songPosition - Conductor.safeZoneOffset * Conductor.timeScale)
				wasGoodHit = true;
			else if (strumTime < Conductor.songPosition - Conductor.safeZoneOffset * Conductor.timeScale)
			   tooLate = true;
		}

		if (!PlayState.instance.allowHealthModifiers)
			if (isOnScreen(PlayState.instance.camHUD) && !withinCompensation)
				withinCompensation = true;

		if (tooLate)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
		else if (toggledSurpriseNote)
		{
			animation.play(dataColor[noteData] + 'Scroll');
			if (noteType != 'mine')
				blend = ADD;
		}
		else if (withinCompensation && color != 0xFFBDFCFF && alpha != 0.75)
		{
			color = 0xFFBDFCFF;
			alpha = 0.75;
			if (!isSustainNote && noteType != 'mine' && noteType != 'trigger')
			{
				animation.play(dataColor[noteData] + 'SafeScroll');
			}
		}
	}
}
