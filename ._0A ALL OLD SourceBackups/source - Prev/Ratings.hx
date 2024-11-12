import flixel.FlxG;

class Ratings
{
    public static function GenerateLetterRank(accuracy:Float) // generate a letter ranking
    {
        var ranking:String = "N/A";
        if (accuracy > 0)
        {
            if(FlxG.save.data.botplay)
                ranking = "[BotPlay]";
            if (PlayState.misses == 0 && PlayState.bads == 0 && PlayState.shits == 0 && PlayState.goods == 0) // Perfect (SICK) Full Combo
                ranking = "PFC";
            else if (PlayState.misses == 0 && PlayState.bads == 0 && PlayState.shits == 0 && PlayState.goods >= 1) // Good Full Combo (Nothing but Goods & Sicks)
                ranking = "GFC";
            else if (PlayState.misses == 0) // Regular FC
                ranking = "FC";
            else if (PlayState.misses < 10) // Single Digit Combo Breaks
                ranking = "SDCB";
            else if (PlayState.misses < 30) // Double Digit Combo Breaks
                ranking = "DDCB";
            else
                ranking = "Clear";
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

    public static function checkRating(ms:Float, ts:Float)
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

    public static function CalculateRanking(score:Int,scoreDef:Int,nps:Int,maxNPS:Int,accuracy:Float):String
    {
        return
         (!PlayStateChangeables.botPlay ?
         (FlxG.save.data.npsDisplay ? "NPS:" + nps + "/" + maxNPS + (!PlayStateChangeables.botPlay ? " | " : "") : "") +		 // NPS
         "Score:" + (Conductor.safeFrames != 10 ? score + " (" + scoreDef + ")" : "" + score) +                                  // Score
         (FlxG.save.data.accuracyDisplay ?																						 // Accuracy Toggle
         " | Slips:" + PlayState.misses + 																				         // Misses/Combo Breaks
         " | Rating:" + GenerateLetterRank(accuracy) +  				                                                         // Accuracy
         " (" + HelperFunctions.truncateFloat(accuracy, 2) + "%)" : "") 													     // Letter Rank
         : "");
    }
}
