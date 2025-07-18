package lore_minigames;

import flixel.system.FlxSound;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.util.FlxFSM;
import flixel.util.FlxTimer;

using StringTools;

enum PlayerActions
{
	IDLE;
	WALK;
	RUN;
	JUMP;
	SNEAK;
	SLIDE;
	CLIMB;
	NONE;
}

class Player extends FlxSprite
{
	public var GRAVITY:Float = 750;
	public var fsm:FlxFSM<Player>;
	public var chosenMoveset:String = 'default';//Making this changable so that we can add custom abilities in the future if ever
	public var queuedActions:Array<PlayerActions> = [];
	public var curAction:PlayerActions = IDLE;
	public var wasRunning:Bool = false;
	public var canMove:Bool = true;
	public var stamina:Float = 100;
	public var ranOutOfBreath:Bool = false;

	var walkSnd:FlxSound;

	public var defaultSpeedCaps:Array<Float> = [75, 150, 400]; //In Order: Sneaking, Walking, Running

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		pixelPerfectPosition = true;
		walkSnd = FlxG.sound.load('assets/minigame/sounds/walk' + FlxG.random.int(0, 5) + '.ogg', 0.5);
		
		loadGraphic("assets/minigame/images/guyPixel-Sheet.png", true, 64, 64);
		setFacingFlip(LEFT, true, false);
		setFacingFlip(RIGHT, false, false);
		facing = RIGHT;
		animation.add("idle", [0, 1, 2, 3, 4, 5], 12);
		//animation.add("jump", [0, 1, 2, 3, 4, 5], 12, false);
		animation.add("sneak", [6, 7, 8, 9], 16, false);
		animation.add("unsneak", [10, 11, 12], 14, false);
		animation.add("walk", [13, 14, 15, 16, 17, 18, 19, 20], 8);
		animation.add("run-mach1", [13, 14, 15, 16, 17, 18, 19, 20], 12);
		animation.play("idle");
		animation.finishCallback = (animName:String)->
		{
			switch (animName)
			{
				case "walk":
					walkSnd.play(true);
				case "unsneak":
					animation.play("idle");
			}
			/*if(animationName == "jump_land" || animationName == "jump_landHARD")
			{
				trace('WOOOOO');
				animation.play("idle");
			}*/
		};

		//health = 100;

		setSize(24, 50);
		offset.set(20, 8);

		acceleration.y = GRAVITY;
		maxVelocity.set(defaultSpeedCaps[1], GRAVITY);
		drag.set(maxVelocity.x * 2, 0);

		fsm = new FlxFSM(this);
		initializeFSM(chosenMoveset);
	}

	public var quickTimer:FlxTimer = new FlxTimer();
	public var quickTimeCaller:PlayerActions = NONE;
	public function startQuickTimer(timeInSecs:Float, ?onComplete:FlxTimer -> Void):Void
	{
		quickTimeCaller = curAction;
		if (onComplete != null)
			quickTimer.start(timeInSecs, onComplete);
		else
			quickTimer.start(timeInSecs);
	}

	public var frameTimeMult:Float = 1;
	public function updateFrameTimeMult(fromPlayState:Float):Void
	{
		frameTimeMult = fromPlayState;
	}


	/*override public function hurt(damage:Float):Void
	{
		if (damage <= health)
			health -= damage;
		else
			health = 0;
	}*/
	
	private function initializeFSM(moveset:String):Void
	{
		switch (moveset)
		{
			default:
				//                  From   To     Conditions
				//Note: Jump will NEVER turn to Fall, but fall can turn to Jump
				//Jump
				fsm.transitions.add(Idle, Jump, Conditions.startJump);
				fsm.transitions.add(Sneak, Jump, Conditions.startJump);
				fsm.transitions.add(Jump, Idle, Conditions.landFromAir);
				fsm.transitions.add(Jump, Sneak, Conditions.landFromAirSneaked);

				//Fall
				fsm.transitions.add(Idle, Falling, Conditions.startFall);
				fsm.transitions.add(Falling, Jump, Conditions.startJump);
				fsm.transitions.add(Falling, Idle, Conditions.landFromAir);

				//Sneak
				fsm.transitions.add(Idle, Sneak, Conditions.startSneak);
				fsm.transitions.add(Sneak, Idle, Conditions.endSneak);

				fsm.transitions.add(Idle, Slide, Conditions.startSlide);
				fsm.transitions.add(Slide, Idle, Conditions.endSlideNormal);
				fsm.transitions.add(Slide, Sneak, Conditions.endSlideSneaky);

				fsm.transitions.add(StillIdle, Idle, Conditions.exitStillIdle);
				fsm.transitions.add(Idle, StillIdle, Conditions.forceStillIdle);
				fsm.transitions.add(Falling, StillIdle, Conditions.forceStillIdle);
				fsm.transitions.add(Jump, StillIdle, Conditions.forceStillIdle);
				fsm.transitions.add(Sneak, StillIdle, Conditions.forceStillIdle);

				//HAVE NOT ADDED WALL CLUMB YET
		}
		fsm.transitions.start(Idle);
	}

	override function update(elapsed:Float):Void
	{
		fsm.update(elapsed);
		super.update(elapsed);

		//Stamina gains/drains
		if (canMove)
		{
			switch (curAction)
			{
				case RUN:
					stamina -= elapsed * 20;
				case SLIDE:
					if (stamina < 100)
						stamina += elapsed * 25;
				case IDLE:
					if (stamina < 100)
						stamina += elapsed * 20;
				case JUMP:
					if (stamina < 100)
						stamina += elapsed * 7.5;
				default:
					if (stamina < 100)
						stamina += elapsed * 10;
			}

			if (stamina <= 0)
			{
				stamina = 0;//make sure we don't overdrain the player
				ranOutOfBreath = true;
			}
			else if (ranOutOfBreath && stamina >= 25)
				ranOutOfBreath = false;
		}
		else
		{
			if (stamina < 100)
				stamina = 100;
		}

		if (!quickTimer.active && quickTimeCaller != NONE)
			quickTimeCaller = NONE;
	}

	override function destroy():Void
	{
		fsm.destroy();
		fsm = null;
		super.destroy();
	}
}

