package lore_minigames;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;

using StringTools;

class Player extends FlxSprite
{
	var touchedFloorAgain:Bool = true;
	var defaultMaxVelocityX:Float = 100;
	var defaultMaxVelocityY:Float = 830;
	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		//trace('loading playurr');
		loadGraphic('assets/minigame/images/player.png', true, 32, 32);
		setFacingFlip(LEFT, true, false);
		setFacingFlip(RIGHT, false, false);
		animation.add("idle", [2, 2, 1, 0, 0, 1], 6, true);
		animation.add("idle_static", [2], 1, false);
		animation.add("walkLEFT", [3, 4], 5, false);
		animation.add("walkRIGHT", [5, 6], 5, false);
		animation.add("jump_start", [7, 8], 13, false);
		animation.add("jump_hold", [9, 8], 15, true);
		animation.add("jump_midAir", [10], 1, false);
		animation.add("jump_falling", [11], 1, false);
		animation.add("jump_land", [13, 0, 1, 2], 16, false);
		animation.add("jump_landHARD", [12, 12, 13, 0, 1, 1, 2], 17, false);
		maxVelocity.set(defaultMaxVelocityX, defaultMaxVelocityY);
		acceleration.y = 500;
		drag.x = maxVelocity.x*5;
		setSize(18, 28);
		offset.set(7, 2);
		animation.play("idle");
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
			if (velocity.x > 0)
				velocity.x *= -1;

			if (isTouching(FLOOR)) //Speed on Ground
				acceleration.x = -maxVelocity.x*3;
			else //Speed on Air
				acceleration.x = -maxVelocity.x*1.5;
			facing = LEFT;
			if (!animation.curAnim.name.startsWith("jump") || ((animation.curAnim.name.startsWith("jump") && animation.curAnim.finished)))
				playerWalk();
		}
		if(FlxG.keys.anyPressed([RIGHT, D]) && !FlxG.keys.anyPressed([SPACE]))
		{
			if (velocity.x < 0)
				velocity.x *= -1;
			
			if (isTouching(FLOOR)) //Speed on Ground
				acceleration.x = maxVelocity.x*3;
			else //Speed on Air
			{
				acceleration.x = maxVelocity.x*1.5;
			}
			facing = RIGHT;
			if (!animation.curAnim.name.startsWith("jump") || ((animation.curAnim.name.startsWith("jump") && animation.curAnim.finished)))
				playerWalk();
		}
		if (FlxG.keys.anyPressed([SHIFT, Q])) //Running
			maxVelocity.x = 175;
		else //Resetting of velocity once shift is let go
			maxVelocity.x = defaultMaxVelocityX;

		//Jump
		if (FlxG.keys.justReleased.SPACE && jumpCount < 2)
		{
			velocity.y = (-chargePower * maxVelocity.y);
			FlxG.sound.play('assets/minigame/sounds/jump' + FlxG.random.int(0, 5) + '.ogg', 0.6);
			jumpCount++;
		}

		if(FlxG.keys.pressed.SPACE && isTouching(FLOOR) && jumpCount < 2)
		{
			if (animation.curAnim.name != 'jump_start' && chargePower < 0.35)
				animation.play("jump_start", false);
			else if (animation.curAnim.name == 'jump_start' && chargePower < 0.35)
				chargePower += 0.003;
			else if (animation.curAnim.name != 'jump_hold' && animation.curAnim.name == 'jump_start' && animation.curAnim.finished && chargePower >= 0.35)
				animation.play("jump_hold", false);
			//trace(chargePower);
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

		if (isTouching(FLOOR) && !touchedFloorAgain)
		{
			if (!inTerminalVelocity)
			{
				//trace ('chickitee 1');
				animation.play("jump_land", false);
				//FlxG.sound.play('assets/minigame/sounds/land' + FlxG.random.int(0, 5) + '.ogg', 0.8);
				FlxG.sound.play('assets/minigame/sounds/walk' + FlxG.random.int(0, 5) + '.ogg', 0.65);
			}
			else
			{
				//trace ('chickitee 2');
				animation.play("jump_landHARD", false);
				MinigameState.shakeCam = true;
				//FlxG.sound.play('assets/minigame/sounds/landHard' + FlxG.random.int(0, 5) + '.ogg', 0.8);
				FlxG.sound.play('assets/minigame/sounds/walk' + FlxG.random.int(0, 5) + '.ogg', 0.7);
				inTerminalVelocity = false;
			}
			touchedFloorAgain = true;
			jumpCount = 0;
			chargePower = 0.18;
		}
		else if (!isTouching(FLOOR))
		{
			if (velocity.y > 415)
				inTerminalVelocity = true;
			if (velocity.y <= 0)
				animation.play("jump_midAir");
			else if (velocity.y > 0)
				animation.play("jump_falling");
			touchedFloorAgain = false;
			//trace("Velocity Y = " + velocity.y);
			//trace("Max Velocity Limit = " + maxVelocity.y * 0.4);
		}

		if (animation.curAnim.name != 'idle' && (animation.curAnim.finished || animation.curAnim.name.startsWith("walk")) && velocity.x == 0 && velocity.x == 0 && isTouching(FLOOR) && !FlxG.keys.anyPressed([A, S, W, D, SPACE]))
			animation.play("idle", true);

		super.update(elapsed);
	}

	var playWalkSound:Bool = false;

	function playerWalk()
	{
		if ((animation.curAnim.name == 'idle' || animation.curAnim.finished) && velocity.x != 0)
		{
			//trace ('walk!');
			walked = !walked;

			if(!walked)
				animation.play("walkLEFT");
			else
				animation.play("walkRIGHT");
		}
		
		if ((animation.curAnim.name.startsWith("walk") && animation.curAnim.curFrame == 0) && velocity.x != 0 && !playWalkSound)
		{
			playWalkSound = true;
			FlxG.sound.play('assets/minigame/sounds/walk' + FlxG.random.int(0, 5) + '.ogg', 0.5);
		}
		else if ((animation.curAnim.name.startsWith("walk") && animation.curAnim.curFrame == 1) && velocity.x != 0 && playWalkSound)
		//{
			playWalkSound = false;
		//}
	}
}