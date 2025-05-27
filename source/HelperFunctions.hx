import flixel.math.FlxMath;

class HelperFunctions
{
    /*public static function truncateFloat( number : Float, precision : Int): Float 
	{
		//I dont trust the math here so im just gonna-
		//do my own thang
		var num:Float = number; //get the number
		var div:Float = 1;
		for(i in 0...precision) //multiply the number to bump up the decimal places
		{
			num *= 10;
			div *= 0.1;
		}
		num = Math.floor(num); //floor the number to remove the decimal places
		num *= div;
		//trace('truncated: ' + num + ' | full: ' + number);
		return num;
	}*/

	public static function truncateFloat(number:Float, precision:Int):Float 
	{
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.floor(num) / Math.pow(10, precision);
		//trace('truncated: ' + num + ' | full: ' + number);
		return num;
	}

	public static function GCD(a, b) {
		return b == 0 ? FlxMath.absInt(a) : GCD(b, a % b);
	}

}