class Conditions
{
	public static function forceStillIdle(Player:Player):Bool
		{return !Player.canMove;}

	public static function exitStillIdle(Player:Player):Bool
		{return Player.canMove;}

	public static function startFall(Player:Player):Bool
		{return !Player.isTouching(FLOOR);}

	public static function startJump(Player:Player):Bool
		{return (Player.isTouching(FLOOR) && (FlxG.keys.justPressed.SPACE)) || Player.queuedActions.contains(JUMP);}

	public static function landFromAir(Player:Player):Bool
		{return Player.isTouching(FLOOR) && (!FlxG.keys.pressed.DOWN || (FlxG.keys.pressed.SHIFT && Player.wasRunning));}

	public static function landFromAirSneaked(Player:Player):Bool
		{return Player.isTouching(FLOOR) && FlxG.keys.pressed.DOWN && (!FlxG.keys.pressed.SHIFT || !Player.wasRunning);}

	public static function startSneak(Player:Player):Bool
		{return Player.isTouching(FLOOR) && ((FlxG.keys.justPressed.DOWN && Player.curAction != RUN) || Player.queuedActions.contains(SNEAK));}

	public static function endSneak(Player:Player):Bool
		{return Player.isTouching(FLOOR) && FlxG.keys.justReleased.DOWN;}

	public static function startSlide(Player:Player):Bool
		{return Player.isTouching(FLOOR) && FlxG.keys.justPressed.DOWN && Player.curAction == RUN;}

	public static function endSlideNormal(Player:Player):Bool
		{return Player.isTouching(FLOOR) && !FlxG.keys.pressed.DOWN && ((FlxG.keys.justReleased.SHIFT || FlxG.keys.justReleased.DOWN) || ((Player.facing == RIGHT && Player.velocity.x < 90) || (Player.facing == LEFT && Player.velocity.x > -90))) && Player.curAction == SLIDE;}

	public static function endSlideSneaky(Player:Player):Bool
		{return Player.isTouching(FLOOR) && FlxG.keys.pressed.DOWN && (FlxG.keys.justReleased.SHIFT || ((Player.facing == RIGHT && Player.velocity.x < 90) || (Player.facing == LEFT && Player.velocity.x > -90))) && Player.curAction == SLIDE;}

	//God i have not touched this script in so long LMFAO
	public static function startWallClimb(Player:Player):Bool
		{return !Player.isTouching(WALL) && FlxG.keys.pressed.SHIFT;}


}

class StillIdle extends FlxFSMState<Player>
{
	override function enter(owner:Player, fsm:FlxFSM<Player>):Void
	{
		trace('entered!');
		owner.maxVelocity.x = owner.defaultSpeedCaps[1];
		owner.drag.x = owner.maxVelocity.x * 2;
		owner.velocity.x = 0;
		owner.velocity.y = 0;
		owner.acceleration.x = 0;
		owner.acceleration.y = 0;
		owner.curAction = NONE;
		owner.animation.play("idle");
	}

