package;

/*
IMPORTANT NOTES!!!

FIX LE BUGS:
[/]   URGENT!!! Make the precaching shit for this and funnysplash into an AsyncLoop (use the the the the caching.hx as example)
[ ]   Add loading bars to asynchlloops? hehehehe hehehehe ehhehe
[ ]	  URGENT!!! Redo the allSongsMix shit from SCRATCH!!!!! (export stems of songs then mix/master everything)
[/]   FIX THE HECKING TUTORIAL TWEENS
[/]   FIX THE LOADONG THING NOT SJOWOMG (OFFSETS)
[/]   GOKSBOSO FIX THE FUCKING STARTING COUNDTOWN SHIT IM PISSED OFF FJIDSGBSJ
[/]   Fix the enemy miss shit
[/]   Crashing when endsong() happens [Hint: It's probably because of the miscs shit ya just added! (YEP!)]
[/]   Crashing when finale loops (Fixed once, but broke again in 3/31/2022. I assume it's because of the caching again-? maybe-?)
[/]   Fix finale not playing the chart again (figure out what makes the charts play)
[/]	  Finale not playing notes after it loops
[/]   Fix Finale making notes too tiiiny (WHAT)
[/]   Make Finale be able to infinitely loop without crashes and shit
[/]   Retaliation crash when skipping song intro and pausing. (As of 12:29 4/10/2022, you can now skip the intro.) (Fixed for real. Crash because of opensubstate expecting the scountdown timer without it existing (As of 14:47 4/12/2022)
[/]	  Crashing when loading a song after loading finale (Idk what causes this as of 03/29/2022) (APPARENTLY IT'S CAUSE OF THE ANTI RECACHING THING, BETTER MAKE A NEW METHOD BY DOING A NULL FLXSOUND TO AVOID MEMORY LEAK! as of 3/31/2022 Added a few minutes later!!)
[/]   BRUH FIX LE LAG IN STORY MODE AWKWARD PAUSES BRUH CMONNN PLEASE FIXE THE LAG NOW PLEASE
[/]   Optimise ResyncVocals?????? (Not the main problem)
[/]   Optimise POPUPNOTE?!?!?!?!?!?!!!!?!?!??!??!?! (The main problem) (i tried-)
[/]   Fix Chance of a softlock happening because of resyncvocals (probs that resyncvocaltimer shit, get rid of that disgusting lines of code!!11!)
[/]   Fix Resync Vocals Appearing at inopportune moments
[/]   Fix Missing CamPan in Normal Up and Beyond
[ ]   Redo the disgusting fuckin option menu lmao
[/]   Fix lagspike when missing notes (or altleast compensate or sum shit)
[/]   Kid with a gun not previewing and saving score
[/]   Change haxeflixel mute/error beep into something less ear-piercing
[ ]   ADD NOTEHITSOUNDTYPES (default, bubble, osu, etc)
[ ]   Add starting animation for guy in tech. difficulties of him putting away his phone (cutscene continuation)
[/]   Fix Practice Mode Not Working (lmao)
[/]   Fix Practice Mode Text
[/]   UR NOTES ARE SHIT! Compare with Kade 1.6 Code for assurance (Huh, I compared it and nothing seems to be amiss??)
[/]   Update note hit sounds to be 4 different variables (Sick, Good, Bad, Sh*t) so that you can preload them properly
[/]   Add song subtitles to Optimized mode
[ ]   Add video cutscenes to Optimised mode
[ ]   Add a setting based on optimsed mode that just limits the visible stuff going on (check bianca's suggestions)
[/]   Redo popupscore sprite
[/]   Update gameplaycustomizestate to change based on if optimized mode/midscroll is on
[/]   Add a "night mode" that turns on everytime the clock detects it's late
[/]   Lower lowHPHeartBeat volume
[X]   Make lowHPHeartBeat volume adapt based on the song's amplitude
[/]   Increase lowHPHeartBeat volume by 1 or 2 db
[/]   Make it so that the adaptiveMus volume is at 100% when hp is showing the cross eyed icons
[/]   Fix "shit" sustain notes lagging (probably because it calculates both the parent and the children at the same time)
[ ]   Make both vignettes (for stages that use them) and Strumlines Darker, Yet Darker...
*/

import lime.media.openal.AL;
#if sys
import sys.io.File;
#end
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import Replay.Ana;
import Replay.Analysis;
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import openfl.Lib;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.effects.FlxFlicker;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.FlxSoundGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import WiggleEffect.WiggleEffectType;
import lime.app.Application;
import flixel.util.FlxAxes;

