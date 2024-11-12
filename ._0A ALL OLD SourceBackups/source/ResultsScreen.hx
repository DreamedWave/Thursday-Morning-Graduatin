package;
import haxe.Exception;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import flixel.system.FlxSound;
import flixel.util.FlxAxes;
import flixel.util.FlxTimer;
import flixel.FlxSubState;
import Options.Option;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.app.Application;
import lime.utils.Assets;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.input.FlxKeyManager;
import flixel.addons.transition.FlxTransitionableState;

#if windows
import Discord.DiscordClient;
#end

using StringTools;

class ResultsScreen extends FlxSubState
{
    public var darkenScreen:FlxSprite;
    public var text:FlxText;

    public var anotherdarkenScreen:FlxSprite;
    public var graph:HitGraph;
    public var graphSprite:OFLSprite;

    public var comboText:FlxText;
    public var contText:FlxText;
    public var settingsText:FlxText;

    public var music:FlxSound;
    var rewardSound:FlxSound;

    public var graphData:BitmapData;

    public var ranking:String;
    public var accuracy:String;

    var rewardSpamPrevention:Bool = false;
    var reward:FlxSprite;

	override function create()
	{	
        darkenScreen = new FlxSprite(0,0).makeGraphic(FlxG.width,FlxG.height,FlxColor.BLACK);
        darkenScreen.scrollFactor.set();
        add(darkenScreen);

        if (!PlayState.instance.inResults) 
        {
            FlxG.sound.play(Paths.sound('ResultsScreenAppear'));
            //make this into a case statement
            //done!
            if (PlayState.instance.accuracy > 20)
            {
            //Make the player feel bad by playing no music if the accuracy is low as hell LMAO
                switch (StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase())
                {
                    case 'technical-difficulties':
                        Conductor.changeBPM(130);
                        music = new FlxSound().loadEmbedded(Paths.music('songending/Technical_Difficulties'), true, true);
                        music.volume = 0.5;
                        music.play();
                    default:
                        Conductor.changeBPM(80);
                        music = new FlxSound().loadEmbedded(Paths.music('songending/resultScreen'), true, true);
                        music.volume = 0.3;
                        music.play(false, FlxG.random.int(0, Std.int(music.length / 2)));
                }
            }
            else
                music = new FlxSound();
            FlxG.sound.list.add(music);
        }

        darkenScreen.alpha = 0;

        text = new FlxText(20,-55,0,"Song Cleared!");
        text.setFormat(Paths.font("playtime.ttf"), 45);
        text.antialiasing = true;
        text.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
        text.color = FlxColor.WHITE;
        text.scrollFactor.set();
        add(text);

        var score = PlayState.instance.songScore;
        if (PlayState.isStoryMode)
            score = PlayState.campaignScore;
        
        if (!PlayStateChangeables.botPlay && !PlayState.toggledPracticeMode)
        {
            trace("cheats are off");
            if (PlayState.storyWeek > 0)
                text.text = "Song Cleared!";
            else
                text.text = "End of Tutorial!";
        }
        else
        {
            trace("cheats are on");
            if (PlayState.storyWeek > 0)
                text.text = "Practice Run Finished\n(Note: Try playing without cheats!)\n";
            else
                text.text = "End of Tutorial\n(Note: Try playing without cheats!)\n";
        }

        comboText = new FlxText(40,-75,0,'Judgements:\nSicks - ${PlayState.sicks}\nGoods - ${PlayState.goods}\nBads - ${PlayState.bads}\n\nCombo Breaks: ${(PlayState.isStoryMode ? PlayState.campaignMisses : PlayState.misses)}\nHighest Combo: ${PlayState.highestCombo + 1}\nScore: ${(PlayState.isStoryMode ? PlayState.campaignScore : PlayState.instance.songScore)}\nAccuracy: ${(PlayState.isStoryMode ? HelperFunctions.truncateFloat(PlayState.campaignAccuracy,2) : HelperFunctions.truncateFloat(PlayState.instance.accuracy,2))}%\n\n${(PlayState.isStoryMode ? Ratings.GenerateLetterRank(PlayState.campaignAccuracy) : Ratings.GenerateLetterRank(PlayState.instance.accuracy))}\n\nF1 - Claim prize\nF2 - Replay song
        ');
        comboText.setFormat(Paths.font("playtime.ttf"), 30);
        comboText.antialiasing = true;
        comboText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
        comboText.color = FlxColor.WHITE;
        comboText.scrollFactor.set();
        add(comboText);

        contText = new FlxText(FlxG.width - 475, FlxG.height + 20, 0, 'Press [${KeyBinds.gamepad ? 'A' : 'ENTER'}] to continue.');
        contText.size = 28;
        contText.antialiasing = true;
        contText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
        contText.color = FlxColor.YELLOW;
        contText.scrollFactor.set();
        add(contText);

        anotherdarkenScreen = new FlxSprite(FlxG.width - 500,45).makeGraphic(450,240,FlxColor.BLACK);
        anotherdarkenScreen.scrollFactor.set();
        anotherdarkenScreen.alpha = 0;
        add(anotherdarkenScreen);
        
        graph = new HitGraph(FlxG.width - 500,45,495,240);
        graph.alpha = 0;

        graphSprite = new OFLSprite(FlxG.width - 510,45,460,240,graph);

        graphSprite.scrollFactor.set();
        graphSprite.alpha = 0;
        
        add(graphSprite);


        var sicks = HelperFunctions.truncateFloat(PlayState.sicks / PlayState.goods,1);
        var goods = HelperFunctions.truncateFloat(PlayState.goods / PlayState.bads,1);

        if (sicks == Math.POSITIVE_INFINITY)
            sicks = 0;
        if (goods == Math.POSITIVE_INFINITY)
            goods = 0;

        var mean:Float = 0;


        for (i in 0...PlayState.rep.replay.songNotes.length)
        {
            // 0 = time
            // 1 = length
            // 2 = type
            // 3 = diff
            var obj = PlayState.rep.replay.songNotes[i];
            // judgement
            var obj2 = PlayState.rep.replay.songJudgements[i];

            var obj3 = obj[0];

            var diff = obj[3];
            var judge = obj2;
            if (diff != (166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166))
                mean += diff;
            if (obj[1] != -1)
                graph.addToHistory(diff, judge, obj3);
        }

        graph.update();

        mean = HelperFunctions.truncateFloat(mean / PlayState.rep.replay.songNotes.length,2);

        settingsText = new FlxText(5, FlxG.height + 75, 0,'SF: ${PlayState.rep.replay.sf} | Ratio (SA/GA): ${Math.round(sicks)}:1 ${Math.round(goods)}:1 | Mean: ${mean}ms | Played on ${PlayState.SONG.song} ${CoolUtil.difficultyFromInt(PlayState.storyDifficulty).toUpperCase()}');
        settingsText.setFormat(Paths.font("vcr.ttf"), 16);
        settingsText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,2,1);
        settingsText.color = FlxColor.WHITE;
        settingsText.scrollFactor.set();
        add(settingsText);


        FlxTween.tween(darkenScreen, {alpha: 0.5},0.5,{type: ONESHOT});
        FlxTween.tween(text, {y:20},0.5,{type: ONESHOT, ease: FlxEase.expoOut});
        FlxTween.tween(comboText, {y:145},0.5,{type: ONESHOT, ease: FlxEase.expoOut});
        FlxTween.tween(contText, {y:FlxG.height - 45},0.5,{type: ONESHOT, ease: FlxEase.expoOut});
        FlxTween.tween(settingsText, {y:FlxG.height - 35},0.5,{type: ONESHOT, ease: FlxEase.expoOut});
        FlxTween.tween(anotherdarkenScreen, {alpha: 0.6},0.5, {onUpdate: function(tween:FlxTween) {
            graph.alpha = FlxMath.lerp(0,1,tween.percent);
            graphSprite.alpha = FlxMath.lerp(0,1,tween.percent);
        }});

        cameras = [PlayState.instance.camHUD];

		super.create();

        #if windows
		if (FlxG.save.data.showPresence)
			DiscordClient.changePresence("In the Results Screen", null, null, true);
		#end
	}