	override function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void
	{
		//doNothin
	}

	override function exit(owner:Player) 
	{
		trace("EXITED!!!");
		owner.acceleration.y = owner.GRAVITY;
		super.exit(owner);
	}
}

class Idle extends FlxFSMState<Player>
{
	override function enter(owner:Player, fsm:FlxFSM<Player>):Void
	{
		if (owner.curAction != JUMP)
		{
			if (owner.curAction != SLIDE)
				owner.maxVelocity.x = owner.defaultSpeedCaps[1];
			owner.drag.x = owner.maxVelocity.x * 2;
		}
		owner.curAction = IDLE;
		if (owner.animation.curAnim.name != 'unsneak')
			owner.animation.play("idle");
	}

	override function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void
	{
		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT)
		{
			//Placeholder SND and anims
			if (FlxG.keys.pressed.SHIFT && !owner.ranOutOfBreath) //RUN
			{
				owner.animation.play("run-mach1");
				owner.animation.curAnim.frameRate = 12 + (owner.facing != LEFT ? owner.velocity.x/owner.maxVelocity.x : -owner.velocity.x/-owner.maxVelocity.x);
				owner.maxVelocity.x = owner.defaultSpeedCaps[2];
				owner.curAction = RUN;
				if (FlxG.keys.pressed.RIGHT)
				{
					owner.facing = RIGHT;
		
					//Flip player (2)
					if (owner.velocity.x < 0)
					{
						owner.acceleration.x = 10;
						owner.velocity.x *= -0.8;
					}
	
					if (owner.velocity.x < owner.maxVelocity.x * 0.5)
						owner.velocity.x = owner.maxVelocity.x * 0.5;
					if (owner.acceleration.x < owner.maxVelocity.x)
						owner.acceleration.x = CoolUtil.freyaLerp(owner.acceleration.x, owner.maxVelocity.x, 12, elapsed);
				}
				else
				{
					owner.facing = LEFT;
		
					//Flip player (1)
					if (owner.velocity.x > 0)
					{
						owner.acceleration.x = -10;
						owner.velocity.x *= -0.8;
					}
	
					if (owner.velocity.x > -owner.maxVelocity.x * 0.5 )
						owner.velocity.x = -owner.maxVelocity.x * 0.5;
					if (owner.acceleration.x > -owner.maxVelocity.x)
						owner.acceleration.x = CoolUtil.freyaLerp(owner.acceleration.x, -owner.maxVelocity.x, 12, elapsed);
				}
			}
			else //WALK
			{
				owner.animation.play("walk");
				owner.animation.curAnim.frameRate = 8 + owner.velocity.x / (owner.facing != LEFT ? owner.maxVelocity.x : -owner.maxVelocity.x);
				owner.maxVelocity.x = owner.defaultSpeedCaps[1];
				owner.curAction = WALK;
				if (FlxG.keys.pressed.RIGHT)
				{
					owner.facing = RIGHT;
		
					//Flip player (2)
					if (owner.velocity.x < 0)
						owner.velocity.x *= -0.75;
	
					if (owner.velocity.x < owner.maxVelocity.x / 2)
						owner.velocity.x = owner.maxVelocity.x / 2;
					owner.acceleration.x = owner.maxVelocity.x * 2;
				}
				else
				{
					owner.facing = LEFT;
		
					//Flip player (1)
					if (owner.velocity.x > 0)
						owner.velocity.x *= -0.75;

					if (owner.velocity.x > -owner.maxVelocity.x / 2)
						owner.velocity.x = -owner.maxVelocity.x / 2;
					owner.acceleration.x = -owner.maxVelocity.x * 2;
				}
			}
		}
		
		if (FlxG.keys.justReleased.LEFT || FlxG.keys.justReleased.RIGHT)
		{
			owner.acceleration.x = 0;
			owner.curAction = IDLE;
			owner.animation.curAnim.frameRate = 12;
			owner.animation.play("idle");
			owner.velocity.x *= 0.1;
		}
	}

	override function exit(owner:Player) 
	{
		//walkSnd.stop();
		super.exit(owner);
	}
}

class Jump extends FlxFSMState<Player>
{
	var jumpBuffer:FlxTimer;
	var jumpHoldTimer:FlxTimer;

