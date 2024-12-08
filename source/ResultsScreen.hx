package;
import haxe.Exception;
#if sys
import sys.FileSystem;
import sys.io.File;
#end
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import flixel.util.FlxAxes;
import flixel.util.FlxTimer;
import flixel.FlxSubState;
import Options.Option;
import flixel.input.FlxInput;
import flixel.input.keyboard.FlxKey;
//import flixel.FlxG;
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

using StringTools;

class ResultsScreen extends MusicBeatSubstate
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

    var fumbled:Bool = false;

    var startBeatShit:Bool;
    var songPlayed:String = '';
    var camZoomValues:Array<Float> = [0, 0];

    var blurTweenGoBrr:FlxTween = null;
    var funnyBlur:Float;

	override function create()
	{
        if (blurTweenGoBrr != null)
			blurTweenGoBrr.cancel();

        PlayState.instance.camGame.filtersEnabled = true;
		blurTweenGoBrr = FlxTween.tween(this, {funnyBlur: 5}, 1.5, {ease: FlxEase.cubeOut,
			onUpdate: function(twn:FlxTween) 
			{
				PlayState.instance.pauseBlurLol.blurX = funnyBlur;
				PlayState.instance.pauseBlurLol.blurY = funnyBlur;
			},
			
			onComplete: function(twn:FlxTween) 
			{
				blurTweenGoBrr = null;
			}
		});

        var guide:FlxSprite = new FlxSprite().loadGraphic(Paths.image('resultsScreen/guide'));
        guide.antialiasing = FlxG.save.data.antialiasing;
        guide.alpha = 0.6;
        guide.screenCenter();
        add(guide);

        songPlayed = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();

        darkenScreen = new FlxSprite(0,0).makeGraphic(FlxG.width,FlxG.height,FlxColor.BLACK);
        darkenScreen.scrollFactor.set();
        add(darkenScreen);

        music = new FlxSound();

        FlxG.sound.play(Paths.sound('ResultsScreenAppear'));
        if (!PlayState.isStoryMode || PlayState.storyWeek == 0)
        {
            if (PlayState.instance.accuracy > 50)
            {
                switch (songPlayed)
                {
                    case 'technical-difficulties':
                        Conductor.changeBPM(130);
                        music.loadEmbedded(Paths.music('song_end/technical-difficulties_results'), true, true);
                        music.volume = 0.5;
                        music.play();
                    default:
                        Conductor.changeBPM(80);
                        music.loadEmbedded(Paths.music('song_end/resultScreen'), true, true);
                        music.volume = 0.3;
                        music.play(false, FlxG.random.int(0, Std.int(music.length / 2)));
                }
            }
            else
            {
                //Make the player feel bad by playing sad music if the accuracy is low as hell LMAO
                Conductor.changeBPM(105);
                music.loadEmbedded(Paths.music('song_end/resultsScreen_failed'), true, true);
                music.volume = 0.1;
                music.play(false);
                fumbled = true;
            }
            music.fadeIn(5, 0.1, music.volume);
            FlxG.sound.list.add(music);
        }

        darkenScreen.alpha = 0;

        text = new FlxText(10, -55,0,"Song Cleared!");
        text.setFormat(Paths.font("playtime.ttf"), 45);
        text.antialiasing = true;
        text.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
        text.color = FlxColor.WHITE;
        text.scrollFactor.set();
        add(text);

        var score = PlayState.instance.songScore;
        if (PlayState.isStoryMode)
            score = PlayState.campaignScore;

        var smolTxtAdjuster:Float = 0;
        
        if (!PlayStateChangeables.botPlay && !PlayState.toggledPracticeMode)
        {
            trace("cheats are off");

            if (PlayState.storyWeek > 0)
                text.text = "Song Cleared!";
            else
                text.text = "End of Tutorial!";

            if (PauseSubState.skippedSong)
                text.text += "\n(Play through all songs for a saved rank!)";
        }
        else
        {
            trace("cheats are on");
            if (PlayState.storyWeek > 0)
                text.text = "Practice Run Finished\n(Note: Try playing without cheats!)";
            else
                text.text = "End of Tutorial\n(Note: Try playing without cheats!)";
            smolTxtAdjuster = 20;
        }
        text.updateHitbox();

        comboText = new FlxText(text.x + 20, text.y + text.height, 0,'Judgements:\nSicks - ${(!PlayState.isStoryMode ? PlayState.instance.sicks : PlayState.campaignSicks)}\nGoods - ${(!PlayState.isStoryMode ? PlayState.instance.goods : PlayState.campaignGoods)}\nBads - ${(!PlayState.isStoryMode ? PlayState.instance.bads : PlayState.campaignBads)}\nSlips - ${(PlayState.isStoryMode ? PlayState.campaignMisses : PlayState.instance.misses)}\n\nTotal Fails: ${PlayState.campaignDeaths}\nHighest Combo: ${PlayState.highestCombo + 1}\nScore: ${(PlayState.isStoryMode ? PlayState.campaignScore : PlayState.instance.songScore)}\nAccuracy: ${(PlayState.isStoryMode ? HelperFunctions.truncateFloat(PlayState.campaignAccuracy,2) : HelperFunctions.truncateFloat(PlayState.instance.accuracy,2))}%\n\nRank: ${(PlayState.isStoryMode ? Ratings.GenerateLetterRank(PlayState.campaignAccuracy, PlayState.instance.keeledOver) : Ratings.GenerateLetterRank(PlayState.instance.accuracy, PlayState.instance.keeledOver))}' + (PauseSubState.skippedSong ? '*' : '') + (!PlayState.isStoryMode ? '\n\nF1 - Claim prize\nF2 - Replay song' : ''));
        comboText.setFormat(Paths.font("playtime.ttf"), 30);
        comboText.antialiasing = true;
        comboText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
        comboText.color = FlxColor.WHITE;
        comboText.scrollFactor.set();
        add(comboText);

        anotherdarkenScreen = new FlxSprite(FlxG.width - 550, 45).makeGraphic(500, 300,FlxColor.BLACK);
        anotherdarkenScreen.scrollFactor.set();
        anotherdarkenScreen.alpha = 0;
        add(anotherdarkenScreen);
        
        graph = new HitGraph(anotherdarkenScreen.x, 45, 500, 300);
        graph.alpha = 0;

        graphSprite = new OFLSprite(anotherdarkenScreen.x, 45, 500, 300, graph);
        graphSprite.scrollFactor.set();
        graphSprite.alpha = 0;
        add(graphSprite);




        var sicks = HelperFunctions.truncateFloat((!PlayState.isStoryMode ? PlayState.instance.sicks : PlayState.campaignSicks) / (!PlayState.isStoryMode ? PlayState.instance.goods : PlayState.campaignGoods),1);
        var goods = HelperFunctions.truncateFloat((!PlayState.isStoryMode ? PlayState.instance.goods : PlayState.campaignGoods) / (!PlayState.isStoryMode ? PlayState.instance.bads : PlayState.campaignBads), 1);

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

        settingsText = new FlxText(3, FlxG.height, 0,'SF: ${PlayState.rep.replay.sf} | Ratio (SA/GA): ${Math.round(sicks)}:1 ${Math.round(goods)}:1 | Mean: ${mean}ms | Played on ${(!PlayState.isStoryMode ? PlayState.SONG.song : "Campaign [Part " + PlayState.storyWeek + "]")} ${CoolUtil.difficultyFromInt(PlayState.storyDifficulty).toUpperCase()}');
        settingsText.setFormat(Paths.font("vcr.ttf"), 16);
        settingsText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,2,1);
        settingsText.color = FlxColor.WHITE;
        settingsText.updateHitbox();
        settingsText.scrollFactor.set();
        add(settingsText);

        contText = new FlxText(FlxG.width - 470, FlxG.height + 20, 0, 'Press [${KeyBinds.gamepad ? 'A' : 'ENTER'}] to continue.');
        contText.size = 28;
        contText.antialiasing = true;
        contText.setBorderStyle(FlxTextBorderStyle.OUTLINE,FlxColor.BLACK,4,1);
        contText.color = FlxColor.YELLOW;
        contText.scrollFactor.set();
        add(contText);

        FlxTween.tween(darkenScreen, {alpha: 0.5}, 1, {type: ONESHOT, ease: FlxEase.expoOut});
        FlxTween.tween(text, {y: 10}, 0.5,{type: ONESHOT, ease: FlxEase.expoOut});
        FlxTween.tween(comboText, {y: 10 + text.height + 25 - smolTxtAdjuster}, 0.6, {type: ONESHOT, ease: FlxEase.expoOut});
        FlxTween.tween(contText, {y: FlxG.height - contText.height - 10}, 0.7, {type: ONESHOT, ease: FlxEase.expoOut});
        FlxTween.tween(settingsText, {y: FlxG.height - settingsText.height - 3}, 0.55, {type: ONESHOT, ease: FlxEase.expoOut});
        FlxTween.tween(anotherdarkenScreen, {alpha: 0.7}, 0.5, {ease: FlxEase.smootherStepOut, onUpdate: function(tween:FlxTween) {
            graph.alpha = FlxMath.lerp(0, 1, tween.percent);
            graphSprite.alpha = FlxMath.lerp(0, 1, tween.percent);
        }});

        cameras = [PlayState.instance.camEXT];
        camZoomValues = [PlayState.instance.camGame.zoom, PlayState.instance.camHUD.zoom];

		super.create();

        #if windows
		if (FlxG.save.data.showPresence)
        {
            var funnyTextLol:String = (!PlayState.isStoryMode ? PlayState.SONG.song : "Campaign [Part " + PlayState.storyWeek + "]") + ' - Score: ' + (PlayState.isStoryMode ? PlayState.campaignScore : PlayState.instance.songScore) + " [" + (PlayState.isStoryMode ? Ratings.GenerateLetterRank(PlayState.campaignAccuracy, PlayState.instance.keeledOver) : Ratings.GenerateLetterRank(PlayState.instance.accuracy, PlayState.instance.keeledOver)) + ' (' + (PlayState.isStoryMode ? HelperFunctions.truncateFloat(PlayState.campaignAccuracy, 2) : HelperFunctions.truncateFloat(PlayState.instance.accuracy,2)) + '%)]';
			DiscordClient.changePresence("The Results!", funnyTextLol);
        }
		#end

        startBeatShit = true;
	}

    var frames = 0;

	override function update(elapsed:Float)
	{
        if (music != null && music.playing)
        {
            if (!fumbled && music.volume < 0.5)
                music.volume += 0.01 * elapsed;
            else if (fumbled && music.volume < 0.45)
                music.volume += 0.005 * elapsed;

            Conductor.songPosition = music.time;
        }

        cameras[0].zoom = FlxMath.lerp(1, cameras[0].zoom, CoolUtil.boundTo(1 - (elapsed * 2.5 * (Conductor.bpm * 0.01)), 0, 1));
        PlayState.instance.camGame.zoom = FlxMath.lerp(camZoomValues[0], PlayState.instance.camGame.zoom, CoolUtil.boundTo(1 - (elapsed * 2.5 * (Conductor.bpm * 0.01)), 0, 1));
        PlayState.instance.camHUD.zoom = FlxMath.lerp(camZoomValues[1], PlayState.instance.camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 2.5 * (Conductor.bpm * 0.01)), 0, 1));

        // keybinds

        if (PlayerSettings.player1.controls.ACCEPT || FlxG.mouse.justPressed)
        {   
            if (music != null && music.playing)
                FlxTween.tween(music, {pitch: 1.5}, 0.15, {ease: FlxEase.quartInOut, type: ONESHOT, onComplete: function(twn:FlxTween){music.tapeStop(0.35, 0);}});

            trace("Deleting Temp Shit");
            CleanUpAfterYoself('assets/temp');

            FlxG.cameras.fade(FlxColor.BLACK, 0.5, false, function()
            {
                //causes crash LMAO
                //FlxG.bitmap.clearCache();
                if (PlayState.isStoryMode)
                    FlxG.switchState(new StoryMenuState());
                else
                    FlxG.switchState(new FreeplayState());
                PlayState.instance.clear();
            });
        }

        if ((FlxG.keys.justPressed.F1 || FlxG.mouse.justPressedMiddle) && !rewardSpamPrevention && !PlayState.isStoryMode)
        {
            rewardSpamPrevention = true;
            if (rewardSound != null && rewardSound.playing)
                rewardSound.stop();
            rewardSound = FlxG.sound.play(Paths.soundRandom('resultScreenPrize/rewardSound_', 0, 15), 0.8);
            rewardSound.pitch = FlxG.random.float(0.9, 1.1);
            rewardSound.autoDestroy = true;
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

        if ((FlxG.keys.justPressed.F2 || FlxG.mouse.justPressedRight) && !PlayState.isStoryMode)
        {
            PlayState.instance.nextStateIsPlayState = true;
            FlxG.resetState();
        }

		super.update(elapsed);
		
	}

    var camBopAmt:Float = 0;

    override function beatHit()
    {
        super.beatHit();

        if (FlxG.save.data.camzoom && startBeatShit)
            if (curBeat % 4 == 0)
            {
                if (music != null && music.playing)
                    camBopAmt = 0.01 * (!fumbled ? music.volume / 0.5 : music.volume / 0.3);
                cameras[0].zoom += camBopAmt;
                PlayState.instance.camGame.zoom += camBopAmt;
                PlayState.instance.camHUD.zoom += camBopAmt;
            }
    }

	override function destroy()
	{
        if (music != null && music.playing)
		    music.destroy();
		super.destroy();
	}

    //Clears the temp folder
	public static function CleanUpAfterYoself(path:String):Void
    {
        if (sys.FileSystem.exists(path) && sys.FileSystem.isDirectory(path))
        {
            var entries = sys.FileSystem.readDirectory(path);
            var pathPlusEntry:String = '' ;
            for (entry in entries) 
            {
                pathPlusEntry = path + '/' + entry;
                if (sys.FileSystem.isDirectory(pathPlusEntry) && entry != "IMPORTANT.txt")
                {
                    if (entry.endsWith('.tempSongData'))
                    {
                        trace("Deleting " + pathPlusEntry);
                        sys.FileSystem.deleteFile(pathPlusEntry);
                    }
                }
            }
        }
        trace("Cleaned Up after mahself");
    }
}
