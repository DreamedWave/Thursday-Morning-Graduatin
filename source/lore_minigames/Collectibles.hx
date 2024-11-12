package lore_minigames;

import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

using StringTools;

enum CollectibleType
{
	FINAL;
	SECRET;
}

class Collectibles extends FlxSprite
{
	public var type:CollectibleType;

	public var isActive:Bool = true;

	public function new(x:Float = 0, y:Float = 0, type:CollectibleType)
	{
		super(x, y);
		this.type = type;
		switch (this.type)
		{
			case FINAL:
				//trace('loading playurr');
				makeGraphic(32, 32, 0xFFFFC400);
			case SECRET:
				makeGraphic(32, 32, 0xFF51ff17);
		}
	}

	override function kill()
	{
		alive = false;
		FlxTween.tween(this, {alpha: 0, y: y - 16}, 1, {ease: FlxEase.circOut, onComplete: finishKill});
	}

	function finishKill(_)
	{
		exists = false;
	}
}