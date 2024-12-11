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
                    var sicks:Int = 0;
                    var goods:Int = 0;
                    var bads = 0;
                    var slips = 0;
                    var misses = 0;

                    //lazygurl's way :3
                    //For readability porpoises!!
                    //if (!PlayState.isStoryMode)
                    //{
                        sicks = PlayState.instance.sicks;
                        goods = PlayState.instance.goods;
                        bads = PlayState.instance.bads;
                        slips = PlayState.instance.slips;
                        misses = PlayState.instance.misses;
                    /*}
                    else
                    {
                        sicks = PlayState.campaignSicks;
                         goods = PlayState.campaignGoods;
                        bads = PlayState.campaignBads;
                        slips = PlayState.campaignSlips;
                        misses = PlayState.campaignMisses;
                        
                    }*/

                    if (misses == 0 && slips == 0 && bads == 0 && goods == 0) // Perfect (SICK) Full Combo
                        ranking = "PFC";
                    else if (misses == 0 && slips == 0 && bads == 0 && goods >= 1) // Good Full Combo (Nothing but Goods & Sicks)
                        ranking = "GFC";
                    else if (misses == 0 && slips == 0 && bads >= 1) // Regular FC
                        ranking = "BFC";
                    else if (misses < 10) // Single Digit Combo Breaks
                        ranking = "SDR";
                    else if (misses < 30) // Double Digit Combo Breaks
                        ranking = "DDR";
                    else if ((misses < 50 && accuracy > 70) || accuracy > 50)
                        ranking = "CLR";
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
