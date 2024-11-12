package lore_minigames;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;

using StringTools;

class DoorPortal extends FlxSprite
{
	/**
	*Variables for the doors that serve as transitions to other rooms/levels!
	* @param locationID - Basically what specifies which door is connected with each other-
	* @param emitParticles - If the door should emit particles, idk-
	* @param destination - Where this door will teleport you.
	* @param destinationID - specifies if this door is a A -> B [0], or a B -> A [1].
	**/

	public var locationID:String = '';
	public var emitParticles:Bool = false;
	public var destination:Array<Int> = [0, 0];
	public var destinationID:Int = 0;

	public function new(x:Float = 0, y:Float = 0)
	{
		super(x, y);
		//trace('loading playurr');
		makeGraphic(32, 32, 0xFF800080);
		alpha = 0.5;
	}

	/*override function update(elapsed:Float)
	{
		super.update(elapsed);
	}*/
}