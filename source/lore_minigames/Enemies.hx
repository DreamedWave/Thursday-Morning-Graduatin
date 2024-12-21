package;

import flixel.FlxSprite;

enum EnemyType
{
	REGULAR;
	BOSS;
}

class Enemy extends FlxSprite
{
	static inline var WALK_SPEED:Float = 40;
	static inline var CHASE_SPEED:Float = 200;

	var type:EnemyType;

	public function new(x:Float, y:Float, type:EnemyType)
	{
		super(x, y);
		makeGraphic(64, 64, 0xFF640000);
		/*this.type = type;
		var graphic = if (type == BOSS) AssetPaths.boss__png else AssetPaths.enemy__png;
		loadGraphic(graphic, true, 16, 16);
		setFacingFlip(LEFT, false, false);
		setFacingFlip(RIGHT, true, false);
		animation.add("d_idle", [0]);
		animation.add("lr_idle", [3]);
		animation.add("u_idle", [6]);
		animation.add("d_walk", [0, 1, 0, 2], 6);
		animation.add("lr_walk", [3, 4, 3, 5], 6);
		animation.add("u_walk", [6, 7, 6, 8], 6);
		drag.x = drag.y = 10;
		setSize(8, 8);
		offset.x = 4;
		offset.y = 8;*/
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

		super.update(elapsed);
	}
}