	override function enter(owner:Player, fsm:FlxFSM<Player>):Void
	{
		if (owner.queuedActions.contains(JUMP))
			owner.queuedActions.remove(JUMP);

		if (owner.curAction != RUN && (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT))
			owner.velocity.x += (owner.facing == RIGHT ? 100 : -100);

		if (owner.curAction != SNEAK || !owner.quickTimer.active)
			owner.velocity.y = -250;
		else
		{
			owner.velocity.y = -400;
			owner.stamina -= 10;
		}

		if (owner.curAction == RUN)
			owner.wasRunning = true;
		
		owner.curAction = JUMP;
		FlxG.sound.play('assets/minigame/sounds/jump' + FlxG.random.int(0, 5) + '.ogg', 0.75);

		jumpHoldTimer = new FlxTimer().start(0.14);
		//owner.animation.play("jumping");
	}

	override function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void
	{
		//owner.acceleration.x = 0;
		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT)
		{
			owner.acceleration.x += (FlxG.keys.pressed.LEFT ? -50 : 50) * owner.frameTimeMult;
			owner.facing = FlxG.keys.pressed.RIGHT ? RIGHT : LEFT;
			if (FlxG.keys.pressed.RIGHT)
			{
				if (owner.velocity.x < 0)
					owner.velocity.x *= -0.5;
			}
			if (FlxG.keys.pressed.LEFT)
			{
				if (owner.velocity.x > 0)
					owner.velocity.x *= -0.5;
			}
		}

		//Maybe this will stop the floatyt as fuck controls?
		if (FlxG.keys.justReleased.LEFT || FlxG.keys.justReleased.RIGHT)
		{
			owner.acceleration.x *= 0.5;
			owner.velocity.x *= 0.5;
		}

		//Jump cutting
		if(FlxG.keys.justReleased.SPACE && owner.velocity.y < 0)
			owner.velocity.y *= 0.35;

		//Jump Hold
		if (!jumpHoldTimer.active)
		{
			if (FlxG.keys.pressed.SPACE && owner.velocity.y < -5)
			{
				//This is FPS dependent and that's BAD
				owner.velocity.y -= 1.25 * owner.frameTimeMult; //big bnuberes jsncbdnbjf
				if (owner.maxVelocity.y != owner.GRAVITY * 0.4)
				{
					trace('FORCED FLOATY');
					owner.maxVelocity.y = owner.GRAVITY * 0.4;
				}
			}
			else if (owner.velocity.y > 0)
			{
				//trace('downElapsed: ' + elapsed);
				owner.velocity.y += 3 + (2 * (FlxG.keys.pressed.DOWN ? 1 : 0)) * owner.frameTimeMult; //big bnubmer bcuz yes
				if (owner.maxVelocity.y != owner.GRAVITY * 2)
				{
					trace('FORCED DOWN');
					owner.maxVelocity.y = owner.GRAVITY * 2;
				}
			}
		}

		if (FlxG.keys.justReleased.LEFT || FlxG.keys.justReleased.RIGHT)
		{
			trace('stopHoriViaRelease');
			owner.acceleration.x = 0.25;
			owner.velocity.x *= 0.5;
		}

		if(FlxG.keys.justPressed.SPACE)
		{
			//trace('started jump buffer');
			if (jumpBuffer != null)
				jumpBuffer.cancel();
			if (!owner.queuedActions.contains(JUMP))
				owner.queuedActions.push(JUMP);
			jumpBuffer = new FlxTimer().start(0.16666666666, function(tmr:FlxTimer){jumpBuffer = null; if(owner.queuedActions.contains(JUMP)) owner.queuedActions.remove(JUMP); trace('removed jmpbfr');});
		}
	}

	override function exit(owner:Player) 
	{
		jumpHoldTimer.cancel();
		owner.maxVelocity.y = owner.GRAVITY;
		if (!FlxG.keys.pressed.LEFT && !FlxG.keys.pressed.RIGHT)
		{
			owner.acceleration.x = 0;
			owner.velocity.x *= 0.1;
			trace('jumpvelocitystop');
		}
		//jump land animation here?
		//walkSnd.stop();
		super.exit(owner);
	}
}

class Sneak extends FlxFSMState<Player>
{
	override function enter(owner:Player, fsm:FlxFSM<Player>):Void
	{
		if (owner.queuedActions.contains(SNEAK))
			owner.queuedActions.remove(SNEAK);

		owner.maxVelocity.x = owner.defaultSpeedCaps[0];
		owner.drag.x = owner.defaultSpeedCaps[1] * 2;
		owner.curAction = SNEAK;
		owner.startQuickTimer(0.16666666666666666);
		owner.animation.play("sneak");
	}

