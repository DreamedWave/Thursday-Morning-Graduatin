package lore_minigames;

//import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxPoint;
import flixel.math.FlxVelocity;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

enum FinalChaserType
{
	NORMAL;
	BUFFED;
	NERFED;
}

class TheManUpstairs extends FlxSprite
{
	//static inline 
	var CHASE_SPEED:Float = 400;

	var type:FinalChaserType;

	var brain:EnemyAI;
	var idleTimer:Float;
	var moveDirection:Float;
	var seesPlayer:Bool;
	public var playerPosition:FlxPoint;
	public var aiStatus:String = 'idle';

	public var dadSuspenseMusFar:FlxSound;
	public var dadSuspenseMusNear:FlxSound;

	public var dadSNDFar:FlxSound;
	public var dadSNDNear:FlxSound;

	public function new(x:Float, y:Float, type:FinalChaserType)
	{
		super(x, y);
		makeGraphic(64, 64, 0xFF640000);
		alpha = 0.75;
		brain = new EnemyAI(idle);
		idleTimer = 3;
		playerPosition = FlxPoint.get();
		
		//Suspense Music
		//Might remove this and merge it with the below
		dadSuspenseMusFar = FlxG.sound.load('assets/minigame/music/dadSuspense_Far.ogg', 0);
		dadSuspenseMusFar.looped = true;
		dadSuspenseMusFar.proximity(x, y, lore_minigames.MinigameState.player, 5000);
		dadSuspenseMusNear = FlxG.sound.load('assets/minigame/music/dadSuspense_Near.ogg', 0);
		dadSuspenseMusNear.looped = true;
		dadSuspenseMusNear.proximity(x, y, lore_minigames.MinigameState.player, 2000);

		dadSuspenseMusFar.play();
		dadSuspenseMusNear.play();

		//SND like rush or ambush
		dadSNDFar = FlxG.sound.load('assets/minigame/sounds/SND_dadMoving_Far.ogg', 0);
		dadSNDFar.looped = true;
		dadSNDFar.proximity(x, y, lore_minigames.MinigameState.player, 1600, true);
		dadSNDNear = FlxG.sound.load('assets/minigame/sounds/SND_dadMoving_Near.ogg', 0);
		dadSNDNear.looped = true;
		dadSNDNear.proximity(x, y, lore_minigames.MinigameState.player, 500, true);

		dadSuspenseMusFar.setPosition(x + (width / 2), y + (height / 2));
		dadSuspenseMusNear.setPosition(x + (width / 2), y + (height / 2));
		dadSNDFar.setPosition(x + (width / 2), y + (height / 2));
		dadSNDNear.setPosition(x + (width / 2), y + (height / 2));

		//a whopping 4 FLXTWEENS
		FlxTween.tween(dadSuspenseMusFar, {volume: 0.5}, 1, {type: ONESHOT, ease: FlxEase.smoothStepInOut});
		FlxTween.tween(dadSuspenseMusNear, {volume: 0.5}, 1, {type: ONESHOT, ease: FlxEase.smoothStepInOut});
		FlxTween.tween(dadSNDFar, {volume: 1}, 1, {type: ONESHOT, ease: FlxEase.smoothStepInOut});
		FlxTween.tween(dadSNDNear, {volume: 1}, 1, {type: ONESHOT, ease: FlxEase.smoothStepInOut});

		dadSNDFar.play();
		dadSNDNear.play();
	}

	function idle(elapsed:Float)
	{
		if (idleTimer > 0)
			idleTimer -= elapsed;
		else
			brain.activeState = chase;
	}
	
	function chase(elapsed:Float)
	{
		alpha = 1;
		aiStatus = 'chase';
		FlxVelocity.moveTowardsPoint(this, playerPosition, CHASE_SPEED);
	}

	public function setChaseSpeed(givenChaseSpeed:Float = 180):Void
	{
		CHASE_SPEED = givenChaseSpeed;
	}

	//idletime is in secondfs, btw
	public function quellTheDemon(idleTime:Int, resetCurrentTimer:Bool = true, stopCurrentVelocity:Bool = true)
	{
		alpha = 0.75;
		//no <3
		if (idleTime < 0)
			idleTime = 0;
		
		if (stopCurrentVelocity)
		{
			velocity.set(0, 0);
			acceleration.set(0, 0);
		}

		aiStatus = 'idle';
		brain.activeState = idle;
		if (resetCurrentTimer)
			idleTimer = idleTime;
		else
			idleTimer += idleTime;
	}

	override function destroy()
	{
		//Failsafe
		dadSuspenseMusFar.stop();
		dadSuspenseMusNear.stop();
		dadSNDFar.stop();
		dadSNDNear.stop();

		super.destroy();
	}

	override public function update(elapsed:Float)
	{
		if (velocity.x != 0 || velocity.y != 0)
		{
			if (Math.abs(velocity.x) > Math.abs(velocity.y))
			{
				if (velocity.x < 0)
					facing = LEFT;
				else
					facing = RIGHT;
			}
			else
			{
				if (velocity.y < 0)
					facing = UP;
				else
					facing = DOWN;
			}
		}

		/*switch (facing)
		{
			case LEFT, RIGHT:
				animation.play("lr_" + action);

			case UP:
				animation.play("u_" + action);

			case DOWN:
				animation.play("d_" + action);

			case _:
		}*/
		brain.update(elapsed);
		super.update(elapsed);

		dadSuspenseMusFar.setPosition(x + (width / 2), y + (height / 2));
		dadSuspenseMusNear.setPosition(x + (width / 2), y + (height / 2));
		dadSNDFar.setPosition(x + (width / 2), y + (height / 2));
		dadSNDNear.setPosition(x + (width / 2), y + (height / 2));
	}
}