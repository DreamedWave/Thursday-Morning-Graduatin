package lore_minigames;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;

using StringTools;

class Player extends FlxSprite
{
	public var isPanicked:Bool = false;
	public var isSneaking:Bool = false;
	
	var touchedFloorAgain:Bool = true;
	public var defaultMaxVelocityX:Float = 110;
	public var defaultMaxVelocityY:Float = 1000;

	//Fix the moement so that the player is sneaking by default. you can run but it makes you make noise
	//this flips where you need to whoosh past the clatterers in the escape seq
	//Dopne!

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
		acceleration.y = 800;
		drag.x = maxVelocity.x * 8.5;
		setSize(18, 28);
		offset.set(7, 2);
		y -= 7;
		animation.play("idle");
	}

	public var canMove:Bool = true;
	private var walked:Bool = false;
	var inTerminalVelocity:Bool = false;
	var canSlide:Bool = true;
	var slideTimer:FlxTimer;
	var resetTimer:FlxTimer;

	override function update(elapsed:Float)
	{
		if (canMove)
		{
			if(FlxG.keys.pressed.RIGHT)
			{
				facing = RIGHT;
				//Normal walking sneaking state
				if (!isPanicked)
				{
					//Flips velocity for instaturns
					if (velocity.x < 0)
						velocity.x *= -1;
					//So that the movement doesnt feel heavy
					else if (velocity.x == 0)
						velocity.x = maxVelocity.x / 0.75;

					acceleration.x = maxVelocity.x * 3;
				}
				else 
				{
					//Escape sequence running state
					if (!isSneaking)
					{
						//Flips velocity for instaturns
						if (velocity.x < 0)
							velocity.x *= -1;

						//So that the movement doesnt feel heavy
						else if (velocity.x == 0)
							velocity.x = maxVelocity.x / 0.5;


						acceleration.x = maxVelocity.x * 4;
					}
					//Moving while still slidings
					else
					{
						//Slide Cancel when you're not pressin shift
						if (facing == LEFT && !FlxG.keys.pressed.SHIFT)
							stopSliding();

						if (velocity.x < 20)
							velocity.x += 20;
						
					}
				}

				//Anims
				if (!animation.curAnim.name.startsWith("jump") || ((animation.curAnim.name.startsWith("jump") && animation.curAnim.finished)))
					playerWalk(); //change this to animatePlayer(action)
			}
			else if (FlxG.keys.justReleased.RIGHT)
				acceleration.x = 0; //so that u dont keep sliding forever
			
			if (FlxG.keys.pressed.LEFT)
			{
				facing = LEFT;
				//Normal walking sneaking state
				if (!isPanicked)
				{
					//Flips velocity for instaturns
					if (velocity.x > 0)
						velocity.x *= -1;
					//So that the movement doesnt feel heavy
					else if (velocity.x == 0)
						velocity.x = -maxVelocity.x / 0.75;

					acceleration.x = -maxVelocity.x * 3;
				}
				else 
				{
					//Escape sequence running state
					if (!isSneaking)
					{
						//Flips velocity for instaturns
						if (velocity.x > 0)
							velocity.x *= -1;

						//So that the movement doesnt feel heavy
						else if (velocity.x == 0)
							velocity.x = -maxVelocity.x / 0.5;


						acceleration.x = -maxVelocity.x * 4;
					}
					//Moving while still slidings
					else
					{
						//Slide Cancel when you're not pressin shift
						if (facing == RIGHT && !FlxG.keys.pressed.SHIFT)
							stopSliding();

						if (velocity.x > -20)
							velocity.x += -20;
						
					}
				}

				//Anims
				if (!animation.curAnim.name.startsWith("jump") || ((animation.curAnim.name.startsWith("jump") && animation.curAnim.finished)))
					playerWalk(); //change this to animatePlayer(action)
			}
			else if (FlxG.keys.justReleased.LEFT)
				acceleration.x = 0; //so that u dont keep sliding forever

			if (FlxG.keys.justPressed.SHIFT) //Running
			{
				isSneaking = true;
				if (!isPanicked)
				{
					//bro imma make an anim for this trust me
					//Also animation system idea: use prefixes
					//so rather than using set anims like 'idle', 'walk', 'run', etc - do like 'idle-sneaking', 'walk-sneaking', etc!!!
					alpha = 0.65;
					maxVelocity.x = 80;
				}
				else //Sliding
				{
					if (resetTimer == null && canSlide)
					{
						canSlide = false;
						//bro imma make an anim for this trust me
						//Also animation system idea: use prefixes
						//so rather than using set anims like 'idle', 'walk', 'run', etc - do like 'idle-sneaking', 'walk-sneaking', etc!!!
						alpha = 0.65;
						//Sliding
						maxVelocity.x = defaultMaxVelocityX * 2.25;
						drag.x = 0;
						
						maxVelocity.x += 60;
						if (facing == LEFT)
						{
							velocity.x += -maxVelocity.x;
							acceleration.x = -maxVelocity.x * 5; //Speed boost Left
						}
						else
						{
							velocity.x += maxVelocity.x;
							acceleration.x = maxVelocity.x * 5; //Speed boost Right
						}
						FlxG.sound.play('assets/minigame/sounds/jump' + FlxG.random.int(0, 5) + '.ogg', 0.7);

						if (slideTimer != null)
							slideTimer.cancel();
						slideTimer = new FlxTimer().start(0.25, function(tmr:FlxTimer)
						{
							acceleration.x = 0;
							drag.x = maxVelocity.x * 2.5;
							slideTimer = null;
						});
					}
				}
			}
			else if (FlxG.keys.justReleased.SHIFT)//Stop Sneaking
			{	
				if (!isPanicked)
				{
					maxVelocity.x = defaultMaxVelocityX;
					isSneaking = false;
					alpha = 1;
				}
				else
				{
					if (isPanicked && resetTimer == null && !canSlide) //Stop sliding
					{
						resetTimer = new FlxTimer().start(0.25, function(tmr:FlxTimer)
						{
							stopSliding();
						});
					}
				}
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
					MinigameState.camShake(true, false, 0.02, 0.025);
					//FlxG.sound.play('assets/minigame/sounds/landHard' + FlxG.random.int(0, 5) + '.ogg', 0.8);
					FlxG.sound.play('assets/minigame/sounds/walk' + FlxG.random.int(0, 5) + '.ogg', 0.7);
					inTerminalVelocity = false;
				}
				touchedFloorAgain = true;
			}
			else if (!isTouching(FLOOR) && velocity.y != 0)
			{
				if (velocity.y > 415)
					inTerminalVelocity = true;
				if (velocity.y < 0)
					animation.play("jump_midAir");
				else if (velocity.y > 0)
					animation.play("jump_falling");
				touchedFloorAgain = false;
			}

			if (animation.curAnim.name != 'idle' && (animation.curAnim.finished || animation.curAnim.name.startsWith("walk")) && velocity.x == 0 && isTouching(FLOOR) && !FlxG.keys.anyPressed([A, S, W, D, SPACE]))
				animation.play("idle", true);
		}
		else
		{
			if (acceleration.x != 0)
				acceleration.x = 0;
			if (velocity.x != 0)
				velocity.x = 0;
		}


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
			playWalkSound = false;
	}

	function stopSliding()
	{
		maxVelocity.x = defaultMaxVelocityX;
		drag.x = defaultMaxVelocityX * 8.5;
		velocity *= 0.25;
		canSlide = true;
		isSneaking = false;
		if (resetTimer != null)
			resetTimer.cancel();
		resetTimer = null;
		alpha = 1;
	}

	public function doEscSeqChecks() //makes sure everything is set for the esc seq
	{
		isPanicked = true;
		defaultMaxVelocityX = 160;
		color = 0xFFFF0000;
	}
}