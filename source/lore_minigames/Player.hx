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
	NONE;
}

class Player extends FlxSprite
{
	public static inline var GRAVITY:Float = 600;
	public var fsm:FlxFSM<Player>;
	public var chosenMoveset:String = 'default';//Making this changable so that we can add custom abilities in the future if ever
	public var queuedActions:Array<PlayerActions> = [];
	public var curAction:PlayerActions = IDLE;
	public var canMove:Bool = true;
	public var stamina:Float = 100;
	public var ranOutOfBreath:Bool = false;

	public var defaultSpeedCaps:Array<Float> = [65, 100, 300]; //In Order: Sneaking, Walking, Running

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
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
				case "unsneak":
					animation.play("idle");
			}
			/*if(animationName == "jump_land" || animationName == "jump_landHARD")
			{
				trace('WOOOOO');
				animation.play("idle");
			}*/
		};

		health = 100;

		setSize(32, 61);
		offset.set(16, -3);

		acceleration.y = GRAVITY;
		maxVelocity.set(defaultSpeedCaps[1], GRAVITY);
		drag.set(maxVelocity.x * 2, 0);

		fsm = new FlxFSM(this);
		initializeFSM(chosenMoveset);
	}

	override public function hurt(damage:Float):Void
	{
		if (damage <= health)
			health -= damage;
		else
			health = 0;
	}
	
	private function initializeFSM(moveset:String):Void
	{
		switch (moveset)
		{
			default:
				//                  From   To     Conditions
				fsm.transitions.add(Idle, Jump, Conditions.startJump);
				fsm.transitions.add(Jump, Idle, Conditions.landFromAir);

				fsm.transitions.add(Idle, Falling, Conditions.startFall);
				fsm.transitions.add(Falling, Jump, Conditions.startJump);
				fsm.transitions.add(Falling, Idle, Conditions.landFromAir);

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
		{return Player.isTouching(FLOOR) && ((FlxG.keys.justPressed.SPACE) || Player.queuedActions.contains(JUMP));}

	public static function landFromAir(Player:Player):Bool
		{return Player.isTouching(FLOOR);}

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

	public static function animationFinished(Player:Player):Bool
		{return Player.animation.finished;}
}

class StillIdle extends FlxFSMState<Player>
{
	override function enter(owner:Player, fsm:FlxFSM<Player>):Void
	{
		trace('entered!');
		owner.maxVelocity.x = owner.defaultSpeedCaps[1];
		owner.drag.x = owner.maxVelocity.x * 2;
		owner.velocity.x = 0;
		owner.acceleration.x = 0;
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
		super.exit(owner);
	}
}

class Idle extends FlxFSMState<Player>
{
	var walkSnd:FlxSound;

	override function enter(owner:Player, fsm:FlxFSM<Player>):Void
	{
		if (owner.curAction != JUMP)
		{
			owner.maxVelocity.x = owner.defaultSpeedCaps[1];
			owner.drag.x = owner.maxVelocity.x * 2;
		}
		walkSnd = FlxG.sound.load('assets/minigame/sounds/walk' + FlxG.random.int(0, 5) + '.ogg', 0.5);
		owner.curAction = IDLE;
		if (owner.animation.curAnim.name != 'unsneak')
			owner.animation.play("idle");
	}

	override function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void
	{
		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT)
		{
			//Placeholder SND and anims
			walkSnd.play();
			
			if (FlxG.keys.pressed.SHIFT && !owner.ranOutOfBreath) //RUN
			{
				owner.animation.play("run-mach1");
				owner.animation.curAnim.frameRate = 12 + owner.velocity.x / (owner.facing != LEFT ? owner.maxVelocity.x : -owner.maxVelocity.x);
				owner.maxVelocity.x = owner.defaultSpeedCaps[2];
				owner.curAction = RUN;
				if (FlxG.keys.pressed.RIGHT)
				{
					owner.facing = RIGHT;
		
					//Flip player (2)
					if (owner.velocity.x < 0)
						owner.velocity.x *= -0.8;
	
					if (owner.velocity.x < owner.maxVelocity.x / 1.8)
						owner.velocity.x = owner.maxVelocity.x / 1.8;
					owner.acceleration.x = owner.maxVelocity.x * 0.85;
				}
				else
				{
					owner.facing = LEFT;
		
					//Flip player (1)
					if (owner.velocity.x > 0)
						owner.velocity.x *= -0.8;
	
					if (owner.velocity.x > -owner.maxVelocity.x / 1.8)
						owner.velocity.x = -owner.maxVelocity.x / 1.8;
					owner.acceleration.x = -owner.maxVelocity.x * 0.85;
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

	override function enter(owner:Player, fsm:FlxFSM<Player>):Void
	{
		if (owner.queuedActions.contains(JUMP))
			owner.queuedActions.remove(JUMP);

		owner.stamina -= 10;
		owner.velocity.x += (owner.facing == RIGHT ? 100 : -100);

		owner.curAction = JUMP;
		FlxG.sound.play('assets/minigame/sounds/jump' + FlxG.random.int(0, 5) + '.ogg', 0.75);
		//owner.animation.play("jumping");
		owner.velocity.y = -200;
	}

	override function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void
	{
		//owner.acceleration.x = 0;
		if (FlxG.keys.pressed.LEFT || FlxG.keys.pressed.RIGHT)
		{
			owner.acceleration.x += FlxG.keys.pressed.LEFT ? -20 : 20;
		}

		if (FlxG.keys.justReleased.LEFT || FlxG.keys.justReleased.RIGHT)
		{
			owner.acceleration.x = 0.25;
			owner.velocity.x *= 0.5;
		}

		if(jumpBuffer == null)
			jumpBuffer = new FlxTimer().start(0.2, function(tmr:FlxTimer){jumpBuffer = null; if(owner.queuedActions.contains(JUMP)) owner.queuedActions.remove(JUMP);});
		else if (jumpBuffer.active && FlxG.keys.justPressed.SPACE && !owner.queuedActions.contains(JUMP))
		{
			owner.queuedActions.push(JUMP);
		}
	}

	override function exit(owner:Player) 
	{
		if (!FlxG.keys.pressed.LEFT || !FlxG.keys.pressed.RIGHT)
		{
			owner.acceleration.x = 0;
			owner.velocity.x *= 0.1;
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
		owner.animation.play("sneak");
	}

	override function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void
	{
		owner.acceleration.x = 0;
		if (FlxG.keys.pressed.RIGHT)
		{
			if (owner.velocity.x < 0)
				owner.velocity.x *= -0.5;

			owner.facing = RIGHT;
			owner.acceleration.x = 150;
		}
		else if (FlxG.keys.pressed.LEFT)
		{
			if (owner.velocity.x > 0)
				owner.velocity.x *= -0.5;

			owner.facing = LEFT;
			owner.acceleration.x = -150;
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

	override function enter(owner:Player, fsm:FlxFSM<Player>):Void
	{
		owner.curAction = SLIDE;
		owner.animation.play("sneak");
		owner.drag.x = 300;
		owner.stamina -= 25;
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
					owner.acceleration.x += 80;
					oneShot = true;
				}

				if (owner.velocity.x > 0)
				{
					if (FlxG.keys.justPressed.RIGHT)
						owner.acceleration.x += -5;
					else
						owner.acceleration.x = 0;
				}

			case LEFT:
				if (!oneShot)
				{
					owner.velocity.x = -owner.maxVelocity.x;
					owner.acceleration.x -= 80;
					oneShot = true;
				}
					
				if (owner.velocity.x < 0)
				{
					if (FlxG.keys.justPressed.RIGHT)
						owner.acceleration.x += 5;
					else
						owner.acceleration.x = 0;
				}

			default:
				//do nothing lmao
		}
	}

	override function exit(owner:Player) 
	{
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
		coyoteTime = new FlxTimer().start(0.35);
		//Falling anim and state maybe?
	}

	override function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void
	{
		if (FlxG.keys.justPressed.SPACE && coyoteTime.active && !owner.queuedActions.contains(JUMP))
		{
			owner.queuedActions.push(JUMP);
		}
	}

	override function exit(owner:Player) 
	{
		super.exit(owner);
	}
}

/*class SuperJump extends Jump
{
	override function enter(owner:Player, fsm:FlxFSM<Player>):Void
	{
		FlxG.sound.play("assets/superjump.ogg", FlxG.random.float(0.9, 1.0));
		owner.animation.play("jumping");
		owner.velocity.y = -300;
	}
}

class GroundPound extends FlxFSMState<Player>
{
	var time:Float;

	override function enter(owner:Player, fsm:FlxFSM<Player>):Void
	{
		FlxG.sound.play("assets/groundpound.ogg");
		owner.animation.play("pound");
		owner.velocity.x = 0;
		owner.acceleration.x = 0;
		time = 0;
	}

	override function update(elapsed:Float, owner:Player, fsm:FlxFSM<Player>):Void
	{
		time += elapsed;
		if (time < 0.25)
		{
			owner.velocity.y = 0;
		}
		else
		{
			owner.velocity.y = Player.GRAVITY;
		}
	}
}

class GroundPoundFinish extends FlxFSMState<Player>
{
	override function enter(owner:Player, fsm:FlxFSM<Player>):Void
	{
		FlxG.sound.play("assets/groundpoundfinish.ogg");
		owner.animation.play("landing");
		FlxG.camera.shake(0.025, 0.25);
		owner.velocity.x = 0;
		owner.acceleration.x = 0;
	}
}*/