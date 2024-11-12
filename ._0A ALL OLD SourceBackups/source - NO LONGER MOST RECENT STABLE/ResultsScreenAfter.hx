package;
import haxe.Exception;
#if sys
import smTools.SMFile;
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
import io.newgrounds.NG;
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

class ResultsScreenAfter extends FlxSubState
{
//Yes this is a duplicate of ResultsScreen.Hx
//...Yes this is bad
//....
//..........
//shusuhshsuhshhhhhh hush please ive tried everything this is the only way to not make the game crash after a video

    public var darkenScreen:FlxSprite;
    public var text:FlxText;

    public var anotherdarkenScreen:FlxSprite;
    public var graph:HitGraph;
    public var graphSprite:OFLSprite;

    public var comboText:FlxText;
    public var settingsText:FlxText;

    public var music:FlxSound;

    public var graphData:BitmapData;

    public var ranking:String;
    public var accuracy:String;

    var rewardSpamPrevention:Bool = false;

	override function create()
	{	
        #if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Results Screen", null);
		#end

        darkenScreen = new FlxSprite(0,0).makeGraphic(FlxG.width,FlxG.height,FlxColor.BLACK);
        darkenScreen.scrollFactor.set();
        add(darkenScreen);

        if (!PlayState.inResults) 
        {
            if (Credits.finishedCredits)
            {
                FlxG.sound.play(Paths.sound('ResultsScreenFade'));
                music = new FlxSound().loadEmbedded(Paths.music('songending/literalSilence'), true, true);
                music.volume = 1;
                music.play();
                FlxG.sound.list.add(music);
            }
            else if (PlayState.isStoryMode)
            {
                FlxG.sound.play(Paths.sound('ResultsScreenAppear'));
                //Week-dependent results screen song music
                switch (PlayState.storyWeek)
                {
                    case 1:
                        music = new FlxSound().loadEmbedded(Paths.music('songending/literalSilence'), true, true);
                    case 2:
                        music = new FlxSound().loadEmbedded(Paths.music('songending/literalSilence'), true, true);
                    default:
                        music = new FlxSound().loadEmbedded(Paths.music('songending/resultScreen'), true, true);
                }
                music.volume = 1;
                music.play();
                FlxG.sound.list.add(music);
            }
            else
            {
                FlxG.sound.play(Paths.sound('ResultsScreenAppear'));
                music = new FlxSound().loadEmbedded(Paths.music('songending/resultScreen'), true, true);
                music.volume = 0.3;
                music.play(false, FlxG.random.int(0, Std.int(music.length / 2)));
                FlxG.sound.list.add(music);
            }
        }

        darkenScreen.alpha = 0;

        text = new FlxText(20,-55,0,"Chapter Cleared!");
        text.setFormat(Paths.font("playtime.ttf"), 36);
        text.antialiasing = true;
        text.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
        text.color = FlxColor.WHITE;
        text.scrollFactor.set();
        add(text);

        var score = PlayState.campaignScore;

        if (!PlayState.loadRep && !(PlayStateChangeables.botPlay || PlayState.toggledPracticeMode))
        {
            if (PlayState.storyWeek > 0)
                text.text = "End of Part " + PlayState.storyWeek + "!";
            else
                text.text = "End of Tutorial!";
        }
            if (Credits.finishedCredits)
        {
            text.text = "The End!";
        }

        comboText = new FlxText(20,-75,0,'Judgements:\nSicks - ${PlayState.sicks}\nGoods - ${PlayState.goods}\nBads - ${PlayState.bads}\n\nCombo Breaks: ${(PlayState.isStoryMode ? PlayState.campaignMisses : PlayState.misses)}\nHighest Combo: ${PlayState.highestCombo + 1}\nScore: ${PlayState.instance.songScore}\nAccuracy: ${HelperFunctions.truncateFloat(PlayState.instance.accuracy,2)}%\n\n${Highscore.getWeekCombo(PlayState.storyWeek, PlayState.storyDifficulty)}\n\n${!PlayState.loadRep ? "\nPress ENTER to exit the Results Screen" : ""}
        ');
        comboText.setFormat(Paths.font("playtime.ttf"), 30);
        comboText.antialiasing = true;
        comboText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
        comboText.color = FlxColor.WHITE;
        comboText.scrollFactor.set();
        add(comboText);

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

        settingsText = new FlxText(20,FlxG.height + 50,0,'SF: ${PlayState.rep.replay.sf} | Ratio (SA/GA): ${Math.round(sicks)}:1 ${Math.round(goods)}:1 | Mean: ${mean}ms | Played on ${PlayState.SONG.song} ${CoolUtil.difficultyFromInt(PlayState.storyDifficulty).toUpperCase()}');
        settingsText.setFormat(Paths.font("vcr.ttf"), 16);
        settingsText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,2,1);
        settingsText.color = FlxColor.WHITE;
        settingsText.scrollFactor.set();
        add(settingsText);


        FlxTween.tween(darkenScreen, {alpha: 0.5},0.5);
        FlxTween.tween(text, {y:20},0.5,{ease: FlxEase.expoInOut});
        FlxTween.tween(comboText, {y:145},0.5,{ease: FlxEase.expoInOut});
        FlxTween.tween(settingsText, {y:FlxG.height - 35},0.5,{ease: FlxEase.expoInOut});
        FlxTween.tween(anotherdarkenScreen, {alpha: 0.6},0.5, {onUpdate: function(tween:FlxTween) {
            graph.alpha = FlxMath.lerp(0,1,tween.percent);
            graphSprite.alpha = FlxMath.lerp(0,1,tween.percent);
        }});

        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		super.create();
	}


