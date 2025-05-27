package;

import lime.utils.Assets;
import flixel.math.FlxMath;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ["Easy", "Normal", "Hard"];

	public static function difficultyFromInt(difficulty:Int):String
	{
		return difficultyArray[difficulty];
	}

	inline public static function boundTo(value:Float, min:Float, max:Float):Float 
	{
		return Math.max(min, Math.min(max, value));
	}

	//Framerate indepentent lerp funct!
	//TYSM Freya Holmér!!! THE GOAT!!!
	//meow :3 meow :3 meow :3 meow :3 meow :3 
	inline public static function freyaLerp(a:Float, b:Float, decay:Float = 16, deltaTime:Float):Float
	{
		return b + (a - b) * Math.exp(-decay * deltaTime);
	}

	//IDFK WHAT FLXMATH FUNCTUON THIS IS SO IM MAKING IT MYSELF !!!!
	inline public static function getPercentOfNumber(curValue:Float, maxValue:Float, ?roundByHowMuchExactly:Int = 0, ?capPercentAt100:Bool = true):Float
	{
		var returnThisLololol:Float = curValue/maxValue * 100;
		if (roundByHowMuchExactly > 0)
			FlxMath.roundDecimal(returnThisLololol, roundByHowMuchExactly);
		if (capPercentAt100 && returnThisLololol > 100)
			returnThisLololol = 100;
			
		return returnThisLololol;
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}
	
	public static function coolStringFile(path:String):Array<String>
		{
			var daList:Array<String> = path.trim().split('\n');
	
			for (i in 0...daList.length)
			{
				daList[i] = daList[i].trim();
			}
	
			return daList;
		}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}
}
