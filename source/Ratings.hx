//import flixel.FlxG;

class Ratings
{
    public static function GenerateLetterRank(accuracy:Float, ?keeledOver:Bool = false):String // generate a letter ranking
    {
        var ranking:String = "N/A";

        if (keeledOver)
            ranking = "Failed!";
        else
        {
            if (accuracy > 0)
            {
                if(FlxG.save.data.botplay)
                    ranking = "[BotPlay]";
                else
                {
                    if (PlayState.instance.misses == 0 && PlayState.instance.slips == 0 && PlayState.instance.bads == 0 && PlayState.instance.goods == 0) // Perfect (SICK) Full Combo
                        ranking = "PFC";
                    else if (PlayState.instance.misses == 0 && PlayState.instance.slips == 0 && PlayState.instance.bads == 0 && PlayState.instance.goods >= 1) // Good Full Combo (Nothing but Goods & Sicks)
                        ranking = "GFC";
                    else if (PlayState.instance.misses == 0 && PlayState.instance.slips == 0 && PlayState.instance.bads >= 1) // Regular FC
                        ranking = "FC";
                    else if (PlayState.instance.misses < 10) // Single Digit Combo Breaks
                        ranking = "SDCB";
                    else if (PlayState.instance.misses < 30) // Double Digit Combo Breaks
                        ranking = "DDCB";
                    else if ((PlayState.instance.misses < 50 && accuracy > 70) || accuracy > 20)
                        ranking = "CLEAR";
                    else
                        ranking = "RETRY";
                }
            }
        }

        return ranking;
    }
    
    public static function CalculateRating(noteDiff:Float, ?customSafeZone:Float):String // Generate a judgement through some timing shit
    {
        if (FlxG.save.data.botplay)
            return "sick"; // FUNNY
        
        var customTimeScale = Conductor.timeScale;

        if (customSafeZone != null)
            customTimeScale = customSafeZone / 166;
	
        var rating = checkRating(noteDiff,customTimeScale);

        return rating;
    }

    public static function checkRating(ms:Float, ts:Float):String
    {
        var rating = "sick";
        if (ms < 45 * ts && ms >= -45 * ts || ms == 0)
            rating = "sick";
        else if ((ms < 90 * ts && ms >= 45 * ts) || (ms > -90 * ts && ms <= -45 * ts))
            rating = "good";
        else if ((ms < 135 * ts && ms >= 90 * ts) || (ms > -135 * ts && ms <= -90 * ts)) 
            rating = "bad";
        else
            rating = "shit";
        return rating;
    }

    public static function CalculateRanking(score:Int, NPS:Int, maxNPS:Int, accuracy:Float, ?keeledOver:Bool = false):String
    {
        return
         (!PlayStateChangeables.botPlay ?
         (FlxG.save.data.npsDisplay ? "NPS:" + NPS + "/" + maxNPS + " | " : "") //NPS
         + "Score:" + score //Score
         + (FlxG.save.data.accuracyDisplay ? //Accuracy																						 // Accuracy Toggle
         " | RIPs:" + (PlayState.instance.misses + PlayState.instance.slips) + 																				         // Misses/Combo Breaks
         " | Rating:" + GenerateLetterRank(accuracy, keeledOver) + //Rating				                                                         // Accuracy
         " (" + HelperFunctions.truncateFloat(accuracy, 2) + "%)" : "") 													     // Letter Rank
         : "(Press [1] to hide HUD) | Score: " + score); //BotplayScoreText
    }

    public static function DetermineWeekRating(ratingArray:Array<String>):String
    {
        var weekRating:String = ratingArray[0];
        //Ass code but lol anyways
        if (ratingArray.contains('PFC'))
            weekRating = 'PFC';
        if (ratingArray.contains('GFC'))
            weekRating = 'GFC';
        if (ratingArray.contains('FC'))
            weekRating = 'FC';
        if (ratingArray.contains('SDCB'))
            weekRating = 'SDCB';
        if (ratingArray.contains('DDCB'))
            weekRating = 'DDCB';
        if (ratingArray.contains('Clear'))
            weekRating = 'Clear';
        if (ratingArray.contains('Fail!'))
            weekRating = 'Fail!';

        return weekRating;
    }
}
