package lore_minigames;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import flixel.util.FlxDirectionFlags;

using StringTools;

//I DISCOVERED HOW ENUMS WORK IM GONNA OVERUSE THEM NOW !!!!! MUAHAHAHAHHAA >:3>
enum AnimType
{
	NORMAL;
	SCARED;
	PANICKED;
	ANGRY;
}

enum MovementState
{
	IDLE;
	WALKING;
	RUNNING;
	STOPPING;
	SNEAKING;
	FALLING;
	DASHING;
	NONE;
}

enum MovementDirections
{
	LEFT;
	RIGHT;
	UP;
	DOWN;
}

class Player extends FlxSprite
{
	public var canMove:Bool = true;
	public var status:MovementState = IDLE;
	var heldStatus:MovementState = NONE;
	var animType:AnimType = NORMAL;
	var defaultSpeedCaps:Array<Float> = [65, 100, 300]; //In Order: Sneaking, Walking, Running, Dashing
	public var forceSneak:Bool = false; //Bool to force the player to sneak
	var isOnFloor:Bool = true;
	var initialised:Bool = false;

	//Redoing The Char Movement From Scratch
	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		loadGraphic('assets/minigame/images/player.png', true, 32, 32);
		//ANY, CEILING, DOWN, FLOOR, LEFT, NONE, RIGHT, UP, WALL
		setFacingFlip(LEFT, true, false);
		setFacingFlip(RIGHT, false, false);
		animation.add("idle", [2, 2, 1, 0, 0, 1], 6, true);
		animation.add("idle_static", [2], 1, false);
		animation.add("walkLEFT", [3, 4], 3, false);
		animation.add("walkRIGHT", [5, 6], 3, false);
		animation.add("runMach1", [3, 3, 4, 4], 10, false);
		animation.add("runMach2", [5, 6, 7], 10, false);
		animation.add("jump_full", [7, 8, 10], 48, false);
		animation.add("jump_start", [7, 8], 13, false);
		animation.add("jump_hold", [9, 8], 15, true);
		animation.add("jump_midAir", [10], 1, true);
		animation.add("jump_falling", [11], 1, false);
		animation.add("jump_land", [13, 0, 1, 2], 16, false);
		animation.add("jump_landHARD", [12, 12, 13, 0, 1, 1, 2], 17, false);
		setSize(18, 28);
		offset.set(7, 2);
		y -= 7;
		acceleration.y = 620; //Gravity
		maxVelocity.set(defaultSpeedCaps[1], 1000);
		drag.set(maxVelocity.x * 2, maxVelocity.y * 2);
		animation.play("idle");

		new FlxTimer().start(0.25, function(tmr:FlxTimer)
		{
			initialised = true;
		});
		
