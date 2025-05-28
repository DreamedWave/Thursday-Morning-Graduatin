import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import haxe.Timer;

//A class I made by myself (Amiee)!!! :3 :3 :3
class HitStop
{
    //Based on a Unity Tutorial - loosely followed it, then realised that trying to do it that method is not gonna work so I did a thinky think!
    //Tried this before with FlxTimers and it didnt work so I looked at the code of that and saw it was reliant on update(elapsed)
    //So I looked up if Haxe has a timer that isnt based on FlxGame - and apparently it did and here we are!
    //Feel free to implement this in your own stuff - and change it to be better because I am not a coder!!! I just do this shit for fun!!!
    //If you're gonna do that, please make sure to credit me tho!!! And LMK if you did use this in a project becuz I'd love to see it !!!!! WAHH!!!
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


    public static function doSlowDown(duration:Float, slowDownAmt:Float, doTwn:Bool = true, ?waitingFunction:Void->Void, ?thisOnComplete:Void->Void)// (in seconds)
    {
        //trace('wah but not frozen'); //fucking liar BAHAHAHAH
        if (waiting)
        {
            //trace ('waiting test');
            if (waitingFunction != null)
                waitingFunction();
            return;
        }

        waiting = true;
        if (doTwn)
        {
            //trace ('didtwn - should be only showing up once');
            FlxTween.tween(FlxG, {timeScale: slowDownAmt}, duration * 0.75, {type: ONESHOT, ease: FlxEase.cubeOut, onComplete: 
                function(twn:FlxTween)
                {
                    if (slowDownAmt > 0)
                        FlxTween.tween(FlxG, {timeScale: 1}, duration * 0.25, {type: ONESHOT, ease: FlxEase.quartIn, onComplete: function(twn:FlxTween){waiting = false; if (thisOnComplete != null) thisOnComplete();}});
                    else
                        Timer.delay(
                            function()
                            {
                                FlxG.timeScale = 0.025;
                                FlxTween.tween(FlxG, {timeScale: 1}, duration * 0.125, {type: ONESHOT, ease: FlxEase.quartIn, onComplete: function(twn:FlxTween){waiting = false;  if (thisOnComplete != null) thisOnComplete();}});
                            },
                        Math.floor((duration * 0.125) * 1000));
                }
            });
        }
        else
        {
            FlxG.timeScale = slowDownAmt; 
            Timer.delay(unFreeze, Math.floor(duration * 1000));
        }
    }
}