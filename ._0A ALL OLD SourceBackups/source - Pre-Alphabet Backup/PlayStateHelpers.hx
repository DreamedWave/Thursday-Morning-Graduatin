//import flixel.FlxG;
import flixel.math.FlxMath;
using StringTools;

class PlayStateHelpers
{
    public static function getIconID(charName:String = ''):String
    {
        var iconName:String = '';
        if (charName.startsWith('table'))
            iconName = 'holy-cross';
        else if (charName.startsWith('demon-dad'))
            iconName = 'demon-dad';
        else
        {
            switch (charName)
            {
                case 'guy-default' | 'guy-theborder' | 'guy-fail':
                    iconName = 'guy-default';
                case 'priest-theborderpray':
                    iconName = 'priest-default';
                case 'priest-theborderannoyed' | 'priest-angry':
                    iconName = 'priest-annoyed';
                case 'priest-theborderangry':
                    iconName = 'priest-cicatrix';
                default:
                    iconName = charName;
            }
        }
        return iconName;
    }

    public static function calculateLerpTime(timeElapsed:Float, durationMultiplier:Float, min:Int = 0, max:Int = 0)
    {
        var returnedTime:Float = CoolUtil.boundTo(1 - (timeElapsed * durationMultiplier), min, max);
        return returnedTime;
    }
}