		//Finish Callbacks per animation
		animation.finishCallback = (animationName:String)->
		{
			if(animationName == "jump_land" || animationName == "jump_landHARD")
			{
				trace('WOOOOO');
				animation.play("idle");
			}
		};
	}

	var walkBool:Bool = false;
	function move(direction:MovementDirections, triggerSneak:Bool)
	{
		if (!triggerSneak)
		{
			status = WALKING;
			maxVelocity.x = defaultSpeedCaps[1];
		}
		else
		{
			status = SNEAKING;
			maxVelocity.x = defaultSpeedCaps[0];
		}
		switch(direction)
		{
			case LEFT:
				facing = LEFT;

				if (velocity.x > 0)
					velocity.x *= -0.75;

				if (velocity.x > -maxVelocity.x / 2)
					velocity.x = -maxVelocity.x / 2;
				acceleration.x = -maxVelocity.x * 2;


			case RIGHT:
				facing = RIGHT;

				if (velocity.x < 0)
					velocity.x *= -0.75;

				if (velocity.x < maxVelocity.x / 2)
					velocity.x = maxVelocity.x / 2;
				acceleration.x = maxVelocity.x * 2;


			default:
				//do nada
		}

		//Walking anim here - fps of animj dependent on playerspeed
		if ((animation.curAnim.name == 'idle' || animation.curAnim.finished) && !isTouching(WALL))
		{
			trace('walking ' + direction);

			walkBool = !walkBool;
			if (isTouching(FLOOR))
			{
				switch (status)
				{
					case WALKING:
						if (!walkBool)
							animation.play("walkLEFT");
						else
							animation.play("walkRIGHT");
						animation.curAnim.frameRate = 3 + velocity.x / (facing != LEFT ? maxVelocity.x : -maxVelocity.x);
			
						//WalkSound
						FlxG.sound.play('assets/minigame/sounds/walk' + FlxG.random.int(0, 5) + '.ogg', 0.5);

					case SNEAKING:
						if (!walkBool)
							animation.play("walkLEFT");
						else
							animation.play("walkRIGHT");
						animation.curAnim.frameRate = 1.5 + velocity.x / (facing != LEFT ? maxVelocity.x : -maxVelocity.x);
					
						default:
							//do nada
				}
			}
		}	
	}

	function run(direction:MovementDirections)
	{
		maxVelocity.x = defaultSpeedCaps[2];
		status = RUNNING;
		switch(direction)
		{
			case LEFT:
				facing = LEFT;

				//if we were going right a moment ago, do this
				if (velocity.x > 0)
					velocity.x *= -0.5;
				
				if (velocity.x > -defaultSpeedCaps[1] * 1.25)
					velocity.x = -defaultSpeedCaps[1] * 1.25;

				if (acceleration.x > 0)
					acceleration.x = -defaultSpeedCaps[1] * 1.5;
				else
					acceleration.x -= 0.25;

			case RIGHT:
				facing = RIGHT;

				//if we were going left a moment ago, do this
				if (velocity.x < 0)
					velocity.x *= -0.25;
				
				if (velocity.x < defaultSpeedCaps[1] * 1.25)
					velocity.x = defaultSpeedCaps[1] * 1.25;

				if (acceleration.x < 0)
					acceleration.x = defaultSpeedCaps[1] * 1.5;
				else
					acceleration.x += 0.25;

			default:
				//do nada
		}

		//Running anim here - fps of animj dependent on playerspeed
		if ((animation.curAnim.name == 'idle' || animation.curAnim.finished) || animation.curAnim.name.startsWith('walk'))
		{
			trace('running ' + direction);

			if ((velocity.x < 250 && facing == RIGHT) || (velocity.x > -200 && facing == LEFT))
				animation.play("runMach1");
			else
				animation.play("runMach2");

			//RunSoundPlaceholder
			FlxG.sound.play('assets/minigame/sounds/walk' + FlxG.random.int(0, 5) + '.ogg', 0.75);
		}

		animation.curAnim.frameRate = 10 + velocity.x / (facing != LEFT ? maxVelocity.x : -maxVelocity.x);
		trace('accel: ' + acceleration.x + ' | framRat: ' + animation.curAnim.frameRate);
	}

	var jumpHoldTimer:FlxTimer;
	function jump(justJumped:Bool)
	{
		if (justJumped)
		{
			if (isTouching(FLOOR))
			{
				if (jumpBuffered)
				{
					trace('JUMP BUFFERING WORKING!!!!!');
					if (jumpBuffTmr != null)
						jumpBuffTmr.cancel();
					jumpBuffered = false;
				}
				//Placeholder
				animation.play("jump_full");
				FlxG.sound.play('assets/minigame/sounds/jump' + FlxG.random.int(0, 5) + '.ogg', 0.75);
				velocity.y -= 150;

				if (jumpHoldTimer != null)
					jumpHoldTimer.cancel();
				jumpHoldTimer = new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						jumpHoldTimer = null;
					});
			}
			else if (!jumpBuffered)
			{
				trace('le buff e r');
				//Jump Buffer
				jumpBuffered = true;
				if (jumpBuffTmr != null)
					jumpBuffTmr.cancel();
				jumpBuffTmr = new FlxTimer().start(0.15, function(tmr:FlxTimer)
					{
						jumpBuffered = false;
						jumpBuffTmr = null;
					});
			}
		}
		else
		{
			//Jump holding
			if (jumpHoldTimer != null)
			{
				var funnyJumpExtend:Float = 0;
				funnyJumpExtend = -2 + (0.05 * (jumpHoldTimer.elapsedTime / 1000));
				velocity.y += funnyJumpExtend;
			}
		}
	}

	var stoppinTimer:FlxTimer;

	public function stopAction(?stopActAnim:String = '', stopVelocity:Bool= false, stopAcceleration:Bool = true)
	{
		//don't try to stop an action if nothing is happening anyways
		if (status != IDLE || status != STOPPING)
		{
			switch (stopActAnim)
			{
				case 'stop-run':
					trace('stopping run');
					status = STOPPING;
					drag.x = maxVelocity.x / 2;
					//Placeholder
					animation.play("jump_LandHARD");
					FlxG.sound.play('assets/minigame/sounds/jump' + FlxG.random.int(0, 5) + '.ogg', 0.75);
					stoppinTimer = new FlxTimer().start(0.3, function(tmr:FlxTimer)
					{
						trace('stoppedslinding');
						status = IDLE;
						animation.play("idle");
						drag.x = maxVelocity.x * 2;
						forceSneak = false;
					});
				default:
					trace('set to idle');
					status = IDLE;
					animation.play("idle");
					forceSneak = false;
			}
			if (stopVelocity)
				velocity.x = 0;
			if (stopAcceleration)
				acceleration.x = 0;

			maxVelocity.set(defaultSpeedCaps[1], 1000);
		}
	}

	public function primeForEscSeq()
	{
		animType = PANICKED;
		trace('hit the SLAY button!');
	}

	var jumpBuffered:Bool = false;
	var jumpBuffTmr:FlxTimer;

	override function update(elapsed:Float)
	{
		if (canMove)
		{
			if (isTouching(FLOOR))
			{
				if (!isOnFloor)
				{
					//Land the jump
					isOnFloor = true;
					if (jumpHoldTimer != null)
						jumpHoldTimer.cancel();
					//Placeholder
					FlxG.sound.play('assets/minigame/sounds/land-PLACEHOLDER.ogg', 0.5, false);
					animation.play("jump_land");
				}
			}
			else if (initialised)
			{
				if (velocity.y != 0)
				{
					isOnFloor = false;
					trace('not on floor');
					//PlaceholderAnims
					if (animation.curAnim.name == 'jump_full' && animation.curAnim.finished)
					{
						if (velocity.y < 0 && animation.curAnim.name != "jump_midAir")
							animation.play("jump_midAir");
						else if (velocity.y > 0 && animation.curAnim.name != "jump_falling")
							animation.play("jump_falling");
					}
				}
			}

			//placeholder
			if (FlxG.keys.pressed.SHIFT)
				alpha = 0.75;
			else if (alpha != 1)
				alpha = 1;

			//Priority on sneaking rather than running
			if ((!FlxG.keys.pressed.CONTROL || FlxG.keys.pressed.SHIFT) && status != RUNNING && status != STOPPING)
			{
				//Priority depends on which direction player needs to go
				if (animType == NORMAL)
				{
					if (FlxG.keys.pressed.RIGHT)
						move(RIGHT, FlxG.keys.pressed.SHIFT);
					else if (FlxG.keys.pressed.LEFT)
						move(LEFT, FlxG.keys.pressed.SHIFT);
				}
				else
				{
					if (FlxG.keys.pressed.RIGHT)
						move(RIGHT, FlxG.keys.pressed.SHIFT);
					else if (FlxG.keys.pressed.LEFT)
						move(LEFT, FlxG.keys.pressed.SHIFT);
				}
			
				if (FlxG.keys.anyJustReleased([LEFT, RIGHT]))
					stopAction(true);
			}
			else
			{
				if (status != STOPPING)
				{
					if (FlxG.keys.pressed.RIGHT)
						run(RIGHT);
					else if (FlxG.keys.pressed.LEFT)
						run(LEFT);

					if (FlxG.keys.justReleased.CONTROL || ((FlxG.keys.justReleased.LEFT && FlxG.keys.pressed.RIGHT) && (FlxG.keys.justReleased.RIGHT && FlxG.keys.pressed.LEFT)) || FlxG.keys.justPressed.SHIFT)
						stopAction('stop-run');
				}
				else
				{
					if (FlxG.keys.pressed.SHIFT && !forceSneak)
					{
						if (stoppinTimer != null && stoppinTimer.active)
						{
							forceSneak = true;
							if ((facing == RIGHT && FlxG.keys.pressed.LEFT) || (facing == LEFT && FlxG.keys.pressed.RIGHT))
								drag.x = maxVelocity.x * 4;
							//Placeholder
							FlxG.sound.play(Paths.sound('cancelMenu'), 0.25, false);
							animation.play("jump_midAir");
						}
					}
				}
			}

			/*if (FlxG.keys.justPressed.X)
			{}*/

			//Checks if jump is pressed so that you can end jumps early by letting go early
			//This is so messy LMAO
			if (FlxG.keys.justPressed.SPACE || jumpBuffered)
				jump(true);
			else if (FlxG.keys.pressed.SPACE)
				jump(false);

			if (FlxG.keys.justReleased.SPACE)
				if (jumpHoldTimer != null)
					jumpHoldTimer.cancel();
		}

		super.update(elapsed);
	}
}