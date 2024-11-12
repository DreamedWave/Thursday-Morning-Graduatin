package;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;

using StringTools;

class MinigamePlayer extends FlxSprite
{
	var touchedFloorAgain:Bool = true;
	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		trace('loading playurr');
		loadGraphic('assets/minigame/images/player.png', true, 32, 32);
		setFacingFlip(LEFT, true, false);
		setFacingFlip(RIGHT, false, false);
		animation.add("idle", [0, 1], 3, false);
		animation.add("idle_static", [0], 1, false);
		animation.add("walkLEFT", [2, 3], 5, false);
		animation.add("walkRIGHT", [4, 5], 5, false);
		animation.add("jump_charge", [6, 6, 7], 15, false);
		animation.add("jump_midAir", [8], 1, false);
		animation.add("jump_falling", [9], 1, false);
		animation.add("jump_land", [10, 11, 1, 0], 20, false);
		animation.add("jump_landHARD", [10, 10, 10, 11, 11, 6, 1, 0], 15, false);
		maxVelocity.set(100, 830);
		acceleration.y = 500;
		drag.x = maxVelocity.x*4;
		setSize(18, 28);
		offset.set(7, 1);
		animation.play("idle");

		var minigameSFX:Array<String> = ["walk0", "walk1", "walk2", "walk3", "walk4", "walk5", "jump0", "jump1", "jump2", "jump3", "jump4", "jump5"]; //, "land0", "land1", "land2", "land3", "land4", "land5", "landHard0", "landHard1", "landHard2", "landHard3", "landHard4", "landHard5"];
		for (i in minigameSFX) 
		{
			FlxG.sound.load(Paths.sound(i, 'minigame'));
		}
	}

	private var walked:Bool = false;
	var jumpCount:Int = 0;
	var chargePower:Float = 0.18;
	var inTerminalVelocity:Bool = false;

	override function update(elapsed:Float)
	{
		acceleration.x = 0;

		if(FlxG.keys.anyPressed([LEFT, A]) && !FlxG.keys.anyPressed([SPACE]))
		{
			if (isTouching(FlxObject.FLOOR))
				acceleration.x = -maxVelocity.x*3;
			else
				acceleration.x = -maxVelocity.x*1.5;
			facing = LEFT;
			if (!animation.curAnim.name.startsWith("jump") || ((animation.curAnim.name.startsWith("jump") && animation.curAnim.finished)))
				playerWalk();
		}
		if(FlxG.keys.anyPressed([RIGHT, D]) && !FlxG.keys.anyPressed([SPACE]))
		{
			if (isTouching(FlxObject.FLOOR))
				acceleration.x = maxVelocity.x*2;
			else
				acceleration.x = maxVelocity.x*1;
			facing = RIGHT;
			if (!animation.curAnim.name.startsWith("jump") || ((animation.curAnim.name.startsWith("jump") && animation.curAnim.finished)))
				playerWalk();
		}

		//Jump
		if (FlxG.keys.justReleased.SPACE && jumpCount < 2)
		{
			velocity.y = (-chargePower * maxVelocity.y);
			FlxG.sound.play(Paths.soundRandom('jump', 0, 5, 'minigame'), 0.6);
			jumpCount++;
		}

		if(FlxG.keys.pressed.SPACE && isTouching(FlxObject.FLOOR) && jumpCount < 2)
		{
			if (animation.curAnim.name != 'jump_charge')
				animation.play("jump_charge", false);
			else if (animation.curAnim.name == 'jump_charge' && chargePower < 0.35)
				chargePower += 0.003;
			trace(chargePower);
			/*canJump = false;
			trace('player jump!');
			new FlxTimer().start(0.3, function(tmr:FlxTimer)
			{
				//if (!isTouching(FlxObject.FLOOR))
				//	tmr.reset(0.3);
				//else
					canJump = true;
			});*/
		}

		if(FlxG.keys.justPressed.R)
		{
			FlxG.resetState();
		}

		if (isTouching(FlxObject.FLOOR) && !touchedFloorAgain)
		{
			if (!inTerminalVelocity)
			{
				trace ('chickitee 1');
				animation.play("jump_land", false);
				//FlxG.sound.play(Paths.soundRandom('minigame/land', 0, 5), 0.8);
				FlxG.sound.play(Paths.soundRandom('walk', 0, 5, 'minigame'), 0.65);
			}
			else
			{
				trace ('chickitee 2');
				animation.play("jump_landHARD", false);
				MinigameState.shakeCam = true;
				//FlxG.sound.play(Paths.soundRandom('minigame/landHard', 0, 5), 0.8);
				FlxG.sound.play(Paths.soundRandom('walk', 0, 5, 'minigame'), 0.7);
				inTerminalVelocity = false;
			}
			touchedFloorAgain = true;
			jumpCount = 0;
			chargePower = 0.18;
		}
		else if (!isTouching(FlxObject.FLOOR))
		{
			if (velocity.y > 415)
				inTerminalVelocity = true;
			if (velocity.y <= 0)
				animation.play("jump_midAir");
			else if (velocity.y > 0)
				animation.play("jump_falling");
			touchedFloorAgain = false;
			trace("Velocity Y = " + velocity.y);
			//trace("Max Velocity Limit = " + maxVelocity.y * 0.4);
		}

		if (animation.curAnim.finished && velocity.x == 0 && velocity.x == 0 && isTouching(FlxObject.FLOOR) && !FlxG.keys.anyPressed([A, S, W, D, SPACE]))
			animation.play("idle", true);

		super.update(elapsed);
	}

	var playWalkSound:Bool = false;

	function playerWalk()
	{
		if ((animation.curAnim.name == 'idle' || animation.curAnim.finished) && velocity.x != 0)
		{
			trace ('walk!');
			walked = !walked;

			if(!walked)
				animation.play("walkLEFT");
			else
				animation.play("walkRIGHT");
		}
		
		if ((animation.curAnim.name.startsWith("walk") && animation.curAnim.curFrame == 0) && velocity.x != 0 && !playWalkSound)
			playWalkSound = true;
		else if ((animation.curAnim.name.startsWith("walk") && animation.curAnim.curFrame == 1) && velocity.x != 0 && playWalkSound)
		{
			FlxG.sound.play(Paths.soundRandom('walk', 0, 5, 'minigame'), 0.5);
			playWalkSound = false;
		}
	}
}