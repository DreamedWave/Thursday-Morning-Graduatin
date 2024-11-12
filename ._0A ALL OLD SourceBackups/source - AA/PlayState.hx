package;

//YOUR playstate. (writing this so that you dont get confused)
/*
IMPORTANT NOTES!!!

FIX LE BUGS:
[/]   Crashing when endsong() happens [Hint: It's probably because of the miscs shit ya just added! (YEP!)]
[/]   Crashing when finale loops (Fixed once, but broke again in 3/31/2022. I assume it's because of the caching again-? maybe-?)
[/]   Fix finale not playing the chart again (figure out what makes the charts play)
[/]	  Finale not playing notes after it loops
[ ]   Fix Finale making notes too tiiiny (WHAT)
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
*/
import Song.Event;
import openfl.media.Sound;
#if sys
import sys.io.File;
import smTools.SMFile;
#end
import openfl.ui.KeyLocation;
import openfl.events.Event;
import haxe.EnumTools;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
import Replay.Ana;
import Replay.Analysis;
#if cpp
import webm.WebmPlayer;
#end
import flixel.input.keyboard.FlxKey;
import haxe.Exception;
import openfl.geom.Matrix;
import openfl.display.BitmapData;
import openfl.utils.AssetType;
import lime.graphics.Image;
import flixel.graphics.FlxGraphic;
import openfl.utils.AssetManifest;
import openfl.utils.AssetLibrary;
import flixel.system.FlxAssets;
import lime.app.Application;
import lime.media.AudioContext;
import lime.media.AudioManager;
import openfl.Lib;
import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
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
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
//import flash.system.System;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
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
	public static var instance:PlayState = null;

	public static var curStage:String = '';
	public static var stageSuffix:String = '';
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var weekScore:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public static var songPosBG:FlxSprite;
	public static var songPosBar:FlxBar;

	public static var rep:Replay;
	//public static var loadRep:Bool = false;
	public static var inResults:Bool = false;
	public static var resultsPresent:Bool = false;
	public static var cantSkipSong:Bool = false;
	private var skippedShit:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;

	#if windows
	// Discord RPC variables
	var storyDifficultyText:String = "";
	//var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	private var vocals:FlxSound;
	//For things such as Playing With Fire Guns and other shits that I am yet to do
	private var miscs:FlxSound;
	//ADAPTIVE MUSIC AAAAA FUKC
	private var drums:FlxSound = new FlxSound();
	private var taiko:FlxSound = new FlxSound();
	private var choir:FlxSound = new FlxSound();
	private var hats:FlxSound = new FlxSound();
	private var adders:FlxSound = new FlxSound();
	private var slayer:FlxSound = new FlxSound();
	private var retalHats:FlxSound = new FlxSound();
	private var bells:FlxSound = new FlxSound();
	private var pads:FlxSound = new FlxSound();
	private var danger:FlxSound = new FlxSound();
	//FINALE BATTLE SH THIT
	private var dangerLevel:Float = 0;
	var enemyHealth:Float = 100;
	//To prevent preloading again
	public static var hasMiscs:Bool = true;

	public static var isSM:Bool = false;
	#if sys
	public static var sm:SMFile;
	public static var pathToSm:String;
	#end

	public var originalX:Float;

	public static var dad:Character;
	public static var gf:Character;
	public static var boyfriend:Boyfriend;

	var characterBlurEffect:FlxTrail;
	//var noteBlurEffect:FlxTrail;
	//var glitchyGlitchEffect:FlxGlitchEffect;

	var timesShot:Int = 0; //The numnber of times GUY gets shot -- for nerfing purposes LMAO
	var delayAutoPause:Bool = false; //delay the autopause to startcountdown

	public var notes:FlxTypedGroup<Note>;

	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	private var curSection:Int = 0;

	private var camFollow:FlxObject;
	private static var prevCamFollow:FlxObject;
	private var camFollowSpeed:Float = 0.04; //The higher the number is, the faster the camera moves
	private var prevCamFollowSpeed:Float = 0.04;
	private var camFollowing:Bool = true;
	var camTween:FlxTween;

	private var camShake:Bool = false;
	private var triggeredCamShake:Bool = false;
	private var isEarthquake:Bool = false; //A bool for strong camera shakes

	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public static var playerStrums:FlxTypedGroup<FlxSprite> = null;
	public static var cpuStrums:FlxTypedGroup<FlxSprite> = null;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;

	public var health:Float = 1; // making public because sethealth doesnt work without it
	var allowHealthModifiers:Bool = true;

	private var combo:Int = 0;

	public static var misses:Int = 0;
	public static var campaignMisses:Int = 0;

	public static var deaths:Int = 0;
	public static var hasReset:Bool = false;

	public var accuracy:Float = 0.00;
	public static var campaignAccuracy:Float = 0.00;
	public static var campAccDivider:Int = 0;

	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var songPositionBar:Float = 0;

	private var generatedMusic:Bool = false;
	private var generatedArrows:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon; // making these public again because i may be stupid
	public var iconP2:HealthIcon; // what could go wrong?
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

	public static var cannotDie = false;
	public static var toggledPracticeMode = false;

	public static var offsetTesting:Bool = false;

	public var isSMFile:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;
	var idleToBeat:Bool = true; // change if bf and dad would idle to the beat of the song
	var idleBeat:Int = 2; // how frequently bf and dad would play their idle animation(1 - every beat, 2 - every 2 beats and so on)

	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];

	var theBorderBG:FlxSprite;
	var allowRandomGlitchFunction
	:Bool = false;

	var cityLights:FlxTypedGroup<FlxSprite>;
	var cityLightTimeShit:Float = 900;
	var cityStreets:FlxSprite;
	var hurtVignette:FlxSprite;
	var vignette:FlxSprite;
	var blackScreen:FlxSprite;
	var blackScreenAlpha:Int = 0;
	//Making this public static??? cause making this visible in the pause menu wouldnt work
	public static var safeVignette:FlxSprite;
	//var phillyTrain:FlxSprite;
	//var trainSound:FlxSound;

	var songDuration:FlxText;
	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	//var weekRank

	var bgGirls:BackgroundGirls;
	var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	//Toggleable Modchart functionality
	var isolateArrows:Bool = false;

	public static var midsongCutscene:Bool = false;
	private var hitsoundType:String = "";
	var missSound:FlxSound = new FlxSound();
	var allowNoteHitSounds:Bool = true;
	private var lowHPHeartBeat:FlxSound;
	//Make this changable
	//Done!... hopefully nothing breaks haha  ha
	//Transfered from HitSoundFunction
	var noteHitVolume:Float = FlxG.save.data.notesfxVol * 0.01;
	var allowHeartBeatSounds:Bool = true;

	public var songScore:Int = 0;

	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	//var replayTxt:FlxText;

	//var inSubstate:Bool = false;

	//yoiNKED this from Kade Engine 1.8 LMAOO
	var needSkip:Bool = false;
	var skipActive:Bool = false;
	var skipText:FlxText;
	var skipTo:Float;
	//(Thank you KadeMan)

	//Subtitle shits
	var subtitleText:FlxText;
	var subtitleTimer:FlxTimer;
	var hasSubtitles:Bool = false;

	var endedSong:Bool = false;

	public static var campaignScore:Int = 0;

	//THE HIGHER THE NUMBER, THE CLOSER TO THE CAMERA IT IS, OK?
	var defaultCamZoom:Float = 1.05;

	public static var daPixelZoom:Float = 6;

	public static var theFunne:Bool = true;

	public static var inCutscene:Bool = false;
	public static var playedCutscene:Bool = false;
	var usedTimeTravel:Bool = false;

	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;

	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;

	// Will decide if she's even allowed to headbang at all depending on the song
	private var allowedToHeadbang:Bool = false;

	// Per song additive offset
	public static var songOffset:Float = 0;

	// BotPlay text
	private var botPlayText:FlxText;
	// Replay shit
	private var saveNotes:Array<Dynamic> = [];
	private var saveJudge:Array<String> = [];
	private var replayAna:Analysis = new Analysis(); // replay analysis
	// Tutorial graphics
	var tutorialGraphicA:FlxSprite;
	var tutorialGraphicB:FlxSprite;
	var tutorialGraphicC:FlxSprite;
	//Part 3 Tutorial Graphic
	var avoidBulletTipGraphic:FlxSprite;

	var tutorialText:FlxText;

	public static var highestCombo:Int = 0;

	private var executeModchart = false;

	// Animation common suffixes
	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

	public static var startTime = 0.0;

	var video:MP4Handler;
	var videoMusic:FlxSound;

	var songClimax:Bool = false;
	var enemyCanFail:Bool = true;//temp, change to false later

	var countdownTimer:FlxTimer = new FlxTimer();
	var compensationTimer:FlxTimer = new FlxTimer();

	//A story about this: I was gonna actually tween and trail GUY's dodge but like it didn't work and just pooled the memory so nah I just animated him sliding
	//var dodgeTween:FlxTween;
	//var dodgeTimer:FlxTimer;

	// API stuff
	public function addObject(object:FlxBasic)
	{
		add(object);
	}

	public function removeObject(object:FlxBasic)
	{
		remove(object);
	}

	//Making this void (1)
	//Actually, Don't make this void cause it breaks cam follow(?) the cam follow shit :)))
	override public function create()
	{
		/*trace("Freeing Memory");
		trace("Bitmap Clear Unused");
		FlxG.bitmap.clearUnused();
		//FlxG.bitmap.clearCache();
		trace("Garbage Collector");
		System.gc();
		trace("Free'd Memory");*/
		

				
		instance = this;

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(800);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		//Startup Shit
		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;
		misses = 0;

		highestCombo = 0;
		repPresses = 0;
		repReleases = 0;
		timesShot = 0;
		inResults = false;
		midsongCutscene = false;
		if (resultsPresent)
			resultsPresent = false;
		if (storyPlaylist.length <= 1 && curSong != "Mic Test")
			cantSkipSong = true;
		else
			cantSkipSong = false;
		camFollowing = true;
		allowNoteHitSounds = true;

		PlayStateChangeables.useDownscroll = FlxG.save.data.downscroll;
		PlayStateChangeables.safeFrames = FlxG.save.data.frames;
		PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed;
		PlayStateChangeables.botPlay = FlxG.save.data.botplay;
		PlayStateChangeables.Optimize = FlxG.save.data.optimize;

		// pre lowercasing the song name (create)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();

		//removedVideo = false;

		#if windows
		executeModchart = FileSystem.exists(Paths.lua(songLowercase + "/modchart"));
		if (executeModchart)
			PlayStateChangeables.Optimize = false;
		#end
		#if !cpp
		executeModchart = false; // FORCE disable for non cpp targets
		#end

		trace('Mod chart: ' + executeModchart + " - " + Paths.lua(songLowercase + "/modchart"));

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
			{
				detailsText = "Story Mode: Week " + storyWeek;
			}
			else
			{
				detailsText = "Freeplay";
			}

			// String for when the game is paused
			detailsPausedText = "Paused - " + detailsText;

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
			case 'bf-pixel':
				stageSuffix = '-pixel';
			case 'selfsert-default':
				stageSuffix = '-selfsert';
			default:
				if (SONG.song.toLowerCase() == "mic test")
					stageSuffix = '-tutorial';
				else
					stageSuffix = "";
		}

		bgColor = 0xFF000000;

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		
		if (!playedCutscene && storyPlaylist.length > 2 && isStoryMode)
		{
			camHUD.alpha = 0;
			camGame.alpha = 0;
			blackScreenAlpha = 1;
			trace("Le cams alpha 0");
		}
		else
		{
			camHUD.alpha = 1;
			trace("Le cams alpha 1");
		}
		//camHUD.x = 40;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		FlxCamera.defaultCameras = [camGame];

		//The detail thing that appears when you get shot
		hurtVignette = new FlxSprite().loadGraphic(Paths.image('gotShot', 'week3'));
		hurtVignette.scale.x *= 0.8;
		hurtVignette.scale.y *= 0.8;
		hurtVignette.scrollFactor.set();
		hurtVignette.updateHitbox();
		if(FlxG.save.data.antialiasing)
		{
			hurtVignette.antialiasing = true;
		}
		hurtVignette.screenCenter();
		hurtVignette.alpha = 0;
		add(hurtVignette);

		//The detail thing that appears when you cant die
		safeVignette = new FlxSprite().loadGraphic(Paths.image('cannotDie', 'tutorial'));
		safeVignette.y = 30;
		safeVignette.scale.x *= 0.8;
		safeVignette.scale.y *= 0.8;
		safeVignette.alpha = 0.8;
		safeVignette.scrollFactor.set();
		safeVignette.updateHitbox();
		if(FlxG.save.data.antialiasing)
		{
			safeVignette.antialiasing = true;
		}
		safeVignette.screenCenter();
		safeVignette.blend = ADD;
		safeVignette.visible = false;
		add(safeVignette);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial', 'tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		if (SONG.eventObjects == null)
			{
				SONG.eventObjects = [new Song.Event("Init BPM",0,SONG.bpm,"BPM Change")];
			}
	

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
					TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
                }

				currentIndex++;
			}
			convertedStuff.push(new Song.Event(name,pos,value,type));
		}

		SONG.eventObjects = convertedStuff;

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + PlayStateChangeables.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: '
			+ Conductor.timeScale + '\nBotPlay : ' + PlayStateChangeables.botPlay);

		// dialogue shit
		/*switch (songLowercase)
		{
		}*/
		// defaults if no stage was found in chart
		var stageCheck:String = 'stage';

		if (SONG.stage == null)
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

		//Dad REPOSITIONING PER CHAR
		switch (SONG.player2)
		{
			case 'table-default':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (SONG.song == "Mic Test")
				{
					camPos.x += -650;
					camPos.y += -200;
					//tweenCamIn();
				}
			case "priest-theborderpray":
				dad.y += 215;
			case "priest-theborderannoyed":
				dad.y += 215;
			case "priest-theborderangry":
				dad.y += 215;
			case 'monster-christmas':
				dad.y += 130;
			case 'demon-dad':
				camPos.x += 400;
			case 'pico-default':
				camPos.x += 600;
				dad.y += 300;
			case 'selfsert-default':
				dad.y += 260;
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// BF REPOSITIONING PER CHAR
		switch (SONG.player2)
		{
			case 'selsert-default':
				boyfriend.y -= 50;
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
					defaultCamZoom = 0.8;
					curStage = 'border';

					FlxG.sound.load(Paths.sound('glitch_1'));
					FlxG.sound.load(Paths.sound('glitch_2'));

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

					switch (StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase())
					{
						case 'disagreement':
							vignette = new FlxSprite(FlxG.camera.width * -0.33 + 80, FlxG.camera.height * -0.4 + 50);
							vignette.setGraphicSize(Std.int(vignette.width));
							vignette.alpha = 0.6;
							theBorderBG.alpha = 0.75;
						case 'retaliation':
							vignette = new FlxSprite(FlxG.camera.width * -0.33 + 120, FlxG.camera.height * -0.4 + 80);
							vignette.setGraphicSize(Std.int(vignette.width * 0.9));
							vignette.alpha = 1;
							theBorderBG.alpha = 0.5;
							//Boppers

							var bopperFrames = Paths.getSparrowAtlas('theborder_people', 'week2');

							bottomBoppers = new FlxSprite(-380, 590);
							bottomBoppers.frames = bopperFrames;
							bottomBoppers.animation.addByPrefix('idle', 'Idle', 18, true);
							bottomBoppers.animation.addByPrefix('dance', 'Bop', 24, false);
							bottomBoppers.scrollFactor.set(0.9, 0.9);
							bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 0.9));
							bottomBoppers.updateHitbox();
							/*if(FlxG.save.data.antialiasing)
							{
								bottomBoppers.antialiasing = true;
							}*/
							//I turned this off cause lag, hopefully it works.
							if (FlxG.save.data.distractions)
							{
								add(bottomBoppers);
							}
							bottomBoppers.animation.play("idle");
							bottomBoppers.alpha = 0;
						default:
							vignette = new FlxSprite(FlxG.camera.width * -0.33, FlxG.camera.height * -0.35 + 20);
							vignette.setGraphicSize(Std.int(vignette.width * 1.5));
							vignette.alpha = 0.35;
							theBorderBG.alpha = 1;
					}

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

					vignette.frames = Paths.getSparrowAtlas('vignette_black', 'week2');
					vignette.updateHitbox();
					if(FlxG.save.data.antialiasing)
					{
						vignette.antialiasing = true;
					}
					vignette.scrollFactor.set(0.1, 0.1);
					vignette.animation.addByPrefix('vignette', 'vignette', 1, true);
					vignette.animation.play('vignette');
					vignette.active = false;

					allowRandomGlitchFunction = true;
				case 'theCity':
					curStage = 'cityskyline';
					defaultCamZoom = 0.85;

					//X [LEFT or RIGHT]: Negative is LEFT, while postitive is RIGHT. (Same as the Cartesian Plane's)
					//Y [UP or DOWN]: Negative is UP, while positive is DOWN. (Inverted as the Cartesian Plane's)

					//                                 X    Y
					var bg:FlxSprite = new FlxSprite(-140, -80).loadGraphic(Paths.image('philly/sky', 'week3'));
					bg.scrollFactor.set(0.1, 0.1);
					add(bg);

					var city:FlxSprite = new FlxSprite(-120, -85).loadGraphic(Paths.image('philly/city', 'week3'));
					city.scrollFactor.set(0.2, 0.2);
					//city.setGraphicSize(Std.int(city.width * 0.85));
					if(FlxG.save.data.antialiasing)
					{
						city.antialiasing = true;
					}
					city.updateHitbox();
					add(city);

					cityLights = new FlxTypedGroup<FlxSprite>();
					if (FlxG.save.data.distractions)
					{
						add(cityLights);
					}

					for (i in 0...5)
					{
						var light:FlxSprite = new FlxSprite(city.x, city.y).loadGraphic(Paths.image('philly/win' + i, 'week3'));
						light.scrollFactor.set(0.2, 0.2);
						light.visible = false;
						//light.setGraphicSize(Std.int(light.width * 0.85));
						light.updateHitbox();
						if(FlxG.save.data.antialiasing)
							{
								light.antialiasing = true;
							}
						cityLights.add(light);
					}

					var streetBehind:FlxSprite = new FlxSprite(-115, 20).loadGraphic(Paths.image('philly/behindStreet', 'week3'));
					streetBehind.scrollFactor.set(0.65, 0.65);
					streetBehind.setGraphicSize(Std.int(streetBehind.width * 1.1));
					//streetBehind.updateHitbox();
					if(FlxG.save.data.antialiasing)
					{
						streetBehind.antialiasing = true;
					}
					add(streetBehind);

					/*phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train', 'week3'));
					if (FlxG.save.data.distractions)
					{
						add(phillyTrain);
					}

					trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes', 'week3'));
					FlxG.sound.list.add(trainSound);*/

					cityStreets = new FlxSprite(-130, 70);
					cityStreets.frames = Paths.getSparrowAtlas('philly/street', 'week3');
					cityStreets.scrollFactor.set(0.9, 0.9);
					cityStreets.setGraphicSize(Std.int(cityStreets.width * 1.15));
					cityStreets.animation.addByPrefix('street', 'street', 1, true);
					cityStreets.animation.play('street');
					if(FlxG.save.data.antialiasing)
					{
						cityStreets.antialiasing = true;
					}

					vignette = new FlxSprite(-301, -180);
					vignette.frames = Paths.getSparrowAtlas('philly/vignette', 'week3');
					vignette.scrollFactor.set(0, 0);
					vignette.setGraphicSize(Std.int(vignette.width * 0.85));
					vignette.animation.addByPrefix('static', 'vignette justBlack');
					vignette.animation.addByPrefix('warning', 'vignette warnPlayer flashRed', 24, true);
					vignette.animation.addByPrefix('singleFlash', 'vignette warnPlayer flashRed', 12, false);
					vignette.animation.play('static');
					if(FlxG.save.data.antialiasing)
					{
						vignette.antialiasing = true;
					}
				case 'theCityPortal':
					curStage = 'cityskylineVariegated';
					defaultCamZoom = 0.81;

					//X [LEFT or RIGHT]: Negative is LEFT, while postitive is RIGHT. (Same as the Cartesian Plane's)
					//Y [UP or DOWN]: Negative is UP, while positive is DOWN. (Inverted as the Cartesian Plane's)

					//                                 X    Y
					var bg:FlxSprite = new FlxSprite(-140, -80).loadGraphic(Paths.image('portalopen/sky_variegated', 'week3'));
					bg.scrollFactor.set(0.1, 0.1);
					add(bg);

					var city:FlxSprite = new FlxSprite(-120, -85);
					city.scrollFactor.set(0.2, 0.2);
					city.frames = Paths.getSparrowAtlas('portalopen/city_portal', 'week3');
					city.animation.addByPrefix('cityPortal', 'portal_CityIdle', 14, true);
					city.animation.play('cityPortal');
					//city.setGraphicSize(Std.int(city.width * 0.85));
					if(FlxG.save.data.antialiasing)
					{
						city.antialiasing = true;
					}
					city.updateHitbox();
					add(city);

					//MAKE THE CITY LIGHTS THE PARTICLES
					/*cityLights = new FlxTypedGroup<FlxSprite>();
					if (FlxG.save.data.distractions)
					{
						add(cityLights);
					}

					for (i in 0...5)
					{
						var light:FlxSprite = new FlxSprite(city.x, city.y).loadGraphic(Paths.image('philly/win' + i, 'week3'));
						light.scrollFactor.set(0.2, 0.2);
						light.visible = false;
						//light.setGraphicSize(Std.int(light.width * 0.85));
						light.updateHitbox();
						if(FlxG.save.data.antialiasing)
							{
								light.antialiasing = true;
							}
						cityLights.add(light);
					}*/

					var streetBehind:FlxSprite = new FlxSprite(-115, 20);
					streetBehind.frames = Paths.getSparrowAtlas('portalopen/behindStreet_Portal', 'week3');
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

					/*phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train', 'week3'));
					if (FlxG.save.data.distractions)
					{
						add(phillyTrain);
					}

					trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes', 'week3'));
					FlxG.sound.list.add(trainSound);*/

					cityStreets = new FlxSprite(-130, 70);
					cityStreets.frames = Paths.getSparrowAtlas('portalopen/street_portal', 'week3');
					cityStreets.scrollFactor.set(0.9, 0.9);
					cityStreets.setGraphicSize(Std.int(cityStreets.width * 1.15));
					cityStreets.animation.addByPrefix('street', 'streetIdle', 20, true);
					cityStreets.animation.play('street');
					if(FlxG.save.data.antialiasing)
					{
						cityStreets.antialiasing = true;
					}

					//ANIMATE THE VIGNETTE
					vignette = new FlxSprite(-301, -180);
					vignette.frames = Paths.getSparrowAtlas('philly/vignette', 'week3');
					vignette.scrollFactor.set(0, 0);
					vignette.setGraphicSize(Std.int(vignette.width * 0.85));
					vignette.animation.addByPrefix('static', 'vignette justBlack');
					vignette.animation.addByPrefix('warning', 'vignette warnPlayer flashRed', 24, true);
					vignette.animation.addByPrefix('singleFlash', 'vignette warnPlayer flashRed', 12, false);
					vignette.animation.play('static');
					if(FlxG.save.data.antialiasing)
					{
						vignette.antialiasing = true;
					}
				default:
					switch (StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase())
					{
						case 'mic-test':
							defaultCamZoom = 1.2;
						default:
							defaultCamZoom = 0.9;
					}
					curStage = 'stage';
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('graduation/graduation_back', 'week1'));
					if(FlxG.save.data.antialiasing)
						{
							bg.antialiasing = true;
						}
					bg.scrollFactor.set(0.7, 0.7);
					bg.active = false;
					add(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('graduation/graduation_front', 'week1'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					if(FlxG.save.data.antialiasing)
						{
							stageFront.antialiasing = true;
						}
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					add(stageFront);

					var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('graduation/graduation_overlay', 'week1'));
					stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
					stageCurtains.updateHitbox();
					if(FlxG.save.data.antialiasing)
						{
							stageCurtains.antialiasing = true;
						}
					stageCurtains.scrollFactor.set(1.3, 1.3);
					stageCurtains.active = false;

					//move this after (add bf and add dad, and also rename 'vignette' to secondstagelayer/stageoverlay or sum shit)
					add(stageCurtains);
			}

			//Layering for stages LOL
			add(gf);

			if (curStage == 'cityskyline' || curStage == 'cityskylineVariegated')
				add(cityStreets);

			add(dad);
			add(boyfriend);

			if (curStage == 'border' || curStage == 'cityskyline' || curStage == 'cityskylineVariegated')
			{
				add(vignette);
				if (SONG.player2 == "priest-theborderangry")
				{
					if (FlxG.save.data.distractions)
					{
						if (!PlayStateChangeables.Optimize)
						{
							characterBlurEffect = new FlxTrail(dad, null, 3, 8, 0.4, 0.08);
							characterBlurEffect.alpha = 0.5;
							add(characterBlurEffect);
							//glitchyGlitchEffect = new FlxGlitchEffect(3, 1, 0.02, HORIZONTAL);
							//glitchyGlitchEffect.active = false;
							//FlxWaveMode.START;
							//add(glitchyGlitchEffect);
						}
					}
				}
			}
		}
		else
		{
			var stageBG:FlxSprite;
			switch (stageCheck)
			{
				//BG for Usual Rhythm Game BG
				case 'theBorder':
					stageBG = new FlxSprite().loadGraphic(Paths.image('optimBG', 'week2'));
				case 'theCity':
					stageBG = new FlxSprite().loadGraphic(Paths.image('optimBG', 'week3'));
				default:
					stageBG = new FlxSprite().loadGraphic(Paths.image('optimBG', 'week1'));
			}
			stageBG.scale.x *= 0.65;
			stageBG.scale.y *= 0.65;
			stageBG.scrollFactor.set();
			stageBG.updateHitbox();
			if(FlxG.save.data.antialiasing)
			{
				stageBG.antialiasing = true;
			}
			stageBG.screenCenter();
			stageBG.alpha = 0.25;
			add(stageBG);
		}

		blackScreen = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
			-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		blackScreen.scrollFactor.set();
		blackScreen.alpha = blackScreenAlpha;
		add(blackScreen);
		if (camGame.alpha == 0 && blackScreen.alpha == 1)
			camGame.alpha = 1;

		/*if (loadRep)
		{
			FlxG.watch.addQuick('rep rpesses', repPresses);
			FlxG.watch.addQuick('rep releases', repReleases);
			// FlxG.watch.addQuick('Queued',inputsQueued);

			PlayStateChangeables.useDownscroll = rep.replay.isDownscroll;
			PlayStateChangeables.safeFrames = rep.replay.sf;
			PlayStateChangeables.botPlay = true;
		}*/

		trace('safe frames - ' + PlayStateChangeables.safeFrames);

		trace("SF CALC: " + Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));

		/*var doof:DialogueBox = new DialogueBox(false, dialogue);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;*/

		//Skip Intro Shit
		var firstNoteTime = Math.POSITIVE_INFINITY;
		var playerTurn = false;
		for (index => section in SONG.notes)
		{
			if (section.sectionNotes.length > 0 && !isSM)
			{
				if (FlxG.save.data.weekUnlocked <= 2 && deaths > 0 || hasReset)
				{
					if (section.startTime > 5000)
					{
						needSkip = true;
						skipTo = section.startTime - 1000;
					}
					break;
				}
				else if (FlxG.save.data.weekUnlocked >= 2)
				{
					if (section.startTime > 5000)
					{
						needSkip = true;
						skipTo = section.startTime - 1000;
					}
					break;
				}
			}
			else if (isSM)
			{
				for (note in section.sectionNotes)
				{
					if (note[0] < firstNoteTime)
					{
						if (!PlayStateChangeables.Optimize)
						{
							firstNoteTime = note[0];
							if (note[1] > 3)
								playerTurn = true;
							else
								playerTurn = false;
						}
						else if (note[1] > 3)
						{
							firstNoteTime = note[0];
						}
					}
				}
			}
		}

		Conductor.songPosition = -5000;

		//Centering Offset Shit (1) V Doink
		strumLine = new FlxSprite(50, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();

		if (PlayStateChangeables.useDownscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		/*generateStaticArrows(0);
		generateStaticArrows(1);*/

		if (SONG.song == null)
			trace('song is null???');
		else
			trace('song looks gucci');

		generateSong(SONG.song);

		trace('generated');

		// add(strumLine);

		//this was where the cameradata was

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		//TIMESTEP?!?!?!?!?!
		//Lag spikes happen in specific spots after specific actions when timestep is on
		//Have not tested it for off yet tho, it is literally 3 am now
		//I fukked somethin up
		FlxG.fixedTimestep = false;

		if (FlxG.save.data.songPosition) // I dont wanna talk about this code :(
		//LMAOOO YOU GJUST COPIED THE HEALTHBAR CODE AHAHAHAHLMAOOOOO L -- [p roceeds to copy code aswell]
		{
			//Croink                  V
			songPosBG = new FlxSprite(50, 10).loadGraphic(Paths.image('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, 90000);
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);
			
			songDuration = new FlxText(songPosBG.x, songPosBG.y, 0, "Song Progress:", 16);
			songDuration.x = songPosBG.x + (songPosBG.width - songDuration.width) / 2;
			//if (PlayStateChangeables.useDownscroll)
			//	songDuration.y -= 3;
			songDuration.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songDuration.scrollFactor.set();
			add(songDuration);
			songDuration.cameras = [camHUD];
		}
		//Adding Offsets Again      V //Ploink
		healthBarBG = new FlxSprite(50, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (PlayStateChangeables.useDownscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		add(healthBar);

		subtitleText = new FlxText(healthBarBG.x + 70, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 250 : -100), -0);
		subtitleText.text = "";
		subtitleText.antialiasing = true;
		subtitleText.setFormat(Paths.font("playtime.ttf"), 40, CENTER);
		if (FlxG.save.data.centersubtitles)
			subtitleText.x = healthBarBG.x + (healthBarBG.width - subtitleText.width) / 2;
		subtitleText.color = FlxColor.WHITE;
		subtitleText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3, 1);
		subtitleText.cameras = [camHUD];

		// Add Kade Engine watermark
		kadeEngineWatermark = new FlxText(4, healthBarBG.y
			+ 50, 0,
			SONG.song
			+ " - "
			+ CoolUtil.difficultyFromInt(storyDifficulty), 16);
		kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		kadeEngineWatermark.scrollFactor.set();
		add(kadeEngineWatermark);

		if (PlayStateChangeables.useDownscroll)
			kadeEngineWatermark.y = FlxG.height * 0.9 + 45;

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);

		scoreTxt = new FlxText(healthBarBG.x - 35 + healthBar.width / 4, healthBarBG.y + (healthBarBG.height * 2.5 - 5), 0, "", 20);
		originalX = scoreTxt.x;
		scoreTxt.scrollFactor.set();
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 18, FlxColor.WHITE, CENTER);
		scoreTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1.5);
		add(scoreTxt);

		// Literally copy-paste of the above, fu-- (frick)
		botPlayText = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0,
			"BOTPLAY", 20);
		botPlayText.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		botPlayText.scrollFactor.set();
		botPlayText.borderSize = 4;
		botPlayText.borderQuality = 2;
		botPlayText.antialiasing = false;
		if (PlayStateChangeables.botPlay)
			add(botPlayText);

		//	Tutorial Graphics that appear in famous hits such as: "Tutorial", and "nothing else lmao just tutorial"
		//	For the first tutorial popup
		tutorialGraphicA = new FlxSprite().loadGraphic(Paths.image('infocards/TutorialTipA', 'tutorial'));
		tutorialGraphicA.scrollFactor.set();
		tutorialGraphicA.updateHitbox();
		if (FlxG.save.data.antialiasing)
		{
			tutorialGraphicA.antialiasing = true;
		}
		tutorialGraphicA.screenCenter();
		tutorialGraphicA.alpha = 0;
		//	For the second tutorial popup
		tutorialGraphicB = new FlxSprite().loadGraphic(Paths.image('infocards/TutorialTipB', 'tutorial'));
		tutorialGraphicB.scrollFactor.set();
		tutorialGraphicB.updateHitbox();
		if(FlxG.save.data.antialiasing)
		{
			tutorialGraphicB.antialiasing = true;
		}
		tutorialGraphicB.screenCenter();
		tutorialGraphicB.alpha = 0;
		//	For the third tutorial popup
		tutorialGraphicC = new FlxSprite().loadGraphic(Paths.image('infocards/TutorialTipC', 'tutorial'));
		tutorialGraphicC.scrollFactor.set();
		tutorialGraphicC.updateHitbox();
		if(FlxG.save.data.antialiasing)
		{
			tutorialGraphicC.antialiasing = true;
		}
		tutorialGraphicC.screenCenter();
		tutorialGraphicC.alpha = 0;

		tutorialText = new FlxText(0, 0, -0);
		tutorialText.text = '${FlxG.save.data.leftBind}       ${FlxG.save.data.downBind}       ${FlxG.save.data.upBind}       ${FlxG.save.data.rightBind}';
		tutorialText.x = healthBarBG.x + healthBarBG.width / 2 + iconP1.width - 20;
		tutorialText.y = tutorialGraphicA.x + tutorialText.height;
		tutorialText.antialiasing = true;
		tutorialText.setFormat(Paths.font("playtime.ttf"), 50, CENTER);
		tutorialText.color = FlxColor.YELLOW;
		tutorialText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 6, 6);
		tutorialText.cameras = [camHUD];
		tutorialText.alpha = 0;

		//Tip Graphics for tutorial on how to avoid gun lol
		avoidBulletTipGraphic = new FlxSprite().loadGraphic(Paths.image('infocards/SpecialNoteTip', 'week3'));
		avoidBulletTipGraphic.scrollFactor.set();
		avoidBulletTipGraphic.updateHitbox();
		if(FlxG.save.data.antialiasing)
		{
			avoidBulletTipGraphic.antialiasing = true;
		}
		avoidBulletTipGraphic.screenCenter();
		avoidBulletTipGraphic.alpha = 0;

		hurtVignette.cameras = [camHUD];
		safeVignette.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		//replayTxt.cameras = [camHUD];
		botPlayText.cameras = [camHUD];
		tutorialGraphicA.cameras = [camHUD];
		tutorialGraphicB.cameras = [camHUD];
		tutorialGraphicC.cameras = [camHUD];
		avoidBulletTipGraphic.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		//doof.cameras = [camHUD];
		if (FlxG.save.data.songPosition)
		{
			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
		}
		kadeEngineWatermark.cameras = [camHUD];

		startingSong = true;

		trace('starting');

		if (startTime != 0)
		{
			var toBeRemoved = [];
			for(i in 0...unspawnNotes.length)
			{
				var dunceNote:Note = unspawnNotes[i];

				if (dunceNote.strumTime - startTime <= 0)
					toBeRemoved.push(dunceNote);
				else if (dunceNote.strumTime - startTime < 3500)
				{
					notes.add(dunceNote);

					if (dunceNote.mustPress)
						dunceNote.y = (playerStrums.members[Math.floor(Math.abs(dunceNote.noteData))].y
							+ 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
								2)) - dunceNote.noteYOff;
					else
						dunceNote.y = (strumLineNotes.members[Math.floor(Math.abs(dunceNote.noteData))].y
							+ 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
								2)) - dunceNote.noteYOff;
					toBeRemoved.push(dunceNote);
				}
			}

			for(i in toBeRemoved)
				unspawnNotes.remove(i);
		}

		#if windows
		// pre lowercasing the song name (startCountdown)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();
		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState();
			luaModchart.executeState('start', [songLowercase]);
		}
		#end

		//Cameradata
		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());
		FlxG.camera.follow(camFollow, LOCKON);
		//trace("CamFollowLerp was " + FlxG.camera.followLerp);
		FlxG.camera.followLerp = camFollowSpeed * (30 / FlxG.save.data.fpsCap);
		//trace("and is now " + FlxG.camera.followLerp);

		//Song Start Events
		if (!PlayStateChangeables.Optimize)
		{
			//trace("Song Startup Shit");
			//trace("'Played Cutscene' is " + playedCutscene);
			switch (StringTools.replace(curSong, " ", "-").toLowerCase())
			{
				case 'mic-test':
					if (!hasReset && deaths <= 0)
					{
						add(tutorialGraphicA);
						add(tutorialGraphicB);
						add(tutorialGraphicC);
						add(tutorialText);
					}
					startCountdown();
					hasSubtitles = true;
				case 'tech.-difficulties':
					if (isStoryMode && !playedCutscene && !FlxG.save.data.video)
					{
						inCutscene = true;
						playedCutscene = true;
						video =	 new MP4Handler();
						video.playVideo(Paths.video('week1/startcutscene'));
						video.finishCallback = function()
						{
							startCountdown();
						}
					}
					else
						startCountdown();
				case 'awkward-pauses' | 'up-and-beyond':
					startCountdown();
				case 'desperation':
					hasSubtitles = true;
					if (isStoryMode && !playedCutscene && !FlxG.save.data.video)
					{
						inCutscene = true;
						playedCutscene = true;
						video = new MP4Handler();
						if (FlxG.save.data.flashing)
							video.playVideo(Paths.video('week2/startcutscene'));
						else
							video.playVideo(Paths.video('week2/startcutscene-noFlash'));
						video.finishCallback = function()
						{
							desperationIntro();
						}
					}
					else
						startCountdown();
				case 'disagreement':
					hasSubtitles = true;
					if (isStoryMode && !playedCutscene && !FlxG.save.data.video)
					{
						camHUD.alpha = 0;
						blackScreen.alpha = 1;
						inCutscene = true;
						playedCutscene = true;
						video = new MP4Handler();
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
					camFollowSpeed = 0.01;
					//trace("TO " + camFollowSpeed);
					if (isStoryMode && !playedCutscene && !FlxG.save.data.video)
					{
						videoMusic = FlxG.sound.play(Paths.videoMusic('week2/midcutscene2-MUSIC'), 0.93);
						videoMusic.autoDestroy = true;
						videoMusic.looped = false;
						camHUD.alpha = 0;
						blackScreen.alpha = 1;
						inCutscene = true;
						video = new MP4Handler();
						video.playVideo(Paths.video('week2/midcutscene2'), false, false);
						video.finishCallback = function()
						{
							videoMusic.fadeOut(1);
							skipCountdown = true;
							startCountdown();
						}
					}
					else
						startCountdown();
				case 'kid-with-a-gun':
					hasSubtitles = true;
					startCountdown();
				case 'playing-with-fire':
					hasSubtitles = true;
					camFollowSpeed = 0.035;
					if (!playedCutscene)
						add(avoidBulletTipGraphic);
					startCountdown();
					camZooming = true;
				case 'variegated-skylines':
					hasSubtitles = true;
					startCountdown();
				default:
					camZooming = true;
					startCountdown();
			}
		}
		else
		{
			startCountdown();
		}

		//if (!loadRep)
		rep = new Replay("na");

		if (hasSubtitles && FlxG.save.data.subtitles)
		{
			add(subtitleText);
		}

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);

		super.create();

		defaultMashingThreshold = storyDifficulty * 5 * -1 + 20;
		noteMashingThreshold = defaultMashingThreshold;

		if (FlxG.save.data.pauseOnUnfocus)
		{
			switch (SONG.song)
			{
				case "Retaliation":
					if (isStoryMode && !playedCutscene && !FlxG.save.data.video)
					{
						playedCutscene = true;
						delayAutoPause = true;
						FlxG.autoPause = false;
					}
					else					
					{
						delayAutoPause = false;
						FlxG.autoPause = true;
					}
				default:
					delayAutoPause = false;
					FlxG.autoPause = true;
			}

			/*FlxG.signals.focusGained.add(function()
			{
				focusIn();
			});
			FlxG.signals.focusLost.add(function()
			{
				focusOut();
			});*/
		}

		//Preloading Sounds and Music (to prevent laggy euGh  AHFHGAGJMNOmnSKDVkks yes)
		//i am going insane (at how unsure I am if this is good or not [clarified by future me to prevent any concerned parents hehe])

		//Le GameOver Music and SFX
		FlxG.sound.load(Paths.sound("deathsound" + stageSuffix));
		FlxG.sound.load(Paths.music("gameOver" + stageSuffix));
		FlxG.sound.load(Paths.music("gameOverEnd" + stageSuffix));

		FlxG.sound.load(Paths.sound('skipSongIntro'));
		lowHPHeartBeat = FlxG.sound.load(Paths.sound('lowHP'));
		var gameplaySFX:Array<String> = ["intro3", "intro2", "intro1", "introGo", "missnote1", "missnote2", "missnote3", "enemyMiss1", "enemyMiss2", "enemyMiss3"]; //THANK YOU STILL BSOD#2524 FROM HAXE DISCORD SERVER!!!!
		for (i in gameplaySFX) 
		{
			FlxG.sound.load(Paths.sound(i));
			trace("Loaded Gameplay SFX: " + i);
		}

		if (allowNoteHitSounds && FlxG.save.data.notesfx)
		{
			if (PlayStateChangeables.botPlay)
				hitsoundType = "botplay";
			else
				hitsoundType = FlxG.save.data.notesfxType;

			loadNoteHitSound();

			if (SONG.song == "Playing With Fire" || SONG.song == "Variegated Skylines")
			{
				FlxG.sound.load(Paths.sound('Note_Mine'));
				FlxG.sound.load(Paths.sound('Note_Trigger'));
			}
		}
		
		if (SONG.song == "Finale")
		{
			loadFinaleMusic();
			trace("Yuh");
			/*drums.volume = 1;
			taiko.volume = 1;
			choir.volume = 1;
			hats.volume = 1;
			adders.volume = 1;
			slayer.volume = 1;
			retalHats.volume = 1;
			bells.volume = 1;
			pads.volume = 1;
			danger.volume = 0.3;
			trace("Didda Volume Thingy");*/
			//naawww dude, this makes it crash so no LMAO
		}
	}

	function desperationIntro():Void
	{
		generateStaticArrows(0);
		generateStaticArrows(1);
		if (blackScreen.alpha > 0 || camHUD.alpha <= 0)
		{
			FlxTween.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.quadOut, startDelay: 0.3});
			FlxTween.tween(blackScreen, {alpha: 0}, 1, {ease: FlxEase.quadOut, startDelay: 0.3});
			trace("Le cams faded in");
		}
		inCutscene = true;
		gf.playAnim('none', true);
		camHUD.visible = true;
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
				var ready:FlxSprite = new FlxSprite(-650, 590).loadGraphic(Paths.image('ready'));
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
				FlxTween.tween(ready, {y: ready.y + 5, alpha: 0}, Conductor.crochet / 1000, {
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
					camHUD.visible = false;
					camFollow.y =  gf.getGraphicMidpoint().y + 20;
					FlxG.sound.play(Paths.sound('Table_Crash'));
					gf.playAnim('fall', true);
					new FlxTimer().start(0.15, function(swagTimer:FlxTimer)
					{
						camShake = true;
						isEarthquake = true;
						boyfriend.playAnim('scared', true);
						dad.playAnim('scared', true);
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							new FlxTimer().start(0.7, function(swagTimer:FlxTimer)
							{
								camHUD.visible = true;
								startCountdown();
							});
						});
					});
				});
			});
		});
	}

	function changeSubtitles(text:String, color:FlxColor):Void
	{
		if (hasSubtitles && FlxG.save.data.subtitles && !endedSong)
		{
			subtitleText.text = text;
			subtitleText.color = color;
			if (FlxG.save.data.centersubtitles)
				subtitleText.x = healthBarBG.x + (healthBarBG.width - subtitleText.width) / 2;
			if (subtitleText.text == '')
			{
				//if (loadRep)
				//	replayTxt.alpha = 1;
				if (PlayStateChangeables.botPlay)
					botPlayText.alpha = 1;
			}
			else
			{
				//if (loadRep)
				//	replayTxt.alpha = 0.3;
				if (PlayStateChangeables.botPlay)
					botPlayText.alpha = 0.3;
			}
			//scoreTxt.screenCenter(X);
		}
	}

	var luaWiggles:Array<WiggleEffect> = [];

	#if windows
	public static var luaModchart:ModchartState = null;
	#end

	function startCountdown():Void
	{
		trace("StartCountdown");

		if (delayAutoPause)
			FlxG.autoPause = true;

		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Get Ready..!", null);
		#end

		if (!generatedArrows)
		{
			generateStaticArrows(0);
			generateStaticArrows(1);
		}

		if (!inCutscene)
			inCutscene = true;

		if (blackScreen.alpha > 0 || camHUD.alpha <= 0)
		{
			FlxTween.tween(camHUD, {alpha: 1}, 1, {ease: FlxEase.quadOut, startDelay: 0.3});
			FlxTween.tween(blackScreen, {alpha: 0}, 1, {ease: FlxEase.quadOut, startDelay: 0.3});
			trace("Le cams faded in");
		}

		if (storyPlaylist.length <= 2 && SONG.song != 'Mic Test')
			camFollowShit();
		else
		{
			camFollow.x =  gf.getGraphicMidpoint().x;
			camFollow.y =  gf.getGraphicMidpoint().y;
		}
			
		talking = false;
		startedCountdown = true;

		Conductor.songPosition = 0;

		if (!skipCountdown)
		{
			Conductor.songPosition -= Conductor.crochet * 5;
			var swagCounter:Int = 0;

			countdownTimer.start(Conductor.crochet / 1000, function(tmr:FlxTimer)
			{
				dad.dance();
				gf.dance();
				boyfriend.playAnim('idle');

				var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
				introAssets.set('default', ["ready", "set", "go"]);
				introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
				introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

				var introAlts:Array<String> = introAssets.get('default');
				var altSuffix:String = "";

				for (value in introAssets.keys())
				{
					if (value == curStage)
					{
						trace(value + " - " + curStage);
						introAlts = introAssets.get(value);
						if (curStage.contains('school'))
							altSuffix = '-pixel';
					}
				}

				swagCounter += 1;

				switch (swagCounter)
				{
					case 1:
						FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
					case 2:
						var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
						ready.y = 225;
						ready.scrollFactor.set();
						ready.updateHitbox();
						ready.cameras = [camHUD];

						if (curStage.startsWith('school'))
						{
							ready.setGraphicSize(Std.int(ready.width * daPixelZoom));
							if(FlxG.save.data.antialiasing)
								{
									ready.antialiasing = false;
								}		
						}
						else
						{
							if(FlxG.save.data.antialiasing)
								{
									ready.antialiasing = true;
								}
						}

						ready.screenCenter(X);
						add(ready);
						FlxTween.tween(ready, {y: ready.y + 5, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								ready.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
					case 3:
						var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
						set.y = 220;
						set.scrollFactor.set();
						set.cameras = [camHUD];

						if (curStage.startsWith('school'))
						{
							set.setGraphicSize(Std.int(set.width * daPixelZoom));
							if(FlxG.save.data.antialiasing)
								{
									set.antialiasing = false;
								}		
						}
						else
						{
							if(FlxG.save.data.antialiasing)
								{
									set.antialiasing = true;
								}
						}

						set.screenCenter(X);
						add(set);
						FlxTween.tween(set, {y: set.y + 5, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								set.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
					case 4:
						var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
						go.y = 185;
						go.scrollFactor.set();
						go.cameras = [camHUD];

						if (curStage.startsWith('school'))
						{
							go.setGraphicSize(Std.int(go.width * daPixelZoom));
							if(FlxG.save.data.antialiasing)
								{
									go.antialiasing = false;
								}		
						}
						else
						{
							if(FlxG.save.data.antialiasing)
								{
									go.antialiasing = true;
								}
						}

						go.updateHitbox();
						go.screenCenter(X);
						add(go);
						FlxTween.tween(go, {y: go.y + 5, alpha: 0}, Conductor.crochet / 1000, {
							ease: FlxEase.cubeInOut,
							onComplete: function(twn:FlxTween)
							{
								go.destroy();
							}
						});
						FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
					case 5:
						trace('song started');
				}
			}, 5);
		}
		else
			inCutscene = false;
			countdownTimer.start(0);
	}

	var previousFrameTime:Int = 0;
	var songTime:Float = 0;

	private function getKey(charCode:Int):String
	{
		for (key => value in FlxKey.fromStringMap)
		{
			if (charCode == value)
				return key;
		}
		return null;
	}

	var keys = [false, false, false, false];

	private function releaseInput(evt:KeyboardEvent):Void // handles releases
	{
		@:privateAccess
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode) // arrow keys
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
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}

		if (data == -1)
			return;

		keys[data] = false;
	}

	private var noNotesToHit:Bool = true;

	private function handleInput(evt:KeyboardEvent):Void
	{ // this actually handles press inputs

		if (PlayStateChangeables.botPlay || paused)
			return;

		// first convert it from openfl to a flixel key code
		// then use FlxKey to get the key's name based off of the FlxKey dictionary
		// this makes it work for special characters

		@:privateAccess
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode) // arrow keys
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
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}
		if (data == -1)
		{
			//trace("couldn't find a keybind with the code " + key);
			return;
		}
		if (keys[data])
		{
			//trace("ur already holding " + key);
			return;
		}
		//Does this cause the lag? lemme remove it to see.
		//LESSON LEARNED: DON'T REMOVE IT CAUSE IT MAKES SUSTAIN NOTES FUCKIN BAD
		//The Anti-mashing shit
		else if (!keys[data] && startedCountdown && songStarted && !noNotesToHit)
		{
			if (notePresses > noteMashingThreshold + 10 && PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				accuracy -= 0.25;
				updateAccuracy();
				//trace("BRO STOP SPAMMING");
			}
			notePresses++;
			//trace("Input: Is " + notePresses + " < " + noteMashingThreshold + "?");
		}

		keys[data] = true;

		var ana = new Ana(Conductor.songPosition, null, false, "miss", data);

		var dataNotes = [];
		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && daNote.noteData == data)
				dataNotes.push(daNote);
		}); // Collect notes that can be hit

		dataNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime)); // sort by the earliest note

		if (dataNotes.length != 0)
		{
			noNotesToHit = false;

			var coolNote = null;

			for (i in dataNotes)
				if (!i.isSustainNote)
				{
					coolNote = i;
					break;
				}

			if (coolNote == null) // Note is null, which means it's probably a sustain note. Update will handle this (HOPEFULLY???)
			{
				return;
			}

			if (dataNotes.length > 1) // stacked notes or really close ones
			{
				for (i in 0...dataNotes.length)
				{
					if (i == 0) // skip the first note
						continue;

					var note = dataNotes[i];

					if (!note.isSustainNote && (note.strumTime - coolNote.strumTime) < 2)
					{
						//trace('found a stacked/really close note ' + (note.strumTime - coolNote.strumTime));
						// just fuckin remove it since it's a stacked note and shouldn't be there
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
				}
			}

			goodNoteHit(coolNote);
			var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
			ana.hit = true;
			ana.hitJudge = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
			ana.nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
		}
		else if (dataNotes.length <= 0 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			noNotesToHit = true;
		else if (!FlxG.save.data.ghost && songStarted)
		{
			noteMiss(data, null);
			ana.hit = false;
			ana.hitJudge = "shit";
			ana.nearestNote = [];
			songScore -= 50;
			//uhh what happens if i-
			if (allowHealthModifiers)
			{
				if (health >= 0.35)
					health -= 0.10;
				else
					health -= 0.08;
			}
		}
	}

	var songStarted = false;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;

		//trace('song starteted (funct)');

		if (inCutscene)
			inCutscene = false;

		if (!FlxG.sound.music.playing) // don't restart the music if it's already playing
		{
			if (SONG.song != "Finale")
			{
				if (!paused)
				{
					#if sys
					if (!isStoryMode && isSM)
					{
						//trace("Loading " + pathToSm + "/" + sm.header.MUSIC);
						var bytes = File.getBytes(pathToSm + "/" + sm.header.MUSIC);
						var sound = new Sound();
						sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
						FlxG.sound.playMusic(sound);
					}
					else
						FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0, false);
					#else
					FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0, false);
					#end
				}
				FlxG.sound.music.looped = false;
				FlxG.sound.music.onComplete = endSong;
			}
			else
			{
				//trace("reestarded");
				if (!paused)
					FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 0, false);
				FlxG.sound.music.looped = true;
				FlxG.sound.music.autoDestroy = false;
				FlxG.sound.music.onComplete = regenerateSong;
			}
		}

		vocals.play();
		switch (SONG.song)
		{
			//DOn't forget to do this same thing to chartingstate (just search "miscs" there lol)
			case "Playing With Fire" | "Variegated Skylines" | "Sudden Confrontation":
				miscs.play();
		}
		/*IDEA FOR THE FINALE 7:25 FEB-02-2022
		Song Intro: Music's Intro/Prelude like with Asgore when you fight him. Bergentrückung (intro) is a different
			track compared ASGORE (Battle Music). Not sure yet if we should do the countdown thingy or not.
		Music: Is the leitmotif of Retaliation except more epic and adaptive. There will be different drum loops
			(or just loops in general?) for each attack/event and the music is to inform the player about what
			is happening and what will happen. 
		Game Over Screen: Is an animation (accompanied by sfx) of a candle going out with the word retry slowly appearing. 
			Game over music is melancholic, yet calm and hopeful just like the original game over themes. Sample the "Don't
			Stop" vocals somewhere. Pressing ENTER will Reignite the candle, and make the retry light up and the camera zoom out
			and slowly zoom back in. The music will be of a buildup with of course either a cello strum or a chime hit at the end.*/
			
		

		// Song duration in a float, useful for the time left feature
		if (!paused)
			songLength = FlxG.sound.music.length;

		if (FlxG.save.data.songPosition)
		{
			remove(songPosBG);
			remove(songPosBar);
			remove(songDuration);

			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);

			songPosBar = new FlxBar(songPosBG.x
				+ 4, songPosBG.y
				+ 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength
				- 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.GRAY, FlxColor.LIME);
			add(songPosBar);

			songDuration = new FlxText(songPosBG.x, songPosBG.y, 0, "Song Progress:", 16);
			songDuration.x = songPosBG.x + (songPosBG.width - songDuration.width) / 2;
			if (PlayStateChangeables.useDownscroll)
				songDuration.y -= 3;
			songDuration.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songDuration.scrollFactor.set();
			add(songDuration);

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songDuration.cameras = [camHUD];
		}

		// Song check real quick
		switch (curSong)
		{
			case 'Philly Nice' | 'Blammed' | 'Cocoa' | 'Eggnog' | 'Tech. Difficulties'| 'Awkward Pauses':
				allowedToHeadbang = true;
			default:
				allowedToHeadbang = false;
		}

		/*if (useVideo)
			GlobalVideo.get().resume();*/

		#if windows
		if (FlxG.save.data.showPresence)
		{
			// Updating Discord Rich Presence (with Time Left)
			DiscordClient.changePresence(detailsText
				+ " "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"\nAcc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses); //, iconRPC
		}
		#end

		//startTime = 0;
		FlxG.sound.music.time = startTime;
		vocals.time = startTime;
		switch (SONG.song)
		{
			case "Playing With Fire" | "Variegated Skylines" | "Sudden Confrontation":
				miscs.time = startTime;
		}
		Conductor.songPosition = startTime;
		startTime = 0;
		FlxG.sound.music.volume = 1;

		for(i in 0...unspawnNotes.length)
			if (unspawnNotes[i].strumTime < startTime)
				unspawnNotes.remove(unspawnNotes[i]);

		if (needSkip)
			{
				skipActive = true;
				skipText = new FlxText(healthBarBG.x, healthBarBG.y - 110, -0);
				skipText.text = "Press [SPACE] to Skip Intro";
				skipText.antialiasing = true;
				skipText.setFormat(Paths.font("playtime.ttf"), 40);
				skipText.x = healthBarBG.x + (healthBarBG.width - skipText.width) / 2;
				skipText.color = FlxColor.WHITE;
				skipText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 1);
				skipText.cameras = [camHUD];
				skipText.alpha = 0;
				FlxTween.tween(skipText, {alpha: 1}, 0.2);
				FlxTween.tween(botPlayText, {alpha: 0.5}, 0.2, {ease: FlxEase.sineInOut});
				add(skipText);
			}
	}

	var debugNum:Int = 0;

	public function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		#if sys
		if (SONG.needsVoices && !isSM)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();
		#else
		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();
		#end

		//trace('loaded vocals');

		FlxG.sound.list.add(vocals);

		switch (SONG.song)
		{
			case "Playing With Fire" | "Variegated Skylines" | "Sudden Confrontation":
				miscs = new FlxSound().loadEmbedded(Paths.miscs(PlayState.SONG.song));
				hasMiscs = true;
				//trace('loaded miscs');
			case "Finale":
				miscs = new FlxSound();
				hasMiscs = false;
				vocals.looped = true;
			default:
				miscs = new FlxSound();
				hasMiscs = false;
		}

		FlxG.sound.list.add(miscs);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		// Per song offset check
		#if windows
		// pre lowercasing the song name (generateSong)
		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();

		var songPath = 'assets/data/' + songLowercase + '/';
		
		#if sys
		if (isSM && !isStoryMode)
			songPath = pathToSm;
		#end

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
					trace('Offset file not found. Creating one @: ' + songPath);
					sys.io.File.saveContent(songPath + songOffset + '.offset', '');
				}
			}
		}
		#end
		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped


		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

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
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				if (susLength > 0)
					swagNote.isParent = true;

				var type = 0;

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, daNoteStyle);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}

					sustainNote.parent = swagNote;
					swagNote.children.push(sustainNote);
					sustainNote.spotInLine = type;
					type++;
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	//This is shit
	public function regenerateSong():Void
	{
		trace ('Regenerated song');

		vocals.pause();
		FlxG.sound.music.pause();
		FlxG.sound.music.time = 0;
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
		FlxG.sound.music.play();

		trace('reset vocals and music');

		var dataPath:String = SONG.song;
		var songData = SONG;
		curSong = songData.song;
		var noteData:Array<SwagSection>;

		notes = new FlxTypedGroup<Note>();
		add(notes);

		// NEW SHIT.. AGAIN
		var noteData:Array<SwagSection>;
		noteData = songData.notes;

		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

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
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				if (susLength > 0)
					swagNote.isParent = true;

				var type = 0;

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true, daNoteStyle);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}

					sustainNote.parent = swagNote;
					swagNote.children.push(sustainNote);
					sustainNote.spotInLine = type;
					type++;
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			//Sloink                                V
			var babyArrow:FlxSprite = new FlxSprite(50, strumLine.y - 10);

			// defaults if no noteStyle was found in chart
			var noteTypeCheck:String = 'normal';

			if (PlayStateChangeables.Optimize && player == 0)
				continue;

			if (SONG.noteStyle == null)
			{
				switch (storyWeek)
				{
					case 6:
						noteTypeCheck = 'pixel';
				}
			}
			else
			{
				noteTypeCheck = SONG.noteStyle;
			}

			switch (noteTypeCheck)
			{
				case 'pixel':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					for (j in 0...4)
					{
						babyArrow.animation.addByPrefix(dataColor[j], 'arrow' + dataSuffix[j]);	
					}

					var lowerDir:String = dataSuffix[i].toLowerCase();

					babyArrow.animation.addByPrefix('static', 'arrow' + dataSuffix[i]);
					babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 32, false);

					babyArrow.x += Note.swagWidth * i;

					if(FlxG.save.data.antialiasing)
						{
							babyArrow.antialiasing = true;
						}
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.alpha = 0;

			var babyArrowAlphaSubtractor:Float = 0;

			if (player == 0)
				babyArrowAlphaSubtractor = 0.2;

			if (storyPlaylist.length <= 2 && SONG.song != 'Mic Test' && isStoryMode)
			{
				babyArrow.alpha = 1 - babyArrowAlphaSubtractor;
				babyArrow.y += 10;
			}
			else 
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1 - babyArrowAlphaSubtractor}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			//babyArrow.y -= 10;

			babyArrow.ID = i;

			switch (player)
			{
				case 0:
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
					generatedArrows = true;
			}

			babyArrow.animation.play('static');
			if(!PlayStateChangeables.Optimize)
				babyArrow.x += 50;
			else
				babyArrow.x -= 275;
			babyArrow.x += ((FlxG.width / 2) * player);

			cpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets(); // CPU arrows start out slightly off-center
			});

			strumLineNotes.add(babyArrow);
		}
	}

	var finishedHUDFadeOutFunction:Bool = false;

	private function fadeOutGameplayHUD(delayMultiplier:Float):Void
	{
		//delay multiplier guide: set to 0 for no delay, 1 for default delay, below 1 to shorten and beyond 1 to prolong
		strumLineNotes.forEach(function(babyArrow:FlxSprite)
		{
			for (i in 0...4)
			{
				babyArrow.acceleration.y = 900;
				babyArrow.velocity.y -= FlxG.random.int(20, 75);
				babyArrow.velocity.x += FlxG.random.int(-20, 20); 
				FlxTween.tween(babyArrow, {alpha: 0}, 0.5, {ease: FlxEase.quadOut, startDelay: 0.75});
			}
		});
		FlxTween.tween(healthBarBG, {alpha: 0}, 0.5 * delayMultiplier, {ease: FlxEase.quadOut});
		FlxTween.tween(healthBar, {alpha: 0}, 0.5 * delayMultiplier, {ease: FlxEase.quadOut});
		FlxTween.tween(iconP1, {alpha: 0}, 0.5 * delayMultiplier, {ease: FlxEase.quadOut});
		FlxTween.tween(iconP2, {alpha: 0}, 0.5 * delayMultiplier, {ease: FlxEase.quadOut});
		FlxTween.tween(scoreTxt, {alpha: 0}, 0.5 * delayMultiplier, {ease: FlxEase.quadOut});
		FlxTween.tween(kadeEngineWatermark, {alpha: 0}, 0.5 * delayMultiplier, {ease: FlxEase.quadOut});
		finishedHUDFadeOutFunction = true;
	}

	/*function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.5}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.bounceInOut});
	}*/

	override function openSubState(SubState:FlxSubState)
	{
		//inSubstate = true;
		//paused = true;
		//trace("Opened Substate");
		if (!endedSong)
		{
			if (FlxG.save.data.pauseOnUnfocus)
				FlxG.autoPause = false;
			if (paused && !died)
			{
				if (FlxG.sound.music != null)
				{
					FlxG.sound.music.pause();
					vocals.pause();
					switch (SONG.song)
					{
						case "Playing With Fire" | "Variegated Skylines" | "Sudden Confrontation":
							miscs.pause();
						case "Finale":
							drums.pause();
							taiko.pause();
							choir.pause();
							hats.pause();
							adders.pause();
							slayer.pause();
							retalHats.pause();
							bells.pause();
							pads.pause();
							danger.pause();
					}
				}

				#if windows
				if (FlxG.save.data.showPresence)
				{
					DiscordClient.changePresence("PAUSED - "
						+ SONG.song
						+ " ("
						+ storyDifficultyText
						+ ") "
						+ Ratings.GenerateLetterRank(accuracy),
						"\nAcc: "
						+ HelperFunctions.truncateFloat(accuracy, 2)
						+ "% | Score: "
						+ songScore
						+ " | Misses: "
						+ misses); //, iconRPC
				}
				#end
				//if (startedCountdown && !songStarted)
				countdownTimer.active = false;
				trace('countdownTimer.active is ' + countdownTimer.active);
			}
			else if (paused && died)
			{
				#if windows
				// Game Over doesn't get his own variable because it's only used here
				if (FlxG.save.data.showPresence)
				{
					DiscordClient.changePresence("GAME OVER - "
						+ SONG.song
						+ " ("
						+ storyDifficultyText
						+ ") "
						+ Ratings.GenerateLetterRank(accuracy),
						"\nAcc: "
						+ 'DEAD'
						+ " | Score: "
						+ songScore
						+ " | Misses: "
						+ misses); //, iconRPC
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
			if (paused)
			{
				if (FlxG.sound.music != null && !startingSong)
				{
					if (!resultsPresent && !inCutscene)
						resyncVocals();
				}

				//if (startedCountdown && !songStarted)
				countdownTimer.active = true;
				trace('countdownTimer.active is ' + countdownTimer.active);

				switch (SONG.song)
				{
					case "Playing With Fire" | "Variegated Skylines" | "Sudden Confrontation":
						miscs.resume();
					case "Finale":
						drums.resume();
						taiko.resume();
						choir.resume();
						hats.resume();
						adders.resume();
						slayer.resume();
						retalHats.resume();
						bells.resume();
						pads.resume();
						danger.resume();
				}

				paused = false;

				#if windows
				if (FlxG.save.data.showPresence)
				{
					if (countdownTimer.finished && !paused)
					{
						DiscordClient.changePresence(detailsText
							+ " "
							+ SONG.song
							+ " ("
							+ storyDifficultyText
							+ ") "
							+ Ratings.GenerateLetterRank(accuracy),
							"\nAcc: "
							+ HelperFunctions.truncateFloat(accuracy, 2)
							+ "% | Score: "
							+ songScore
							+ " | Misses: "
							+ misses, "", true,
							songLength
							- Conductor.songPosition);
					}
					else
					{
						DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy)); //, iconRPC
					}
				}
				#end
			}
		}
		
		super.closeSubState();
	}

	function resyncVocals():Void
	{
		if (FlxG.sound.music.time - Conductor.songPosition > 150)
			allowHealthModifiers = false;
		//trace("Timing Gap: " + (FlxG.sound.music.time - Conductor.songPosition));
		vocals.pause();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
		FlxG.sound.music.play();
		switch (curSong)
		{
			case "Playing With Fire" | "Variegated Skylines" | "Sudden Confrontation":
				miscs.pause();
				miscs.time = Conductor.songPosition;
				miscs.play();
				//trace("resynced miscs!");
		}
		//trace("resynced vocals!");

		#if windows
		if (FlxG.save.data.showPresence && !paused)
		{
			DiscordClient.changePresence(detailsText
				+ " "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"\nAcc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses); //, iconRPC
		}
		#end

		if (curBeat > 4)
			compensationTimer.start(0.8, function(tmr:FlxTimer)
			{
				allowHealthModifiers = true;
				//trace("compensated (via resync vocals)");
			});
	}

	private var paused:Bool = false;
	private var died:Bool = false;
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

	var frameRateLimit = FlxG.save.data.fpsCap * 0.35; //maybe 0.3 is fine but I'm testing out 0.5
	var compensatedViaLagSpike:Bool = false;

	override public function update(elapsed:Float)
	{
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
					trace("BPM CHANGE to " + timingSegBpm);
					Conductor.changeBPM(timingSegBpm, false);
				}
	
			}

		if (!cannotDie)
			safeVignette.visible = false;
		else
			safeVignette.visible = true;

		/*if (useVideo && GlobalVideo.get() != null && !stopUpdate)
		{
			if (GlobalVideo.get().ended && !removedVideo)
			{
				remove(videoSprite);
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				removedVideo = true;
			}
		}*/

		#if windows
		if (executeModchart && luaModchart != null && songStarted)
		{
			luaModchart.setVar('songPos', Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('cameraZoom', FlxG.camera.zoom);
			luaModchart.executeState('update', [elapsed]);

			for (i in luaWiggles)
			{
				//trace('wiggle le gaming');
				i.update(elapsed);
			}


			FlxG.camera.angle = luaModchart.getVar('cameraAngle', 'float');
			camHUD.angle = luaModchart.getVar('camHudAngle', 'float');

			if (luaModchart.getVar("showOnlyStrums", 'bool') || isolateArrows)
			{
				healthBarBG.visible = false;
				kadeEngineWatermark.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				kadeEngineWatermark.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
			}

			var p1 = luaModchart.getVar("strumLine1Visible", 'bool');
			var p2 = luaModchart.getVar("strumLine2Visible", 'bool');

			for (i in 0...4)
			{
				strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}
		}
		#end

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

		super.update(elapsed);

		FlxG.mouse.visible = false;

		switch (curStage)
		{
			case 'cityskyline':
				//this was once disabled, i enabled it to see what happens
				//hehehe I made it work!!11!
				cityLights.members[curLight].alpha -= (Conductor.crochet / cityLightTimeShit) * FlxG.elapsed;
				/*if (trainMoving && !PlayStateChangeables.Optimize)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}*/
				if (hurtVignette.alpha > 0)
					hurtVignette.alpha -= (Conductor.crochet / cityLightTimeShit * 2) * FlxG.elapsed;
			case 'cityskylineVariegated':
				if (hurtVignette.alpha > 0)
					hurtVignette.alpha -= (Conductor.crochet / cityLightTimeShit * 2) * FlxG.elapsed;
		}

		//Low-Health Volume Suspense
		if (generatedMusic && startedCountdown && !cannotDie)
		{
			if (allowHeartBeatSounds)
			{
				lowHealthSoundVolume = health * -1 + 1.1;
				if (lowHealthSoundVolume < 0)
				{
					lowHealthSoundVolume * -1;
					//trace ("True");
				}
				lowHPHeartBeat.volume = lowHealthSoundVolume;

				switch (curSong)
				{
					case "Mic Test":
						//Do nATHIn
					case "Tech. Difficulties" | "Retaliation":
						//Most Audio Volume during Low Health
						if (health < 1)
							FlxG.sound.music.volume = health + 0.30;
						else if (health >= 1 && FlxG.sound.music.volume < 1)
							FlxG.sound.music.volume = 1;
					case "Awkward Pauses" | "Disagreement":
						//Middle Audio Volume during Low Health
						if (health < 1)
							FlxG.sound.music.volume = health + 0.15;
						else if (health >= 1 && FlxG.sound.music.volume < 1)
							FlxG.sound.music.volume = 1;
					case "Playing With Fire":
						if (health < 1)
						{
							FlxG.sound.music.volume = health + 0.3;
							miscs.volume = health + 0.8;
						}
						else if (health >= 1 && FlxG.sound.music.volume < 1)
						{
							FlxG.sound.music.volume = 1;
							miscs.volume = 1;
						}
					case "Variegated Skylines":	
						if (health < 1)
						{
							FlxG.sound.music.volume = health + 0.9;
							miscs.volume = health + 0.9;
						}
						else if (health >= 1 && FlxG.sound.music.volume < 1)
						{
							FlxG.sound.music.volume = 1;
							//miscs.volume = 1;
						}
					case "Sudden Confrontation":
						if (health < 1)
							FlxG.sound.music.volume = health + 0.75;
						else if (health >= 1 && FlxG.sound.music.volume < 1)
							FlxG.sound.music.volume = 1;
					case "Finale":
						if (health < 1)
						{
							FlxG.sound.music.volume = health;
							drums.volume = health + 0.03;
							taiko.volume = health + 0.03;
							choir.volume = health;
							hats.volume = health + 0.01;
							adders.volume = health;
							slayer.volume = health;
							retalHats.volume = health + 0.03;
							bells.volume = health;
							pads.volume = health;
							danger.volume = health * -1 + 1.1;
						}
						else if (health >= 1 && FlxG.sound.music.volume < 1)
						{
							FlxG.sound.music.volume = 1;
							drums.volume = 1;
							taiko.volume = 1;
							choir.volume = 1;
							hats.volume = 1;
							adders.volume = 1;
							slayer.volume = 1;
							retalHats.volume = 1;
							bells.volume = 1;
							pads.volume = 1;
							danger.volume = 0.1;
						}
					default:
						//Least Audio Volume during Low Health
						if (health < 1)
							FlxG.sound.music.volume = health;
						else if (health >= 1 && FlxG.sound.music.volume < 1)
							FlxG.sound.music.volume = 1;
				}
			}
		}

		if (camShake && !triggeredCamShake)
		{
			triggeredCamShake = true;
			camShake = false;
			prevCamFollowSpeed = camFollowSpeed;
			FlxG.camera.followLerp = 2;
			if (isEarthquake)
			{
				FlxG.camera.shake(0.035, 0.2, camShakeFinish);
			}
			else
				FlxG.camera.shake(0.02, 0.25, camShakeFinish);
		}

		scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS, accuracy);

		var lengthInPx = scoreTxt.textField.length * scoreTxt.frameHeight; // bad way but does more or less a better job
		scoreTxt.x = (originalX - (lengthInPx / 2)) + 206;
		scoreTxt.screenCenter(X);

		if (controls.PAUSE && startedCountdown && canPause)
		{
			pauseGame();
		}

		//#if debug
		if (FlxG.keys.justPressed.SEVEN)
		{
			/*if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				#if sys
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				#end
				removedVideo = true;
			}*/
			deaths = 0;
			hasReset = false;
			cannotDie = true;
			FlxG.switchState(new ChartingState());
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if windows
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}
		//#end

		if (FlxG.save.data.distractions)
		{
			iconP1.setGraphicSize(Std.int(FlxMath.lerp(150, iconP1.width, 0.90)));
			iconP2.setGraphicSize(Std.int(FlxMath.lerp(150, iconP2.width, 0.90)));
		}
		
		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;
		else if (health < 0)
			health = 0;

		if (healthBar.percent < 25)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 85)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		//else if (FlxG.keys.justPressed.THREE)
		else if (FlxG.keys.justPressed.FIVE)
		{
			/*if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				removedVideo = true;
			}*/

			FlxG.switchState(new AnimationDebug(SONG.player2));
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if windows
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}
		else if (FlxG.keys.justPressed.SIX)
		{
			FlxG.switchState(new AnimationDebug(SONG.player1));
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if windows
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}
		else if(FlxG.keys.justPressed.TWO) 
		{ //Go 10 seconds into the future, credit: Shadow Mario#9396
			if (!usedTimeTravel && Conductor.songPosition + 10000 < FlxG.sound.music.length) 
			{
				usedTimeTravel = true;
				FlxG.sound.music.pause();
				vocals.pause();
				switch (SONG.song)
				{
					case "Playing With Fire" | "Variegated Skylines" | "Sudden Confrontation":
						miscs.pause();
				}
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					//if((daNote.strumTime - 500 < Conductor.songPosition && daNote.noteStyle != "mine") || (daNote.strumTime - 5000 <= Conductor.songPosition && daNote.noteStyle == "mine")) 
					if(daNote.strumTime - 500 < Conductor.songPosition && daNote.noteStyle != "mine")
					{
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
						//trace ('deleted note lol');
					}
				});
				for (i in 0...unspawnNotes.length) {
					var daNote:Note = unspawnNotes[0];
					if(daNote.strumTime - 500 >= Conductor.songPosition) {
						break;
					}
					unspawnNotes.splice(unspawnNotes.indexOf(daNote), 1);
				}

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
				switch (SONG.song)
				{
					case "Playing With Fire" | "Variegated Skylines" | "Sudden Confrontation":
						miscs.time = Conductor.songPosition;
						miscs.play();
				}
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						if (healthBar.percent < 50)
						health = 1;
						usedTimeTravel = false;
					});
			}
		}
		#else
		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}
		else if (PlayStateChangeables.botPlay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;
		#end

		// Song duration in a float, useful for the time left feature
		if (!paused)
			songLength = FlxG.sound.music.length;

		//Pause Skip Song Shit
		if (isStoryMode && PauseSubState.skippedSong)
		{
			PauseSubState.skippedSong = false;
			skippedShit = true;
			FlxG.sound.music.volume = 0;
			vocals.volume = 0;
			FlxG.sound.music.pause();
			vocals.pause();
			switch (SONG.song)
			{
				case "Playing With Fire" | "Variegated Skylines" | "Sudden Confrontation":
					miscs.volume = 0;
					miscs.pause();
			}
			PlayState.instance.clear();
			endSong();
		}

		if (skipActive && Conductor.songPosition >= skipTo)
		{
			skipActive = false;
			FlxTween.tween(botPlayText, {alpha: 1}, 0.2, {ease: FlxEase.sineInOut});
			FlxTween.tween(skipText, {alpha: 0}, 0.2,
			{
				onComplete: function(tw)
				{
						skipText.destroy();
				}
			});
		}
	
		if (FlxG.keys.justPressed.SPACE && skipActive && generatedMusic && startedCountdown && curBeat >= 0)
		{
			FlxG.sound.music.pause();
			switch (SONG.song)
			{
				case "Playing With Fire" | "Variegated Skylines" | "Sudden Confrontation":
					miscs.pause();
			}
			vocals.pause();
			Conductor.songPosition = skipTo;
	
			FlxG.sound.music.time = Conductor.songPosition;
			FlxG.sound.music.play();
	
			vocals.time = Conductor.songPosition;
			vocals.play();

			switch (SONG.song)
			{
				case "Mic Test":
					if (!PlayStateChangeables.Optimize)
					{
						camTween.cancel();
						FlxG.camera.zoom = 1.5;
					}
				case "Playing With Fire" | "Variegated Skylines" | "Sudden Confrontation":
					miscs.time = Conductor.songPosition;
					miscs.play();
			}

			FlxG.sound.play(Paths.sound('skipSongIntro'));
			
			FlxTween.tween(botPlayText, {alpha: 1}, 0.1, {ease: FlxEase.sineInOut});
			skipText.destroy();
			skipActive = false;
		}
	

		//Starting Countdown Shit
		if (startingSong)
		{
			if (startedCountdown && !paused)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0 && !songStarted)
					startSong();
			}
		}
		else if (!paused)
		{
			//Portal 2
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			/*@:privateAccess
				{
					FlxG.sound.music._channel.
			}*/
			songPositionBar = Conductor.songPosition;

			//{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					//allowHealthModifiers = false;
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					//trace('MISSED FRAME');
					//allowHealthModifiers = true;
				}

				//CONVERTED TO ELSE IFS
				//Lagspike Prevention Attempt 1
				else if (vocals.volume <= 0 && (vocals.time > FlxG.sound.music.time + 1.5 || vocals.time < FlxG.sound.music.time - 1.5))
				{
					allowHealthModifiers = false;
					Conductor.songPosition = FlxG.sound.music.time;
					vocals.time = FlxG.sound.music.time;
					//trace("BUh'd");
					allowHealthModifiers = true;
				}

				//LagSpike Compensation Attempt 2
				//if (openfl.Lib.current.stage.frameRate < frameRateLimit)
				else if ((cast(Lib.current.getChildAt(0), Main)).getFPS() < frameRateLimit && curBeat > 4)
				{
					allowHealthModifiers = false;
					compensatedViaLagSpike = true;
					//trace("Bruh'd");
				}
				else if (compensatedViaLagSpike)
					compensationTimer..start(0.8, function(tmr:FlxTimer)
					{
						allowHealthModifiers = true;
						compensatedViaLagSpike = false;
						//trace("compensated (via frames)");
					});
			//}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (camZooming && FlxG.save.data.camzoom)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.90);
		}

		#if debug
		FlxG.watch.addQuick("curBPM", Conductor.bpm);
		FlxG.watch.addQuick("Closest Note", (unspawnNotes.length != 0 ? unspawnNotes[0].strumTime - Conductor.songPosition : "No note"));

		FlxG.watch.addQuick("curBeat", curBeat);
		FlxG.watch.addQuick("curStep", curStep);
		#end

		//CHANGED FROM MULTIPLE IF STATEMENTS (see if this causes problems)
		if (startedCountdown && (health <= 0 || (FlxG.keys.justPressed.R && FlxG.save.data.resetButton)) && 
		(!cannotDie && !resultsPresent && !inResults && !inCutscene && !PlayStateChangeables.botPlay && !usedTimeTravel))
			literallyFuckingDie();

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
			fancySongUpdate();

		if (FlxG.save.data.cpuStrums)
		{
			cpuStrums.forEach(function(spr:FlxSprite)
			{
				if (spr.animation.finished)
				{
					spr.animation.play('static');
					spr.centerOffsets();
				}
			});
		}

		if (!inCutscene && songStarted)
			keyShit();
	}

	function camShakeFinish():Void
	{
		//trace("FinishedCamShake");
		isEarthquake = false;
		FlxG.camera.followLerp = prevCamFollowSpeed;
		triggeredCamShake = false;
	}

	function fancySongUpdate():Void
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
			if (!daNote.modifiedByLua)
			{
				if (PlayStateChangeables.useDownscroll)
				{
					if (daNote.mustPress)
						daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
							+ 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
								2)) - daNote.noteYOff;
					else
						daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
							+ 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
								2)) - daNote.noteYOff;
					if (daNote.isSustainNote)
					{
						// Remember = minus makes notes go up, plus makes them go down
						if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
							daNote.y += daNote.prevNote.height;
						else
							daNote.y += daNote.height / 2;

						// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
						if (!PlayStateChangeables.botPlay)
						{
							//(!daNote.mustPress || && !daNote.canBeHit) && daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2)
							if (!daNote.mustPress || (daNote.sustainActive && holdArray[Math.floor(Math.abs(daNote.noteData))]))
							{
								// Clip to strumline
								var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
								swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}
						else
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
							swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								+ Note.swagWidth / 2
								- daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
				}
				else
				{
					if (daNote.mustPress)
						daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
							- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
								2)) + daNote.noteYOff;
					else
						daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
							- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
								2)) + daNote.noteYOff;
					if (daNote.isSustainNote)
					{
						daNote.y -= daNote.height / 2;

						if (!PlayStateChangeables.botPlay)
						{
							//(!daNote.mustPress || && !daNote.canBeHit) && daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2)
							if (!daNote.mustPress || (daNote.sustainActive && holdArray[Math.floor(Math.abs(daNote.noteData))]))
							{
								// Clip to strumline
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.height -= swagRect.y;

								daNote.clipRect = swagRect;
							}
						}
						else
						{
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								+ Note.swagWidth / 2
								- daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}
					}
				}
			}

			if (!daNote.mustPress && !daNote.tooLate && daNote.wasGoodHit)
			{		
				var altAnim:String = "";
				var enemyMissRandomizer:Bool = false;

				if (SONG.notes[Math.floor(curStep / 16)] != null)
				{
					if (SONG.notes[Math.floor(curStep / 16)].altAnim)
						altAnim = '-alt';
				}
				
				// Accessing the animation name directly to play it
				var singData:Int = Std.int(Math.abs(daNote.noteData));

				//EnemyMiss Shit
				switch (SONG.song)
				{
					case "Sudden Confrontation":
						trace ("Enemy miss is " + enemyMissRandomizer);
						if (!daNote.isSustainNote && enemyCanFail)
							enemyMissRandomizer = FlxG.random.bool(accuracy / 8);
						
						if (enemyMissRandomizer && SONG.notes[Math.floor(curStep / 16)] != null && !SONG.notes[Math.floor(curStep / 16)].altAnim)
							enemyMiss(dataSuffix[singData]);
						else
						{
							miscs.volume = 1;
							//"Enemy Sing" health drain
							if (healthBar.percent >= 25 && allowHealthModifiers)
								health += PlayStateHealthModifiers.ModifyHealth(storyDifficulty, 10, health, accuracy);
						}
				}

				//Weird double anim prevention attempt?
				if (!enemyMissRandomizer && daNote.noteStyle != 'mine' && (!dad.animation.curAnim.name.startsWith("sing") || dad.animation.curAnim.curFrame >= 1))
					dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);
				trace ("NOW nemy miss is " + enemyMissRandomizer);

				if (FlxG.save.data.cpuStrums)
				{
					cpuStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(daNote.noteData) == spr.ID && !enemyMissRandomizer && daNote.noteStyle != 'mine')
						{
							trace ("NOW now enemy miss is " + enemyMissRandomizer);
							spr.animation.play('confirm', true);
						}
						if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
						{
							spr.centerOffsets();
							spr.offset.x -= 13;
							spr.offset.y -= 13;
						}
						else
							spr.centerOffsets();
					});
				}

				#if windows
				if (luaModchart != null)
					luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
				#end

				dad.holdTimer = 0;

				if (SONG.needsVoices)
					vocals.volume = 1;

				trace ("OK NOW enemy miss is " + enemyMissRandomizer);
				if (!enemyMissRandomizer)
				{
					daNote.active = false;
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
					trace('deleted nenemy note. The fucker missed = ' + enemyMissRandomizer);
					//OK so it aint deleting the note, find out why.
				}
			}

			if (daNote.mustPress && !daNote.modifiedByLua)
			{
				daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
				daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
				if (!daNote.isSustainNote)
					daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
				if (daNote.sustainActive)
					daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
				daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
			}
			else if (!daNote.wasGoodHit && !daNote.modifiedByLua)
			{
				daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
				daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
				if (!daNote.isSustainNote)
					daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
				if (daNote.sustainActive)
					daNote.alpha = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].alpha;
				daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].angle;
			}

			if (daNote.isSustainNote)
			{
				daNote.x += daNote.width / 2 + 20;
				if (PlayState.curStage.startsWith('school'))
					daNote.x -= 11;
			}

			if (daNote.mustPress && daNote.tooLate)
			{
				if (daNote.isSustainNote && daNote.wasGoodHit)
				{
					daNote.kill();
					notes.remove(daNote, true);
					//trace ('deleted sus note');
				}
				else
				{
					if (daNote.noteStyle == 'mine' && theFunne && !daNote.isSustainNote)
					{
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
					}
					else if (daNote.noteStyle == 'trigger' && theFunne && !daNote.isSustainNote)
					{
						if (allowHealthModifiers)
						{
							camShake = true;
							isEarthquake = true;
							FlxG.sound.play(Paths.sound('Note_Mine'));
							boyfriend.playAnim('hurt', true);
							hurtVignette.alpha = 1;
							//la health drain for failed trigger	
							if (health > 0.7 && timesShot <= 2)
								health = 0.4;
							else if (health < 0.7 && timesShot <= 2)
								health -= 0.2;
							else if (timesShot == 3)
								health -= 10;
							if (theFunne && !daNote.isSustainNote)
								noteMiss(daNote.noteData, daNote);
							totalNotesHit -= 1;
							timesShot++;
							//trace(timesShot + ' bullet/s eaten');
						}
					}
					else
					{
						if (!daNote.isSustainNote)
						{
							//Health Drain for Non-Sustain
							if (allowHealthModifiers || hurtVignette.alpha < 0.2)
								health += PlayStateHealthModifiers.ModifyHealth(storyDifficulty, 0, health, accuracy);
						}
						vocals.volume = 0;
						if (theFunne && !daNote.isSustainNote)
							noteMiss(daNote.noteData, daNote);

						if (daNote.isParent && daNote.visible)
							{
								// give a health punishment for failing a LN
								//Heath Drain for Sustain
								if (allowHealthModifiers || hurtVignette.alpha < 0.2)
									health += PlayStateHealthModifiers.ModifyHealth(storyDifficulty, 1, health, accuracy);
								totalNotesHit -= 1;
								//trace("hold fell over at the start");
								for (i in daNote.children)
								{
									i.alpha = 0.3;
									i.sustainActive = false;
								}
							}
							else
							{
								//Health Drain for Sustain Children
								if (allowHealthModifiers)
									health += PlayStateHealthModifiers.ModifyHealth(storyDifficulty, 2, health, accuracy);
								if (!daNote.wasGoodHit
									&& daNote.isSustainNote
									&& daNote.sustainActive
									&& daNote.spotInLine != daNote.parent.children.length)
								{
									//trace("hold fell over at " + daNote.spotInLine);
									for (i in daNote.parent.children)
									{
										i.alpha = 0.3;
										i.sustainActive = false;
									}
									if (daNote.parent.wasGoodHit)
									{
										if (combo > 5 || misses < 1)
											misses++;
										totalNotesHit -= 1;
									}
									vocals.volume = 0;
									updateAccuracy();
								}
								else if (!daNote.wasGoodHit && !daNote.isSustainNote)
								{
									//Health Drain for... uhhh idk??
									if (allowHealthModifiers)
										health += PlayStateHealthModifiers.ModifyHealth(storyDifficulty, 3, health, accuracy);
								}
							}
					}
				}

				daNote.visible = false;
				daNote.kill();
				notes.remove(daNote, true);
				//trace ('deleted non sus note');
			}
			if (!daNote.mustPress && daNote.tooLate)
			{
				daNote.visible = false;
				daNote.kill();
				notes.remove(daNote, true);
				trace('removed via the too late thing');
			}
		});
	}

	function endSong():Void
	{
		if (!resultsPresent)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			/*if (useVideo)
			{
				GlobalVideo.get().stop();
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				PlayState.instance.remove(PlayState.instance.videoSprite);
			}*/
			endedSong = true;

			if(hasSubtitles && subtitleText.exists)
			{
				subtitleText.kill();
				subtitleText.destroy();
				if(subtitleTimer != null)
				{
					subtitleTimer.destroy();
				}
			}

			campaignMisses += misses;

			playedCutscene = false;
			cannotDie = false;

			if (FlxG.save.data.pauseOnUnfocus)
			{
				FlxG.autoPause = false;

				//FlxG.stage.window.onFocusOut.remove(focusOut);
				//FlxG.stage.window.onFocusIn.remove(focusIn);
			}

			//if (!loadRep)
			if (!skippedShit && FlxG.save.data.scoreScreen)
				rep.SaveReplay(saveNotes, saveJudge, replayAna);
			//if (!loadRep)
			//{
			PlayStateChangeables.botPlay = false;
			PlayStateChangeables.scrollSpeed = 1;
			PlayStateChangeables.useDownscroll = false;
			//}

			if (FlxG.save.data.fpsCap > 290)
				(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

			#if windows
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end

			canPause = false;
			//paused = true;
			FlxG.sound.music.volume = 0;
			vocals.volume = 0;

			switch (SONG.song)
			{
				case "Playing With Fire" | "Variegated Skylines" | "Sudden Confrontation":
					miscs.volume = 0;
					miscs.pause();
					//trace ("Paused Miscs");
			}

			FlxG.sound.music.pause();

			persistentUpdate = true;
			persistentDraw = true;

			vocals.pause();
			if (SONG.validScore && !toggledPracticeMode)
			{
				// adjusting the highscore song name to be compatible
				// would read original scores if we didn't change packages
				var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");
				//trace(PlayState.SONG.song + ' = ' + songScore);

				#if !switch
				Highscore.saveScore(songHighscore, Math.round(songScore), storyDifficulty);
				Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
				#end
			}

			if (offsetTesting)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
				Conductor.changeBPM(102);
				offsetTesting = false;
				LoadingState.loadAndSwitchState(new OptionsMenu());
				FlxG.save.data.offset = offsetTest;
			}
			else
			{
				if (isStoryMode)
				{
					campaignScore += Math.round(songScore);
					campaignAccuracy = campaignAccuracy / campAccDivider;

					storyPlaylist.remove(storyPlaylist[0]);

					hasReset = false;

					if (storyPlaylist.length <= 0)
					{
						transIn = FlxTransitionableState.defaultTransIn;
						transOut = FlxTransitionableState.defaultTransOut;

						PauseSubState.randomMusicTime = false;

						//CHANGE THIS SHIT INTO A SWITCH STATEMENT LOL
						//Done! I dunno if this shit'll still work but oh well!
						if (!FlxG.save.data.video && !toggledPracticeMode)
						{	
							allowHeartBeatSounds = false;
							//paused = true;
							//End Song Cutscenes							
							playEndCutscene();
						}
						else
						{
							camHUD.visible = true;
							camHUD.alpha = 1;
							switch (SONG.song)
							{
								case "Playing With Fire" | "Variegated Skylines" | "Sudden Confrontation":
									miscs.stop();
									//trace ("Stopped Miscs");
							}
							FlxG.sound.music.stop();
							FlxG.sound.music.autoDestroy = true;
							FlxG.sound.music.endTime = 0;
							FlxG.sound.music.volume = 0;
							vocals.stop();
							if (FlxG.save.data.scoreScreen && !resultsPresent)
							{
								if (!finishedHUDFadeOutFunction)
									fadeOutGameplayHUD(1);

								openSubState(new ResultsScreen());
								resultsPresent = true;
								new FlxTimer().start(1, function(tmr:FlxTimer)
								{
									inResults = true;
								});
							}
							//Placeholder For Final Song (2)
							else if (SONG.song.toLowerCase() == "thorns" && !toggledPracticeMode)
							{
								/*Clearing of campaign accuracy and resetting of bools
								toggledPracticeMode = false;
								campaignMisses = 0;
								campaignAccuracy = 0.00;
								campAccDivider = 0;*/
								FlxG.switchState(new Credits());
							}
							else
							{
								//Clearing of campaign accuracy and resetting of bools
								toggledPracticeMode = false;
								campaignMisses = 0;
								campaignAccuracy = 0.00;
								campAccDivider = 0;
								FlxG.switchState(new StoryMenuState());
							}
						}

						#if windows
						if (luaModchart != null)
						{
							luaModchart.die();
							luaModchart = null;
						}
						#end

						if (SONG.validScore && !toggledPracticeMode)
						{
							NGio.unlockMedal(60961);
							Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
							Highscore.saveWeekCombo(storyWeek, Ratings.GenerateLetterRank(campaignAccuracy), storyDifficulty);

							StoryMenuState.unlockNextWeek(storyWeek);
						}
					}
					else
					{
						campaignScore = songScore;
						campaignAccuracy = accuracy;
						// adjusting the song name to be compatible
						var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");

						var poop:String = Highscore.formatSong(songFormat, storyDifficulty);

						trace('LOADING NEXT SONG');
						//trace(poop);

						if (!skippedShit)
						{
							FlxTransitionableState.skipNextTransIn = true;
							FlxTransitionableState.skipNextTransOut = true;
						}
						prevCamFollow = camFollow;

						PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0]);

						switch (SONG.song)
						{
							case "Playing With Fire" | "Variegated Skylines" | "Sudden Confrontation":
								miscs.stop();
								//trace ("Stopped Miscs");
						}
						
						FlxG.sound.music.stop();
						FlxG.sound.music.autoDestroy = true;
						FlxG.sound.music.endTime = 0;
						FlxG.sound.music.volume = 0;
						vocals.stop();

						//FlxG.bitmap.clearCache();

						LoadingState.loadAndSwitchState(new PlayState());
					}
				}
				else
				{
					trace('WENT BACK TO FREEPLAY');

					PauseSubState.randomMusicTime = false;

					//paused = true;

					switch (SONG.song)
					{
						case "Playing With Fire" | "Variegated Skylines" | "Sudden Confrontation":
							miscs.stop();
							//trace ("Stopped Miscs");
					}
					FlxG.sound.music.stop();
					vocals.stop();

					if (FlxG.save.data.scoreScreen && !resultsPresent)
					{
						if (!finishedHUDFadeOutFunction)
							fadeOutGameplayHUD(1);
						
						FlxTransitionableState.skipNextTransOut = true;
						openSubState(new ResultsScreen());
						resultsPresent = true;
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							inResults = true;
						});
					}
					else
					{
						FlxG.sound.music.autoDestroy = true;
						FlxG.switchState(new FreeplayState());
						FlxG.sound.music.endTime = 0;
						FlxG.sound.music.volume = 0;
					}
				}
			}
		}
	}

	function playEndCutscene():Void
	{
		switch (SONG.song)
		{
			case "Playing With Fire" | "Variegated Skylines" | "Sudden Confrontation":
				miscs.stop();
				//trace ("Stopped Miscs");
		}
		FlxG.sound.music.stop();
		FlxG.sound.music.autoDestroy = true;
		FlxG.sound.music.endTime = 0;
		FlxG.sound.music.volume = 0;
		vocals.stop();
		/*if (FlxG.sound.music.playing)
			trace("BRO MUSIC PLAYING?!");
		else
			trace("BRO NO MUSIC PLAYING?!");*/

		FlxTransitionableState.skipNextTransOut = true;
		
		switch (SONG.song.toLowerCase())
		{
			case 'up and beyond':		
				if (FlxG.save.data.scoreScreen)
				{
					inCutscene = true;
					video = new MP4Handler();
					video.finishCallback = function()
					{
						FlxG.switchState(new ResultsScreenAfter());
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								inResults = true;
							});		
						});
					}
					video.playVideo(Paths.video('week1/endcutscene'));
					new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						instance.clear();
						//FlxG.bitmap.clearUnused();
					});
				}
				else
				{
					inCutscene = true;
					video = new MP4Handler();
					video.finishCallback = function()
					{
						LoadingState.loadAndSwitchState(new StoryMenuState());
					}
					video.playVideo(Paths.video('week1/endcutscene'));
					new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						instance.clear();
						//FlxG.bitmap.clearUnused();
					});
				}
			case 'retaliation':
				if (FlxG.save.data.scoreScreen)
				{
					inCutscene = true;
					video = new MP4Handler();
					video.finishCallback = function()
					{
						FlxG.switchState(new ResultsScreenAfter());
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							new FlxTimer().start(1, function(tmr:FlxTimer)
							{
								inResults = true;
							});		
						});
					}
					video.playVideo(Paths.video('week2/endcutscene'));
					new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						instance.clear();
						//FlxG.bitmap.clearUnused();
					});
				}
				else
				{
					inCutscene = true;
					video = new MP4Handler();
					video.finishCallback = function()
					{
						LoadingState.loadAndSwitchState(new StoryMenuState());
					}
					video.playVideo(Paths.video('week2/endcutscene'));
					new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						instance.clear();
						//FlxG.bitmap.clearUnused();
					});
				}
			//Placeholder for Final Song, change when Final Song is added
			case 'thorns':
				inCutscene = true;
				video = new MP4Handler();
				video.finishCallback = function()
				{
					FlxG.switchState(new Credits());	
				}
				video.playVideo(Paths.video('week1/endcutscene'));
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					instance.clear();
					//FlxG.bitmap.clearUnused();
				});
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
					new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							inResults = true;
						});
				}
				else
				{
					FlxG.switchState(new StoryMenuState());
				}
		}
	}

	var endingSong:Bool = false;

	var hits:Array<Float> = [];
	var offsetTest:Float = 0;

	var timeShown = 0;
	var currentTimingShown:FlxText = null;
	var timingTween:FlxTween;

	private function popUpScore(daNote:Note = null):Void
	{
		var timingColour:FlxColor = FlxColor.WHITE;
		var noteDiff:Float;

		if (daNote != null)
			noteDiff = -(daNote.strumTime - Conductor.songPosition);
		else
			noteDiff = Conductor.safeZoneOffset; // Assumed SHIT if no note was given
		
		var wife:Float = EtternaFunctions.wife3(-noteDiff, Conductor.timeScale);
		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		coolText.y -= 350;
		coolText.cameras = [camHUD];

		var rating:FlxSprite = new FlxSprite();
		var score:Float = 350;

		if (FlxG.save.data.accuracyMod == 1)
			totalNotesHit += wife;

		var daRating = daNote.rating;

		if (allowHealthModifiers)
		{
			switch (daRating)
			{
				//To do: Add difficulty-dependent health drains as well as customization
				//uhh i already did that
				//To did: Add(ed) difficulty-dependent health drains
				//oh oop i have not done customization yet
				case 'shit':
					score = -50;
					combo = 0;
					if (combo > 5 || misses < 1)
						misses++;
					//Health Drain
					if (hurtVignette.alpha < 0.2)
						health += PlayStateHealthModifiers.ModifyHealth(storyDifficulty, 4, health, accuracy);
					ss = false;
					shits++;
					if (FlxG.save.data.accuracyMod == 0)
						totalNotesHit -= 1;
					timingColour = FlxColor.RED;
				case 'bad':
					daRating = 'bad';
					score = 0;
					//Health Drain
					if (hurtVignette.alpha < 0.2)
						health += PlayStateHealthModifiers.ModifyHealth(storyDifficulty, 5, health, accuracy);
					ss = false;
					bads++;
					if (FlxG.save.data.accuracyMod == 0)
						if (notePresses <= noteMashingThreshold)
							totalNotesHit += 0.50;
					timingColour = FlxColor.YELLOW;
				case 'good':
					daRating = 'good';
					//Health Drain/Gain
					health += PlayStateHealthModifiers.ModifyHealth(storyDifficulty, 6, health, accuracy);
					score = 200;
					ss = false;
					goods++;
					if (FlxG.save.data.accuracyMod == 0)
						if (notePresses <= noteMashingThreshold)
							totalNotesHit += 0.75;
					timingColour = FlxColor.LIME;
				case 'sick':
					//Health Gain
					health += PlayStateHealthModifiers.ModifyHealth(storyDifficulty, 7, health, accuracy, hurtVignette.alpha);
					if (FlxG.save.data.accuracyMod == 0)
						if (notePresses <= noteMashingThreshold)
							totalNotesHit += 1;
					sicks++;
					timingColour = FlxColor.CYAN;
			}
		}

		//if (daRating != 'shit' || daRating != 'bad')
		//{
			songScore += Math.round(score);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));

			var pixelShitPart1:String = "";
			var pixelShitPart2:String = '';

			if (SONG.noteStyle == 'pixel')
			{
				pixelShitPart1 = 'weeb/pixelUI/';
				pixelShitPart2 = '-pixel';
			}

			rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
			rating.screenCenter();
			rating.x = FlxG.save.data.changedHitX;
			rating.y = FlxG.save.data.changedHitY;
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);

			var msTiming = HelperFunctions.truncateFloat(noteDiff, 3);
			if (PlayStateChangeables.botPlay)
				msTiming = 0;

			//if (loadRep)
			//	msTiming = HelperFunctions.truncateFloat(findByTime(daNote.strumTime)[3], 3);

			if (currentTimingShown != null)
				remove(currentTimingShown);

			currentTimingShown = new FlxText(0, 0, 0, "0ms");
			timeShown = 0;
			currentTimingShown.color = timingColour;
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.size = 20;

			if (msTiming >= 0.03 && offsetTesting)
			{
				// Remove Outliers
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming);

				var total = 0.0;

				for (i in hits)
					total += i;

				offsetTest = HelperFunctions.truncateFloat(total / hits.length, 2);
			}

			if (currentTimingShown.alpha != 1)
				currentTimingShown.alpha = 1;

			var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			currentTimingShown.screenCenter();
			currentTimingShown.x = rating.x + 100;
			currentTimingShown.y = rating.y + 100;
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y -= 150;

			comboSpr.velocity.x += FlxG.random.int(1, 10);
			currentTimingShown.velocity.x += comboSpr.velocity.x;
			if (!PlayStateChangeables.botPlay)
			{
				add(rating);
				if (currentTimingShown.exists)
					add(currentTimingShown);
			}

			if (!curStage.startsWith('school'))
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				if(FlxG.save.data.antialiasing)
					{
						rating.antialiasing = true;
					}
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				if(FlxG.save.data.antialiasing)
					{
						comboSpr.antialiasing = true;
					}
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
			}

			currentTimingShown.updateHitbox();
			comboSpr.updateHitbox();
			rating.updateHitbox();
			
			//Note splash stuff
			if (!PlayStateChangeables.botPlay && !FlxG.save.data.notesplash)
			{
				//var sploosh:FlxSprite = new FlxSprite(daNote.x, playerStrums.members[daNote.noteData].y);
				noteSplashVFX(daNote, daRating);
				adjustVocVolOnNoteHit(daNote);
			}

			currentTimingShown.cameras = [camHUD];
			comboSpr.cameras = [camHUD];
			rating.cameras = [camHUD];

			var seperatedScore:Array<Int> = [];

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

			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
				numScore.screenCenter();
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];

				if (!curStage.startsWith('school'))
				{
					if(FlxG.save.data.antialiasing)
						{
							numScore.antialiasing = true;
						}
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				}
				else
				{
					numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
				}
				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);

				add(numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
						//if (currentTimingShown != null)
						//	currentTimingShown.alpha = 0;
					},
					startDelay: Conductor.crochet * 0.002
				});

				daLoop++;
			}

			coolText.text = Std.string(seperatedScore);

			FlxTween.tween(rating, {alpha: 0}, 0.2, {startDelay: Conductor.crochet * 0.001});
			timingTween = FlxTween.tween(currentTimingShown, {alpha: 0}, 0.2, {startDelay: Conductor.crochet * 0.001});
			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
					if (currentTimingShown != null && timeShown >= 20)
					{
						remove(currentTimingShown);
						currentTimingShown = null;
					}
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});

			curSection += 1;
		//}
	}

	function noteSplashVFX(daNote:Note, daRating:String):Void
	{
		var sploosh:FlxSprite = new FlxSprite(daNote.x, daNote.y);
		if (FlxG.save.data.distractions)
		{
			if (!curStage.startsWith('school'))
			{
				var tex:flixel.graphics.frames.FlxAtlasFrames = Paths.getSparrowAtlas('noteSplashes', 'shared');
				sploosh.frames = tex;
				sploosh.animation.addByPrefix('splash 0 0', 'note impact 1 purple', 27, false);
				sploosh.animation.addByPrefix('splash 0 1', 'note impact 1 blue', 27, false);
				sploosh.animation.addByPrefix('splash 0 2', 'note impact 1 green', 27, false);
				sploosh.animation.addByPrefix('splash 0 3', 'note impact 1 red', 27, false);
				sploosh.animation.addByPrefix('splash 1 0', 'note impact 2 purple', 26, false);
				sploosh.animation.addByPrefix('splash 1 1', 'note impact 2 blue', 26, false);
				sploosh.animation.addByPrefix('splash 1 2', 'note impact 2 green', 26, false);
				sploosh.animation.addByPrefix('splash 1 3', 'note impact 2 red', 26, false);
				sploosh.animation.addByPrefix('splash 0 mine', 'note impact 1 mine', 24, false);
				sploosh.animation.addByPrefix('splash 1 mine', 'note impact 2 mine', 23, false);
				sploosh.animation.addByPrefix('splash 0 trigger', 'note impact 1 trigger', 24, false);
				sploosh.animation.addByPrefix('splash 1 trigger', 'note impact 2 trigger', 23, false);
				sploosh.animation.addByPrefix('splash 0 shit', 'note impact 1 shit', 16, false);
				sploosh.animation.addByPrefix('splash 1 shit', 'note impact 2 shit', 16, false);
				
				if(FlxG.save.data.hqnotesploosh)
				{
					sploosh.antialiasing = true;
				}

				switch (daNote.noteStyle)
				{
					case "mine":
						sploosh.setGraphicSize(Std.int(sploosh.width * 0.9));
						add(sploosh);
						sploosh.cameras = [camHUD];
						sploosh.animation.play('splash ' + FlxG.random.int(0, 1) + " mine");
						sploosh.alpha = 1;
						sploosh.offset.x += 75;
						sploosh.offset.y += 90;
						sploosh.animation.finishCallback = function(name) sploosh.kill();
						//trace('mine sploosh');
					case "trigger":
						sploosh.setGraphicSize(Std.int(sploosh.width * 0.9));
						add(sploosh);
						sploosh.cameras = [camHUD];
						sploosh.animation.play('splash ' + FlxG.random.int(0, 1) + " trigger");
						sploosh.alpha = 0.8;
						sploosh.offset.x += 75;
						sploosh.offset.y += 90;
						sploosh.animation.finishCallback = function(name) sploosh.kill();
					default:
						switch (daRating)
						{
							case "sick":
								sploosh.setGraphicSize(Std.int(sploosh.width * 0.9));
								add(sploosh);
								sploosh.cameras = [camHUD];
								sploosh.animation.play('splash ' + FlxG.random.int(0, 1) + " " + daNote.noteData);
								sploosh.alpha = 0.6;
								sploosh.offset.x += 75;
								sploosh.offset.y += 90;
								sploosh.animation.finishCallback = function(name) sploosh.kill();
							case "shit":
								if (allowHealthModifiers)
								{
									sploosh.setGraphicSize(Std.int(sploosh.width * 0.9));
									sploosh.acceleration.y = 800;
									sploosh.velocity.y -= FlxG.random.int(140, 175);
									sploosh.velocity.x -= FlxG.random.int(0, 5);
									add(sploosh);
									sploosh.cameras = [camHUD];
									sploosh.animation.play('splash ' + FlxG.random.int(0, 1) + ' shit');
									sploosh.alpha = 0.8;
									sploosh.offset.x += 75;
									sploosh.offset.y += 90;
									sploosh.animation.finishCallback = function(name) sploosh.kill();
								}
						}
				}
			}
			else
			{
				sploosh.loadGraphic(Paths.image('weeb/pixelUI/noteSplashes-pixels', 'week6'), true, 50, 50);
				sploosh.animation.add('splash 0 0', [0, 1, 2, 3], 22, false);
				sploosh.animation.add('splash 1 0', [4, 5, 6, 7], 22, false);
				sploosh.animation.add('splash 0 1', [8, 9, 10, 11], 22, false);
				sploosh.animation.add('splash 1 1', [12, 13, 14, 15], 22, false);
				sploosh.animation.add('splash 0 2', [16, 17, 18, 19], 23, false);
				sploosh.animation.add('splash 1 2', [20, 21, 22, 23], 23, false);
				sploosh.animation.add('splash 0 3', [24, 25, 26, 27], 23, false);
				sploosh.animation.add('splash 1 3', [28, 29, 30, 31], 23, false);
				if (daRating == 'sick')
				{
					sploosh.setGraphicSize(Std.int(sploosh.width * daPixelZoom));
					sploosh.updateHitbox();
					add(sploosh);
					sploosh.cameras = [camHUD];
					sploosh.animation.play('splash ' + FlxG.random.int(0, 1) + " " + daNote.noteData);
					sploosh.alpha = 1;
					sploosh.offset.x += 90;
					sploosh.offset.y += 110;
					sploosh.animation.finishCallback = function(name) sploosh.kill();
				}
			}
		}
		else if (!FlxG.save.data.distractions)
		{
			if (!curStage.startsWith('school'))
			{
				var tex:flixel.graphics.frames.FlxAtlasFrames = Paths.getSparrowAtlas('NOTE_assets', 'shared');
				sploosh.frames = tex;
				sploosh.animation.addByPrefix('splash 0 0', 'left 1 splash', 25, false);
				sploosh.animation.addByPrefix('splash 0 1', 'down 1 splash', 25, false);
				sploosh.animation.addByPrefix('splash 0 2', 'up 1 splash', 25, false);
				sploosh.animation.addByPrefix('splash 0 3', 'right 1 splash', 25, false);
				sploosh.animation.addByPrefix('splash 1 0', 'left 2 splash', 24, false);
				sploosh.animation.addByPrefix('splash 1 1', 'down 2 splash', 24, false);
				sploosh.animation.addByPrefix('splash 1 2', 'up 2 splash', 24, false);
				sploosh.animation.addByPrefix('splash 1 3', 'right 2 splash', 24, false);
				sploosh.animation.addByPrefix('splash 2 0', 'left 2 splash', 26, false);
				sploosh.animation.addByPrefix('splash 2 1', 'down 2 splash', 26, false);
				sploosh.animation.addByPrefix('splash 2 2', 'up 2 splash', 26, false);
				sploosh.animation.addByPrefix('splash 2 3', 'right 2 splash', 26, false);
				sploosh.animation.addByPrefix('splash mine 0', 'mine note 1 splash', 24, false);
				sploosh.animation.addByPrefix('splash mine 1', 'mine note 2 splash', 25, false);
				sploosh.animation.addByPrefix('splash mine 2', 'mine note 3 splash', 26, false);
				sploosh.animation.addByPrefix('splash trigger 0', 'trigger note 1 splash', 24, false);
				sploosh.animation.addByPrefix('splash trigger 1', 'trigger note 2 splash', 25, false);
				sploosh.animation.addByPrefix('splash trigger 2', 'trigger note 3 splash', 26, false);
				
				if(FlxG.save.data.hqnotesploosh)
				{
					sploosh.antialiasing = true;
				}

				if (daNote.noteStyle == 'mine')
				{
					add(sploosh);
					sploosh.cameras = [camHUD];
					sploosh.animation.play('splash mine ' + FlxG.random.int(0, 2));
					sploosh.alpha = 0.8;
					sploosh.offset.x += 90;
					sploosh.offset.y += 75;
					sploosh.animation.finishCallback = function(name) sploosh.kill();
					//trace('mine sploosh');
				}
				else if (daNote.noteStyle == 'trigger')
				{
					add(sploosh);
					sploosh.cameras = [camHUD];
					sploosh.animation.play('splash trigger ' + FlxG.random.int(0, 2));
					sploosh.alpha = 0.8;
					sploosh.offset.x += 90;
					sploosh.offset.y += 75;
					sploosh.animation.finishCallback = function(name) sploosh.kill();
				}
				else
				{
					if (daRating == 'sick')
					{
						add(sploosh);
						sploosh.cameras = [camHUD];
						sploosh.animation.play('splash ' + FlxG.random.int(0, 2) + " " + daNote.noteData);
						sploosh.alpha = 0.8;
						sploosh.offset.x += 90;
						sploosh.offset.y += 75;
						sploosh.animation.finishCallback = function(name) sploosh.kill();
					}
				}
			}
			else
			{
				sploosh.loadGraphic(Paths.image('weeb/pixelUI/noteSplashes-pixels', 'week6'), true, 50, 50);
				sploosh.animation.add('splash 0 0', [0, 2, 3], 23, false);
				sploosh.animation.add('splash 1 0', [4, 6, 7], 23, false);
				sploosh.animation.add('splash 0 1', [8, 10, 11], 23, false);
				sploosh.animation.add('splash 1 1', [12, 14, 15], 23, false);
				sploosh.animation.add('splash 0 2', [16, 18, 19], 24, false);
				sploosh.animation.add('splash 1 2', [20, 22, 23], 24, false);
				sploosh.animation.add('splash 0 3', [24, 26, 27], 24, false);
				sploosh.animation.add('splash 1 3', [28, 30, 31], 24, false);
				if (daRating == 'sick')
				{
					sploosh.setGraphicSize(Std.int(sploosh.width * daPixelZoom));
					sploosh.updateHitbox();
					add(sploosh);
					sploosh.cameras = [camHUD];
					sploosh.animation.play('splash ' + FlxG.random.int(0, 1) + " " + daNote.noteData);
					sploosh.alpha = 0.8;
					sploosh.offset.x += 90;
					sploosh.offset.y += 110;
					sploosh.animation.finishCallback = function(name) sploosh.kill();
				}
			}
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

	// THIS FUNCTION JUST FUCKS WIT HELD NOTES AND BOTPLAY/REPLAY (also gamepad shit)

	private function keyShit():Void // I've invested in emma stocks
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		var releaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];
		//FROM 1.8
		//wow this actually made things smooth im keeping this
		var keynameArray:Array<String> = ['left', 'down', 'up', 'right'];
		#if windows
		if (luaModchart != null)
		{

			for (i in 0...pressArray.length)
			{
				if (pressArray[i] == true)
				{
					luaModchart.executeState('keyPressed', [keynameArray[i]]);
				}
			};

			for (i in 0...releaseArray.length)
			{
				if (releaseArray[i] == true)
				{
					luaModchart.executeState('keyReleased', [keynameArray[i]]);
				}
			};

			//Old Input: Testing what's faster
			/*if (controls.LEFT_P)
			{
				luaModchart.executeState('keyPressed', ["left"]);
			};
			if (controls.DOWN_P)
			{
				luaModchart.executeState('keyPressed', ["down"]);
			};
			if (controls.UP_P)
			{
				luaModchart.executeState('keyPressed', ["up"]);
			};
			if (controls.RIGHT_P)
			{
				luaModchart.executeState('keyPressed', ["right"]);
			};*/
		};
		#end

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
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && daNote.sustainActive)
				{
					//trace(daNote.sustainActive);
					goodNoteHit(daNote);
					if (FlxG.save.data.notesfx && allowNoteHitSounds)
					{
						//For Sustain Notes
						FlxG.sound.play(Paths.sound('Note_' + hitsoundType + '_Sustain'), noteHitVolume);
					}
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
						if (pressArray[coolNote.noteData] && !hit[coolNote.noteData])
						{
							//if (mashViolations != 0)
							//	mashViolations--;
							hit[coolNote.noteData] = true;
							scoreTxt.color = FlxColor.WHITE;
							var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
							anas[coolNote.noteData].hit = true;
							anas[coolNote.noteData].hitJudge = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
							anas[coolNote.noteData].nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
							goodNoteHit(coolNote);
						}
					}
				};
				
				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
				{
					if (((boyfriend.animation.curAnim.name.startsWith('sing') && boyfriend.animation.curAnim.curFrame >= 10) && ((boyfriend.animation.curAnim.name != "hurt" && !boyfriend.animation.curAnim.name.startsWith("dodge")) || boyfriend.animation.curAnim.finished)) && !boyfriend.animation.curAnim.name.endsWith('miss'))
					//{
						boyfriend.playAnim('idleHOLD');
						//trace("Idle (line 5553)");
					//}
				}
				else if (!FlxG.save.data.ghost)
				{
					for (shit in 0...pressArray.length)
						if (pressArray[shit])
							noteMiss(shit, null);
				}
			}

			//if (!loadRep)
			for (i in anas)
				if (i != null)
					replayAna.anaArray.push(i); // put em all there
		}
		notes.forEachAlive(function(daNote:Note)
		{
			if (PlayStateChangeables.useDownscroll && daNote.y > strumLine.y || !PlayStateChangeables.useDownscroll && daNote.y < strumLine.y)
			{
				// Force good note hit regardless if it's too late to hit it or not as a fail safe
				if (PlayStateChangeables.botPlay && daNote.canBeHit && daNote.mustPress || PlayStateChangeables.botPlay && daNote.tooLate && daNote.mustPress)
				{
					/*if (loadRep)
					{
						// trace('ReplayNote ' + tmpRepNote.strumtime + ' | ' + tmpRepNote.direction);
						var n = findByTime(daNote.strumTime);
						trace(n);
						if (n != null)
						{
							goodNoteHit(daNote);
							boyfriend.holdTimer = daNote.sustainLength;
						}
					}
					else
					{*/
						goodNoteHit(daNote);
						boyfriend.holdTimer = daNote.sustainLength;
					//}
				}
			}
		});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
		{
			if (((boyfriend.animation.curAnim.name.startsWith('sing') && boyfriend.animation.curAnim.curFrame >= 10) && ((boyfriend.animation.curAnim.name != "hurt" && !boyfriend.animation.curAnim.name.startsWith("dodge")) || boyfriend.animation.curAnim.finished)) && !boyfriend.animation.curAnim.name.endsWith('miss'))
			//{
				boyfriend.playAnim('idleHOLD');
				//trace("Idle (line 5601)");
			//}
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			if (keys[spr.ID] && spr.animation.curAnim.name != 'confirm' && spr.animation.curAnim.name != 'pressed')
				spr.animation.play('pressed');
			if (!keys[spr.ID])
				spr.animation.play('static');

			if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
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

	public var fuckingVolume:Float = 1;
	//public var useVideo = false;

	public static var webmHandler:WebmHandler;

	public var playingDathing = false;

	//Making this void (3)
	//Removing de shits
	/*public function focusOut():Void
	{
		if (paused)
			return;
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.pause();
			vocals.pause();
		}

		openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		if (FlxG.save.data.pauseOnUnfocus && FlxG.autoPause && !inSubstate && songStarted && !resultsPresent)
		{
			//FlxG.sound.music.pause();
			paused = true;
			persistentUpdate = false;
			trace ("focusOut");
		}
	}

	public function focusIn()
	{
		if (FlxG.save.data.pauseOnUnfocus && FlxG.autoPause && !inSubstate && songStarted && !resultsPresent)
		{
			//FlxG.sound.music.play();
			paused = false;
			persistentUpdate = true;
			trace ("focusIn");
		}
		// nada
	}*/

	/*public function backgroundVideo(source:String) // for background videos
	{
		#if cpp
		useVideo = true;

		FlxG.stage.window.onFocusOut.add(focusOut);
		FlxG.stage.window.onFocusIn.add(focusIn);

		var ourSource:String = "assets/videos/daWeirdVid/dontDelete.webm";
		var str1:String = "WEBM SHIT";
		webmHandler = new WebmHandler();
		webmHandler.source(ourSource);
		webmHandler.makePlayer();
		webmHandler.webm.name = str1;

		GlobalVideo.setWebm(webmHandler);

		GlobalVideo.get().source(source);
		GlobalVideo.get().clearPause();
		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().updatePlayer();
		}
		GlobalVideo.get().show();

		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().restart();
		}
		else
		{
			GlobalVideo.get().play();
		}

		var data = webmHandler.webm.bitmapData;

		videoSprite = new FlxSprite(-470, -30).loadGraphic(data);

		videoSprite.setGraphicSize(Std.int(videoSprite.width * 1.2));

		remove(gf);
		remove(boyfriend);
		remove(dad);
		add(videoSprite);
		add(gf);
		add(boyfriend);
		add(dad);

		trace('poggers');

		if (!songStarted)
			webmHandler.pause();
		else
			webmHandler.resume();
		#end
	}*/

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		//trace("note miss!!");
		if (!boyfriend.stunned && allowHealthModifiers)
		{
			if (combo > 5)
			{
				if (gf.animOffsets.exists('sad') && curSong != "Mic Test")
					gf.playAnim('sad');
				else if (dad.animOffsets.exists('sad') && curSong == "Mic Test")
					dad.playAnim('sad');
				misses++;
			}
			else if (misses < 1)
				misses++;
			combo = 0;

			saveNotes.push([
				daNote.strumTime,
				0,
				direction,
				166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166
			]);
			saveJudge.push("miss");

			if (FlxG.save.data.accuracyMod == 1 && daNote.noteStyle != 'mine')
				totalNotesHit -= 1;

			if (!daNote.isSustainNote && daNote != null && daNote.noteStyle != 'mine')
				songScore -= 300;

			//NOTE MISS SOUND
			if(FlxG.save.data.missSounds && daNote.noteStyle != 'mine')
			{
				missSound = FlxG.sound.play(Paths.soundRandom('missnote', 1, 3));
				missSound.volume = FlxG.random.float(0.2, 0.3);
			}

			//FlxG.sound.list.add(missSound);

			// Whole switch statement replaced with a single line :)
			if ((boyfriend.animation.curAnim.name != 'hurt' && !boyfriend.animation.curAnim.name.startsWith("dodge")) || boyfriend.animation.curAnim.curFrame >= 3)
				boyfriend.playAnim('sing' + dataSuffix[direction] + 'miss', true);

			//trace("BUH NOTE MISS PLAY ANIM HERE");

			#if cpp
			if (luaModchart != null)
				luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
			#end

			updateAccuracy();
		}
	}

	function enemyMiss(noteDirection):Void
	{
		dad.playAnim('sing' + noteDirection + "miss", true);
		miscs.volume = 0;
		if(FlxG.save.data.missSounds)
		{
			missSound = FlxG.sound.play(Paths.soundRandom('enemyMiss', 1, 3));
			missSound.volume = FlxG.random.float(0.25, 0.35);
		}
		
		if (healthBar.percent < 85)
			health += PlayStateHealthModifiers.ModifyHealth(storyDifficulty, 9, health, accuracy);
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

	var notePresses:Int = 0;
	//number after defaultmashingthreshold is the mashing limit
	var defaultMashingThreshold:Int = 20;
	//Threshold is set by goodNoteHit(); and is reset by fancyNoteUpdate();
	var noteMashingThreshold:Int = 20;
	//My attempt at an anti-mash system (dreamedwave (that's me))

	/*function getPossibleKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		trace ("PossibleKeyPresses " + possibleNotes.length);
		return possibleNotes.length;
	}

	Let's try removing this, is this even used or--
	var mashing:Int = 0;
	var mashViolations:Int = 0;*/
	//Removed cause it wasn't really used lol

	/*var etternaModeScore:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
	{
		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));

		if (controlArray[note.noteData])
		{
			//goodNoteHit(note, (mashing > getKeyPresses(note)));
			goodNoteHit(note);
		}
	}*/

	function loadFinaleMusic():Void
	{
		if (deaths <= 0 && !hasReset)
		{
			var soundNameArr:Array<String> = ["drums_0", "drums_1", "drums_2", "drums_3", "drums_climax", "taiko_0", "taiko_1", "taiko_2", "taiko_3", 
			"taiko_4", "taiko_5", "choir_0", "choir_1", "hats_0", "hats_1", "woodwinds", "violin", "slayer_0", "slayer_1", "slayer_climax", "retal-hats_0", 
			"retal-hats_1", "bells_0", "bells_1", "pads_0", "pads_1", "pads_climax", "pads_climax_bosslowhp", "elecpiano_climax", "danger-loop", "stab"]; //THANK YOU BSOD#2524 FROM HAXE DISCORD SERVER!!!!
			for (i in soundNameArr) 
				FlxG.sound.load(Paths.sound("finaleAdaptiveMus/" + i));
			trace("Preloaded Finale Shit");
		}
	}

	function loadNoteHitSound():Void
	{
		if (PlayStateChangeables.botPlay)
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
			{
				FlxG.sound.load(Paths.sound(i));
				trace("Loaded Hit SFX: " + i);
			}
		}
		else
			FlxG.sound.load(Paths.sound("Note_botplay"));

		trace('Preloaded Hit Sounds');
	}

	//Making this void (5)
	function playNoteHitSound(note:Note):Void
	{
		var rating = note.rating;
		//FLXTIMER to prevent it from playing 2 at once
		//nOPE ya got soundlist for that shit!
		//nOPE!!
		//new FlxTimer().start(0.003, function(tmr:FlxTimer)
		//{
		//	SFX for hitting notes (such as SICK, GOOD, BAD, SHIT, and SPECIAL NOTEs);
		if (hitsoundType != 'botplay')
		{
			//Converted from nested if-else statements and 2 switch statements to a one switch! You're welcome!
			switch (rating)
			{
				case 'sick':
					//For Sick Rating
					FlxG.sound.play(Paths.sound("Note_" + hitsoundType + "_Sick"), noteHitVolume);
					//Vocal Shit
					vocals.volume = 1;
				case 'good':
					//For Good Rating
					FlxG.sound.play(Paths.sound("Note_" + hitsoundType + "_Good"), noteHitVolume);
					//Vocal Shit
					vocals.volume = 0.85;
				case 'bad':
					//For Bad Rating
					FlxG.sound.play(Paths.sound("Note_" + hitsoundType + "_Bad"), noteHitVolume);
					//Vocal Shit
					vocals.volume = 0.55;
				case 'shit':
					//For Shit Rating
					FlxG.sound.play(Paths.sound("Note_" + hitsoundType + "_Crap"), noteHitVolume);
					//Vocal Shit
					vocals.volume = 0.1;
			}
		}
		else if (hitsoundType == 'botplay')
		{
			FlxG.sound.play(Paths.sound("Note_botplay"), noteHitVolume);
		}
		//});
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
					vocals.volume = 0.85;
				case 'bad':
					//For Bad Rating
					//Vocal Shit
					vocals.volume = 0.55;
				case 'shit':
					//For Shit Rating
					//Vocal Shit
					vocals.volume = 0.1;
			}
		}
		else if (PlayStateChangeables.botPlay)
		{
			vocals.volume = 1;
		}
		//});
	}

	function goodNoteHit(note:Note):Void
	//(note:Note, resetMashViolation = true)
	{
		//if (mashing != 0)
		//	mashing = 0;

		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		/*if (loadRep)
		{
			noteDiff = findByTime(note.strumTime)[3];
			note.rating = rep.replay.songJudgements[findByTimeIndex(note.strumTime)];
		}
		else*/
		note.rating = Ratings.CalculateRating(noteDiff);

		if (note.rating == "miss")
			return;

		// add newest note to front of notesHitArray
		// the oldest notes are at the end and are removed first
		if (!note.isSustainNote)
		{
			if (note.noteStyle != 'mine')
			{
				combo += 1;
				notesHitArray.unshift(Date.now());
				popUpScore(note);
				/*Note hit sound function ()
				if (allowNoteHitSounds)
					playNoteHitSound(note);*/
				//This line of code was written before I die probably, If i die because of getting canceled on twitter because of politics please remember my name
				//MY    NAME      IS        SA kml km ,,   /
			}
			else
				noteSplashVFX(note, note.rating);
		}

		//if (!resetMashViolation && mashViolations >= 1)
		//	mashViolations--;

		//if (mashViolations < 0)
		//	mashViolations = 0;

		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				//popUpScore(note);
				//Note hit sound function
				noteMashingThreshold++;
				if (allowNoteHitSounds && FlxG.save.data.notesfx)
					playNoteHitSound(note);
				else
					adjustVocVolOnNoteHit(note);
			}
			else
			{
				//Health Gain for Sustain
				if (allowHealthModifiers)
					health += PlayStateHealthModifiers.ModifyHealth(storyDifficulty, 8, health, accuracy);
				vocals.volume = 1;
				if (notePresses <= noteMashingThreshold)
					totalNotesHit += 1;
			}

			switch (note.noteStyle)
			{
				case 'mine':
					if (!PlayStateChangeables.botPlay && allowHealthModifiers)
					{
						FlxG.sound.play(Paths.sound('Note_Mine'));
						boyfriend.playAnim('hurt', true);
						camShake = true;
						isEarthquake = true;
						hurtVignette.alpha = 1;
						songScore -= 500;
						//misses++;
						//la health drain for mine notes
						if (health > 0.7 && timesShot <= 2)
							health = 0.4;
						else if (health < 0.7 && timesShot <= 2)
							health -= 0.2;
						else if (timesShot == 3)
							health -= 10;
						//if (theFunne && !note.isSustainNote)
						//	noteMiss(note.noteData, note);
						totalNotesHit -= 1;
						timesShot++;
						//trace(timesShot + ' bullet/s eaten');
					}
				case 'trigger':
					FlxG.sound.play(Paths.sound('Note_Trigger'), 0.75);
					if (FlxG.save.data.accuracyMod == 0)
						if (notePresses <= noteMashingThreshold)
							totalNotesHit += 1;
					sicks++;
					//la health gain for trigger notes
					health += PlayStateHealthModifiers.ModifyHealth(storyDifficulty, 11, health, accuracy);
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
					camShake = true;
				default:
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

			#if windows
			if (luaModchart != null)
				luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
			#end

			if (note.mustPress)
			{
				var array = [note.strumTime, note.sustainLength, note.noteData, noteDiff];
				if (note.isSustainNote)
					array[1] = -1;
				saveNotes.push(array);
				saveJudge.push(note.rating);
			}

			if (note.noteStyle != 'mine')
			{
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.animation.play('confirm', true);
					}
				});
			}

			note.kill();
			notes.remove(note, true);
			note.destroy();

			updateAccuracy();
		}
	}

	function pauseGame():Void
	{
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		// 3 / 1000 chance for Gitaroo Man easter egg
		if (FlxG.random.bool(0.1))
		{
			//TURN THIS INTO A SUBSTATE!!!
			trace('GITAROO MAN EASTER EGG');
			FlxG.switchState(new GitarooPause());
		}
		else
		{
			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}
	}

	function literallyFuckingDie():Void
	{
		boyfriend.stunned = true;

		persistentUpdate = false;
		persistentDraw = false;
		paused = true;
		died = true;

		deaths++;
		hasReset = true;

		vocals.stop();
		switch (SONG.song)
		{
			case "Playing With Fire" | "Variegated Skylines" | "Sudden Confrontation":
				miscs.stop();
			case "Finale":
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
		FlxG.sound.music.stop();

		openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
	}

	/*var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		if (FlxG.save.data.distractions)
		{
			trainMoving = true;
			if (!trainSound.playing)
				trainSound.play(true);
		}
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (FlxG.save.data.distractions)
		{
			if (trainSound.time >= 4700)
			{
				startedMoving = true;
				gf.playAnim('hairBlow');
			}

			if (startedMoving)
			{
				phillyTrain.x -= 400;

				if (phillyTrain.x < -2000 && !trainFinishing)
				{
					phillyTrain.x = -1150;
					trainCars -= 1;

					if (trainCars <= 0)
						trainFinishing = true;
				}

				if (phillyTrain.x < -4000 && trainFinishing)
					trainReset();
			}
		}
	}

	function trainReset():Void
	{
		if (FlxG.save.data.distractions)
		{
			gf.playAnim('hairFall');
			phillyTrain.x = FlxG.width + 200;
			trainMoving = false;
			// trainSound.stop();
			// trainSound.time = 0;
			trainCars = 8;
			trainFinishing = false;
			startedMoving = false;
		}
	}*/

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('glitch_', 1, 2));

		if (FlxG.save.data.flashing)
		{
			theBorderBG.animation.play('lightning');
		}
		else
		{
			theBorderBG.animation.play('glitch');
		}

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(16, 32);

		boyfriend.playAnim('scared', true);
		dad.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	//var danced:Bool = false;

	override function stepHit()
	{
		cityLightTimeShit = 1000 - 1000 * Conductor.bpm * 0.001;

		var newScroll = PlayStateChangeables.scrollSpeed;

		for(i in SONG.eventObjects)
		{
			switch(i.type)
			{
				case "Scroll Speed Change":
					if (i.position < curDecimalBeat)
						newScroll = i.value;
			}
		}

		PlayStateChangeables.scrollSpeed = newScroll;

		super.stepHit();

		//Moved from BeatHit
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			if (!resultsPresent && !inCutscene && songStarted && !endedSong)
				resyncVocals();
		}

		#if windows
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curStep', curStep);
			luaModchart.executeState('stepHit', [curStep]);
		}
		#end

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			// Make sure Girlfriend cheers only for certain songs
			if (allowedToHeadbang && !resultsPresent)
			{
				// Don't animate GF if something else is already animating her (eg. train passing)
				if (gf.animation.curAnim.name == 'danceLeft'
					|| gf.animation.curAnim.name == 'danceRight'
					|| gf.animation.curAnim.name == 'idle')
				{
					// Per song treatment since some songs will only have the 'Hey' at certain times
					switch (curSong)
					{
						case 'Philly Nice':
							{
								// General duration of the song
								if (curBeat < 250)
								{
									// Beats to skip or to stop GF from cheering
									if (curBeat != 184 && curBeat != 216)
									{
										if (curBeat % 16 == 8)
										{
											// Just a garantee that it'll trigger just once
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Tech. Difficulties':
							{
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
							}
						case 'Awkward Pauses':
							{
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
												triggeredAlready = true;
											}
										}
										else 
											triggeredAlready = false;
									}
								}
							}
						case 'Blammed':
							{
								if (curBeat > 30 && curBeat < 190)
								{
									if (curBeat < 90 || curBeat > 128)
									{
										if (curBeat % 4 == 2)
										{
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Cocoa':
							{
								if (curBeat < 170)
								{
									if (curBeat < 65 || curBeat > 130 && curBeat < 145)
									{
										if (curBeat % 16 == 15)
										{
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'Eggnog':
							{
								if (curBeat > 10 && curBeat != 111 && curBeat < 220)
								{
									if (curBeat % 8 == 7)
									{
										if (!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
					}
				}
			}
			camFollowShit();
		}
	}

	//Removed from void, does this fix camfollowing?
	//No
	function camFollowShit():Void
	{	
		//if (camFollowSpeed != 0.04)
		if (FlxG.camera.followLerp != camFollowSpeed * (30 / FlxG.save.data.fpsCap))
		{
			FlxG.camera.followLerp = camFollowSpeed * (30 / FlxG.save.data.fpsCap);
			trace("CamFollowLerp is now " + FlxG.camera.followLerp);
		}
		//might cause lag ugh
		//from beathit() function

		#if windows
		if (luaModchart != null)
			luaModchart.setVar("mustHit", PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
		#end

		if (camFollow.x != dad.getMidpoint().x + 150 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
		{
			var offsetX = 0;
			var offsetY = 0;
			#if windows
			if (luaModchart != null)
			{
				offsetX = luaModchart.getVar("followXOffset", "float");
				offsetY = luaModchart.getVar("followYOffset", "float");
			}
			#end

			
			//Mashing Detection Reset
			if (notePresses != 0 && noteMashingThreshold != defaultMashingThreshold)
			{
				noteMashingThreshold = defaultMashingThreshold;
				notePresses = 0;
				//trace ("Reset Mashing SHit");
			}

			if (timesShot > 0)
				timesShot = 0;

			if (camFollowing && !camShake && !triggeredCamShake)
			{
				//trace("CamFollowSpeed = " + camFollowSpeed);

				if (curSong == 'Mic Test' && !PlayStateChangeables.Optimize)
					camTween = FlxTween.tween(FlxG.camera, {zoom: 1.5}, (Conductor.stepCrochet * 4 / 850), {ease: FlxEase.elasticInOut});

				camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
				//trace("CamFollowed Dad");
			}

			vocals.volume = 1;
			//trace("Vocal Volume = " + vocals.volume);

			#if windows
			if (luaModchart != null)
			{
				luaModchart.executeState('playerTwoTurn', []);
				//trace("P2 Turn");
			}
			#end
			// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

			//CamFollow Repositioning Per Dad Char
			/*switch (dad.curCharacter)
			{
			}*/
		}

		if (camFollow.x != boyfriend.getMidpoint().x - 100 && PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
		{
			var offsetX = 0;
			var offsetY = 0;
			#if windows
			if (luaModchart != null)
			{
				offsetX = luaModchart.getVar("followXOffset", "float");
				offsetY = luaModchart.getVar("followYOffset", "float");
			}
			#end

			//Mashing Detection Reset
			if (notePresses != 0 && noteMashingThreshold != defaultMashingThreshold)
			{
				noteMashingThreshold = defaultMashingThreshold;
				notePresses = 0;
				//trace ("Reset Mashing SHit");
			}
			
			if (camFollowing && !camShake && !triggeredCamShake)
			{
				//trace("CamFollowSpeed = " + camFollowSpeed);

				if (curSong == 'Mic Test' && !PlayStateChangeables.Optimize)
					camTween = FlxTween.tween(FlxG.camera, {zoom: 1.2}, (Conductor.stepCrochet * 4 / 750), {ease: FlxEase.elasticInOut});

				camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);
				//trace("CamFollowed BF");
			}

			vocals.volume = 1;
			//trace("Vocal Volume = " + vocals.volume);

			#if windows
			if (luaModchart != null)
			{
				luaModchart.executeState('playerOneTurn', []);
				//trace("P1 Turn");
			}
			#end

			//Positioning for BF per Stage
			switch (curStage)
			{
			}
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	var lowHealthSoundVolume:Float = 0;

	override function beatHit()
	{
		super.beatHit();

		//trace(curBeat);

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, (PlayStateChangeables.useDownscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));

			switch (curSong)
			{
				case "Mic Test" | "Sudden Confrontation":
					//do NATHIN
				default:
					if (health < 1 && !midsongCutscene && allowHeartBeatSounds && !resultsPresent && !inResults && !inCutscene && !cannotDie)
					{
						if (Conductor.bpm <= 300)
						{
							if (health > 0.75 && curBeat % 4 == 0)
							{
								lowHPHeartBeat.play(true);
								//trace ("Played Low HP Noise");
							}
							else if (health > 0.5 && curBeat % 2 == 0)
							{
								lowHPHeartBeat.play(true);
								//trace ("Played Low HP Noise");
							}
							else if (health < 0.5)
							{
								lowHPHeartBeat.play(true);
								//trace ("Played Low HP Noise");
							}
						}
						else
						{
							if (health > 0.75 && curBeat % 4 == 0)
							{
								lowHPHeartBeat.play(true);
								//trace ("Played Low HP Noise || BPM > 300");
							}
							else if (curBeat % 2 == 0)
							{
								lowHPHeartBeat.play(true);
								//trace ("Played Low HP Noise || BPM > 300");
							}
						}
						//trace (lowHealthSoundVolume);
					}
			}
		}

		#if windows
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curBeat', curBeat);
			luaModchart.executeState('beatHit', [curBeat]);
		}
		#end

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			// Here so that Dad doesnt interrupt his own notes
			if ((PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection || !dad.animation.curAnim.name.startsWith("sing")))
				if (curBeat % idleBeat == 0 || dad.curCharacter == "priest-theborderpray" || dad.curCharacter == "table-default")
					dad.dance(idleToBeat);
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		if (FlxG.save.data.camzoom && camZooming && !resultsPresent)
		{
			switch (curSong)
			{
				case "Up and Beyond":
					if (FlxG.save.data.camzoom && camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 1)
					{
						FlxG.camera.zoom += 0.013;
						camHUD.zoom += 0.02;
					}
				default:
					if (FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
					{
						FlxG.camera.zoom += 0.015;
						camHUD.zoom += 0.01;
					}
			}
		}

		if (FlxG.save.data.distractions)
		{
			iconP1.setGraphicSize(Std.int(iconP1.width + 30));
			iconP2.setGraphicSize(Std.int(iconP2.width + 30));
		}

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		//Mid song Events - If statement is added to prevent them from playing in the ResultsScreen
		if (!resultsPresent && !PlayStateChangeables.Optimize)
		{
			switch (curSong)
			{
				case 'Mic Test':
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
						case 8:
							//if (FlxG.save.data.weekUnlocked <= 2 && isStoryMode)
							if (deaths <= 0 && !hasReset)
							{
								if (needSkip)
									FlxTween.tween(skipText, {alpha: 0}, 0.3, {ease: FlxEase.sineInOut});
								new FlxTimer().start(0.025, function(tmr:FlxTimer)
								{
									tutorialGraphicA.alpha += 0.085;
									tutorialText.alpha += 0.085;
									if (tutorialGraphicA.alpha < 1 && tutorialText.alpha < 1)
									{
										tmr.reset(0.025);
									}
									else
									{
										//Just traces a mesage for debugging purposes/
										//trace('Created Tutorial Tip A');
									}
								});
							}
						case 20:
							//if (FlxG.save.data.weekUnlocked <= 2 && isStoryMode)
							if (deaths <= 0 && !hasReset)
							{
								if (needSkip)
									FlxTween.tween(skipText, {alpha: 1}, 0.3, {ease: FlxEase.sineInOut});
								new FlxTimer().start(0.025, function(tmr:FlxTimer)
								{
									tutorialGraphicA.alpha -= 0.09;
									tutorialText.alpha -= 0.09;
									if (tutorialGraphicA.alpha > 0 && tutorialText.alpha > 0)
									{
										tmr.reset(0.025);
									}
									else
									{
										//Just traces a mesage for debugging purposes/
										//trace('Removed Tutorial Tip A');
										tutorialGraphicA.destroy();
										tutorialText.destroy();
									}
								});
							}
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
						case 24:
							//if (FlxG.save.data.weekUnlocked <= 2 && isStoryMode)
							if (deaths <= 0 && !hasReset)
							{
								if (needSkip)
									FlxTween.tween(skipText, {alpha: 0}, 0.3, {ease: FlxEase.sineInOut});
								new FlxTimer().start(0.025, function(tmr:FlxTimer)
								{
									tutorialGraphicB.alpha += 0.085;
									if (tutorialGraphicB.alpha < 1)
									{
										tmr.reset(0.025);
									}
									else
									{
										//Just traces a mesage for debugging purposes/
										//trace('Created Tutorial Tip B');
									}
								});
							}
						case 39:
							//if (FlxG.save.data.weekUnlocked <= 2 && isStoryMode)
							if (deaths <= 0 && !hasReset)
							{
								if (needSkip)
									FlxTween.tween(skipText, {alpha: 1}, 0.3, {ease: FlxEase.sineInOut});
								new FlxTimer().start(0.025, function(tmr:FlxTimer)
								{
									tutorialGraphicB.alpha -= 0.09;
									if (tutorialGraphicB.alpha > 0)
									{
										tmr.reset(0.025);
									}
									else
									{
										//Just traces a mesage for debugging purposes/
										//trace('Removed Tutorial Tip B');
										tutorialGraphicB.destroy();
									}
								});
							}
						case 40:
							//if (FlxG.save.data.weekUnlocked <= 2 && isStoryMode)
							if (deaths <= 0 && !hasReset)
							{
								if (needSkip)
									FlxTween.tween(skipText, {alpha: 0}, 0.3, {ease: FlxEase.sineInOut});
								new FlxTimer().start(0.025, function(tmr:FlxTimer)
								{	
									tutorialGraphicC.alpha += 0.085;
									if (tutorialGraphicC.alpha < 1)
									{
										tmr.reset(0.025);
									}
									else
									{
										//Just traces a mesage for debugging purposes/
										//trace('Created Tutorial Tip C');
									}
								});
							}
						case 52:
							//if (FlxG.save.data.weekUnlocked <= 2 && isStoryMode)
							if (deaths <= 0 && !hasReset)
							{
								if (needSkip)
									FlxTween.tween(skipText, {alpha: 1}, 0.3, {ease: FlxEase.sineInOut});
								new FlxTimer().start(0.025, function(tmr:FlxTimer)
								{
									tutorialGraphicC.alpha -= 0.09;
									if (tutorialGraphicC.alpha > 0)
									{
										tmr.reset(0.025);
									}
									else
									{
										//Just traces a mesage for debugging purposes/
										//trace('Removed Tutorial Tip C');
										tutorialGraphicC.destroy();
									}
								});
							}
						case 53:
							changeSubtitles("Ok, do as I say!", 0xFFfff300);
							dad.playAnim('singUP-alt', true);
						case 54:
							dad.playAnim('singRIGHT-alt', true);
							new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								dad.playAnim('singLEFT-alt', true);
							});
						case 55:
							dad.playAnim('singUP-alt', true);
						case 56:
							changeSubtitles("Left", 0xFFfff300);
						case 58:
							changeSubtitles("Right", 0xFFfff300);
						case 59:
							changeSubtitles("Everyone, left", 0xFFfff300);
						case 61:
							changeSubtitles("Everyone, right!", 0xFFfff300);
						case 64:
							changeSubtitles("", 0xFF4adaff);
						case 70:
							changeSubtitles("Good job!", 0xFFfff300);
						case 72:
							changeSubtitles("Up", 0xFFfff300);
						case 74:
							changeSubtitles("Down", 0xFFfff300);
						case 75:
							changeSubtitles("Everyone, up", 0xFFfff300);
						case 77:
							changeSubtitles("Everyone, down!", 0xFFfff300);
						case 80:
							changeSubtitles("", 0xFF4adaff);
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
							changeSubtitles("", 0xFF4adaff);
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
							changeSubtitles("", 0xFF4adaff);
						case 118:
							changeSubtitles("Now, free-style it!", 0xFFfff300);
						case 120:
							changeSubtitles("", 0xFF4adaff);
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
							changeSubtitles("", 0xFF4adaff);
						case 180:
							changeSubtitles("That's how you do it, good job!", 0xFFfff300);
						case 184:
							changeSubtitles("Ok up, rise, down, left, right", 0xFFfff300);
						case 188:
							changeSubtitles("down, left, right, right, fall.", 0xFFfff300);
						case 191 | 207 | 215 | 247 | 279:
							if (accuracy > 30)
							{
								dad.playAnim('cheer', true);
							}
							else
							{
								dad.playAnim('cheerFail', true);
							}
						case 192:
							changeSubtitles("Down, down, up, right", 0xFFfff300);
						case 196:
							changeSubtitles("left, up, up", 0xFFfff300);
						case 198:
							changeSubtitles("now, free-style it!", 0xFFfff300);
						case 200:
							changeSubtitles("", 0xFF4adaff);
						case 212:
							changeSubtitles("That's how you do it!", 0xFFfff300);
						case 214:
							changeSubtitles("Ok here we go.", 0xFFfff300);
						case 216:
							changeSubtitles("", 0xFF4adaff);
						case 278:
							changeSubtitles("That's how you do it~!!", 0xFFfff300);
						case 280:
							changeSubtitles("", 0xFF4adaff);
					}
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
					}
					if (curBeat % 8 == 3 && curBeat > 120 && curBeat < 150)
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
					}
					if (curBeat % 16 == 7 && curBeat > 151 && curBeat < 215)
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
					}
					if (curBeat % 8 == 3 && curBeat > 216 && curBeat < 280)
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
					}
				case 'Tech. Difficulties':
					if (curBeat % 8 == 7 && curBeat > 0 && curBeat < 280 && curBeat != 87 && curBeat != 215)
					{
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
						case 7:
							camZooming = true;
					}
				case 'Awkward Pauses':
					switch (curBeat)
					{
						case 31:
							camZooming = true;
						case 254:
							dad.playAnim('badFingerStart', true);
							FlxTween.tween(FlxG.camera, {zoom: 1}, 0.1, {ease: FlxEase.expoIn});
							allowHeartBeatSounds = false;
						case 255:
							camFollowing = false;
							midsongCutscene = true;
							camFollow.x =  gf.getGraphicMidpoint().x;
							camFollow.y =  gf.getGraphicMidpoint().y;
							dad.playAnim('badFingerHold', true);
							boyfriend.playAnim('scared', false);
							gf.playAnim('scared', true);
							if (FlxG.save.data.distractions)
							{
								//Hides the HUD and zooms the camera out once daddy dearest flips off bf
								camHUD.visible = false;
								camZooming = false;
								FlxG.camera.zoom = 0.8;
							}
						case 256:
							allowHeartBeatSounds = true;
							gf.playAnim('danceRight', true);
							boyfriend.playAnim('scaredHOLD', false);
							camFollowing = true;
							if (FlxG.save.data.distractions)
							{
								camZooming = true;
								camHUD.visible = true;
							}
						case 258:
							boyfriend.playAnim('awkward', true);
							//trace("AWKWARD LMAO");
						case 259:
							midsongCutscene = false;
					}
				case 'Up and Beyond':
					//Hardcoding for Zooms
					if (FlxG.save.data.camzoom && camZooming && curBeat % 4 == 3 && curBeat > 193 && curBeat < 257)
					{
						if (FlxG.save.data.camzoom && FlxG.save.data.flashing)
						{
							FlxG.camera.zoom += 0.015;
							camHUD.zoom += 0.01;
						}
					}
					if (FlxG.save.data.camzoom && camZooming && curBeat % 4 == 3 && curBeat > 389 && curBeat < 513)
					{
						if (FlxG.save.data.camzoom && FlxG.save.data.flashing)
						{
							FlxG.camera.zoom += 0.015;
							camHUD.zoom += 0.01;
						}
					}
					switch (curBeat)
					{
						case 32:
							camZooming = true;
						case 519:
							camZooming = false;
						case 528:
							//trace("YOU BETTER BE CHANGED FROM " + camFollowSpeed);
							camFollowSpeed = 0.02;
							//trace("TO " + camFollowSpeed);
						case 529:
							if (isStoryMode)
							{
								fadeOutGameplayHUD(4.5);
								//trace('HUD now Faded Out');
							}
					}
				case 'Desperation':
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
							changeSubtitles("", 0xFF4adaff);
						case 32:
							changeSubtitles("Help us, oh Lord please help us!", 0xFF5ce766);
						case 40:
							changeSubtitles("Lord, please help us", 0xFF5ce766);
						case 44:
							changeSubtitles("please, Lord help us!", 0xFF5ce766);
						case 48:
							changeSubtitles("", 0xFF4adaff);
						case 63:
							camZooming = true;
						case 64:
							changeSubtitles("[Speaking in tounges]", 0xFF5ce766);
						case 68:
							changeSubtitles("", 0xFF5ce766);
						case 80:
							changeSubtitles("", 0xFF4adaff);
						case 96:
							changeSubtitles("[Speaking in tounges]", 0xFF5ce766);
						case 100:
							changeSubtitles("", 0xFF5ce766);
						case 112:
							changeSubtitles("", 0xFF4adaff);
						case 128:
							changeSubtitles("Lord, please help us!", 0xFF5ce766);
						case 132:
							changeSubtitles("Oh Lord, please help us!", 0xFF5ce766);
						case 136:
							changeSubtitles("Lord, Lord, please help us!", 0xFF5ce766);
						case 140:
							changeSubtitles("[Speaking in tounges]", 0xFF5ce766);
						case 144:
							changeSubtitles("", 0xFF4adaff);
						case 160:
							changeSubtitles("Help us, Lord please help us!", 0xFF5ce766);
						case 168:
							changeSubtitles("Lord, please help us!", 0xFF5ce766);
						case 172:
							changeSubtitles("[changeSubtitles(%NoOneCanHearYou%, 0xFF5ce766);]", 0xffa38e8e);
						case 174:
							changeSubtitles("[%%%%%%%%]", 0xffa38e8e);
						case 175:
							changeSubtitles("", 0xFF5ce766);
							camZooming = false;
							boyfriend.playAnim('awkward', true);
						case 176:
							camZooming = true;
							changeSubtitles("(I don't think)", 0xFF4adaff);
						case 180:
							changeSubtitles("(I'm able to do that)", 0xFF4adaff);
						case 184:
							changeSubtitles("(It's a little...)", 0xFF4adaff);
						case 188:
							changeSubtitles("(...too hard for me-?)", 0xFF4adaff);
						case 190:
							changeSubtitles("", 0xFF5ce766);
							//VINE BOOM
							iconP2.animation.play('priest-theborderannoyed');
							dad.playAnim('gotPissed', true);
							boyfriend.playAnim('awkward', true);
							camZooming = false;
							midsongCutscene = true;
							vignette.alpha = 0.65;
							if (FlxG.save.data.distractions)
							{
								camHUD.visible = false;
								FlxG.camera.zoom = 0.95;
								FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 1.0, 
									{
										ease: FlxEase.quadInOut,
									});
							}
						case 191:
							remove(dad);
							dad = new Character(100, 315, 'priest-theborderannoyed');
							add(dad);
							camZooming = true;
							midsongCutscene = false;
							if (FlxG.save.data.distractions)
							{
								camHUD.visible = true;
							}
						case 192:
							changeSubtitles("[Angrily] LORD. PLEASE. HELP. 'US'.", 0xFF5ce766);
						case 196:
							changeSubtitles("OH, LORD. PLEASE. 'HELP'. 'US'.", 0xFF5ce766);
						case 200:
							changeSubtitles("LORD LORD, PLEASE. HELP. 'US'.", 0xFF5ce766);
						case 204:
							changeSubtitles("[Angrily babbling]", 0xFF5ce766);
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
							changeSubtitles("{I can pray like you do-?}", 0xFF4adaff);
						case 255:
							new FlxTimer().start(0.1, function(tmr:FlxTimer)
							{
								boyfriend.playAnim('concerned', true);
								changeSubtitles("(um-)", 0xFF4adaff);
							});
						case 256:
							changeSubtitles("", 0xFF5ce766);
							allowHeartBeatSounds = false;
							if (isStoryMode)
							{
								camHUD.visible = false;
							}
							camZooming = false;
							if (FlxG.save.data.camzoom)
							{
								FlxG.camera.zoom = 1.0;
								FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 1.3, 
									{
										ease: FlxEase.quadInOut,
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
							if (FlxG.save.data.distractions)
							{
								boyfriend.playAnim('hey', true);
							}
						case 127:
							dad.playAnim('gotPissed', true);
							changeSubtitles("HUH?!", 0xFF5ce766);
						case 129:
							changeSubtitles("", 0xFF4adaff);
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
							dad.playAnim('gotPissed', true);
						case 160:
							changeSubtitles("{That's not even what I said!}", 0xFF4adaff);
						case 162:
							changeSubtitles("[Scolding]", 0xFF5ce766);
						case 168:
							changeSubtitles("([Responding])", 0xFF4adaff);
						case 176:
							changeSubtitles("", 0xFF4adaff);
						case 179:
							changeSubtitles("I don't think you understood that.", 0xFF5ce766);
						case 184:
							changeSubtitles("{Ugh-!}", 0xFF4adaff);
						case 186:
							dad.playAnim('gotPissed', true);
							changeSubtitles("Grgh-", 0xFF5ce766);
						case 188:
							changeSubtitles("LET ME TELL YOU ONCE AGAIN.", 0xFF5ce766);
						case 191:
							boyfriend.playAnim('concerned', true);
							changeSubtitles("(wh-)", 0xFF4adaff);
						case 192:
							changeSubtitles("", 0xFF5ce766);
						case 207:
							boyfriend.playAnim('singRIGHT', true);
							camFollowing = false;
							midsongCutscene = true;
							camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
							//changeSubtitles("(I-)", 0xFF4adaff);
						case 208:
							boyfriend.playAnim('singLEFTmiss', true);
							//changeSubtitles("([Gets Intterupted])", 0xFF4adaff);
						case 212:
							camFollowing = true;
							midsongCutscene = false;
							changeSubtitles("", 0xFF5ce766);
						case 254:
							dad.playAnim('gotPissed', true);
							changeSubtitles("[Angry Sigh]", 0xFF5ce766);
						case 256:
							changeSubtitles("", 0xFF5ce766);
						case 271:
							if (FlxG.save.data.distractions)
							{
								boyfriend.playAnim('awkward', true);
							}
						case 303:
							if (FlxG.save.data.distractions)
							{
								boyfriend.playAnim('awkward', true);
							}
						//case 397:
						//	glitchyGlitchEffect.active = true;
						case 398:
							//glitchyGlitchEffect.active = false;
						case 400:
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
							if (isStoryMode)
							{
								var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
									-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
								blackShit.scrollFactor.set();
								add(blackShit);
								camHUD.visible = false;
							}
					}					
				case 'Retaliation':
					// HARDCODING FOR ZOOMS!
					if (FlxG.save.data.camzoom && camZooming && FlxG.camera.zoom < 1.35)
					{
						if (curBeat >= 160 && curBeat < 224)
						{
							FlxG.camera.zoom += 0.015;
							camHUD.zoom += 0.01;	
						}
						else if (curBeat >= 354 && curBeat < 416)
						{
							FlxG.camera.zoom += 0.025;
							camHUD.zoom += 0.02;
						}
					}
					else if (curBeat % 4 == 2 && curBeat > 316 && curBeat < 480)
					{
						if (camZooming && FlxG.save.data.camzoom && FlxG.save.data.flashing)
						{
							FlxG.camera.zoom += 0.02;
							camHUD.zoom += 0.015;
						}
					}			
					switch (curBeat)
					{
						case 31:
							camZooming = true;
						case 32:
							//trace("YOU BETTER BE CHANGED FROM " +  camFollowSpeed);
							camFollowSpeed = 0.04;
							//trace("TO " + camFollowSpeed);
						//case 157:
							//glitchyGlitchEffect.active = true;
						//case 158:
							//glitchyGlitchEffect.active = false;
						case 157:
							camZooming = false;
						case 159:
							//glitchyGlitchEffect.active = true;
							dad.playAnim('midsongAnim', true);
						case 160:
							camZooming = true;
							//glitchyGlitchEffect.active = false;
							if(FlxG.save.data.distractions)
							{
								FlxTween.tween(bottomBoppers, {alpha: 0.65, y: bottomBoppers.y - bottomBoppers.height / 1.2}, 0.5, {ease: FlxEase.quadOut});
								FlxTween.tween(theBorderBG, {alpha: 0.3}, 0.5, {ease: FlxEase.quadOut});
							}
							characterBlurEffect.alpha = 0.8;
							songClimax = true;
						case 223:
							//glitchyGlitchEffect.active = true;
							if(FlxG.save.data.distractions)
							{
								FlxTween.tween(bottomBoppers, {alpha: 0, y: 590}, 1, {ease: FlxEase.quadIn});
								FlxTween.tween(theBorderBG, {alpha: 0.5}, 0.5, {ease: FlxEase.quadOut});
							}
						case 224:
							//glitchyGlitchEffect.active = false;
							characterBlurEffect.alpha = 0.5;
							songClimax = false;
						case 351:
							camZooming = false;
							//glitchyGlitchEffect.active = true;
							dad.playAnim('midsongAnim', true);
						case 352:
							//glitchyGlitchEffect.active = false;
							if (FlxG.save.data.camZoom)
							{
								FlxG.camera.zoom = 0.7;
							}
						case 354:
							camZooming = true;
							characterBlurEffect.alpha = 0.8;
							songClimax = true;
							if(FlxG.save.data.distractions)
							{
								FlxTween.tween(bottomBoppers, {alpha: 0.8, y: bottomBoppers.y - bottomBoppers.height / 1.2}, 0.5, {ease: FlxEase.quadOut});
								FlxTween.tween(theBorderBG, {alpha: 0.3}, 0.5, {ease: FlxEase.quadOut});
							}
						case 416:
							characterBlurEffect.alpha = 0.5;
						case 479:
							camZooming = false;
						case 480:
							songClimax = false;
							allowNoteHitSounds = false;
							camFollowSpeed = 0.02;
							if(FlxG.save.data.distractions)
							{
								if(FlxG.save.data.distractions)
									FlxTween.tween(bottomBoppers, {alpha: -10, y: 690}, 4.1142, {ease: FlxEase.quadIn});
								FlxTween.tween(camHUD, {alpha: 0.6}, 4.1142, {ease: FlxEase.sineInOut, startDelay: 0.1});
								FlxTween.tween(theBorderBG, {alpha: 0.8}, 4.1142, {ease: FlxEase.sineInOut, startDelay: 0.1});
								theBorderBG.alpha += 0.0035;
								//trace('HUD is now Translucent');
							}
						case 508:
							characterBlurEffect.alpha = 0.3;
							//glitchyGlitchEffect.active = true;
							camFollowSpeed = 0.04;
							boyfriend.playAnim('awkward', true);
							midsongCutscene = true;
							dad.playAnim('endsongAnim1', true);
							FlxTween.tween(FlxG.camera, {zoom: 1.8}, 2, {ease: FlxEase.quadIn});
						case 509:
							//glitchyGlitchEffect.active = false;
							boyfriend.playAnim('concerned', true);
							dad.playAnim('endsongAnim1', true);
						case 510:
							dad.playAnim('endsongAnim2', true);
						case 511:
							boyfriend.playAnim('scared', true);
							dad.playAnim('endsongAnim3', true);
							camShake = true;
							theBorderBG.animation.play('lightning');
						case 512:
							remove(boyfriend);
							remove(dad);
							vignette.kill();
							vignette.destroy();
							characterBlurEffect.destroy();
							var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
								-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
							blackShit.scrollFactor.set();
							add(blackShit);
							allowHeartBeatSounds = false;
							camHUD.alpha = 1;
							FlxG.camera.flash(FlxColor.WHITE, 0.5);
							if (isStoryMode)
								camHUD.visible = false;
					}
				case 'Kid With a Gun':
					switch(curBeat)
					{
						case 3:
							camZooming = true;
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
						case 169:
							midsongCutscene = true;
							boyfriend.playAnim('scaredHOLD', false);
						case 172:
							midsongCutscene = false;
							subtitleTimer = new FlxTimer().start(0.11, function(tmr:FlxTimer)
							{
								changeSubtitles("(Sir, I have told you many times)", 0xFF4adaff);
							});
						case 176:
							changeSubtitles("(is my voice not audible-?)", 0xFF4adaff);
						case 180:
							changeSubtitles("Leave. now. or. die.", 0xFFb7d855);
						case 184:
							changeSubtitles("LEAVE. NOW. OR. DIE.", 0xFFb7d855);
						case 188:
							changeSubtitles("(Can he not hear me-?)", 0xFF4adaff);
						case 192:
							camZooming = false;
							FlxG.camera.zoom = 0.82;
							changeSubtitles("(C-Can ANYONE HEAR ME-??)", 0xFF4adaff);
						case 194:
							FlxFlicker.flicker(subtitleText, 0.3, 0.06, true);
						case 195:
							subtitleText.alpha = 0;
						case 196:
							camZooming = true;
							subtitleTimer = new FlxTimer().start(0.22, function(tmr:FlxTimer)
							{
								subtitleText.alpha = 1;
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
							changeSubtitles("", 0xFF4adaff);
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
							changeSubtitles("", 0xFF4adaff);
					}
				case 'Playing With Fire':
					if (FlxG.save.data.flashing && curBeat % 2 == 1 && curBeat > 276 && curBeat < 304)
						vignette.animation.play('singleFlash');
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
							midsongCutscene = true;
							boyfriend.playAnim('scaredHOLD', false);
						case 110:
							changeSubtitles("pointed at your goddamn faces!", 0xFFb7d855);
						case 112:
							midsongCutscene = false;
							changeSubtitles("", 0xFF4adaff);
						case 128:
							changeSubtitles("THIS IS YOUR LAST WARNING.", 0xFFb7d855);
						case 131:
							changeSubtitles("LEAVE NOW BEFORE I START FIRING MY GUN", 0xFFb7d855);
						case 136:
							changeSubtitles("POINTED AT YOUR", 0xFFb7d855);
						case 140:
							changeSubtitles("POINTED AT YOUR GODDAMN", 0xFFb7d855);
							midsongCutscene = true;
							boyfriend.playAnim('scared', false);
						case 142:
							changeSubtitles("POINTED AT YOUR GODDAMN FACES!", 0xFFb7d855);
						case 144:
							midsongCutscene = false;
							changeSubtitles("", 0xFF4adaff);
						case 159:
							camZooming = false;
						case 160:
							FlxTween.tween(FlxG.camera, {zoom: 0.82}, 2, {ease: FlxEase.quadInOut});
							camFollowSpeed = 0.035;
						case 174:
							dad.playAnim('gunLOAD', true);
							FlxTween.tween(FlxG.camera, {zoom: 0.85}, 0.4, {ease: FlxEase.sineInOut});
						case 175:
							FlxTween.tween(FlxG.camera, {zoom: 0.95}, 0.15, {ease: FlxEase.quadInOut});
							dad.playAnim('gunWARNING', true);
							boyfriend.playAnim('scared', true);
							gf.playAnim('scared', true);
							camShake = true;
							isEarthquake = true;
							allowHeartBeatSounds = false;
							camFollowSpeed = 0.045;
						case 176:
							midsongCutscene = true;
							boyfriend.playAnim('scaredHOLD', false);
							FlxG.camera.zoom = 0.8;
							if (!playedCutscene)
							{
								avoidBulletTipGraphic.x -= 110;
								avoidBulletTipGraphic.y -= 30;
								FlxTween.tween(avoidBulletTipGraphic, {x: avoidBulletTipGraphic.x + 150, y: avoidBulletTipGraphic.y + 45, alpha: 1}, 0.5, {ease: FlxEase.elasticInOut});
							}
						case 180:
							camFollowSpeed = 0.04;
							allowHeartBeatSounds = true;
							midsongCutscene = false;
							camZooming = true;
							if (!playedCutscene)
							{
								playedCutscene = true;
								avoidBulletTipGraphic.acceleration.y = 1200;
								avoidBulletTipGraphic.acceleration.x = 800;
								avoidBulletTipGraphic.velocity.y -= FlxG.random.int(150, 175);
								avoidBulletTipGraphic.velocity.x += FlxG.random.int(300, 400);
								FlxTween.tween(avoidBulletTipGraphic, {alpha: 0}, 0.5, {ease: FlxEase.sineInOut, startDelay: 0.3,
									onComplete: function(twn:FlxTween)
									{
										avoidBulletTipGraphic.kill();
										avoidBulletTipGraphic.destroy();
									}
								});
								//trace('Removed Tutorial Tip');
							}
						case 186 | 198 | 210 | 226 | 231 | 235 | 241 | 341 | 350 | 357 | 365 | 410 | 418 | 422 | 429 
						| 433 | 472 | 477 | 480 | 484 | 488 | 492 | 496 | 531 | 535 | 546 | 549 | 552 | 562:
							dad.playAnim('gunLOAD', true);
							if (!vignette.animation.curAnim.name.startsWith("warning") && FlxG.save.data.flashing)
								vignette.animation.play('warning');
						case 187 | 199 | 211 | 227 | 232 | 236 | 242 | 342 | 351 | 358 | 366 | 405 
						| 411 | 419 | 423 | 430 | 434 | 469 | 473 | 475 | 478 | 481 | 483 
						| 485 | 489 | 491 | 493 | 497 | 499 | 539 | 550 | 553 | 555 | 557 | 561:
							//Add some more curbeats lol so that it doesnt get as clunky
							dad.playAnim('gunSHOOT', true);
							if (!vignette.animation.curAnim.name.startsWith("static"))
								vignette.animation.play('static');
							if (!camShake)
							{
								camShake = true;
							}
						case 244:
							camFollowSpeed = 0.05;
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
							changeSubtitles("(BUT PLEASE JUST HELP US OUT)", 0xFF4adaff);
						case 300:
							changeSubtitles("(THE EXIT WILL TAKE US AWAY FROM)", 0xFF4adaff);
						case 302:
							camFollowing = false;
							midsongCutscene = true;
							camFollow.x =  gf.getGraphicMidpoint().x;
							camFollow.y =  gf.getGraphicMidpoint().y;
							camZooming = false;
							FlxTween.tween(FlxG.camera, {zoom: 1}, 0.5, {ease: FlxEase.elasticInOut});
							changeSubtitles("(THE EXIT WILL TAKE US AWAY FROM HERE)", 0xFF4adaff);
							FlxFlicker.flicker(subtitleText, 0.3, 0.04, true);
						case 303:
							subtitleText.alpha = 0;
						case 304:
							if (FlxG.save.data.distractions)
							{
								//Hides the HUD and zooms the camera out once priest speaks
								//camHUD.visible = false;
								strumLineNotes.forEach(function(babyArrow:FlxSprite)
								{
									FlxTween.tween(babyArrow, {alpha: 0}, 0.2, {ease: FlxEase.quadOut});
								});
							}
							dad.playAnim('gunSHOCKED', true);
							gf.playAnim('singDOWN-alt', true);
							new FlxTimer().start(0.176, function(tmr:FlxTimer)
							{
								gf.playAnim('singUP-alt', true);
								subtitleText.alpha = 1;
								changeSubtitles("YOU", 0xFF5ce766);
							});
							//Priest: Yfou--
						case 305:
							//Priest: --can't
							gf.playAnim('singUP-alt', true);
							changeSubtitles("YOU CAN'T", 0xFF5ce766);
						case 306:
							//Priest: --sing!
							dad.playAnim('gunPISSED', true);
							gf.playAnim('singUP-alt', true);
							changeSubtitles("YOU CAN'T SING!", 0xFF5ce766);
						case 307:
							camFollow.y -= 10;
							camFollowing = true;
							FlxG.camera.zoom = 0.9;
							boyfriend.playAnim('scared', true);
							dad.playAnim('gunWARNING', true);
							gf.playAnim('scared', true);
							changeSubtitles("", 0xFF5ce766);
							camShake = true;
							//gf getting scared cause pico shoots a warning shot
						case 308:
							camFollowSpeed = 0.04;
							if (FlxG.save.data.distractions)
							{
								strumLineNotes.forEach(function(babyArrow:FlxSprite)
								{
									FlxTween.tween(babyArrow, {alpha: 1}, 0.2, {ease: FlxEase.quadIn});
								});
							}
							camZooming = true;
							midsongCutscene = false;
							changeSubtitles("One more time.", 0xFFb7d855);
						case 312:
							subtitleTimer = new FlxTimer().start(0.17, function(tmr:FlxTimer)
							{
								changeSubtitles("Don't need to tell you", 0xFFb7d855);
							});
						case 316:
							changeSubtitles("Don't need to tell you one more time.", 0xFFb7d855);
						case 320:
							subtitleTimer = new FlxTimer().start(0.17, function(tmr:FlxTimer)
							{
								changeSubtitles("Don't need to tell you", 0xFFb7d855);
							});
						case 322:
							changeSubtitles("Don't need to tell you 'Leave or die.'", 0xFFb7d855);
						case 324:
							changeSubtitles("I'll shoot you if you- if y-", 0xFFb7d855);
						case 328:
							changeSubtitles("ONE. MORE. TIME.", 0xFFb7d855);
						case 332:
							changeSubtitles("", 0xFFb7d855);
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
							changeSubtitles("", 0xFFb7d855);
						case 372:
							changeSubtitles("One more time.", 0xFFb7d855);
						case 376:
							subtitleTimer = new FlxTimer().start(0.17, function(tmr:FlxTimer)
							{
								changeSubtitles("Don't need to tell you", 0xFFb7d855);
							});
						case 380:
							changeSubtitles("Don't need to tell you one more time.", 0xFFb7d855);
						case 384:
							subtitleTimer = new FlxTimer().start(0.17, function(tmr:FlxTimer)
							{
								changeSubtitles("Don't need to tell you", 0xFFb7d855);
							});
						case 386:
							changeSubtitles("Don't need to tell you 'Leave or die!'", 0xFFb7d855);
						case 388:
							changeSubtitles("I'll shoot you if you- if y-", 0xFFb7d855);
						case 392:
							changeSubtitles("ONE. MORE. TIME.", 0xFFb7d855);
						case 396:
							changeSubtitles("", 0xFFb7d855);
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
							changeSubtitles("", 0xFFb7d855);
							dad.playAnim('gunLOAD', true);
							if (!vignette.animation.curAnim.name.startsWith("warning") && FlxG.save.data.flashing)
								vignette.animation.play('warning');
						case 435:
							dad.playAnim('gunLOAD', true);
							if (FlxG.save.data.flashing)
								vignette.animation.play('warning');
							new FlxTimer().start(0.176, function(tmr:FlxTimer)
							{
								dad.playAnim('gunSHOOT', true);
								vignette.animation.play('static');
							});
							camFollowSpeed = 0.05;
						case 436:
							changeSubtitles("THIS IS YOUR LAST WARNING", 0xFFb7d855);
							dad.playAnim('gunSHOOT', true);
							if (!vignette.animation.curAnim.name.startsWith("static"))
								vignette.animation.play('static');
							if (!camShake)
							{
								camShake = true;
							}
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
							changeSubtitles("", 0xFFb7d855);
							dad.playAnim('gunLOAD', true);
							if (!vignette.animation.curAnim.name.startsWith("warning") && FlxG.save.data.flashing)
								vignette.animation.play('warning');
						case 474:
							new FlxTimer().start(0.176, function(tmr:FlxTimer)
							{
								dad.playAnim('gunSHOOT', true);
							});
						case 482:
							new FlxTimer().start(0.176, function(tmr:FlxTimer)
							{
								dad.playAnim('gunSHOOT', true);
							});
						case 490:
							new FlxTimer().start(0.176, function(tmr:FlxTimer)
							{
								dad.playAnim('gunSHOOT', true);
							});
						case 498:
							new FlxTimer().start(0.176, function(tmr:FlxTimer)
							{
								dad.playAnim('gunSHOOT', true);
							});
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
							changeSubtitles("", 0xFFb7d855);
						case 532:
							dad.playAnim('gunSHOOT', true);
							if (!vignette.animation.curAnim.name.startsWith("static"))
								vignette.animation.play('static');
							if (!camShake)
							{
								camShake = true;
							}
							subtitleTimer = new FlxTimer().start(0.17, function(tmr:FlxTimer)
							{
								changeSubtitles("TOLD YOU TO LEAVE", 0xFFb7d855);
							});
						case 536:
							dad.playAnim('gunSHOOT', true);
							if (!vignette.animation.curAnim.name.startsWith("static"))
								vignette.animation.play('static');
							if (!camShake)
							{
								camShake = true;
							}
							subtitleTimer = new FlxTimer().start(0.17, function(tmr:FlxTimer)
							{
								changeSubtitles("BUT THEN YOU NEVER LEFT", 0xFFb7d855);
							});
						case 538:
							new FlxTimer().start(0.176, function(tmr:FlxTimer)
							{
								dad.playAnim('gunSHOOT', true);
							});
						case 540:
							changeSubtitles("WHAT WILL IT TAKE FOR ME TO", 0xFFb7d855);
						case 544:
							changeSubtitles("WARN YOU 'BOUT THIS GUN I'M HOLDING!?!", 0xFFb7d855);
						case 547:
							new FlxTimer().start(0.176, function(tmr:FlxTimer)
							{
								dad.playAnim('gunSHOOT', true);
								vignette.animation.play('static');
							});
						case 548:
							changeSubtitles("", 0xFFb7d855);
						case 554:
							new FlxTimer().start(0.176, function(tmr:FlxTimer)
							{
								dad.playAnim('gunSHOOT', true);
							});
						case 559:
							new FlxTimer().start(0.176, function(tmr:FlxTimer)
							{
								dad.playAnim('gunSHOOT', true);
							});
						case 563:
							dad.playAnim('gunSHOOT', true);
							vignette.animation.play('static');
							new FlxTimer().start(0.176, function(tmr:FlxTimer)
							{
								dad.playAnim('gunSHOOT', true);
							});
							camFollowSpeed = 0.035;
						//Shooting
						//342, 351, 358, 366, 405, 411, 419, 423, 430, 434, 435-436, 469, 473, 474-475, 478, 481, 482-483, 485, 489, 490-491, 493, 497, 498-499, 532, 536, 538-539, 547 (next to 548), 550, 553, 554-555, 557, 559 (next to 560), 561, 562, 563					} oops this bracket is gone it caused a compile error. not removing it for HI S TO R Y!
						//Reloading
						//341, 350, 357, 365, 404, 410, 418, 422, 429, 433, 435, 468, 472, 477, 480, 484, 488, 492, 496, 531, 535, 546, 549, 552, 560
					}
				case 'Variegated Skylines':
					switch(curBeat)
					{
						case 31:
							camZooming = true;
					}
				case 'Finale': //ADAPTIVE MUSIC!! WOOOOO!!!
					//SPHAGETTI CODE INCOMING CAUSE FLIXEL DON'T HAVE A WELL DOCUMENTED WAY OF FRICKINJ SOUND GROUPSAFA
					//Drums/Taiko
					//Choir, Taiko, Drums, Hats, Bells
					if (curBeat % 16 == 0)
					{
						drums.stop();
						taiko.stop();
						if (dangerLevel < 50 && enemyHealth > 30)
						{
							drums = FlxG.sound.play(Paths.soundRandom('finaleAdaptiveMus/drums_', 0, 1));
							taiko = FlxG.sound.play(Paths.soundRandom('finaleAdaptiveMus/taiko_', 0, 2));
							taiko.time = drums.time;
							trace("Le Drummos");
						}
						else if (dangerLevel >= 50 && enemyHealth > 30)
						{
							drums = FlxG.sound.play(Paths.soundRandom('finaleAdaptiveMus/drums_', 2, 3));
							taiko = FlxG.sound.play(Paths.soundRandom('finaleAdaptiveMus/taiko_', 0, 5));
							taiko.time = drums.time;
							trace("Le Drummos but Epico");
						}
						else
						{
							drums = FlxG.sound.play(Paths.sound('finaleAdaptiveMus/drums_climax'));
							taiko = FlxG.sound.play(Paths.soundRandom('finaleAdaptiveMus/taiko_', 4, 5));
							taiko.time = drums.time;
							trace("Le Drummos but Epicest");
						}
					}
					//Choir, Hihats, Violin/Woodwinds, and Slayer
					if (curBeat % 32 == 0)
					{
						choir.stop();
						hats.stop();
						if (dangerLevel < 50 && enemyHealth > 30)
						{
							choir = FlxG.sound.play(Paths.sound('finaleAdaptiveMus/choir_0'));
							hats = FlxG.sound.play(Paths.sound('finaleAdaptiveMus/hats_0'));
							if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
								adders = FlxG.sound.play(Paths.sound('finaleAdaptiveMus/woodwinds'));
						}
						else if (dangerLevel >= 50 && enemyHealth > 30)
						{
							adders.stop();
							choir = FlxG.sound.play(Paths.sound('finaleAdaptiveMus/choir_1'));
							hats = FlxG.sound.play(Paths.sound('finaleAdaptiveMus/hats_1'));
							adders = FlxG.sound.play(Paths.sound('finaleAdaptiveMus/violin'));
						}
						else
						{
							adders.stop();
							pads.stop();
							choir = FlxG.sound.play(Paths.sound('finaleAdaptiveMus/choir_1'));
							hats = FlxG.sound.play(Paths.sound('finaleAdaptiveMus/hats_1'));
							adders = FlxG.sound.play(Paths.sound('finaleAdaptiveMus/elecpiano_climax'));
							pads = FlxG.sound.play(Paths.sound('finaleAdaptiveMus/pads_climax'));
						}

						if (dangerLevel < 50 && enemyHealth > 30 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
							slayer = FlxG.sound.play(Paths.sound('finaleAdaptiveMus/slayer_0'));
						else if (dangerLevel < 50 && enemyHealth > 30 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
						{
							slayer = FlxG.sound.play(Paths.sound('finaleAdaptiveMus/slayer_1'));
							//if (dangerLevel < 50)
							//	dangerLevel = 50;
						}
						else if (enemyHealth <= 30)
						{
							slayer.stop();
							slayer = FlxG.sound.play(Paths.sound('finaleAdaptiveMus/slayer_climax'));
							//if (dangerLevel < 50)
							//	dangerLevel = 50;
						}
						trace("Le Choir/Hats/Adders/Slayers");
						dangerLevel = FlxG.random.int(49, 50);
						enemyHealth = FlxG.random.int(31, 30);
					}
					//Cymbals/Hats
					if (curBeat % 64 == 0)
					{
						retalHats.stop();
						FlxG.sound.play(Paths.sound('finaleAdaptiveMus/stab'), 0.9);
						if (dangerLevel < 50 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
							retalHats = FlxG.sound.play(Paths.sound('finaleAdaptiveMus/retal-hats_0'));
						else if (dangerLevel < 50 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
							retalHats = FlxG.sound.play(Paths.sound('finaleAdaptiveMus/retal-hats_1'));
						else
							retalHats = FlxG.sound.play(Paths.sound('finaleAdaptiveMus/retal-hats_0'));
						//retalHats.time = drums.time;
						trace("Le RetalHats/Crash");
					}
					//Bells, and Pads
					if (curBeat % 64 == 32)
					{
						if (dangerLevel < 50)
						{
							bells.stop();
							bells = FlxG.sound.play(Paths.sound('finaleAdaptiveMus/bells_0'));
							if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && FlxG.random.bool(50))
								pads = FlxG.sound.play(Paths.sound('finaleAdaptiveMus/pads_0'));
						}
						else if (enemyHealth > 30)
						{
							if (FlxG.random.bool(75))
							{
								bells.stop();
								bells = FlxG.sound.play(Paths.sound('finaleAdaptiveMus/bells_1'));
							}
							pads = FlxG.sound.play(Paths.sound('finaleAdaptiveMus/pads_1'));
						}
						else
						{
							bells.stop();
							bells = FlxG.sound.play(Paths.sound('finaleAdaptiveMus/bells_1'));
						}
						trace("Le Bells & Pads");
					}
					if (curBeat % 128 == 0)
					{
						danger.stop();
						danger = FlxG.sound.play(Paths.sound('finaleAdaptiveMus/danger-loop'), 0.1);
						trace("Le Danger | Volume = " + danger.volume);
					}
			}
		}
		else if (!resultsPresent && curSong == "Mic Test")
		{
			switch (curBeat)
			{
				case 8:
					//if (FlxG.save.data.weekUnlocked <= 2 && isStoryMode)
					if (deaths <= 0 && !hasReset)
					{
						if (needSkip)
							FlxTween.tween(skipText, {alpha: 0}, 0.3, {ease: FlxEase.sineInOut});
						new FlxTimer().start(0.025, function(tmr:FlxTimer)
						{
							tutorialGraphicA.alpha += 0.085;
							if (tutorialGraphicA.alpha < 1)
							{
								tmr.reset(0.025);
							}
							else
							{
								//Just traces a mesage for debugging purposes/
								//trace('Created Tutorial Tip A');
							}
						});
					}
				case 20:
					//if (FlxG.save.data.weekUnlocked <= 2 && isStoryMode)
					if (deaths <= 0 && !hasReset)
					{
						if (needSkip)
							FlxTween.tween(skipText, {alpha: 1}, 0.3, {ease: FlxEase.sineInOut});
						new FlxTimer().start(0.025, function(tmr:FlxTimer)
						{
							tutorialGraphicA.alpha -= 0.09;
							if (tutorialGraphicA.alpha > 0)
							{
								tmr.reset(0.025);
							}
							else
							{
								//Just traces a mesage for debugging purposes/
								//trace('Removed Tutorial Tip A');
								tutorialGraphicA.destroy();
							}
						});
					}
				case 24:
					//if (FlxG.save.data.weekUnlocked <= 2 && isStoryMode)
					if (deaths <= 0 && !hasReset)
					{
						if (needSkip)
							FlxTween.tween(skipText, {alpha: 0}, 0.3, {ease: FlxEase.sineInOut});
						new FlxTimer().start(0.025, function(tmr:FlxTimer)
						{
							tutorialGraphicB.alpha += 0.085;
							if (tutorialGraphicB.alpha < 1)
							{
								tmr.reset(0.025);
							}
							else
							{
								//Just traces a mesage for debugging purposes/
								//trace('Created Tutorial Tip B');
							}
						});
					}
				case 39:
					//if (FlxG.save.data.weekUnlocked <= 2 && isStoryMode)
					if (deaths <= 0 && !hasReset)
					{
						if (needSkip)
							FlxTween.tween(skipText, {alpha: 1}, 0.3, {ease: FlxEase.sineInOut});
						new FlxTimer().start(0.025, function(tmr:FlxTimer)
						{
							tutorialGraphicB.alpha -= 0.09;
							if (tutorialGraphicB.alpha > 0)
							{
								tmr.reset(0.025);
							}
							else
							{
								//Just traces a mesage for debugging purposes/
								//trace('Removed Tutorial Tip B');
								tutorialGraphicB.destroy();
							}
						});
					}
				case 40:
					//if (FlxG.save.data.weekUnlocked <= 2 && isStoryMode)
					if (deaths <= 0 && !hasReset)
					{
						if (needSkip)
							FlxTween.tween(skipText, {alpha: 0}, 0.3, {ease: FlxEase.sineInOut});
						new FlxTimer().start(0.025, function(tmr:FlxTimer)
						{	
							tutorialGraphicC.alpha += 0.085;
							if (tutorialGraphicC.alpha < 1)
							{
								tmr.reset(0.025);
							}
							else
							{
								//Just traces a mesage for debugging purposes/
								//trace('Created Tutorial Tip C');
							}
						});
					}
				case 52:
					//if (FlxG.save.data.weekUnlocked <= 2 && isStoryMode)
					if (deaths <= 0 && !hasReset)
					{
						if (needSkip)
							FlxTween.tween(skipText, {alpha: 1}, 0.3, {ease: FlxEase.sineInOut});
						new FlxTimer().start(0.025, function(tmr:FlxTimer)
						{
							tutorialGraphicC.alpha -= 0.09;
							if (tutorialGraphicC.alpha > 0)
							{
								tmr.reset(0.025);
							}
							else
							{
								//Just traces a mesage for debugging purposes/
								//trace('Removed Tutorial Tip C');
								tutorialGraphicC.destroy();
							}
						});
					}
			}
		}

		if (gfSpeed > 0)
			if (curBeat % gfSpeed == 0)
					gf.dance();

		//(IDK???)> (╯°□°）╯︵ ┻━┻
		if ((!boyfriend.animation.curAnim.name.startsWith('sing') && (boyfriend.animation.curAnim.name != "hurt" && !boyfriend.animation.curAnim.name.startsWith("dodge") || boyfriend.animation.curAnim.finished)) && curBeat % idleBeat == 0 && !midsongCutscene)
		{
			boyfriend.playAnim('idle', idleToBeat);
			//trace("Idle (line 8468)");
		}

		// yes this updates every ~~step~~ beat.
		// yes this is bad (but less bad compared to updating every step)
		// but i'm doing it to update misses and accuracy (bro it's discord, nobody would mind)
		#if windows

		// Updating Discord Rich Presence (with Time Left)
		if (FlxG.save.data.showPresence && !paused && !resultsPresent)
		{
			DiscordClient.changePresence(detailsText
				+ " "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"\nAcc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, "", true,
				songLength
				- Conductor.songPosition);
		}
		#end

		switch (curStage)
		{
			case "border":
				if (FlxG.save.data.distractions)
				{
					if (curSong == "Retaliation")
					{
						if (songClimax)
							bottomBoppers.animation.play('dance', true);
						else if (!songClimax && bottomBoppers.animation.curAnim.name != "idle")
							bottomBoppers.animation.play('idle', true);
					}
				}
			case "cityskyline":
				if (FlxG.save.data.distractions)
				{
					/*if (!trainMoving)
						trainCooldown += 1;*/

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

				/*if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					if (FlxG.save.data.distractions)
					{
						trainCooldown = FlxG.random.int(-4, 0);
						trainStart();
					}
				}*/
		}

		if (allowRandomGlitchFunction && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			if (FlxG.save.data.distractions && !midsongCutscene && !resultsPresent && !boyfriend.animation.curAnim.name.startsWith('sing'))
			{
				lightningStrikeShit();
			}
		}
	}

	var curLight:Int = 0;
}
