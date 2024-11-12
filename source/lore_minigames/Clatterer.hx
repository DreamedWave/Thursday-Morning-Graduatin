package lore_minigames;

import flixel.FlxSprite;
import flixel.FlxObject;
import flixel.util.FlxTimer;

using StringTools;

class Clatterer extends FlxSprite
{
	public var canClatter:Bool = true;
	public var clatterAmt:Int = 1;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		//trace('loading playurr');
		makeGraphic(24, 16, 0xFF640000);
		alpha = 0.25;
	}

	public function playerMadeNoise()
	{
		//ruhehehehehhe
		//switch (clatterAMt)
		FlxG.sound.play('assets/minigame/sounds/clatterSND_Placeholder.ogg', 1);
		alpha = 0.1;
	}
}