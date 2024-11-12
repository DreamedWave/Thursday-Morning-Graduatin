//import flixel.FlxG;
import flixel.math.FlxMath;

class PlayStateHelpers
{
    public static function calculateScore(daRating:String):Int
    {
        switch(daRating)
            {
                case 'miss':
                    return -150;
                case 'shit':
                    return -50;
                case 'bad':
                    return 0;
                case 'good':
                    return 200;
                case 'sick':
                    return 350;
            }
        return 0;
    }

    public static function calculateHealth(difficulty:Int, hpDrainType:Int, health:Float, accuracy:Float, externalValue:Float = 0)
    {
        var feedbackHealth:Float = 0.00;
        switch (hpDrainType)
        {
            //Health Drain for Non-Sustain
            case 0:
                //trace ('Non Sus Loss');
                switch (difficulty)
                {
                    case 0:
                        if (health <= 0.35 || accuracy > 50)
                            feedbackHealth = -0.09;
                        else
                            feedbackHealth = -0.15;
                    case 1:
                        if (health <= 0.35 || accuracy > 60)
                            feedbackHealth = -0.12;
                        else
                            feedbackHealth = -0.13;
                    default:
                        if (health <= 0.35 || accuracy > 70)
                            feedbackHealth = -0.15;
                        else
                            feedbackHealth = -0.11;
                }
            //Heath Drain for Sustain Parent
            case 1:
                //trace ('Sus Parent Loss');
                switch (difficulty)
                {
                    case 0:
                        if (health <= 0.35 && accuracy < 50)
                            feedbackHealth = -0.1;
                        else
                            feedbackHealth = -0.11; 
                    case 1:
                        if (health <= 0.35 && accuracy < 60)
                            feedbackHealth = -0.12;
                        else
                            feedbackHealth = -0.13; 
                    default:
                        if (health <= 0.35 && accuracy < 70)
                            feedbackHealth = -0.14;
                        else
                            feedbackHealth = -0.15; 
                }
            //Health Drain for Sustain Initial Slip
            case 2:
                //trace ('Sus Init Slip Loss');
                switch (difficulty)
                {
                    case 0:
                        if (health >= 0.35 || accuracy < 50)
                            feedbackHealth = -0.03;
                    case 1:
                        if (health <= 0.35 || accuracy > 60)
                            feedbackHealth = -0.025;
                        else
                            feedbackHealth = -0.045;
                    default:
                        if (health <= 0.35 || accuracy > 70)
                            feedbackHealth = -0.035;
                        else
                            feedbackHealth = -0.055;
                }
            //Health Drain for Sustain Children
            case 3:
                //trace ('Sus Loss');
                switch (difficulty)
                {
                    case 0:
                        if (health >= 0.35 || accuracy < 50)
                            feedbackHealth = -0.015;
                    case 1:
                        if (health <= 0.35 || accuracy > 60)
                            feedbackHealth = -0.01;
                        else
                            feedbackHealth = -0.03;
                    default:
                        if (health <= 0.35 || accuracy > 70)
                            feedbackHealth = -0.02;
                        else
                            feedbackHealth = -0.04;
                }
            //Shit Rating
            case 4:
                //trace ('Shit Gain');
                switch (difficulty)
                {
                    case 0:
                        if (accuracy < 50)
                            feedbackHealth = -0.075;
                        else
                            feedbackHealth = -0.025;
                    case 1:
                        if (accuracy < 60)
                            feedbackHealth = -0.08;
                        else
                            feedbackHealth = -0.05;
                    default:
                        if (accuracy < 70)
                            feedbackHealth = -0.1;
                        else
                            feedbackHealth = -0.08;
                }
            //Bad Rating
            case 5:
                //trace ('Bad Gain');
                switch (difficulty)
                {
                    case 0:
                        if (accuracy < 50)
                            feedbackHealth = -0.04;
                        else
                            feedbackHealth = -0.03;
                    case 1:
                        if (accuracy < 60)
                            feedbackHealth = -0.06;
                        else
                            feedbackHealth = -0.045;
                    default:
                        if (accuracy < 70)
                            feedbackHealth = -0.08;
                        else
                            feedbackHealth = -0.06;
                }
            //Good Rating
            case 6:
                //trace ('Good Gain');
                switch (difficulty)
                {
                    case 0:
                        if (health < 0.7 && accuracy > 50)
                            feedbackHealth = 0.07;
                        else if (accuracy < 50)
                            feedbackHealth = -0.05;
                    case 1:
                        if (health < 0.7 && accuracy > 60)
                            feedbackHealth = 0.05;
                        else if (accuracy < 60)
                            feedbackHealth = -0.03;
                    default:
                        if (health < 0.7 && accuracy > 70)
                            feedbackHealth = 0.03;
                        else if (accuracy < 70)
                            feedbackHealth = -0.01;
                }
            //Sick Rating
            case 7:
                //trace ('Sick Gain');
                    switch (difficulty)
                    {
                        case 0:
                            if (health < 0.7 && accuracy > 50)
                                feedbackHealth = 0.09;
                            else if (externalValue > 0 && accuracy > 20)
                                feedbackHealth = 0.055;
                            else
                                feedbackHealth = 0.075;
                        case 1:
                            if (health < 0.7 && accuracy > 60)
                                feedbackHealth = 0.075;
                            else if (externalValue > 0 && accuracy > 35)
                                feedbackHealth = 0.045;
                            else
                                feedbackHealth = 0.060;
                        default:
                            if (health < 0.7 && accuracy > 70)
                                feedbackHealth = 0.07;
                            else if (externalValue > 0 && accuracy > 50)
                                feedbackHealth = 0.035;
                            else
                                feedbackHealth = 0.055;
                    }
            //Health Gain for Sustain
            case 8:
                //trace ('Health Gain for Sus');
                switch(difficulty)
                {
                    case 0:
                        if (health < 0.8 && accuracy > 50)
                            feedbackHealth = 0.008;
                        else if (accuracy > 20)
                            feedbackHealth = 0.006;
                    case 1:
                        if (health < 0.8 && accuracy > 60)
                            feedbackHealth = 0.007;
                        else if (accuracy > 35)
                            feedbackHealth = 0.005;
                    default:
                        if (health < 0.8 && accuracy > 70)
                            feedbackHealth = 0.006;
                        else if (accuracy > 50)
                            feedbackHealth = 0.004;
                }
            //Enemy Fail
            case 9:
                //trace ('Enemy Fail Gain');
                switch (difficulty)
                {
                    case 0:
                        if (accuracy < 50)
                            feedbackHealth = 0.04;
                        else
                            feedbackHealth = 0.08;
                    case 1:
                        if (accuracy < 60)
                            feedbackHealth = 0.03;
                        else
                            feedbackHealth = 0.06;
                    default:
                        if (accuracy < 70)
                            feedbackHealth = 0.02;
                        else
                            feedbackHealth = 0.04;
                }
            //Enemy Sing
            case 10:
                //trace ('Enemy Sing Loss');
                switch (difficulty)
                {
                    case 0:
                        if (health >= 1)
                            feedbackHealth = -0.0075;
                        else 
                            feedbackHealth = -0.005;
                    case 1:
                        if (health >= 1)
                            feedbackHealth = -0.01;
                        else
                            feedbackHealth = -0.0075;
                    default:
                        if (health >= 1)
                            feedbackHealth = -0.015;
                        else
                            feedbackHealth = -0.01;
                }
            //Enemy Sing Sustain
            case 11:
                //trace ('Enemy Sing Sustain Loss');
                switch (difficulty)
                {
                    case 0:
                        if (health >= 1)
                            feedbackHealth = -0.003;
                        else 
                            feedbackHealth = -0.001;
                    case 1:
                        if (health >= 1)
                            feedbackHealth = -0.004;
                        else
                            feedbackHealth = -0.002;
                    default:
                        if (health >= 1)
                            feedbackHealth = -0.005;
                        else
                            feedbackHealth = -0.003;
                }
            //Trigger Note Health Gain
            case 12:
                if (health < 0.2)
                    feedbackHealth = 0.15;
                if (health < 0.5)
                    feedbackHealth = 0.08;
                else
                    feedbackHealth = 0.03;
            case 13:
                //e
            //Taunt Health Gain
            case 14:
                var styleHitMult:Float = externalValue / 4;
                if (health < 2)
                  feedbackHealth = ((2 - health) / 4) * styleHitMult;
        }
        return feedbackHealth;
    }

    public static function calculateLerpTime(timeElapsed:Float, durationMultiplier:Float, min:Int = 0, max:Int = 0)
    {
        var returnedTime:Float = CoolUtil.boundTo(1 - (timeElapsed * durationMultiplier), min, max);
        return returnedTime;
    }
}