#if windows
import Discord.DiscordClient;
#end
#if windows
import Sys;
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState;
	public var initialized:Bool = false; //crash prevention

	public static var curStage:String = '';
	public static var stageSuffix:String = '';
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var playlistLength:Int = 0;
	public static var storyProgress:Int = 0;
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var weekScore:Int = 0;
	public var slips:Int = 0;
	public var bads:Int = 0;
	public var goods:Int = 0;
	public var sicks:Int = 0;

	// Less laggy controls
	private var keysArray:Array<Dynamic>;
	private var controlArray:Array<String>;

	var songPosGroup:FlxSpriteGroup = null;
	var songPosBG:FlxSprite;
	var songPosBar:FlxBar;
	var songPosDeathIndicator:FlxSprite;
	var songPosClock:FlxSprite;
	var songDurationTxt:FlxText;
	private var songPositionBar:Float = 0;
	public var songLength:Float = 0;

	public var inResults:Bool = false;
	public var resultsPresent:Bool = false;
	private var skippedShit:Bool = false;
	public static var didPauseSkippin:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	var songNameTXT:FlxText;

	#if windows
	// Discord RPC variables
	var storyDifficultyText:String = "";
	//var iconRPC:String = "";
	var detailsText:String = "";
	#end

	public var musicGroup:FlxSoundGroup;
	var hitSFXGroup:FlxSoundGroup;
	var susHitSFXGroup:FlxSoundGroup;
	var specilNoteSFXGroup:FlxSoundGroup;
	//for the adaptive Music
	public var instLowHP:FlxSound;
	//For the FNF voices
	public var vocals:FlxSound;
	//For things such as Playing With Fire Guns and other shits that I am yet to do
	public var miscs:FlxSound;
	//ADAPTIVE MUSIC AAAAA FUKC
	private var drums = new FlxSound();
	private var taiko = new FlxSound();
	private var choir = new FlxSound();
	private var hats = new FlxSound();
	private var adders = new FlxSound();
	private var slayer = new FlxSound();
	private var retalHats = new FlxSound();
	private var bells = new FlxSound();
	private var pads = new FlxSound();
	private var danger = new FlxSound();
	public var pauseMusicName:String = "";//Here cause preloading LMAO
	//FINALE BATTLE SH THIT
	private var dangerLevel:Float = 0;
	var enemyHealth:Float = 100;

	public var dad:Character;
	var dadSwaperoo:String = "";
	public var gf:Character;
	public var boyfriend:Boyfriend;

	//idfk gawd
	var objectWiggleShader:WiggleEffect;
	var updateWiggleShader:Bool = false;
	var objectTrailShader:FlxTrail;
	var iconTrail1:FlxTrail;
	var iconTrail2:FlxTrail;

	var timesShot:Int = 0; //The numnber of times GUY gets shot -- for nerfing purposes LMAO
	var timesClutched:Int = 0;
	var hurtDelay:Int = 0;

	var delayAutoPause:Bool = false; //delay the autopause to startcountdown

	public var notes:FlxTypedGroup<Note>;

	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	private var camFollow:FlxObject;
	private static var prevCamFollow:FlxObject;
	private var dadCamFollowOffsetX:Float = 0;
	private var dadCamFollowOffsetY:Float = 0;
	private var bfCamFollowOffsetX:Float = 0;
	private var bfCamFollowOffsetY:Float = 0;
	private var camFollowSpeed:Float = 0.04; //The higher the number is, the faster the camera moves
	private var doCamFollowing:Bool = true;
	private var camTween:FlxTween;

	private var idleCamShakeTimer:Float = 0;

	var grpRatings = new FlxSpriteGroup();
	var grpRaters = new FlxSpriteGroup();
	var grpStrumLine:FlxSpriteGroup = null;
	var strumLineBGTween:FlxTween;
	var doStrumLineBGTweening:Bool = true;
	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public static var playerStrums:FlxTypedGroup<FlxSprite> = null;
	public var cpuStrums:FlxTypedGroup<FlxSprite> = null;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;

	public var curScroll:Float = 1;
	var defaultScroll:Float = 1;
	var prevScroll:Float = 1;
	var prevScrollCheck:Bool = false;
	var newScroll:Float = 1;
	var diffSpeedMult:Float = 1;

	var sustainHeightMultiplier:Float = 1;

	var songSpeedTween:FlxTween;

	public var health:Float = 1; // making public because sethealth doesnt work without it
	var targetHealth:Float = 1; //So that health changes are smoother
	public static var prevHealth:Float = 1;
	public var causeOfDeath:String = '';
	public var allowHealthModifiers:Bool = true; //LAGSPIKE COMPENSATION AAAA
	public var doLagComp:Bool = true;

	private var combo:Int = 0;

	public var misses:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var campaignBads:Int = 0;
	public static var campaignGoods:Int = 0;
	public static var campaignSicks:Int = 0;

	public static var campaignDeaths:Int = 0;
	public var songDeaths:Int = 0;
	public static var hasReset:Bool = false;
	public static var showedLoadingIcon:Bool = false;

	public var accuracy:Float = 0.00;
	public static var campaignAccuracy:Float = 0.00;
	public static var campAccDivider:Int = 0;
	public static var campaignRatingArray:Array<String> = [];

	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var generatedArrows:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon; // making these public again because i may be stupid
	public var iconP2:HealthIcon; // what could go wrong?
	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var camEXT:FlxCamera;

	public static var cannotDie = false;
	public static var toggledPracticeMode = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;
	var idleToBeat:Bool = true; // change if bf and dad would idle to the beat of the song
	var idleBeat:Int = 2; // how frequently bf and dad would play their idle animation(1 - every beat, 2 - every 2 beats and so on)

	var stageOverlayGroup:FlxSpriteGroup;
	var colourWash:FlxSprite;
	var stageAmbColour:FlxColor = FlxColor.TRANSPARENT;
	var stageAmbAlpha:Float = 1;
	var stageAmbBlend:BlendMode = SCREEN;
	
	var theBorderBG:FlxSprite;
	var bgBopper:BackgroundAnims.TheBorderPeople;

	var cityLights:FlxTypedGroup<FlxSprite>;
	var curLight:Int = 0;
	var city:FlxSprite;
	var cityStreets:FlxSprite;
	var hurtVignette:FlxSprite;
	var resetHurtFxScale:Bool = true;
	var stageOverlay:FlxSprite;
	var blackScreen:FlxSprite;
	var blackScreenAlpha:Float = 0;
	var blackScreenFadeTo:Float = 0;
	var stageGradient:PsychEngineFancyStageShit.FancyStageGradient;
	var stageParticles:FlxTypedGroup<PsychEngineFancyStageShit.FancyStageParticle>;
	var stageSound:FlxSound;
	//Making this public static??? cause making this visible in the pause menu wouldnt work
	public var safeVignette:FlxSprite;

	//For stage-only fade outs
	var dummyBlackScreen:FlxSprite;

	private var hitsoundType:String = "default";
	var allowNoteHitSounds:Bool = true;
	private var missSound:FlxSound;
	private var lowHPHeartBeat:FlxSound;
	private var lowHPOverlay:FlxSprite;
	//Make this changable
	//Done!... hopefully nothing breaks haha  ha
	//Transfered from HitSoundFunction
	var noteHitVolume:Float = 0;
	var allowHeartBeatSounds:Bool = true;

	public var songScore:Int = 0;
	var dummySongScore:Float = 0;
	public var maxSongScore:Int = 0;
	var scoreTxt:FlxText;

	//yoiNKED this from Kade Engine 1.8 LMAOO
	var needSkip:Bool = false;
	var skipActive:Bool = false;
	var skipButton:FlxSprite;
	var skipTo:Float = 0;
	//(Thank you KadeMan)

	//Subtitle shits
	var subtitleText:FlxText;
	var subtitleBackground:FlxSprite;
	var defaultSubTxtY:Float = 0;
	var subtitleTimer:FlxTimer;
	var hasSubtitles:Bool = false;

	var endedSong:Bool = false;

	public static var campaignScore:Int = 0;

	//THE HIGHER THE NUMBER, THE CLOSER TO THE CAMERA IT IS, OK?
	var defaultCamZoom:Float = 1.05;

	//public static var theFunne:Bool = true;

	static var inCutscene:Bool = false;
	public static var playedCutscene:Bool = false;
	var midsongCutscene:Bool = false;

	// Per song additive offset
	public static var songOffset:Float = 0;

	// BotPlay text
	private var botPlayText:FlxText;
	// Replay shit
	public static var rep:Replay;
	private var saveNotes:Array<Dynamic> = [];
	private var saveJudge:Array<String> = [];
	private var replayAna:Analysis = new Analysis(); // replay analysis
	var doReplayShit:Bool = true;
	// Tutorial graphics
	var tutorialGraphicA:FlxSprite;
	var tutorialGraphicB:FlxSprite;
	var tutorialGraphicC:FlxSprite;
	var tutorialText = new FlxTypedGroup<FlxText>();
	var bindTxtLeft:FlxText;
	var bindTxtDown:FlxText;
	var bindTxtUp:FlxText;
	var bindTxtRight:FlxText;
	var preventTutorialTips:Bool = false;
	//Part 3 Tutorial Graphic
	var avoidBulletTipGraphic:FlxSprite;

	public var loadingIcon:FlxSprite;
	var lagCompIcon:FlxSprite;

	public static var highestCombo:Int = 0;

	// Animation common suffixes
	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

	public static var startTime:Float = 0.0;

	var video:MP4Handler;
	var videoMusic:FlxSound;

	var inSongClimax:Bool = false;
	var triggeredAlready:Bool = false;
	var enemyCanFail:Bool = true;//temp, change to false later

	var compensationTimer:FlxTimer = new FlxTimer();
	var compensationTimerResetCheck:Int = 0;
	var compensationTime:Float;

	var songLowercase = StringTools.replace(SONG.song, " ", "-").toLowerCase();

	var fakeCrochet:Float = 0;
	var didCachingShits:Bool = false;

	override public function create():Void
	{
		if (playlistLength < storyPlaylist.length)
			playlistLength = storyPlaylist.length;

		if (FlxG.save.data.pauseOnUnfocus)
		{
			switch (SONG.song)
			{
				case "Retaliation":
					if (isStoryMode && !playedCutscene)
						delayAutoPause = true;
					else					
						delayAutoPause = false;
				default:
					delayAutoPause = false;
			}

			if (delayAutoPause)
				FlxG.autoPause = false;
			else
				FlxG.autoPause = true;
		}

		FlxG.game.soundTray.silent = true;
		
		#if debug
		trace(Paths.dumpExclusions);
		#end
		Paths.clearStoredMemory();

		instance = this;

		//Update Saves
		KadeEngineData.initSave();

		noteHitVolume = FlxG.save.data.notesfxVol * 0.01;

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(800);


		//LMAO WE NEED THIS LIKE ACTUALLY-
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		//Startup Shit
		songStarted = false;

		PauseSubState.resyncToLastPos = false;

		highestCombo = 0;

		PlayStateChangeables.useDownscroll = FlxG.save.data.downscroll;
		PlayStateChangeables.safeFrames = FlxG.save.data.frames;
		PlayStateChangeables.safeZoneOffset = (PlayStateChangeables.safeFrames / 60) * 1000;
		PlayStateChangeables.botPlay = FlxG.save.data.botplay;
		PlayStateChangeables.Optimize = FlxG.save.data.optimize;

		#if windows
		if (FlxG.save.data.showPresence)
		{
			// Making difficulty text for Discord Rich Presence.
			storyDifficultyText = CoolUtil.difficultyFromInt(storyDifficulty);

			//iconRPC = SONG.player2;

			// To avoid having duplicate images in Discord assets
			/*switch (iconRPC)
			{
			}*/

			// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
			if (isStoryMode)
				detailsText = "Story Mode - (Part " + storyWeek + "): ";
			else
				detailsText = "Freeplay: ";

			#if windows
			// Updating Discord Rich Presence
			DiscordClient.changePresence("Loading...", null);
			#end
		}
		#end

		//for Gameover StageSuffix. Moved here to allow pre-caching of the sounds.
		//Could maybe be used for somethin else
		switch (SONG.player1)
		{
			case 'selfsert-default':
				stageSuffix = '-selfsert';
			default:
				if (songLowercase == "mic-test")
					stageSuffix = '-tutorial';
				else
					stageSuffix = "";
		}

		bgColor = 0xFF000000;

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camEXT = new FlxCamera();

		camHUD.bgColor.alpha = 0;
		camEXT.bgColor.alpha = 0;

		blackScreenFadeTo = !Main.nightMode && !FlxG.save.data.nightmode ? 0 : 0.25;

		if (isStoryMode && campaignDeaths == 0 && !hasReset)
		{
			if (storyProgress == 0)
			{
				trace('me mama');
				blackScreenAlpha = 1;
			}
			else if (!playedCutscene)
			{
				blackScreenAlpha = blackScreenFadeTo;
				health = prevHealth;
				trace('startupHealth = ' + health);
			}
		}

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camEXT);

		FlxCamera.defaultCameras = [camGame];

		doCachingShits();

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial', 'tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);
		fakeCrochet = (60 / SONG.bpm) * 1000;
		idleCamShakeTimer = Conductor.crochet / 1000 - 0.01;
		compensationTime = Conductor.crochet * 2 / 1000;

		diffSpeedMult = 1 + ((storyDifficulty + 1) * 0.1 - 0.3);
		trace ('difficulty mult = ' + diffSpeedMult);
		defaultScroll = (SONG.speed * diffSpeedMult) * FlxG.save.data.scrollSpeed;
		curScroll = defaultScroll;
		prevScroll = defaultScroll;
		newScroll = defaultScroll;

		if (SONG.eventObjects == null)
			SONG.eventObjects = [new Song.Event("Init BPM",0,SONG.bpm,"BPM Change")];

		if (SONG.eventObjects.length == 0)
			SONG.eventObjects = [new Song.Event("Init BPM",0,SONG.bpm,"BPM Change")];

		TimingStruct.clearTimings();

		var convertedStuff:Array<Song.Event> = [];

		var currentIndex = 0;
		
		for (i in SONG.eventObjects)
		{
			var name = Reflect.field(i,"name");
			var type = Reflect.field(i,"type");
			var pos = Reflect.field(i,"position");
			var value = Reflect.field(i,"value");

			if (type == "BPM Change")
			{
                var beat:Float = pos;

                var endBeat:Float = Math.POSITIVE_INFINITY;

                TimingStruct.addTiming(beat,value,endBeat, 0); // offset in this case = start time since we don't have a offset
				
                if (currentIndex != 0)
                {
                    var data = TimingStruct.AllTimings[currentIndex - 1];
                    data.endBeat = beat;
                    data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
					trace('startTime = ' + data.startTime);
					if (data.startTime == 0)
						data.startTime = data.startBeat * Conductor.crochet;
					trace('NOW startTime = ' + data.startTime);
					TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
                }

				currentIndex++;
			}
			convertedStuff.push(new Song.Event(name,pos,value,type));
		}

		SONG.eventObjects = convertedStuff;

		// dialogue shit
		/*switch (songLowercase)
		{
		}*/
		// defaults if no stage was found in chart
		var stageCheck:String = 'default';

		if (SONG.stage == null || SONG.stage == '' || SONG.stage == ' ')
		{
			switch (storyWeek)
			{
				case 2:
					stageCheck = 'theBorder';
				case 3:
					if (songLowercase == "variegated skylines")
						stageCheck = 'theCityPortal';
					else
						stageCheck = 'theCity';
				case 4:
					stageCheck = 'theHouse';
				default:
					stageCheck = 'default';
			}
		}
		else
		{
			stageCheck = SONG.stage;
		}

		/*if (!PlayStateChangeables.Optimize)
		{
			//Stages used to be here, just move it back if shit go doo doo poo poo ahahhaha poop ahahahhaa
		}*/
		// defaults if no gf was found in chart
		var gfCheck:String = 'table-default';

		if (SONG.gfVersion == null)
		{
			switch (storyWeek)
			{
				case 2:
					gfCheck = 'table-theborder';
			}
		}
		else
		{
			gfCheck = SONG.gfVersion;
		}

		//Turned switch statement into this one thingy
		var curGf:String = gfCheck;

		//priestGf's hardcoded offsets
		gf = new Character(270, 240, curGf);
		gf.scrollFactor.set(0.9, 0.9);

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		//Dad REPOSITIONING PER CHAR OF OFFSETS AND CAMFOLLOW OFFSETS
		switch (SONG.player2)
		{
			case 'demon-dad':
				dadCamFollowOffsetY = -40;
				camPos.x += 400;
			case 'table-default':
				dadCamFollowOffsetX = -30;
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (SONG.song == "Mic Test")
				{
					camPos.x -= 650;
					camPos.y -= 200;
				}
			case "priest-theborderpray" |  "priest-theborderannoyed" | "priest-theborderangry":
				dadCamFollowOffsetX = -75;
				dadCamFollowOffsetY = 15;
				if (SONG.player2 == "priest-theborderannoyed")
					dadCamFollowOffsetY = 0;
				else if (SONG.player2 == "priest-theborderangry")
					dadCamFollowOffsetY = -25;	
				dad.y += 215;
			case 'pico-default':
				dadCamFollowOffsetX = -120;
				dadCamFollowOffsetY = 20;
				camPos.x += 600;
				dad.y += 300;
			case 'pico-stressed':
				dadCamFollowOffsetX = -120;
				camPos.x += 600;
				dad.y += 300;
			case 'selfsert-default':
				camPos.x += 200;
				camPos.y += 20;
				dadCamFollowOffsetY = 15;
				dad.y += 260;
				dad.x -= 15;
			case 'guy-default':
				dad.y += 350;
				dad.x -= 10;
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// BF REPOSITIONING PER CHAR
		switch (SONG.player1)
		{
			case 'guy-theborder':
				bfCamFollowOffsetY = 40;
			case 'selfsert-default':
				boyfriend.y = 360;
				//selfsert player y
			default:
				bfCamFollowOffsetX = 30;
				bfCamFollowOffsetY = -10;
				if (songLowercase == 'sudden-confrontation')
					boyfriend.x += 15;
			//bfCamFollowOffset
		}

		//Repositioning per stage was here idk

		//Stages and Layering LOL
		if (!PlayStateChangeables.Optimize)
		{
			//Stages LOL
			switch (stageCheck)
			{
				//Fun fact about TMG's development: I was searching for 'theBorder' once and I accidentally typed 'theBorger' instead. That's kind of funny I think
				case 'theBorder':
					curStage = 'border';

					//X: Negative is LEFT, while postitive is RIGHT.
					//Y: Negative is UP, while positive is DOWN.

					//                            X     Y
					theBorderBG = new FlxSprite(-430, -250);
					theBorderBG.scrollFactor.set(0.1, 0.1);
					theBorderBG.frames = Paths.getSparrowAtlas('theborder_bg', 'week2');
					theBorderBG.animation.addByPrefix('idle', 'the border bg0');
					theBorderBG.animation.addByPrefix('lightning', 'the border bg glitch', 24, false);
					theBorderBG.animation.addByPrefix('glitch', 'the border bg glitch non flashy', 24, false);
					theBorderBG.animation.play('idle');
					if(FlxG.save.data.antialiasing)
						{
							theBorderBG.antialiasing = true;
						}
					add(theBorderBG);

					switch (songLowercase)
					{
						case 'disagreement':
							defaultCamZoom = 0.865;
							stageOverlay = new FlxSprite();
							stageOverlay.setGraphicSize(Math.round(stageOverlay.width * 0.7));
							stageOverlay.alpha = 0.6;
							theBorderBG.alpha = 0.75;
							stageAmbColour = 0xFF13070D;
							stageAmbAlpha = 0.1;

						case 'retaliation':
							defaultCamZoom = 0.815;
							stageOverlay = new FlxSprite();
							stageOverlay.setGraphicSize(Math.round(stageOverlay.width * 0.65));
							stageOverlay.alpha = 1;
							theBorderBG.alpha = 0.5;
							//Boppers
							bgBopper = new BackgroundAnims.TheBorderPeople(-380, 590);
							bgBopper.alpha = 0;
							if (FlxG.save.data.distractions)
								add(bgBopper);
							stageAmbColour = 0xFF1B080E;
							stageAmbAlpha = 0.25;

						default:
							defaultCamZoom = 0.8;
							stageOverlay = new FlxSprite();
							stageOverlay.setGraphicSize(Std.int(stageOverlay.width * 0.75));
							stageOverlay.alpha = 0.35;
							theBorderBG.alpha = 1;
							stageAmbColour = 0xFF140A13;
							stageAmbAlpha = 0.025;
					}
					stageOverlay.scrollFactor.set();
					stageAmbBlend = MULTIPLY;

					var theborderFloor:FlxSprite = new FlxSprite(-650, 590).loadGraphic(Paths.image('theborder_floor', 'week2'));
					//theborderFloor.setGraphicSize(Std.int(theborderFloor.width * 1.0));
					theborderFloor.updateHitbox();
					if(FlxG.save.data.antialiasing)
						{
							theborderFloor.antialiasing = true;
						}
					theborderFloor.scrollFactor.set(0.9, 0.9);
					theborderFloor.active = false;
					add(theborderFloor);

					stageOverlay.frames = Paths.getSparrowAtlas('vignette_black', 'week2');
					if(FlxG.save.data.antialiasing)
					{
						stageOverlay.antialiasing = true;
					}
					stageOverlay.scrollFactor.set(0.1, 0.1);
					stageOverlay.animation.addByPrefix('vignette', 'vignette', 1, true);
					stageOverlay.animation.play('vignette');
					stageOverlay.updateHitbox();
					stageOverlay.screenCenter();
					stageOverlay.active = false;


				case 'theCity':
					curStage = 'cityskyline';
					defaultCamZoom = 0.85;

					//X [LEFT or RIGHT]: Negative is LEFT, while postitive is RIGHT. (Same as the Cartesian Plane's)
					//Y [UP or DOWN]: Negative is UP, while positive is DOWN. (Inverted as the Cartesian Plane's)

					//                                 X    Y
					var bg:FlxSprite = new FlxSprite(-140, -80).loadGraphic(Paths.image('theCity/sky', 'week3'));
					bg.scrollFactor.set(0.1, 0.1);
					if(FlxG.save.data.antialiasing)
						bg.antialiasing = true;
					bg.active = false;
					add(bg);

					city = new FlxSprite(-120, -85).loadGraphic(Paths.image('theCity/city', 'week3'));
					city.scrollFactor.set(0.2, 0.2);
					//city.setGraphicSize(Std.int(city.width * 0.85));
					if(FlxG.save.data.antialiasing)
						city.antialiasing = true;
					city.updateHitbox();
					city.active = false;
					add(city);

					cityLights = new FlxTypedGroup<FlxSprite>();
					if (FlxG.save.data.distractions)
					{
						add(cityLights);
					}

					for (i in 0...5)
					{
						var light:FlxSprite = new FlxSprite(city.x, city.y).loadGraphic(Paths.image('theCity/win' + i, 'week3'));
						light.scrollFactor.set(0.2, 0.2);
						light.visible = false;
						//light.setGraphicSize(Std.int(light.width * 0.85));
						light.updateHitbox();
						//light.blend = MULTIPLY;
						if(FlxG.save.data.antialiasing)
							light.antialiasing = true;
						cityLights.add(light);
					}

					var streetBehind:FlxSprite = new FlxSprite(-160, 0).loadGraphic(Paths.image('theCity/behindStreet', 'week3'));
					streetBehind.scrollFactor.set(0.65, 0.65);
					streetBehind.setGraphicSize(Std.int(streetBehind.width * 1.1));
					//streetBehind.updateHitbox();
					if(FlxG.save.data.antialiasing)
						streetBehind.antialiasing = true;
					streetBehind.active = false;
					add(streetBehind);

					cityStreets = new FlxSprite(-150, 70);
					cityStreets.frames = Paths.getSparrowAtlas('theCity/street', 'week3');
					cityStreets.scrollFactor.set(0.9, 0.9);
					cityStreets.setGraphicSize(Std.int(cityStreets.width * 1.15));
					cityStreets.animation.addByPrefix('street', 'street', 1, true);
					cityStreets.animation.play('street');
					if(FlxG.save.data.antialiasing)
					{
						cityStreets.antialiasing = true;
					}

					stageOverlay = new FlxSprite();
					stageOverlay.frames = Paths.getSparrowAtlas('theCity/vignette', 'week3');
					stageOverlay.scrollFactor.set();
					stageOverlay.setGraphicSize(Std.int(stageOverlay.width * 0.75));
					stageOverlay.animation.addByPrefix('static', 'vignette justBlack');
					if (FlxG.save.data.flashing)
						stageOverlay.animation.addByPrefix('warning', 'vignette warnPlayer flashRed', 24, true);
					else
						stageOverlay.animation.addByPrefix('warning', 'vignette warnPlayer flashRed', 15, false);
					stageOverlay.animation.addByPrefix('singleFlash', 'vignette warnPlayer flashRed', 12, false);
					//stageOverlay.blend = MULTIPLY;
					stageOverlay.animation.play('static');
					stageOverlay.updateHitbox();
					stageOverlay.screenCenter();
					if(FlxG.save.data.antialiasing)
						stageOverlay.antialiasing = true;
					stageAmbColour = 0xFF130A25;
					stageAmbBlend = LIGHTEN;
					stageAmbAlpha = 0.85;
					

				case 'theCityPortal':
					curStage = 'cityskylineVariegated';
					defaultCamZoom = 0.83;

					//X [LEFT or RIGHT]: Negative is LEFT, while postitive is RIGHT. (Same as the Cartesian Plane's)
					//Y [UP or DOWN]: Negative is UP, while positive is DOWN. (Inverted as the Cartesian Plane's)

					//                                 X    Y
					var bg:FlxSprite = new FlxSprite(-140, -80).loadGraphic(Paths.image('theCityPortalOpen/sky_variegated', 'week3'));
					bg.scrollFactor.set(0.1, 0.1);
					if(FlxG.save.data.antialiasing)
						bg.antialiasing = true;
					bg.active = false;
					add(bg);

					city = new FlxSprite(-120, -85);
					city.scrollFactor.set(0.2, 0.2);
					city.frames = Paths.getSparrowAtlas('theCityPortalOpen/city_portal', 'week3');
					city.animation.addByPrefix('cityPortal', 'portal_CityIdle', 14, true);
					city.animation.play('cityPortal');
					//city.setGraphicSize(Std.int(city.width * 0.85));
					if(FlxG.save.data.antialiasing)
					{
						city.antialiasing = true;
					}
					city.updateHitbox();
					add(city);

					stageParticles = new FlxTypedGroup<PsychEngineFancyStageShit.FancyStageParticle>();
					stageParticles.visible = false;
					add(stageParticles);

					var streetBehind:FlxSprite = new FlxSprite(-160, 0);
					streetBehind.frames = Paths.getSparrowAtlas('theCityPortalOpen/behindStreet_Portal', 'week3');
					streetBehind.scrollFactor.set(0.65, 0.65);
					streetBehind.setGraphicSize(Std.int(streetBehind.width * 1.1));
					streetBehind.animation.addByPrefix('trees', 'treesIdle', 18, true);
					streetBehind.animation.play('trees');
					//streetBehind.updateHitbox();
					if(FlxG.save.data.antialiasing)
					{
						streetBehind.antialiasing = true;
					}
					add(streetBehind);

					cityStreets = new FlxSprite(-150, 70);
					cityStreets.frames = Paths.getSparrowAtlas('theCityPortalOpen/street_portal', 'week3');
					cityStreets.scrollFactor.set(0.9, 0.9);
					cityStreets.setGraphicSize(Std.int(cityStreets.width * 1.15));
					cityStreets.animation.addByPrefix('street', 'streetIdle', 20, true);
					cityStreets.animation.play('street');
					if(FlxG.save.data.antialiasing)
					{
						cityStreets.antialiasing = true;
					}

					//ANIMATE THE VIGNETTE
					stageOverlay = new FlxSprite();
					stageOverlay.frames = Paths.getSparrowAtlas('theCity/vignette', 'week3');
					stageOverlay.scrollFactor.set();
					stageOverlay.setGraphicSize(Std.int(stageOverlay.width * 0.675));
					stageOverlay.animation.addByPrefix('static', 'vignette justBlack');
					if (FlxG.save.data.flashing)
						stageOverlay.animation.addByPrefix('warning', 'vignette warnPlayer flashRed', 24, true);
					else
						stageOverlay.animation.addByPrefix('warning', 'vignette warnPlayer flashRed', 15, false);
					stageOverlay.animation.addByPrefix('singleFlash', 'vignette warnPlayer flashRed', 12, false);
					stageOverlay.animation.play('static');
					stageOverlay.updateHitbox();
					stageOverlay.screenCenter();
					if(FlxG.save.data.antialiasing)
						stageOverlay.antialiasing = true;
					stageAmbColour = 0xFF1A002C;
					stageAmbAlpha = 0.65;


				case 'theHouse':
					bfCamFollowOffsetY += 15;
					dadCamFollowOffsetY += 15;
					boyfriend.x += 25;
					boyfriend.y -= 20;
					dad.x += 20;
					dad.y -= 20;
					defaultCamZoom = 0.98;
					curStage = 'house';

					var baseBG:FlxSprite = new FlxSprite(-400, -200).loadGraphic(Paths.image('house/HouseBG', 'week4'));
					baseBG.setGraphicSize(Std.int(baseBG.width * 0.75));
					baseBG.updateHitbox();
					if(FlxG.save.data.antialiasing)
						baseBG.antialiasing = true;
					baseBG.scrollFactor.set(0.3, 0.3);
					baseBG.active = false;
					add(baseBG);

					var parralax1:FlxSprite = new FlxSprite(-400, -200).loadGraphic(Paths.image('house/ParralaxObjects1', 'week4'));
					parralax1.setGraphicSize(Std.int(parralax1.width * 0.77));
					parralax1.updateHitbox();
					if(FlxG.save.data.antialiasing)
						parralax1.antialiasing = true;
					parralax1.scrollFactor.set(0.3, 0.3);
					parralax1.active = false;
					add(parralax1);

					var baseFloor:FlxSprite = new FlxSprite(-740, -290).loadGraphic(Paths.image('house/ParralaxFloor', 'week4'));
					baseFloor.setGraphicSize(Std.int(baseFloor.width * 0.95));
					if(FlxG.save.data.antialiasing)
						baseFloor.antialiasing = true;
					baseFloor.scrollFactor.set(0.95, 0.95);
					baseFloor.active = false;
					add(baseFloor);

					var parralax2Shadow:FlxSprite = new FlxSprite(-980, -200).loadGraphic(Paths.image('house/ParralaxObjects2Shadow', 'week4'));
					parralax2Shadow.setGraphicSize(Std.int(parralax2Shadow.width * 0.60));
					if(FlxG.save.data.antialiasing)
						parralax2Shadow.antialiasing = true;
					parralax2Shadow.scrollFactor.set(0.9, 0.9);
					parralax2Shadow.blend = SUBTRACT;
					parralax2Shadow.alpha = 0.3;
					parralax2Shadow.active = false;
					add(parralax2Shadow);

					var parralax2:FlxSprite = new FlxSprite(-950, -200).loadGraphic(Paths.image('house/ParralaxObjects2', 'week4'));
					parralax2.setGraphicSize(Std.int(parralax2.width * 0.60));
					if(FlxG.save.data.antialiasing)
						parralax2.antialiasing = FlxG.save.data.antialiasing;
					parralax2.scrollFactor.set(0.92, 0.92);
					parralax2.active = false;
					add(parralax2);
					
					var shading1:FlxSprite = new FlxSprite(-395, -190).loadGraphic(Paths.image('house/BlendLight_Window1', 'week4'));
					shading1.setGraphicSize(Std.int(shading1.width * 0.76));
					shading1.updateHitbox();
					shading1.antialiasing = FlxG.save.data.antialiasing;
					shading1.scrollFactor.set(0.3, 0.3);
					shading1.blend = ADD;
					shading1.alpha = 0.6;
					shading1.active = false;
					add(shading1);

					var shading2:FlxSprite = new FlxSprite(-395, -190).loadGraphic(Paths.image('house/BlendLight_Window2', 'week4'));
					shading2.setGraphicSize(Std.int(shading2.width * 0.76));
					shading2.updateHitbox();
					shading2.antialiasing = FlxG.save.data.antialiasing;
					shading2.scrollFactor.set(0.35, 0.35);
					shading2.blend = ADD;
					shading2.active = false;
					add(shading2);
					stageAmbColour = 0xFF030C18;
					stageAmbBlend = LIGHTEN;
					stageAmbAlpha = 0.65;
					

				default:
					switch (songLowercase)
					{
						case 'mic-test':
							defaultCamZoom = 1.2;
						default:
							defaultCamZoom = 0.9;
					}
					curStage = 'stage';
					var stageBG:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('graduation/graduation_back', 'week1'));
					stageBG.antialiasing = FlxG.save.data.antialiasing;
					stageBG.scrollFactor.set(0.7, 0.7);
					stageBG.active = false;
					add(stageBG);

					var stageFloor:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('graduation/graduation_front', 'week1'));
					stageFloor.setGraphicSize(Std.int(stageFloor.width * 1.1));
					stageFloor.updateHitbox();
					stageFloor.antialiasing = FlxG.save.data.antialiasing;
					stageFloor.scrollFactor.set(0.9, 0.9);
					stageFloor.active = false;
					add(stageFloor);

					stageOverlay = new FlxSprite(-490, -300).loadGraphic(Paths.image('graduation/graduation_overlay', 'week1'));
					stageOverlay.setGraphicSize(Std.int(stageOverlay.width * 0.9));
					stageOverlay.updateHitbox();
					stageOverlay.antialiasing = FlxG.save.data.antialiasing;
					stageOverlay.scrollFactor.set(1.3, 1.3);
					stageOverlay.active = false;
					stageAmbColour = 0xFF09130E;
			}

			//Layering for stages LOL
			switch (curStage)
			{
				case 'cityskyline' | 'cityskylineVariegated':
					add(gf);
					add(cityStreets);
				case 'house':
					//do nada
				default:
					add(gf);
			}

			dummyBlackScreen = new FlxSprite(-FlxG.width * defaultCamZoom,
				-FlxG.height * defaultCamZoom).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
			dummyBlackScreen.scrollFactor.set();
			dummyBlackScreen.alpha = 0;
			dummyBlackScreen.active = false;
			add(dummyBlackScreen);

			add(dad);
			add(boyfriend);

			colourWash = new FlxSprite(-FlxG.width,
				-FlxG.height).makeGraphic(FlxG.width * 2, FlxG.height * 2, stageAmbColour);
			colourWash.scrollFactor.set();
			if (stageAmbColour == FlxColor.TRANSPARENT)
				colourWash.visible = false;
			colourWash.alpha = stageAmbAlpha;
			colourWash.blend = stageAmbBlend;
			colourWash.cameras = [camHUD];
			add(colourWash);

			stageOverlayGroup = new FlxSpriteGroup();
			add(stageOverlayGroup);

			//Stage dependent shit
			switch (curStage)
			{
				case 'stage':
					stageOverlayGroup.add(stageOverlay);
				case 'border' | 'cityskyline':
					stageOverlayGroup.add(stageOverlay);
					stageOverlayGroup.cameras = [camHUD];
				case 'cityskylineVariegated':
					var windEffect:FlxSprite = new FlxSprite();
					windEffect.frames = Paths.getSparrowAtlas('theCityPortalOpen/portalWind', 'week3');
					windEffect.animation.addByPrefix('loop', 'portalWindBLOW', 12, true);
					windEffect.animation.play('loop');
					windEffect.updateHitbox();
					windEffect.screenCenter();
					windEffect.scrollFactor.set();
					windEffect.blend = ADD;
					windEffect.alpha = 0.1;
					if(FlxG.save.data.antialiasing)
						windEffect.antialiasing = true;
					stageOverlayGroup.add(windEffect);
					FlxTween.tween(windEffect, {alpha: 1}, Conductor.crochet * 256 / 1000, {type: ONESHOT, ease: FlxEase.expoOut, startDelay: Conductor.crochet * 4 / 1000});
					stageOverlayGroup.add(stageOverlay);
					stageOverlayGroup.cameras = [camHUD];
					if (FlxG.save.data.distractions && !PlayStateChangeables.Optimize)
					{
						updateWiggleShader = true;
						objectWiggleShader = new WiggleEffect();
						objectWiggleShader.effectType = WiggleEffectType.WAVY;
						objectWiggleShader.waveAmplitude = 0.0008;
						objectWiggleShader.waveFrequency = 20;
						objectWiggleShader.waveSpeed = 16;
						city.shader = objectWiggleShader.shader;
					}
			}

			//Character dependent shit
			switch (SONG.player2)
			{
				case "priest-theborderangry":
					objectTrailShader = new FlxTrail(dad, null, 3, 8, 0.4, 0.08);
					objectTrailShader.alpha = 0.65;
					add(objectTrailShader);

					updateWiggleShader = true;
					objectWiggleShader = new WiggleEffect();
					objectWiggleShader.effectType = WiggleEffectType.DREAMY;
					objectWiggleShader.waveAmplitude = 0.0015;
					objectWiggleShader.waveFrequency = 100;
					objectWiggleShader.waveSpeed = 4;
					dad.shader = objectWiggleShader.shader;
			}
		}
		else
		{
			var stageBG:FlxSprite;
			switch (storyWeek)
			{
				//BG for Usual Rhythm Game BG
				case 2:
					stageBG = new FlxSprite().loadGraphic(Paths.image('optimBG', 'week2'));
				case 3:
					stageBG = new FlxSprite().loadGraphic(Paths.image('optimBG', 'week3'));
					if (stageCheck == "theCityPortal")
					{
						updateWiggleShader = true;
						objectWiggleShader = new WiggleEffect();
						objectWiggleShader.effectType = WiggleEffectType.WAVY;
						objectWiggleShader.waveAmplitude = 0.0008;
						objectWiggleShader.waveFrequency = 20;
						objectWiggleShader.waveSpeed = 16;
						city.shader = objectWiggleShader.shader;
					}
				default:
					stageBG = new FlxSprite().loadGraphic(Paths.image('optimBG', 'week1'));
			}
			stageBG.scale.x *= 0.65;
			stageBG.scale.y *= 0.65;
			stageBG.scrollFactor.set();
			stageBG.updateHitbox();
			stageBG.antialiasing = FlxG.save.data.antialiasing;
			stageBG.screenCenter();
			stageBG.alpha = 0.2;
			add(stageBG);
		}

		blackScreen = new FlxSprite(-FlxG.width * camGame.zoom,
			-FlxG.height * camGame.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		blackScreen.scrollFactor.set();
		blackScreen.alpha = blackScreenAlpha;
		blackScreen.cameras = [camEXT];
		add(blackScreen);

		//UI Vignettes
		//The detail thing that appears when you get shot
		hurtVignette = new FlxSprite().loadGraphic(Paths.image('gotShot', 'week3'));
		hurtVignette.scale.x *= 0.68;
		hurtVignette.scale.y *= 0.68;
		hurtVignette.scrollFactor.set();
		hurtVignette.updateHitbox();
		if(FlxG.save.data.antialiasing)
			hurtVignette.antialiasing = true;
		if(!FlxG.save.data.distractions)
			hurtVignette.blend = MULTIPLY;
		hurtVignette.screenCenter();
		hurtVignette.alpha = 0;
		add(hurtVignette);

		lowHPOverlay = new FlxSprite().loadGraphic(Paths.image('lowHPOverlay'));
		lowHPOverlay.scale.x *= 0.68;
		lowHPOverlay.scale.y *= 0.68;
		lowHPOverlay.scrollFactor.set();
		lowHPOverlay.updateHitbox();
		if(FlxG.save.data.antialiasing)
			lowHPOverlay.antialiasing = true;
		lowHPOverlay.screenCenter();
		lowHPOverlay.alpha = 0;
		add(lowHPOverlay);

		//The detail thing that appears when you cant die
		safeVignette = new FlxSprite().loadGraphic(Paths.image('cannotDie', 'tutorial'));
		safeVignette.y = 30;
		safeVignette.scale.x *= 0.7;
		safeVignette.scale.y *= 0.7;
		safeVignette.scrollFactor.set();
		if(FlxG.save.data.antialiasing)
		{
			safeVignette.antialiasing = true;
		}
		safeVignette.screenCenter();
		safeVignette.alpha = 0.65;
		safeVignette.blend = ADD;
		safeVignette.visible = false;
		add(safeVignette);

		//Skip Intro Shit
		var firstNoteTime = Math.POSITIVE_INFINITY;
		var playerTurn = false;
		if (songLowercase != 'finale')
		{
			for (index => section in SONG.notes)
			{
				if (section.sectionNotes.length > 0)
				{
					if ((storyWeek < FlxG.save.data.weekUnlocked || (campaignDeaths > 0 || hasReset)) || !isStoryMode)
					{
						if (section.startTime > Conductor.crochet * 16 && SONG.bpm >= 170 || section.startTime > Conductor.crochet * 8)
						{
							needSkip = true;
							skipTo = section.startTime - Conductor.crochet * 4;
						}
						break;
					}
				}
			}
		}

		Conductor.songPosition = -5000;

		//Centering Offset Shit (1) V Doink
		strumLine = new FlxSprite(50, 50).makeGraphic(FlxG.width, 10);
		//strumLine.scrollFactor.set();

		if (PlayStateChangeables.useDownscroll)
			strumLine.y = FlxG.height - 165;

		grpStrumLine = new FlxSpriteGroup();
		add(grpStrumLine);

		add(grpRatings);
		add(grpRaters);

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		/*generateStaticArrows(0);
		generateStaticArrows(1);*/

		#if debug
		if (SONG.song == null)
			trace('song is null???');
		else
			trace('song looks gucci');
		#end

		generateSong(SONG.song);

		//this was where the cameradata was

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		//Adding Offsets Again      V //Ploink
		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (PlayStateChangeables.useDownscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.antialiasing = true;
		healthBarBG.color = FlxColor.BLACK;
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		healthBar.antialiasing = true;
		add(healthBar);

		subtitleText = new FlxText(healthBarBG.x + 70, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 80 : -80), 0);
		defaultSubTxtY = subtitleText.y;
		subtitleText.text = "";
		subtitleText.antialiasing = FlxG.save.data.antialiasing;
		subtitleText.setFormat(Paths.font("playtime.ttf"), 38, CENTER);
		if (FlxG.save.data.centersubtitles)
			subtitleText.x = healthBarBG.x + (healthBarBG.width - subtitleText.width) / 2;
		subtitleText.color = FlxColor.WHITE;
		subtitleText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3, 1);
			subtitleText.cameras = [camEXT];

		subtitleBackground = new FlxSprite(subtitleText.x, subtitleText.y).makeGraphic(1, 1, FlxColor.BLACK);
		subtitleBackground.cameras = [camEXT];
		subtitleBackground.alpha = 0;

		// Add Kade Engine watermark
		songNameTXT = new FlxText(4, 0, 0,
			SONG.song
			+ " - "
			+ CoolUtil.difficultyFromInt(storyDifficulty), 16);
		songNameTXT.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
		songNameTXT.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1.3);
		songNameTXT.scrollFactor.set();
		songNameTXT.y = (!PlayStateChangeables.useDownscroll ? FlxG.height - songNameTXT.height - 4 : songNameTXT.height - 10);
		add(songNameTXT);

		iconP1 = new HealthIcon(boyfriend.healthIcon, true);
		iconP1.y = healthBar.y - 75;
		add(iconP1);

		iconP2 = new HealthIcon(dad.healthIcon, false);
		iconP2.y = healthBar.y - 75;
		add(iconP2);

		scoreTxt = new FlxText(healthBarBG.x - 35 + healthBar.width / 4, healthBarBG.y + 40, 0, Ratings.CalculateRanking(Math.round(dummySongScore), nps, maxNPS, accuracy, songDeaths), 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER);
		scoreTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1.5);
		scoreTxt.screenCenter(X);
		add(scoreTxt);

		// Literally copy-paste of the above, fu-- (frick)
		botPlayText = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0,
			"BOTPLAY", 20);
		botPlayText.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botPlayText.scrollFactor.set();
		botPlayText.borderSize = 4;
		botPlayText.borderQuality = 2;
		botPlayText.antialiasing = false;
		botPlayText.visible = false;
		botPlayText.x = healthBarBG.x + (healthBarBG.width - botPlayText.width) / 2;
		if (PlayStateChangeables.botPlay)
			add(botPlayText);

		//Song-dependent tutorial cards
		//also health icon trails
		switch (songLowercase)
		{
			case 'mic-test':
				//	Tutorial Graphics that appear in famous hits such as: "Tutorial", and "nothing else lmao just tutorial"
				//	For the first tutorial popup
				if (!PlayStateChangeables.Optimize && !PlayStateChangeables.useDownscroll)
					tutorialGraphicA = new FlxSprite().loadGraphic(Paths.image('infocards/TutorialTipA', 'tutorial'));
				else if (!PlayStateChangeables.Optimize && PlayStateChangeables.useDownscroll)
					tutorialGraphicA = new FlxSprite().loadGraphic(Paths.image('infocards/TutorialTipA_DownScroll', 'tutorial'));
				else if (!PlayStateChangeables.useDownscroll)
					tutorialGraphicA = new FlxSprite().loadGraphic(Paths.image('infocards/TutorialTipA_MiddleScroll', 'tutorial'));
				else
					tutorialGraphicA = new FlxSprite().loadGraphic(Paths.image('infocards/TutorialTipA_MiddleDownScroll', 'tutorial'));
				tutorialGraphicA.scrollFactor.set();
				tutorialGraphicA.updateHitbox();
				tutorialGraphicA.antialiasing = FlxG.save.data.antialiasing;
				tutorialGraphicA.screenCenter();
				tutorialGraphicA.alpha = 0;

				//	For the second tutorial popup
				tutorialGraphicB = new FlxSprite().loadGraphic(Paths.image('infocards/TutorialTipB', 'tutorial'));
				tutorialGraphicB.scrollFactor.set();
				tutorialGraphicB.updateHitbox();
				tutorialGraphicB.antialiasing = FlxG.save.data.antialiasing;
				tutorialGraphicB.screenCenter();
				tutorialGraphicB.alpha = 0;
				
				//	For the third tutorial popup
				tutorialGraphicC = new FlxSprite().loadGraphic(Paths.image('infocards/TutorialTipC', 'tutorial'));
				tutorialGraphicC.scrollFactor.set();
				tutorialGraphicC.updateHitbox();
				tutorialGraphicC.antialiasing = FlxG.save.data.antialiasing;
				tutorialGraphicC.screenCenter();
				tutorialGraphicC.alpha = 0;

				tutorialGraphicA.cameras = [camHUD];
				tutorialGraphicB.cameras = [camHUD];
				tutorialGraphicC.cameras = [camHUD];
				add(tutorialGraphicA);
				add(tutorialGraphicB);
				add(tutorialGraphicC);

				add(tutorialText);

				bindTxtLeft = new FlxText(0, 0, -0);
				bindTxtLeft.text = '${FlxG.save.data.leftBind}';
				bindTxtLeft.antialiasing = true;
				bindTxtLeft.setFormat(Paths.font("playtime.ttf"), 50, CENTER);
				bindTxtLeft.color = FlxColor.YELLOW;
				bindTxtLeft.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 6, 6);

				bindTxtDown = new FlxText(0, 0, -0);
				bindTxtDown.text = '${FlxG.save.data.downBind}';
				bindTxtDown.antialiasing = true;
				bindTxtDown.setFormat(Paths.font("playtime.ttf"), 50, CENTER);
				bindTxtDown.color = FlxColor.YELLOW;
				bindTxtDown.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 6, 6);

				bindTxtUp = new FlxText(0, 0, -0);
				bindTxtUp.text = '${FlxG.save.data.upBind}';
				bindTxtUp.antialiasing = true;
				bindTxtUp.setFormat(Paths.font("playtime.ttf"), 50, CENTER);
				bindTxtUp.color = FlxColor.YELLOW;
				bindTxtUp.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 6, 6);

				bindTxtRight = new FlxText(0, 0, -0);
				bindTxtRight.text = '${FlxG.save.data.rightBind}';
				bindTxtRight.antialiasing = true;
				bindTxtRight.setFormat(Paths.font("playtime.ttf"), 50, CENTER);
				bindTxtRight.color = FlxColor.YELLOW;
				bindTxtRight.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 6, 6);

				tutorialText.add(bindTxtLeft);
				tutorialText.add(bindTxtDown);
				tutorialText.add(bindTxtUp);
				tutorialText.add(bindTxtRight);
				for (i in 0...4)
				{
					tutorialText.members[i].alpha = 0;
				}


			case 'playing-with-fire':
				//Tip Graphics for tutorial on how to avoid gun lol
				avoidBulletTipGraphic = new FlxSprite().loadGraphic(Paths.image('infocards/SpecialNoteTip', 'week3'));
				avoidBulletTipGraphic.scrollFactor.set();
				avoidBulletTipGraphic.updateHitbox();
				avoidBulletTipGraphic.antialiasing = FlxG.save.data.antialiasing;
				avoidBulletTipGraphic.screenCenter();
				avoidBulletTipGraphic.alpha = 0;
				avoidBulletTipGraphic.cameras = [camHUD];

				//health icon trails for getting shot
				iconTrail1 = new FlxTrail(iconP1, null, 5, 0, 0.65, 0.1);
				iconTrail1.cameras = [camHUD];
				iconTrail1.active = false;
				add(iconTrail1);
				
				iconTrail2 = new FlxTrail(iconP2, null, 5, 0, 0.65, 0.1);
				iconTrail2.cameras = [camHUD];
				iconTrail2.active = false;
				add(iconTrail2);


			case 'variegated-skylines':
				//health icon trails for getting shot
				iconTrail1 = new FlxTrail(iconP1, null, 5, 0, 0.65, 0.1);
				iconTrail1.cameras = [camHUD];
				iconTrail1.active = false;
				add(iconTrail1);
				
				iconTrail2 = new FlxTrail(iconP2, null, 5, 0, 0.65, 0.1);
				iconTrail2.cameras = [camHUD];
				iconTrail2.active = false;
				add(iconTrail2);


			case 'finale' | 'sudden-confrontation' | 'sprouting-irritation':
				// Literally copy-paste of the above, fu-- (frick) (AUGH AGAIN?? nah jk it aint a big deal LMAO)
				var wipText = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 70 : -70), 0,
				"[WIP LEVEL - (NOT FINAL!)]",25);
				wipText.setFormat(Paths.font("vcr.ttf"), 25, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				wipText.scrollFactor.set();
				wipText.borderSize = 4;
				wipText.borderQuality = 2;
				wipText.antialiasing = false;
				wipText.screenCenter(X);
				wipText.cameras = [camEXT];
				add(wipText);

				//SO that run does not count in story mode
				if (isStoryMode)
					toggledPracticeMode = true;
		}

		//LoadingNextSong
		loadingIcon = new FlxSprite().loadGraphic(Paths.image('loadingNextSong'));
		loadingIcon.setGraphicSize(Std.int(loadingIcon.width * 0.5));
		//loadingIcon.screenCenter();
		loadingIcon.x = FlxG.width - loadingIcon.width / 2;
		loadingIcon.y = FlxG.height - loadingIcon.height / 2;
		loadingIcon.scrollFactor.set();
		loadingIcon.updateHitbox();
		loadingIcon.antialiasing = FlxG.save.data.antialiasing;
		//loadingIcon.screenCenter();
		loadingIcon.cameras = [camEXT];
		add(loadingIcon);
		if (showedLoadingIcon)
			loadingIcon.alpha = 0;
		else
			loadingIcon.alpha = 1;

		if (FlxG.save.data.lagCompensation)
		{
			lagCompIcon = new FlxSprite().loadGraphic(Paths.image('compensaTurtle'));
			//loadingIcon.screenCenter();
			//lagCompIcon.setGraphicSize(Std.int(lagCompIcon.width * 1.5));
			//lagCompIcon.x = FlxG.width - lagCompIcon.width * 1.6;
			//lagCompIcon.y = FlxG.height - lagCompIcon.height * 1.5;
			lagCompIcon.x = FlxG.width - lagCompIcon.width * 1.1;
			lagCompIcon.y = (PlayStateChangeables.useDownscroll ? 20 : FlxG.height - lagCompIcon.height * 1.1);
			lagCompIcon.scrollFactor.set();
			lagCompIcon.updateHitbox();
			lagCompIcon.blend = LIGHTEN;
			lagCompIcon.alpha = 0;
			if(FlxG.save.data.antialiasing)
				lagCompIcon.antialiasing = true;
			//lagCompIcon.screenCenter();
			lagCompIcon.cameras = [camEXT];
			add(lagCompIcon);
			//trace("added lagComp ting");
		}

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		add(grpNoteSplashes);

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0;

		hurtVignette.cameras = [camHUD];
		lowHPOverlay.cameras = [camHUD];
		safeVignette.cameras = [camHUD];
		grpStrumLine.cameras = [camHUD];
		grpRatings.cameras = [camHUD];
		grpRaters.cameras = [camHUD];
		tutorialText.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		//replayTxt.cameras = [camHUD];
		botPlayText.cameras = [camEXT];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		//doof.cameras = [camHUD];
		songNameTXT.cameras = [camHUD];

		songPosGroup = new FlxSpriteGroup();
		add(songPosGroup);

		//trace('starting');

		//Cameradata
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		if (PlayStateChangeables.Optimize)
			camFollow.screenCenter();
		add(camFollow);

		camGame.zoom = defaultCamZoom;
		camGame.focusOn(camFollow.getPosition());
		camGame.follow(camFollow, LOCKON);
		camGame.followLerp = camFollowSpeed * (30 / FlxG.save.data.fpsCap);

		//For CamHUD to fix itself after shake
		var camHUDFollow:FlxObject = new FlxObject(0, 0, 1, 1);
		camHUDFollow.screenCenter();
		camHUD.focusOn(camHUDFollow.getPosition());
		camHUD.follow(camHUDFollow, LOCKON);
		camHUD.followLerp = 0.8 * (30 / FlxG.save.data.fpsCap);

		//if (!loadRep)
		rep = new Replay("na");

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);

		transIn.camera = camHUD;
		transOut.camera = camHUD;
		//trace('set transInCam to camHUD');

		super.create();

		startingSong = true;
		video = new MP4Handler();

		//Song Start Events
		//trace("Song Startup Shit");
		//trace("'Played Cutscene' is " + playedCutscene);
		switch (songLowercase)
		{
			case 'mic-test':
				startCountdown();
				hasSubtitles = true;
				if (!PlayStateChangeables.Optimize)
					doCamFollowing = false;
			case 'tech.-difficulties':
				if (isStoryMode && !playedCutscene)
				{
					inCutscene = true;
					playedCutscene = true;
					FlxTween.tween(loadingIcon, {alpha: 0}, 0.1, {type: ONESHOT, ease: FlxEase.smootherStepIn, onComplete: function(twn:FlxTween)
					{
						video.playVideo(Paths.video('week1/startcutscene'));
						video.finishCallback = function()
						{
							//loadingIcon.alpha = 0;
							startCountdown();
						}
					}});
				}
				else
					startCountdown();
			case 'awkward-pauses' | 'up-and-beyond':
				startCountdown();
			case 'desperation':
				hasSubtitles = true;
				if (isStoryMode && !playedCutscene)
				{
					blackScreen.alpha = 1;
					inCutscene = true;
					playedCutscene = true;
					FlxTween.tween(loadingIcon, {alpha: 0}, 0.1, {type: ONESHOT, ease: FlxEase.smootherStepIn, onComplete: function(twn:FlxTween)
					{
						video.playVideo(Paths.video('week2/startcutscene'));
						video.finishCallback = function()
						{
							loadingIcon.alpha = 0;
							if (!PlayStateChangeables.Optimize)
								desperationIntro();
							else
								startCountdown();
						}
					}});
				}
				else
					startCountdown();
			case 'disagreement':
				hasSubtitles = true;
				if (isStoryMode && !playedCutscene)
				{
					health = 1;
					blackScreen.alpha = 1;
					//loadingIcon.alpha = 0;
					//blackScreen.alpha = 1;
					inCutscene = true;
					playedCutscene = true;
					loadingIcon.alpha = 0;
					video.playVideo(Paths.video('week2/midcutscene1'));
					video.finishCallback = function()
					{
						startCountdown();
					}
				}
				else
					startCountdown();
				camZooming = true;
			case 'retaliation':
				//trace("YOU BETTER BE CHANGED FROM " + camFollowSpeed);
				health = 1;
				camFollowSpeed = 0.01;
				hasSubtitles = true;
				//trace("TO " + camFollowSpeed);
				if (isStoryMode && !playedCutscene)
				{
					camFollow.x = dad.getGraphicMidpoint().x;
					camFollow.y = dad.getGraphicMidpoint().y - 50;
					loadingIcon.alpha = 0;
					blackScreen.alpha = 1;
					inCutscene = true;
					playedCutscene = true;
					//This is here cause the previous song ends with a black screen
					FlxTween.tween(loadingIcon, {alpha: 0}, 0.1, {type: ONESHOT, ease: FlxEase.smootherStepIn, onComplete: function(twn:FlxTween)
					{
						videoMusic = FlxG.sound.play(Paths.videoMusic('week2/midcutscene2-MUSIC'), 0.7);
						videoMusic.autoDestroy = true;
						videoMusic.looped = false;
						video.playVideo(Paths.video('week2/midcutscene2'), false, false);
						video.finishCallback = function()
						{
							if (!PlayStateChangeables.Optimize)
								lightningStrikeShit();
							camEXT.flash(FlxColor.WHITE, Conductor.crochet * 2 / 1000);
							blackScreen.alpha = 0;
							camGame.zoom += 0.45;
							FlxTween.tween(camGame, {zoom: camGame.zoom - 0.45}, Conductor.crochet * 8 / 1000, {type: ONESHOT, ease: FlxEase.expoOut});
							camShake(true, true, 'camGame', 0.01, Conductor.crochet * 2 / 1000);
							videoMusic.fadeOut(0.8);
							skipCountdown = true;
							loadingIcon.alpha = 0;

							startCountdown();
						}
					}});
				}
				else
					startCountdown();
			case 'kid-with-a-gun':
				hasSubtitles = true;
				startCountdown();
			case 'playing-with-fire':
				hasSubtitles = true;
				camFollowSpeed = 0.035;
				add(avoidBulletTipGraphic);
				startCountdown();
			case 'variegated-skylines':
				stageParticles.visible = true;
				hasSubtitles = true;
				startCountdown();
			case 'sudden-confrontation' | 'sprouting-irritation':
				if (isStoryMode && !playedCutscene)
				{
					camFollow.x = gf.getGraphicMidpoint().x + 60;
					camFollow.y = gf.getGraphicMidpoint().y - 60;
					playedCutscene = true;
				}
				startCountdown();
			default:
				camZooming = true;
				startCountdown();
		}
	
		if (hasSubtitles && FlxG.save.data.subtitles)
		{
			add(subtitleBackground);
			add(subtitleText);
		}

		Paths.clearUnusedMemory();

		if ((isStoryMode && storyWeek == 0) || !isStoryMode) //hummuna humman change this if you want to reenable results in story mode (0)
			doReplayShit = true;

		defaultMashingThreshold = -storyDifficulty * 5 + (10 + Math.round(DiffCalc.CalculateDiff(SONG)));
		mashPressThreshold = defaultMashingThreshold;

		FlxG.game.soundTray.silent = false;
	}

	private function doCachingShits():Void
	{
		//Preloading Sounds and Music (to prevent laggy euGh  AHFHGAGJMNOmnSKDVkks yes)
		//i am going insane (at how unsure I am if this is good or not [clarified by future me to prevent any concerned parents hehe])
		//i think i made it as robiust (haha bust) as it can
		//nvm i found out that psych did it better *cries*

		if(!Main.todayIsSunday)
		{
			switch (storyWeek)
			{
				case 2:
					pauseMusicName = 'pauseScreen/callous_desperation';
				case 3:
					if (songLowercase != 'variegated-skylines')
						pauseMusicName = 'pauseScreen/heated_stalemate';
					else
						pauseMusicName = 'pauseScreen/holy_shit_the_stalemate_is_on_fire';
				default:
					pauseMusicName = 'pauseScreen/bathroom_break';
			}
		}
		else
			pauseMusicName = 'pauseScreen/today_is_a_sunday_pauseMix';

		//Caching the game stuffs
		var preloadList:Map<String, String> = new Map<String, String>();
		//Sounds
		//Per-song load

		//This will get uncached if cachemusic is off to save RAM
		if (!FlxG.save.data.cacheMusic)
		{
			preloadList.set(SONG.song, 'inst');
			if (SONG.needsVoices)
				preloadList.set(SONG.song, 'voices');
			if (SONG.needsMiscs)
				preloadList.set(SONG.song, 'miscs');
			if (SONG.needsAdaptiveMus)
				preloadList.set(SONG.song, 'adaptiveMus');
		}

		switch (SONG.song)
		{
			case "Mic Test":
				preloadList.set('skipButton', 'image-in-week-library');
			case "Desperation" | "Disagreement" | "Retaliation":
				preloadList.set('glitch_1', 'sound-in-week-library');
				preloadList.set('glitch_2', 'sound-in-week-library');
				if (SONG.song == 'Desperation')
				{
					dadSwaperoo = "priest-theborderannoyed";
					preloadList.set('Table_Crash', 'sound-in-week-library');
				}
				else if (SONG.song == 'Retaliation')
					preloadList.set('week2/midcutscene2-MUSIC', 'video-music');
			case "Variegated Skylines":
				var leLoopCount:Int = 0;
				for (i in 0...9)
				{
					preloadList.set('theCityPortalOpen/effects/stageParticle_' + leLoopCount, 'image-in-week-library');
					leLoopCount++;
				}
			case "Finale":
				var soundNameArr:Array<String> = ["drums_0", "drums_1", "drums_2", "drums_3", "drums_climax", "taiko_0", "taiko_1", "taiko_2", "taiko_3", 
				"taiko_4", "taiko_5", "choir_0", "choir_1", "hats_0", "hats_1", "woodwinds", "violin", "slayer_0", "slayer_1", "slayer_climax", "retal-hats_0", 
				"retal-hats_1", "bells_0", "bells_1", "pads_0", "pads_1", "pads_climax", "pads_climax_bosslowhp", "elecpiano_climax", "danger-loop", "stab"]; //THANK YOU BSOD#2524 FROM HAXE DISCORD SERVER!!!!
				for (i in soundNameArr) 
					preloadList.set('finaleAdaptiveMus/' + i, 'music');
		}

		preloadList.set(pauseMusicName, 'music');

		if (dadSwaperoo != "" && !FlxG.save.data.cacheImages)
		{
			preloadList.set("characters/" + dadSwaperoo, 'image');
			var swaperooIconPath:String = 'icons/' + PlayStateHelpers.getIconID(dadSwaperoo);
			preloadList.set(swaperooIconPath, 'image');
		}
		#if debug
		else
			trace ("wHAT A SMART DADDY~");
		#end

		lowHPHeartBeat = new FlxSound().loadEmbedded(Paths.sound('lowHP'));
		styleSound = new FlxSound().loadEmbedded(Paths.sound('styleOnEm'));
		missSound = new FlxSound();

		//Le GameOver Music and SFX
		preloadList.set("deathsound" + stageSuffix, 'sound');
		preloadList.set("gameOver" + stageSuffix, 'music');
		preloadList.set("gameOver" + stageSuffix + "_End", 'music');
		preloadList.set('Gameover_0', 'image');
		preloadList.set('Gameover_1', 'image');
		
		var gameplaySFX:Array<String> = ["skipSongIntro", "intro3", "intro2", "intro1", "introGo", "missnote1", "missnote2", "missnote3", "enemyMiss1", "enemyMiss2", "enemyMiss3", "GitarooFail", "GitarooPress", "GitarooHover", "practiceModeFail", "styleOnEm"]; //THANK YOU STILL BSOD#2524 FROM HAXE DISCORD SERVER!!!!
		for (i in gameplaySFX) 
			preloadList.set(i, 'sound');

		var imagesToCache:Array<String> = [];
		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images")))
		{
			if (i.endsWith(".png") && i != "lol.png" && i != "screencapTierImage.png" && i != "zzzzzzzz.png")
			{
				i = StringTools.replace(i, ".png", "");
				imagesToCache.push(i);
			}
		}

		for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/countdown")))
		{
			if (i.endsWith(".png"))
			{
				i = 'countdown/' + StringTools.replace(i, ".png", "");
				imagesToCache.push(i);
			}
		}
		for (i in imagesToCache) 
			preloadList.set(i, 'image');

		for (i in 0...10) 
			preloadList.set('num' + i, 'image');

		musicGroup = new FlxSoundGroup(1);
		specilNoteSFXGroup = new FlxSoundGroup(1);
		if (FlxG.save.data.notesfx)
		{
			hitSFXGroup = new FlxSoundGroup(1);
			susHitSFXGroup = new FlxSoundGroup(1);
			if (PlayStateChangeables.botPlay)
				hitsoundType = "botplay";
			else
				hitsoundType = FlxG.save.data.notesfxType;

			if (!PlayStateChangeables.botPlay)
			{
				var soundsToPreload:Array<String> = [];
				switch (hitsoundType)
				{
					case "chill":
						soundsToPreload = ["Note_chill_Sick", "Note_chill_Good", "Note_chill_Bad", "Note_chill_Crap", "Note_chill_Sustain"];
					case "osu":
						soundsToPreload = ["Note_osu_Sick", "Note_osu_Good", "Note_osu_Bad", "Note_osu_Crap", "Note_osu_Sustain"];
					case "bubble":
						soundsToPreload = ["Note_bubble_Sick", "Note_bubble_Good", "Note_bubble_Bad", "Note_bubble_Crap", "Note_bubble_Sustain"];
					case "custom":
						soundsToPreload = ["Note_custom_Sick", "Note_custom_Good", "Note_custom_Bad", "Note_custom_Crap", "Note_custom_Sustain"];
					default:
						soundsToPreload = ["Note_default_Sick", "Note_default_Good", "Note_default_Bad", "Note_default_Crap", "Note_default_Sustain"];
				}
				
				for (i in soundsToPreload)
					preloadList.set(i, 'sound');
			}
			preloadList.set('Note_botplay', 'sound');

			if (SONG.song == "Playing With Fire" || SONG.song == "Variegated Skylines")
			{
				preloadList.set('Note_Mine', 'sound');
				preloadList.set('Note_Trigger', 'sound');
				preloadList.set('damageAlert_1', 'sound');
				preloadList.set('damageAlert_2', 'sound');
				preloadList.set('damageAlert_3', 'sound');
				preloadList.set('damageAlert_fail', 'sound');
			}
		}

		var pathLibrary:String = "week" + storyWeek;
		if (storyWeek == 0)
			pathLibrary = "tutorial";

		//CacheAllShits
		for (key => type in preloadList)
		{
			switch(type)
			{
				case 'image':
					Paths.image(key);
				case 'image-in-week-library':
					Paths.image(key, pathLibrary);
				case 'sound':
					Paths.sound(key);
				case 'sound-in-week-library':
					Paths.sound(key, pathLibrary);
				case 'music':
					Paths.music(key);
				case 'music-in-week-library':
					Paths.music(key, pathLibrary);
				case 'video-music':
					Paths.videoMusic(key);
				case 'inst':
					Paths.inst(key);
				case 'voices':
					Paths.voices(key);
				case 'miscs':
					Paths.miscs(key);
				case 'adaptiveMus':
					Paths.adaptiveMus(key);
			}
			#if debug
			trace("Preloaded " + key + " (" + type + ")");
			#end
		}

		didCachingShits = true;
	}

	function desperationIntro():Void
	{
		generateStaticArrows(0);
		generateStaticArrows(1);
		if (blackScreen.alpha > 0 || camHUD.alpha <= 0)
		{
			FlxTween.tween(camHUD, {alpha: 1}, 1, {type: ONESHOT, ease: FlxEase.quadOut, startDelay: 0.3});
			FlxTween.tween(blackScreen, {alpha: (!Main.nightMode && !FlxG.save.data.nightmode ? 0 : 0.25)}, 1, {type: ONESHOT, ease: FlxEase.quadOut, startDelay: 0.3});
		}
		inCutscene = true;
		canPause = false;
		gf.playAnim('none', true);
		camFollow.x =  gf.getGraphicMidpoint().x;
		camFollow.y =  gf.getGraphicMidpoint().y - 30;
		new FlxTimer().start(Conductor.crochet / 1000, function(swagTimer:FlxTimer)
		{
			FlxG.sound.play(Paths.sound('intro3'), 0.6);
			boyfriend.playAnim('idle', true);
			dad.playAnim('danceLeft', true);
			gf.playAnim('none', true);
			new FlxTimer().start(Conductor.crochet / 1000, function(swagTimer:FlxTimer)
			{
				var ready:FlxSprite = new FlxSprite(-650, 590).loadGraphic(Paths.image('countdown/ready'));
				ready.y = 225;
				ready.scrollFactor.set();
				ready.updateHitbox();
				ready.screenCenter(X);
				ready.cameras = [camHUD];
				if(FlxG.save.data.antialiasing)
					{
						ready.antialiasing = true;
					}
				add(ready);
				FlxTween.tween(ready, {y: ready.y + 5, alpha: 0}, Conductor.crochet / 1000, {type: ONESHOT, 
					ease: FlxEase.cubeInOut,
					onComplete: function(twn:FlxTween)
					{
						ready.destroy();
					}
				});
				FlxG.sound.play(Paths.sound('intro2'), 0.6);
				dad.playAnim('danceRight', true);
				gf.playAnim('none', true);
				new FlxTimer().start(Conductor.crochet / 1000, function(swagTimer:FlxTimer)
				{
					camHUD.alpha = 0;
					camFollow.y =  gf.getGraphicMidpoint().y + 20;
					FlxG.sound.play(Paths.sound('Table_Crash', 'week2'));
					gf.playAnim('fall', true);
					new FlxTimer().start(0.15, function(swagTimer:FlxTimer)
					{
						camShake(true, true, 'camGame', 0.04, 0.5);
						boyfriend.playAnim('scared', true);
						dad.playAnim('scared', true);
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							new FlxTimer().start(0.7, function(swagTimer:FlxTimer)
							{
								camHUD.alpha = 1;
								startCountdown();
								canPause = true;
							});
						});
					});
				});
			});
		});
	}

	var subTxtXTween:FlxTween;
	var subBGWidthTween:FlxTween;
	var subBGXTween:FlxTween;
	var prevText:String = 'ThisWillNEVERBeUsedAsASubtitleIsntThatWeird???';

	function changeSubtitles(text:String, color:FlxColor = 0xFFFFFFFF, borderColour:FlxColor = 0xFF000000, blendMode:String = "NORMAL", alpha:Float = 1, bgAlpha:Float = 0.45, font:String = 'Playtime With Hot Toddies', isBold:Bool = false, isItalic:Bool = false):Void
	{
		//Mmm sphagetti code
		if (hasSubtitles && FlxG.save.data.subtitles && !endedSong)
		{
			var subTxtTargetX:Float = 0;
			var subBGTargetWidth:Float = 0;

			if (text == "")
				clearSubtitles();

			subtitleText.font = font;
			switch (subtitleText.font)
			{
				case "VCR OSD Mono":
					subtitleText.size = 32;
				case "Times New Roman":
					subtitleText.size = 36;
				default:
					subtitleText.size = 38;
			}
			if (subtitleText.text != "")
				prevText = subtitleText.text;
			subtitleText.text = text;
			subtitleText.color = color;
			subtitleText.borderColor = borderColour;
			subtitleText.bold = isBold;
			subtitleText.italic = isItalic;
			subtitleText.blend = blendMode;
			subtitleText.alpha = alpha;

			subtitleBackground.alpha = bgAlpha * subtitleText.alpha;
			subBGTargetWidth = subtitleText.width + 20;
			subtitleBackground.scale.y = subtitleText.height;

			var hideChars:Array<String> = ['.', ',', '~', '!', '@', '#', '$', '%', '^', '&', '*', '(', ')',
			 '[', ']', '{', '}', '-', "+", '_', '=', '<', '>', '|', '/', '`'];

			//TweenCheck
			prevText = StringTools.trim(prevText).toLowerCase();
			//Change the 'text' variable since we aint gonna use it for anything no mo
			text = StringTools.trim(text).toLowerCase();
			//this better not lag
			//nope!
			for (character in hideChars)
			{
				text = StringTools.replace(text, character, "");
				prevText = StringTools.replace(prevText, character, "");
			}
			//trace("Does '" + text + "' contain " + prevText + "??");
			if (StringTools.contains(text, prevText))
			{
				if (FlxG.save.data.centersubtitles)
					subTxtTargetX = healthBarBG.x + (healthBarBG.width - subtitleText.width) / 2;
				else
					subTxtTargetX = subtitleText.x;
	
				if (subTxtXTween != null)
					subTxtXTween.cancel();
				subTxtXTween = FlxTween.tween(subtitleText, {x: subTxtTargetX}, 0.2, {type: ONESHOT, ease: FlxEase.quartOut, onComplete:
					function (twn:FlxTween)
					{
						subTxtXTween = null;
					}
				});
	
				if (subBGWidthTween != null)
				{
					subBGWidthTween.cancel();
					subtitleBackground.updateHitbox();
				}
				subBGWidthTween = FlxTween.tween(subtitleBackground.scale, {x: subBGTargetWidth}, 0.025, {type: ONESHOT, ease: FlxEase.quartOut, onComplete:
					function (twn:FlxTween)
					{
						subBGWidthTween = null;
						subtitleBackground.updateHitbox();
					}
				});
				subtitleBackground.updateHitbox();
	
				if (subBGXTween != null)
					subBGXTween.cancel();
				subBGXTween = FlxTween.tween(subtitleBackground, {x: subTxtTargetX - 10}, 0.15, {type: ONESHOT, ease: FlxEase.quartOut, onComplete:
					function (twn:FlxTween)
					{
						subBGXTween = null;
					}
				});	
			}
			else
			{
				if (subTxtXTween != null)
					subTxtXTween.cancel();
				if (subBGWidthTween != null)
					subBGWidthTween.cancel();
				if (subBGXTween != null)
					subBGXTween.cancel();
				if (FlxG.save.data.centersubtitles)
					subtitleText.x = healthBarBG.x + (healthBarBG.width - subtitleText.width) / 2;
				subtitleBackground.scale.x = subtitleText.width + 20;
				subtitleBackground.updateHitbox();
				subtitleBackground.x = subtitleText.x - 10;
			}

			if (PlayStateChangeables.botPlay)
			{
				botPlayText.alpha = 0.5;
				subtitleText.y = defaultSubTxtY + (PlayStateChangeables.useDownscroll ? botPlayText.height : -botPlayText.height);
			}
			subtitleBackground.y = subtitleText.y;

			subtitleText.visible = true;
			subtitleBackground.visible = true;
		}
	}

	//var funnySubtitleFormat:FlxTextFormat;

	/*function addSubtitles(textToAdd:String, otherColor:FlxColor = 0xFFFFFFFF, otherBorderColor:FlxColor = 0xFF000000, otherFont:String = 'Playtime With Hot Toddies', isAlsoBold:Bool = false, isAlsoItalic:Bool = false):Void
	{
		funnySubtitleFormat = new FlxTextFormat(otherColor, isAlsoBold, isAlsoItalic, otherBorderColor);
		subtitleText.text = subtitleText.text + textToAdd;
		trace (subtitleText.text);
		subtitleText.addFormat(funnySubtitleFormat, subtitleText.text.length + 1);
		subtitleBackground.scale.x = subtitleText.width + 20;
		subtitleBackground.scale.y = subtitleText.height;
		if (FlxG.save.data.centersubtitles)
			subtitleText.x = healthBarBG.x + (healthBarBG.width - subtitleText.width) / 2;
		subtitleText.y += (!PlayStateChangeables.useDownscroll ? -subtitleText.height / 2 : subtitleText.height / 2);
		subtitleBackground.y = subtitleText.y;
	}*/

	function clearSubtitles():Void
	{
		if (PlayStateChangeables.botPlay)
			botPlayText.alpha = 1;
		subtitleText.text = "";
		prevText = "ThisWillNEVERBeUsedAsASubtitleIsntThatWeird???";
		subtitleText.blend = NORMAL;
		subtitleText.y = defaultSubTxtY;
		subtitleText.visible = false;
		subtitleText.alpha = 0;
		subtitleBackground.visible = false;
		subtitleBackground.alpha = 0;
		//subtitleText.clearFormats();
	}

	var startTimer:FlxTimer;

	function startCountdown(altSuffix:String = ""):Void
	{
		#if debug
		trace("StartCountdown");
		#end

		initialized = true;

		if (delayAutoPause)
			FlxG.autoPause = true;

		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Get Ready..!", null);
		#end

		if (!generatedArrows)
		{
			botPlayText.visible = true;
			if (!PlayStateChangeables.Optimize)
				generateStaticArrows(0);
			generateStaticArrows(1);
		}

		if (!showedLoadingIcon)
			FlxTween.tween(loadingIcon, {alpha: 0}, 0.3, {type: ONESHOT, ease: FlxEase.smootherStepIn, startDelay: 0.1});

		if (blackScreen.alpha != blackScreenFadeTo)
		{
			FlxTween.tween(blackScreen, {alpha: blackScreenFadeTo}, 1, {type: ONESHOT, ease: FlxEase.quadOut, startDelay: 0.3});
		}

		if (!isStoryMode || storyProgress > 0 && (SONG.song != 'Mic Test' || !hasReset && campaignDeaths <= 0))
		{
			camFollowShit();
		}
		else
		{
			camFollow.x = gf.getGraphicMidpoint().x;
			camFollow.y = gf.getGraphicMidpoint().y;
		}
			
		startedCountdown = true;

		Conductor.songPosition = 0;

		//if (!skipCountdown)
		//{
		var swagCounter:Int = 0;
		var startTimerTime:Float = Conductor.crochet / 1000;
		if (!skipCountdown)
			Conductor.songPosition = -Conductor.crochet * 5;
		else
			startTimerTime = 0;

		for (daNote in notes) 
		{
			if (daNote.scrollSpeed != defaultScroll)
				daNote.scrollSpeed = defaultScroll;
		}

		startTimer = new FlxTimer().start(startTimerTime, function(tmr:FlxTimer)
		{
			if (!skipCountdown)
			{
				if (!PlayStateChangeables.Optimize)
				{
					switch(songLowercase)
					{
						case "tech.-difficulties":
							dad.dance();
							gf.dance();
							//if (boyfriend.animation.curAnim.name != 'phoneHide')
							boyfriend.playAnim('idle');
						case "disagreement" | "retaliation" | "playing-with-fire":
							dad.dance();
							gf.dance();
							if (boyfriend.animation.curAnim.name != 'scaredHOLD')
								boyfriend.playAnim('scaredHOLD');
						case "variegated-skylines":
							camShake(false, false, 'camGame', 0.002, idleCamShakeTimer);
							if (swagCounter == 1 || swagCounter == 3)
								createStageParticle('theCityPortalOpen/effects/stageParticle');
							dad.dance();
							gf.dance();
							boyfriend.playAnim('idle');
						default:
							dad.dance();
							gf.dance();
							boyfriend.playAnim('idle');
					}
				}

				swagCounter += 1;

				switch (swagCounter)
				{
					case 1:
						FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
					case 2:
						var ready:FlxSprite = new FlxSprite(0, 225).loadGraphic(Paths.image("countdown/ready" + altSuffix));
						ready.cameras = [camHUD];
						if(FlxG.save.data.antialiasing)
							ready.antialiasing = true;		
						ready.screenCenter();
						add(ready);

						FlxTween.tween(ready, {y: ready.y + 5, alpha: 0}, Conductor.crochet / 1000, {type: ONESHOT, 
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								ready.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
					case 3:
						var set:FlxSprite = new FlxSprite(0, 220).loadGraphic(Paths.image("countdown/set" + altSuffix));
						set.cameras = [camHUD];
						if(FlxG.save.data.antialiasing)
							set.antialiasing = true;	
						set.screenCenter();
						add(set);

						FlxTween.tween(set, {y: set.y + 5, alpha: 0}, Conductor.crochet / 1000, {type: ONESHOT, 
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								set.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
					case 4:
						var go:FlxSprite = new FlxSprite(0, 185).loadGraphic(Paths.image("countdown/go" + altSuffix));
						go.cameras = [camHUD];
						if(FlxG.save.data.antialiasing)
							go.antialiasing = true;
						go.screenCenter();
						add(go);

						FlxTween.tween(go, {y: go.y + 5, alpha: 0}, Conductor.crochet / 1000, {type: ONESHOT, 
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								go.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				}
			}
		}, 5);
		//}
		//else
		//	inCutscene = false;
		//	startTimer = new FlxTimer().start(0);
	}

	var keys = [false, false, false, false];
	function handleInput(event:KeyboardEvent):Void // this actually handles press inputs
	{
		if (PlayStateChangeables.botPlay || paused)
			return;

		var eventKey:FlxKey = event.keyCode;
		var key:Int = getKeyFromEvent(event.keyCode);

		if (startedCountdown && key > -1 && FlxG.keys.checkStatus(eventKey, JUST_PRESSED))
		{
			var ana = new Ana(Conductor.songPosition, null, false, "miss", key);
			var sortedNotesList:Array<Note> = [];
			var pressNotes:Array<Note> = [];
			var notesStopped:Bool = false;
			
			keys[key] = true;

			//more accurate hit time for the ratings?
			//AJAJAJAJAJAJAJA PSYCHN HENGINE AFAJG
			var lastTime:Float = Conductor.songPosition;
			if (FlxG.sound.music.time < musicTimeCusp)
				Conductor.songPosition = FlxG.sound.music.time;

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
					if(daNote.noteData == key)
						sortedNotesList.push(daNote);
			}); // Collect notes that can be hit

			sortedNotesList.sort(sortHitNotes); // sort by the earliest note

			if (sortedNotesList.length > 0) 
			{
				for (epicNote in sortedNotesList)
				{
					if (epicNote.isSustainNote) // Note is null, which means it's probably a sustain note. Update will handle this (HOPEFULLY???)
						return;

					for (doubleNote in pressNotes) 
					{
						if (Math.abs(doubleNote.strumTime - epicNote.strumTime) < 1) 
						{
							doubleNote.kill();
							notes.remove(doubleNote, true);
							doubleNote.destroy();
						} 
						else
							notesStopped = true;
					}

					// eee jack detection before was not super good
					if (!notesStopped) 
					{
						if (!epicNote.delayedDeath)
							goodNoteHit(epicNote);
						pressNotes.push(epicNote);
						var noteDiff:Float = -(epicNote.strumTime - Conductor.songPosition);
						if (doReplayShit) // hummuna humman change this if you want to reenable results in story mode (6)
						{
							ana.hit = true;
							ana.hitJudge = Ratings.CalculateRating(noteDiff, Math.floor(PlayStateChangeables.safeZoneOffset));
							ana.nearestNote = [epicNote.strumTime, epicNote.noteData, epicNote.sustainLength];
						}	
					}
				}
			}
			else if (songStarted && allowHealthModifiers)
			{
				if (!FlxG.save.data.ghost)
				{
					noteMiss(key, null);
					if (doReplayShit) // hummuna humman change this if you want to reenable results in story mode (6)
					{
						ana.hit = false;
						ana.hitJudge = "shit";
						ana.nearestNote = [];
					}
					songScore -= 50;
					//uhh what happens if i-
					if (allowHealthModifiers)
					{
						if (targetHealth >= 0.35)
							targetHealth -= 0.10;
						else
							targetHealth -= 0.075;
					}
				}
				else
				{
					//Antimash
					if (nearestNoteUpcoming)
					{		
						mashPresses++;
					
						if (mashPresses > mashPressThreshold)
						{
							mashing = true;
							accuracy -= 0.2;
							targetHealth += PlayStateHelpers.calculateHealth(storyDifficulty, 9);
							updateAccuracy();
							#if debug
							trace("BRO STOP SPAMMING - " + mashPresses + ' | ' + mashPressThreshold);
							#end
						}
						else
							mashing = false;
					}
				}
			}

			//more accurate hit time for the ratings? part 2 (Now that the calculations are done, go back to the time it was before for not causing a note stutter)
			//PSYCHENGINE MMGMSAGMSGMMMMMMMMM
			Conductor.songPosition = lastTime;
		}
	}

	private function sortHitNotes(a:Note, b:Note):Int
	{
		if (a.lowPriority && !b.lowPriority)
			return 1;
		else if (!a.lowPriority && b.lowPriority)
			return -1;

		return FlxSort.byValues(FlxSort.ASCENDING, a.strumTime, b.strumTime);
	}

	private function releaseInput(event:KeyboardEvent):Void // handles releases
	{
		var key:Int = getKeyFromEvent(event.keyCode);

		if (key == -1)
			return;

		keys[key] = false;
	}

	private function getKeyFromEvent(keyCode:Int):Int
	{
		@:privateAccess
		var keyString:String = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(keyCode));
		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];
		var data = -1;

		switch (keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == keyString.toLowerCase())
				data = i;
		}

		return data;
	}

	public static var songStarted = false;
	//1 beat before music end
	var musicTimeCusp:Float = 0;
	var musicBeatCusp:Int = 0;

	private function startSong():Void
	{
		startingSong = false;
		songStarted = true;

		inCutscene = false;
		doCamFollowing = true;

		if (!FlxG.sound.music.playing) //don't restart the music if it's already playing
		{
			if (SONG.song != "Finale")
			{
				FlxG.sound.playMusic(Paths.inst(SONG.song), 1, false);
				FlxG.sound.music.looped = false;
				FlxG.sound.music.onComplete = endSong;
			}
			else
			{
				FlxG.sound.playMusic(Paths.inst(SONG.song), 1, false);
				FlxG.sound.music.looped = true;
				FlxG.sound.music.autoDestroy = false;
				FlxG.sound.music.onComplete = regenerateSong;
			}
		}

		musicTimeCusp = FlxG.sound.music.length - Conductor.crochet;
		musicBeatCusp = Math.round(musicTimeCusp / Conductor.crochet);
		//#if debug
		trace('1 Beat before music end = ' + musicTimeCusp + ' (in miliseconds) | ' + musicBeatCusp + ' (in beats)');
		//#end

		//Beat 0 Events (cause beathit doesnt update properly lmao)
		doSubtitleShit();
		if (SONG.notes[Std.int(curStep / 16)].mustHitSection)
			isBFTurn = true;
		else
			isBFTurn = false;

		instLowHP.time = FlxG.sound.music.time;
		instLowHP.play();
		musicGroup.add(instLowHP);
		vocals.play();
		miscs.play();
		/*IDEA FOR THE FINALE 7:25 FEB-02-2022
		[] Song Intro: Music's Intro/Prelude like with Asgore when you fight him. Bergentrückung (intro) is a different
			track compared ASGORE (Battle Music). Not sure yet if we should do the countdown thingy or not (Edit [4/2/32]: probably not).
		[] Music: Is the leitmotif of Retaliation except more epic and adaptive. There will be different drum loops
			(or just loops in general?) for each attack/event and the music is to inform the player about what
			is happening and what will happen. 
		[] Game Over Screen: Is an animation (accompanied by sfx) of a candle going out with the word retry slowly appearing. 
			Game over music is melancholic, yet calm and hopeful just like the original game over themes. Sample the "Don't
			Stop" vocals somewhere. Pressing ENTER will Reignite the candle, and make the retry light up and the camera zoom out
			and slowly zoom back in. The music will be of a buildup with of course either a cello strum or a chime hit at the end.*/


		// Song duration in a float, useful for the time left feature
		if (!paused)
			songLength = FlxG.sound.music.length;

		if (FlxG.save.data.songPosition)
		{
			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('timePosBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height - songPosBG.height - 10;
			songPosBG.screenCenter(X);
			songPosBG.color = FlxColor.BLACK;
			songPosBG.x += 10;
			//songPosBG.scrollFactor.set();

			songPosBar = new FlxBar(songPosBG.x
				+ 4, songPosBG.y
				+ 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength
				- 1000);
			songPosBar.numDivisions = 800;
			//songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(0xFF333333, 0xFFeb829c);

			songPosDeathIndicator = new FlxSprite(-1000, 10).loadGraphic(Paths.image('timePosBar_DeathMarker'));
			if(!PlayStateChangeables.useDownscroll)
			{
				songPosDeathIndicator.flipY = true;
				songPosDeathIndicator.y = songPosBar.y;
			}
			else
				songPosDeathIndicator.y = songPosBar.y - (40 + songPosBar.height);
			if(FlxG.save.data.antialiasing)
				songPosDeathIndicator.antialiasing = true;

			songPosClock = new FlxSprite(songPosBG.x - 20, songPosBG.y - 6).loadGraphic(Paths.image('timePosClock'));

			songDurationTxt = new FlxText(songPosBG.x, songPosBG.y - 6, 0, "--:--", 16);
			songDurationTxt.screenCenter(X);
			songDurationTxt.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songDurationTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3, 3);
			//songDurationTxt.scrollFactor.set();

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songPosDeathIndicator.cameras = [camHUD];
			songPosClock.cameras = [camHUD];
			songDurationTxt.cameras = [camHUD];
			songPosGroup.cameras = [camHUD];

			songPosGroup.add(songPosBG);
			songPosGroup.add(songPosBar);
			songPosGroup.add(songPosDeathIndicator);
			songPosGroup.add(songPosClock);
			songPosGroup.add(songDurationTxt);

			songPosGroup.forEach(function(blep:FlxSprite)
			{
				blep.alpha = 0;
				blep.y -= 15;
				FlxTween.tween(blep, {alpha: 1, y: blep.y + 15}, 1, {type: ONESHOT, ease: FlxEase.elasticOut});
			});
		}
		else
			strumLine.y -= 15;

		/*if (useVideo)
			GlobalVideo.get().resume();*/

		#if windows
		if (FlxG.save.data.showPresence)
		{
			// Updating Discord Rich Presence (with Time Left)
			DiscordClient.changePresence(detailsText
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ")   ",
				"\nRating: "
				+ Ratings.GenerateLetterRank(accuracy)
				+ " ("
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "%) | Score: "
				+ songScore
				+ " | Misses: "
				+ misses); //, iconRPC
		}
		#end

		if (startTime > 0)
		{
			setSongTime(startTime);
			clearNotesBefore(startTime);

		}
		else
		{
			vocals.time = FlxG.sound.music.time;
			instLowHP.time = FlxG.sound.music.time;
			miscs.time = FlxG.sound.music.time;
			Conductor.songPosition = FlxG.sound.music.time;
		}

		if (needSkip)
		{
			skipActive = true;
			//Note: Add anim for this lmao
			switch(songLowercase)
			{
				case "mic-test":
					skipButton = new FlxSprite(0, healthBar.y).loadGraphic(Paths.image('skipButton', 'tutorial'));
				default:
					skipButton = new FlxSprite(0, healthBar.y).loadGraphic(Paths.image('skipButton'));
			}
			skipButton.x = FlxG.width - skipButton.width - 35;
			if(!PlayStateChangeables.useDownscroll)
				skipButton.y = FlxG.height - skipButton.height - 10;
			else
				skipButton.y = 10;
			skipButton.y += 5;
			if(FlxG.save.data.antialiasing)
				skipButton.antialiasing = true;
			skipButton.updateHitbox();
			skipButton.cameras = [camEXT];
			skipButton.alpha = 0;
			add(skipButton);
			FlxTween.tween(skipButton, {alpha: 1, y: skipButton.y - 5}, 0.2, {type: ONESHOT, ease: FlxEase.sineInOut});
		}
	}

	public function generateSong(dataPath:String):Void
	{
		var songData = SONG;
		//Conductor.changeBPM(songData.bpm);
		//fakeCrochet = (60 / songData.bpm) * 1000;
		//idleCamShakeTimer = Conductor.crochet / 1000 - 0.01;
		//compensationTime = Conductor.crochet * 2 / 1000;

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(SONG.song));
		else
			vocals = new FlxSound();
		FlxG.sound.list.add(vocals);



		if (SONG.needsMiscs)
			miscs = new FlxSound().loadEmbedded(Paths.miscs(SONG.song));
		else
			miscs = new FlxSound();
		FlxG.sound.list.add(miscs);



		if (SONG.needsAdaptiveMus)
			instLowHP = new FlxSound().loadEmbedded(Paths.adaptiveMus(SONG.song), FlxG.sound.music.looped);
		else
			instLowHP = new FlxSound();
		instLowHP.volume = 0;
		FlxG.sound.list.add(instLowHP);



		switch (SONG.song)
		{
			case "Retaliation":
				miscs.volume = 0.5;
			case "Finale":
				vocals.looped = true;
		}

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		// Per song offset check
		#if windows
		// pre lowercasing the song name (generateSong)

		var songPath = 'assets/data/' + songLowercase + '/';

		for (file in sys.FileSystem.readDirectory(songPath))
		{
			var path = haxe.io.Path.join([songPath, file]);
			if (!sys.FileSystem.isDirectory(path))
			{
				if (path.endsWith('.offset'))
				{
					//trace('Found offset file: ' + path);
					songOffset = Std.parseFloat(file.substring(0, file.indexOf('.off')));
					break;
				}
				else
				{
					//trace('Offset file not found. Creating one @: ' + songPath);
					sys.io.File.saveContent(songPath + songOffset + '.offset', '');
				}
			}
		}
		#end
		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped


		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				//This is were the notes are created!
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset + songOffset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var daNoteStyle:String = songNotes[3];

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				if (!gottaHitNote && PlayStateChangeables.Optimize)
					continue;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, daNoteStyle);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollSpeed = defaultScroll;

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				if (susLength > 0)
					swagNote.isParent = true;
				unspawnNotes.push(swagNote);

				var type = 0;

				//this is where sustain notes are created!
				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, daNoteStyle);
					sustainNote.scrollSpeed = defaultScroll;
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;
					sustainNote.alpha -= 0.1;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}

					sustainNote.parent = swagNote;
					swagNote.children.push(sustainNote);
					sustainNote.spotInLine = type;
					if (type == 0)
					{
						sustainNote.isBehindParent = true;
						//sustainNote.connectSusToParent();
						//sustainNote.connectToParent(strumLine.y);
					}
					type++;
					if (type == Math.floor(susLength - 1))
						sustainNote.isBeforeTail;
				}

				swagNote.mustPress = gottaHitNote;
				swagNote.alpha -= 0.1;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			daBeats += 1;
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	//This is shit
	//actually not really?
	public function regenerateSong():Void
	{
		setSongTime(0);
		vocals.play();
		//musicGroup.play();

		var dataPath:String = SONG.song;
		var songData = SONG;
		curSong = songData.song;

		// NEW SHIT.. AGAIN
		var noteData:Array<SwagSection>;
		noteData = songData.notes;

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset + songOffset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);
				var daNoteStyle:String = songNotes[3];

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, daNoteStyle);

				if (!gottaHitNote && PlayStateChangeables.Optimize)
					continue;

				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set();

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				if (susLength > 0 && !swagNote.isSustainNote)
					swagNote.isParent = true;

				var type = 0;

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, daNoteStyle);
					//sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;
					sustainNote.alpha -= 0.1;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}

					sustainNote.parent = swagNote;
					swagNote.children.push(sustainNote);
					sustainNote.spotInLine = type;
					if (type == 0)
					{
						sustainNote.isBehindParent = true;
						//sustainNote.connectSusToParent();
						//sustainNote.connectToParent(strumLine.y);
					}
					type++;
				}

				swagNote.mustPress = gottaHitNote;
				swagNote.alpha -= 0.1;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
		}

		unspawnNotes.sort(sortByShit);
		resyncVocals();
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	var funnyRatingCheckStart:Float = 0;
	var funnyRatingCheckEnd:Float = 0;
	var daBabyArrowY:Float = 0;
	
	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			//Sloink                                V
			var babyArrow:FlxSprite = new FlxSprite(58, strumLine.y + (!PlayStateChangeables.useDownscroll ? -10 : 10));

			if (PlayStateChangeables.Optimize && player == 0)
				continue;

			babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
			for (j in 0...4)
			{
				babyArrow.animation.addByPrefix(dataColor[j], 'arrow' + dataSuffix[j]);	
			}

			var lowerDir:String = dataSuffix[i].toLowerCase();

			babyArrow.animation.addByPrefix('static', 'arrow' + dataSuffix[i]);
			babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
			babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

			babyArrow.x += Note.swagWidth * i;

			if(FlxG.save.data.antialiasing)
				babyArrow.antialiasing = true;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

			babyArrow.updateHitbox();
			//babyArrow.scrollFactor.set();


			if (storyProgress > 0 && SONG.song != 'Mic Test' && isStoryMode && !hasReset && campaignDeaths == 0)
				babyArrow.y += (!PlayStateChangeables.useDownscroll ? 10 : -10);
			else 
			{
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + (!PlayStateChangeables.useDownscroll ? 10 : -10), alpha: 1}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.circOut, startDelay: Conductor.crochet / 1000 + (0.2 * i)});
			}

			babyArrow.ID = i;

			babyArrow.animation.play('static');
			if(!PlayStateChangeables.Optimize)
				babyArrow.x += 40;
			else
				babyArrow.x -= 275;
			babyArrow.x += (FlxG.width / 2) * player;

			cpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets(); // CPU arrows start out slightly off-center
			});

			switch (player)
			{
				case 0:
					babyArrow.color = 0xFFD8D7D2;
					cpuStrums.add(babyArrow);
				case 1:
					if (FlxG.save.data.strumline)
					{
						var strumlineBG:FlxSprite = new FlxSprite(babyArrow.x - 2, -10).loadGraphic(Paths.image('strumline', 'week' + (storyWeek > 0 ? storyWeek : 1)));
						strumlineBG.antialiasing = FlxG.save.data.antialiasing;

						if (storyProgress > 0 && SONG.song != 'Mic Test' && isStoryMode && !hasReset && campaignDeaths == 0)
						{
							strumlineBG.y = 0;
							strumlineBG.alpha = 0.7;
						}
						else
						{
							strumlineBG.alpha = 0;
							FlxTween.tween(strumlineBG, {y: 0, alpha: 0.5}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.expoOut, startDelay: Conductor.crochet / 500 + (0.2 * i)});
						}
						if (PlayStateChangeables.useDownscroll)
							strumlineBG.flipY = true;

						grpStrumLine.add(strumlineBG);
					}
					playerStrums.add(babyArrow);
					generatedArrows = true;
			}

			strumLineNotes.add(babyArrow);

			if (player == 1)
			{
				if (funnyRatingCheckEnd <= 0)
				{
					funnyRatingCheckStart = babyArrow.x;
					funnyRatingCheckEnd = babyArrow.x + babyArrow.width * 0.7;
				}
				else
					funnyRatingCheckEnd += babyArrow.width * 0.7;

				if (daBabyArrowY == 0)
					daBabyArrowY = babyArrow.y + (!PlayStateChangeables.useDownscroll ? 10 : -10);

				if (songLowercase == 'mic-test')
				{
					tutorialText.members[i].x = babyArrow.x + 40;
					tutorialText.members[i].y = (!PlayStateChangeables.useDownscroll ? babyArrow.y + babyArrow.width - tutorialText.members[i].height : babyArrow.y - babyArrow.width + tutorialText.members[i].height) + 20;
				}
			}
		}
	}

	var finishedHUDFadeOutFunction:Bool = false;

	private function fadeOutGameplayHUD(delayMultiplier:Float):Void
	{
		//Stops tweens from conflicting
		doStrumLineBGTweening = false;
		if (strumLineBGTween != null)
			strumLineBGTween.cancel();

		//delay multiplier guide: set to 0 for no delay, 1 for default delay, below 1 to shorten and beyond 1 to prolong
		strumLineNotes.forEach(function(babyArrow:FlxSprite)
		{
			for (i in 0...4)
			{
				babyArrow.acceleration.y = 900;
				babyArrow.velocity.y -= FlxG.random.int(20, 75);
				babyArrow.velocity.x += FlxG.random.int(-20, 20); 
				FlxTween.tween(babyArrow, {alpha: 0}, 0.5, {type: ONESHOT, ease: FlxEase.quadOut, startDelay: 0.75});
			}
		});

		if (FlxG.save.data.strumline)
			grpStrumLine.forEach(function(strumlineBG:FlxSprite)
			{
				for (i in 0...4)
				{
					strumlineBG.acceleration.y = 1100;
					strumlineBG.velocity.y -= FlxG.random.int(20, 75);
					strumlineBG.velocity.x -= FlxG.random.int(-20, 20); 
					FlxTween.tween(strumlineBG, {alpha: 0}, 0.5, {type: ONESHOT, ease: FlxEase.expoIn});
				}
			});
		FlxTween.tween(healthBarBG, {alpha: 0}, 0.5 * delayMultiplier, {type: ONESHOT, ease: FlxEase.quadOut});
		FlxTween.tween(healthBar, {alpha: 0}, 0.5 * delayMultiplier, {type: ONESHOT, ease: FlxEase.quadOut});
		FlxTween.tween(iconP1, {alpha: 0}, 0.5 * delayMultiplier, {type: ONESHOT, ease: FlxEase.quadOut});
		FlxTween.tween(iconP2, {alpha: 0}, 0.5 * delayMultiplier, {type: ONESHOT, ease: FlxEase.quadOut});
		FlxTween.tween(scoreTxt, {alpha: 0}, 0.5 * delayMultiplier, {type: ONESHOT, ease: FlxEase.quadOut});
		FlxTween.tween(songNameTXT, {alpha: 0}, 0.5 * delayMultiplier, {type: ONESHOT, ease: FlxEase.quadOut});
		finishedHUDFadeOutFunction = true;
	}

	/*function tweenCamIn():Void
	{
		FlxTween.tween(camGame, {zoom: 1.5}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.bounceInOut});
	}*/

	override function openSubState(SubState:FlxSubState)
	{
		if (!endedSong)
		{
			if (FlxG.save.data.pauseOnUnfocus)
				FlxG.autoPause = false;

			if (paused && !died)
			{
				if (FlxG.sound.music != null)
				{
					FlxG.sound.music.pause();
					musicGroup.pause();
					vocals.pause();
					miscs.pause();

					switch (curSong)
					{
						case "Desperation" | "Disagreement" | "Retaliation":
							if (!startedCountdown && songStarted)
								if (stageSound.exists && stageSound.playing)
									stageSound.pause();
					}
				}

				#if windows
				if (FlxG.save.data.showPresence)
				{
					DiscordClient.changePresence("[PAUSED] \n" 
						+ detailsText
						+ SONG.song
						+ " ("
						+ storyDifficultyText
						+ ")   ",
						"\nRating: "
						+ Ratings.GenerateLetterRank(accuracy)
						+ " ("
						+ HelperFunctions.truncateFloat(accuracy, 2)
						+ "%) | Score: "
						+ songScore
						+ " | Misses: "
						+ misses);
				}
				#end

				if (startTimer != null && !startTimer.finished)
					startTimer.active = false;
			}
			else if (paused && died)
			{
				#if windows
				// Game Over doesn't get his own variable because it's only used here
				if (FlxG.save.data.showPresence)
				{
					DiscordClient.changePresence("[GAMEOVER!] \n" 
						+ detailsText
						+ SONG.song
						+ " ("
						+ storyDifficultyText
						+ ")   ",
						"\nRating: FAIL ("
						+ HelperFunctions.truncateFloat(accuracy, 2)
						+ "%) | Score: "
						+ songScore
						+ " | Misses: "
						+ misses);
				}
				#end
			}
		}

		super.openSubState(SubState);
	}
	

	//Making this void (2)
	override function closeSubState():Void
	{
		//inSubstate = false;
		//trace("Closed Substate");
		if (!endedSong)
		{
			if (FlxG.save.data.pauseOnUnfocus)
				FlxG.autoPause = true;
			if (paused && !died)
			{
				if (FlxG.sound.music != null && !startingSong)
				{
					if (!resultsPresent && !inCutscene)
						resyncVocals();
				}
		
				if (startTimer != null && !startTimer.finished)
					startTimer.active = true;

				switch (curSong)
				{
					case "Desperation" | "Disagreement" | "Retaliation":
						if (!startedCountdown && songStarted)
							if (stageSound.exists && !stageSound.playing)
								stageSound.resume();
				}
		
				paused = false;
		
				#if windows
				if (FlxG.save.data.showPresence)
				{
					if (startTimer != null && startTimer.finished && !paused)
					{
						DiscordClient.changePresence(detailsText
							+ SONG.song
							+ " ("
							+ storyDifficultyText
							+ ")   ",
							"\nRating: "
							+ Ratings.GenerateLetterRank(accuracy)
							+ " ("
							+ HelperFunctions.truncateFloat(accuracy, 2)
							+ "%) | Score: "
							+ songScore
							+ " | Misses: "
							+ misses, true,
							songLength
							- Conductor.songPosition - FlxG.save.data.offset + songOffset);
					}
				}
				#end
			}
		}
		
		super.closeSubState();
	}

	function resyncVocals():Void
	{
		if (!endedSong && Conductor.songPosition < musicTimeCusp)
		{
			if (FlxG.sound.music.time - Conductor.songPosition > 150 && FlxG.save.data.lagCompensation && !endedSong)
			{
				allowHealthModifiers = false;
				lagCompIcon.alpha = 0.5;
			}
			//trace("Timing Gap: " + (FlxG.sound.music.time - Conductor.songPosition));

			if (PauseSubState.resyncToLastPos && songStarted)
			{
				PauseSubState.resyncToLastPos = false;
				setSongTime(Conductor.songPosition);
			}
			else
			{
				//vocals.pause();
				//miscs.pause();
				if (FlxG.sound.music.time > 10)
				Conductor.songPosition = FlxG.sound.music.time;
				vocals.time = Conductor.songPosition;
				miscs.time = Conductor.songPosition;
				vocals.play();
				miscs.play();
				FlxG.sound.music.play();
			}
		}

		//trace("resynced vocals & miscs!");
	}

	private var paused:Bool = false;
	var died:Bool = false;
	var startedCountdown:Bool = false;
	var skipCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	//public static var songRate = 1.5;

	//public var stopUpdate = false;
	//public var removedVideo = false;

	public var currentBPM = 0;
	public var updateFrame = 0;

	var lagspikeDetectionThreshold = FlxG.save.data.fpsCap * 0.35; //maybe 0.3 is fine but I'm testing out 0.35
	var compensatedViaLagSpike:Bool = false;
	var keeledOver:Bool = false;

	var styleSound:FlxSound;
	var goodStyleHits:Int = 0;
	var improvStyleHits:Int = 0;
	var badStyleHits:Int = 0;
	var stylePresses:Int = 0;

	function styleOnEm(ms:Float):Void
	{
		#if debug
		trace('beatOffset: ' + ms);
		#end
		var styleRating:String = Ratings.CalculateRating(ms);
		//Placeholder Anims - I'll add rating dependent ones in the future maybe
		boyfriend.playAnim('style', true);

		//Style bonus
		switch (styleRating)
		{
			case 'sick' | 'good':
				if (badStyleHits <= 4)
				{
					if (storyWeek < 3)
					{
						if (storyWeek > 0)
							gf.playAnim('styleCheer', true);
						else
							if (!dad.animation.curAnim.name.startsWith('sing') && !dad.animation.curAnim.name.startsWith('cheer'))
								dad.playAnim('styleCheer', true);
					}
					goodStyleHits++;
				}
				else
					if (badStyleHits > 0)
						badStyleHits--;
					else if (improvStyleHits >= 2)
						improvStyleHits++;
			default:
				if (stylePresses >= goodStyleHits + 4)
					badStyleHits++;
				else if (goodStyleHits >= 4)
					goodStyleHits++;
				else if (improvStyleHits >= 4)
					improvStyleHits++;
		}
		styleSound.play(true);
		styleSound.volume = 0.35;
		#if cpp
		@:privateAccess
		{
			lime.media.openal.AL.sourcef(styleSound._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, FlxG.random.float(0.8, 1.2));
		}
		#end
	}

	private function styleCheck():Void
	{
		goodStyleHits += improvStyleHits;
		if (goodStyleHits >= 1)
		{
			popUpScore('style');
			switch(goodStyleHits)
			{
				case 0:
					//how tf
				case 1:
					songScore += 25 + (FlxMath.isOdd(goodStyleHits) ? 10 : 0);
				case 2:
					songScore += 75 + (FlxMath.isOdd(goodStyleHits) ? 25 : 0);
				case 3:
					songScore += 150 + (FlxMath.isOdd(goodStyleHits) ? 40 : 0);
				case 4:
					songScore += 250 + (FlxMath.isOdd(goodStyleHits) ? 55 : 0);
				default:
					if (goodStyleHits > 1)
						songScore += 350 + (50 * goodStyleHits - 5) + (FlxMath.isOdd(goodStyleHits) ? 100 : 0);
			}
			targetHealth += PlayStateHelpers.calculateHealth(storyDifficulty, 14, (FlxMath.isOdd(goodStyleHits) ? health : health / 2), accuracy, goodStyleHits);
		}
		goodStyleHits = 0;
		improvStyleHits = 0;
	}

	private function tweenScroll():Void
	{
		if (songSpeedTween != null)
			songSpeedTween.cancel();

		songSpeedTween = FlxTween.tween(this, {curScroll: newScroll}, Conductor.crochet / 1000, {ease: FlxEase.smootherStepOut,
			onUpdate: function(twn:FlxTween) 
			{
				for (note in notes) 
				{
					note.scrollSpeed = curScroll;
				}
				for (note in unspawnNotes) 
				{
					note.scrollSpeed = curScroll;
				}
			},
			
			onComplete: function(twn:FlxTween) 
			{
				for (note in notes) 
				{
					note.scrollSpeed = newScroll;
				}
				for (note in unspawnNotes) 
				{
					note.scrollSpeed = newScroll;
				}
				curScroll = newScroll; //Failsafe
				songSpeedTween = null;
			}
		});
	}

	override public function update(elapsed:Float)
	{
		FlxG.mouse.visible = false;
	
		super.update(elapsed);
		
		if (didCachingShits)
		{
			if (!resultsPresent && !endedSong)
			{
				if (FlxG.sound.music.playing)
				{
					if (SONG.eventObjects != null && SONG.eventObjects.length != 0)
					{
						for(i in SONG.eventObjects)
						{
							switch(i.type)
							{
								case "Scroll Speed Change":
									if (i.position <= curDecimalBeat && !i.triggerCheck)
									{
										i.triggerCheck = true;
										prevScrollCheck = false;
										if (newScroll != i.value)
											trace('susChange = ' + newScroll + ' -> ' + i.value);
										prevScroll = newScroll;
										newScroll = (i.value * diffSpeedMult) * FlxG.save.data.scrollSpeed;
										tweenScroll();
									}
							}
						}
					}
				}
	
				notes.sort(FlxSort.byY, (PlayStateChangeables.useDownscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));
	
				if (updateFrame == 4)
				{
					TimingStruct.clearTimings();
	
					var currentIndex = 0;
					for (i in SONG.eventObjects)
					{
						if (i.type == "BPM Change")
						{
							var beat:Float = i.position;
	
							var endBeat:Float = Math.POSITIVE_INFINITY;
	
							TimingStruct.addTiming(beat,i.value,endBeat, 0); // offset in this case = start time since we don't have a offset
							
							if (currentIndex != 0)
							{
								var data = TimingStruct.AllTimings[currentIndex - 1];
								data.endBeat = beat;
								data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
								TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
							}
	
							currentIndex++;
						}
					}
					updateFrame++;
				}
				else if (updateFrame != 5)
					updateFrame++;
	
				var timingSeg = TimingStruct.getTimingAtTimestamp(Conductor.songPosition);
	
				if (timingSeg != null)
				{
	
					var timingSegBpm = timingSeg.bpm;
	
					if (timingSegBpm != Conductor.bpm)
					{
						#if debug
						trace("BPM CHANGE to " + timingSegBpm);
						#end
						Conductor.changeBPM(timingSegBpm, false);
						fakeCrochet = (60 / timingSegBpm) * 1000;
						idleCamShakeTimer = Conductor.crochet / 1000 - 0.01;
						compensationTime = Conductor.crochet * 2 / 1000;			
					}
	
				}
			}	
	
			if (!cannotDie && !endedSong)
				safeVignette.visible = false;
			else if (!endedSong && canPause)
				safeVignette.visible = true;
	
			// reverse iterate to remove oldest notes first and not invalidate the iteration
			// stop iteration as soon as a note is not removed
			// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
			if (FlxG.save.data.npsDisplay)
			{
				var balls = notesHitArray.length - 1;
				while (balls >= 0)
				{
					var cock:Date = notesHitArray[balls];
					if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
						notesHitArray.remove(cock);
					else
						balls = 0;
					balls--;
				}
				nps = notesHitArray.length;
				if (nps > maxNPS)
					maxNPS = nps;
			}
	
			if (controls.PAUSE && !video.isPlaying && initialized && canPause && !paused && (FlxG.sound.music.time < musicTimeCusp || !FlxG.sound.music.playing))
				pauseGame();
	
			//CHANGED FROM MULTIPLE IF STATEMENTS (see if this causes problems)
			//Changed it back to multiple if statements to allow for more functionality
			if ((FlxG.sound.music.playing && FlxMath.roundDecimal(health, 3) <= 0) || (FlxG.keys.justPressed.R && FlxG.save.data.resetButton))
			{
				if (!resultsPresent && !inResults && !video.isPlaying && initialized && !PlayStateChangeables.botPlay)
				{
					if (!cannotDie)
					{
						if (!allowHealthModifiers && !FlxG.keys.justPressed.R)
							targetHealth = 0.05;
						else
							literallyFuckingDie();
					}
					else if (!FlxG.keys.justPressed.R)
					{
						targetHealth = 1;
						health = 1;
						if (camGame.finishedFade)
						{
							camGame.fade(FlxColor.RED, Conductor.crochet / 500, true);
							FlxG.sound.play(Paths.sound('practiceModeFail'));
							//preventRepeatDeaths = true;
							campaignDeaths++;
							songDeaths++;
							camShake(true, false);
							if (!keeledOver)
							{
								keeledOver = true;
								if (FlxG.save.data.songPosition)
									songPosDeathIndicator.x = songPosBar.x + (songPosBar.width * (songPosBar.percent * 0.01)) - (songPosDeathIndicator.width - 26) - 6;
								safeVignette.color = 0xFFFF0000;
								safeVignette.blend = MULTIPLY;
								safeVignette.alpha = 1;
								boyfriend.blend = ADD;
								boyfriend.color = 0xFF00F7FF;
								blackScreen.alpha = (!Main.nightMode && !FlxG.save.data.nightmode ? 0.15 : 0.4);
								healthBar.color = 0xFFFF0000;
								iconP1.color = 0xFF808080;
								scoreTxt.color = 0xFFADA99B;
								if (FlxG.save.data.strumline)
									grpStrumLine.color = 0xFF788D7F;
							}
						}
					}
				}
			}
	
			#if debug
			if (FlxG.keys.justPressed.ONE)
			{
				clearAllNotes();
				endSong();
			}
			else if(FlxG.keys.justPressed.TWO) 
			{
				setSongTime(Conductor.songPosition + 10000);
				clearNotesBefore(Conductor.songPosition);
			}
			else if (FlxG.keys.justPressed.FIVE)
			{
				Main.updateTimeStuffs();
				FlxG.switchState(new AnimationDebug(SONG.player2));
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			}
			else if (FlxG.keys.justPressed.SIX)
			{
				Main.updateTimeStuffs();
				FlxG.switchState(new AnimationDebug(SONG.player1));
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			}

			if (FlxG.keys.justPressed.SEVEN)
			{
				campaignDeaths = 0;
				hasReset = false;
				showedLoadingIcon = false;
				cannotDie = true;
				canPause = false;
				Main.updateTimeStuffs();
				FlxG.switchState(new ChartingState());
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
				FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			}
			#end

			if (FlxG.keys.justPressed.NINE)
				iconP1.swapOldIcon();
			else if (PlayStateChangeables.botPlay && FlxG.keys.justPressed.ONE)
				camHUD.visible = !camHUD.visible;
	
			if (generatedMusic && startedCountdown)
			{
				if (!paused && !endedSong)
				{
					fancySongUpdate(elapsed);
					if (!startingSong && songStarted && !inCutscene)
						keyShit();
				}	
			
				//Updating of alphas
				if (FlxG.save.data.lagCompensation && lagCompIcon.alpha > 0)
				{
					if (allowHealthModifiers)
						lagCompIcon.alpha -= (Conductor.crochet / 500) * FlxG.elapsed;
					//else
						//allowHealthModifiers = true;
					//Failsafe incase it fails to get turned on again
				}
	
				if (!endedSong && !inResults && !resultsPresent && !startingSong)
				{
					if (controls.STYLE && generatedMusic)
					{
						stylePresses++;
						if ((!boyfriend.animation.curAnim.name.startsWith('style') || boyfriend.animation.curAnim.curFrame >= 3) && !boyfriend.animation.curAnim.name.startsWith('dodge') && !boyfriend.animation.curAnim.name.startsWith('hurt') && !boyfriend.stunned)
						{
							var bpmMult:Float = Conductor.songPosition * (Conductor.bpm * 0.01);
							var beatOffset = Std.int(bpmMult % 600);
							beatOffset = (beatOffset >= 300) ? beatOffset - 600 : beatOffset;
							styleOnEm(beatOffset);
						}
						else
						{
							badStyleHits++;
							if (stylePresses >= goodStyleHits + 8)
								goodStyleHits--;
						}
					}
				}
	
				//Particles and stage updates
				switch (curStage)
				{
					case 'border':
						if (updateWiggleShader)
							objectWiggleShader.update(elapsed);
					case 'cityskyline':
						//this was once disabled, i enabled it to see what happens
						//hehehe I made it work!!11!
						cityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;
					case 'cityskylineVariegated':
						if (updateWiggleShader)
							objectWiggleShader.update(elapsed);

						if(stageParticles != null)
						{
							var i:Int = stageParticles.members.length-1;
							while (i > 0)
							{
								var particle = stageParticles.members[i];
								if(particle.alpha < 0)
								{
									particle.kill();
									stageParticles.remove(particle, true);
									particle.destroy();
								}
								--i;
							}
						}
				}
	
				//HurtVignette
				if (hurtDelay == 0)
				{
					if (hurtVignette.alpha > 0)
					{
						resetHurtFxScale = false;
						hurtVignette.alpha = FlxMath.lerp(0, hurtVignette.alpha, PlayStateHelpers.calculateLerpTime(elapsed, (Conductor.bpm * 0.01), 0, 1));
						var hurtScaleAmt:Float = 0.68 + (0.07 * hurtVignette.alpha);
						hurtVignette.scale.set(hurtScaleAmt, hurtScaleAmt);
						hurtVignette.screenCenter();
					}
					else if (!resetHurtFxScale)
					{
						resetHurtFxScale = true;
						hurtVignette.scale.set(0.68, 0.68);
						hurtVignette.screenCenter();
					}
				}
	
				//Low-Health Suspense
				lowHealthEffectVolume = 1 - health;
				lowHPHeartBeat.volume = FlxMath.lerp(lowHealthEffectVolume, lowHPHeartBeat.volume, PlayStateHelpers.calculateLerpTime(elapsed, 15, 0, 1));
				
				if (lowHPOverlay.alpha > 0)
				{
					
					if (FlxG.save.data.flashing)
						lowHPOverlay.alpha = FlxMath.lerp(0, lowHPOverlay.alpha, PlayStateHelpers.calculateLerpTime(elapsed, 4.5 * (Conductor.bpm * 0.01), 0, 1));
					else
						lowHPOverlay.alpha = FlxMath.lerp(lowHPHeartBeat.volume, lowHPOverlay.alpha, PlayStateHelpers.calculateLerpTime(elapsed, 6 * (Conductor.bpm * 0.01), 0, 1));
					
					hurtVignette.updateHitbox();
				}
	
				if (SONG.needsAdaptiveMus)
				{
					//Least Audio Volume during Low Health
					//FIX THIS SHIT
					switch (songLowercase)
					{
						case 'retaliation':
							if (health < 1)
							{
								FlxG.sound.music.volume = FlxMath.lerp(health - 0.3, FlxG.sound.music.volume, PlayStateHelpers.calculateLerpTime(elapsed, 15, 0, 1));
								instLowHP.volume = FlxMath.lerp(lowHealthEffectVolume + 0.3, instLowHP.volume, PlayStateHelpers.calculateLerpTime(elapsed, 15, 0, 1));
								miscs.volume = FlxMath.lerp(lowHealthEffectVolume + 0.25, miscs.volume, PlayStateHelpers.calculateLerpTime(elapsed, 15, 0, 1));
							}
							else if (health >= 1 && FlxG.sound.music.volume < 1)
							{
								FlxG.sound.music.volume = 1;
								instLowHP.volume = 0;
								miscs.volume = 0.5;
								lowHPOverlay.alpha = 0;
							}
						default:
							if (health < 1)
							{
								FlxG.sound.music.volume = FlxMath.lerp(health - 0.3, FlxG.sound.music.volume, PlayStateHelpers.calculateLerpTime(elapsed, 15, 0, 1));
								instLowHP.volume = FlxMath.lerp(lowHealthEffectVolume + 0.3, instLowHP.volume, PlayStateHelpers.calculateLerpTime(elapsed, 15, 0, 1));
							}
							else if (health >= 1 && FlxG.sound.music.volume < 1)
							{
								FlxG.sound.music.volume = 1;
								instLowHP.volume = 0;
								lowHPOverlay.alpha = 0;
							}
					}
				}
	
				dummySongScore = FlxMath.lerp(dummySongScore, songScore, 0.15);
				scoreTxt.text = Ratings.CalculateRanking(Math.round(dummySongScore), nps, maxNPS, accuracy, songDeaths);
				//scoreTxt.text = 'daScroll: ' + FlxMath.roundDecimal(curScroll, 5);
				scoreTxt.screenCenter(X);
			}
	
			if (FlxG.save.data.distractions)
			{
				var mult1:Float = FlxMath.lerp(1, iconP1.scale.x, PlayStateHelpers.calculateLerpTime(elapsed, 7.5 * (Conductor.bpm * 0.01), 0, 1));
				iconP1.scale.set(mult1, mult1);
				iconP1.updateHitbox();
		
				var mult2:Float = FlxMath.lerp(1, iconP2.scale.x, PlayStateHelpers.calculateLerpTime(elapsed, 7.5 * (Conductor.bpm * 0.01), 0, 1));
				iconP2.scale.set(mult2, mult2);
				iconP2.updateHitbox();
			}
	
			iconP1.x = healthBar.x + 5 + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - 26;
			//iconP1.y = healthBar.y - 75 * iconP1.scale.y;
			iconP2.x = healthBar.x - 5 + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - 26 * 2;
			//iconP2.y = healthBar.y - 75 * iconP2.scale.y;
	
			//Health Caps
			if (health > 2.05)
				health = 2.05;
			else if (health < 0)
			{
				health = 0;
				targetHealth = 0;
			}
			
			if (targetHealth > 2.05)
				targetHealth = 2.05;
			if (targetHealth < -0.00005)
				targetHealth = -0.00005;
	
			//Health Icons
			if (healthBar.percent <= 25)
			{
				if (iconP1.isShowingAlive)
					iconP1.playAnimation('lowHP');
			}
			else if (!iconP1.isShowingAlive)
				iconP1.playAnimation('normal');
	
			if (healthBar.percent >= 80)
			{
				if (iconP2.isShowingAlive)
					iconP2.playAnimation('lowHP');
			}
			else if (!iconP2.isShowingAlive)
				iconP2.playAnimation('normal');
	
			// Song duration in a float, useful for the time left feature
			songLength = FlxG.sound.music.length;
	
			//Pause Skip Song Shit
			if (isStoryMode && storyPlaylist.length > 0 && PauseSubState.skippedSong)
			{
				nextStateIsPlayState = true;
				playedCutscene = false;
				songPosGroup.visible = false;
				if (startTimer != null && !startTimer.finished)
					startTimer.active = false;
				clearAllNotes();
				skippedShit = true;
				didPauseSkippin = true;
				endSong();
				//instance.clear();
			}
	
			if (skipActive && Conductor.songPosition >= skipTo)
			{
				skipActive = false;
				FlxTween.tween(skipButton, {alpha: 0, y: skipButton.y + 10}, Conductor.crochet / 1000,
				{type: ONESHOT, ease: FlxEase.sineInOut,
					onComplete: function(tw)
					{
							skipButton.destroy();
					}
				});
			}
		
			if (FlxG.keys.justPressed.SPACE && skipActive && generatedMusic && startedCountdown && curBeat >= 0)
			{
				preventTutorialTips = true;
				FlxG.sound.play(Paths.sound('skipSongIntro'));
				setSongTime(skipTo);
				clearNotesBefore(skipTo);
	
				if (songLowercase == 'mic-test')
				{
					if (camTween != null)
						camTween.cancel();
					camGame.zoom = 1.5;
					if (tutorialGraphicA.exists)
						tutorialGraphicA.destroy();
					if (tutorialGraphicB.exists)
						tutorialGraphicB.destroy();
					if (tutorialGraphicC.exists)
						tutorialGraphicC.destroy();
	
					if (tutorialText.exists)
					{
						for (i in 0...4)
						{
							if (tutorialText.members.length > 0 && tutorialText.members[i].exists)
								tutorialText.members[i].kill();
						}
						if (bindTxtLeft.exists)
							tutorialText.remove(bindTxtLeft);
						if (bindTxtDown.exists)
							tutorialText.remove(bindTxtDown);
						if (bindTxtUp.exists)
							tutorialText.remove(bindTxtUp);
						if (bindTxtRight.exists)
							tutorialText.remove(bindTxtRight);
						tutorialText.destroy();
					}
				}
				
				FlxTween.shake(songPosClock, 0.05, Conductor.crochet / 1000, XY, {ease: FlxEase.sineOut});
				skipButton.destroy();
				skipActive = false;
			}
	
			//Starting Countdown Shit
			//Portal
			if (startingSong)
			{
				if (!died && startedCountdown)
				{	
					//Health lerp shits
					health = FlxMath.lerp(1, health, 0.95);
					Conductor.songPosition += FlxG.elapsed * 1000;
					if (Conductor.songPosition >= 0 && !songStarted)
						startSong();
				}
			}
			else
			{
				if (!paused)
				{
					//Health lerp shits
					health = FlxMath.lerp(targetHealth, health, PlayStateHelpers.calculateLerpTime(elapsed, 16, 0, 1));
					if (Conductor.songPosition < FlxG.sound.music.length)
						Conductor.songPosition += FlxG.elapsed * 1000;
					else if (Conductor.songPosition != songLength)
						Conductor.songPosition = songLength;

					songPositionBar = FlxMath.lerp(Conductor.songPosition, songPositionBar, 0.965);
	
					if (FlxG.save.data.songPosition)
					{
						var curTime:Float = Conductor.songPosition - FlxG.save.data.offset + songOffset;
						if(curTime < 0)
							curTime = 0;
						var songCalc:Float = (songLength - curTime);
						var secondsTotal:Int = Math.floor(songCalc / 1000);
						if(secondsTotal < 0)
							secondsTotal = 0;
						songDurationTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
						songDurationTxt.screenCenter(X);
					}
	
					// Interpolation type beat
					//if (Conductor.lastSongPos != Conductor.songPosition)
						//Conductor.lastSongPos = Conductor.songPosition;
	
					//CONVERTED TO ELSE IFS
					//NEVERMIND-??
					if (FlxG.save.data.lagCompensation && generatedMusic)
					{
						//LagSpike Compensation Attempt 2
						if (doLagComp)
						{
							if ((cast(Lib.current.getChildAt(0), Main)).getFPS() < lagspikeDetectionThreshold && curBeat > 4 && !endedSong && allowHealthModifiers)
							{
								lagCompIcon.alpha = 1;
								allowHealthModifiers = false;
								compensatedViaLagSpike = true;
							}
						}

						if (compensatedViaLagSpike)
						{
							if (!compensationTimer.active)
							{
								compensationTimer = new FlxTimer().start(compensationTime, function(tmr:FlxTimer)
								{
									compensatedViaLagSpike = false;
									allowHealthModifiers = true;
								});
							}
							else if (compensationTimerResetCheck > 30)
							{
								compensationTimerResetCheck++;
								compensationTimer.reset(compensationTime);
							}
							else
							{
								compensationTimerResetCheck = 0;
								compensatedViaLagSpike = false;
								allowHealthModifiers = true;
								compensationTimer.cancel();
							}
						}

						//Failsafe-?? maybe??
						if ((!compensationTimer.active || compensationTimer.finished) && !allowHealthModifiers)
							allowHealthModifiers = true;
					}
				}
			}

			if (camZooming)
			{
				camGame.zoom = FlxMath.lerp(defaultCamZoom, camGame.zoom, PlayStateHelpers.calculateLerpTime(elapsed, 2.5 * (Conductor.bpm * 0.01), 0, 1));
				camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, PlayStateHelpers.calculateLerpTime(elapsed, 3 * (Conductor.bpm * 0.01), 0, 1));
			}
	
			#if debug
			FlxG.watch.addQuick("curBPM", Conductor.bpm);
			//Broken
			FlxG.watch.addQuick("Closest Note", (unspawnNotes.length > 0 ? unspawnNotes[0].strumTime - Conductor.songPosition : "No note"));
			FlxG.watch.addQuick("NoteCheck idfk", (unspawnNotes.length > 0 ? unspawnNotes[0].canBeHit : "Nada"));
			//FlxG.watch.addQuick("Closest Can Hit", nearestNoteCanBeHit);
			FlxG.watch.addQuick("scrollSpeed", curScroll);
			FlxG.watch.addQuick("curBeat", curBeat);
			FlxG.watch.addQuick("curBeat (Decimal)", curDecimalBeat);
			FlxG.watch.addQuick("curStep", curStep);
			FlxG.watch.addQuick("Vocals Volume", vocals.volume);
			FlxG.watch.addQuick("Miscs Volume", miscs.volume);
			//FlxG.watch.addQuick("Song Amplitude", FlxG.sound.music.amplitude);
			#end
	
			if (unspawnNotes[0] != null)
			{
				var time:Float = 2000;
				if(curScroll < 1) 
					time = 2000 / curScroll;
				while (unspawnNotes.length > 0 && unspawnNotes[0].strumTime - Conductor.songPosition < time)
				{
					var dunceNote:Note = unspawnNotes[0];
					notes.insert(0, dunceNote);
	
					var index:Int = unspawnNotes.indexOf(dunceNote);
					unspawnNotes.splice(index, 1);
				}
			}
	
			if (FlxG.save.data.cpuStrums)
			{
				cpuStrums.forEach(function(spr:FlxSprite)
				{
					if (spr.animation.curAnim.curFrame >= 6 || spr.animation.curAnim.finished)
					{
						spr.animation.play('static');
						spr.centerOffsets();
					}
				});
			}
		}
	}

	function camShake(force:Bool = true, decay:Bool = false, camToShake:String = 'camGame', intensity:Float = 0.03, duration:Float = 0.25, axis:FlxAxes = XY):Void
	{
		if (decay)
		{
			intensity *= 2;
			duration *= 2;
		}

		switch (camToShake)
		{
			case 'camGame':
				camGame.shake(intensity, duration, force, decay, axis);
			case 'camHUD':
				camHUD.shake(intensity, duration, force, decay, axis);
		}
	}

	function fancySongUpdate(elapsed:Float):Void
	{
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];

		notes.forEachAlive(function(daNote:Note)
		{
			// instead of doing stupid y > FlxG.height
			// we be men and actually calculate the time :)
			if (daNote.tooLate)
			{
				daNote.active = false;
				daNote.visible = false;
			}
			else
			{
				daNote.visible = true;
				daNote.active = true;
			}

			var center:Float = strumLineNotes.members[daNote.noteData].y + Note.swagWidth / 2;

			if (PlayStateChangeables.useDownscroll)
			{
				if (daNote.mustPress)
					daNote.y = (playerStrums.members[daNote.noteData].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * daNote.scrollSpeed);
				else
					daNote.y = (strumLineNotes.members[daNote.noteData].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * daNote.scrollSpeed);

				if (daNote.isSustainNote)
				{
					//daNote.fixPossibleGaps();
					//SUSTAIN FIXINS (downscroll)
					//YOINKED FROM PSYCH
					// Remember = minus makes notes go up, plus makes them go down
					if (daNote.isSustainTail)
					{
						daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * daNote.scrollSpeed + (46 * (daNote.scrollSpeed - 1));
						daNote.y -= 46 * (1 - (fakeCrochet / 600)) * daNote.scrollSpeed;
					}
					//daNote.y += 30 * (1 - (fakeCrochet / 600)) * daNote.scrollSpeed;
					daNote.y += (Note.swagWidth / 2) - (60.5 * (daNote.scrollSpeed - 1));
					daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (daNote.scrollSpeed - 1);

					// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
					//Im yOINKING THE DOWNSCROLL SHIT FROM PSYCH-
					if ((!daNote.mustPress && !daNote.forceMiss) || ((daNote.sustainActive && holdArray[daNote.noteData] && (daNote.parent == null || daNote.parent.wasGoodHit)) || PlayStateChangeables.botPlay))
					{
						if(daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
				}
			}
			else
			{
				if (daNote.mustPress)
					daNote.y = (playerStrums.members[daNote.noteData].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * daNote.scrollSpeed);
				else
					daNote.y = (strumLineNotes.members[daNote.noteData].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * daNote.scrollSpeed);
				
				//Offset akgsgkdksg
				//daNote.y += daNote.offsetY;

				if (daNote.isSustainNote)
				{
					daNote.y -= 10.5 * (fakeCrochet / 400) * 1.5 * daNote.scrollSpeed + (46 * (daNote.scrollSpeed - 1));
					daNote.y += 46 * (1 - (fakeCrochet / 600)) * daNote.scrollSpeed;

					if ((!daNote.mustPress && !daNote.forceMiss) || ((daNote.sustainActive && holdArray[daNote.noteData] && (daNote.parent == null || daNote.parent.wasGoodHit)) || PlayStateChangeables.botPlay))
					{
						// Clip to strumline
						if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (center - daNote.y) / daNote.scale.y;
							if (!PlayStateChangeables.botPlay)
								swagRect.height -= swagRect.y;
							//swagRect.bottom = swagRect.y + daNote.height + 30; //basically playing it safe

							daNote.clipRect = swagRect;
						}
					}
				}
			}

			//if (daNote.)
			//daNote.fixPossibleGaps();

			if (!daNote.mustPress && daNote.wasGoodHit)		
				enemyNoteHit(daNote);

			//if a player's note, update until deleted
			if (daNote.mustPress)
			{
				//horrible way (?) but it works i guess
				//for mashing check
				if (daNote.overlaps(grpStrumLine) && !daNote.isSustainNote)
				{
					nearestNoteUpcoming = true;
					nearestNoteDecayBeat = 4;
				}
				
				daNote.visible = playerStrums.members[daNote.noteData].visible;
				if (daNote.x != playerStrums.members[daNote.noteData].x)
				{
					daNote.x = playerStrums.members[daNote.noteData].x;
					if (daNote.isSustainNote)
					{
						daNote.x += daNote.width / 2 + 20;
						switch (daNote.noteData)
						{
							case 0 | 1:
								daNote.x += 1;
							case 2 | 3:
								daNote.x -= 1;
						}
					}
				}
				if (!daNote.isSustainNote)
					daNote.modAngle = playerStrums.members[daNote.noteData].angle;
				if (daNote.sustainActive && !daNote.withinCompensation)
					daNote.alpha = daNote.baseAlpha * playerStrums.members[daNote.noteData].alpha;
				daNote.modAngle = playerStrums.members[daNote.noteData].angle;
			}
			//otherwise, update until a good hit. start updating again if a forcemiss
			else if (!daNote.wasGoodHit || daNote.forceMiss)
			{
				//trace ("test");
				daNote.visible = strumLineNotes.members[daNote.noteData].visible;
				if (daNote.x != strumLineNotes.members[daNote.noteData].x)
				{
					daNote.x = strumLineNotes.members[daNote.noteData].x;
					if (daNote.isSustainNote)
					{
						daNote.x += daNote.width / 2 + 20;
						switch (daNote.noteData)
						{
							case 0 | 1:
								daNote.x += 1;
							case 2 | 3:
								daNote.x -= 1;
						}
					}
				}
				if (!daNote.isSustainNote)
					daNote.modAngle = strumLineNotes.members[daNote.noteData].angle;
				if (daNote.sustainActive && !daNote.withinCompensation)
					daNote.alpha = daNote.baseAlpha * strumLineNotes.members[daNote.noteData].alpha;
				daNote.modAngle = strumLineNotes.members[daNote.noteData].angle;
			}
			
			if (daNote.mustPress && daNote.toggledSurpriseNote && !daNote.triggeredNoteEvent)
			{
				daNote.triggeredNoteEvent = true;
				if (!dad.animation.curAnim.name.startsWith("gun") || dad.animation.curAnim.curFrame >= 3)
				dad.playAnim('gunLOAD', false);
				if (stageOverlay.exists && !PlayStateChangeables.Optimize)
					stageOverlay.animation.play('warning');
			}

			if (daNote.tooLate)
			{
				if (!daNote.delayedDeath)
				{
					if (daNote.mustPress && !daNote.withinCompensation && !PlayStateChangeables.botPlay)
					{
						if (!daNote.isSustainNote)
						{
							switch (daNote.noteType)
							{
								case 'mine':
									if (stageOverlay.exists && !PlayStateChangeables.Optimize)
										stageOverlay.animation.play('static');
									dad.playAnim('gunSHOOT', true);
									camShake(true, false, 0.02);
									//la health none for mine
									if (FlxG.save.data.accuracyMod == 0)
										totalNotesHit += 1;
									sicks++;
									//placeholder for deflect anim
									switch (daNote.noteData)
									{
										case 0 | 2:
											boyfriend.playAnim('dodgeB', true);
										case 1 | 3:
											boyfriend.playAnim('dodgeA', true);
									}
								case 'trigger':
									if (!daNote.isSustainNote)
									{
										noteMiss(daNote.noteData, daNote);
										getFuckingShot();
									}
								default:
									if (allowHealthModifiers && !daNote.withinCompensation && hurtVignette.alpha < 0.2)
									{
										if (daNote.isParent)
										{
											// give a health punishment for failing an LN
											//Heath Drain for Sustain Parent
											targetHealth += PlayStateHelpers.calculateHealth(storyDifficulty, 1, targetHealth, accuracy);
											totalNotesHit -= 1;
											//trace("hold fell over at the start");
											for (i in daNote.children)
											{
												i.alpha = 0.3;
												i.baseAlpha = 0.3;
												i.sustainActive = false;
											}
										}
										else
										{
											//Health Drain for Non-Sustain
											targetHealth += PlayStateHelpers.calculateHealth(storyDifficulty, 0, targetHealth, accuracy);
											vocals.volume = 0;
										}
										noteMiss(daNote.noteData, daNote);
									}
							}
						}
						else
						{
							if (!daNote.isParent && !daNote.wasGoodHit && allowHealthModifiers && !daNote.withinCompensation && hurtVignette.alpha < 0.2)
							{
								if (daNote.sustainActive && daNote.spotInLine != daNote.parent.children.length)
								{
									//Health Drain for Sustain Slip
									targetHealth += PlayStateHelpers.calculateHealth(storyDifficulty, 2, targetHealth, accuracy);
									for (i in daNote.parent.children)
									{
										i.alpha = 0.3;
										i.sustainActive = false;
									}
									
									//Gives a miss if you, well, miss holding a sUS note
									if (daNote.parent.wasGoodHit && !daNote.isSustainTail && !daNote.isBeforeTail && !daNote.parent.withinCompensation)
									{
										daNote.rating = 'miss';
										if (FlxG.save.data.notesplash)
											sploshThisShitUp(daNote, 'miss', false);
										popUpScore('', daNote);
										if(FlxG.save.data.missSounds)
										{
											if (missSound.playing)
												missSound.stop();
											missSound = FlxG.sound.play(Paths.soundRandom('missnote', 1, 3));
											missSound.volume = FlxG.random.float(0.15, 0.2);
										}
										vocals.volume = 0;
										updateAccuracy();
									}
								}
								else
									//Health Drain for Sustain Children
									targetHealth += PlayStateHelpers.calculateHealth(storyDifficulty, 3, targetHealth, accuracy);
							}
						}

						daNote.visible = false;
						//daNote.finnaBeKilled = true;
						daNote.kill();
						notes.remove(daNote, true);
						//trace ('deleted non sus note');
					}
					else
					{
						if (!daNote.isSustainNote)
						{
							switch (daNote.noteType)
							{
								case 'mine':
									if (stageOverlay.exists && !PlayStateChangeables.Optimize)
										stageOverlay.animation.play('static');
									dad.playAnim('gunSHOOT', true);
									camShake(true, false, 0.02);
									//placeholder for deflect anim
									switch (daNote.noteData)
									{
										case 0 | 2:
											boyfriend.playAnim('dodgeB', true);
										case 1 | 3:
											boyfriend.playAnim('dodgeA', true);
									}
								case 'trigger':
									dad.playAnim('gunSHOOT', true);
									if (stageOverlay.exists && !PlayStateChangeables.Optimize)
										stageOverlay.animation.play('static');
									if (allowHealthModifiers && !daNote.withinCompensation && hurtVignette.alpha < 0.2)
									{
										specilNoteSFXGroup.stop();
										FlxG.sound.play(Paths.sound('Note_Mine'), 1, false, specilNoteSFXGroup);
										boyfriend.playAnim('hurt', true);
										camShake(true, false, 'camGame', 0.05);
										camShake(true, true, 'camHUD', 0.025);
									}
							}
						}

						//daNote.finnaBeKilled = true;
						daNote.visible = false;
						daNote.kill();
						notes.remove(daNote, true);
					}	
				}
				else
				{
					if (!daNote.isSustainTail || daNote.prevNote == null || daNote.prevNote.delayedDeath)
					{
						daNote.visible = false;
						//daNote.finnaBeKilled = true;
						daNote.kill();
						notes.remove(daNote, true);
					}
				}
			}

			if (daNote.forceAlpha && !daNote.isSustainNote) //!daNote.mustPress is a fgiven since this variable is turned on within Note.hx and could only be activated if it's not a player note
			{
				daNote.alpha = 0.5;
				daNote.baseAlpha = 0.5;
				if (daNote.isParent)
				{	
					for (i in daNote.children)
					{
						i.alpha = 0.3;
						i.baseAlpha = 0.3;
						i.sustainActive = false;
					}
				}
			}

			if (!allowHealthModifiers && daNote.canBeHit && !daNote.delayedDeath)
			{
				daNote.withinCompensation = true;
				if ((daNote.strumTime <= Conductor.songPosition - Conductor.safeZoneOffset * Conductor.timeScale))
				{
					if (daNote.isSustainNote
					&& daNote.sustainActive
					&& daNote.spotInLine != daNote.parent.children.length)
						for (i in daNote.parent.children)
						{
							i.alpha = 0.1;
							i.sustainActive = false;
						}
					else
					{
						daNote.visible = false;
						//daNote.finnaBeKilled = true;
						daNote.kill();
						notes.remove(daNote, true);
					}
				}
			}
		});
	}

	function getFuckingShot():Void
	{
		dad.playAnim('gunSHOOT', true);
		if (stageOverlay.exists && stageOverlay.animation.curAnim.name.toLowerCase() == 'warning' && !PlayStateChangeables.Optimize)
			stageOverlay.animation.play('static');
		//mmm complex system ahf h
		if (allowHealthModifiers)
		{
			iconP1.playAnimation('lowHP');
			if (health >= 0.5)
			{
				iconTrail1.active = true;
				iconTrail2.active = true;
				new FlxTimer().start(0.3, function(tmr:FlxTimer)
				{
					iconTrail1.active = false;
					iconTrail1.resetTrail();
					iconTrail2.active = false;
					iconTrail2.resetTrail();
				});
			}
			hurtVignette.alpha = 1;
			if (hurtDelay < 8)
				hurtDelay += 2;
			specilNoteSFXGroup.stop();
			FlxG.sound.play(Paths.sound('Note_Mine'), 1, false, specilNoteSFXGroup);
			boyfriend.playAnim('hurt', true);
			camShake(true, false, 'camGame', 0.05, Conductor.crochet / 1000);
			camShake(true, true, 'camHUD', 0.025, Conductor.crochet / 1000);

			timesShot++;
			trace("ate " + timesShot + ' bullet/s');

			causeOfDeath = 'ate-bullet';
			
			//la health drain for failed specil	
			if (timesShot < 3 && timesClutched <= 3)
			{
				if (timesShot == 1 && health > 0.25)
					targetHealth = 0.25;
				else if (timesShot == 2 && health > 0.025)
					targetHealth = 0.025;
				else
					targetHealth -= 0.01;
			}
			else
			{
				if (timesClutched < 3)
				{
					timesShot = timesClutched;
					timesClutched++;
					trace("clutched " + timesClutched + ' death/s');

					targetHealth = 0;
					//IDEA! MAKE IT DEPENDENT ON HOW CLOSE YOU ARE TO DYING!!!
					//LIKE Paths.sound('damageAlert_' + timesClutched)!! !!!
					//d0ne!!
					FlxG.sound.play(Paths.sound('damageAlert_' + timesClutched), 0.65 + 0.05 * timesClutched, false, specilNoteSFXGroup);
				}
				else if (!cannotDie)
				{
					causeOfDeath = 'ate-many-bullets';
					FlxG.sound.play(Paths.sound('damageAlert_fail'), 0.7, false, specilNoteSFXGroup);
					targetHealth = -100;
					health = -100;
				}
			}
		}
		else
		{
			camShake(true, false);
		}
	}

	function endSong():Void
	{
		trace("ended song");
		endedSong = true;
		generatedMusic = false;
		if (!resultsPresent)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);

			if(hasSubtitles && subtitleText.exists)
			{
				subtitleText.destroy();
				if(subtitleTimer != null)
				{
					subtitleTimer.destroy();
				}
			}

			if (skipActive)
			{
				skipButton.visible = false;
				skipButton.destroy();
			}

			if (FlxG.save.data.shitBreaksCombo)
				campaignMisses += misses + slips;
			else
				campaignMisses += misses;
			campaignBads += bads;
			campaignGoods += goods;
			campaignSicks += sicks;

			playedCutscene = false;
			if (!toggledPracticeMode)
				cannotDie = false;

			if (FlxG.save.data.pauseOnUnfocus)
			{
				FlxG.autoPause = false;
			}

			//hummuna humman change this if you want to reenable results in story mode
			if (!skippedShit && FlxG.save.data.scoreScreen && doReplayShit)
				rep.SaveReplay(saveNotes, saveJudge, replayAna);

			PlayStateChangeables.botPlay = false;
			PlayStateChangeables.useDownscroll = false;

			if (FlxG.save.data.fpsCap > 290)
				(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

			canPause = false;
			//paused = true;
			FlxG.sound.music.volume = 0;
			musicGroup.volume = 0;
			vocals.volume = 0;
			miscs.volume = 0;
			// = 0;

			FlxG.sound.music.pause();
			musicGroup.pause();
			vocals.pause();
			miscs.pause();

			persistentUpdate = true;
			persistentDraw = true;

			if (SONG.validScore && !toggledPracticeMode)
			{
				var songHighscore = StringTools.replace(SONG.song, " ", "-");

				Highscore.saveScore(songHighscore, songScore, storyDifficulty);
				if (!didPauseSkippin)
					Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
				campaignRatingArray.push(Ratings.GenerateLetterRank(accuracy));
			}

			showedLoadingIcon = false;

			if (isStoryMode)
			{
				campaignScore += songScore;
				campaignAccuracy = campaignAccuracy / campAccDivider;

				storyPlaylist.remove(storyPlaylist[0]);
				storyProgress++;

				if (storyProgress >= playlistLength)
				{
					//CHANGE THIS SHIT INTO A SWITCH STATEMENT LOL
					//Done! I dunno if this shit'll still work but oh well!
					if (!toggledPracticeMode)
					{	
						allowHeartBeatSounds = false;
						//paused = true;
						//End Song Cutscenes							
						playEndCutscene();
						//trace('played cutscene');
					}
					else
					{
						camHUD.visible = true;
						camHUD.alpha = 1;
						FlxG.sound.music.stop();
						vocals.stop();
						miscs.stop();
						musicGroup.stop();
						musicGroup.volume = 0;
						FlxG.sound.music.autoDestroy = true;
						vocals.stop();
						if (FlxG.save.data.scoreScreen && !resultsPresent)
						{
							if (!finishedHUDFadeOutFunction)
								fadeOutGameplayHUD(1);

							resultsPresent = true;
							inResults = true;
							openSubState(new ResultsScreen());
						}
						//Placeholder For Final Song (2)
						else if (songLowercase == "thorns" && !toggledPracticeMode)
						{
							Main.updateTimeStuffs();
							FlxG.switchState(new Credits());
						}
						else
						{
							Main.updateTimeStuffs();
							if (FlxG.save.data.scoreScreen)
							{
								resultsPresent = true;
								inResults = true;
								FlxG.switchState(new ResultsScreen());
							}
							else
								FlxG.switchState(new StoryMenuState());
						}
					}

					if (SONG.validScore && !toggledPracticeMode)
					{
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
						Highscore.saveWeekCombo(storyWeek, Ratings.DetermineWeekRating(campaignRatingArray), storyDifficulty);
						if (storyWeek + 1 > FlxG.save.data.weekUnlocked && storyWeek < 4)
							StoryMenuState.unlockNextWeek(storyWeek);
					}
				}
				else
				{
					nextStateIsPlayState = true;
					
					if (!PauseSubState.skippedSong)
						prevHealth = health;
					else
						PauseSubState.skippedSong = false;

					prevCamFollow = camFollow;
					campaignScore = songScore;
					campaignAccuracy = accuracy;
					// adjusting the song name to be compatible
					var songFormat = StringTools.replace(storyPlaylist[0], " ", "-");

					var poop:String = Highscore.formatSong(songFormat, storyDifficulty);

					#if debug
					trace('LOADING NEXT SONG');
					#end
					//trace(poop);

					lagCompIcon.alpha = 0;

					FlxTween.tween(loadingIcon, {alpha: 1}, 0.25, {type: ONESHOT, ease: FlxEase.smootherStepIn, onComplete: function(twn:FlxTween)
					{
						if (!skippedShit)
						{
							FlxTransitionableState.skipNextTransIn = true;
							FlxTransitionableState.skipNextTransOut = true;
						}

						SONG = Song.loadFromJson(poop, storyPlaylist[0]);

						FlxG.sound.music.stop();
						vocals.stop();
						miscs.stop();
						musicGroup.stop();
						musicGroup.volume = 0;
						FlxG.sound.music.autoDestroy = true;

						//FlxG.bitmap.clearCache();

						LoadingState.loadAndSwitchState(new PlayState());
					}});
				}
			}
			else
			{
				#if debug
				trace('WENT BACK TO FREEPLAY');
				#end
			
				FlxG.sound.music.stop();
				miscs.stop();
				vocals.stop();
				musicGroup.stop();

				if (FlxG.save.data.scoreScreen && !resultsPresent)
				{
					if (!finishedHUDFadeOutFunction)
						fadeOutGameplayHUD(1);
					
					FlxTransitionableState.skipNextTransOut = true;
					openSubState(new ResultsScreen());
					resultsPresent = true;
					new FlxTimer().start(0.3, function(tmr:FlxTimer)
					{
						inResults = true;
					});
				}
				else
				{
					FlxG.sound.music.autoDestroy = true;
					Main.updateTimeStuffs();
					FlxG.switchState(new FreeplayState());
				}
				PauseSubState.randomMusicTime = false;
			}
		}
	}

	public var nextStateIsPlayState:Bool = false;

	override function destroy()
	{
		if (!nextStateIsPlayState)
		{
			trace ('CLEARING PLAYSTATE DATA!!!!!!');
			FlxG.mouse.visible = true;
			FlxG.game.soundTray.silent = false;

			didPauseSkippin = false;

			//Clearing of campaign accuracy and resetting of bools

			storyPlaylist = [];
			playlistLength = 0;
			storyProgress= 0;

			campaignScore = 0;
			campaignMisses = 0;
			campaignBads = 0;
			campaignGoods = 0;
			campaignSicks = 0;
			campaignAccuracy = 0.00;
			campaignRatingArray = [];
			campAccDivider = 0;
			highestCombo = 0;

			camEXT.visible = false;
			prevHealth = 1;
			hasReset = false;
			toggledPracticeMode = false;
			playedCutscene = false;

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;
			transIn.camera = FlxCamera.defaultCameras[FlxCamera.defaultCameras.length];
			transOut.camera = FlxCamera.defaultCameras[FlxCamera.defaultCameras.length];

			PauseSubState.randomMusicTime = false;
		}

		super.destroy();
	}

	function playEndCutscene():Void
	{
		FlxG.sound.music.stop();
		vocals.stop();
		miscs.stop();
		musicGroup.stop();
		musicGroup.volume = 0;
		FlxG.sound.music.autoDestroy = true;
		
		/*if (FlxG.sound.music.playing)
			trace("BRO MUSIC PLAYING?!");
		else
			trace("BRO NO MUSIC PLAYING?!");*/

		FlxTransitionableState.skipNextTransOut = true;
		
		video = new MP4Handler();

		switch (songLowercase)
		{
			case 'up-and-beyond':		
				if (FlxG.save.data.scoreScreen)
				{
					//FlxG.switchState(new MinigameState());
					inCutscene = true;
					video.playVideo(Paths.video('week1/endcutscene'));
					new FlxTimer().start(0.3, function(tmr:FlxTimer)
					{
						camGame.visible = false;
						camGame.active = false;
					});
					video.finishCallback = function()
					{
						openSubState(new ResultsScreen());
					}
				}
				else
				{
					inCutscene = true;
					video.finishCallback = function()
					{
						FlxG.switchState(new StoryMenuState());
					}
					video.playVideo(Paths.video('week1/endcutscene'));
				}
			case 'retaliation':
				if (FlxG.save.data.scoreScreen)
				{
					inCutscene = true;
					video.playVideo(Paths.video('week2/endcutscene'));
					new FlxTimer().start(0.3, function(tmr:FlxTimer)
					{
						camGame.visible = false;
						camGame.active = false;
					});
					video.finishCallback = function()
					{
						openSubState(new ResultsScreen());
					}
				}
				else
				{
					inCutscene = true;
					video.playVideo(Paths.video('week2/endcutscene'));
					video.finishCallback = function()
					{
						FlxG.switchState(new StoryMenuState());
					}
				}
			//Placeholder for Final Song, change when Final Song is added
			case 'thorns':
				inCutscene = true;
				video.playVideo(Paths.video('week1/endcutscene'));
				new FlxTimer().start(0.3, function(tmr:FlxTimer)
				{
					camGame.visible = false;
					camGame.active = false;
				});
				video.finishCallback = function()
				{
					Main.updateTimeStuffs();
					FlxG.switchState(new Credits());	
				}
			//Crash Prevention
			default:
				//paused = true;
				camHUD.visible = true;
				camHUD.alpha = 1;
				if (FlxG.save.data.scoreScreen && !resultsPresent)
				{
					if (!finishedHUDFadeOutFunction)
						fadeOutGameplayHUD(1);

					openSubState(new ResultsScreen());
					resultsPresent = true;
					new FlxTimer().start(0.3, function(tmr:FlxTimer)
						{
							inResults = true;
						});
				}
				else
				{
					Main.updateTimeStuffs();
					FlxG.switchState(new StoryMenuState());
				}
		}
	}

	var endingSong:Bool = false;
	var timeShown = 0;
	var currentTimingShown:FlxText = null;
	var timingTween:FlxTween;
	var showNumShit:Bool = true;

	private function popUpScore(type:String, daNote:Note = null):Void
	{
		switch (type)
		{
			case 'style':
				var rating:FlxSprite = new FlxSprite().loadGraphic(Paths.image("rating_style"));
				rating.x = FlxG.save.data.changedHitX + 15;
				rating.y = FlxG.save.data.changedHitY + 10;
				rating.acceleration.y = 700;
				rating.velocity.y -= FlxG.random.int(150, 180);
				rating.velocity.x -= FlxG.random.int(-15, 20);
				if(FlxG.save.data.antialiasing)
					rating.antialiasing = true;
				rating.updateHitbox();
				rating.cameras = [camHUD];
				grpRaters.add(rating);

				FlxTween.tween(rating, {alpha: 0}, 0.1, 
				{
					type: ONESHOT, 
					onComplete: function(tween:FlxTween)
					{
						rating.destroy();
					},
					startDelay: Conductor.crochet * 0.001 / 2
				});

			default:
				if (daNote == null)
					return;
				var daRating = daNote.rating;
				if (daRating == null)
					return;
		
				var timingColour:FlxColor = 0xFF88979c;
				var noteDiff:Float;
		
				if (daNote != null)
					noteDiff = -(daNote.strumTime - Conductor.songPosition);
				else
					noteDiff = Conductor.safeZoneOffset; // Assumed SHIT if no note was given
				var wife:Float = EtternaFunctions.wife3(-noteDiff, Conductor.timeScale);
				var placement:String = Std.string(combo);
		
				var rating:FlxSprite = new FlxSprite();
				var score:Float = 350;
		
		
				if (FlxG.save.data.accuracyMod == 1)
					totalNotesHit += wife;
		
				if (daRating != 'miss')
					showNumShit = true;
				else
				{
					if (combo == 0)
						showNumShit = false;
				}
		
				if (allowHealthModifiers && !daNote.withinCompensation)
				{
					//trace (songScore);
					songScore += PlayStateHelpers.calculateScore(daRating);
					maxSongScore += PlayStateHelpers.calculateScore(daRating);

					switch (daRating)
					{
						//To do: Add difficulty-dependent health drains as well as customization
						//uhh i already did that
						//To did: Add(ed) difficulty-dependent health drains
						//oh oop i have not done customization yet
						case 'miss':
							bypassOppMissCheck++;
							if (lagCompIcon.alpha < 0.1)
							{
								combo = 0;
								misses++;
								timingColour = FlxColor.RED;
							}
						case 'shit':
							bypassOppMissCheck++;

							if (lagCompIcon.alpha < 0.1)
							{
								if (FlxG.save.data.shitBreaksCombo)
								{
									combo = 0;
									misses++;
									if (FlxG.save.data.accuracyMod == 0)
										totalNotesHit -= 1;
								}
								//Health Drain
								if (hurtVignette.alpha < 0.2)
									targetHealth += PlayStateHelpers.calculateHealth(storyDifficulty, 4, targetHealth, accuracy);
								timingColour = FlxColor.RED;
							}
						case 'bad':
							daRating = 'bad';
							//Health Drain
							if (hurtVignette.alpha < 0.2)
								targetHealth += PlayStateHelpers.calculateHealth(storyDifficulty, 5, targetHealth, accuracy);
							bads++;
							if (FlxG.save.data.accuracyMod == 0)
								if (mashPresses <= mashPressThreshold)
									totalNotesHit += 0.50;
							timingColour = FlxColor.YELLOW;
						case 'good':
							bypassOppMissCheck--;
							daRating = 'good';
							//Health Gain
							targetHealth += !mashing ? PlayStateHelpers.calculateHealth(storyDifficulty, 6, targetHealth, accuracy) : PlayStateHelpers.calculateHealth(storyDifficulty, 6, targetHealth, accuracy) / 4;
							goods++;
							if (FlxG.save.data.accuracyMod == 0)
								if (mashPresses <= mashPressThreshold)
									totalNotesHit += 0.75;
							timingColour = FlxColor.LIME;
						case 'sick':
							bypassOppMissCheck -= 2;
							//Health Gain
							targetHealth += !mashing ? PlayStateHelpers.calculateHealth(storyDifficulty, 7, targetHealth, accuracy, hurtVignette.alpha) : PlayStateHelpers.calculateHealth(storyDifficulty, 7, targetHealth, accuracy, hurtVignette.alpha) / 4;
							if (FlxG.save.data.accuracyMod == 0)
								if (mashPresses <= mashPressThreshold)
									totalNotesHit += 1;
							sicks++;
							timingColour = FlxColor.CYAN;
					}
				}
		
				if (!PlayStateChangeables.botPlay)
				{
					rating.loadGraphic(Paths.image("rating_" + daRating));
					rating.x = FlxG.save.data.changedHitX;
					rating.y = FlxG.save.data.changedHitY;
					rating.acceleration.y = 550;
					rating.velocity.y -= FlxG.random.int(140, 175);
					rating.velocity.x -= FlxG.random.int(0, 10);
					if(FlxG.save.data.antialiasing)
						rating.antialiasing = true;
					rating.updateHitbox();
					rating.cameras = [camHUD];
					grpRatings.add(rating);
		
					if (daRating != 'miss')
					{
						var msTiming = FlxMath.roundDecimal(noteDiff, 1);
						if (PlayStateChangeables.botPlay)
							msTiming = 0;
			
						if (currentTimingShown != null)
							grpRaters.remove(currentTimingShown);
			
						currentTimingShown = new FlxText(0, 0, 200, "0 ms");
						timeShown = 0;
						currentTimingShown.font = "VCR OSD Mono";
						currentTimingShown.alignment = LEFT;
						currentTimingShown.color = timingColour;
						currentTimingShown.borderStyle = OUTLINE;
						currentTimingShown.borderSize = 3;
						currentTimingShown.borderColor = FlxColor.BLACK;
						currentTimingShown.text = (msTiming > 0 ? " " : "") + msTiming + " ms";
						currentTimingShown.size = 25;
						currentTimingShown.x = rating.x + 115;
						currentTimingShown.y = rating.y + 95;
						currentTimingShown.updateHitbox();
						currentTimingShown.cameras = [camHUD];
						if (currentTimingShown.alpha != 1)
							currentTimingShown.alpha = 1;
						if (currentTimingShown.exists)
							grpRaters.add(currentTimingShown);
					}
		
					if (showNumShit)
					{
						var seperatedScore:Array<Int> = [];
						var daLoop:Int = 0;
						var comboSplit:Array<String> = (combo + "").split('');
		
						if (combo > highestCombo)
							highestCombo = combo;
		
						// make sure we have 3 digits to display (looks weird otherwise lol)
						if (comboSplit.length == 1)
						{
							seperatedScore.push(0);
							seperatedScore.push(0);
						}
						else if (comboSplit.length == 2)
							seperatedScore.push(0);
		
						for (i in 0...comboSplit.length)
						{
							var str:String = comboSplit[i];
							seperatedScore.push(Std.parseInt(str));
						}
		
						for (i in seperatedScore)
						{
							var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num' + Std.int(i)));
							numScore.x = rating.x + (37 * daLoop);
							numScore.y = rating.y + 90;
							numScore.cameras = [camHUD];
		
							if(FlxG.save.data.antialiasing)
								numScore.antialiasing = true;
							//numScore.setGraphicSize(Std.int(numScore.width * 0.8));
							numScore.updateHitbox();
							switch (daRating)
							{
								case 'shit' | 'miss':
									if (allowHealthModifiers && !daNote.withinCompensation)
									{
										if (daRating != 'shit' || FlxG.save.data.shitBreaksCombo)
											numScore.color = timingColour;
										rating.color = 0xFFFFC7C7;
									}
									else
									{
										rating.color = timingColour;
										rating.alpha = 0.75;
									}
							}
		
							numScore.acceleration.y = FlxG.random.int(200, 300);
							numScore.velocity.y -= FlxG.random.int(120, 140);
							numScore.velocity.x = FlxG.random.float(-5, 5);
		
							grpRatings.add(numScore);
		
							FlxTween.tween(numScore, {alpha: 0}, 0.2, {type: ONESHOT, 
								onComplete: function(tween:FlxTween)
								{
									numScore.destroy();
									//if (currentTimingShown != null)
									//	currentTimingShown.alpha = 0;
								},
								startDelay: Conductor.crochet * 0.0015
							});
		
							daLoop++;
						}
					}
		
					if (daRating != 'miss')
					{
						timingTween = FlxTween.tween(currentTimingShown, {alpha: 0}, 0.2, {type: ONESHOT, startDelay: Conductor.crochet * 0.001});
						FlxTween.tween(rating, {alpha: 0}, 0.2, {type: ONESHOT, 
							onComplete: function(tween:FlxTween)
							{
								if (currentTimingShown != null && timeShown >= 20)
								{
									grpRaters.remove(currentTimingShown);
									currentTimingShown = null;
								}
								rating.destroy();
							},
							startDelay: Conductor.crochet * 0.001
						});
					}
					else
					{
						FlxTween.tween(rating, {alpha: 0}, 0.2, {type: ONESHOT, 
							onComplete: function(tween:FlxTween)
							{
								rating.destroy();
							},
							startDelay: Conductor.crochet * 0.001
						});
					}
				}
		
				//Note splash stuff
				if (allowHealthModifiers && !daNote.withinCompensation && daRating != 'miss')
				{
					var specialNote:Bool = true;
					if (daNote.noteType != 'mine' && daNote.noteType != 'trigger')
						specialNote = false;
					if (FlxG.save.data.notesplash && !PlayStateChangeables.botPlay && !daNote.isSustainNote && (specialNote || (daRating != 'shit' || FlxG.save.data.shitBreaksCombo)))
						sploshThisShitUp(daNote, daRating, specialNote);
					else
						adjustVocVolOnNoteHit(daNote);
				}
		}
	}

	function sploshThisShitUp(daNote:Note, daRating:String, isSpecialNote:Bool = false):Void
	{
		if ((allowHealthModifiers && !daNote.withinCompensation) || ((daRating != 'shit' && daRating != 'miss') || isSpecialNote))
		{
			var sploosh:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
			sploosh.setupNoteSplash(!daNote.isSustainNote ? daNote.x : playerStrums.members[daNote.noteData].x, !daNote.isSustainNote ? daNote.y : playerStrums.members[daNote.noteData].y, daNote.rating, daNote.noteType, daNote.noteData, daBabyArrowY);
			grpNoteSplashes.add(sploosh);
		}
	}

	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;

	private function keyShit():Void // I've invested in emma stocks
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		var releaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];
		//FROM 1.8
		//wow this actually made things smooth im keeping this
		var keynameArray:Array<String> = ['left', 'down', 'up', 'right'];

		// Prevent player input if botplay is on
		if (PlayStateChangeables.botPlay)
		{
			holdArray = [false, false, false, false];
			pressArray = [false, false, false, false];
			releaseArray = [false, false, false, false];
		}

		var anas:Array<Ana> = [null, null, null, null];

		for (i in 0...pressArray.length)
			if (pressArray[i])
				anas[i] = new Ana(Conductor.songPosition, null, false, "miss", i);

		// HOLDS, check for sustain notes
		if (holdArray.contains(true) && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && (daNote.parent == null || daNote.parent.wasGoodHit) && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && daNote.sustainActive)
				{
					//trace(daNote.sustainActive);
					if (!daNote.delayedDeath)
						goodNoteHit(daNote);
				}
			});
		}

		if ((KeyBinds.gamepad && !FlxG.keys.justPressed.ANY))
		{
			// PRESSES, check for note hits
			if (pressArray.contains(true) && generatedMusic)
			{
				boyfriend.holdTimer = 0;

				var possibleNotes:Array<Note> = []; // notes that can be hit
				var directionList:Array<Int> = []; // directions that can be hit
				var dumbNotes:Array<Note> = []; // notes to kill later
				var directionsAccounted:Array<Bool> = [false, false, false, false]; // we don't want to do judgments for more than one presses

				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !directionsAccounted[daNote.noteData])
					{
						if (directionList.contains(daNote.noteData))
						{
							directionsAccounted[daNote.noteData] = true;
							for (coolNote in possibleNotes)
							{
								if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
								{ // if it's the same note twice at < 10ms distance, just delete it
									// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
									dumbNotes.push(daNote);
									break;
								}
								else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
								{ // if daNote is earlier than existing note (coolNote), replace
									possibleNotes.remove(coolNote);
									possibleNotes.push(daNote);
									break;
								}
							}
						}
						else
						{
							directionsAccounted[daNote.noteData] = true;
							possibleNotes.push(daNote);
							directionList.push(daNote.noteData);
						}
					}
				});

				for (note in dumbNotes)
				{
					FlxG.log.add("killing dumb ass note at " + note.strumTime);
					//note.finnaBeKilled = true;
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}

				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				var hit = [false,false,false,false];

				if (possibleNotes.length > 0)
				{
					if (!FlxG.save.data.ghost)
					{
						for (shit in 0...pressArray.length)
						{ // if a direction is hit that shouldn't be
							if (pressArray[shit] && !directionList.contains(shit))
								noteMiss(shit, null);
						}
					}
					for (coolNote in possibleNotes)
					{
						if (pressArray[coolNote.noteData] && !hit[coolNote.noteData] && !coolNote.delayedDeath)
						{
							//if (mashViolations != 0)
							//	mashViolations--;
							hit[coolNote.noteData] = true;
							scoreTxt.color = FlxColor.WHITE;
							var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
							anas[coolNote.noteData].hit = true;
							anas[coolNote.noteData].hitJudge = Ratings.CalculateRating(noteDiff, Math.floor(PlayStateChangeables.safeZoneOffset));
							anas[coolNote.noteData].nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
							goodNoteHit(coolNote);
						}
					}
				};
				
				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
					if ((boyfriend.animation.curAnim.name.startsWith('sing') && boyfriend.animation.curAnim.curFrame >= 10 && ((boyfriend.animation.curAnim.name != "hurt" && !boyfriend.animation.curAnim.name.startsWith("dodge")) || boyfriend.animation.curAnim.finished)) && !boyfriend.animation.curAnim.name.endsWith('miss'))
						boyfriend.playAnim('idleAfterSing');
				else if (!FlxG.save.data.ghost)
				{
					for (shit in 0...pressArray.length)
						if (pressArray[shit])
							noteMiss(shit, null);
				}
			}

			//if (!loadRep)
			for (i in anas)
				if (i != null && doReplayShit) // hummuna humman change this if you want to reenable results in story mode (5)
					replayAna.anaArray.push(i); // put em all there
		}
		notes.forEachAlive(function(daNote:Note)
		{
			if (PlayStateChangeables.useDownscroll && daNote.y > strumLine.y || !PlayStateChangeables.useDownscroll && daNote.y < strumLine.y)
			{
				// Force good note hit regardless if it's too late to hit it or not as a fail safe
				if (PlayStateChangeables.botPlay && daNote.canBeHit && daNote.mustPress || PlayStateChangeables.botPlay && daNote.tooLate && daNote.mustPress)
				{
					if (!daNote.delayedDeath)
						goodNoteHit(daNote);
					boyfriend.holdTimer = daNote.sustainLength;
				}
			}
		});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
		{
			if (((boyfriend.animation.curAnim.name.startsWith('sing') && boyfriend.animation.curAnim.curFrame >= 10) && ((boyfriend.animation.curAnim.name != "hurt" && !boyfriend.animation.curAnim.name.startsWith("dodge")) || boyfriend.animation.curAnim.finished)) && !boyfriend.animation.curAnim.name.endsWith('miss'))
			//{
				boyfriend.playAnim('idleAfterSing');
				//trace("Idle (line 5601)");
			//}
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			if (keys[spr.ID] && spr.animation.curAnim.name != 'confirm' && spr.animation.curAnim.name != 'pressed')
				spr.animation.play('pressed');
			if (!keys[spr.ID] && (spr.animation.curAnim.name != 'confirm' || spr.animation.curAnim.curFrame >= 6) && spr.animation.curAnim.name != 'static')
				spr.animation.play('static');

			if (spr.animation.curAnim.name == 'confirm')
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	public function findByTime(time:Float):Array<Dynamic>
	{
		for (i in rep.replay.songNotes)
		{
			if (i[0] == time)
				return i;
		}
		return null;
	}

	public function findByTimeIndex(time:Float):Int
	{
		for (i in 0...rep.replay.songNotes.length)
		{
			if (rep.replay.songNotes[i][0] == time)
				return i;
		}
		return -1;
	}

	//Making this void (3)
	//Removing de shits
	//removing this from public
	//converting to override from private
	override function onFocusLost():Void
	{
		if (songStarted && generatedMusic && !endedSong && FlxG.save.data.pauseOnUnfocus && !paused)
		{
			doLagComp = false;

			#if windows
			if (FlxG.save.data.showPresence)
			{
				DiscordClient.changePresence("[AUTO-PAUSED] \n"
				+ detailsText
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ")   ",
				"\nRating: "
				+ Ratings.GenerateLetterRank(accuracy)
				+ " ("
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "%) | Score: "
				+ songScore
				+ " | Misses: "
				+ misses);
			}
			#end
		}
	}

	//removing from publicskov
	//converting to override from private
	override function onFocus():Void
	{
		if (songStarted && generatedMusic && !endedSong && FlxG.save.data.pauseOnUnfocus && !paused)
		{
			new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				doLagComp = true;
			});

			#if windows
			if (FlxG.save.data.showPresence)
			{
				DiscordClient.changePresence(detailsText
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ")   ",
					"\nRating: "
					+ Ratings.GenerateLetterRank(accuracy)
					+ " ("
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "%) | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, true,
					songLength
					- Conductor.songPosition - FlxG.save.data.offset + songOffset);
			}
			#end
		}
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		causeOfDeath = '';
		if (!boyfriend.stunned && allowHealthModifiers && !daNote.withinCompensation)
		{
			bypassOppMissCheck++;

			//hummuna humman change this if you want to reenable results in story mode (2)
			if (doReplayShit)
			{
				saveNotes.push([
					daNote.strumTime,
					0,
					direction,
					166 * Math.floor((rep.replay.sf / 60) * 1000) / 166
				]);
				saveJudge.push("miss");
			}

			updateAccuracy();

			if (combo > 5)
			{
				if (gf.animOffsets.exists('sad') && curSong != "Mic Test")
					gf.playAnim('sad');
				else if (dad.animOffsets.exists('sad') && curSong == "Mic Test")
					dad.playAnim('sad');
			}

			daNote.rating = 'miss';
			if (daNote.noteType != "trigger")
				popUpScore('', daNote);
			if (FlxG.save.data.notesplash && !PlayStateChangeables.botPlay)
				sploshThisShitUp(daNote, daNote.rating); 

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit -= 1;

			if (!daNote.isSustainNote && daNote != null)
				songScore -= 300;

			//NOTE MISS SOUND
			if(FlxG.save.data.missSounds && daNote.noteType != 'trigger')
			{
				vocals.volume = 0;
				if (missSound.playing)
					missSound.stop();
				missSound = FlxG.sound.play(Paths.soundRandom('missnote', 1, 3));
				missSound.volume = FlxG.random.float(0.2, 0.25);
			}

			// Whole switch statement replaced with a single line :)
			if ((boyfriend.animation.curAnim.name != 'hurt' && !boyfriend.animation.curAnim.name.startsWith("dodge")) || boyfriend.animation.curAnim.curFrame >= 3)
				boyfriend.playAnim('sing' + dataSuffix[direction] + 'miss', true);
			//trace("BUH NOTE MISS PLAY ANIM HERE");
		}
	}

	var bypassOppMiss:Bool = false;
	var bypassOppMissCheck:Int = 0;
	var curEnemyNote:Int = 0;

	private function enemyNoteMiss(noteDirection, isSustain:Bool = false, ?curEnemyNoteCheck:Int = 0):Void
	{
		if (bypassOppMissCheck <= 0)
		{
			bypassOppMissCheck = 0;
			bypassOppMiss = false;
		}
		else if (bypassOppMissCheck > 15 / storyDifficulty)
			bypassOppMiss = true;
		if (!bypassOppMiss)
		{
			if (!isSustain)
			{
				if (((!dad.animation.curAnim.name.startsWith("sing") || !dad.animation.curAnim.name.startsWith("cheer")) || dad.animation.curAnim.curFrame >= 1) && ((dad.animation.curAnim.name != "gunSHOOT" || dad.animation.curAnim.curFrame >= 3) && (dad.animation.curAnim.name != "gunLOAD" || dad.animation.curAnim.finished)))
					dad.playAnim('sing' + noteDirection + "miss", true);
				miscs.volume = 0;
				if(FlxG.save.data.missSounds)
				{
					if (missSound.playing)
						missSound.stop();
					missSound = FlxG.sound.play(Paths.soundRandom('enemyMiss', 1, 3));
					missSound.volume = FlxG.random.float(0.15, 0.2);
				}
				
				if (healthBar.percent < 85)
					targetHealth += PlayStateHelpers.calculateHealth(storyDifficulty, 10, targetHealth, accuracy);
			}
			else
			{
				if (curEnemyNote == curEnemyNoteCheck)
				{
					if (((!dad.animation.curAnim.name.startsWith("sing") || !dad.animation.curAnim.name.startsWith("cheer")) || dad.animation.curAnim.curFrame >= 1) && ((dad.animation.curAnim.name != "gunSHOOT" || dad.animation.curAnim.curFrame >= 3) && (dad.animation.curAnim.name != "gunLOAD" || dad.animation.curAnim.finished)))
						dad.playAnim('sing' + noteDirection + "miss", true);
					miscs.volume = 0;
					if (healthBar.percent < 85)
						targetHealth += PlayStateHelpers.calculateHealth(storyDifficulty, 11, targetHealth, accuracy) / 4;
				}
			}
			dad.holdTimer = 0;
		}
	}

	//Making this void (4)
	function updateAccuracy():Void
	{
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
		if (isStoryMode)
		{
			campaignAccuracy += accuracy;
			campAccDivider++;
		}
	}

	var mashPresses:Int = 0;
	//number after defaultmashingthreshold is the mashing limit
	var defaultMashingThreshold:Int = 20;
	//Threshold is set by goodNoteHit(); and is reset by fancyNoteUpdate();
	var mashPressThreshold:Int = 20;
	//My attempt at an anti-mash system (dreamedwave (that's me))
	var mashing:Bool = false;
	var nearestNoteUpcoming:Bool = false;
	var nearestNoteDecayBeat:Int = 0;

	//Make a sound group for necessary instruments that need to be split, combine other insts in one track tor educe clutter
	//a LIIITTLE messy rn sdkksgksgk
	function playFinaleMusic():Void
	{
		if (curBeat % 16 == 0)
		{
			drums.stop();
			taiko.stop();
			if (dangerLevel < 50 && enemyHealth > 30)
			{
				drums = FlxG.sound.play(Paths.musicRandom('finaleAdaptiveMus/drums_', 0, 1), 1, false, musicGroup);
				taiko = FlxG.sound.play(Paths.musicRandom('finaleAdaptiveMus/taiko_', 0, 2), 1, false, musicGroup);
				taiko.time = drums.time;
				//trace("Le Drummos");
			}
			else if (dangerLevel >= 50 && enemyHealth > 30)
			{
				drums = FlxG.sound.play(Paths.musicRandom('finaleAdaptiveMus/drums_', 2, 3), 1, false, musicGroup);
				taiko = FlxG.sound.play(Paths.musicRandom('finaleAdaptiveMus/taiko_', 0, 5), 1, false, musicGroup);
				taiko.time = drums.time;
				//trace("Le Drummos but Epico");
			}
			else
			{
				drums = FlxG.sound.play(Paths.music('finaleAdaptiveMus/drums_climax'), 1, false, musicGroup);
				taiko = FlxG.sound.play(Paths.musicRandom('finaleAdaptiveMus/taiko_', 4, 5), 1, false, musicGroup);
				taiko.time = drums.time;
				//trace("Le Drummos but Epicest");
			}
		}
		//Choir, Hihats, Violin/Woodwinds, and Slayer
		if (curBeat % 32 == 0)
		{
			choir.stop();
			hats.stop();
			if (dangerLevel < 50 && enemyHealth > 30)
			{
				choir = FlxG.sound.play(Paths.music('finaleAdaptiveMus/choir_0'), 1, false, musicGroup);
				hats = FlxG.sound.play(Paths.music('finaleAdaptiveMus/hats_0'), 1, false, musicGroup);
				if (!isBFTurn)
					adders = FlxG.sound.play(Paths.music('finaleAdaptiveMus/woodwinds'), 1, false, musicGroup);
			}
			else if (dangerLevel >= 50 && enemyHealth > 30)
			{
				adders.stop();
				choir = FlxG.sound.play(Paths.music('finaleAdaptiveMus/choir_1'), 1, false, musicGroup);
				hats = FlxG.sound.play(Paths.music('finaleAdaptiveMus/hats_1'), 1, false, musicGroup);
				adders = FlxG.sound.play(Paths.music('finaleAdaptiveMus/violin'), 1, false, musicGroup);
			}
			else
			{
				adders.stop();
				pads.stop();
				choir = FlxG.sound.play(Paths.music('finaleAdaptiveMus/choir_1'), 1, false, musicGroup);
				hats = FlxG.sound.play(Paths.music('finaleAdaptiveMus/hats_1'), 1, false, musicGroup);
				adders = FlxG.sound.play(Paths.music('finaleAdaptiveMus/elecpiano_climax'), 1, false, musicGroup);
				pads = FlxG.sound.play(Paths.music('finaleAdaptiveMus/pads_climax'), 1, false, musicGroup);
			}

			if (dangerLevel < 50 && enemyHealth > 30 && !isBFTurn)
				slayer = FlxG.sound.play(Paths.music('finaleAdaptiveMus/slayer_0'), 1, false, musicGroup);
			else if (dangerLevel < 50 && enemyHealth > 30 && !isBFTurn)
			{
				slayer = FlxG.sound.play(Paths.music('finaleAdaptiveMus/slayer_1'), 1, false, musicGroup);
				//if (dangerLevel < 50)
				//	dangerLevel = 50;
			}
			else if (enemyHealth <= 30)
			{
				slayer.stop();
				slayer = FlxG.sound.play(Paths.music('finaleAdaptiveMus/slayer_climax'), 1, false, musicGroup);
				//if (dangerLevel < 50)
				//	dangerLevel = 50;
			}
			dangerLevel = FlxG.random.int(49, 50);
			enemyHealth = FlxG.random.int(31, 30);
		}
		//Cymbals/Hats
		if (curBeat % 64 == 0)
		{
			retalHats.stop();
			FlxG.sound.play(Paths.music('finaleAdaptiveMus/stab'), 0.9, false, musicGroup);
			if (dangerLevel < 50 && !isBFTurn)
				retalHats = FlxG.sound.play(Paths.music('finaleAdaptiveMus/retal-hats_0'), 1, false, musicGroup);
			else if (dangerLevel < 50 && !isBFTurn)
				retalHats = FlxG.sound.play(Paths.music('finaleAdaptiveMus/retal-hats_1'), 1, false, musicGroup);
			else
				retalHats = FlxG.sound.play(Paths.music('finaleAdaptiveMus/retal-hats_0'), 1, false, musicGroup);
		}
		//Bells, and Pads
		if (curBeat % 64 == 32)
		{
			if (dangerLevel < 50)
			{
				bells.stop();
				bells = FlxG.sound.play(Paths.music('finaleAdaptiveMus/bells_0'), 1, false, musicGroup);
				if (!isBFTurn && FlxG.random.bool(50))
					pads = FlxG.sound.play(Paths.music('finaleAdaptiveMus/pads_0'), 1, false, musicGroup);
			}
			else if (enemyHealth > 30)
			{
				if (FlxG.random.bool(75))
				{
					bells.stop();
					bells = FlxG.sound.play(Paths.music('finaleAdaptiveMus/bells_1'), 1, false, musicGroup);
				}
				pads = FlxG.sound.play(Paths.music('finaleAdaptiveMus/pads_1'), 1, false, musicGroup);
			}
			else
			{
				bells.stop();
				bells = FlxG.sound.play(Paths.music('finaleAdaptiveMus/bells_1'), 1, false, musicGroup);
			}
		}
		if (curBeat % 128 == 0)
		{
			danger.stop();
			danger = FlxG.sound.play(Paths.music('finaleAdaptiveMus/danger-loop'), 0, false, musicGroup);
		}
	}

	//Making this void (5)
	function playNoteHitSound(note:Note):Void
	{
		if (!note.isSustainNote)
		{
			var rating = note.rating;
			//	SFX for hitting notes (such as SICK, GOOD, BAD, SHIT, and SPECIAL NOTEs);
			if (hitsoundType != 'botplay' && !note.withinCompensation)
			{
				hitSFXGroup.stop();
				//Converted from nested if-else statements and 2 switch statements to a one switch! You're welcome!
				switch (rating)
				{
					case 'sick':
						//For Sick Rating
						FlxG.sound.play(Paths.sound("Note_" + hitsoundType + "_Sick"), noteHitVolume, false, hitSFXGroup);
						//Vocal Shit
						vocals.volume = 1;

					case 'good':
						//For Good Rating
						FlxG.sound.play(Paths.sound("Note_" + hitsoundType + "_Good"), noteHitVolume, false, hitSFXGroup);
						//Vocal Shit
						vocals.volume = 0.85;

					case 'bad':
						//For Bad Rating
						FlxG.sound.play(Paths.sound("Note_" + hitsoundType + "_Bad"), noteHitVolume, false, hitSFXGroup);
						//Vocal Shit
						vocals.volume = 0.55;

					case 'shit':
						//For Shit Rating
						if (lagCompIcon.alpha < 0.1)
							FlxG.sound.play(Paths.sound("Note_" + hitsoundType + "_Crap"), noteHitVolume, false, hitSFXGroup);
						else
							FlxG.sound.play(Paths.sound("Note_" + hitsoundType + "_Bad"), noteHitVolume, false, hitSFXGroup);
						//Vocal Shit
						if (FlxG.save.data.shitBreaksCombo)
							vocals.volume = 0.1;
						else
							vocals.volume = 0.55;

					case 'miss':
						//For Miss Rating
						//Vocal Shit
						vocals.volume = 0;
				}
			}
			else
			{
				hitSFXGroup.stop();
				FlxG.sound.play(Paths.sound("Note_botplay"), noteHitVolume, false, hitSFXGroup);
				vocals.volume = 1;
			}
		}
		else if (hitsoundType != 'botplay')
		{
			susHitSFXGroup.stop();
			FlxG.sound.play(Paths.sound('Note_' + hitsoundType + '_Sustain'), noteHitVolume, false, susHitSFXGroup);
		}	
	}

	//Making this void (Copypaste of the above FUUUUU)
	function adjustVocVolOnNoteHit(note:Note):Void
	{
		var rating = note.rating;
		//FLXTIMER to prevent it from playing 2 at once
		//nOPE ya got soundlist for that shit!
		//new FlxTimer().start(0.003, function(tmr:FlxTimer)
		//{
		//	SFX for hitting notes (such as SICK, GOOD, BAD, SHIT, and SPECIAL NOTEs)
		if (!PlayStateChangeables.botPlay)
		{
			//Converted from nested if-else statements and 2 switch statements to a one switch! You're welcome!
			switch (rating)
			{
				case 'sick':
					//For Sick Rating
					//Vocal Shit
					vocals.volume = 1;
				case 'good':
					//For Good Rating
					//Vocal Shit
					if (!note.isSustainNote)
						vocals.volume = 0.85;
				case 'bad':
					//For Bad Rating
					//Vocal Shit
					if (!note.isSustainNote)
						vocals.volume = 0.55;
				case 'shit':
					//For Shit Rating
					//Vocal Shit
					if (!note.isSustainNote)
						vocals.volume = 0.1;
				case 'miss':
					vocals.volume = 0;
			}
		}
		else if (PlayStateChangeables.botPlay)
			vocals.volume = 1;
		//});
	}

	function enemyNoteHit(note:Note):Void
	{
		var altAnim:String = "";
		var enemyMissRandomizer:Bool = false;
	
		// Accessing the animation name directly to play it
		var singData:Int = Std.int(note.noteData);
		
		switch (SONG.song)
		{
			case "Sudden Confrontation" | "Sprouting Irritation":
				//trace ("Enemy miss is " + enemyMissRandomizer);
				if (enemyCanFail && health < 85)
				{
					if (!note.forceMiss && !note.isSustainNote)
					{
						curEnemyNote++;
						if (!note.isParent)
							enemyMissRandomizer = FlxG.random.bool(accuracy / 4);
						else
						{
							enemyMissRandomizer = FlxG.random.bool(accuracy / 8);
							note.parentID = curEnemyNote;
						}

						if (enemyMissRandomizer)
						{
							note.forceMiss = true;
							if (note.isParent)
								for (i in note.children)
								{
									i.forceMiss = true;
									i.sustainActive = false;
								}
							enemyNoteMiss(dataSuffix[singData]);
						}
					}
					else if (note.forceMiss && note.isSustainNote)
						enemyNoteMiss(dataSuffix[singData], true, note.parent.parentID);
				}
		}

		if (note.forceMiss)
		{
			return;
			trace('returnin');
		}

		//trace ("Enemy miss is " + enemyMissRandomizer);
		//trace ("then why the FUCK did this appear???");

		if (!note.tooLate)
		{
			//trace ("OK NOW Enemy miss is " + enemyMissRandomizer);

			if (SONG.notes[Math.floor(curStep / 16)] != null)
			{
				if (SONG.notes[Math.floor(curStep / 16)].altAnim)
					altAnim = '-alt';
			}

			//Enemy Sing Shit
			switch (SONG.song)
			{
				case "Sudden Confrontation" | "Sprouting Irritation":
					miscs.volume = 1;
					//"Enemy Sing" health drain
					if (healthBar.percent >= 25 && allowHealthModifiers && !note.withinCompensation)
					{
						if (!note.isSustainNote)
							targetHealth -= PlayStateHelpers.calculateHealth(storyDifficulty, 10, targetHealth, accuracy);
						else
							targetHealth -= PlayStateHelpers.calculateHealth(storyDifficulty, 11, targetHealth, accuracy);
					}
			}

			//Weird double anim prevention attempt?
			if (((!dad.animation.curAnim.name.startsWith("sing") || !dad.animation.curAnim.name.startsWith("cheer")) || dad.animation.curAnim.curFrame >= 1) && ((dad.animation.curAnim.name != "gunSHOOT" || dad.animation.curAnim.curFrame >= 3) && (dad.animation.curAnim.name != "gunLOAD" || dad.animation.curAnim.finished)))
				dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
			//trace ("NOW nemy miss is " + enemyMissRandomizer);

			if (FlxG.save.data.cpuStrums)
			{
				cpuStrums.forEach(function(spr:FlxSprite)
				{
					if (note.noteData == spr.ID)
						spr.animation.play('confirm', true);
					if (spr.animation.curAnim.name == 'confirm')
					{
						spr.centerOffsets();
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					}
				});
			}

			dad.holdTimer = 0;

			if (SONG.needsVoices)
				vocals.volume = 1;

			//trace ("OK NOW enemy miss is " + enemyMissRandomizer);
			//note.finnaBeKilled = true;
			note.active = false;
			note.kill();
			notes.remove(note, true);
			note.destroy();
			//trace('deleted nenemy note. The fucker missed = ' + enemyMissRandomizer);
			//OK so it aint deleting the note, find out why.
		}
		else
		{
			if (note.noteType == 'mine')
			{
				//trace("YOU BETTER NOT DELETE SHIT");
				note.visible = false;
				note.kill();
				notes.remove(note, true);
				//trace('removed via the too late thing');
			}
		}
	}

	var sustainSoundBool:Bool = false; //reduction of the amount of sounds the sustainnotes play

	function goodNoteHit(note:Note):Void
	{
		//double-count prevention
		if (!note.wasGoodHit)
		{
			causeOfDeath = '';

			if (note.mustPress && note.noteType != 'mine')
				note.wasGoodHit = true;

			var noteDiff:Float = -(note.strumTime - Conductor.songPosition);
			note.rating = Ratings.CalculateRating(noteDiff);

			if (note.rating == "miss")
				return;

			// add newest note to front of notesHitArray
			// the oldest notes are at the end and are removed first
			if (!note.isSustainNote)
			{
				if (note.noteType != 'mine')
				{
					combo += 1;
					notesHitArray.unshift(Date.now());
					popUpScore('', note);
					//This line of code was written before I die probably, If i die because of getting canceled on twitter because of politics please remember my name
					//MY    NAME      IS        SA kml km ,,   /
				}
				else if (FlxG.save.data.notesplash && !PlayStateChangeables.botPlay && allowHealthModifiers && !note.withinCompensation)
					sploshThisShitUp(note, note.rating);
			}

			if (!note.isSustainNote)
				mashPressThreshold++;
			else
			{
				//Health Gain for Sustain
				if (allowHealthModifiers)
					targetHealth += !mashing ? PlayStateHelpers.calculateHealth(storyDifficulty, 8, targetHealth, accuracy) : PlayStateHelpers.calculateHealth(storyDifficulty, 8, targetHealth, accuracy) / 4;
				songScore += 5;
				maxSongScore += 5;
				vocals.volume = 1;
				if (mashPresses <= mashPressThreshold)
					totalNotesHit += 1;
			}

			switch (note.noteType)
			{
				case 'mine':
					if (!note.isSustainNote)
						getFuckingShot();
				case 'trigger':
					if (stageOverlay.exists && !PlayStateChangeables.Optimize)
						stageOverlay.animation.play('static');
					dad.playAnim('gunSHOOT', true);
					camShake(true, false, 0.035);
					FlxG.sound.play(Paths.sound('Note_Trigger'), 1, false, hitSFXGroup);
					if (timesShot > 0 && note.rating == 'sick')
						timesShot--;
					//la health gain for trigger notes
					targetHealth += PlayStateHelpers.calculateHealth(storyDifficulty, 12, targetHealth, accuracy);
					//dodge anims (REPLACE WITH DEFLECT ANIMS)
					//if (boyfriend.animation.curAnim.curFrame >= 5)
					//{}
					switch (note.noteData)
					{
						case 0 | 1:
							boyfriend.playAnim('dodgeB', true);
						case 2 | 3:
							boyfriend.playAnim('dodgeA', true);
					}
					//trace("Dodge Anim/s (6119)");
				default:
					if (allowNoteHitSounds && FlxG.save.data.notesfx)
						playNoteHitSound(note);
					else
						adjustVocVolOnNoteHit(note);		
					if (!midsongCutscene)
					{
						if (boyfriend.animation.curAnim.name != 'hey' || boyfriend.animation.curAnim.curFrame >= 5)
						{
							//Weird double anim prevention attempt?
							if (!boyfriend.animation.curAnim.name.startsWith("sing") || boyfriend.animation.curAnim.curFrame >= 1)
							{
								switch (note.noteData)
								{
									case 0:
										boyfriend.playAnim('singLEFT', true);
									case 1:
										boyfriend.playAnim('singDOWN', true);
									case 2:
										boyfriend.playAnim('singUP', true);
									case 3:
										boyfriend.playAnim('singRIGHT', true);
								}
							}
						}
					}
			}

			if (note.mustPress)
			{
				var array = [note.strumTime, note.sustainLength, note.noteData, noteDiff];
				if (note.isSustainNote)
					array[1] = -1;
				if (doReplayShit)
				{
					//hummuna humman change this if you want to reenable results in story mode (3)
					saveNotes.push(array);
					saveJudge.push(note.rating);
				}
			}

			if (note.noteType != 'mine')
			{
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (note.noteData == spr.ID)
						spr.animation.play('confirm', true);
				});
			}

			//note.finnaBeKilled = true;
			if (!note.isSustainNote || note.delayedDeath && !note.isBehindParent)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			else
				note.delayedDeath = true;

			updateAccuracy();
		}
	}

	function pauseGame():Void
	{
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.pause();
			musicGroup.pause();
			vocals.pause();
			miscs.pause();

			switch (curSong)
			{
				case "Desperation" | "Disagreement" | "Retaliation":
					if (!startedCountdown && songStarted)
						if (stageSound.exists && stageSound.playing)
							stageSound.pause();
			}
		}

		// 5 / 1000 chance for Gitaroo Man easter egg
		//debating if i should remove this or not
		if (!FlxG.random.bool(0.5))
			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		else
			openSubState(new GitarooPause());	
	}

	function literallyFuckingDie():Void
	{
		if (startTimer != null && !startTimer.finished)
			startTimer.active = false;

		if (causeOfDeath == '' || FlxG.keys.justPressed.R)
			causeOfDeath = 'skill-issue';

		camGame.stopFX();
		camHUD.stopFX();

		specilNoteSFXGroup.volume = 0.65;

		boyfriend.stunned = true;
		prevHealth = 1;

		persistentUpdate = false;
		persistentDraw = false;
		paused = true;
		died = true;

		campaignDeaths++;
		songDeaths++;
		hasReset = true;
		showedLoadingIcon = true;

		if (songStarted)
		{
			vocals.stop();
			miscs.stop();
			FlxG.sound.music.stop();
			musicGroup.stop();
		}

		openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
	}

	function lightningStrikeShit():Void
	{
		stageSound = FlxG.sound.play(Paths.soundRandom('glitch_', 1, 2, 'week2'), 0.85 - (0.05 * storyProgress));
		stageSound.persist = true;
		stageSound.autoDestroy = true;

		if (FlxG.save.data.flashing)
			theBorderBG.animation.play('lightning');
		else
			theBorderBG.animation.play('glitch');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(16, 32);

		boyfriend.playAnim('scared', true);
		dad.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	//var danced:Bool = false;
	var strumTweenToggle:Bool = false;

	override function stepHit()
	{
		super.stepHit();

		if (hurtDelay > 0)
			hurtDelay--;

		if (doStrumLineBGTweening)
		{
			if (nearestNoteDecayBeat > 1)
			{
				if (strumTweenToggle)
				{
					strumTweenToggle = false;
					if (strumLineBGTween != null)
						strumLineBGTween.cancel();
					strumLineBGTween = FlxTween.tween(grpStrumLine, {alpha: 1}, (Conductor.stepCrochet / 1000), {type: ONESHOT, ease: FlxEase.smootherStepOut, onComplete:
						function (twn:FlxTween)
						{
							strumLineBGTween = null;
						}
					});
				}
			}
			else
			{
				if (!strumTweenToggle)
				{
					strumTweenToggle = true;
					if (strumLineBGTween != null)
						strumLineBGTween.cancel();
					strumLineBGTween = FlxTween.tween(grpStrumLine, {alpha: 0.7}, Conductor.crochet * 2 / 1000, {type: ONESHOT, ease: FlxEase.quadOut, startDelay: Conductor.crochet * 2 / 1000, onComplete:
						function (twn:FlxTween)
						{
							strumLineBGTween = null;
						}
					});
				}
			}
		}

		//Moved from BeatHit
		//if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition)) > 20
		|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition)) > 20))
		{
			if (!resultsPresent && !inCutscene && generatedMusic && songStarted && !endedSong)
				resyncVocals();
		}

		if (generatedMusic && SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (SONG.notes[Std.int(curStep / 16)].mustHitSection)
				isBFTurn = true;
			else
				isBFTurn = false;
			
			// Make sure Girlfriend cheers only for certain songs
			if (!resultsPresent && !endedSong && generatedMusic)
			{
				// Don't animate GF if something else is already animating her (eg. train passing)
				if (gf.animation.curAnim.name == 'danceLeft'
				|| gf.animation.curAnim.name == 'danceRight'
				|| gf.animation.curAnim.name == 'idle'
				|| gf.animation.curAnim.name.startsWith('sing'))
				{
					// Per song treatment since some songs will only have the 'Hey' at certain times
					switch (curSong)
					{
						case 'Tech. Difficulties':
							// General duration of the song
							if(curBeat < 280)
							{
								// Beats to skip or to stop GF from cheering
								if(curBeat != 7 && curBeat != 23 && curBeat != 39 && curBeat != 71 && curBeat != 87  && curBeat != 167  && curBeat != 199  && curBeat != 215)
								{
									if(curBeat % 8 == 7)
									{
										// Just a guarantee that it'll trigger just once
										if(!triggeredAlready)
										{
											if (accuracy > 75 || curBeat < 32)
											{
												gf.playAnim('cheer');
											}
											else
											{
												gf.playAnim('cheerFail');
											}
											triggeredAlready = true;
										}
									}
									else 
										triggeredAlready = false;
								}
							}
						case 'Awkward Pauses':
							// General duration of the song
							if(curBeat < 410)
							{
								// Beats to skip or to stop GF from cheering
								if(curBeat != 7 && curBeat != 15 && curBeat != 23 && curBeat != 31 && curBeat != 39 && curBeat != 55 && curBeat != 71 && curBeat != 87 
								&& curBeat != 103 && curBeat != 119 && curBeat != 127 && curBeat != 143 && curBeat != 159 && curBeat != 175 && curBeat != 191 && curBeat != 199 
								&& curBeat != 215 && curBeat != 231 && curBeat != 247 && curBeat != 255 && curBeat != 263 && curBeat != 279 && curBeat != 287 && curBeat != 303 
								&& curBeat != 319 && curBeat != 335 && curBeat != 351 && curBeat != 367 && curBeat != 384 && curBeat != 399)
								{
									if(curBeat % 8 == 7)
									{
										// Just a guarantee that it'll trigger just once
										if(!triggeredAlready)
										{
											if (accuracy > 75 || curBeat < 84)
											{
												gf.playAnim('cheer');
											}
											else
											{
												gf.playAnim('cheerFail');
											}
											styleCheck();
											triggeredAlready = true;
										}
									}
									else 
										triggeredAlready = false;
								}
							}
						case 'Retaliation':
							if (healthBar.percent >= 25 && camZooming)
							{
								if (!inSongClimax)
									targetHealth -= 0.001 * storyDifficulty; 
								else
									targetHealth -= 0.005 * storyDifficulty; 
							}
					}
				}
				camFollowShit();
			}
			
			//camFollowShit();

			// yes this updates every ~~step~~ beat.
			// yes this is bad (but less bad compared to updating every step)
			// but i'm doing it to update misses and accuracy (bro it's discord, nobody would mind)
			//I have learned why it needs to be every step, I have reverted this change.
			#if windows
			// Updating Discord Rich Presence (with Time Left)
			if (FlxG.save.data.showPresence && !paused && !resultsPresent && !endedSong)
			{
				DiscordClient.changePresence(detailsText
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ")   ",
					"\nRating: "
					+ Ratings.GenerateLetterRank(accuracy)
					+ " ("
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "%) | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, true,
					songLength
					- Conductor.songPosition - FlxG.save.data.offset + songOffset);
			}
			#end
		}
		//camFollowShit();
	}

	var isBFTurn:Bool = false;

	//Removed from void, does this fix doCamFollowing?
	//No
	//bro it's the charts
	function camFollowShit():Void
	{	
		if (camGame.followLerp != camFollowSpeed * (30 / FlxG.save.data.fpsCap))
			camGame.followLerp = camFollowSpeed * (30 / FlxG.save.data.fpsCap);

		if (SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (doCamFollowing)
			{
				if (camFollow.x != dad.getMidpoint().x + 150 + dadCamFollowOffsetX && !isBFTurn)
				{
					//Copy paste cause it literally needs to be (1)
					//if (timesShot > 0)
						//timesShot--;
		
					//Mashing Detection Reset
					if (mashPresses < mashPressThreshold)
					{
						mashPresses = 0;
						mashing = false;
					}
					else
					{
						mashPresses -= mashPressThreshold;
						mashPresses = Math.round(mashPresses / 2);
					}
					mashPressThreshold = defaultMashingThreshold;

					stylePresses = 0;
		
					if (badStyleHits > 8)
						badStyleHits -= 8;
					else
						badStyleHits = 0;

					if (curSong == 'Mic Test' && !PlayStateChangeables.Optimize && generatedMusic && curBeat >= 4)
					{
						if (camTween != null)
							camTween.cancel();
						camTween = FlxTween.tween(camGame, {zoom: 1.5}, (Conductor.stepCrochet * 4 / 900), {type: ONESHOT, ease: FlxEase.elasticInOut, onComplete:
							function (twn:FlxTween)
							{
								camTween = null;
							}
						});
					}
						
					camFollow.setPosition(dad.getMidpoint().x + 150 + dadCamFollowOffsetX, dad.getMidpoint().y - 100 + dadCamFollowOffsetY);
					//trace("CamFollowed Dad");

					vocals.volume = 1;
					//trace("Vocal Volume = " + vocals.volume);

					//CamFollow Repositioning Per Dad Char
					/*switch (dad.curCharacter)
					{
					}*/
				}

				if (camFollow.x != boyfriend.getMidpoint().x - 100 + bfCamFollowOffsetX && isBFTurn)
				{	
					//Copy paste cause it literally needs to be (2)
					//if (timesShot > 0)
						//timesShot--;
		
					//Mashing Detection Reset
					if (mashPresses < mashPressThreshold)
					{
						mashPresses = 0;
						mashing = false;
					}
					else
					{
						mashPresses -= mashPressThreshold;
						mashPresses = Math.round(mashPresses / 2);
					}
					mashPressThreshold = defaultMashingThreshold;
		
					if (badStyleHits > 8)
						badStyleHits -= 8;
					else
						badStyleHits = 0;

					if (curSong == 'Mic Test' && !PlayStateChangeables.Optimize && generatedMusic && curBeat >= 4) // && (camTweened || camTweened == null))
					{
						if (camTween != null)
							camTween.cancel();
						camTween = FlxTween.tween(camGame, {zoom: 1.2}, (Conductor.stepCrochet * 4 / 800), {type: ONESHOT, ease: FlxEase.elasticInOut, onComplete:
							function (twn:FlxTween)
							{
								camTween = null;
							}
						});
					}

					camFollow.setPosition(boyfriend.getMidpoint().x - 100 + bfCamFollowOffsetX, boyfriend.getMidpoint().y - 100 + bfCamFollowOffsetY);
					//trace("CamFollowed BF");
					vocals.volume = 1;
				}
			}
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	var lowHealthEffectVolume:Float = 0;

	function doSubtitleShit():Void
	{
		if (hasSubtitles && FlxG.save.data.subtitles)
		{
			switch (curSong)
			{
				case "Mic Test":
					switch (curBeat)
					{ 
						//NOTE FOR FUTURE SAMUELS:  PREVENT CRASH WHEN SKIPPING IN TUTORIAL USING BOOL preventTutorialTips
						case 6:
							subtitleTimer = new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								changeSubtitles("Mic test.", 0xFFfff300);
							});
						case 8:
							clearSubtitles();
							if (!preventTutorialTips)
								subtitleTimer = new FlxTimer().start(0.025, function(tmr:FlxTimer)
								{
									tutorialGraphicA.alpha += 0.085;
									for (i in 0...4)
										tutorialText.members[i].alpha += tutorialGraphicA.alpha;
									if (tutorialGraphicA.alpha < 1)
										tmr.reset(0.025);
								});
						case 20:
							if (!preventTutorialTips)
								subtitleTimer = new FlxTimer().start(0.025, function(tmr:FlxTimer)
								{
									tutorialGraphicA.alpha -= 0.09;
									for (i in 0...4)
									{
										//trace('check0');
										tutorialText.members[i].alpha -= tutorialGraphicA.alpha;
									}
									if (tutorialGraphicA.alpha > 0)
										tmr.reset(0.025);
									else
									{
										tutorialGraphicA.destroy();
										for (i in 0...4)
										{
											//trace('check1');
											tutorialText.members[i].kill();
										}
										tutorialText.remove(bindTxtLeft);
										tutorialText.remove(bindTxtDown);
										tutorialText.remove(bindTxtUp);
										tutorialText.remove(bindTxtRight);
										if (tutorialText.exists)
											tutorialText.destroy();
										//trace ('made it past this');
									}
								});
						case 22:
							changeSubtitles("Ok, here we go.", 0xFFfff300);
						case 24:
							clearSubtitles();
							if (!preventTutorialTips)
								subtitleTimer = new FlxTimer().start(0.025, function(tmr:FlxTimer)
								{
									tutorialGraphicB.alpha += 0.085;
									if (tutorialGraphicB.alpha < 1)
										tmr.reset(0.025);
								});
						case 39:
							if (!preventTutorialTips)
								subtitleTimer = new FlxTimer().start(0.025, function(tmr:FlxTimer)
								{
									tutorialGraphicB.alpha -= 0.09;
									if (tutorialGraphicB.alpha > 0)
										tmr.reset(0.025);
									else
										tutorialGraphicB.destroy();
								});
						case 40:
							if (!preventTutorialTips)
								subtitleTimer = new FlxTimer().start(0.025, function(tmr:FlxTimer)
								{	
									tutorialGraphicC.alpha += 0.085;
									if (tutorialGraphicC.alpha < 1)
										tmr.reset(0.025);
								});
						case 52:
							if (!preventTutorialTips)
								subtitleTimer = new FlxTimer().start(0.025, function(tmr:FlxTimer)
								{
									tutorialGraphicC.alpha -= 0.09;
									if (tutorialGraphicC.alpha > 0)
										tmr.reset(0.025);
									else
										tutorialGraphicC.destroy();
								});
						case 53:
							changeSubtitles("Ok, do as I say!", 0xFFfff300);
						case 56:
							changeSubtitles("Left.", 0xFFfff300);
						case 58:
							changeSubtitles("Right.", 0xFFfff300);
						case 59:
							changeSubtitles("Everyone, left", 0xFFfff300);
						case 61:
							changeSubtitles("Everyone, right!", 0xFFfff300);
						case 64:
							clearSubtitles();
						case 70:
							changeSubtitles("Good job!", 0xFFfff300);
						case 72:
							changeSubtitles("Up.", 0xFFfff300);
						case 74:
							changeSubtitles("Down.", 0xFFfff300);
						case 75:
							changeSubtitles("Everyone, up", 0xFFfff300);
						case 77:
							changeSubtitles("Everyone, down!", 0xFFfff300);
						case 80:
							clearSubtitles();
						case 86:
							changeSubtitles("Yes, good job!", 0xFFfff300);
						case 88:
							changeSubtitles("Left", 0xFFfff300);
						case 90:
							changeSubtitles("Up", 0xFFfff300);
						case 91:
							changeSubtitles("Everyone, down", 0xFFfff300);
						case 93:
							changeSubtitles("Everyone, right!", 0xFFfff300);
						case 96:
							clearSubtitles();
						case 102:
							changeSubtitles("That's how you do it!", 0xFFfff300);
						case 104:
							changeSubtitles("Right", 0xFFfff300);
						case 106:
							changeSubtitles("Down", 0xFFfff300);
						case 107:
							changeSubtitles("Everyone, left", 0xFFfff300);
						case 109:
							changeSubtitles("Everyone, up!", 0xFFfff300);
						case 112:
							clearSubtitles();
						case 118:
							changeSubtitles("Now, free-style it!", 0xFFfff300);
						case 120:
							clearSubtitles();
						case 150:
							changeSubtitles("Ok, here we go-", 0xFFfff300);
						case 152:
							changeSubtitles("You may rise.", 0xFFfff300);
						case 156:
							changeSubtitles("You may fall.", 0xFFfff300);
						case 160:
							changeSubtitles("Say left, right, up, up, down, right", 0xFFfff300);
						case 164:
							changeSubtitles("You may now", 0xFFfff300);
						case 166:
							changeSubtitles("You may NOW FREE-STYLE IT!", 0xFFfff300);
						case 168:
							clearSubtitles();
						case 180:
							changeSubtitles("That's how you do it, good job!", 0xFFfff300);
						case 184:
							changeSubtitles("Ok up, rise, down, left, right.", 0xFFfff300);
						case 188:
							changeSubtitles("Down, left, right, right, fall.", 0xFFfff300);
						case 192:
							changeSubtitles("Down, down, up, right", 0xFFfff300);
						case 196:
							changeSubtitles("Down, down, up, right, left, up, up", 0xFFfff300);
						case 198:
							changeSubtitles("NOW, free-style it!", 0xFFfff300);
						case 200:
							clearSubtitles();
						case 212:
							changeSubtitles("That's how you do it!", 0xFFfff300);
						case 214:
							changeSubtitles("Ok here we go.", 0xFFfff300);
						case 216:
							clearSubtitles();
						case 278:
							changeSubtitles("That's how you do it!!", 0xFFfff300);
						case 280:
							clearSubtitles();
					}
				case "Desperation":
					switch (curBeat)
					{
						case 0:
							changeSubtitles("Lord, please help us!", 0xFF5ce766);
						case 1:
							changeSubtitles("Lord, please help us!", 0xFF5ce766);
						case 4:
							changeSubtitles("Oh Lord, please help us!", 0xFF5ce766);
						case 8:
							changeSubtitles("Lord, Lord, please help us!", 0xFF5ce766);
						case 12:
							changeSubtitles("[Speaking in tounges]", 0xFF5ce766);
						case 16:
							clearSubtitles();
						case 32:
							changeSubtitles("Help us, oh Lord please help us!", 0xFF5ce766);
						case 40:
							changeSubtitles("Lord, please help us", 0xFF5ce766);
						case 44:
							changeSubtitles("please, Lord help us!", 0xFF5ce766);
						case 48:
							clearSubtitles();
						case 64:
							changeSubtitles("[Speaking in tounges]", 0xFF5ce766);
						case 68:
							clearSubtitles();
						case 96:
							changeSubtitles("[Speaking in tounges]", 0xFF5ce766);
						case 100:
							clearSubtitles();
						case 128:
							changeSubtitles("Lord, please help us!", 0xFF5ce766);
						case 132:
							changeSubtitles("Oh Lord, please help us!", 0xFF5ce766);
						case 136:
							changeSubtitles("Lord, Lord, please help us!", 0xFF5ce766);
						case 140:
							changeSubtitles("[Speaking in tounges]", 0xFF5ce766);
						case 144:
							clearSubtitles();
						case 160:
							changeSubtitles("Help us, Lord please help us!", 0xFF5ce766);
						case 168:
							changeSubtitles("Lord, please help us!", 0xFF5ce766);
						case 172:
							changeSubtitles("[changeSubtitles(%NoOneCanHearYou%, 0xFF5ce766);]", 0xffa38e8e);
						case 173:
							changeSubtitles("[%%%%%%%%]", 0xffa38e8e, ADD);
						case 176:
							changeSubtitles("(I don't think)", 0xFF4adaff);
						case 180:
							changeSubtitles("(that I can follow through that-)", 0xFF4adaff);
						case 184:
							changeSubtitles("(I feel as if...)", 0xFF4adaff);
						case 188:
							changeSubtitles("(it's too much for me-?)", 0xFF4adaff);
						case 190:
							clearSubtitles();
						case 192:
							changeSubtitles("LORD. PLEASE. HELP. 'US'.", 0xFF5ce766);
						case 196:
							changeSubtitles("OH, LORD. PLEASE. 'HELP'. 'US'.", 0xFF5ce766);
						case 200:
							changeSubtitles("LORD LORD, PLEASE. HELP. 'US'.", 0xFF5ce766);
						case 204:
							changeSubtitles("[Angry babbling]", 0xff9feea4);
						case 208:
							changeSubtitles("(I don't mean to)", 0xFF4adaff);
						case 212:
							changeSubtitles("(disrespect our religion-)", 0xFF4adaff);
						case 216:
							changeSubtitles("(I just want to state that)", 0xFF4adaff);
						case 220:
							changeSubtitles("(that part is a little too hard for me-)", 0xFF4adaff);
						case 224:
							changeSubtitles("OH, HELP 'US'.", 0xFF5ce766);
						case 228:
							changeSubtitles("LORD. PLEASE. HELP. 'US'.", 0xFF5ce766);
						case 232:
							changeSubtitles("LORD. 'PLEASE'. HELP. 'US'.", 0xFF5ce766);
						case 236:
							changeSubtitles("PLEASE LORD HELP 'US', OH.", 0xFF5ce766);
						case 240:
							changeSubtitles("(Please just listen)", 0xFF4adaff);
						case 244:
							changeSubtitles("(I didn't mean to offend you.)", 0xFF4adaff);
						case 248:
							changeSubtitles("(I just don't think)", 0xFF4adaff);
						case 252:
							changeSubtitles("{I can help you..?}", 0xFF4adaff);	
						case 255:
							subtitleTimer = new FlxTimer().start(0.1, function(tmr:FlxTimer)
							{
								changeSubtitles("(um-)", 0xFF4adaff);
							});
						case 256:
							clearSubtitles();
					}
				case "Disagreement":
					switch (curBeat)
					{
						case 127:
							changeSubtitles("HUH?!", 0xFF5ce766);
						case 129:
							clearSubtitles();
						case 132:
							changeSubtitles("When will you learn?!", 0xFF5ce766);
						case 136:
							changeSubtitles("(Please!)", 0xFF4adaff);
						case 140:
							changeSubtitles("(Try to listen to me!)", 0xFF4adaff);
						case 148:
							changeSubtitles("What do you mean it's my fault??", 0xFF5ce766);
						case 154:
							changeSubtitles("(That's not)", 0xFF4adaff);
						case 156:
							changeSubtitles("(That's not even)", 0xFF4adaff);
						case 158:
							changeSubtitles("(That's not even what)", 0xFF4adaff);
						case 159:
							changeSubtitles("(That's not even what I)", 0xFF4adaff);
						case 160:
							changeSubtitles("{That's not even what I said!}", 0xFF4adaff);
						case 162:
							clearSubtitles();
						case 179:
							changeSubtitles("I don't think you understood that.", 0xFF5ce766);
						case 184:
							changeSubtitles("{Ugh-!}", 0xFF4adaff);
						case 186:
							changeSubtitles("Grgh-", 0xFF5ce766);
						case 188:
							changeSubtitles("LET ME TELL YOU ONCE AGAIN.", 0xFF5ce766);
						case 191:
							changeSubtitles("(wh-)", 0xFF4adaff);
						case 192:
							clearSubtitles();
						case 254:
							changeSubtitles("[Angry Sigh]", 0xff9feea4);
						case 256:
							clearSubtitles();
					}
				case "Retaliation":
					switch (curBeat)
					{
						case 32:
							changeSubtitles("{How could one say}", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 36:
							changeSubtitles("{How could one say something so demeaning?}", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 40:
							changeSubtitles("{To someone who}", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 44:
							changeSubtitles("{To someone who did all of the cleaning after}", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 48:
							changeSubtitles("{something young and dumb}", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 54:
							changeSubtitles("{something young and dumb and oh}", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 58:
							changeSubtitles("{something young and dumb and oh so fragile}", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 64:
							clearSubtitles();
						case 96:
							changeSubtitles("{All your mother wanted was to}", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 100:
							changeSubtitles("{All your mother wanted was to give us cheer.}", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 104:
							changeSubtitles("{Nobody expected that we'd}", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 108:
							changeSubtitles("{Nobody expected that we'd end up here.}", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 111:
							changeSubtitles("{Just you and me and}", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 116:
							changeSubtitles("{Just you and me and her}", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 118:
							changeSubtitles("{10}", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 120:
							changeSubtitles("{10 miles}", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 122:
							changeSubtitles("{10 miles far}", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 123:
							changeSubtitles("{10 miles far away into the city}.", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 128:
							changeSubtitles("(Never have you ever not)", 0xFF4adaff, FlxColor.BLACK, NORMAL, 0.1);
						case 132:
							changeSubtitles("(Never have you ever not shifted the blame to me)", 0xFF4adaff, FlxColor.BLACK, NORMAL, 0.125);
						case 136:
							changeSubtitles("(I don't even know if)", 0xFF4adaff, FlxColor.BLACK, NORMAL, 0.15);
						case 140:
							changeSubtitles("(I don't even know if one day you'll be sorry)", 0xFF4adaff, FlxColor.BLACK, NORMAL, 0.175);
						case 143:
							subtitleTimer = new FlxTimer().start((Conductor.crochet / 1000) / 0.75, function(tmr:FlxTimer)
							{
								//addSubtitles("\n(Because of that I sometimes)", 0xFF4adaff, FlxColor.BLACK);
								changeSubtitles("(Because of that I sometimes)", 0xFF4adaff, FlxColor.BLACK, NORMAL, 0.3);
							});
						//case 146:
							//changeSubtitles("(Because of that I sometimes)", 0xFF4adaff, FlxColor.BLACK, NORMAL, 0.3);
						case 152:
							changeSubtitles("(Because of that I sometimes wish that)", 0xFF4adaff, FlxColor.BLACK, NORMAL, 0.5);
						case 154:
							changeSubtitles("(Because of that I sometimes wish that)", 0xFF4adaff, FlxColor.BLACK, NORMAL, 0.7);
						case 155:
							changeSubtitles("{Because of that I sometimes wish that I was never your son.}", 0xFF4adaff, FlxColor.BLACK, MULTIPLY, 0.9);
						case 159:
							FlxFlicker.flicker(subtitleText, Conductor.crochet / 1000, 0.03, true);
							FlxFlicker.flicker(subtitleBackground, Conductor.crochet / 1000, 0.03, true);	
						case 160:
							clearSubtitles();
						case 224:
							changeSubtitles("{You still are}", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 227:
							changeSubtitles("{You still are an ungrateful little sick brat}", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 232:
							changeSubtitles("{Maybe one day you'll}", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 235:
							changeSubtitles("{Maybe one day you'll realize your mistakes so that}", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 240:
							changeSubtitles("{You'll drown in regret}", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 246:
							changeSubtitles("{You'll drown in regret once}", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 248:
							changeSubtitles("{You'll drown in regret once it's}", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 250:
							changeSubtitles("{You'll drown in regret once it's too}", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 252:
							changeSubtitles("{You'll drown in regret once it's too late}", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 254:
							changeSubtitles("{You'll drown in regret once it's too late for}", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 256:
							changeSubtitles("{You'll drown in regret once it's too late for change.}", FlxColor.TRANSPARENT, 0xFFD39D9D, SUBTRACT, 1, 0, "VCR OSD Mono");
						case 258:
							clearSubtitles();
						case 288:
							changeSubtitles("Often times he comes home drunk.", 0x00000000, 0xFF5ce766, SUBTRACT, 0.5, 0, "Times New Roman");
						case 292:
							changeSubtitles("Then gets pissed off when you flunk.", 0x00000000, 0xFF5ce766, SUBTRACT, 0.5, 0, "Times New Roman");
						case 296:
							changeSubtitles("(Can you hear me?)", 0xFF4adaff, FlxColor.BLACK, NORMAL, 0.3);
						case 300:
							changeSubtitles("(Can you hear me? I CAN'T SAY THE SAME FOR YOU.)", 0xFF4adaff, FlxColor.BLACK, NORMAL, 0.4);
						case 304:
							changeSubtitles("Can't run from the truth", 0x00000000, 0xFF5ce766, SUBTRACT, 0.5, 0, "Times New Roman");
						case 310:
							changeSubtitles("Why", 0x00000000, 0xFF5ce766, SUBTRACT, 0.5, 0, "Times New Roman");
						case 312:
							changeSubtitles("Why don't", 0x00000000, 0xFF5ce766, SUBTRACT, 0.5, 0, "Times New Roman");
						case 314:
							changeSubtitles("Why don't you", 0x00000000, 0xFF5ce766, SUBTRACT, 0.5, 0, "Times New Roman");
						case 315:
							changeSubtitles("Why don't you just give up your own fleeting youth", 0x00000000, 0xFF5ce766, SUBTRACT, 0.5, 0, "Times New Roman");
						case 320:
							changeSubtitles("(I don't care for what you think.)", 0xFF4adaff, FlxColor.BLACK, NORMAL, 0.5);
						case 324:
							changeSubtitles("(You'll just like watching me sink.)", 0xFF4adaff, FlxColor.BLACK, NORMAL, 0.5);
						case 328:
							changeSubtitles("You're a coward.", 0x00000000, 0xFF5ce766, SUBTRACT, 0.5, 0, "Times New Roman");
						case 332:
							changeSubtitles("You're a coward. All your fears have gone empowered.", 0x00000000, 0xFF5ce766, SUBTRACT, 0.5, 0, "Times New Roman");
						case 336:
							changeSubtitles("(All I ever WANT)", 0xFF4adaff, FlxColor.BLACK, NORMAL, 0.5);
						case 342:
							changeSubtitles("(All I ever WANT is)", 0xFF4adaff, FlxColor.BLACK, NORMAL, 0.5);
						case 344:
							changeSubtitles("(All I ever WANT is for)", 0xFF4adaff, FlxColor.BLACK, NORMAL, 0.5);
						case 346:
							changeSubtitles("(All I ever WANT is for things)", 0xFF4adaff, FlxColor.BLACK, NORMAL, 0.5);
						case 347:
							changeSubtitles("{All I ever WANT is for things to be like it once was...}", 0xFF4adaff, FlxColor.BLACK, NORMAL, 0.5);
						case 351:
							FlxFlicker.flicker(subtitleText, Conductor.crochet / 1000, 0.03, true);
							FlxFlicker.flicker(subtitleBackground, Conductor.crochet / 1000, 0.03, true);
						case 352:
							clearSubtitles();
					}
				case "Kid With a Gun":
					switch(curBeat)
					{
						case 68:
							subtitleTimer = new FlxTimer().start(0.22, function(tmr:FlxTimer)
							{
								changeSubtitles("What are you doing in here?", 0xFFb7d855);
							});
						case 72:
							subtitleTimer = new FlxTimer().start(0.22, function(tmr:FlxTimer)
							{
								changeSubtitles("Get out! Get out!", 0xFFb7d855);
							});
						case 76:
							changeSubtitles("What are you doing in here?", 0xFFb7d855);
						case 80:
							subtitleTimer = new FlxTimer().start(0.22, function(tmr:FlxTimer)
							{
								changeSubtitles("Please leave me two alone.", 0xFFb7d855);
							});
						case 83:
							subtitleTimer = new FlxTimer().start(0.22, function(tmr:FlxTimer)
							{
								changeSubtitles("(Sir, we don't know why we're here nor)", 0xFF4adaff);
							});
						case 88:
							subtitleTimer = new FlxTimer().start(0.22, function(tmr:FlxTimer)
							{
								changeSubtitles("(what we're here for.)", 0xFF4adaff);
							});
						case 92:
							changeSubtitles("(We'll try to find an exit)", 0xFF4adaff);
						case 96:
							subtitleTimer = new FlxTimer().start(0.22, function(tmr:FlxTimer)
							{
								changeSubtitles("(so that we could leave you lone.)", 0xFF4adaff);
							});
						case 100:
							subtitleTimer = new FlxTimer().start(0.22, function(tmr:FlxTimer)
							{
								changeSubtitles("What are you doing in here?!", 0xFFb7d855);
							});
						case 104:
							subtitleTimer = new FlxTimer().start(0.22, function(tmr:FlxTimer)
							{
								changeSubtitles("Get out! Get out!", 0xFFb7d855);
							});
						case 108:
							changeSubtitles("What are you doing in here!?", 0xFFb7d855);
						case 112:
							subtitleTimer = new FlxTimer().start(0.22, function(tmr:FlxTimer)
							{
								changeSubtitles("Please leave me two alone!", 0xFFb7d855);
							});
						case 115:
							subtitleTimer = new FlxTimer().start(0.22, function(tmr:FlxTimer)
							{
								changeSubtitles("(Sir, I'm trying to tell you that)", 0xFF4adaff);
							});
						case 120:
							changeSubtitles("(we're not here to threaten you)", 0xFF4adaff);
						case 124:
							changeSubtitles("(We're trying to find an exit)", 0xFF4adaff);
						case 128:
							subtitleTimer = new FlxTimer().start(0.22, function(tmr:FlxTimer)
							{
								changeSubtitles("(so that we could leave you alone.)", 0xFF4adaff);
							});
						case 132:
							subtitleTimer = new FlxTimer().start(0.11, function(tmr:FlxTimer)
							{
								changeSubtitles("Don't make me tell you one more time.", 0xFFb7d855);
							});
						case 136:
							subtitleTimer = new FlxTimer().start(0.22, function(tmr:FlxTimer)
							{
								changeSubtitles("Leave or die. Leave or DIE.", 0xFFb7d855);
							});
						case 140:
							subtitleTimer = new FlxTimer().start(0.11, function(tmr:FlxTimer)
							{
								changeSubtitles("(Don't need to tell us one more time)", 0xFF4adaff);
							});
						case 144:
							subtitleTimer = new FlxTimer().start(0.22, function(tmr:FlxTimer)
							{
								changeSubtitles("(we won't try, we won't try!)", 0xFF4adaff);
							});
						case 148:
							changeSubtitles("Don't make me tell you ONE. MORE. TIME.", 0xFFb7d855);
						case 152:
							subtitleTimer = new FlxTimer().start(0.11, function(tmr:FlxTimer)
							{
								changeSubtitles("Leave or DIE, Leave or DIE!", 0xFFb7d855);
							});
						case 156:
							changeSubtitles("(Sir, you don't need to tell us one more time)", 0xFF4adaff);
						case 160:
							subtitleTimer = new FlxTimer().start(0.11, function(tmr:FlxTimer)
							{
								changeSubtitles("(we won't pry, we won't pry.)", 0xFF4adaff);
							});
						case 164:
							subtitleTimer = new FlxTimer().start(0.11, function(tmr:FlxTimer)
							{
								changeSubtitles("Don't make me tell you one more time.", 0xFFb7d855);
							});
						case 168:
							subtitleTimer = new FlxTimer().start(0.11, function(tmr:FlxTimer)
							{
								changeSubtitles("I'LL SHOOT YOU IF YOU DON'T LEAVE!", 0xFFb7d855);
							});
						case 172:
							subtitleTimer = new FlxTimer().start(0.11, function(tmr:FlxTimer)
							{
								changeSubtitles("(Sir, I have told you many times)", 0xFF4adaff);
							});
						case 176:
							changeSubtitles("(is my voice not audible??)", 0xFF4adaff);
						case 180:
							changeSubtitles("Leave. now. or. die.", 0xFFb7d855);
						case 184:
							changeSubtitles("LEAVE. NOW. OR. DIE.", 0xFFb7d855);
						case 188:
							changeSubtitles("(Can anyone hear me...)", 0xFF4adaff);
						case 192:
							changeSubtitles("(Please someone, hear me...)", 0xFF4adaff);
						case 194:
							FlxFlicker.flicker(subtitleText, Conductor.crochet / 1000 / 0.75, 0.06, true);
							FlxFlicker.flicker(subtitleBackground, Conductor.crochet / 1000 / 0.75, 0.06, true);
						case 195:
							subtitleText.alpha = 0;
							subtitleBackground.alpha = 0;
						case 196:
							subtitleTimer = new FlxTimer().start(0.22, function(tmr:FlxTimer)
							{
								subtitleText.alpha = 1;
								subtitleBackground.alpha = 0.45;
								changeSubtitles("What are you doing in here?!", 0xFFb7d855);
							});
						case 200:
							subtitleTimer = new FlxTimer().start(0.22, function(tmr:FlxTimer)
							{
								changeSubtitles("Get out! Get out!", 0xFFb7d855);
							});
						case 204:
							changeSubtitles("What are you doing in here!?", 0xFFb7d855);
						case 208:
							subtitleTimer = new FlxTimer().start(0.22, function(tmr:FlxTimer)
							{
								changeSubtitles("Please leave me alone.", 0xFFb7d855);
							});
						case 210:
							changeSubtitles("Please leave me two ALONE!", 0xFFb7d855);
						case 212:
							clearSubtitles();
						case 228:
							subtitleTimer = new FlxTimer().start(0.22, function(tmr:FlxTimer)
							{
								changeSubtitles("What are you doing in here?!", 0xFFb7d855);
							});
						case 232:
							subtitleTimer = new FlxTimer().start(0.22, function(tmr:FlxTimer)
							{
								changeSubtitles("Get out! Get out!", 0xFFb7d855);
							});
						case 236:
							changeSubtitles("What are you doing in here!?", 0xFFb7d855);
						case 240:
							subtitleTimer = new FlxTimer().start(0.22, function(tmr:FlxTimer)
							{
								changeSubtitles("PLEASE LEAVE ME TWO ALONE!", 0xFFb7d855);
							});
						case 244:
							clearSubtitles();
					}
				case "Playing With Fire":
					switch (curBeat)
					{
						case 96:
							changeSubtitles("This is your last warning.", 0xFFb7d855);
						case 99:
							changeSubtitles("Leave now before I start firing my gun", 0xFFb7d855);
						case 104:
							changeSubtitles("pointed at your", 0xFFb7d855);
						case 108:
							changeSubtitles("pointed at your goddamn", 0xFFb7d855);
						case 110:
							changeSubtitles("pointed at your goddamn faces!", 0xFFb7d855);
						case 112:
							clearSubtitles();
						case 128:
							changeSubtitles("THIS IS YOUR LAST WARNING.", 0xFFb7d855);
						case 131:
							changeSubtitles("LEAVE NOW BEFORE I START FIRING MY GUN", 0xFFb7d855);
						case 136:
							changeSubtitles("POINTED AT YOUR", 0xFFb7d855);
						case 140:
							changeSubtitles("POINTED AT YOUR GODDAMN", 0xFFb7d855);
						case 142:
							changeSubtitles("POINTED AT YOUR GODDAMN FACES!", 0xFFb7d855);
						case 144:
							clearSubtitles();
						case 176:
							avoidBulletTipGraphic.x -= 110;
							avoidBulletTipGraphic.y -= 30;
							FlxTween.tween(avoidBulletTipGraphic, {x: avoidBulletTipGraphic.x + 150, y: avoidBulletTipGraphic.y + 45, alpha: 1}, 0.5, {type: ONESHOT, ease: FlxEase.elasticInOut});
						case 180:
							avoidBulletTipGraphic.acceleration.y = 1200;
							avoidBulletTipGraphic.acceleration.x = 800;
							avoidBulletTipGraphic.velocity.y -= FlxG.random.int(150, 175);
							avoidBulletTipGraphic.velocity.x += FlxG.random.int(300, 400);
							FlxTween.tween(avoidBulletTipGraphic, {alpha: 0}, 0.5, {type: ONESHOT, ease: FlxEase.sineInOut, startDelay: 0.3,
								onComplete: function(twn:FlxTween)
								{
									avoidBulletTipGraphic.kill();
									avoidBulletTipGraphic.destroy();
								}
							});
						case 244:
							subtitleTimer = new FlxTimer().start(0.17, function(tmr:FlxTimer)
							{
								changeSubtitles("'Told you to leave", 0xFFb7d855);
							});
						case 248:
							subtitleTimer = new FlxTimer().start(0.17, function(tmr:FlxTimer)
							{
								changeSubtitles("BUT THEN YOU NEVER LEFT.", 0xFFb7d855);
							});
						case 252:
							changeSubtitles("What will it take for me to", 0xFFb7d855);
						case 256:
							changeSubtitles("WARN YOU 'BOUT THIS GUN I'M HOLDING??", 0xFFb7d855);
						case 260:
							subtitleTimer = new FlxTimer().start(0.17, function(tmr:FlxTimer)
							{
								changeSubtitles("(Sir, WE'RE SORRY)", 0xFF4adaff);
							});
						case 264:
							subtitleTimer = new FlxTimer().start(0.17, function(tmr:FlxTimer)
							{
								changeSubtitles("(BUT WE CAN'T LEAVE THIS PLACE)", 0xFF4adaff);
							});
						case 268:
							changeSubtitles("(THE EXIT'S AROUND HERE SOMEWHERE)", 0xFF4adaff);
						case 272:
							changeSubtitles("(THERE'S NO NEED TO MAKE THIS GORY-)", 0xFF4adaff);
						case 276:
							subtitleTimer = new FlxTimer().start(0.17, function(tmr:FlxTimer)
							{
								changeSubtitles("I told you to leave", 0xFFb7d855);
							});
						case 280:
							subtitleTimer = new FlxTimer().start(0.17, function(tmr:FlxTimer)
							{
								changeSubtitles("BUT THEN YOU NEVER LEFT!", 0xFFb7d855);
							});
						case 284:
							changeSubtitles("WHAT WILL IT TAKE FOR ME TO", 0xFFb7d855);
						case 288:
							changeSubtitles("WARN YOU 'BOUT THIS GUN I'M HOLDING?!", 0xFFb7d855);
						case 292:
							subtitleTimer = new FlxTimer().start(0.17, function(tmr:FlxTimer)
							{
								changeSubtitles("(WE GOT THE WARNING)", 0xFF4adaff);
							});
						case 296:
							changeSubtitles("(BUT PLEASE JUST HELP US LEAVE)", 0xFF4adaff);
						case 300:
							changeSubtitles("(AFTER THAT WE'LL BE OFF YOUR HAIR)", 0xFF4adaff);
						case 302:
							FlxFlicker.flicker(subtitleText, Conductor.crochet / 1000 / 0.75, 0.04, true);
							FlxFlicker.flicker(subtitleBackground, Conductor.crochet / 1000 / 0.75, 0.04, true);
						case 303:
							subtitleText.alpha = 0;
							subtitleBackground.alpha = 0;
						case 304:
							subtitleTimer = new FlxTimer().start(0.176, function(tmr:FlxTimer)
							{
								subtitleText.alpha = 1;
								subtitleBackground.alpha = 0.45;
								changeSubtitles("YOU", 0xFF5ce766);
							});
							//Priest: Yfou--
						case 305:
							//Priest: --can't
							changeSubtitles("YOU CAN'T", 0xFF5ce766);
						case 306:
							//Priest: --sing!
							changeSubtitles("YOU CAN'T SING!", 0xFF5ce766);
						case 307:
							clearSubtitles();
						case 308:
							changeSubtitles("One more time.", 0xFFb7d855);
						case 312:
							subtitleTimer = new FlxTimer().start(0.17, function(tmr:FlxTimer)
							{
								changeSubtitles("Don't need to tell you", 0xFFb7d855);
							});
						case 316:
							changeSubtitles("One. more. time.", 0xFFb7d855);
						case 320:
							subtitleTimer = new FlxTimer().start(0.17, function(tmr:FlxTimer)
							{
								changeSubtitles("Don't need to tell you", 0xFFb7d855);
							});
						case 322:
							changeSubtitles("'Leave or die.'", 0xFFb7d855);
						case 324:
							changeSubtitles("I'll shoot you if you- if y-", 0xFFb7d855);
						case 328:
							changeSubtitles("ONE. MORE. TIME.", 0xFFb7d855);
						case 332:
							clearSubtitles();
						case 333:
							changeSubtitles("You will die.", 0xFFb7d855);
						case 336:
							subtitleTimer = new FlxTimer().start(0.17, function(tmr:FlxTimer)
							{
								changeSubtitles("You will die if-", 0xFFb7d855);
							});
						case 338:
							changeSubtitles("ONE. MORE. TIME.", 0xFFb7d855);
						case 340:
							clearSubtitles();
						case 372:
							changeSubtitles("One more time.", 0xFFb7d855);
						case 376:
							subtitleTimer = new FlxTimer().start(0.17, function(tmr:FlxTimer)
							{
								changeSubtitles("Don't need to tell you", 0xFFb7d855);
							});
						case 380:
							changeSubtitles("One. more. time.", 0xFFb7d855);
						case 384:
							subtitleTimer = new FlxTimer().start(0.17, function(tmr:FlxTimer)
							{
								changeSubtitles("Don't need to tell you", 0xFFb7d855);
							});
						case 386:
							changeSubtitles("'Leave or die!'", 0xFFb7d855);
						case 388:
							changeSubtitles("I'll shoot you if you- if y-", 0xFFb7d855);
						case 392:
							changeSubtitles("ONE. MORE. TIME.", 0xFFb7d855);
						case 396:
							clearSubtitles();
						case 397:
							changeSubtitles("You will die.", 0xFFb7d855);
						case 400:
							subtitleTimer = new FlxTimer().start(0.17, function(tmr:FlxTimer)
							{
								changeSubtitles("You will die if-", 0xFFb7d855);
							});
						case 402:
							changeSubtitles("ONE. MORE. TIME!-", 0xFFb7d855);
						case 404:
							clearSubtitles();
						case 436:
							changeSubtitles("THIS IS YOUR LAST WARNING", 0xFFb7d855);
						case 439:
							changeSubtitles("LEAVE NOW BEFORE I START FIRING MY GUN", 0xFFb7d855);
						case 444:
							changeSubtitles("POINTED AT YOUR", 0xFFb7d855);
						case 448:
							changeSubtitles("GOD DAMN FACES.", 0xFFb7d855);
						case 452:
							subtitleTimer = new FlxTimer().start(0.17, function(tmr:FlxTimer)
							{
								changeSubtitles("TOLD YOU TO LEAVE", 0xFFb7d855);
							});
						case 456:
							subtitleTimer = new FlxTimer().start(0.17, function(tmr:FlxTimer)
							{
								changeSubtitles("BUT THEN YOU NEVER LEFT", 0xFFb7d855);
							});
						case 460:
							changeSubtitles("WHAT WILL IT TAKE FOR ME TO", 0xFFb7d855);
						case 464:
							changeSubtitles("WARN YOU 'BOUT THIS GUN I'M HOLDING?!?", 0xFFb7d855);
						case 468:
							clearSubtitles();
						case 500:
							subtitleTimer = new FlxTimer().start(0.17, function(tmr:FlxTimer)
							{
								changeSubtitles("TOLD YOU TO LEAVE", 0xFFb7d855);
							});
						case 504:
							subtitleTimer = new FlxTimer().start(0.17, function(tmr:FlxTimer)
							{
								changeSubtitles("BUT THEN YOU NEVER LEFT", 0xFFb7d855);
							});
						case 508:
							changeSubtitles("WHAT WILL IT TAKE FOR ME TO", 0xFFb7d855);
						case 512:
							changeSubtitles("WARN YOU 'BOUT THIS GUN I'M HOLDING?!?", 0xFFb7d855);
						case 516:
							clearSubtitles();
						case 532:
							subtitleTimer = new FlxTimer().start(0.17, function(tmr:FlxTimer)
							{
								changeSubtitles("TOLD YOU TO LEAVE", 0xFFb7d855);
							});
						case 536:
							subtitleTimer = new FlxTimer().start(0.17, function(tmr:FlxTimer)
							{
								changeSubtitles("BUT THEN YOU NEVER LEFT", 0xFFb7d855);
							});
						case 540:
							changeSubtitles("WHAT WILL IT TAKE FOR ME TO", 0xFFb7d855);
						case 544:
							changeSubtitles("WARN YOU 'BOUT THIS GUN I'M HOLDING!?!", 0xFFb7d855);
						case 548:
							clearSubtitles();

					}
				case "Variegated Skylines":
					switch(curBeat)
					{
						case 96:
							changeSubtitles("WHAT THE HELL HAVE YOU DONE!?", 0xFFb7d855);
						case 98:
							subtitleTimer = new FlxTimer().start(Conductor.crochet / 2 / 1000 , function(tmr:FlxTimer)
							{
								changeSubtitles("You've doomed the city, ALL IS GONE-", 0xFFb7d855);
							});
						case 104:
							changeSubtitles("WHAT THE HELL HAVE YOU DONE", 0xFFb7d855);
						case 106:
							subtitleTimer = new FlxTimer().start(Conductor.crochet / 2 / 1000 , function(tmr:FlxTimer)
							{
								changeSubtitles("You LET EVERYONE DIE-", 0xFFb7d855);
							});
						case 111:
							changeSubtitles("{WHAT- HOW IS THIS MY DOING}", 0xFF4adaff);
						case 115:
							changeSubtitles("{WHEN I WASN'T EVEN THE ONE SHOOTING}", 0xFF4adaff);
						case 120:
							changeSubtitles("{YOU'RE THE ONE WITH THE GUN WHILE I AM}", 0xFF4adaff);
						case 124:
							changeSubtitles("{FENDING FOR MY OWN DEAR GODDAMN LIFE.}", 0xFF4adaff);
						case 132:
							clearSubtitles();
						case 191:
							subtitleTimer = new FlxTimer().start(Conductor.crochet / 2 / 1000 , function(tmr:FlxTimer)
							{
								changeSubtitles("You've doomed us all.", 0xFFb7d855);
							});
						case 194:
							subtitleTimer = new FlxTimer().start(Conductor.crochet / 2 / 1000 , function(tmr:FlxTimer)
							{
								changeSubtitles("Now take the fall.", 0xFFb7d855);
							});
						case 198:
							changeSubtitles("No else.", 0xFFb7d855);
						case 199:
							subtitleTimer = new FlxTimer().start(Conductor.crochet / 2 / 1000 , function(tmr:FlxTimer)
							{
								changeSubtitles("You're doomed to fall.", 0xFFb7d855);
							});
						case 202:
							subtitleTimer = new FlxTimer().start(Conductor.crochet / 2 / 1000 , function(tmr:FlxTimer)
							{
								changeSubtitles("Now it's your call.", 0xFFb7d855);
							});
						case 205:
							subtitleTimer = new FlxTimer().start(Conductor.crochet / 2 / 1000 , function(tmr:FlxTimer)
							{
								changeSubtitles("TO TAKE FAULT FOR YOUR ACTIONS", 0xFFb7d855);
							});
						case 213:
							subtitleTimer = new FlxTimer().start(Conductor.crochet / 2 / 1000 , function(tmr:FlxTimer)
							{
								changeSubtitles("THE BLOOD IS IN YOUR OWN HANDS.", 0xFFb7d855);
							});
						case 223:
							clearSubtitles();
						case 224:
							changeSubtitles("Why are you sticking around now?", FlxColor.BLACK, 0xFFb7d855, NORMAL, 1, 0, "VCR OSD Mono");
						case 233:
							changeSubtitles("When before you won't even bat a brow.", FlxColor.BLACK, 0xFFb7d855, NORMAL, 1, 0, "VCR OSD Mono");
						case 241:
							changeSubtitles("You treat us as an unknown.", FlxColor.BLACK, 0xFFb7d855, NORMAL, 1, 0, "VCR OSD Mono");
						case 247:
							changeSubtitles("YOU", FlxColor.BLACK, 0xFFb7d855, NORMAL, 1, 0, "VCR OSD Mono");
						case 248:
							changeSubtitles("You LEFT", FlxColor.BLACK, 0xFFb7d855, NORMAL, 1, 0, "VCR OSD Mono");
						case 249:
							subtitleTimer = new FlxTimer().start(Conductor.crochet / 2 / 1000 , function(tmr:FlxTimer)
							{
								changeSubtitles("You left US", FlxColor.BLACK, 0xFFb7d855, NORMAL, 1, 0, "VCR OSD Mono");
							});
						case 251:
							changeSubtitles("You left us ALONE", FlxColor.BLACK, 0xFFb7d855, NORMAL, 1, 0, "VCR OSD Mono");
						case 256:
							clearSubtitles();
						case 351:
							subtitleTimer = new FlxTimer().start(Conductor.crochet / 2 / 1000 , function(tmr:FlxTimer)
							{
								changeSubtitles("YOU'VE DOOMED US ALL", 0xFFb7d855);
							});
						case 354:
							subtitleTimer = new FlxTimer().start(Conductor.crochet / 2 / 1000 , function(tmr:FlxTimer)
							{
								changeSubtitles("NOW TAKE THE FALL", 0xFFb7d855);
							});
						case 358:
							changeSubtitles("NO ELSE", 0xFFb7d855);
						case 359:
							subtitleTimer = new FlxTimer().start(Conductor.crochet / 2 / 1000 , function(tmr:FlxTimer)
							{
								changeSubtitles("YOU'RE DOOMED TO FALL", 0xFFb7d855);
							});
						case 362:
							subtitleTimer = new FlxTimer().start(Conductor.crochet / 2 / 1000 , function(tmr:FlxTimer)
							{
								changeSubtitles("NOW IT'S YOUR CALL", 0xFFb7d855);
							});
						case 365:
							subtitleTimer = new FlxTimer().start(Conductor.crochet / 2 / 1000 , function(tmr:FlxTimer)
							{
								changeSubtitles("TO TAKE FAULT FOR YOUR ACTIONS", 0xFFb7d855);
							});
						case 373:
							changeSubtitles("THE BLOOD IS IN YOUR OWN HANDS.", 0xFFb7d855);
						case 383:
							clearSubtitles();
						case 384:
							changeSubtitles("WHY ARE YOU STICKING AROUND NOW!?", 0xFFb7d855, FlxColor.BLACK, NORMAL, 1, 0, "VCR OSD Mono");
						case 393:
							changeSubtitles("WHEN BEFORE YOU WON'T EVEN BAT A BROW.", 0xFFb7d855, FlxColor.BLACK, NORMAL, 1, 0, "VCR OSD Mono");
						case 401:
							changeSubtitles("YOU TREAT US AS AN UNKNOWN.", 0xFFb7d855, FlxColor.BLACK, NORMAL, 1, 0, "VCR OSD Mono");
						case 407:
							changeSubtitles("YOU", 0xFFb7d855, FlxColor.BLACK, NORMAL, 1, 0, "VCR OSD Mono");
						case 408:
							changeSubtitles("YOU LEFT", 0xFFb7d855, FlxColor.BLACK, NORMAL, 1, 0, "VCR OSD Mono");
						case 409:
							subtitleTimer = new FlxTimer().start(Conductor.crochet / 2 / 1000 , function(tmr:FlxTimer)
							{
								changeSubtitles("YOU LEFT US", 0xFFb7d855, FlxColor.BLACK, NORMAL, 1, 0, "VCR OSD Mono");
							});
						case 411:
							changeSubtitles("YOU LEFT US ALONE", 0xFFb7d855, FlxColor.BLACK, NORMAL, 1, 0, "VCR OSD Mono");
						case 416:
							clearSubtitles();
					}
			}
		}
	}

	//Functions From PsychEngine
	public function clearAllNotes() 
	{
		while(notes.length > 0) 
		{
			var daNote:Note = notes.members[0];
			//daNote.finnaBeKilled = true;
			daNote.active = false;
			daNote.visible = false;

			daNote.kill();
			notes.remove(daNote, true);
			daNote.destroy();
		}
		unspawnNotes = [];
	}

	public function clearNotesBefore(time:Float)
	{
		var i:Int = unspawnNotes.length - 1;
		while (i >= 0) 
		{
			var daNote:Note = unspawnNotes[i];
			if(daNote.strumTime - 500 < time)
			{
				//daNote.finnaBeKilled = true;
				daNote.active = false;
				daNote.visible = false;
				daNote.withinCompensation = true;

				daNote.kill();
				unspawnNotes.remove(daNote);
				daNote.destroy();
			}
			--i;
		}

		i = notes.length - 1;
		while (i >= 0) 
		{
			var daNote:Note = notes.members[i];
			if(daNote.strumTime - 500 < time)
			{
				//daNote.finnaBeKilled = true;
				daNote.active = false;
				daNote.visible = false;
				daNote.withinCompensation = true;

				daNote.kill();
				notes.remove(daNote, true);
				daNote.destroy();
			}
			--i;
		}
	}

	function swapDadForNewChar(failSafe:String = "", X:Float = -0.32145678, Y:Float = -0.54332179):Void
	{
		if (dad.curCharacter != dadSwaperoo)
		{
			if (dadSwaperoo == "")
			{
				failSafe == dad.curCharacter;
				#if debug
				trace("NO DAD WAS SPECIFIED! Go check Song Start Events and put a 'dadSwaperoo = [charactername]' there!");
				#end
			}
			if (failSafe == "")
				failSafe == dadSwaperoo;

			if (X == -0.32145678)
				X = dad.x;
			if (Y == -0.54332179)
				Y = dad.y;

			remove(dad);
			#if debug
			trace("if you the game crashes and you see this, it means that you did a typo, or the dad replacement you specified doesn't exist!");
			#end
			dad = new Character(X, Y, failSafe);
			add(dad);
		}
	}
	
	public function setSongTime(time:Float)
	{
		if(time < 0)
			time = 0;

		musicGroup.pause();
		vocals.pause();
		miscs.pause();

		FlxG.sound.music.pause();
		FlxG.sound.music.time = time;
		FlxG.sound.music.play();
			
		if (curSong == "Finale")
		{
			drums.stop();
			taiko.stop();
			choir.stop();
			hats.stop();
			adders.stop();
			slayer.stop();
			retalHats.stop();
			bells.stop();
			pads.stop();
			danger.stop();
		}

		instLowHP.time = time;
		musicGroup.resume();

		vocals.time = time;
		vocals.play();

		miscs.time = time;
		miscs.play();

		Conductor.songPosition = time;
	}

	//var beatCheck:Int = 0;
	//For preventing double-beat accients

	private function createStageParticle(particlePath, minFileNum:Int = 0, maxFileNum:Int = 9, minAmt:Int = 1, maxAmt:Int = 10, color:FlxColor = FlxColor.WHITE, nextColor:FlxColor = FlxColor.BLACK):Void
	{
		var particlesNum:Int = FlxG.random.int(minAmt, maxAmt);
		var currentWeek:String = 'week' + storyWeek;
		var width:Float = (2000 / particlesNum);
		var particlePercentage:Float = 1;
		for (j in 0...3)
		{
			for (i in 0...particlesNum)
			{
				particlePercentage = (i / particlesNum) * 10;
				var particle:PsychEngineFancyStageShit.FancyStageParticle = new PsychEngineFancyStageShit.FancyStageParticle(particlePath, currentWeek, particlePercentage, minFileNum, maxFileNum, -400 + width * i + FlxG.random.float(-width / 5, width / 5), (cityStreets.y + 250) - (FlxG.random.float(0, 50)), color, nextColor);
				stageParticles.add(particle);
			}
		}
	}

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic && SONG.notes[Std.int(curStep / 16)] != null)
		{	
			if (nearestNoteDecayBeat > 0)
				nearestNoteDecayBeat--;
	
			if (nearestNoteUpcoming)
			{
				if (nearestNoteDecayBeat < 4)
					nearestNoteUpcoming = false;
			}

			if (curBeat == musicBeatCusp - 1 && songLowercase != 'finale')
			{
				if (FlxG.save.data.songPosition && camHUD.visible && camHUD.active)
				{
					songPosGroup.forEach(function(blep:FlxSprite)
					{
						FlxTween.tween(blep, {alpha: 0}, 0.5, {type: ONESHOT, ease: FlxEase.smootherStepIn, onComplete: function(twn:FlxTween)
						{
							blep.visible = false;
						}});
					});
				}
			}

			switch (curSong)
			{
				case "Mic Test" | "Sudden Confrontation" | "Sprouting Irritation":
					//do NATHIN
				default:
					if (health < 1 && !midsongCutscene && allowHeartBeatSounds && !resultsPresent && !inResults && !inCutscene && !cannotDie && allowHealthModifiers)
					{
						if (Conductor.bpm <= 250)
						{
							if (health >= 0.7 && curBeat % 4 == 0 || health > 0.5 && curBeat % 2 == 0 || health < 0.5)
							{
								lowHPHeartBeat.play(true);
								#if cpp
								@:privateAccess
								{
									lime.media.openal.AL.sourcef(lowHPHeartBeat._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, FlxG.random.float(0.85, 1.15));
								}
								#end
								if (FlxG.save.data.flashing)
									lowHPOverlay.alpha = lowHPHeartBeat.volume;
								//trace ("Played Low HP Noise");
							}
						}
						else
						{
							if (health >= 0.7 && curBeat % 4 == 0 || curBeat % 2 == 0)
							{
								lowHPHeartBeat.play(true);
								#if cpp
								@:privateAccess
								{
									lime.media.openal.AL.sourcef(lowHPHeartBeat._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, FlxG.random.float(0.85, 1.15));
								}
								#end
								if (FlxG.save.data.flashing)
									lowHPOverlay.alpha = lowHPHeartBeat.volume;
								//trace ("Played Low HP Noise || BPM > 300");
							}
						}
						//trace (lowHealthEffectVolume);
					}
			}

			// Here so that Dad doesnt interrupt his own notes
			if (!dad.animation.curAnim.name.startsWith("sing") && (!dad.animation.curAnim.name.startsWith("gun") || dad.animation.curAnim.curFrame >= 3))
				if (curBeat % idleBeat == 0 || dad.curCharacter == "priest-theborderpray" || dad.curCharacter == "table-default")
					dad.dance(idleToBeat);
			// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

			//Mid song Events - If statement is added to prevent them from playing in the ResultsScreen
			if (!inResults && !resultsPresent)
			{
				//Subtitle shits
				doSubtitleShit();

				if (!PlayStateChangeables.Optimize && FlxG.save.data.distractions)
				{
					switch (curSong)
					{
						case 'Mic Test':
							if (curBeat % 16 == 7 && curBeat > 70 && curBeat < 120)
							{
								if (accuracy > 30)
								{
									boyfriend.playAnim('hey', true);
									dad.playAnim('cheer', true);
								}
								else
								{
									boyfriend.playAnim('awkward', true);
									dad.playAnim('cheerFail', true);
								}
								styleCheck();
							}
							else if (curBeat % 8 == 3 && curBeat > 120 && curBeat < 150)
							{
								if (accuracy > 30)
								{
									boyfriend.playAnim('hey', true);
									dad.playAnim('cheer', true);
								}
								else
								{
									boyfriend.playAnim('awkward', true);
									dad.playAnim('cheerFail', true);
								}
								styleCheck();
							}
							else if (curBeat % 16 == 7 && curBeat > 151 && curBeat < 215)
							{
								if (accuracy > 30)
								{
									boyfriend.playAnim('hey', true);
									dad.playAnim('cheer', true);
								}
								else
								{
									boyfriend.playAnim('awkward', true);
									dad.playAnim('cheerFail', true);
								}
								styleCheck();
							}
							else if (curBeat % 8 == 3 && curBeat > 216 && curBeat < 280)
							{
								if (accuracy > 30)
								{
									boyfriend.playAnim('hey', true);
									dad.playAnim('cheer', true);
								}
								else
								{
									boyfriend.playAnim('awkward', true);
									dad.playAnim('cheerFail', true);
								}
								styleCheck();
							}
							switch (curBeat)
							{ 
								case 5:
									dad.playAnim('singDOWN-alt', true);
									new FlxTimer().start(0.3, function(tmr:FlxTimer)
									{
										dad.playAnim('singDOWN-alt', true);
									});
								case 6:
									dad.playAnim('singDOWN-alt', true);
									new FlxTimer().start(0.3, function(tmr:FlxTimer)
									{
										dad.playAnim('singUP-alt', true);
									});
								case 7:
									dad.playAnim('singUP-alt', true);
								case 22:
									dad.playAnim('singLEFT-alt', true);
									new FlxTimer().start(0.3, function(tmr:FlxTimer)
									{
										dad.playAnim('singRIGHT-alt', true);
									});
								case 23:
									dad.playAnim('singUP-alt', true);
									new FlxTimer().start(0.3, function(tmr:FlxTimer)
									{
										dad.playAnim('singUP-alt', true);
									});
								case 53:
									dad.playAnim('singUP-alt', true);
								case 54:
									dad.playAnim('singRIGHT-alt', true);
									new FlxTimer().start(0.3, function(tmr:FlxTimer)
									{
										dad.playAnim('singLEFT-alt', true);
									});
								case 55:
									dad.playAnim('singUP-alt', true);
								case 191:
									if (accuracy > 30)
										boyfriend.playAnim('hey', true);
									else
										boyfriend.playAnim('awkward', true);		
								case 199:
									if (accuracy > 30)
									{
										boyfriend.playAnim('hey', true);
										dad.playAnim('cheer', true);
									}
									else
									{
										boyfriend.playAnim('awkward', true);
										dad.playAnim('cheerFail', true);
									}
									styleCheck();
								case 207 | 247 | 279:
									if (accuracy > 30)
										dad.playAnim('cheer', true);
									else
										dad.playAnim('cheerFail', true);
									styleCheck();
								case 214:
									dad.playAnim('singLEFT-alt', true);
									new FlxTimer().start(0.3, function(tmr:FlxTimer)
									{
										dad.playAnim('singRIGHT-alt', true);
									});
								case 215:
									dad.playAnim('singUP-alt', true);
									new FlxTimer().start(0.3, function(tmr:FlxTimer)
									{
										dad.playAnim('singUP-alt', true);
									});
							}

							
						case 'Tech. Difficulties':
							if (curBeat % 8 == 7 && curBeat > 0 && curBeat < 280 && curBeat != 87 && curBeat != 215)
							{
								styleCheck();
								if (accuracy > 75 || curBeat < 33 && curBeat > 8)
								{
									boyfriend.playAnim('hey', true);
								}
								else
								{
									boyfriend.playAnim('awkward', true);
								}
							}
							switch (curBeat)
							{
								case 8:
									camZooming = true;
								case 280:
									allowHeartBeatSounds = false;
									camZooming = false;
							}


						case 'Awkward Pauses':
							switch (curBeat)
							{
								case 32:
									camZooming = true;
								case 250:
									camFollowSpeed = 0.08;
									//doCamFollowing = false;
								case 254:
									dadCamFollowOffsetX = -60;
									dadCamFollowOffsetY = -60;
									dad.playAnim('badFingerStart', true);
									FlxTween.tween(camGame, {zoom: 1}, 0.1, {type: ONESHOT, ease: FlxEase.expoIn});
									allowHeartBeatSounds = false;
								case 255:
									//doCamFollowing = false;
									midsongCutscene = true;
									dad.playAnim('badFingerHold', true);
									boyfriend.playAnim('scared', false);
									gf.playAnim('scared', true);
									//Hides the HUD and zooms the camera out once daddy dearest flips off bf
									camHUD.alpha = 0;
									camZooming = false;
									camGame.zoom = 0.8;
								case 256:
									camFollowSpeed = 0.04;
									dadCamFollowOffsetX = 0;
									dadCamFollowOffsetY = -40;
									allowHeartBeatSounds = true;
									gf.playAnim('danceRight', true);
									boyfriend.playAnim('scaredHOLD', false);
									FlxTween.tween(camHUD, {alpha: 1}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.quadIn});
								case 258:
									defaultCamZoom += 0.15;
									camZooming = true;
									boyfriend.playAnim('awkward', true);
									//trace("AWKWARD LMAO");
								case 260:
									midsongCutscene = false;
									defaultCamZoom -= 0.15;
								case 416:
									allowHeartBeatSounds = false;
									camZooming = false;
							}


						case 'Up and Beyond':
							switch (curBeat)
							{
								case 0 | 1:
									camFollowSpeed = 0.02;
								case 32:
									camZooming = true;
									camFollowSpeed = 0.04;
								case 193:
									defaultCamZoom += 0.1;
								case 257:
									defaultCamZoom -= 0.1;
								case 385:
									camZooming = false;
								case 389:
									camZooming = true;
									defaultCamZoom += 0.1;
								case 513:
									defaultCamZoom -= 0.1;
									allowHeartBeatSounds = false;
								case 528:
									//trace("YOU BETTER BE CHANGED FROM " + camFollowSpeed);
									dadCamFollowOffsetX = -70;
									dadCamFollowOffsetY = -30;
									camFollowSpeed = 0.02;
									//trace("TO " + camFollowSpeed);
								case 529:
									if (isStoryMode)
									{
										fadeOutGameplayHUD(4.5);
										FlxTween.tween(camGame, {zoom: 1.05}, Conductor.crochet * 8 / 1000, {type: ONESHOT, ease: FlxEase.expoInOut});
										//trace('HUD now Faded Out');
									}
								case 530:
									midsongCutscene = true;
									camZooming = false;
							}


						case 'Desperation':
							switch (curBeat)
							{
								case 64:
									camZooming = true;
								case 175:
									camZooming = false;
									boyfriend.playAnim('awkward', true);
								case 176:
									camZooming = true;
								case 190:
									//VINE BOOM
									strumLineNotes.visible = false;
									grpStrumLine.visible = false;
									iconP2.changeIcon('priest-annoyed');
									dad.playAnim('gotPissed', true);
									boyfriend.playAnim('awkward', true);
									camZooming = false;
									midsongCutscene = true;
									stageOverlay.alpha = 0.65;
									defaultCamZoom = 0.85;
									camGame.zoom = 1;
									FlxTween.tween(camGame, {zoom: defaultCamZoom}, 1.0, 
										{type: ONESHOT, 
											ease: FlxEase.quadInOut,
										});
								case 191:
									swapDadForNewChar(dadSwaperoo, 100, 315);
								case 192:
									strumLineNotes.visible = true;
									grpStrumLine.visible = true;
									defaultCamZoom = 0.8;
									camZooming = true;
									midsongCutscene = false;
								case 255:
									new FlxTimer().start(0.1, function(tmr:FlxTimer)
									{
										boyfriend.playAnim('concerned', true);
									});
								case 256:
									allowHeartBeatSounds = false;
									if (isStoryMode)
										camHUD.alpha = 0;
									camZooming = false;
									if (FlxG.save.data.camzoom)
									{
										camGame.zoom = 1.15;
										FlxTween.tween(camGame, {zoom: 0.95}, Conductor.crochet * 4.5 / 1000, 
											{type: ONESHOT, 
												ease: FlxEase.quadOut,
											});	
									}
									dad.playAnim('angryLoop', true);
								case 258:
									dad.playAnim('angryLoop', true);
								case 260:
									dad.playAnim('angryLoop', true);
								case 262:
									dad.playAnim('angryLoop', true);
								case 264:
									dad.playAnim('angryLoop', true);
								case 265:
									dad.playAnim('angryLoop', true);
							}


						case 'Disagreement':
							switch (curBeat)
							{
								case 111:
									boyfriend.playAnim('awkward', true);
								case 127:
									dad.playAnim('gotPissed', true);
								case 132:
									defaultCamZoom = 0.9;
								case 159:
									dad.playAnim('gotPissed', true);
								case 186:
									dad.playAnim('gotPissed', true);
								case 188:
									defaultCamZoom = 0.95;
								case 191:
									boyfriend.playAnim('concerned', true);
								case 192:
									defaultCamZoom = 1.15;
								case 207:
									boyfriend.playAnim('singRIGHT', true);
									doCamFollowing = false;
									midsongCutscene = true;
									camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
								case 208:
									boyfriend.playAnim('singLEFTmiss', true);
									defaultCamZoom = 1.3;
								case 212:
									defaultCamZoom = 1.15;
									doCamFollowing = true;
									midsongCutscene = false;
								case 254:
									dad.playAnim('gotPissed', true);
								case 256:
									defaultCamZoom = 0.925;
								case 268:
									defaultCamZoom = 0.975;
								case 271:
									boyfriend.playAnim('awkward', true);
								case 272:
									defaultCamZoom = 0.925;
								case 284:
									defaultCamZoom = 0.975;
								case 288:
									defaultCamZoom = 0.925;
								case 300:
									defaultCamZoom = 1;
								case 303:
									boyfriend.playAnim('awkward', true);
								case 304:
									defaultCamZoom = 0.925;
								case 316:
									defaultCamZoom = 1.1;
								case 320:
									defaultCamZoom = 0.875;
								case 344:
									defaultCamZoom = 1;
								case 352:
									defaultCamZoom = 0.925;
								case 380:
									defaultCamZoom = 1.25;
								case 384:
									defaultCamZoom = 0.875;
								case 400:
									defaultCamZoom = 1;
									dadCamFollowOffsetY += 10;
									dad.playAnim('angryLoop', true);
								case 402:
									dad.playAnim('angryLoop', true);
								case 404:
									dad.playAnim('angryLoop', true);
								case 406:
									dad.playAnim('angryLoop', true);
								case 408:
									dad.playAnim('angryLoop', true);
								case 410:
									dad.playAnim('angryLoop', true);
								case 412:
									dad.playAnim('angryLoop', true);
								//case 413:
									//glitchyGlitchEffect.active = true;
								case 414:
									allowHeartBeatSounds = false;
									camZooming = false;
									remove(boyfriend);
									remove(dad);
									stageOverlay.kill();
									stageOverlay.destroy();
									dummyBlackScreen.alpha = 1;
									dummyBlackScreen.active = true;
									if (isStoryMode)
										camHUD.alpha = 0;
									else
										camHUD.alpha = 1;
							}
							

						case 'Retaliation':	
							switch (curBeat)
							{
								case 32:
									camZooming = true;
									camFollowSpeed = 0.04;
									defaultCamZoom = 1;
								case 155:
									camZooming = false;
									doCamFollowing = false;
									camGame.zoom -= 0.02;
									bfCamFollowOffsetY += 40;
								case 158:
									camFollow.x = gf.getGraphicMidpoint().x + 10;
									camFollow.y = gf.getGraphicMidpoint().y + 50;
								case 159:
									dad.playAnim('midsongAnim', true);
									camZooming = true;
								case 160:
									doCamFollowing = true;
									defaultCamZoom = 0.815;
									camGame.zoom += 0.02;
									objectTrailShader.alpha = 0.8;
									objectWiggleShader.waveSpeed = 8;
									objectWiggleShader.waveAmplitude = 0.002;
									objectTrailShader.blend = ADD;
									objectTrailShader.color = 0xff8080;
									FlxTween.tween(bgBopper, {alpha: 0.65, y: bgBopper.y - bgBopper.height / 1.2}, 0.5, {type: ONESHOT, ease: FlxEase.quadOut});
									FlxTween.tween(theBorderBG, {alpha: 0.3}, 0.5, {type: ONESHOT, ease: FlxEase.quadOut});
									dadCamFollowOffsetY = -35;
									bfCamFollowOffsetY -= 20;
									inSongClimax = true;
									if (FlxG.save.data.flashing)
									{
										colourWash.alpha = 0;
										FlxTween.tween(colourWash, {alpha: 0.1}, Conductor.crochet * 4 / 1000, {type: ONESHOT, ease: FlxEase.smootherStepOut});
									}
								case 223:
									FlxTween.tween(bgBopper, {alpha: 0, y: 590}, 1, {type: ONESHOT, ease: FlxEase.quadIn});
									FlxTween.tween(theBorderBG, {alpha: 0.5}, 0.5, {type: ONESHOT, ease: FlxEase.quadOut});
									objectWiggleShader.waveSpeed = 4;
									objectWiggleShader.waveAmplitude = 0.0015;
									objectTrailShader.alpha = 0.65;
									objectTrailShader.blend = NORMAL;
									objectTrailShader.color = 0xffffff;
									inSongClimax = false;
									if (FlxG.save.data.flashing)
										FlxTween.tween(colourWash, {alpha: stageAmbAlpha}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.smootherStepOut});
								case 224:
									//glitchyGlitchEffect.active = false;
									defaultCamZoom = 0.95;
									dadCamFollowOffsetY = -25;
									bfCamFollowOffsetY -= 20;
								case 287:
									dad.playAnim('midsongAnim', true);
								case 288:
									defaultCamZoom = 1;
									objectWiggleShader.waveSpeed = 8;
									objectWiggleShader.waveAmplitude = 0.001;
									objectTrailShader.blend = SUBTRACT;
									objectTrailShader.alpha = 0.3;
									objectTrailShader.color = 0xFF5ce766;
								case 296:
									defaultCamZoom = 1.05;
								case 304:
									defaultCamZoom = 1.15;
								case 320:
									defaultCamZoom = 1.25;
								case 328:
									defaultCamZoom = 1.3;
								case 336:
									defaultCamZoom = 1.35;
								case 347:
									camZooming = false;
									camGame.zoom -= 0.04;
								case 351:
									objectWiggleShader.waveSpeed = 4;
									objectWiggleShader.waveAmplitude = 0.0015;
									objectTrailShader.color = 0xac5050;
									objectTrailShader.alpha = 0.65;
									//glitchyGlitchEffect.active = true;
									dad.playAnim('midsongAnim', true);
								case 352:
									//glitchyGlitchEffect.active = false;
									if (FlxG.save.data.camZoom)
									{
										camGame.zoom = 0.7;
									}
									dadCamFollowOffsetY = -35;
									bfCamFollowOffsetY += 20;
								case 353:
									camZooming = true;
								case 354:
									objectWiggleShader.waveSpeed = 8;
									objectWiggleShader.waveAmplitude = 0.0015;
									objectTrailShader.alpha = 0.65;
									objectTrailShader.blend = ADD;
									objectTrailShader.color = 0xffffff;
									objectTrailShader.alpha = 1;
									defaultCamZoom = 0.815;
									camGame.zoom += 0.02;
									FlxTween.tween(bgBopper, {alpha: 0.8, y: bgBopper.y - bgBopper.height / 1.2}, 0.5, {type: ONESHOT, ease: FlxEase.quadOut});
									FlxTween.tween(theBorderBG, {alpha: 0.3}, 0.5, {type: ONESHOT, ease: FlxEase.quadOut});
									inSongClimax = true;
									if (FlxG.save.data.flashing)
									{
										colourWash.blend = ADD;
										FlxTween.color(colourWash, Conductor.crochet * 4 / 1000, FlxColor.WHITE, stageAmbColour, {type: ONESHOT, ease: FlxEase.smootherStepOut});
									}
								case 416:
									objectTrailShader.alpha = 0.5;
									objectWiggleShader.waveSpeed = 6;
									objectTrailShader.blend = NORMAL;
									objectWiggleShader.waveAmplitude = 0.001;
									defaultCamZoom = 0.82;
									dadCamFollowOffsetY = -25;
									bfCamFollowOffsetY -= 10;
								case 479:
									allowHeartBeatSounds = false;
								case 480:
									objectWiggleShader.waveSpeed = 2;
									bfCamFollowOffsetY -= 10;
									allowNoteHitSounds = false;
									camFollowSpeed = 0.02;
									FlxTween.tween(bgBopper, {alpha: -10, y: 690}, 4.1142, {type: ONESHOT, ease: FlxEase.quadIn});
									FlxTween.tween(camHUD, {alpha: 0.75}, 4.1142, {type: ONESHOT, ease: FlxEase.sineInOut, startDelay: 0.1});
									FlxTween.tween(theBorderBG, {alpha: 0.8}, 4.1142, {type: ONESHOT, ease: FlxEase.sineInOut, startDelay: 0.1});
									theBorderBG.alpha += 0.0035;
									dadCamFollowOffsetY = -25;
									inSongClimax = false;
									if (FlxG.save.data.flashing)
									{
										colourWash.blend = SCREEN;
										colourWash.alpha = 0;
										FlxTween.tween(colourWash, {alpha: stageAmbAlpha}, Conductor.crochet * 4 / 1000, {type: ONESHOT, ease: FlxEase.smootherStepOut});
									}
								case 507:
									dadCamFollowOffsetY = -5;
									camZooming = false;
								case 508:
									objectWiggleShader.waveSpeed = 4;
									objectTrailShader.alpha = 0.3;
									//glitchyGlitchEffect.active = true;
									camFollowSpeed = 0.04;
									boyfriend.playAnim('awkward', true);
									midsongCutscene = true;
									dad.playAnim('endsongAnim1', true);
									camShake(true, true, 'camGame', 0.003, idleCamShakeTimer - 0.05);
									FlxTween.tween(camGame, {zoom: 1.65}, 2, {type: ONESHOT, ease: FlxEase.quadIn});
								case 509:
									//glitchyGlitchEffect.active = false;
									boyfriend.playAnim('concerned', true);
									dad.playAnim('endsongAnim1', true);
									camShake(true, true, 'camGame', 0.008, idleCamShakeTimer - 0.05);
								case 510:
									dad.playAnim('endsongAnim2', true);
									camShake(true, false, 'camGame', 0.01, idleCamShakeTimer);
								case 511:
									objectWiggleShader.waveSpeed = 10;
									boyfriend.playAnim('scared', true);
									dad.playAnim('endsongAnim3', true);
									camShake(true, false, 'camGame', 0.045, Conductor.crochet / 1000);
									camShake(true, false, 'camHUD', 0.005, Conductor.crochet / 1000);
									theBorderBG.animation.play('lightning');
								case 512:
									remove(boyfriend);
									remove(dad);
									stageOverlay.kill();
									stageOverlay.destroy();
									objectTrailShader.destroy();
									dummyBlackScreen.alpha = 1;
									dummyBlackScreen.active = true;
									camGame.flash(DisclaimerScreen.flashColor, 0.5);
									if (isStoryMode)
										camHUD.alpha = 0;
									else
										camHUD.alpha = 1;
							}


							if (inSongClimax)
								camShake(true, false, 'camGame', 0.003, idleCamShakeTimer);

						case 'Kid With a Gun':
							switch(curBeat)
							{
								case 3:
									camZooming = true;
								case 169:
									midsongCutscene = true;
									boyfriend.playAnim('scaredHOLD', false);
								case 172:
									midsongCutscene = false;
								case 192:
									camZooming = false;
									camGame.zoom = 0.82;
								case 196:
									camZooming = true;
								case 260:
									allowHeartBeatSounds = false;
								case 261:
									camZooming = false;
							}


						case 'Playing With Fire':
							if (FlxG.save.data.flashing)
							{
								if (curBeat % 2 == 1 && curBeat > 276 && curBeat < 307)
									stageOverlay.animation.play('singleFlash');
								else if ((curBeat % 8 == 5 || curBeat % 8 == 7) && curBeat > 372 && curBeat < 404)
									stageOverlay.animation.play('singleFlash');
							}
							switch (curBeat)
							{
								case 0 | 1:
									gfSpeed = 2;
								case 32:
									camZooming = true;
								case 108:
									midsongCutscene = true;
									boyfriend.playAnim('scaredHOLD', false);
								case 112:
									midsongCutscene = false;
								case 140:
									midsongCutscene = true;
									boyfriend.playAnim('scared', false);
									gf.playAnim('cheerFail');
								case 144:
									midsongCutscene = false;
								case 159:
									camZooming = false;
								case 160:
									FlxTween.tween(camGame, {zoom: 0.82}, Conductor.crochet * 8 / 1000, {type: ONESHOT, ease: FlxEase.quadInOut});
									strumLineNotes.forEach(function(babyArrow:FlxSprite)
									{
										FlxTween.tween(babyArrow, {alpha: 0}, Conductor.crochet * 4 / 1000, {type: ONESHOT, ease: FlxEase.quadIn});
									});
									if (FlxG.save.data.strumline)
									{
										doStrumLineBGTweening = false;
										grpStrumLine.forEach(function(leStrussy:FlxSprite)
										{
											FlxTween.tween(leStrussy, {alpha: 0}, Conductor.crochet * 4 / 1000, {type: ONESHOT, ease: FlxEase.quadIn});
										});
									}
									camFollowSpeed = 0.035;
								case 174:
									dad.playAnim('gunLOAD', true);
									FlxTween.tween(camGame, {zoom: 0.85}, 0.4, {type: ONESHOT, ease: FlxEase.sineInOut});
								case 175:
									FlxTween.tween(camGame, {zoom: 0.95}, 0.15, {type: ONESHOT, ease: FlxEase.quadInOut});
									midsongCutscene = true;
									dad.playAnim('gunWARNING', true);
									boyfriend.playAnim('scared', true);
									gf.playAnim('scared', true);
									camShake(true, true, 'camGame', 0.05, 0.5);
									allowHeartBeatSounds = false;
									camFollowSpeed = 0.045;
								case 176:
									boyfriend.playAnim('scaredHOLD', false);
									gf.playAnim('cheerFail');
									camGame.zoom = 0.8;
								case 179:
									strumLineNotes.forEach(function(babyArrow:FlxSprite)
									{
										FlxTween.tween(babyArrow, {alpha: 1}, Conductor.crochet / 2000, {type: ONESHOT, ease: FlxEase.quadIn});
									});
									if (FlxG.save.data.strumline)
										grpStrumLine.forEach(function(leStrussy:FlxSprite)
										{
											FlxTween.tween(leStrussy, {alpha: 0.45}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.quadOut, onComplete: 
												function(twn:FlxTween)
												{
													doStrumLineBGTweening = true;
												}
											});
										});
									gfSpeed = 1;
								case 180:
									camFollowSpeed = 0.04;
									allowHeartBeatSounds = true;
									midsongCutscene = false;
									camZooming = true;
								case 244:
									camFollowSpeed = 0.05;
									defaultCamZoom = 0.9;
								case 276:
									defaultCamZoom = 0.95;
								case 300:
									gfSpeed = 0;
									gf.playAnim('cheerFail');
								case 302:
									doCamFollowing = false;
									midsongCutscene = true;
									camFollow.x = gf.getGraphicMidpoint().x;
									camFollow.y = gf.getGraphicMidpoint().y - 30;
									camZooming = false;
									FlxTween.tween(camGame, {zoom: 1}, 0.5, {type: ONESHOT, ease: FlxEase.elasticInOut});
								case 304:
									//Hides the HUD and zooms the camera out once priest speaks
									defaultCamZoom = 1.05;
									strumLineNotes.forEach(function(babyArrow:FlxSprite)
									{
										FlxTween.tween(babyArrow, {alpha: 0}, 0.2, {type: ONESHOT, ease: FlxEase.quadOut});
									});
									if (FlxG.save.data.strumline)
									{
										doStrumLineBGTweening = false;
										grpStrumLine.forEach(function(leStrussy:FlxSprite)
										{
											FlxTween.tween(leStrussy, {alpha: 0}, 0.2, {type: ONESHOT, ease: FlxEase.quadIn});
										});
									}
									dad.playAnim('gunSHOCKED', true);
									gf.playAnim('singDOWN-alt', true);
									new FlxTimer().start(0.176, function(tmr:FlxTimer)
									{
										gf.playAnim('singUP-alt', true);
									});
									//Priest: You--
								case 305:
									//Priest: --can't
									gf.playAnim('singUP-alt', true);
								case 306:
									//Priest: --sing!
									dad.playAnim('gunPISSED', true);
									gf.playAnim('singUP-alt', true);
								case 307:
									camFollow.y -= 10;
									doCamFollowing = true;
									camGame.zoom = 0.9;
									boyfriend.playAnim('scared', true);
									dad.playAnim('gunWARNING', true);
									gf.playAnim('scared', true);
									camShake(true, false, 'camGame', 0.03);
									//gf getting scared cause pico shoots a warning shot
								case 308:
									defaultCamZoom = 0.85;
									boyfriend.playAnim('scaredHOLD', true);
									midsongCutscene = false;
									strumLineNotes.forEach(function(babyArrow:FlxSprite)
									{
										FlxTween.tween(babyArrow, {alpha: 1}, Conductor.crochet / 2000, {type: ONESHOT, ease: FlxEase.quadIn});
									});
									if (FlxG.save.data.strumline)
										grpStrumLine.forEach(function(leStrussy:FlxSprite)
										{
											FlxTween.tween(leStrussy, {alpha: 0.45}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.quadOut, onComplete:
											function(twn:FlxTween)
											{
												doStrumLineBGTweening = true;
											}
											});
										});
									camFollowSpeed = 0.04;
									camZooming = true;
									gfSpeed = 1;
								case 435:
									camFollowSpeed = 0.05;
								case 538:
									new FlxTimer().start(0.176, function(tmr:FlxTimer)
									{
										dad.playAnim('gunSHOOT', true);
									});
								case 563:
									camFollowSpeed = 0.035;
									allowHeartBeatSounds = false;
									camZooming = false;
								//Shooting
								//342, 351, 358, 366, 405, 411, 419, 423, 430, 434, 435-436, 469, 473, 474-475, 478, 481, 482-483, 485, 489, 490-491, 493, 497, 498-499, 532, 536, 538-539, 547 (next to 548), 550, 553, 554-555, 557, 559 (next to 560), 561, 562, 563					} oops this bracket is gone it caused a compile error. not removing it for HI S TO R Y!
								//Reloading
								//341, 350, 357, 365, 404, 410, 418, 422, 429, 433, 435, 468, 472, 477, 480, 484, 488, 492, 496, 531, 535, 546, 549, 552, 560
							}


						case 'Variegated Skylines':
							switch(curBeat)
							{
								case 32:
									defaultCamZoom = 0.95;
									camZooming = true;
								case 96:
									defaultCamZoom = 0.82;
									inSongClimax = true;
								case 128:
									defaultCamZoom = 0.95;
									inSongClimax = false;
								case 192:
									defaultCamZoom = 0.8;
									inSongClimax = true;
								case 223:
									dad.blend = SUBTRACT;
									dummyBlackScreen.active = true;
									stageParticles.visible = false;
									FlxTween.tween(dummyBlackScreen, {alpha: 1}, Conductor.crochet / 900, {type: ONESHOT, ease: FlxEase.sineInOut});
								case 224:
									inSongClimax = false;
									dad.blend = LIGHTEN;
								case 256:
									defaultCamZoom = 0.85;
									stageParticles.visible = true;
									camGame.flash(DisclaimerScreen.flashColor, Conductor.crochet * 4 / 1000);
									dummyBlackScreen.active = false;
									dummyBlackScreen.alpha = 0;
									dad.blend = NORMAL;
								case 288:
									defaultCamZoom = 1;
								case 351:
									defaultCamZoom = 0.85;
									camZooming = false;
								case 352:
									inSongClimax = true;
									defaultCamZoom = 0.8;
								case 353:
									camZooming = true;
								case 416:
									FlxTween.tween(camGame, {zoom: 1}, Conductor.crochet * 30 / 1000, {type: ONESHOT, ease: FlxEase.sineInOut});
									allowHeartBeatSounds = false;
									camZooming = false;
									inSongClimax = true;
									camHUD.zoom = 1;
								case 447:
									FlxTween.tween(camGame, {zoom: 0.85}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.expoIn});
								case 448:
									defaultCamZoom = 0.85;
									camShake(true, true, 'camGame', 0.035, 0.3);
							}

							if (stageParticles.visible)
							{
								if (!inSongClimax)
									camShake(false, false, 'camGame', 0.002, idleCamShakeTimer);
								else
									camShake(false, false, 'camGame', 0.004, idleCamShakeTimer);
								if (curBeat % 2 == 0)
									createStageParticle('theCityPortalOpen/effects/stageParticle');
							}


						case 'Sudden Confrontation':
							switch(curBeat)
							{
								case 15:
									camZooming = true;
								case 240:
									dad.playAnim('awkward', true);
							}


						case 'Sprouting Irritation':
							switch (curBeat)
							{
								case 31:
								camZooming = true;
							}


						case 'Finale': //ADAPTIVE MUSIC!! WOOOOO!!!
							//SPHAGETTI CODE INCOMING CAUSE FLIXEL DON'T HAVE A WELL DOCUMENTED WAY OF FRICKINJ SOUND GROUPSAFA
							//Drums/Taiko
							//Choir, Taiko, Drums, Hats, Bells
							playFinaleMusic();
					}
				}
				else
				{
					switch (curSong)
					{
						case 'Tech. Difficulties':
							switch (curBeat)
							{
								case 8:
									camZooming = true;
								case 280:
									allowHeartBeatSounds = false;
									camZooming = false;
							}
						case 'Awkward Pauses':
							switch (curBeat)
							{
								case 32:
									camZooming = true;
								case 416:
									allowHeartBeatSounds = false;
									camZooming = false;
							}
						case 'Up and Beyond':
							switch (curBeat)
							{
								case 32:
									camZooming = true;
								case 386:
									camZooming = false;
								case 390:
									camZooming = true;
								case 530:
									camZooming = false;
							}
						case 'Desperation':
							switch (curBeat)
							{
								case 64:
									camZooming = true;
								case 192:
									camZooming = true;
							}
						case 'Disagreement':
							switch (curBeat)
							{
								case 414:
									camZooming = false;
							}					
						case 'Retaliation':		
							switch (curBeat)
							{
								case 32:
									camZooming = true;
								case 480:
									allowHeartBeatSounds = false;
								case 508:
									camZooming = false;
							}
						case 'Kid With a Gun':
							switch(curBeat)
							{
								case 4:
									camZooming = true;
								case 192:
									camZooming = false;
									camGame.zoom = 0.82;
								case 196:
									camZooming = true;
								case 260:
									allowHeartBeatSounds = false;
								case 261:
									camZooming = false;
							}
						case 'Playing With Fire':
							switch (curBeat)
							{
								case 160:
									camZooming = false;
								case 180:
									camZooming = true;
								case 564:
									allowHeartBeatSounds = false;
									camZooming = false;
							}
						case 'Variegated Skylines':
							switch(curBeat)
							{
								case 32:
									camZooming = true;
								case 352:
									camZooming = false;
								case 354:
									camZooming = true;
								case 416:
									camZooming = false;
							}
						case 'Sudden Confrontation':
							switch(curBeat)
							{
								case 16:
									camZooming = true;
							}
						case 'Sprouting Irritation':
							switch (curBeat)
							{
								case 32:
								camZooming = true;
							}
						case 'Finale': //ADAPTIVE MUSIC!! WOOOOO!!!
							//SPHAGETTI CODE INCOMING CAUSE FLIXEL DON'T HAVE A WELL DOCUMENTED WAY OF FRICKINJ SOUND GROUPSAFA
							//Drums/Taiko
							//Choir, Taiko, Drums, Hats, Bells
							playFinaleMusic();
					}
				}
			}

			//HARDCODING FOR ZOOMS
			if (!resultsPresent && !inResults)
			{
				switch (curSong)
				{
					case "Up and Beyond":
						if (FlxG.save.data.camzoom && camZooming)
						{
							if (curBeat % 4 == 1)
							{
								camGame.zoom += 0.025;
								camHUD.zoom += 0.015;	
							}

							if (curBeat % 8 == 1)
								styleCheck();
							
							if (curBeat % 4 == 3)
							{
								if (curBeat > 193 && curBeat < 257)
								{
									camGame.zoom += 0.027;
									camHUD.zoom += 0.017;
								}
								else if (curBeat > 389 && curBeat < 513)
								{
									camGame.zoom += 0.028;
									camHUD.zoom += 0.018;
								}
							}
						}
						else
							if (curBeat % 8 == 1)
								styleCheck();
					case "Retaliation":
						if (FlxG.save.data.camzoom && camZooming)
						{
							if (curBeat % 8 == 0)
								styleCheck();

							if (curBeat > 316 && curBeat < 354)
							{
								if (curBeat % 4 == 2)
								{
									camGame.zoom += 0.025;
									camHUD.zoom += 0.015;
								}
							}	
							else
							{
								if (curBeat % 4 == 0)
								{
									camGame.zoom += 0.025;
									camHUD.zoom += 0.015;
								}
							}

							if (curBeat >= 160 && curBeat < 224)
							{
								camGame.zoom += 0.025;
								camHUD.zoom += 0.015;	
							}
							else if (curBeat >= 354 && curBeat < 480)
							{
								camGame.zoom += 0.03;
								camHUD.zoom += 0.02;
							}
						}
						else
							if (curBeat % 8 == 0)
								styleCheck();
					case "Variegated Skylines":
						if (FlxG.save.data.camzoom && camZooming)
						{
							if (curBeat % 4 == 0 && curBeat != 383)
							{
								camGame.zoom += 0.025;
								camHUD.zoom += 0.015;
							}

							if (curBeat % 8 == 0)
								styleCheck();

							if (curBeat % 4 == 2 && curBeat > 96 && curBeat < 130 || curBeat > 192 && curBeat < 256)
							{
								camGame.zoom += 0.025;
								camHUD.zoom += 0.015;
								if (FlxG.save.data.flashing && FlxG.save.data.distractions)
									stageOverlay.animation.play('singleFlash');
							}	

							if (curBeat > 352 && curBeat < 416 && curBeat != 383)
							{
								camGame.zoom += 0.0255;
								camHUD.zoom += 0.0155;
								if (curBeat % 2 == 0 && FlxG.save.data.flashing && FlxG.save.data.distractions)
									stageOverlay.animation.play('singleFlash');
							}
						}
						else
						{
							if (curBeat % 8 == 0)
								styleCheck();
							
							if (curBeat % 4 == 2 && curBeat > 96 && curBeat < 130 || curBeat > 192 && curBeat < 256 && FlxG.save.data.flashing && FlxG.save.data.distractions)
								stageOverlay.animation.play('singleFlash');

							if (curBeat > 352 && curBeat < 416 && curBeat != 383 && curBeat % 2 == 0 && FlxG.save.data.flashing && FlxG.save.data.distractions)
								stageOverlay.animation.play('singleFlash');
						}
					default:
						if (FlxG.save.data.camzoom && camZooming)
						{
							if (curBeat % 4 == 0)
							{
								camGame.zoom += 0.025;
								camHUD.zoom += 0.015;
							}
							switch(songLowercase)
							{
								case 'mic-test' | 'tech.-difficulties' | 'awkward-pauses':
									//nothin
								case 'desperation':
									if (curBeat % 4 == 0)
										styleCheck();
								default:
									if (curBeat % 8 == 0)
										styleCheck();
							}
						}
						else if (camZooming)
						{
							switch(songLowercase)
							{
								case 'mic-test' | 'tech.-difficulties' | 'awkward-pauses':
									//nothin
								case 'desperation':
									if (curBeat % 4 == 0)
										styleCheck();
								default:
									if (curBeat % 8 == 0)
										styleCheck();
							}
						}
				}
			}

			if (FlxG.save.data.distractions)
			{
				iconP1.scale.set(1.2, 1.2);
				iconP2.scale.set(1.2, 1.2);
		
				iconP1.updateHitbox();
				iconP2.updateHitbox();
			}

			if (gfSpeed > 0 && curBeat % gfSpeed == 0 && !midsongCutscene)
				gf.dance();

			//(IDK???)> (╯°□°）╯︵ ┻━┻
			if (((boyfriend.animation.curAnim.name != 'idleAfterSing' && !boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.startsWith('hey') || boyfriend.animation.curAnim.finished) && (boyfriend.animation.curAnim.name != "hurt" && !boyfriend.animation.curAnim.name.startsWith("dodge") || boyfriend.animation.curAnim.finished)) && curBeat % idleBeat == 0 && !midsongCutscene)
				boyfriend.playAnim('idle', idleToBeat);
				//trace("Idle (line 8468)");

			switch (curStage)
			{
				case "border":
					if (!midsongCutscene && !resultsPresent && !inResults)
					{
						if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset && FlxG.save.data.distractions)
							lightningStrikeShit();
						
						if (FlxG.save.data.distractions && curSong == "Retaliation")
							bgBopper.dance(inSongClimax);
					}
				case "cityskyline":
					if (FlxG.save.data.distractions && camZooming)
					{
						if (curBeat % 4 == 0)
						{
							cityLights.forEach(function(light:FlxSprite)
							{
								light.visible = false;
							});

							curLight = FlxG.random.int(0, cityLights.length - 1);

							cityLights.members[curLight].visible = true;
							cityLights.members[curLight].alpha = 1;
						}
					}
			}
		}
	}
}