    var frames = 0;

	override function update(elapsed:Float)
	{
        if (music != null && music.volume < 0.5)
		    music.volume += 0.01 * elapsed;

        // keybinds

        if (PlayerSettings.player1.controls.ACCEPT)
        {   

			PlayState.startTime = 0;
            PlayState.deaths = 0;
			/*if (PlayState.instance.useVideo)
			{
				GlobalVideo.get().stop();
				PlayState.instance.remove(PlayState.instance.videoSprite);
				PlayState.instance.removedVideo = true;
			}*/
            
            PlayState.rep = null;

			var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");

			#if !switch
			Highscore.saveScore(songHighscore, Math.round(PlayState.instance.songScore), PlayState.storyDifficulty);
			Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(PlayState.instance.accuracy),PlayState.storyDifficulty);
			#end

            PlayState.instance.resultsPresent = false;
            PlayState.hasReset = false;

            PlayState.cannotDie = false;
            PlayState.toggledPracticeMode = false;
            PlayState.campaignMisses = 0;
            PlayState.campaignAccuracy = 0.00;
            PlayState.campAccDivider = 0;

            music.fadeOut(0.3);

            trace("Deleting Temp Shit");
            CleanUpAfterYoself('assets/temp');

            FlxG.cameras.fade(FlxColor.BLACK, 0.4, false, function()
            {
                //causes crash LMAO
                //FlxG.bitmap.clearCache();
                if (PlayState.isStoryMode)
                    FlxG.switchState(new StoryMenuState());
                else
                    FlxG.switchState(new FreeplayState());
            });
        }

