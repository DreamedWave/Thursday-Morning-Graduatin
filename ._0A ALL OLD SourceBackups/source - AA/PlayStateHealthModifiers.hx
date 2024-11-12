import flixel.FlxG;

class PlayStateHealthModifiers
{
    public static function ModifyHealth(difficulty:Int, hpDrainType:Int, health:Float, accuracy:Float, alpha:Float = 0)
    {
        var feedbackHealth:Float = 0.00;
        switch (hpDrainType)
        {
            //Health Drain for Non-Sustain (PlayState line 4275)
            case 0:
                switch (difficulty)
                {
                    case 0:
                        if (health <= 0.35 || accuracy > 50)
                            feedbackHealth = -0.04;
                        else
                            feedbackHealth = -0.06;
                    case 1:
                        if (health <= 0.35 || accuracy > 60)
                            feedbackHealth = -0.06;
                        else
                            feedbackHealth = -0.08;
                    default:
                        if (health <= 0.35 || accuracy > 70)
                            feedbackHealth = -0.08;
                        else
                            feedbackHealth = -0.1;
                }
            //Heath Drain for Sustain (PlayState line 4288)
            case 1:
                switch (difficulty)
                {
                    case 0:
                        if (health <= 0.35 && accuracy < 50)
                            feedbackHealth = -0.6;
                        else
                            feedbackHealth = -0.11; 
                    case 1:
                        if (health <= 0.35 && accuracy < 60)
                            feedbackHealth = -0.8;
                        else
                            feedbackHealth = -0.13; 
                    default:
                        if (health <= 0.35 && accuracy < 70)
                            feedbackHealth = -0.1;
                        else
                            feedbackHealth = -0.15; 
                }
            //Health Drain for Sustain Children (PlayState line 4299)
            case 2:
                switch (difficulty)
                {
                    case 0:
                        if (health >= 0.35 || accuracy < 50)
                            feedbackHealth = -0.015;
                    case 1:
                        if (health <= 0.35 || accuracy > 60)
                            feedbackHealth = -0.01;
                        else
                            feedbackHealth = -0.025;
                    default:
                        if (health <= 0.35 || accuracy > 70)
                            feedbackHealth = -0.02;
                        else
                            feedbackHealth = -0.035;
                }
            //Health Drain for... uhhh idk?? (PlayState line 4322)
            case 3:
                switch (difficulty)
                {
                    case 0:
                        if (health <= 0.35 && accuracy < 50)
                            feedbackHealth = -0.6;
                        else
                            feedbackHealth = -0.11; 
                    case 1:
                        if (health <= 0.35 && accuracy < 60)
                            feedbackHealth = -0.8;
                        else
                            feedbackHealth = -0.13; 
                    default:
                        if (health <= 0.35 && accuracy < 70)
                            feedbackHealth = -0.1;
                        else
                            feedbackHealth = -0.15; 
                }
            //Shit Rating (PlayState line 4783)
            case 4:
                switch (difficulty)
                {
                    case 0:
                        if (accuracy < 50)
                            feedbackHealth = -0.05;
                        else
                            feedbackHealth = -0.025;
                    case 1:
                        if (accuracy < 60)
                            feedbackHealth = -0.075;
                        else
                            feedbackHealth = -0.05;
                    default:
                        if (accuracy < 70)
                            feedbackHealth = -0.1;
                        else
                            feedbackHealth = -0.08;
                }
            //Bad Rating (PlayState line 4795)
            case 5:
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
            //Good Rating (PlayState line 4807)
            case 6:
                switch (difficulty)
                {
                    case 0:
                        if (health < 0.7 && accuracy > 50)
                            feedbackHealth = 0.05;
                    case 1:
                        if (health < 0.7 && accuracy > 60)
                            feedbackHealth = 0.03;
                        else if (accuracy < 60)
                            feedbackHealth = -0.01;
                    default:
                        if (health < 0.7 && accuracy > 70)
                            feedbackHealth = 0.01;
                        else if (accuracy < 70)
                            feedbackHealth = -0.03;
                }
            //Sick Rating (PlayState line 4818)
            case 7:
                switch (difficulty)
                {
                    case 0:
                        if (health < 0.7 && accuracy > 50)
                            feedbackHealth = 0.06;
                        else if (alpha > 0)
                            feedbackHealth = 0.035;
                        else
                            feedbackHealth = 0.055;
                    case 1:
                        if (health < 0.7 && accuracy > 60)
                            feedbackHealth = 0.055;
                        else if (alpha > 0)
                            feedbackHealth = 0.025;
                        else
                            feedbackHealth = 0.05;
                    default:
                        if (health < 0.7 && accuracy > 70)
                            feedbackHealth = 0.05;
                        else if (alpha > 0)
                            feedbackHealth = 0.015;
                        else
                            feedbackHealth = 0.03;
                }
            //Health Gain for Sustain
            case 8:
                switch(difficulty)
                {
                    case 0:
                        if (health < 0.8 && accuracy > 50)
                            feedbackHealth = 0.008;
                        else
                            feedbackHealth = 0.006;
                    case 1:
                        if (health < 0.8 && accuracy > 60)
                            feedbackHealth = 0.007;
                        else
                            feedbackHealth = 0.005;
                    default:
                        if (health < 0.8 && accuracy > 70)
                            feedbackHealth = 0.006;
                        else
                            feedbackHealth = 0.004;
                }
            //Enemy Fail (PlayState line 4441)
            case 9:
                switch (difficulty)
                {
                    case 0:
                        if (accuracy < 50)
                            feedbackHealth = 0.02;
                        else
                            feedbackHealth = 0.03;
                    case 1:
                        if (accuracy < 60)
                            feedbackHealth = 0.035;
                        else
                            feedbackHealth = 0.05;
                    default:
                        if (accuracy < 70)
                            feedbackHealth = 0.05;
                        else
                            feedbackHealth = 0.07;
                }
            //Enemy Sing (PlayState line 4288)
            case 10:
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
            //Trigger Note Health Gain (PlayState line 6073)
            case 11:
                if (health < 0.2)
                    feedbackHealth = 0.15;
                if (health < 0.5)
                    feedbackHealth = 0.08;
                else
                    feedbackHealth = 0.03;
        }
        return feedbackHealth;
    }
}