    var frames = 0;

	override function update(elapsed:Float)
	{
        if (music != null && music.volume < 0.5)
		    music.volume += 0.01 * elapsed;

        // keybinds

        if (PlayerSettings.player1.controls.ACCEPT)
        {
            music.fadeOut(0.3);
            
			PlayState.startTime = 0;
            PlayState.deaths = 0;
			/*if (PlayState.instance.useVideo)
			{
				GlobalVideo.get().stop();
				PlayState.instance.remove(PlayState.instance.videoSprite);
				PlayState.instance.removedVideo = true;
			}*/
			if(PlayState.loadRep)
			{
				FlxG.save.data.botplay = false;
				FlxG.save.data.scrollSpeed = 1;
				FlxG.save.data.downscroll = false;
			}

            PlayState.loadRep = false;
            PlayState.rep = null;

			var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");
			switch (songHighscore) {
				case 'Philly-Nice': songHighscore = 'Philly';
                case 'Kid-with-a-Gun': songHighscore = 'KidWithAGun';
			}

			#if !switch
			Highscore.saveScore(songHighscore, Math.round(PlayState.instance.songScore), PlayState.storyDifficulty);
			Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(PlayState.instance.accuracy),PlayState.storyDifficulty);
			#end

			#if windows
			if (PlayState.luaModchart != null)
			{
				PlayState.luaModchart.die();
				PlayState.luaModchart = null;
			}
			#end

            PlayState.resultsPresent = false;
            PlayState.hasReset = false;

            PlayState.cannotDie = false;
            PlayState.toggledPracticeMode = false;
            
            FlxG.camera.fade(FlxColor.BLACK, 0.4, false, function()
            {
                FlxG.bitmap.clearCache();
                if (PlayState.isStoryMode && !Credits.finishedCredits)
                {
                    Conductor.changeBPM(102);
                    FlxG.switchState(new StoryMenuState());
                }
                else
                {
                    FlxG.sound.play(Paths.sound('returnMenu'));
                    new FlxTimer().start(0.5, function(tmr:FlxTimer)
                    {
                        Conductor.changeBPM(0);
                        Credits.finishedCredits = false;
                        FlxG.switchState(new StoryMenuState());
                    });
                }
            }, true);
        }

		super.update(elapsed);
		
	}
}