	override function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void
	{
		owner.acceleration.x = 0;
		if (FlxG.keys.pressed.RIGHT)
		{
			if (owner.velocity.x < 0)
				owner.velocity.x *= -0.5;

			if (owner.velocity.x < owner.maxVelocity.x * 0.35 )
				owner.velocity.x = owner.maxVelocity.x * 0.35;

			owner.facing = RIGHT;
			owner.acceleration.x = 100;
		}
		else if (FlxG.keys.pressed.LEFT)
		{
			if (owner.velocity.x > 0)
				owner.velocity.x *= -0.5;

			if (owner.velocity.x > -owner.maxVelocity.x * 0.35 )
				owner.velocity.x = -owner.maxVelocity.x * 0.35;

			owner.facing = LEFT;
			owner.acceleration.x = -100;
		}

		if (FlxG.keys.justReleased.LEFT || FlxG.keys.justReleased.RIGHT)
		{
			owner.acceleration.x = 0;
			owner.velocity.x *= 0.5;
		}
	}

	override function exit(owner:Player) 
	{
		owner.animation.play("unsneak");
		super.exit(owner);
	}
}

class Slide extends FlxFSMState<Player>
{
	var oneShot:Bool = false;
	var slowTmr:FlxTimer;

	override function enter(owner:Player, fsm:FlxFSM<Player>):Void
	{
		owner.curAction = SLIDE;
		owner.animation.play("sneak");
		owner.stamina -= 10;
		owner.drag *= 0.2;
		slowTmr = new FlxTimer().start(0.2, function(tmr:FlxTimer){owner.drag.x = 400; trace ('player slowed'); owner.stamina -= 10;});
	}

	override function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void
	{
		if (FlxG.keys.justPressed.DOWN && !owner.queuedActions.contains(SNEAK))
			owner.queuedActions.push(SNEAK);
		else if (FlxG.keys.justReleased.DOWN && owner.queuedActions.contains(SNEAK))
			owner.queuedActions.remove(SNEAK);

		switch(owner.facing)
		{
			case RIGHT:
				if (!oneShot)
				{
					owner.velocity.x = owner.maxVelocity.x;
					owner.acceleration.x += 80 * owner.frameTimeMult;
					oneShot = true;
				}

				if (owner.velocity.x > 0)
				{
					if (FlxG.keys.justPressed.RIGHT)
						owner.acceleration.x += -5 * owner.frameTimeMult;
					else
						owner.acceleration.x = 0;
				}

			case LEFT:
				if (!oneShot)
				{
					owner.velocity.x = -owner.maxVelocity.x;
					owner.acceleration.x -= 80 * owner.frameTimeMult;
					oneShot = true;
				}
					
				if (owner.velocity.x < 0)
				{
					if (FlxG.keys.justPressed.RIGHT)
						owner.acceleration.x += 5 * owner.frameTimeMult;
					else
						owner.acceleration.x = 0;
				}

			default:
				//do nothing lmao
		}
	}

	override function exit(owner:Player) 
	{
		if (slowTmr != null && slowTmr.active)
		{
			slowTmr.cancel();
			if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT)
				owner.velocity.x += (owner.facing == RIGHT ? 100 : -100);
			owner.stamina += 5;
		}
		else
			owner.acceleration.x = 0;
		//unslide animation here
		super.exit(owner);
	}
}

class Falling extends FlxFSMState<Player>
{
	var coyoteTime:FlxTimer;

	override function enter(owner:Player, fsm:FlxFSM<Player>):Void
	{
		//maybe this serves as both coyote and jumpbuffer
		//nuh uh
		//nonono!
		//n a h~
		coyoteTime = new FlxTimer().start(0.08333333333333333); //5 frames (in 60 fps) lol
		//Falling anim and state maybe?
	}

	override function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void
	{
		if (FlxG.keys.justPressed.SPACE && coyoteTime.active && !owner.queuedActions.contains(JUMP))
		{
			owner.queuedActions.push(JUMP);
		}

		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT)
		{
			owner.acceleration.x += (FlxG.keys.pressed.LEFT ? -50 : 50) * owner.frameTimeMult;
			owner.facing = FlxG.keys.pressed.RIGHT ? RIGHT : LEFT;
			if (FlxG.keys.pressed.RIGHT)
			{
				if (owner.velocity.x < 0)
					owner.velocity.x *= -0.5 * owner.frameTimeMult;
			}
			if (FlxG.keys.pressed.LEFT)
			{
				if (owner.velocity.x > 0)
					owner.velocity.x *= -0.5 * owner.frameTimeMult;
			}
		}
	}

	override function exit(owner:Player) 
	{
		super.exit(owner);
	}
}