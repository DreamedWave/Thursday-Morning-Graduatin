import haxe.Timer;

//A class I made by myself (Amiee)!!! :3 :3 :3
class HitStop
{
    //Based on a Unity Tutorial - loosely followed it, then realised that trying to do it that method is not gonna work so I did a thinky think!
    //Tried this before with FlxTimers and it didnt work so I looked at the code of that and saw it was reliant on update(elapsed)
    //So I looked up if Haxe has a timer that isnt based on FlxGame - and apparently it did and here we are!
   static var waiting:Bool = false;

    public static function doHitStop(duration:Float)// (in seconds)
    {
        trace('wah');
        if (waiting)
            return;
        waiting = true;
        FlxG.timeScale = 0;
        Timer.delay(unFreeze, Math.floor(duration * 1000));
    }

    static function unFreeze()
    {
        FlxG.timeScale = 1;
        waiting = false;
    }
}