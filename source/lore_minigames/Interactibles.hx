package lore_minigames;

import flixel.FlxSprite;
//import flixel.FlxG;
import flixel.FlxObject;
import flixel.util.FlxTimer;

using StringTools;

enum InteractType
{
	DOOR;
	OTHER;
}

class Interactibles extends FlxSprite
{
	public var type:InteractType;

	/**
	*Variables for the doors that serve as transitions to other rooms/levels!
	* @param locationID - Basically what specifies which door is connected with each other-
	* @param specialAnimType - The type of animation the door will make, idk- (default = 'none')
	* @param destination - Where this door will teleport you.
	* @param destinationID - specifies if this door is a A -> B [0], or a B -> A [1].
	**/
	public var locationID:String = '';
	public var specialAnimType:String = 'none';
	public var destination:Array<Int> = [0, 0];
	public var destinationID:Int = 0;
	public var isLocked:Bool = false;

	/**
	*Variables for interactible objects!
	* @param spriteID - Specifies what the interactible item would look like-
	* @param specialAnimType - The type of animation the item will make as it is showing the dialogue. shares the same var with the door
	* @param dialogueArray - what dialogue the object would say.
	**/
	public var spriteID:String = '';
	public var dialogueArray:Array<String> = [];

	public function new(x:Float = 0, y:Float = 0, type:InteractType)
	{
		super(x, y);
		this.type = type;
		switch (this.type)
		{
			case DOOR:
				makeGraphic(32, 32, 0xFF800080);
				alpha = 0.5;
			case OTHER:
				makeGraphic(32, 32, 0xFF00ffee);
				alpha = 0.75;
		}
	}

	/*override function update(elapsed:Float)
	{
		super.update(elapsed);
	}*/
}