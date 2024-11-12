package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'guy-default';
	public var healthIcon:String = 'guy-default';

	public var holdTimer:Float = 0;
	public var dodgetime:Float = 0;

	public function new(x:Float, y:Float, ?character:String = "guy-default", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		if(FlxG.save.data.antialiasing)
			{
				antialiasing = true;
			}

		healthIcon = PlayStateHelpers.getIconID(curCharacter);

		switch (curCharacter)
		{
			case 'table-default':
				tex = Paths.getSparrowAtlas('table_default','shared',true);
				frames = tex;
				animation.addByPrefix('styleCheer', 'GF Cheer', 24, false);
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('cheerFail', 'gf uhh', 24, false);

				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);

				animation.addByPrefix('singLEFT-alt', 'GF left speak', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'GF Right Speak', 24, false);
				animation.addByPrefix('singUP-alt', 'GF Up Speak', 24, false);
				animation.addByPrefix('singDOWN-alt', 'GF Mic Hit', 24, false);

				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);
				loadOffsetFile(curCharacter);
				playAnim('danceRight');


			case 'table-theborder':
				tex = Paths.getSparrowAtlas('table_theBorder','shared',true);
				frames = tex;
				animation.addByPrefix('styleCheer', 'GF Cheer', 20, false);
				animation.addByPrefix('cheer', 'GF left note', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);

				animation.addByPrefix('singLEFT-alt', 'GF left speak', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'GF Right Speak', 24, false);
				animation.addByPrefix('singUP-alt', 'GF Up Speak', 24, false);
				animation.addByPrefix('singDOWN-alt', 'GF Mic Hit', 24, false);

				animation.addByPrefix('none', 'gf None', 24, true);
				animation.addByPrefix('fall', 'gf Fall', 24, false);

				animation.addByPrefix('sad', 'gf sad', 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				loadOffsetFile(curCharacter);
				playAnim('danceRight');


			case 'demon-dad':
				tex = Paths.getSparrowAtlas('demonDad','shared',true);
				frames = tex;
				animation.addByPrefix('idle', 'Dad idle dance', 24, false);

				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24);

				animation.addByPrefix('badFingerStart', 'Dad Finger Start', 24, false);
				animation.addByPrefix('badFingerHold', 'Dad Finger Hold', 24);

				loadOffsetFile(curCharacter);
				playAnim('idle');


			case 'priest-theborderpray':
				tex = Paths.getSparrowAtlas('priest_theBorder','shared',true);
				frames = tex;
				animation.addByPrefix('singUP', 'Pray Up', 24, false);
				animation.addByPrefix('singDOWN', 'Pray Down', 24, false);
				animation.addByPrefix('singLEFT', 'Pray Left', 24, false);
				animation.addByPrefix('singRIGHT', 'Pray Right', 24, false);

				animation.addByIndices('danceLeft', 'Idle Dance', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'Idle Dance', [8, 10, 12, 14], "", 12, false);

				animation.addByPrefix('scared', 'Scared Normal', 24);
				animation.addByPrefix('gotPissed', 'Got Pissed', 24);
				animation.addByPrefix('angryLoop', 'Annoyed Loop', 24);

				loadOffsetFile(curCharacter);
				playAnim('danceRight');


			case 'priest-theborderannoyed':
				tex = Paths.getSparrowAtlas('priest_theBorder','shared',true);
				frames = tex;
				animation.addByPrefix('singUP', 'Sing Annoyed Up', 24, false);
				animation.addByPrefix('singDOWN', 'Sing Annoyed Down', 24, false);
				animation.addByPrefix('singLEFT', 'Sing Annoyed Left', 24, false);
				animation.addByPrefix('singRIGHT', 'Sing Annoyed Right', 24, false);
				animation.addByPrefix('idle', "Idle Annoyed", 24, false);

				animation.addByPrefix('scared', 'Scared Annoyed', 24);
				animation.addByPrefix('gotPissed', 'Got Pissed', 24);
				animation.addByPrefix('angryLoop', 'Annoyed Loop', 24);

				loadOffsetFile(curCharacter);
				playAnim('idle');


			case 'priest-theborderangry':
				tex = Paths.getSparrowAtlas('priest_theBorderAngry','shared',true);
				frames = tex;
				animation.addByPrefix('singUP', 'Sing Up', 24, false);
				animation.addByPrefix('singDOWN', 'Sing Down', 24, false);
				animation.addByPrefix('singLEFT', 'Sing Left', 24, false);
				animation.addByPrefix('singRIGHT', 'Sing Right', 24, false);
				animation.addByPrefix('idle', "Idle", 24, false);
				animation.addByPrefix('singUP-alt', 'Sing Angry Up', 24, false);
				animation.addByPrefix('singDOWN-alt', 'Sing Angry Down', 24, false);
				animation.addByPrefix('singLEFT-alt', 'Sing Angry Left', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'Sing Angry Right', 24, false);

				animation.addByPrefix('scared', 'Scared Normal', 24);
				animation.addByPrefix('angryLoop', 'Angry Loop', 24);
				animation.addByPrefix('midsongAnim', 'Midsong Loop', 24);
				animation.addByPrefix('endsongAnim1', 'Endsong Cutscene A', 24, false);
				animation.addByPrefix('endsongAnim2', 'Endsong Cutscene B', 24);
				animation.addByPrefix('endsongAnim3', 'Endsong Cutscene C', 24);

				loadOffsetFile(curCharacter);
				playAnim('idle');


			case 'pico-default':
				tex = Paths.getSparrowAtlas('pico_default','shared',true);
				frames = tex;
				animation.addByPrefix('idle', "Pico Idle Dance", 24, false);
				animation.addByPrefix('singUP', 'pico Up note0', 24, false);
				animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
				if (isPlayer)
				{
					animation.addByPrefix('singLEFT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico Note Right Miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico NOTE LEFT miss', 24, false);
				}
				else
				{
					// Need to be flipped! REDO THIS LATER!
					animation.addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico NOTE LEFT miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico Note Right Miss', 24, false);
				}

				animation.addByPrefix('singUPmiss', 'pico Up note miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Pico Down Note MISS', 24, false);

				animation.addByPrefix('gunLOAD', 'Pico Load Gun', 24, false);
				animation.addByPrefix('gunSHOOT', 'Pico Shoot Gun', 24, false);
				animation.addByPrefix('gunSHOCKED', 'Pico Load Shocked', 24, false);
				animation.addByPrefix('gunPISSED', 'Pico Load Annoyed', 24, false);
				animation.addByPrefix('gunWARNING', 'Pico Shoot Annoyed', 24, false);

				loadOffsetFile(curCharacter);
				flipX = true;
				playAnim('idle');


			case 'guy-default':
				tex = Paths.getSparrowAtlas('guy_default','shared',true);
				frames = tex;

				animation.addByPrefix('idle', 'GUY idle dance', 12, false);
				animation.addByPrefix('idleAfterSing', 'GUY idle hold', 12, false);
				animation.addByPrefix('singUP', 'GUY NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'GUY NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'GUY NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'GUY NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'GUY NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'GUY NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'GUY NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'GUY NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'GUY HEY', 24, false);
				animation.addByPrefix('style', 'GUY HEY', 24, false);

				animation.addByPrefix('dodgeA', 'GUY Dodge A', 24, false);
				animation.addByPrefix('dodgeB', 'GUY Dodge B', 24, false);

				animation.addByPrefix('awkward', 'GUY Awkward', 12, false);

				animation.addByPrefix('firstDeath', "GUY dies", 24, false);
				animation.addByPrefix('deathLoop', "GUY Dead Loop", 28, false);
				animation.addByPrefix('deathConfirm', "GUY Dead confirm", 24, false);

				animation.addByPrefix('scared', 'GUY idle shaking', 24, true);
				animation.addByPrefix('scaredHOLD', 'GUY shaking hold', 24, false);

				animation.addByPrefix('hurt', 'GUY gotShot', 25, false);

				loadOffsetFile(curCharacter);
				playAnim('idle');
				flipX = true;


			case 'guy-fail':
				tex = Paths.getSparrowAtlas('guy_Fail','shared',true);
				frames = tex;

				trace(tex.frames.length);

				animation.addByPrefix('firstDeath', "GUY fails", 24, false);
				animation.addByPrefix('deathLoop', "GUY Failed Idle", 24, false);
				animation.addByPrefix('deathConfirm', "GUY Failed retry", 24, false);

				loadOffsetFile(curCharacter);
				playAnim('firstDeath');
				flipX = true;


			case 'guy-theborder':
				tex = Paths.getSparrowAtlas('guy_theBorder','shared',true);
				frames = tex;

				trace(tex.frames.length);

				animation.addByPrefix('idle', 'GUY idle dance', 12, false);
				animation.addByPrefix('idleAfterSing', 'GUY idle hold', 12, false);
				animation.addByPrefix('singUP', 'GUY NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'GUY NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'GUY NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'GUY NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'GUY NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'GUY NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'GUY NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'GUY NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'GUY HEY', 24, false);
				animation.addByPrefix('style', 'GUY HEY', 24, false);

				animation.addByPrefix('awkward', 'GUY Awkward', 12, false);
				animation.addByPrefix('concerned', 'GUY U OK', 24, false);

				animation.addByPrefix('firstDeath', "GUY dies", 24, false);
				animation.addByPrefix('deathLoop', "GUY Dead Loop", 28, false);
				animation.addByPrefix('deathConfirm', "GUY Dead confirm", 24, false);

				animation.addByPrefix('scared', 'GUY idle shaking', 24);
				animation.addByPrefix('scaredHOLD', 'GUY shaking hold', 24, false);

				loadOffsetFile(curCharacter);
				playAnim('idle');
				flipX = true;

				
			case 'selfsert-default':
				tex = Paths.getSparrowAtlas('selfsert_default','shared',true);
				frames = tex;
				animation.addByPrefix('idle', 'DreamedWave idle dance', 13, false);
				animation.addByPrefix('idleAfterSing', 'DreamedWave idle hold', 13, false);
				animation.addByPrefix('singUP', 'DreamedWave NOTE UP0', 14, false);
				animation.addByPrefix('style', 'DreamedWave OHSHIT', 18, false);
				if (!isPlayer)
				{
					//Inverted Left and Right
					animation.addByPrefix('singLEFT', 'DreamedWave NOTE RIGHT0', 14, false);
					animation.addByPrefix('singRIGHT', 'DreamedWave NOTE LEFT0', 14, false);
					animation.addByPrefix('singLEFTmiss', 'DreamedWave NOTE RIGHT MISS', 12, false);
					animation.addByPrefix('singRIGHTmiss', 'DreamedWave NOTE LEFT MISS', 12, false);
				}
				else
				{
					animation.addByPrefix('singLEFT', 'DreamedWave NOTE LEFT0', 14, false);
					animation.addByPrefix('singRIGHT', 'DreamedWave NOTE RIGHT0', 14, false);
					animation.addByPrefix('singLEFTmiss', 'DreamedWave NOTE LEFT MISS', 12, false);
					animation.addByPrefix('singRIGHTmiss', 'DreamedWave NOTE RIGHT MISS', 12, false);
				}
				animation.addByPrefix('singDOWN', 'DreamedWave NOTE DOWN0', 14, false);
				animation.addByPrefix('singUPmiss', 'DreamedWave NOTE UP MISS', 12, false);
				animation.addByPrefix('singDOWNmiss', 'DreamedWave NOTE DOWN MISS', 12, false);
				animation.addByPrefix('awkward', 'DreamedWave OHSHIT', 15, false);

				animation.addByPrefix('firstDeath', "DreamedWave dies", 20, false);
				animation.addByPrefix('deathLoop', "DreamedWave Dead Loop", 24, false);
				animation.addByPrefix('deathConfirm', "DreamedWave Dead confirm", 18, false);

				animation.addByPrefix('scared', 'DreamedWave idle shaking', 24);

				if (isPlayer)
					loadOffsetFile(curCharacter + '_player');
				else
					loadOffsetFile(curCharacter);
				flipX = true;
				playAnim('idle');
		}

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('guy') && !curCharacter.startsWith('selfsert'))
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	public function loadOffsetFile(character:String)
	{
		var offset:Array<String> = CoolUtil.coolTextFile(Paths.txt('images/characters/' + character + "Offsets", 'shared'));

		for (i in 0...offset.length)
		{
			var data:Array<String> = offset[i].split(' ');
			addOffset(data[0], Std.parseInt(data[1]), Std.parseInt(data[2]));
		}
	}

	override function update(elapsed:Float)
	{
		if (dodgetime > 0)
			dodgetime--;
		else if (dodgetime < 0)
			dodgetime = 0;

		if (!curCharacter.startsWith('guy') && (!curCharacter.startsWith('selfsert') || !isPlayer))
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;

			switch (curCharacter)
			{
				case "demon-dad":
					dadVar = 6;
				case "selfsert-default":
					dadVar = 7.1;
			}
			if (holdTimer > Conductor.stepCrochet * dadVar * 0.001)
			{
				//trace('dance');
				dance();
				holdTimer = 0;
			}
		}
		
		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(forced:Bool = true)
	{
		if (!debugMode)
		{
			switch (curCharacter)
			{
				case 'table-default' | 'table-theborder':
					if ((!animation.curAnim.name.startsWith("sing") || animation.curAnim.finished) && (!animation.curAnim.name.startsWith("style") || animation.curAnim.curFrame >= 3))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight', forced);
						else
							playAnim('danceLeft', forced);
					}
				case 'priest-theborderpray':
					//if (!animation.curAnim.name.startsWith("sing") || animation.curAnim.curFrame >= 5)
					//{
						danced = !danced;

						if (danced)
							playAnim('danceRight', forced);
						else
							playAnim('danceLeft', forced);
					//}
				/*case 'demon-dad':
					if (!animation.curAnim.name.startsWith("sing") || animation.curAnim.curFrame >= 6)
						playAnim('idle', forced);*/
				default:
					//if (!animation.curAnim.name.startsWith("sing") || animation.curAnim.curFrame >= 5)
					playAnim('idle', forced);
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'table-default' || curCharacter == 'table-theborder' || curCharacter == 'priest-theborderpray')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}
