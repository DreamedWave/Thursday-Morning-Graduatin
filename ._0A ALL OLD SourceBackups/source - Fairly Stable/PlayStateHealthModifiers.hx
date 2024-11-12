class PlayStateHealthModifiers
{
    var returnHealth:Float;
    static public function modifyHealth(difficulty:Int, hpDrainType:Int)
    {
        switch (hpDrainType)
        {
            //Health Drain for Non-Sustain (PlayState line 4173)
            case 0:
                switch (difficulty)
                {
                    case 0:
                        if (PlayState.health <= 0.35 || PlayState.accuracy > 50)
                            returnHealth -= 0.04;
                        else
                            returnHealth -= 0.06;
                    case 1:
                        if (PlayState.health <= 0.35 || PlayState.accuracy > 60)
                            returnHealth -= 0.06;
                        else
                            returnHealth -= 0.08;
                    default:
                        if (PlayState.health <= 0.35 || PlayState.accuracy > 70)
                            returnHealth -= 0.08;
                        else
                            returnHealth -= 0.1;
                }
            //Heath Drain for Sustain (PlayState line 4186)
            case 1:
                switch (difficulty)
                {
                    case 0:
                        if (PlayState.health <= 0.35 && PlayState.accuracy < 50)
                            returnHealth -= 0.6;
                        else
                            returnHealth -= 0.11; 
                    case 1:
                        if (PlayState.health <= 0.35 && PlayState.accuracy < 60)
                            returnHealth -= 0.8;
                        else
                            returnHealth -= 0.13; 
                    default:
                        if (PlayState.health <= 0.35 && PlayState.accuracy < 70)
                            returnHealth -= 0.1;
                        else
                            returnHealth -= 0.15; 
                }
            //Health Drain for Sustain Children (PlayState line 4201)
            case 2:
                switch (difficulty)
                {
                    case 0:
                        if (PlayState.health >= 0.35 || PlayState.accuracy < 50)
                            returnHealth -= 0.015;
                    case 1:
                        if (PlayState.health <= 0.35 || PlayState.accuracy > 60)
                            returnHealth -= 0.01;
                        else
                            returnHealth -= 0.025;
                    default:
                        if (PlayState.health <= 0.35 || PlayState.accuracy > 70)
                            returnHealth -= 0.02;
                        else
                            returnHealth -= 0.035;
                }
            //Health Drain for... uhhh idk?? (PlayState line 4226)
            case 3:
                switch (difficulty)
                {
                    case 0:
                        if (PlayState.health <= 0.35 && PlayState.accuracy < 50)
                            returnHealth -= 0.6;
                        else
                            returnHealth -= 0.11; 
                    case 1:
                        if (PlayState.health <= 0.35 && PlayState.accuracy < 60)
                            returnHealth -= 0.8;
                        else
                            returnHealth -= 0.13; 
                    default:
                        if (PlayState.ealth <= 0.35 && PlayState.accuracy < 70)
                            returnHealth -= 0.1;
                        else
                            returnHealth -= 0.15; 
                }
            //Shit Rating (PlayState line 4671)
            case 4:
                switch (difficulty)
                {
                    case 0:
                        if (PlayState.accuracy < 50)
                            returnHealth -= 0.05;
                        else
                            returnHealth -= 0.025;
                    case 1:
                        if (PlayState.accuracy < 60)
                            returnHealth -= 0.075;
                        else
                            returnHealth -= 0.05;
                    default:
                        if (PlayState.accuracy < 70)
                            returnHealth -= 0.1;
                        else
                            returnHealth -= 0.08;
                }
            //Bad Rating (PlayState line )
            case 5:
                switch (difficulty)
                {
                    case 0:
                        if (PlayState.accuracy < 50)
                            returnHealth -= 0.04;
                        else
                            returnHealth -= 0.03;
                    case 1:
                        if (PlayState.accuracy < 60)
                            returnHealth -= 0.06;
                        else
                            returnHealth -= 0.045;
                    default:
                        if (PlayState.accuracy < 70)
                            returnHealth -= 0.08;
                        else
                            returnHealth -= 0.06;
                }
            //Good Rating (PlayState line )
            case 6:
                switch (difficulty)
                {
                    case 0:
                        if (PlayState.health < 0.7 && PlayState.accuracy > 50)
                            returnHealth += 0.05;
                    case 1:
                        if (PlayState.health < 0.7 && PlayState.accuracy > 60)
                            returnHealth += 0.03;
                        else if (PlayState.accuracy < 60)
                            returnHealth -= 0.01;
                    default:
                        if (PlayState.health < 0.7 && PlayState.accuracy > 70)
                            returnHealth += 0.01;
                        else if (PlayState.accuracy < 70)
                            returnHealth -= 0.03;
                }
            //Sick Rating (PlayState line)
            case 7:
                switch (difficulty)
                {
                    case 0:
                        if (PlayState.health < 0.7 && PlayState.accuracy > 50)
                            returnHealth += 0.06;
                        else if (PlayState.hurtVignette.alpha > 0)
                            returnHealth += 0.035;
                        else
                            returnHealth += 0.055;
                    case 1:
                        if (PlayState.health < 0.7 && PlayState.accuracy > 60)
                            returnHealth += 0.055;
                        else if (PlayState.hurtVignette.alpha > 0)
                            returnHealth += 0.025;
                        else
                            returnHealth += 0.05;
                    default:
                        if (PlayState.health < 0.7 && PlayState.accuracy > 70)
                            returnHealth += 0.05;
                        else if (PlayState.hurtVignette.alpha > 0)
                            returnHealth += 0.015;
                        else
                            returnHealth += 0.03;
                }
        }
        return returnHealth;
    }
}