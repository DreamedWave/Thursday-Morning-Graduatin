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
		loadGraphic('assets/images/minigame/player.png', true, 32, 32);
		setFacingFlip(LEFT, true, false);
		setFacingFlip(RIGHT, false, false);
		animation.add("idle", [0, 1], 5, false);
		animation.add("idle_static", [0], 1, false);
		animation.add("walkLEFT", [2, 3], 10, false);
		animation.add("walkRIGHT", [4, 5], 10, false);
		animation.add("jump_charge", [6, 7, 7, 8], 24, false);
		animation.add("jump_midAir", [8], 1, false);
		animation.add("jump_falling", [9], 1, false);
		animation.add("jump_land", [10, 11, 1, 0], 20, false);
		animation.add("jump_landHARD", [10, 10, 11, 6, 1, 0], 20, false);
		maxVelocity.set(100, 450);
		acceleration.y = 500;
		drag.x = maxVelocity.x*4;
		setSize(18, 28);
		offset.set(7, 1);
		animation.play("idle");
	}

	private var walked:Bool = false;
	var canJump:Bool = true;

	override function update(elapsed:Float)
	{
		acceleration.x = 0;

		if(FlxG.keys.anyPressed([LEFT, A]))
		{
			if (isTouching(FlxObject.FLOOR))
				acceleration.x = -maxVelocity.x*4;
			else
				acceleration.x = -maxVelocity.x*2.5;
			facing = LEFT;
			if (!animation.curAnim.name.startsWith("jump") || ((animation.curAnim.name.startsWith("jump") && animation.curAnim.finished) || (animation.curAnim.name.startsWith("jump_land") && animation.curAnim.finished)) && !FlxG.keys.anyPressed([SPACE]))
				playerWalk();
		}
		if(FlxG.keys.anyPressed([RIGHT, D]))
		{
			if (isTouching(FlxObject.FLOOR))
				acceleration.x = maxVelocity.x*4;
			else
				acceleration.x = maxVelocity.x*2.5;
			facing = RIGHT;
			if (!animation.curAnim.name.startsWith("jump") || ((animation.curAnim.name.startsWith("jump") && animation.curAnim.finished) || (animation.curAnim.name.startsWith("jump_land") && animation.curAnim.finished)) && !FlxG.keys.anyPressed([SPACE]))
				playerWalk();
		}

		//Jump
		if ((animation.curAnim.name == 'jump_charge' && animation.curAnim.finished) || (animation.curAnim.name.startsWith("jump_land") && animation.curAnim.finished && FlxG.keys.anyPressed([SPACE])))
			velocity.y = -0.4 * maxVelocity.y;

		if(FlxG.keys.anyPressed([SPACE]) && isTouching(FlxObject.FLOOR) && canJump)
		{
			if (animation.curAnim.name != 'jump_charge' && !animation.curAnim.name.startsWith("jump_land") && canJump)
			{
				animation.play("jump_charge", false);
				//jumpsound
			}
			canJump = false;
			trace('player jump!');
			new FlxTimer().start(0.3, function(tmr:FlxTimer)
			{
				//if (!isTouching(FlxObject.FLOOR))
				//	tmr.reset(0.3);
				//else
					canJump = true;
			});
		}
		else if (isTouching(FlxObject.FLOOR) && !touchedFloorAgain)
		{
			if (velocity.y < maxVelocity.y * 0.6 || velocity.y > -maxVelocity.y * 0.6)
				animation.play("jump_land", false);
			else
			{
				animation.play("jump_landHARD", false);
				MinigameState.shakeCam = true;
			}
			touchedFloorAgain = true;
		}
		else if (!isTouching(FlxObject.FLOOR))
		{
			if (velocity.y < 0)
				animation.play("jump_midAir");
			else if (velocity.y > 0)
				animation.play("jump_falling");
			touchedFloorAgain = false;
		}

		if (animation.curAnim.finished && velocity.x == 0 && velocity.x == 0 && isTouching(FlxObject.FLOOR))
			animation.play("idle", true);

		super.update(elapsed);
	}

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
		//else if ((animation.curAnim.name.startsWith("walk") || animation.curAnim.curFrame == 1) && velocity.x != 0)
			//playwalksound
	}
}