        if (FlxG.keys.justPressed.F1 && !rewardSpamPrevention)
        {
            rewardSpamPrevention = true;
            rewardSound = FlxG.sound.play(Paths.soundRandom('resultScreenPrize/rewardSound_', 0, 15), 0.8);
            switch (FlxG.random.int(0, 2))
            {
                case 0:
                    reward = new FlxSprite(-650, 590).loadGraphic(Paths.image('prizes/prizeText_0'));
                case 1:
                    reward = new FlxSprite(-650, 590).loadGraphic(Paths.image('prizes/prizeText_1'));
                case 2:
                    reward = new FlxSprite(-650, 590).loadGraphic(Paths.image('prizes/prizeText_2'));
            }
            reward.y = 200;
            reward.scrollFactor.set();
            reward.updateHitbox();
            reward.screenCenter(X);
            /*if(FlxG.save.data.antialiasing)
            {
                reward.antialiasing = true;
            }*/
            add(reward);
            FlxTween.tween(reward, {y: reward.y + 5, alpha: 0}, 0.5, 
            {
                ease: FlxEase.cubeInOut,
                onComplete: function(twn:FlxTween)
                {
                    reward.destroy();
                    rewardSpamPrevention = false;
                }
            });
        }

        if (FlxG.keys.justPressed.F2)
        {
            PlayState.instance.resultsPresent = false;
            PlayState.deaths = 0;
            PlayState.hasReset = true;
            PlayState.startTime = 0;
            /*if (PlayState.instance.useVideo)
            {
                GlobalVideo.get().stop();
                PlayState.instance.remove(PlayState.instance.videoSprite);
                PlayState.instance.removedVideo = true;
            }*/
            //Testing if this doesn't increase RAM
            PlayState.instance.clear();
            FlxG.resetState();
        }

		super.update(elapsed);
		
	}

	override function destroy()
	{
		music.destroy();
		super.destroy();
	}

    //Clears the temp folder
	private function CleanUpAfterYoself(path:String): Void
    {
        if (sys.FileSystem.exists(path) && sys.FileSystem.isDirectory(path))
        {
            var entries = sys.FileSystem.readDirectory(path);
            for (entry in entries) 
            {
                if (sys.FileSystem.isDirectory(path + '/' + entry)) 
                {
                    trace("Deleting " + path + '/' + entry);
                    CleanUpAfterYoself(path + '/' + entry);
                    sys.FileSystem.deleteDirectory(path + '/' + entry);
                } 
                else if (entry != "IMPORTANT.txt")
                {
                    trace("Deleting " + path + '/' + entry);
                    sys.FileSystem.deleteFile(path + '/' + entry);
                }
            }
        }
        trace("Cleaned Up after mahself");
    }
}
