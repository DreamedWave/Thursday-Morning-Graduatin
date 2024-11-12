package;

//YOUR playstate. (writing this so that you dont get confused)
/*
IMPORTANT NOTES!!!

FIX LE BUGS:
[/]   FIX THE HECKING TUTORIAL TWEENS
[/]   FIX THE LOADONG THING NOT SJOWOMG (OFFSETS)
[/]   GOKSBOSO FIX THE FUCKING STARTING COUNDTOWN SHIT IM PISSED OFF FJIDSGBSJ
[/]   Fix the enemy miss shit
[/]   Crashing when endsong() happens [Hint: It's probably because of the miscs shit ya just added! (YEP!)]
[/]   Crashing when finale loops (Fixed once, but broke again in 3/31/2022. I assume it's because of the caching again-? maybe-?)
[/]   Fix finale not playing the chart again (figure out what makes the charts play)
[/]	  Finale not playing notes after it loops
[/]   Fix Finale making notes too tiiiny (WHAT)
[ ]   Make Finale be able to infinitely loop without crashes and shit
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
[ ]   Redo popupscore sprite
[ ]   Update gameplaycustomizestate to change based on if optimized mode/midscroll is on
[/]   Add a "night mode" that turns on everytime the clock detects it's late
[/]   Lower lowHPHeartBeat volume
[ ]   Make lowHPHeartBeat volume adapt based on the song's amplitude
[/]   Increase lowHPHeartBeat volume by 1 or 2 db
[/]   Make it so that the adaptiveMus volume is at 100% when hp is showing the cross eyed icons
[/]   Fix "shit" sustain notes lagging (probably because it calculates both the parent and the children at the same time)

YO herre's the pitch change thing I found.
		#if cpp
		@:privateAccess
		{
			if (FlxG.sound.music.playing)
				lime.media.openal.AL.sourcef(FlxG.sound.music._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, |[pitch here]|);
		}
		#end
*/
import Song.Event;
import openfl.media.Sound;
import lime.media.openal.AL;
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

	private static var preloadCheck:Bool = false;
	private static var songsPlayedIn:Array<String> = [];
	//For Oneshot Preloads

	var songPosGroup = new FlxTypedGroup<FlxSprite>();
	var songPosBG:FlxSprite;
	var songPosBar:FlxBar;
	var songPosDeathIndicator:FlxSprite;
	var songDurationTxt:FlxText;
	private var songPositionBar:Float = 0;
	var songLength:Float = 0;

	public static var rep:Replay;
	//public static var loadRep:Bool = false;
	public static var inResults:Bool = false;
	public static var resultsPresent:Bool = false;
	private var skippedShit:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	var songNameTXT:FlxText;

	#if windows
	// Discord RPC variables
	var storyDifficultyText:String = "";
	//var iconRPC:String = "";
	var detailsText:String = "";
	#end

	var musicGroup:FlxSoundGroup;
	//var vocalsGroup:FlxSoundGroup;
	//var gameplaySFXGroup:FlxSoundGroup;
	//for the adaptive Music
	private var instLowHP:FlxSound;
	//For the FNF voices
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
	public static var pauseMusicName:String = "";//Here cause preloading LMAO
	//FINALE BATTLE SH THIT
	private var dangerLevel:Float = 0;
	var enemyHealth:Float = 100;

	public static var isSM:Bool = false;
	#if sys
	public static var sm:SMFile;
	public static var pathToSm:String;
	#end

	public var originalScoreTxtX:Float;

	public static var dad:Character;
	var dadSwaperoo:String = "";
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

	private var camFollow:FlxObject;
	private static var prevCamFollow:FlxObject;
	private var dadCamFollowOffsetX:Float = 0;
	private var dadCamFollowOffsetY:Float = 0;
	private var bfCamFollowOffsetX:Float = 0;
	private var bfCamFollowOffsetY:Float = 0;
	private var camFollowSpeed:Float = 0.04; //The higher the number is, the faster the camera moves
	private var prevCamFollowSpeed:Float = 0.04;
	private var camFollowing:Bool = true;
	private var camTween:FlxTween;
	//private static var camTweened:Bool;

	private var triggeredCamShake:Bool = false;

	var grpStrumLine:FlxTypedGroup<FlxSprite> = null;
	public static var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public static var playerStrums:FlxTypedGroup<FlxSprite> = null;
	public var cpuStrums:FlxTypedGroup<FlxSprite> = null;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;

	public var health:Float = 1; // making public because sethealth doesnt work without it
	var healthLerp:Float = 1; //So that health changes are smoother
	public static var prevHealth:Float = 1;
	var allowHealthModifiers:Bool = true;

	private var combo:Int = 0;

	public static var misses:Int = 0;
	public static var campaignMisses:Int = 0;

	public static var deaths:Int = 0;
	public static var hasReset:Bool = false;
	public static var showedLoadSprInCurSong:Bool = false;

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

	private var generatedMusic:Bool = false;
	private var generatedArrows:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon; // making these public again because i may be stupid
	public var iconP2:HealthIcon; // what could go wrong?
	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var camMiscs:FlxCamera;

	public static var cannotDie = false;
	public static var toggledPracticeMode = false;

	public var isSMFile:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;
	var idleToBeat:Bool = true; // change if bf and dad would idle to the beat of the song
	var idleBeat:Int = 2; // how frequently bf and dad would play their idle animation(1 - every beat, 2 - every 2 beats and so on)

	var theBorderBG:FlxSprite;

	var cityLights:FlxTypedGroup<FlxSprite>;
	var curLight:Int = 0;
	var cityStreets:FlxSprite;
	var hurtVignette:FlxSprite;
	var stageOverlay:FlxSprite;
	var blackScreen:FlxSprite;
	var blackScreenAlpha:Float = (!Main.nightMode && !FlxG.save.data.nightmode ? 0 : 0.3);
	var stageGradient:PsychEngineFancyStageShit.FancyStageGradient;
	var stageParticles:FlxTypedGroup<PsychEngineFancyStageShit.FancyStageParticle>;
	var stageSound:FlxSound;
	//Making this public static??? cause making this visible in the pause menu wouldnt work
	public static var safeVignette:FlxSprite;

	var bgBoppers2:FlxSprite;
	var bgBoppers1:FlxSprite;

	var dummyBlackScreen:FlxSprite;
	//For stage-only fade outs

	var midsongCutscene:Bool = false;
	private var hitsoundType:String = "";
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

	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	//var replayTxt:FlxText;

	//var inSubstate:Bool = false;

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

	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

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

	var loadingIcon:FlxSprite;
	var lagCompIcon:FlxSprite;

	public static var highestCombo:Int = 0;

	// Animation common suffixes
	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

	public static var startTime:Float = 0.0;

	var video:MP4Handler;
	var videoMusic:FlxSound;

	var allowBGBopping:Bool = false;
	var triggeredAlready:Bool = false;
	var enemyCanFail:Bool = true;//temp, change to false later

	//var countdownTimer:FlxTimer;
	var compensationTimer:FlxTimer;

	//songlowercase
	var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();

	var flashColor:FlxColor = FlxColor.WHITE;

	//A story about this: I was gonna actually tween and trail GUY's dodge but like it didn't work and just pooled the memory so nah I just animated him sliding
	//var dodgeTween:FlxTween;
	//var dodgeTimer:FlxTimer;

	//Making this void (1)
	//Actually, Don't make this void cause it breaks cam follow(?) the cam follow shit :)))
	override public function create()
	{	
		instance = this;

		flashColor = (!Main.nightMode && !FlxG.save.data.nightmode ? flashColor : 0xFF836666);
		noteHitVolume = FlxG.save.data.notesfxVol * 0.01;

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
		songStarted = false;

		PauseSubState.resyncToLastPos = false;

		highestCombo = 0;
		repPresses = 0;
		repReleases = 0;
		timesShot = 0;
		inResults = false;
		if (resultsPresent)
			resultsPresent = false;

		PlayStateChangeables.useDownscroll = FlxG.save.data.downscroll;
		PlayStateChangeables.safeFrames = FlxG.save.data.frames;
		PlayStateChangeables.safeZoneOffset = (PlayStateChangeables.safeFrames / 60) * 1000;
		PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed;
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
				detailsText = "Story Mode: (Part " + storyWeek + ") | ";
			else
				detailsText = "Freeplay | ";

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
		camMiscs = new FlxCamera();

		camHUD.bgColor.alpha = 0;
		camMiscs.bgColor.alpha = 0;
		
		if (!playedCutscene && storyPlaylist.length > 2 && isStoryMode)
		{
			camHUD.alpha = 0;
			camGame.alpha = 0;
			blackScreenAlpha = 1;
			//trace("Le cams alpha 0");
		}
		else if (storyPlaylist.length <= 2 && isStoryMode)
			health = prevHealth;
		//else
		//{
			//camHUD.alpha = 1;
			//trace("Le cams alpha 1");
		//}
		//camHUD.x = 40;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camMiscs);

		FlxCamera.defaultCameras = [camGame];

		//The detail thing that appears when you get shot
		hurtVignette = new FlxSprite().loadGraphic(Paths.image('gotShot', 'week3'));
		hurtVignette.scale.x *= 0.75;
		hurtVignette.scale.y *= 0.75;
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
		safeVignette.updateHitbox();
		if(FlxG.save.data.antialiasing)
		{
			safeVignette.antialiasing = true;
		}
		safeVignette.screenCenter();
		safeVignette.alpha = 0.65;
		safeVignette.blend = ADD;
		safeVignette.visible = false;
		add(safeVignette);

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial', 'tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		defaultScrollSpeed = (PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed);

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
					camPos.x += -650;
					camPos.y += -200;
					//tweenCamIn();
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
							stageOverlay = new FlxSprite(camGame.width * -0.33 + 80, camGame.height * -0.4 + 50);
							stageOverlay.setGraphicSize(Std.int(stageOverlay.width));
							stageOverlay.alpha = 0.6;
							theBorderBG.alpha = 0.75;
						case 'retaliation':
							defaultCamZoom = 0.815;
							stageOverlay = new FlxSprite(camGame.width * -0.33 + 120, camGame.height * -0.4 + 80);
							stageOverlay.setGraphicSize(Std.int(stageOverlay.width * 0.9));
							stageOverlay.alpha = 1;
							theBorderBG.alpha = 0.5;
							//Boppers

							var bopperFrames = Paths.getSparrowAtlas('theborder_people', 'week2');

							bgBoppers1 = new FlxSprite(-380, 590);
							bgBoppers1.frames = bopperFrames;
							bgBoppers1.animation.addByPrefix('idle', 'Idle', 18, true);
							bgBoppers1.animation.addByPrefix('dance', 'Bop', 24, false);
							bgBoppers1.scrollFactor.set(0.9, 0.9);
							//bgBoppers1.setGraphicSize(Std.int(bgBoppers1.width * 0.9));
							bgBoppers1.updateHitbox();
							/*if(FlxG.save.data.antialiasing)
							{
								bgBoppers1.antialiasing = true;
							}*/
							//I turned this off cause lag, hopefully it works.
							if (FlxG.save.data.distractions)
							{
								add(bgBoppers1);
							}
							bgBoppers1.animation.play("idle");
							bgBoppers1.alpha = 0;
						default:
							defaultCamZoom = 0.8;
							stageOverlay = new FlxSprite(camGame.width * -0.33, camGame.height * -0.35 + 20);
							stageOverlay.setGraphicSize(Std.int(stageOverlay.width * 1.5));
							stageOverlay.alpha = 0.35;
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

					stageOverlay.frames = Paths.getSparrowAtlas('vignette_black', 'week2');
					stageOverlay.updateHitbox();
					if(FlxG.save.data.antialiasing)
					{
						stageOverlay.antialiasing = true;
					}
					stageOverlay.scrollFactor.set(0.1, 0.1);
					stageOverlay.animation.addByPrefix('vignette', 'vignette', 1, true);
					stageOverlay.animation.play('vignette');
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

					var city:FlxSprite = new FlxSprite(-120, -85).loadGraphic(Paths.image('theCity/city', 'week3'));
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

					stageOverlay = new FlxSprite(-301, -180);
					stageOverlay.frames = Paths.getSparrowAtlas('theCity/vignette', 'week3');
					stageOverlay.scrollFactor.set(0, 0);
					stageOverlay.setGraphicSize(Std.int(stageOverlay.width * 0.85));
					stageOverlay.animation.addByPrefix('static', 'vignette justBlack');
					if (FlxG.save.data.flashing)
						stageOverlay.animation.addByPrefix('warning', 'vignette warnPlayer flashRed', 24, true);
					else
						stageOverlay.animation.addByPrefix('warning', 'vignette warnPlayer flashRed', 15, false);
					stageOverlay.animation.addByPrefix('singleFlash', 'vignette warnPlayer flashRed', 12, false);
					//stageOverlay.blend = MULTIPLY;
					stageOverlay.animation.play('static');
					if(FlxG.save.data.antialiasing)
						stageOverlay.antialiasing = true;
				case 'theCityPortal':
					curStage = 'cityskylineVariegated';
					defaultCamZoom = 0.81;

					//X [LEFT or RIGHT]: Negative is LEFT, while postitive is RIGHT. (Same as the Cartesian Plane's)
					//Y [UP or DOWN]: Negative is UP, while positive is DOWN. (Inverted as the Cartesian Plane's)

					//                                 X    Y
					var bg:FlxSprite = new FlxSprite(-140, -80).loadGraphic(Paths.image('theCityPortalOpen/sky_variegated', 'week3'));
					bg.scrollFactor.set(0.1, 0.1);
					if(FlxG.save.data.antialiasing)
						bg.antialiasing = true;
					bg.active = false;
					add(bg);

					var city:FlxSprite = new FlxSprite(-120, -85);
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
					stageOverlay = new FlxSprite(-301, -180);
					stageOverlay.frames = Paths.getSparrowAtlas('theCity/vignette', 'week3');
					stageOverlay.scrollFactor.set(0, 0);
					stageOverlay.setGraphicSize(Std.int(stageOverlay.width * 0.85));
					stageOverlay.animation.addByPrefix('static', 'vignette justBlack');
					if (FlxG.save.data.flashing)
						stageOverlay.animation.addByPrefix('warning', 'vignette warnPlayer flashRed', 24, true);
					else
						stageOverlay.animation.addByPrefix('warning', 'vignette warnPlayer flashRed', 15, false);
					stageOverlay.animation.addByPrefix('singleFlash', 'vignette warnPlayer flashRed', 12, false);
					stageOverlay.animation.play('static');
					if(FlxG.save.data.antialiasing)
						stageOverlay.antialiasing = true;

					dummyBlackScreen = new FlxSprite(-FlxG.width * defaultCamZoom,
						-FlxG.height * defaultCamZoom).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
					dummyBlackScreen.scrollFactor.set();
					dummyBlackScreen.alpha = 0;
					dummyBlackScreen.active = false;
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
						parralax2.antialiasing = true;
					parralax2.scrollFactor.set(0.92, 0.92);
					parralax2.active = false;
					add(parralax2);
					
					var shading1:FlxSprite = new FlxSprite(-395, -190).loadGraphic(Paths.image('house/BlendLight_Window1', 'week4'));
					shading1.setGraphicSize(Std.int(shading1.width * 0.76));
					shading1.updateHitbox();
					if(FlxG.save.data.antialiasing)
						shading1.antialiasing = true;
					shading1.scrollFactor.set(0.3, 0.3);
					shading1.blend = ADD;
					shading1.alpha = 0.6;
					shading1.active = false;
					add(shading1);

					var shading2:FlxSprite = new FlxSprite(-395, -190).loadGraphic(Paths.image('house/BlendLight_Window2', 'week4'));
					shading2.setGraphicSize(Std.int(shading2.width * 0.76));
					shading2.updateHitbox();
					if(FlxG.save.data.antialiasing)
						shading2.antialiasing = true;
					shading2.scrollFactor.set(0.35, 0.35);
					shading2.blend = ADD;
					shading2.active = false;
					add(shading2);
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
					if(FlxG.save.data.antialiasing)
						stageBG.antialiasing = true;
					stageBG.scrollFactor.set(0.7, 0.7);
					stageBG.active = false;
					add(stageBG);

					var stageFloor:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('graduation/graduation_front', 'week1'));
					stageFloor.setGraphicSize(Std.int(stageFloor.width * 1.1));
					stageFloor.updateHitbox();
					if(FlxG.save.data.antialiasing)
						stageFloor.antialiasing = true;
					stageFloor.scrollFactor.set(0.9, 0.9);
					stageFloor.active = false;
					add(stageFloor);

					stageOverlay = new FlxSprite(-490, -300).loadGraphic(Paths.image('graduation/graduation_overlay', 'week1'));
					stageOverlay.setGraphicSize(Std.int(stageOverlay.width * 0.9));
					stageOverlay.updateHitbox();
					if(FlxG.save.data.antialiasing)
						stageOverlay.antialiasing = true;
					stageOverlay.scrollFactor.set(1.3, 1.3);
					stageOverlay.active = false;

					//move this after (add bf and add dad, and also rename 'vignette' to secondstagelayer/stageoverlay or sum shit)
					//add(stageCurtains);
					//done!
			}

			//Layering for stages LOL
			if (songLowercase != 'sudden-confrontation' && songLowercase != 'sprouting-irritation')
				add(gf);

			if (curStage == 'cityskyline')
				add(cityStreets);
			else if (curStage == 'cityskylineVariegated')
			{
				add(cityStreets);
				add(dummyBlackScreen);
			}

			add(dad);
			add(boyfriend);

			switch (curStage)
			{
				case 'stage' | 'border' | 'cityskyline' | 'cityskylineVariegated':
					add(stageOverlay);
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
			switch (storyWeek)
			{
				//BG for Usual Rhythm Game BG
				case 2:
					stageBG = new FlxSprite().loadGraphic(Paths.image('optimBG', 'week2'));
				case 3:
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
			stageBG.alpha = 0.2;
			add(stageBG);
		}

		blackScreen = new FlxSprite(-FlxG.width * camGame.zoom,
			-FlxG.height * camGame.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
		blackScreen.scrollFactor.set();
		blackScreen.alpha = blackScreenAlpha;
		add(blackScreen);
		if (camGame.alpha == 0)
			camGame.alpha = 1;

		//Skip Intro Shit
		var firstNoteTime = Math.POSITIVE_INFINITY;
		var playerTurn = false;
		for (index => section in SONG.notes)
		{
			if (section.sectionNotes.length > 0 && !isSM)
			{
				if ((storyWeek != 6 && (storyWeek < FlxG.save.data.weekUnlocked || (deaths > 0 || hasReset))) || (storyWeek >= 6 || !isStoryMode))
				{
					if (section.startTime > Conductor.crochet * 16 && SONG.bpm >= 170 || section.startTime > Conductor.crochet * 8 && SONG.bpm < 170)
					{
						needSkip = true;
						skipTo = section.startTime - Conductor.crochet * 4;
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

		grpStrumLine = new FlxTypedGroup<FlxSprite>();
		add(grpStrumLine);

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

		//trace('generated');

		// add(strumLine);

		//this was where the cameradata was

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		//TIMESTEP?!?!?!?!?!
		//Lag spikes happen in specific spots after specific actions when timestep is on
		//Have not tested it for off yet tho, it is literally 3 am now
		//I fukked somethin up
		FlxG.fixedTimestep = false;



		//Adding Offsets Again      V //Ploink
		healthBarBG = new FlxSprite(50, FlxG.height * 0.91).loadGraphic(Paths.image('healthBar'));
		if (PlayStateChangeables.useDownscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		healthBarBG.antialiasing = true;
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		healthBar.antialiasing = true;
		add(healthBar);

		subtitleText = new FlxText(healthBarBG.x + 70, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 85 : -85), 0);
		defaultSubTxtY = subtitleText.y;
		subtitleText.text = "";
		if(FlxG.save.data.antialiasing)
			subtitleText.antialiasing = true;
		subtitleText.setFormat(Paths.font("playtime.ttf"), 38, CENTER);
		if (FlxG.save.data.centersubtitles)
			subtitleText.x = healthBarBG.x + (healthBarBG.width - subtitleText.width) / 2;
		subtitleText.color = FlxColor.WHITE;
		subtitleText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3, 1);
			subtitleText.cameras = [camMiscs];

		subtitleBackground = new FlxSprite(subtitleText.x, subtitleText.y).makeGraphic(1, 1, FlxColor.BLACK);
		subtitleBackground.cameras = [camMiscs];
		subtitleBackground.alpha = 0;

		// Add Kade Engine watermark
		songNameTXT = new FlxText(4, 0, 0,
			SONG.song
			+ " - "
			+ CoolUtil.difficultyFromInt(storyDifficulty), 16);
		songNameTXT.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
		songNameTXT.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1.3);
		songNameTXT.scrollFactor.set();
		songNameTXT.y = (!PlayStateChangeables.useDownscroll ? FlxG.height - songNameTXT.height - 4 : songNameTXT.height + 4);
		add(songNameTXT);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - 75;
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - 75;
		add(iconP2);

		scoreTxt = new FlxText(healthBarBG.x - 35 + healthBar.width / 4, healthBarBG.y + 40, 0, "", 20);
		originalScoreTxtX = scoreTxt.x;
		scoreTxt.scrollFactor.set();
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER);
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
		botPlayText.x = healthBarBG.x + (healthBarBG.width - botPlayText.width) / 2;
		if (PlayStateChangeables.botPlay)
			add(botPlayText);

		//Song-dependent tutorial cards
		switch (songLowercase)
		{
			case 'mic-test':
				//	Tutorial Graphics that appear in famous hits such as: "Tutorial", and "nothing else lmao just tutorial"
				//	For the first tutorial popup
				if (!PlayStateChangeables.Optimize)
					tutorialGraphicA = new FlxSprite().loadGraphic(Paths.image('infocards/TutorialTipA', 'tutorial'));
				else
					tutorialGraphicA = new FlxSprite().loadGraphic(Paths.image('infocards/TutorialTipA_MiddleScroll', 'tutorial'));
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

				tutorialGraphicA.cameras = [camHUD];
				tutorialGraphicB.cameras = [camHUD];
				tutorialGraphicC.cameras = [camHUD];

				tutorialText = new FlxText(0, 0, -0);
				tutorialText.text = '${FlxG.save.data.leftBind}       ${FlxG.save.data.downBind}       ${FlxG.save.data.upBind}       ${FlxG.save.data.rightBind}';
				if (!PlayStateChangeables.Optimize)
					tutorialText.x = healthBarBG.x + healthBarBG.width / 2 + iconP1.width - 20;
				else
					tutorialText.screenCenter(X);
				tutorialText.y = tutorialGraphicA.x + tutorialText.height;
				tutorialText.antialiasing = true;
				tutorialText.setFormat(Paths.font("playtime.ttf"), 50, CENTER);
				tutorialText.color = FlxColor.YELLOW;
				tutorialText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 6, 6);
				tutorialText.cameras = [camHUD];
				tutorialText.alpha = 0;
			case 'playing-with-fire':
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
				avoidBulletTipGraphic.cameras = [camHUD];
		}

		//LoadingNextSong
		loadingIcon = new FlxSprite().loadGraphic(Paths.image('loadingNextSong'));
		loadingIcon.setGraphicSize(Std.int(loadingIcon.width * 0.5));
		//loadingIcon.screenCenter();
		loadingIcon.x = FlxG.width - loadingIcon.width / 2;
		loadingIcon.y = FlxG.height - loadingIcon.height / 2;
		loadingIcon.scrollFactor.set();
		loadingIcon.updateHitbox();
		if (FlxG.save.data.antialiasing)
			loadingIcon.antialiasing = true;
		//loadingIcon.screenCenter();
		loadingIcon.cameras = [camMiscs];
		add(loadingIcon);
		if (showedLoadSprInCurSong)
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
			lagCompIcon.cameras = [camMiscs];
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
		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		//replayTxt.cameras = [camHUD];
		botPlayText.cameras = [camMiscs];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		//doof.cameras = [camHUD];
		songNameTXT.cameras = [camHUD];

		startingSong = true;

		//trace('starting');

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
		camGame.zoom = defaultCamZoom;
		camGame.focusOn(camFollow.getPosition());
		camGame.follow(camFollow, LOCKON);
		//trace("CamFollowLerp was " + FlxG.camera.followLerp);
		camGame.followLerp = camFollowSpeed * (30 / FlxG.save.data.fpsCap);
		//trace("and is now " + FlxG.camera.followLerp);

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

			/*FlxG.signals.focusGained.add(function()
			{
				focusIn();
			});
			FlxG.signals.focusLost.add(function()
			{
				focusOut();
			});*/
		}

		//Song Start Events
		if (!PlayStateChangeables.Optimize)
		{
			//trace("Song Startup Shit");
			//trace("'Played Cutscene' is " + playedCutscene);
			//if (!hasReset && deaths <= 0 && storyPlaylist.length <= 2)
			//	camMiscs.bgColor = 0xFFF0EFAB;

			switch (songLowercase)
			{
				case 'mic-test':
					add(tutorialGraphicA);
					add(tutorialGraphicB);
					add(tutorialGraphicC);
					add(tutorialText);
					startCountdown();
					hasSubtitles = true;
				case 'tech.-difficulties':
					if (isStoryMode && !playedCutscene)
					{
						inCutscene = true;
						playedCutscene = true;
						FlxTween.tween(loadingIcon, {alpha: 0}, 0.1, {type: ONESHOT, ease: FlxEase.smootherStepIn, onComplete: function(twn:FlxTween)
						{
							video =	 new MP4Handler();
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
					dadSwaperoo = "priest-theborderannoyed";
					hasSubtitles = true;
					if (isStoryMode && !playedCutscene)
					{
						inCutscene = true;
						playedCutscene = true;
						FlxTween.tween(loadingIcon, {alpha: 0}, 0.1, {type: ONESHOT, ease: FlxEase.smootherStepIn, onComplete: function(twn:FlxTween)
						{
							video = new MP4Handler();
							if (FlxG.save.data.flashing)
								video.playVideo(Paths.video('week2/startcutscene'));
							else
								video.playVideo(Paths.video('week2/startcutscene-noFlash'));
							video.finishCallback = function()
							{
								loadingIcon.alpha = 0;
								desperationIntro();
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
						prevHealth = 1;
						camHUD.alpha = 0;
						blackScreen.alpha = 1;
						//loadingIcon.alpha = 0;
						//blackScreen.alpha = 1;
						inCutscene = true;
						playedCutscene = true;
						loadingIcon.alpha = 0;
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
					health = 1;
					prevHealth = 1;
					camFollowSpeed = 0.01;
					hasSubtitles = true;
					//trace("TO " + camFollowSpeed);
					if (isStoryMode && !playedCutscene)
					{
						camHUD.alpha = 0;
						loadingIcon.alpha = 0;
						blackScreen.alpha = 1;
						inCutscene = true;
						//This is here cause the previous song ends with a black screen
						FlxTween.tween(loadingIcon, {alpha: 0}, 0.1, {type: ONESHOT, ease: FlxEase.smootherStepIn, onComplete: function(twn:FlxTween)
						{
							videoMusic = FlxG.sound.play(Paths.videoMusic('week2/midcutscene2-MUSIC'));
							videoMusic.autoDestroy = true;
							videoMusic.looped = false;
							video = new MP4Handler();
							video.playVideo(Paths.video('week2/midcutscene2'), false, false);
							video.finishCallback = function()
							{
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
					if (!playedCutscene)
						add(avoidBulletTipGraphic);
					startCountdown();
					camZooming = true;
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
		}
		else
		{
			startCountdown();
			camZooming = true;
		}

		//if (!loadRep)
		rep = new Replay("na");

		if (hasSubtitles && FlxG.save.data.subtitles)
		{
			add(subtitleBackground);
			add(subtitleText);
		}

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);

		super.create();

		if (FlxG.save.data.pauseOnUnfocus)
		{
			if (delayAutoPause)
			{
				playedCutscene = true;
				FlxG.autoPause = false;
			}
			else
				FlxG.autoPause = true;
		}

		defaultMashingThreshold = storyDifficulty * 5 * -1 + (20 + Math.round(DiffCalc.CalculateDiff(SONG)));
		noteMashingThreshold = defaultMashingThreshold;

		//Preloading Sounds and Music (to prevent laggy euGh  AHFHGAGJMNOmnSKDVkks yes)
		//i am going insane (at how unsure I am if this is good or not [clarified by future me to prevent any concerned parents hehe])
		//i think i made it as robiust (haha bust) as it can
		//nvm i found out that psych did it better *cries*

		musicGroup = new FlxSoundGroup(1);

		switch (storyWeek)
		{
			case 2:
				pauseMusicName = 'pauseScreen/callous_desperation';
			case 3:
				pauseMusicName = 'pauseScreen/heated_stalemate';
			default:
				pauseMusicName = 'pauseScreen/bathroom_break';
		}

		//Caching the game stuffs
		var preloadList:Map<String, String> = new Map<String, String>();
		var daImageShitData:Map<String,FlxGraphic> = new Map<String,FlxGraphic>();
		//Sounds
		//Per-song load
		if (!songsPlayedIn.contains(songLowercase))
		{
			songsPlayedIn.push(songLowercase);
			#if debug
			trace ("pushed " + songLowercase);
			trace ("preloading shits!");
			#end
			if (!FlxG.save.data.cacheMusic)
			{
				preloadList.set(PlayState.SONG.song, 'inst');
				if (SONG.needsVoices)
					preloadList.set(PlayState.SONG.song, 'voices');
				if (SONG.needsMiscs)
					preloadList.set(PlayState.SONG.song, 'miscs');
				if (SONG.needsAdaptiveMus)
					preloadList.set(PlayState.SONG.song, 'adaptiveMus');
			}

			switch (SONG.song)
			{
				case "Desperation" | "Disagreement" | "Retaliation":
					if (songsPlayedIn.length >= 0)
					{
						preloadList.set('glitch_1', 'sound');
						preloadList.set('glitch_2', 'sound');
					}
				case "Variegated Skylines":
					var leLoopCount:Int = 0;
					for (i in 0...9)
					{
						preloadList.set('stageParticle_' + leLoopCount, 'image');
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
			
			if (deaths <= 0)
			{
				//Le GameOver Music and SFX
				preloadList.set("deathsound" + stageSuffix, 'sound');
				preloadList.set("gameOver" + stageSuffix, 'music');
				preloadList.set("gameOver" + stageSuffix + "_End", 'music');
			}

			if (dadSwaperoo != "" && !FlxG.save.data.cacheImages)
				preloadList.set("characters/" + dadSwaperoo, 'image');
		}
		#if debug
		else
			trace ("wHAT A SMART DADDY~");
		#end

		lowHPHeartBeat = new FlxSound().loadEmbedded(Paths.sound('lowHP'));
		missSound = new FlxSound();

		if (!preloadCheck)
		{
			var gameplaySFX:Array<String> = ["skipSongIntro", "intro3", "intro2", "intro1", "introGo", "missnote1", "missnote2", "missnote3", "enemyMiss1", "enemyMiss2", "enemyMiss3", "GitarooFail", "GitarooPress", "GitarooHover", "practiceModeFail"]; //THANK YOU STILL BSOD#2524 FROM HAXE DISCORD SERVER!!!!
			for (i in gameplaySFX) 
				preloadList.set(i, 'sound');

			var imagesToCache:Array<String> = ["bad", "good", "miss", "noteSplashes", "shit", "sick", "skipButton", "alphabet"];
			for (i in FileSystem.readDirectory(FileSystem.absolutePath("assets/shared/images/countdown")))
				imagesToCache.push(i);
			for (i in imagesToCache) 
				preloadList.set(i, 'image');

			for (i in 0...10) 
				preloadList.set('num' + i, 'image');

			preloadCheck = true;
		}

		if (allowNoteHitSounds && FlxG.save.data.notesfx)
		{
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
			}
		}

		//CacheAllShits
		for (key => type in preloadList)
		{
			switch(type)
			{
				case 'image':
					var data:BitmapData = BitmapData.fromFile(Paths.image(key));
					var cachedImages = FlxGraphic.fromBitmapData(data);
					daImageShitData.set(key, cachedImages);
				case 'sound':
					FlxG.sound.cache(Paths.sound(key));
				case 'music':
					FlxG.sound.cache(Paths.music(key));
				case 'inst':
					FlxG.sound.cache(Paths.inst(key));
				case 'voices':
					FlxG.sound.cache(Paths.voices(key));
				case 'miscs':
					FlxG.sound.cache(Paths.miscs(key));
				case 'adaptiveMus':
					FlxG.sound.cache(Paths.adaptiveMus(key));
			}
		}
	}

	function desperationIntro():Void
	{
		generateStaticArrows(0);
		generateStaticArrows(1);
		if (blackScreen.alpha > 0 || camHUD.alpha <= 0)
		{
			FlxTween.tween(camHUD, {alpha: 1}, 1, {type: ONESHOT, ease: FlxEase.quadOut, startDelay: 0.3});
			FlxTween.tween(blackScreen, {alpha: (!Main.nightMode && !FlxG.save.data.nightmode ? 0 : 0.3)}, 1, {type: ONESHOT, ease: FlxEase.quadOut, startDelay: 0.3});
		}
		inCutscene = true;
		gf.playAnim('none', true);
		camHUD.alpha = 1;
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
					FlxG.sound.play(Paths.sound('Table_Crash'));
					gf.playAnim('fall', true);
					new FlxTimer().start(0.15, function(swagTimer:FlxTimer)
					{
						camShake(true);
						boyfriend.playAnim('scared', true);
						dad.playAnim('scared', true);
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							new FlxTimer().start(0.7, function(swagTimer:FlxTimer)
							{
								camHUD.alpha = 1;
								startCountdown();
							});
						});
					});
				});
			});
		});
	}

	function changeSubtitles(text:String, color:FlxColor = 0xFFFFFFFF, borderColour:FlxColor = 0xFF000000, blendMode:String = "NORMAL", alpha:Float = 1, bgAlpha:Float = 0.45, font:String = 'Playtime With Hot Toddies', isBold:Bool = false, isItalic:Bool = false):Void
	{
		if (hasSubtitles && FlxG.save.data.subtitles && !endedSong)
		{
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
			subtitleText.text = text;
			subtitleText.color = color;
			subtitleText.borderColor = borderColour;
			subtitleText.bold = isBold;
			subtitleText.italic = isItalic;
			subtitleText.blend = blendMode;
			subtitleText.alpha = alpha;

			if (FlxG.save.data.centersubtitles)
				subtitleText.x = healthBarBG.x + (healthBarBG.width - subtitleText.width) / 2;

			subtitleBackground.alpha = bgAlpha * subtitleText.alpha;
			subtitleBackground.scale.x = subtitleText.width + 20;
			subtitleBackground.scale.y = subtitleText.height;
			subtitleBackground.updateHitbox();

			if (PlayStateChangeables.botPlay)
			{
				botPlayText.alpha = 0.5;
				subtitleText.y = defaultSubTxtY + (PlayStateChangeables.useDownscroll ? botPlayText.height : -botPlayText.height);
			}
			/*if (needSkip && skipActive)
			{
				skipButton.alpha = 0.35;
				subtitleText.y = subtitleText.y + (PlayStateChangeables.useDownscroll ? skipButton.height : -skipButton.height);
			}*/
			subtitleText.visible = true;
			subtitleBackground.visible = true;
			subtitleBackground.x = subtitleText.x - 10;
			subtitleBackground.y = subtitleText.y;
			//scoreTxt.screenCenter(X);
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
			if (PlayStateChangeables.Optimize && FlxG.save.data.changedHitX <= funnyRatingCheckStart / 1.5 && FlxG.save.data.changedHitX >= funnyRatingCheckEnd 
			&& FlxG.save.data.changedHitY <= 0 && FlxG.save.data.changedHitY >= 113)
				funnyRatingOffset = 150;
		}

		if (!showedLoadSprInCurSong)
			FlxTween.tween(loadingIcon, {alpha: 0}, 0.3, {type: ONESHOT, ease: FlxEase.smootherStepIn, startDelay: 0.1});

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

		if (!inCutscene)
			inCutscene = true;

		if (blackScreen.alpha > 0 || camHUD.alpha <= 0)
		{
			FlxTween.tween(camHUD, {alpha: 1}, 1, {type: ONESHOT, ease: FlxEase.quadOut, startDelay: 0.3});
			FlxTween.tween(blackScreen, {alpha: (!Main.nightMode && !FlxG.save.data.nightmode ? 0 : 0.3)}, 1, {type: ONESHOT, ease: FlxEase.quadOut, startDelay: 0.3});
		}

		if (!isStoryMode || storyPlaylist.length <= 2 && SONG.song != 'Mic Test')
			camFollowShit();
		else
		{
			camFollow.x =  gf.getGraphicMidpoint().x;
			camFollow.y =  gf.getGraphicMidpoint().y;
		}
			
		startedCountdown = true;

		Conductor.songPosition = 0;

		//if (!skipCountdown)
		//{
		var swagCounter:Int = 0;
		var startTimerTime:Float = Conductor.crochet / 1000;
		if (!skipCountdown)
			Conductor.songPosition -= Conductor.crochet * 5;
		else
		{
			startTimerTime = 0;
			if (health != 1)
				health = 1;
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
			else
				inCutscene = false;
		}, 5);
		//}
		//else
		//	inCutscene = false;
		//	startTimer = new FlxTimer().start(0);
	}

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

		if (PlayStateChangeables.botPlay || paused)// || (FlxG.save.data.lagCompensation && (cast(Lib.current.getChildAt(0), Main)).getFPS() < frameRateLimit && curBeat > 4))
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
			if (notePresses > noteMashingThreshold && PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				accuracy -= 0.15;
				healthLerp -= 0.0255;
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
						note.finnaBeKilled = true;
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
				}
			}

			goodNoteHit(coolNote);
			var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
			ana.hit = true;
			ana.hitJudge = Ratings.CalculateRating(noteDiff, Math.floor(PlayStateChangeables.safeZoneOffset));
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

	public static var songStarted = false;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;

		//trace('song starteted (funct)');

		if (inCutscene)
			inCutscene = false;

		if (!FlxG.sound.music.playing) // don't restart the music if it's already playing
		{
			
			if (SONG.song != "Finale")
			{
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
				FlxG.sound.music.looped = false;
				FlxG.sound.music.onComplete = endSong;
			}
			else
			{
				playFinaleMusic();
				FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
				FlxG.sound.music.looped = true;
				FlxG.sound.music.autoDestroy = false;
				FlxG.sound.music.onComplete = regenerateSong;
			}
		}
		musicGroup.add(FlxG.sound.music);

		//le subtitle shti 2
		doSubtitleShit();

		instLowHP.time = FlxG.sound.music.time;
		instLowHP.play();
		musicGroup.add(instLowHP);
		vocals.play();
		miscs.play();
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
			songPosGroup = new FlxTypedGroup<FlxSprite>();
			add(songPosGroup);

			songPosBG = new FlxSprite(0, 10).loadGraphic(Paths.image('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height - songPosBG.height - 10;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();

			songPosBar = new FlxBar(songPosBG.x
				+ 4, songPosBG.y
				+ 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength
				- 1000);
			songPosBar.numDivisions = 1000;
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(0xFF333333, 0xFFeb829c);

			songPosDeathIndicator = new FlxSprite(-1000, 10).loadGraphic(Paths.image('timePosBar_DeathMarker'));
			if(!PlayStateChangeables.useDownscroll)
			{
				songPosDeathIndicator.flipY = true;
				songPosDeathIndicator.y = songPosBar.y;
			}
			else
				songPosDeathIndicator.y = songPosBar.y - 40;
			if(FlxG.save.data.antialiasing)
				songPosDeathIndicator.antialiasing = true;

			songDurationTxt = new FlxText(songPosBG.x, songPosBG.y - 6, 0, "--:--", 16);
			songDurationTxt.x = songPosBG.x + (songPosBG.width - songDurationTxt.width) / 2;
			if (PlayStateChangeables.useDownscroll)
				songDurationTxt.y -= 6;
			songDurationTxt.setFormat(Paths.font("vcr.ttf"), 30, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			songDurationTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3, 3);
			songDurationTxt.scrollFactor.set();

			songPosBG.cameras = [camHUD];
			songPosBar.cameras = [camHUD];
			songPosDeathIndicator.cameras = [camHUD];
			songDurationTxt.cameras = [camHUD];
			songPosGroup.cameras = [camHUD];

			songPosGroup.add(songPosBG);
			songPosGroup.add(songPosBar);
			songPosGroup.add(songPosDeathIndicator);
			songPosGroup.add(songDurationTxt);

			songPosGroup.forEach(function(blep:FlxSprite)
			{
				blep.alpha = 0;
				blep.y -= 15;
				FlxTween.tween(blep, {alpha: 1, y: blep.y + 15}, 1, {type: ONESHOT, ease: FlxEase.elasticOut});
			});
		}

		/*if (useVideo)
			GlobalVideo.get().resume();*/

		#if windows
		if (FlxG.save.data.showPresence)
		{
			// Updating Discord Rich Presence (with Time Left)
			DiscordClient.changePresence(detailsText
				+ " \n"
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ")   "
				+ Ratings.GenerateLetterRank(accuracy),
				"\nAcc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Combo Breaks: "
				+ misses); //, iconRPC
		}
		#end

		//startTime = 0;
		if (startTime > 0)
			setSongTime(startTime);
		else
		{
			vocals.time = FlxG.sound.music.time;
			instLowHP.time = FlxG.sound.music.time;
			miscs.time = FlxG.sound.music.time;
			Conductor.songPosition = FlxG.sound.music.time;
		}
		//startTime = 0;

		for(i in 0...unspawnNotes.length)
			if (unspawnNotes[i].strumTime < startTime)
				unspawnNotes.remove(unspawnNotes[i]);

		if (needSkip)
		{
			skipActive = true;
			//Note: Add anim for this lmao
			skipButton = new FlxSprite(0, healthBar.y).loadGraphic(Paths.image('skipButton'));
			skipButton.x = FlxG.width - skipButton.width - 35;
			if(!PlayStateChangeables.useDownscroll)
				skipButton.y = FlxG.height - skipButton.height - 10;
			else
				skipButton.y = 10;
			skipButton.y += 5;
			if(FlxG.save.data.antialiasing)
				skipButton.antialiasing = true;
			skipButton.updateHitbox();
			skipButton.cameras = [camMiscs];
			skipButton.alpha = 0;
			add(skipButton);
			FlxTween.tween(skipButton, {alpha: 1, y: skipButton.y - 5}, 0.2, {type: ONESHOT, ease: FlxEase.sineInOut});
		}
	}

	public function generateSong(dataPath:String):Void
	{
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
		FlxG.sound.list.add(vocals);



		if (SONG.needsMiscs)
			miscs = new FlxSound().loadEmbedded(Paths.miscs(PlayState.SONG.song));
		else
			miscs = new FlxSound();
		FlxG.sound.list.add(miscs);



		if (SONG.needsAdaptiveMus)
			instLowHP = new FlxSound().loadEmbedded(Paths.adaptiveMus(PlayState.SONG.song), FlxG.sound.music.looped);
		else
			instLowHP = new FlxSound();
		instLowHP.volume = 0;
		FlxG.sound.list.add(instLowHP);



		switch (SONG.song)
		{
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
				swagNote.scrollFactor.set();

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

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	//This is shit
	//actually not really?
	public function regenerateSong():Void
	{
		vocals.pause();
		musicGroup.pause();
		FlxG.sound.music.time = 0;
		beatCheck = 0;
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
		musicGroup.resume();

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
			resyncVocals();
		}

		unspawnNotes.sort(sortByShit);
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	var funnyRatingCheckStart:Float = 0;
	var funnyRatingCheckEnd:Float = 0;
	var funnyRatingOffset:Float = 0;
	var daBabyArrowY:Float = 0;
	
	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			//Sloink                                V
			var babyArrow:FlxSprite = new FlxSprite(50, strumLine.y + (!PlayStateChangeables.useDownscroll ? -10 : 10));

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
				{
					babyArrow.antialiasing = true;
				}
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			var babyArrowAlphaSubtractor:Float = 0;

			if (player == 0)
				babyArrowAlphaSubtractor = 0.15;

			if (storyPlaylist.length <= 2 && SONG.song != 'Mic Test' && isStoryMode)
			{
				babyArrow.alpha -= babyArrowAlphaSubtractor;
				babyArrow.y += (!PlayStateChangeables.useDownscroll ? 10 : -10);
			}
			else 
			{
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + (!PlayStateChangeables.useDownscroll ? 10 : -10), alpha: 1 - babyArrowAlphaSubtractor}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.circOut, startDelay: Conductor.crochet / 1000 + (0.2 * i)});
			}

			babyArrow.ID = i;

			babyArrow.animation.play('static');
			if(!PlayStateChangeables.Optimize)
				babyArrow.x += 50;
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
					cpuStrums.add(babyArrow);
				case 1:
					if (FlxG.save.data.strumline)
					{
						var strumlineBG:FlxSprite = new FlxSprite(babyArrow.x, -10).loadGraphic(Paths.image('strumline', 'week' + (storyWeek > 0 ? storyWeek : 1)));
						if (FlxG.save.data.antialiasing)
							strumlineBG.antialiasing = true;
						if (storyPlaylist.length <= 2 && SONG.song != 'Mic Test' && isStoryMode)
						{
							strumlineBG.y = 0;
							strumlineBG.alpha = 0.45;
						}
						else
						{
							strumlineBG.alpha = 0;
							FlxTween.tween(strumlineBG, {y: 0, alpha: 0.45}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.expoOut, startDelay: Conductor.crochet / 500 + (0.2 * i)});
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
			}
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
					DiscordClient.changePresence("PAUSED - \n"
						+ SONG.song
						+ " ("
						+ storyDifficultyText
						+ ")   "
						+ Ratings.GenerateLetterRank(accuracy),
						"\nAcc: "
						+ HelperFunctions.truncateFloat(accuracy, 2)
						+ "% | Score: "
						+ songScore
						+ " | Combo Breaks: "
						+ misses); //, iconRPC
				}
				#end

				if (!startTimer.finished)
					startTimer.active = false;
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
						+ " | Combo Breaks: "
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
			if (paused && !died)
			{
				if (FlxG.sound.music != null && !startingSong)
				{
					if (!resultsPresent && !inCutscene)
						resyncVocals();
				}
		
				if (!startTimer.finished)
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
					if (startTimer.finished && !paused)
					{
						
						DiscordClient.changePresence(detailsText
							+ " \n"
							+ SONG.song
							+ " ("
							+ storyDifficultyText
							+ ")   "
							+ Ratings.GenerateLetterRank(accuracy),
							"\nAcc: "
							+ HelperFunctions.truncateFloat(accuracy, 2)
							+ "% | Score: "
							+ songScore
							+ " | Combo Breaks: "
							+ misses, "", true,
							songLength
							- Conductor.songPosition);
					}
				}
				#end
			}
		}
		
		super.closeSubState();
	}

	function resyncVocals():Void
	{
		if (FlxG.sound.music.time - Conductor.songPosition > 150 && FlxG.save.data.lagCompensation && !endedSong)
		{
			allowHealthModifiers = false;
			lagCompIcon.alpha = 0.5;
		}
		//trace("Timing Gap: " + (FlxG.sound.music.time - Conductor.songPosition));

		if (!endedSong)
		{
			if (PauseSubState.resyncToLastPos && songStarted)
			{
				PauseSubState.resyncToLastPos = false;
				setSongTime(Conductor.songPosition);
			}
			else
				setSongTime(FlxG.sound.music.time, true);
		}

		//trace("resynced vocals & miscs!");
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
	var sustainHeightMultiplier:Float = 1;
	var defaultScrollSpeed:Float = 1;
	var newScroll:Float = 1;
	var keeledOver:Bool = false;
	//var preventRepeatDeaths:Bool = false;

	override public function update(elapsed:Float)
	{
		if (!resultsPresent && !endedSong)
		{
			if (FlxG.sound.music.playing)
			{
				if (PlayStateChangeables.scrollSpeed != 1)
					newScroll = PlayStateChangeables.scrollSpeed;

				if (SONG.eventObjects != null && SONG.eventObjects.length != 0)
				{
					for(i in SONG.eventObjects)
					{
						switch(i.type)
						{
							case "Scroll Speed Change":
								if (i.position <= curDecimalBeat)
									newScroll = i.value;
						}
					}
				}
			}

			//FIX THIS SHIT
			//did so lol
			if (PlayStateChangeables.scrollSpeed != newScroll)
			{
				if (FlxG.save.data.scrollSpeed == 1)
					sustainHeightMultiplier = FlxMath.roundDecimal(newScroll / defaultScrollSpeed, 2);
				PlayStateChangeables.scrollSpeed = FlxMath.lerp(newScroll, (PlayStateChangeables.scrollSpeed == 1 ? defaultScrollSpeed : PlayStateChangeables.scrollSpeed), CoolUtil.boundTo(1 - (elapsed * 15), 0, 1));
				//trace("Scroll Speed Multiplier = " + sustainHeightMultiplier);
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
				}

			}
		}	

		if (!cannotDie && !endedSong)
			safeVignette.visible = false;
		else if (!endedSong)
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

		if (generatedMusic && !paused)
		{
			fancySongUpdate(elapsed);
			if (songStarted && !inCutscene)
				keyShit();
		}	

		FlxG.mouse.visible = false;

		//Updating of alphas
		if (FlxG.save.data.lagCompensation && lagCompIcon.alpha > 0)
		{
			if (allowHealthModifiers)
				lagCompIcon.alpha -= (Conductor.crochet / 500) * FlxG.elapsed;
			//else
				//allowHealthModifiers = true;
			//Failsafe incase it fails to get turned on again
		}

		//Low-Health Volume Suspense
		if (generatedMusic && startedCountdown)
		{
			switch (curStage)
			{
				case 'cityskyline':
					//this was once disabled, i enabled it to see what happens
					//hehehe I made it work!!11!
					cityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed * 1.5;
				case 'cityskylineVariegated':
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

			if (hurtVignette.alpha > 0)
				hurtVignette.alpha -= (Conductor.crochet * 3 / 1000) * FlxG.elapsed;

			lowHealthEffectVolume = 1 - health;
			lowHPHeartBeat.volume = FlxMath.lerp(lowHealthEffectVolume, lowHPHeartBeat.volume, CoolUtil.boundTo(1 - (elapsed * 15), 0, 1));
			
			if (FlxG.save.data.flashing)
				lowHPOverlay.alpha = FlxMath.lerp(0, lowHPOverlay.alpha, CoolUtil.boundTo(1 - (elapsed * 4.5 * (Conductor.bpm * 0.01)), 0, 1));
			else
				lowHPOverlay.alpha = FlxMath.lerp(lowHPHeartBeat.volume, lowHPOverlay.alpha, CoolUtil.boundTo(1 - (elapsed * 6 * (Conductor.bpm * 0.01)), 0, 1));

			if (SONG.needsAdaptiveMus)
			{
				//Least Audio Volume during Low Health
				//FIX THIS SHIT
				if (health < 1)
				{
					FlxG.sound.music.volume = FlxMath.lerp(health - 0.125, FlxG.sound.music.volume, CoolUtil.boundTo(1 - (elapsed * 15), 0, 1));
					instLowHP.volume = FlxMath.lerp(lowHealthEffectVolume + 0.125, instLowHP.volume, CoolUtil.boundTo(1 - (elapsed * 15), 0, 1));
					//instLowHP.time = FlxG.sound.music.time;
				}
				else if (health >= 1 && FlxG.sound.music.volume < 1)
				{
					FlxG.sound.music.volume = 1;
					instLowHP.volume = 0;
					lowHPOverlay.alpha = 0;
					//instLowHP.time = FlxG.sound.music.time;
				}
			}
			/*else
			{
				if (curSong != "Mic Test" && !cannotDie)
				{
					//Least Audio Volume during Low Health
					if (health < 1)
						FlxG.sound.music.volume = FlxMath.lerp(health, FlxG.sound.music.volume, CoolUtil.boundTo(1 - (elapsed * 15), 0, 1));
					else if (health >= 1 && FlxG.sound.music.volume < 1)
						FlxG.sound.music.volume = 1;
				}
			}*/

			scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS, accuracy);

			var lengthInPx = scoreTxt.textField.length * scoreTxt.frameHeight; // bad way but does more or less a better job
			scoreTxt.x = (originalScoreTxtX - (lengthInPx / 2)) + 206; //wdym? i fixed it for u lol
			scoreTxt.screenCenter(X);
		}

		if (controls.PAUSE && startedCountdown && canPause && !paused)
			pauseGame();

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
			showedLoadSprInCurSong = false;
			cannotDie = true;
			FlxG.switchState(new ChartingState());
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
		}
		//#end

		if (FlxG.save.data.distractions)
		{
			var mult:Float = FlxMath.lerp(1, iconP1.scale.x, CoolUtil.boundTo(1 - (elapsed * 7.5 * (Conductor.bpm * 0.01)), 0, 1));
			iconP1.scale.set(mult, mult);
			iconP1.updateHitbox();
	
			var mult:Float = FlxMath.lerp(1, iconP2.scale.x, CoolUtil.boundTo(1 - (elapsed * 7.5 * (Conductor.bpm * 0.01)), 0, 1));
			iconP2.scale.set(mult, mult);
			iconP2.updateHitbox();
		}

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - 26);
		iconP1.y = healthBar.y - 75 * iconP1.scale.y;
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - 26);
		iconP2.y = healthBar.y - 75 * iconP2.scale.y;

		//Failsafes
		if (health > 2.1)
			health = 2.1;
		else if (health < 0)
			health = 0;
		
		if (healthLerp > 2.1)
			healthLerp = 2.1;
		else if (healthLerp < 0)
			healthLerp = 0;

		if (healthBar.percent <= 25)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent >= 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

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
		//else if (FlxG.keys.justPressed.THREE)
		else if (FlxG.keys.justPressed.FIVE)
		{
			/*if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				FlxG.stage.window.onFocusOut.remove(focusOut);image.png
				FlxG.stage.window.onFocusIn.remove(focusIn);
				removedVideo = true;
			}*/

			FlxG.switchState(new AnimationDebug(SONG.player2));
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
		}
		else if (FlxG.keys.justPressed.SIX)
		{
			FlxG.switchState(new AnimationDebug(SONG.player1));
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
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
		songLength = FlxG.sound.music.length;

		//Pause Skip Song Shit
		if (isStoryMode && storyPlaylist.length > 0 && PauseSubState.skippedSong)
		{
			vocals.volume = 0;
			miscs.volume = 0;
			musicGroup.volume = 0;
			vocals.stop();
			miscs.stop();
			musicGroup.stop();
			clearAllNotes();
			if (!startTimer.finished)
				startTimer.active = false;
			skippedShit = true;
			endSong();
			instance.clear();
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
			FlxG.sound.play(Paths.sound('skipSongIntro'));
			setSongTime(skipTo);
			clearNotesBefore(skipTo);

			if (songLowercase == 'mic-test' && !PlayStateChangeables.Optimize)
			{
				camTween.cancel();
				camGame.zoom = 1.5;
				if (tutorialGraphicA.exists)
					tutorialGraphicA.destroy();
				if (tutorialGraphicB.exists)
					tutorialGraphicB.destroy();
				if (tutorialGraphicC.exists)
					tutorialGraphicC.destroy();
			}
			
			skipButton.destroy();
			skipActive = false;
		}
	

		//Starting Countdown Shit
		//Portal
		if (startingSong)
		{
			if (startedCountdown)
			{
				health = FlxMath.lerp(1, health, CoolUtil.boundTo(1 - (elapsed * 15), 0, 1));
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			Conductor.songPosition += FlxG.elapsed * 1000;
			songPositionBar = FlxMath.lerp(Conductor.songPosition, songPositionBar, 0.965);

			if (!paused)
			{
				//Health lerp shits
				health = FlxMath.lerp(healthLerp, health, CoolUtil.boundTo(1 - (elapsed * 19), 0, 1));
				if (FlxG.save.data.songPosition)
				{
					var curTime:Float = Conductor.songPosition - FlxG.save.data.offset;
					if(curTime < 0)
						curTime = 0;
					var songCalc:Float = (songLength - curTime);
					var secondsTotal:Int = Math.floor(songCalc / 1000);
					if(secondsTotal < 0)
						secondsTotal = 0;
					songDurationTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
				}

				// Interpolation type beat
				//if (Conductor.lastSongPos != Conductor.songPosition)
					//Conductor.lastSongPos = Conductor.songPosition;

				//CONVERTED TO ELSE IFS
				//NEVERMIND-??
				if (FlxG.save.data.lagCompensation && generatedMusic)
				{
					//Lagspike Compensation Attempt 1
					if (vocals.volume <= 0 && (vocals.time > FlxG.sound.music.time + 1.5 || vocals.time < FlxG.sound.music.time - 1.5) && !endedSong)
					{
						lagCompIcon.alpha = 0.75;
						allowHealthModifiers = false;
						Conductor.songPosition = FlxG.sound.music.time;
						vocals.time = FlxG.sound.music.time;
						//trace("BUh'd");
						allowHealthModifiers = true;
					}

					//LagSpike Compensation Attempt 2
					//if (openfl.Lib.current.stage.frameRate < frameRateLimit)
					if ((cast(Lib.current.getChildAt(0), Main)).getFPS() < frameRateLimit && curBeat > 4 && !endedSong)
					{
						lagCompIcon.alpha = 1;
						allowHealthModifiers = false;
						compensatedViaLagSpike = true;
						//trace("Bruh'd");
					}
					if (compensatedViaLagSpike)
						compensationTimer = new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							compensatedViaLagSpike = false;
							allowHealthModifiers = true;
							compensationTimer = null;
							//trace("compensated (via frames)");
						});
					//Failsafe-?? maybe??
					if (compensationTimer == null && !allowHealthModifiers)
						allowHealthModifiers = true;
				}
			}
		}

		if (camZooming && FlxG.save.data.camzoom)
		{
			camGame.zoom = FlxMath.lerp(defaultCamZoom, camGame.zoom, CoolUtil.boundTo(1 - (elapsed * 2.5 * (Conductor.bpm * 0.01)), 0, 1));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, CoolUtil.boundTo(1 - (elapsed * 3 * (Conductor.bpm * 0.01)), 0, 1));
		}

		#if debug
		FlxG.watch.addQuick("curBPM", Conductor.bpm);
		FlxG.watch.addQuick("Closest Note", (unspawnNotes.length != 0 ? unspawnNotes[0].strumTime - Conductor.songPosition : "No note"));

		FlxG.watch.addQuick("curBeat", curBeat);
		FlxG.watch.addQuick("curStep", curStep);
		//FlxG.watch.addQuick("Song Amplitude", FlxG.sound.music.amplitude);
		#end

		//CHANGED FROM MULTIPLE IF STATEMENTS (see if this causes problems)
		//Changed it back to multiple if statements to allow for more functionality
		if (startedCountdown && (healthLerp <= 0 || (FlxG.keys.justPressed.R && FlxG.save.data.resetButton)))
		{
			if (!resultsPresent && !inResults && !inCutscene && !PlayStateChangeables.botPlay)
			{
				if (!cannotDie)
				{
					if (allowHealthModifiers)
						literallyFuckingDie();
					else
						healthLerp = 0.05;
				}
				else
				{
					if (camGame.finishedFade)
					{
						camGame.fade(FlxColor.RED, Conductor.crochet / 500, true);
						FlxG.sound.play(Paths.sound('practiceModeFail'));
						//preventRepeatDeaths = true;
						healthLerp = 1;
						health = 1;
						allowHealthModifiers;
						deaths++;
						camShake();
						if (!keeledOver)
						{
							keeledOver = true;
							if (FlxG.save.data.songPosition)
								songPosDeathIndicator.x = songPosBar.x + (songPosBar.width * (songPosBar.percent * 0.01)) - (songPosDeathIndicator.width - 26) - 6;
							safeVignette.color = 0xFFFF0000;
							safeVignette.blend = MULTIPLY;
							safeVignette.alpha = 1;
							boyfriend.blend = ADD;
							boyfriend.color = 0xFF00A8AD;
							blackScreen.alpha = (!Main.nightMode && !FlxG.save.data.nightmode ? 0.25 : 0.4);
							healthBar.color = 0xFFFF0000;
							iconP1.color = 0xFF808080;
							scoreTxt.color = 0xFFADA99B;
							if (FlxG.save.data.strumline)
								grpStrumLine.forEach(function(strumlineBG:FlxSprite)
								{
									for (i in 0...4)
									{
										strumlineBG.color = 0xFF788D7F;
									}
								});
						}
					}
					else
					{
						healthLerp = 1;
						health = 1;
					}
				}
			}
		}


		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 3500)
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

	function camShakeFinish():Void
	{
		//trace("FinishedCamShake");
		camGame.followLerp = prevCamFollowSpeed;
		triggeredCamShake = false;
	}

	function camShake(isEarthquake:Bool = false):Void
	{
		triggeredCamShake = true;
		prevCamFollowSpeed = camFollowSpeed;
		camGame.followLerp = 2;
		if (isEarthquake)
			camGame.shake(0.04, 0.2, camShakeFinish);
		else
			camGame.shake(0.025, 0.25, camShakeFinish);
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
						if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
							&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
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
				/*if (daNote.mustPress)
					daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
						- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
							2)) + daNote.noteYOff;
				else
					daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
						- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
							2)) + daNote.noteYOff;*/
				if (daNote.mustPress)
					daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed, 2));
				else
					daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed, 2));
				
				if (daNote.isSustainNote)
				{
					//SUSTAIN FIXINS (upscroll)
					if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
					{
							if (daNote.prevNote.isSustainNote && !daNote.prevNote.finnaBeKilled)
								daNote.y = daNote.prevNote.y + daNote.prevNote.height - (15 / sustainHeightMultiplier);
							else
								daNote.y -= daNote.height / 2 + (15 / sustainHeightMultiplier);
					}
					else
					{
						daNote.y -= daNote.height / 2 - (daNote.childBehindParent ? 50 : 0);
						daNote.scale.y = FlxMath.lerp(Std.int(daNote.height * sustainHeightMultiplier) / daNote.frameHeight + 0.05, daNote.scale.y, CoolUtil.boundTo(1 - (elapsed * 20), 0, 1)); //.1 just to be safe
					}

					var center:Float = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y + Note.swagWidth / 2;
					if (!PlayStateChangeables.botPlay)
					{
						if (!daNote.mustPress || (daNote.sustainActive && holdArray[Math.floor(Math.abs(daNote.noteData))]))
						{
							// Clip to strumline
							if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
							{
								var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
								swagRect.y = (center - daNote.y) / daNote.scale.y * (!daNote.animation.curAnim.name.endsWith('end') ? sustainHeightMultiplier : 1);
								swagRect.height -= swagRect.y;
								swagRect.bottom = (swagRect.y + (daNote.height * daNote.scale.y + 30)) * sustainHeightMultiplier; //the 30 is here just to be safe

								daNote.clipRect = swagRect;
							}
						}
					}
					else
					{
						if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
						{
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (center - daNote.y) / daNote.scale.y * (!daNote.animation.curAnim.name.endsWith('end') ? sustainHeightMultiplier : 1);
							swagRect.bottom = (swagRect.y + (daNote.height * daNote.scale.y + 30)) * sustainHeightMultiplier; //the 30 is here just to be safe

							daNote.clipRect = swagRect;
						}
					}
				}
			}

			if (!daNote.mustPress && daNote.wasGoodHit)		
				enemyNoteHit(daNote);

			if (daNote.mustPress)
			{
				daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
				daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
				if (!daNote.isSustainNote)
					daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
				if (daNote.sustainActive)
					daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha;
				daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].angle;
			}
			else if (!daNote.wasGoodHit)
			{
				//trace ("test");
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
				if (daNote.mustPress && !daNote.withinCompensation && !PlayStateChangeables.botPlay)
				{
					if (daNote.isSustainNote && daNote.wasGoodHit)
					{
						daNote.finnaBeKilled = true;
						daNote.kill();
						notes.remove(daNote, true);
						//trace ('deleted sus note');
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
									camShake();
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
									timesShot++;
									dad.playAnim('gunSHOOT', true);
									if (stageOverlay.exists && !PlayStateChangeables.Optimize)
										stageOverlay.animation.play('static');
									if (allowHealthModifiers)
									{
										FlxG.sound.play(Paths.sound('Note_Mine'));
										boyfriend.playAnim('hurt', true);
										camShake(true);
										hurtVignette.alpha = 1;
										//la health drain for failed trigger	
										if (healthLerp > 0.7 && timesShot <= 2)
											healthLerp = 0.25;
										else if (healthLerp < 0.7 && timesShot <= 2)
											healthLerp = 0.05;
										if (timesShot >= 3)
											healthLerp -= 100;
										if (!daNote.isSustainNote)
											noteMiss(daNote.noteData, daNote);
										totalNotesHit -= 1;
										//trace(timesShot + ' bullet/s eaten');
									}
								default:
									if (daNote.isParent)
									{
										// give a health punishment for failing an LN
										//Heath Drain for Sustain Parent
										if (allowHealthModifiers || hurtVignette.alpha < 0.2)
											healthLerp += PlayStateHealthModifiers.ModifyHealth(storyDifficulty, 1, healthLerp, accuracy);
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
										//Health Drain for Non-Sustain
										if (allowHealthModifiers || hurtVignette.alpha < 0.2)
											healthLerp += PlayStateHealthModifiers.ModifyHealth(storyDifficulty, 0, healthLerp, accuracy);
										vocals.volume = 0;
									}
									noteMiss(daNote.noteData, daNote);
							}
						}
						else
						{
							if (!daNote.isParent && !daNote.wasGoodHit)
							{
								if (daNote.sustainActive && daNote.spotInLine != daNote.parent.children.length)
								{
									//Health Drain for Sustain Tail
									if (allowHealthModifiers)
										healthLerp += PlayStateHealthModifiers.ModifyHealth(storyDifficulty, 2, healthLerp, accuracy);
									for (i in daNote.parent.children)
									{
										i.alpha = 0.3;
										i.sustainActive = false;
									}
									if (daNote.parent.wasGoodHit)
									{
										misses++;
										totalNotesHit -= 1;
									}
									vocals.volume = 0;
									updateAccuracy();
								}
								else
								{
									//Health Drain for Sustain Children
									if (allowHealthModifiers)
										healthLerp += PlayStateHealthModifiers.ModifyHealth(storyDifficulty, 3, healthLerp, accuracy);
								}
							}
						}
					}

					daNote.visible = false;
					daNote.finnaBeKilled = true;
					daNote.kill();
					notes.remove(daNote, true);
					//trace ('deleted non sus note');
				}
				else
				{
					if (daNote.isSustainNote && daNote.wasGoodHit)
					{
						daNote.finnaBeKilled = true;
						daNote.kill();
						notes.remove(daNote, true);
						//trace ('deleted sus note');
					}
					else
					{
						if (!daNote.isSustainNote) // theFunne
						{
							switch (daNote.noteType)
							{
								case 'mine':
									if (stageOverlay.exists && !PlayStateChangeables.Optimize)
										stageOverlay.animation.play('static');
									dad.playAnim('gunSHOOT', true);
									camShake();
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
									if (allowHealthModifiers)
									{
										FlxG.sound.play(Paths.sound('Note_Mine'));
										boyfriend.playAnim('hurt', true);
										camShake(true);
									}
							}
						}
					}

					daNote.visible = false;
					daNote.finnaBeKilled = true;
					daNote.kill();
					notes.remove(daNote, true);
				}	
			}

			if (!allowHealthModifiers && daNote.canBeHit)
			{
				daNote.withinCompensation = true;
				if (!daNote.isSustainNote && daNote.noteType != 'mine' && daNote.noteType != 'trigger')
					daNote.animation.play(daNote.dataColor[daNote.noteData] + 'SafeScroll');
				daNote.alpha = 0.5;
				if ((daNote.strumTime <= Conductor.songPosition - Conductor.safeZoneOffset * Conductor.timeScale))
				{
					if (daNote.isSustainNote
					&& daNote.sustainActive
					&& daNote.spotInLine != daNote.parent.children.length)
						for (i in daNote.parent.children)
						{
							i.alpha = 0;
							i.sustainActive = false;
							//i.kill();
							//i.remove(daNote, true);
						}
					else
					{
						daNote.visible = false;
						daNote.finnaBeKilled = true;
						daNote.kill();
						notes.remove(daNote, true);
					}
				}
			}
		});
	}

	function endSong():Void
	{
		beatCheck = 0;
		endedSong = true;
		if (!resultsPresent)
		{
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);

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
			if (FlxG.save.data.songPosition)
			{
				songPosGroup.forEach(function(blep:FlxSprite)
				{
					FlxTween.tween(blep, {alpha: 0}, 0.2, {type: ONESHOT, ease: FlxEase.smootherStepIn, onComplete: function(twn:FlxTween)
					{
						blep.visible = false;
					}});
				});
			}
			playedCutscene = false;
			cannotDie = false;

			if (FlxG.save.data.pauseOnUnfocus)
			{
				FlxG.autoPause = false;

				//if (FlxG.signals.focusGained.has(focusIn))
					//FlxG.signals.focusGained.remove(focusIn);
	
				//if (FlxG.signals.focusLost.has(focusOut))
					//FlxG.signals.focusLost.remove(focusOut);

				//FlxG.stage.window.onFocusOut.remove(focusOut);
				//FlxG.stage.window.onFocusIn.remove(focusIn);
			}

			//if (!loadRep)
			if (!skippedShit && FlxG.save.data.scoreScreen && ((isStoryMode && storyWeek == 0) || !isStoryMode))
				rep.SaveReplay(saveNotes, saveJudge, replayAna);
			//if (!loadRep)
			//{
			PlayStateChangeables.botPlay = false;
			PlayStateChangeables.scrollSpeed = 1;
			PlayStateChangeables.useDownscroll = false;
			//}

			if (FlxG.save.data.fpsCap > 290)
				(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

			canPause = false;
			//paused = true;
			musicGroup.volume = 0;
			vocals.volume = 0;
			miscs.volume = 0;

			musicGroup.pause();
			vocals.pause();
			miscs.pause();

			persistentUpdate = true;
			persistentDraw = true;

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

			showedLoadSprInCurSong = false;

			if (isStoryMode)
			{
				campaignScore += Math.round(songScore);
				campaignAccuracy = campaignAccuracy / campAccDivider;

				storyPlaylist.remove(storyPlaylist[0]);

				if (storyPlaylist.length <= 0)
				{
					prevHealth = 1;
					hasReset = false;

					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;

					PauseSubState.randomMusicTime = false;

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
						miscs.stop();
						musicGroup.stop();
						musicGroup.volume = 0;
						FlxG.sound.music.autoDestroy = true;
						FlxG.sound.music.endTime = 0;
						vocals.stop();
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
						//Placeholder For Final Song (2)
						else if (songLowercase == "thorns" && !toggledPracticeMode)
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
					if (!PauseSubState.skippedSong)
						prevHealth = health;
					else
						PauseSubState.skippedSong = false;

					prevCamFollow = camFollow;
					campaignScore = songScore;
					campaignAccuracy = accuracy;
					// adjusting the song name to be compatible
					var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");

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

						PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0]);

						miscs.stop();
						musicGroup.stop();
						musicGroup.volume = 0;
						FlxG.sound.music.autoDestroy = true;
						FlxG.sound.music.endTime = 0;
						vocals.stop();

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
				
				prevHealth = 1;
				musicGroup.stop();
				miscs.stop();
				vocals.stop();

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
					musicGroup.volume = 0;
					FlxG.sound.music.autoDestroy = true;
					FlxG.switchState(new FreeplayState());
					FlxG.sound.music.endTime = 0;
				}

				Conductor.songPosition = FlxG.sound.music.length;
				//Failsafe incase the game is stupid
				//makes the conductor position into the end incase the song resyncs cause of this bool being reset
				PauseSubState.randomMusicTime = false;
			}
		}
	}

	function playEndCutscene():Void
	{
		miscs.stop();
		musicGroup.stop();
		musicGroup.volume = 0;
		FlxG.sound.music.autoDestroy = true;
		FlxG.sound.music.endTime = 0;
		vocals.stop();
		/*if (FlxG.sound.music.playing)
			trace("BRO MUSIC PLAYING?!");
		else
			trace("BRO NO MUSIC PLAYING?!");*/

		FlxTransitionableState.skipNextTransOut = true;
		
		switch (songLowercase)
		{
			case 'up-and-beyond':		
				if (FlxG.save.data.scoreScreen)
				{
					inCutscene = true;
					video = new MP4Handler();
					video.finishCallback = function()
					{
						/*FlxG.switchState(new ResultsScreenAfter());
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								inResults = true;
							});		
						});*/
						FlxG.switchState(new MinigameState());
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
						/*FlxG.switchState(new ResultsScreenAfter());
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								inResults = true;
							});		
						});*/
						FlxG.switchState(new MinigameState());
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
					new FlxTimer().start(0.3, function(tmr:FlxTimer)
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
	var timeShown = 0;
	var currentTimingShown:FlxText = null;
	var timingTween:FlxTween;
	var showNumShit:Bool = true;

	private function popUpScore(daNote:Note = null):Void
	{
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
			switch (daRating)
			{
				//To do: Add difficulty-dependent health drains as well as customization
				//uhh i already did that
				//To did: Add(ed) difficulty-dependent health drains
				//oh oop i have not done customization yet
				case 'miss':
					if (lagCompIcon.alpha < 0.1)
					{
						score = -100;
						combo = 0;
						misses++;
						ss = false;
						timingColour = FlxColor.RED;
					}
				case 'shit':
					if (lagCompIcon.alpha < 0.1)
					{
						score = -50;
						combo = 0;
						misses++;
						ss = false;
						//Health Drain
						if (hurtVignette.alpha < 0.2)
							healthLerp += PlayStateHealthModifiers.ModifyHealth(storyDifficulty, 4, healthLerp, accuracy);
						if (FlxG.save.data.accuracyMod == 0)
							totalNotesHit -= 1;
						timingColour = FlxColor.RED;
					}
				case 'bad':
					daRating = 'bad';
					score = 0;
					//Health Drain
					if (hurtVignette.alpha < 0.2)
						healthLerp += PlayStateHealthModifiers.ModifyHealth(storyDifficulty, 5, healthLerp, accuracy);
					ss = false;
					bads++;
					if (FlxG.save.data.accuracyMod == 0)
						if (notePresses <= noteMashingThreshold)
							totalNotesHit += 0.50;
					timingColour = FlxColor.YELLOW;
				case 'good':
					daRating = 'good';
					//Health Drain/Gain
					healthLerp += PlayStateHealthModifiers.ModifyHealth(storyDifficulty, 6, healthLerp, accuracy);
					score = 200;
					ss = false;
					goods++;
					if (FlxG.save.data.accuracyMod == 0)
						if (notePresses <= noteMashingThreshold)
							totalNotesHit += 0.75;
					timingColour = FlxColor.LIME;
				case 'sick':
					//Health Gain
					healthLerp += PlayStateHealthModifiers.ModifyHealth(storyDifficulty, 7, healthLerp, accuracy, hurtVignette.alpha);
					if (FlxG.save.data.accuracyMod == 0)
						if (notePresses <= noteMashingThreshold)
							totalNotesHit += 1;
					sicks++;
					timingColour = FlxColor.CYAN;
			}
		}

		songScore += Math.round(score);
		songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));

		if (!PlayStateChangeables.botPlay)
		{
			rating.loadGraphic(Paths.image("rating_" + daRating));
			rating.screenCenter();
			rating.x = FlxG.save.data.changedHitX;
			rating.y = FlxG.save.data.changedHitY + funnyRatingOffset;
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);
			if(FlxG.save.data.antialiasing)
				rating.antialiasing = true;
			rating.updateHitbox();
			rating.cameras = [camHUD];
			add(rating);

			if (daRating != 'miss')
			{
				var msTiming = FlxMath.roundDecimal(HelperFunctions.truncateFloat(noteDiff, 3), 2);
				if (PlayStateChangeables.botPlay)
					msTiming = 0;
	
				if (currentTimingShown != null)
					remove(currentTimingShown);
	
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
				currentTimingShown.screenCenter();
				currentTimingShown.x = rating.x + 115;
				currentTimingShown.y = rating.y + 105;
				currentTimingShown.updateHitbox();
				currentTimingShown.cameras = [camHUD];
				if (currentTimingShown.alpha != 1)
					currentTimingShown.alpha = 1;
				if (currentTimingShown.exists)
					add(currentTimingShown);
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
					numScore.screenCenter();
					numScore.x = rating.x + (37 * daLoop);
					numScore.y = rating.y + 120;
					numScore.cameras = [camHUD];

					if(FlxG.save.data.antialiasing)
						numScore.antialiasing = true;
					//numScore.setGraphicSize(Std.int(numScore.width * 0.8));
					numScore.updateHitbox();
					switch (daRating)
					{
						case 'shit' | 'miss':
							if (lagCompIcon.alpha < 0.1 && allowHealthModifiers)
							{
								numScore.color = timingColour;
								rating.color = 0xFFFFC7C7;
							}
							else
								rating.color = timingColour;
					}

					numScore.acceleration.y = FlxG.random.int(200, 300);
					numScore.velocity.y -= FlxG.random.int(140, 160);
					numScore.velocity.x = FlxG.random.float(-5, 5);

					add(numScore);

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
							remove(currentTimingShown);
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
		if (FlxG.save.data.notesplash && !PlayStateChangeables.botPlay && allowHealthModifiers) //!PlayStateChangeables.botPlay && [REMOVED FOR TEXTING, PUT THIS TF BACK OK?!]
			//var sploosh:FlxSprite = new FlxSprite(daNote.x, playerStrums.members[daNote.noteData].y);
			sploshThisShitUp(daNote, daRating);
		else
			adjustVocVolOnNoteHit(daNote);
	}

	function sploshThisShitUp(daNote:Note, daRating:String):Void
	{
		if (allowHealthModifiers && !daNote.withinCompensation && (lagCompIcon.alpha < 0.1 || daRating != 'shit') && !daNote.isSustainNote)
		{
			var sploosh:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
			sploosh.setupNoteSplash(daNote.x, daNote.y, daNote.rating, daNote.noteType, daNote.noteData, daBabyArrowY);
			//x and y here idfk
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
					note.finnaBeKilled = true;
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
							anas[coolNote.noteData].hitJudge = Ratings.CalculateRating(noteDiff, Math.floor(PlayStateChangeables.safeZoneOffset));
							anas[coolNote.noteData].nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
							goodNoteHit(coolNote);
						}
					}
				};
				
				if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
				{
					if (!noNotesToHit && (boyfriend.animation.curAnim.name.startsWith('sing') && boyfriend.animation.curAnim.curFrame >= 10 && ((boyfriend.animation.curAnim.name != "hurt" && !boyfriend.animation.curAnim.name.startsWith("dodge")) || boyfriend.animation.curAnim.finished)) && !boyfriend.animation.curAnim.name.endsWith('miss'))
					//{
						boyfriend.playAnim('idleAfterSing');
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
		if (songStarted && generatedMusic && !endedSong && !FlxG.save.data.pauseOnUnfocus)
		{
			if (paused)
				return;
			if (FlxG.save.data.showPresence)
			{
				DiscordClient.changePresence("AUTO PAUSED - "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ")   "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Combo Breaks: "
					+ misses); //, iconRPC
			}
		}
	}

	//removing from publicskov
	//converting to override from private
	override function onFocus():Void
	{
		if (songStarted && generatedMusic && !endedSong && !FlxG.save.data.pauseOnUnfocus)
		{
			if (paused)
				return;
			if (FlxG.save.data.showPresence)
			{
				allowHealthModifiers = true;
				compensatedViaLagSpike = false;

				DiscordClient.changePresence(detailsText
					+ " \n"
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ")   "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Combo Breaks: "
					+ misses, "", true,
					songLength
					- Conductor.songPosition);
			}
		}
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		//trace("note miss!!");
		if (!boyfriend.stunned && allowHealthModifiers && !daNote.withinCompensation)
		{
			if (combo > 5)
			{
				if (gf.animOffsets.exists('sad') && curSong != "Mic Test")
					gf.playAnim('sad');
				else if (dad.animOffsets.exists('sad') && curSong == "Mic Test")
					dad.playAnim('sad');
			}

			daNote.rating = 'miss';
			if (daNote.noteType != "trigger")
				popUpScore(daNote);
			else
				if (FlxG.save.data.notesplash && !PlayStateChangeables.botPlay && allowHealthModifiers)
					sploshThisShitUp(daNote, daNote.rating); 

			saveNotes.push([
				daNote.strumTime,
				0,
				direction,
				166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166
			]);
			saveJudge.push("miss");

			if (FlxG.save.data.accuracyMod == 1 && daNote.noteType != 'mine')
				totalNotesHit -= 1;

			if (!daNote.isSustainNote && daNote != null && daNote.noteType != 'mine')
				songScore -= 300;

			//NOTE MISS SOUND
			if(FlxG.save.data.missSounds && daNote.noteType != 'mine' && daNote.noteType != 'trigger')
			{
				missSound.stop();
				missSound = FlxG.sound.play(Paths.soundRandom('missnote', 1, 3));
				missSound.volume = FlxG.random.float(0.23, 0.3);
			}

			//FlxG.sound.list.add(missSound);

			// Whole switch statement replaced with a single line :)
			if ((boyfriend.animation.curAnim.name != 'hurt' && !boyfriend.animation.curAnim.name.startsWith("dodge")) || boyfriend.animation.curAnim.curFrame >= 3)
				boyfriend.playAnim('sing' + dataSuffix[direction] + 'miss', true);
			//trace("BUH NOTE MISS PLAY ANIM HERE");

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
			missSound.volume = FlxG.random.float(0.15, 0.2);
		}
		
		if (healthBar.percent < 85)
			healthLerp += PlayStateHealthModifiers.ModifyHealth(storyDifficulty, 9, healthLerp, accuracy);
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

	function playFinaleMusic():Void
	{
		if (curBeat % 16 == 0)
		{
			drums.stop();
			taiko.stop();
			if (dangerLevel < 50 && enemyHealth > 30)
			{
				drums = FlxG.sound.play(Paths.musicRandom('finaleAdaptiveMus/drums_', 0, 1));
				taiko = FlxG.sound.play(Paths.musicRandom('finaleAdaptiveMus/taiko_', 0, 2));
				taiko.time = drums.time;
				//trace("Le Drummos");
			}
			else if (dangerLevel >= 50 && enemyHealth > 30)
			{
				drums = FlxG.sound.play(Paths.musicRandom('finaleAdaptiveMus/drums_', 2, 3));
				taiko = FlxG.sound.play(Paths.musicRandom('finaleAdaptiveMus/taiko_', 0, 5));
				taiko.time = drums.time;
				//trace("Le Drummos but Epico");
			}
			else
			{
				drums = FlxG.sound.play(Paths.music('finaleAdaptiveMus/drums_climax'));
				taiko = FlxG.sound.play(Paths.musicRandom('finaleAdaptiveMus/taiko_', 4, 5));
				taiko.time = drums.time;
				//trace("Le Drummos but Epicest");
			}
			musicGroup.add(drums);
			musicGroup.add(taiko);
		}
		//Choir, Hihats, Violin/Woodwinds, and Slayer
		if (curBeat % 32 == 0)
		{
			choir.stop();
			hats.stop();
			if (dangerLevel < 50 && enemyHealth > 30)
			{
				choir = FlxG.sound.play(Paths.music('finaleAdaptiveMus/choir_0'));
				hats = FlxG.sound.play(Paths.music('finaleAdaptiveMus/hats_0'));
				if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
					adders = FlxG.sound.play(Paths.music('finaleAdaptiveMus/woodwinds'));
			}
			else if (dangerLevel >= 50 && enemyHealth > 30)
			{
				adders.stop();
				choir = FlxG.sound.play(Paths.music('finaleAdaptiveMus/choir_1'));
				hats = FlxG.sound.play(Paths.music('finaleAdaptiveMus/hats_1'));
				adders = FlxG.sound.play(Paths.music('finaleAdaptiveMus/violin'));
			}
			else
			{
				adders.stop();
				pads.stop();
				choir = FlxG.sound.play(Paths.music('finaleAdaptiveMus/choir_1'));
				hats = FlxG.sound.play(Paths.music('finaleAdaptiveMus/hats_1'));
				adders = FlxG.sound.play(Paths.music('finaleAdaptiveMus/elecpiano_climax'));
				pads = FlxG.sound.play(Paths.music('finaleAdaptiveMus/pads_climax'));
			}

			if (dangerLevel < 50 && enemyHealth > 30 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
				slayer = FlxG.sound.play(Paths.music('finaleAdaptiveMus/slayer_0'));
			else if (dangerLevel < 50 && enemyHealth > 30 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				slayer = FlxG.sound.play(Paths.music('finaleAdaptiveMus/slayer_1'));
				//if (dangerLevel < 50)
				//	dangerLevel = 50;
			}
			else if (enemyHealth <= 30)
			{
				slayer.stop();
				slayer = FlxG.sound.play(Paths.music('finaleAdaptiveMus/slayer_climax'));
				//if (dangerLevel < 50)
				//	dangerLevel = 50;
			}
			//trace("Le Choir/Hats/Adders/Slayers");
			musicGroup.add(choir);
			musicGroup.add(hats);
			if (adders.playing)
				musicGroup.add(adders);
			if (pads.playing)
				musicGroup.add(pads);
			if (slayer.playing)
				musicGroup.add(slayer);
			dangerLevel = FlxG.random.int(49, 50);
			enemyHealth = FlxG.random.int(31, 30);
		}
		//Cymbals/Hats
		if (curBeat % 64 == 0)
		{
			retalHats.stop();
			FlxG.sound.play(Paths.music('finaleAdaptiveMus/stab'), 0.9);
			if (dangerLevel < 50 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
				retalHats = FlxG.sound.play(Paths.music('finaleAdaptiveMus/retal-hats_0'));
			else if (dangerLevel < 50 && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
				retalHats = FlxG.sound.play(Paths.music('finaleAdaptiveMus/retal-hats_1'));
			else
				retalHats = FlxG.sound.play(Paths.music('finaleAdaptiveMus/retal-hats_0'));
			//retalHats.time = drums.time;
			//trace("Le RetalHats/Crash");
			musicGroup.add(retalHats);
		}
		//Bells, and Pads
		if (curBeat % 64 == 32)
		{
			if (dangerLevel < 50)
			{
				bells.stop();
				bells = FlxG.sound.play(Paths.music('finaleAdaptiveMus/bells_0'));
				if (!PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && FlxG.random.bool(50))
					pads = FlxG.sound.play(Paths.music('finaleAdaptiveMus/pads_0'));
			}
			else if (enemyHealth > 30)
			{
				if (FlxG.random.bool(75))
				{
					bells.stop();
					bells = FlxG.sound.play(Paths.music('finaleAdaptiveMus/bells_1'));
				}
				pads = FlxG.sound.play(Paths.music('finaleAdaptiveMus/pads_1'));
			}
			else
			{
				bells.stop();
				bells = FlxG.sound.play(Paths.music('finaleAdaptiveMus/bells_1'));
			}
			//trace("Le Bells & Pads");
			if (bells.playing)
				musicGroup.add(bells);
			if (pads.playing)
				musicGroup.add(pads);
		}
		if (curBeat % 128 == 0)
		{
			danger.stop();
			danger = FlxG.sound.play(Paths.music('finaleAdaptiveMus/danger-loop'), 0.1);
			//trace("Le Danger | Volume = " + danger.volume);
			musicGroup.add(danger);
		}
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
		if (hitsoundType != 'botplay' && !note.withinCompensation)
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
					if (lagCompIcon.alpha < 0.1)
					{
						//For Shit Rating
						FlxG.sound.play(Paths.sound("Note_" + hitsoundType + "_Crap"), noteHitVolume);
						//Vocal Shit
						vocals.volume = 0.1;
					}
					else
					{
						FlxG.sound.play(Paths.sound("Note_" + hitsoundType + "_Bad"), noteHitVolume);
						vocals.volume = 0.55;
					}
			}
		}
		else
		{
			FlxG.sound.play(Paths.sound("Note_botplay"), noteHitVolume);
			vocals.volume = 1;
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
			vocals.volume = 1;
		//});
	}

	function enemyNoteHit(note:Note):Void
	{
		var altAnim:String = "";
		var enemyMissRandomizer:Bool = false;
	
		// Accessing the animation name directly to play it
		var singData:Int = Std.int(Math.abs(note.noteData));
		
		switch (SONG.song)
		{
			case "Sudden Confrontation" | "Sprouting Irritation":
				//trace ("Enemy miss is " + enemyMissRandomizer);
				if (!note.forceMiss)
				{
					if (!note.isSustainNote && !note.isParent && enemyCanFail)
						enemyMissRandomizer = FlxG.random.bool(accuracy / 4);
					if (enemyMissRandomizer)
					{
						note.forceMiss = true;
						enemyMiss(dataSuffix[singData]);
					}
					//trace ("Enemy miss is " + enemyMissRandomizer);
				}
		}

		//trace ("Enemy miss is " + enemyMissRandomizer);
		//trace ("then why the FUCK did this appear???");

		if (!note.tooLate && !note.forceMiss)
		{
			//trace ("OK NOW Enemy miss is " + enemyMissRandomizer);

			if (SONG.notes[Math.floor(curStep / 16)] != null)
			{
				if (SONG.notes[Math.floor(curStep / 16)].altAnim)
					altAnim = '-alt';
			}

			//EnemyMiss Shit
			switch (SONG.song)
			{
				case "Sudden Confrontation" | "Sprouting Irritation":
					miscs.volume = 1;
					//"Enemy Sing" health drain
					if (healthBar.percent >= 25 && allowHealthModifiers)
					{
						if (!note.isSustainNote)
							healthLerp += PlayStateHealthModifiers.ModifyHealth(storyDifficulty, 10, healthLerp, accuracy);
						else
							healthLerp += PlayStateHealthModifiers.ModifyHealth(storyDifficulty, 11, healthLerp, accuracy);
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
					if (Math.abs(note.noteData) == spr.ID)
					{
						//trace ("NOW now enemy miss is " + enemyMissRandomizer);
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

			dad.holdTimer = 0;

			if (SONG.needsVoices)
				vocals.volume = 1;

			//trace ("OK NOW enemy miss is " + enemyMissRandomizer);
			note.finnaBeKilled = true;
			note.active = false;
			note.kill();
			notes.remove(note, true);
			note.destroy();
			//trace('deleted nenemy note. The fucker missed = ' + enemyMissRandomizer);
			//OK so it aint deleting the note, find out why.
		}
		if (note.tooLate)
		{
			if (note.noteType == 'mine' || note.forceMiss)
			{
				//trace("YOU BETTER NOT DELETE SHIT");
				note.finnaBeKilled = true;
				note.visible = false;
				note.kill();
				notes.remove(note, true);
				//trace('removed via the too late thing');
			}
		}
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
			if (note.noteType != 'mine')
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
			else if (FlxG.save.data.notesplash && !PlayStateChangeables.botPlay && allowHealthModifiers)
				sploshThisShitUp(note, note.rating);
		}

		//if (!resetMashViolation && mashViolations >= 1)
		//	mashViolations--;

		//if (mashViolations < 0)
		//	mashViolations = 0;

		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
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
					healthLerp += PlayStateHealthModifiers.ModifyHealth(storyDifficulty, 8, healthLerp, accuracy);
				vocals.volume = 1;
				if (notePresses <= noteMashingThreshold)
					totalNotesHit += 1;
				
				if (!PlayStateChangeables.botPlay && FlxG.save.data.notesfx && allowNoteHitSounds)
				{
					//Hit Sounds For Sustain Notes
					FlxG.sound.play(Paths.sound('Note_' + hitsoundType + '_Sustain'), noteHitVolume);
				}
			}

			switch (note.noteType)
			{
				case 'mine':
					dad.playAnim('gunSHOOT', true);
					if (stageOverlay.exists && !PlayStateChangeables.Optimize)
						stageOverlay.animation.play('static');
					if (!PlayStateChangeables.botPlay && !note.withinCompensation)
					{
						timesShot++;
						if (allowHealthModifiers)
						{
							FlxG.sound.play(Paths.sound('Note_Mine'));
							boyfriend.playAnim('hurt', true);
							camShake(true);
							hurtVignette.alpha = 1;
							songScore -= 300;
							//misses++;
							//la health drain for mine notes
							if (healthLerp > 0.7 && timesShot <= 2)
								healthLerp = 0.25;
							else if (healthLerp < 0.7 && timesShot <= 2)
								healthLerp -= 0.05;
							if (timesShot >= 3)
								healthLerp -= 100;
							//if (theFunne && !note.isSustainNote)
							//	noteMiss(note.noteData, note);
							totalNotesHit -= 1;
							//trace(timesShot + ' bullet/s eaten');
						}
					}
					else
						camShake();
				case 'trigger':
					if (stageOverlay.exists && !PlayStateChangeables.Optimize)
						stageOverlay.animation.play('static');
					dad.playAnim('gunSHOOT', true);
					camShake();
					FlxG.sound.play(Paths.sound('Note_Trigger'), 0.75);
					sicks++;
					//la health gain for trigger notes
					healthLerp += PlayStateHealthModifiers.ModifyHealth(storyDifficulty, 12, healthLerp, accuracy);
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
				saveNotes.push(array);
				saveJudge.push(note.rating);
			}

			if (note.noteType != 'mine')
			{
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (Math.abs(note.noteData) == spr.ID)
					{
						spr.animation.play('confirm', true);
					}
				});
			}

			note.finnaBeKilled = true;
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

		if (FlxG.sound.music != null)
		{
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

		// 3 / 1000 chance for Gitaroo Man easter egg
		//debating if i should remove this or not
		if (!FlxG.random.bool(0.1))
			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		else
			FlxG.switchState(new GitarooPause());	
	}

	function literallyFuckingDie():Void
	{
		boyfriend.stunned = true;
		prevHealth = 1;

		persistentUpdate = false;
		persistentDraw = false;
		paused = true;
		died = true;

		deaths++;
		hasReset = true;
		showedLoadSprInCurSong = true;

		vocals.stop();

		miscs.stop();
		FlxG.sound.music.stop();
		musicGroup.stop();

		openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
	}

	function lightningStrikeShit():Void
	{
		stageSound = FlxG.sound.play(Paths.soundRandom('glitch_', 1, 2));
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

	override function stepHit()
	{
		super.stepHit();

		//Moved from BeatHit
		//if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition)) > 20
		|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition)) > 20))
		{
			if (!resultsPresent && !inCutscene && songStarted && !endedSong)
				resyncVocals();
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			// Make sure Girlfriend cheers only for certain songs
			if (!resultsPresent && !endedSong)
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
											triggeredAlready = true;
										}
									}
									else 
										triggeredAlready = false;
								}
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
					+ " \n"
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ")   "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Combo Breaks: "
					+ misses, "", true,
					songLength
					- Conductor.songPosition);
			}
			#end
		}
		//camFollowShit();
	}

	//Removed from void, does this fix camfollowing?
	//No
	//bro it's the charts
	function camFollowShit():Void
	{	
		//if (camFollowSpeed != 0.04)
		if (camGame.followLerp != camFollowSpeed * (30 / FlxG.save.data.fpsCap))
		//{
			camGame.followLerp = camFollowSpeed * (30 / FlxG.save.data.fpsCap);
			//trace("CamFollowLerp is now " + camGame.followLerp);
		//}
		//might cause lag ugh
		//from beathit() function

		if (PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (camFollow.x != dad.getMidpoint().x + 150 + dadCamFollowOffsetX && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				//Mashing Detection Reset
				if (notePresses != 0 && noteMashingThreshold != defaultMashingThreshold)
				{
					noteMashingThreshold = defaultMashingThreshold;
					notePresses = 0;
					//trace ("Reset Mashing SHit");
				}

				if (timesShot > 0)
					timesShot = 0;

				if (camFollowing && !triggeredCamShake)
				{
					//trace("CamFollowSpeed = " + camFollowSpeed);

					if (curSong == 'Mic Test' && !PlayStateChangeables.Optimize) //&& (!camTweened || camTweened == null))
					{
						camTween = FlxTween.tween(camGame, {zoom: 1.5}, (Conductor.stepCrochet * 4 / 800), {type: ONESHOT, ease: FlxEase.elasticInOut});
						//camTweened = true;
					}
					
					camFollow.setPosition(dad.getMidpoint().x + 150 + dadCamFollowOffsetX, dad.getMidpoint().y - 100 + dadCamFollowOffsetY);
					//trace("CamFollowed Dad");
				}

				vocals.volume = 1;
				//trace("Vocal Volume = " + vocals.volume);

				//CamFollow Repositioning Per Dad Char
				/*switch (dad.curCharacter)
				{
				}*/
			}

			if (camFollow.x != boyfriend.getMidpoint().x - 100 + bfCamFollowOffsetX && PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				//Mashing Detection Reset
				if (notePresses != 0 && noteMashingThreshold != defaultMashingThreshold)
				{
					noteMashingThreshold = defaultMashingThreshold;
					notePresses = 0;
					//trace ("Reset Mashing SHit");
				}
				
				if (camFollowing && !triggeredCamShake)
				{
					//trace("CamFollowSpeed = " + camFollowSpeed);

					if (curSong == 'Mic Test' && !PlayStateChangeables.Optimize) // && (camTweened || camTweened == null))
					{
						camTween = FlxTween.tween(camGame, {zoom: 1.2}, (Conductor.stepCrochet * 4 / 800), {type: ONESHOT, ease: FlxEase.elasticInOut});
						//camTweened = false;
					}

					camFollow.setPosition(boyfriend.getMidpoint().x - 100 + bfCamFollowOffsetX, boyfriend.getMidpoint().y - 100 + bfCamFollowOffsetY);
					//trace("CamFollowed BF");
				}

				vocals.volume = 1;
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
						case 6:
							subtitleTimer = new FlxTimer().start(0.3, function(tmr:FlxTimer)
							{
								changeSubtitles("Mic test.", 0xFFfff300);
							});
						case 8:
							clearSubtitles();
							subtitleTimer = new FlxTimer().start(0.025, function(tmr:FlxTimer)
							{
								tutorialGraphicA.alpha += 0.085;
								tutorialText.alpha += 0.085;
								if (tutorialGraphicA.alpha < 1 && tutorialText.alpha < 1)
									tmr.reset(0.025);
							});
						case 20:
							subtitleTimer = new FlxTimer().start(0.025, function(tmr:FlxTimer)
							{
								tutorialGraphicA.alpha -= 0.09;
								tutorialText.alpha -= 0.09;
								if (tutorialGraphicA.alpha > 0 && tutorialText.alpha > 0)
									tmr.reset(0.025);
								else
									tutorialGraphicA.destroy();
									tutorialText.destroy();
							});
						case 22:
							changeSubtitles("Ok, here we go.", 0xFFfff300);
						case 24:
							clearSubtitles();
							subtitleTimer = new FlxTimer().start(0.025, function(tmr:FlxTimer)
							{
								tutorialGraphicB.alpha += 0.085;
								if (tutorialGraphicB.alpha < 1)
									tmr.reset(0.025);
							});
						case 39:
							subtitleTimer = new FlxTimer().start(0.025, function(tmr:FlxTimer)
							{
								tutorialGraphicB.alpha -= 0.09;
								if (tutorialGraphicB.alpha > 0)
									tmr.reset(0.025);
								else
									tutorialGraphicB.destroy();
							});
						case 40:
							subtitleTimer = new FlxTimer().start(0.025, function(tmr:FlxTimer)
							{	
								tutorialGraphicC.alpha += 0.085;
								if (tutorialGraphicC.alpha < 1)
									tmr.reset(0.025);
							});
						case 52:
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
							changeSubtitles("(I'm able to do that)", 0xFF4adaff);
						case 184:
							changeSubtitles("(It's a little...)", 0xFF4adaff);
						case 188:
							changeSubtitles("(...too hard for me-?)", 0xFF4adaff);
						case 190:
							clearSubtitles();
						case 192:
							changeSubtitles("[Angrily] LORD. PLEASE. HELP. 'US'.", 0xFF5ce766);
						case 196:
							changeSubtitles("OH, LORD. PLEASE. 'HELP'. 'US'.", 0xFF5ce766);
						case 200:
							changeSubtitles("LORD LORD, PLEASE. HELP. 'US'.", 0xFF5ce766);
						case 204:
							changeSubtitles("[Angrily babbling]", 0xff9feea4);
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
							changeSubtitles("[Scolding]", 0xff9feea4);
						case 168:
							changeSubtitles("([Responding])", 0xff93dbec);
						case 176:
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
							changeSubtitles("{How could one say}", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
						case 36:
							changeSubtitles("{How could one say something so demeaning?}", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
						case 40:
							changeSubtitles("{To someone who}", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
						case 44:
							changeSubtitles("{To someone who did all of the cleaning after}", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
						case 48:
							changeSubtitles("{something young and dumb}", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
						case 54:
							changeSubtitles("{something young and dumb and oh}", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
						case 58:
							changeSubtitles("{something young and dumb and oh so fragile}", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
						case 64:
							clearSubtitles();
						case 96:
							changeSubtitles("{All your mother wanted was to}", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
						case 100:
							changeSubtitles("{All your mother wanted was to give us cheer.}", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
						case 104:
							changeSubtitles("{Nobody expected that we'd}", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
						case 108:
							changeSubtitles("{Nobody expected that we'd end up here.}", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
						case 111:
							changeSubtitles("{Just you and me and}", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
						case 116:
							changeSubtitles("{Just you and me and her}", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
						case 118:
							changeSubtitles("{10}", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
						case 120:
							changeSubtitles("{10 miles}", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
						case 122:
							changeSubtitles("{10 miles far}", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
						case 123:
							changeSubtitles("{10 miles far away into the city}.", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
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
							changeSubtitles("{You still are}", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
						case 227:
							changeSubtitles("{You still are an ungrateful little sick brat}", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
						case 232:
							changeSubtitles("{Maybe one day you'll}", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
						case 235:
							changeSubtitles("{Maybe one day you'll realize your mistakes so that}", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
						case 240:
							changeSubtitles("{You'll drown in regret}", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
						case 246:
							changeSubtitles("{You'll drown in regret once}", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
						case 248:
							changeSubtitles("{You'll drown in regret once it's}", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
						case 250:
							changeSubtitles("{You'll drown in regret once it's too}", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
						case 252:
							changeSubtitles("{You'll drown in regret once it's too late}", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
						case 254:
							changeSubtitles("{You'll drown in regret once it's too late for}", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
						case 256:
							changeSubtitles("{You'll drown in regret once it's too late for us.}", 0x00000000, 0xFFD39D9D, SUBTRACT, 0.35, 0, "VCR OSD Mono");
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
	
	public function setSongTime(time:Float, ignoreFlxGMusic:Bool = false)
	{
		if(time < 0)
			time = 0;

		musicGroup.pause();
		vocals.pause();
		miscs.pause();

		if (!ignoreFlxGMusic)
		{
			FlxG.sound.music.time = time;
			//trace("resynced music time aaa");
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
		}
		FlxG.sound.music.play();
		instLowHP.time = time;
		musicGroup.resume();

		vocals.time = time;
		vocals.play();

		miscs.time = time;
		miscs.play();

		Conductor.songPosition = time;
		#if debug
		trace('did song time setting shit');
		#end
	}

	var beatCheck:Int = 0;
	//For preventing double-beat accients

	private function createStageParticle(particlePath, min:Int = 1, max:Int = 15, color:FlxColor = FlxColor.WHITE, nextColor:FlxColor = FlxColor.BLACK):Void
	{
		var particlesNum:Int = FlxG.random.int(min, max);
		var currentWeek:String = 'week' + storyWeek;
		var width:Float = (2000 / particlesNum);
		var particlePercentage:Float = 1;
		for (j in 0...3)
		{
			for (i in 0...particlesNum)
			{
				particlePercentage = (i / particlesNum) * 10;
				var particle:PsychEngineFancyStageShit.FancyStageParticle = new PsychEngineFancyStageShit.FancyStageParticle(particlePath, currentWeek, particlePercentage, 0, 9, -400 + width * i + FlxG.random.float(-width / 5, width / 5), cityStreets.y + 200 + (FlxG.random.float(50, 125) + j * 40), color, nextColor);
				stageParticles.add(particle);
			}
		}
	}

	override function beatHit()
	{
		super.beatHit();

		//trace(curBeat);

		if (beatCheck < curBeat)
		{
			beatCheck = curBeat;
			if (generatedMusic)
			{
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
			}

			if (SONG.notes[Math.floor(curStep / 16)] != null)
			{
				// Here so that Dad doesnt interrupt his own notes
				if (!dad.animation.curAnim.name.startsWith("sing") && (!dad.animation.curAnim.name.startsWith("gun") || dad.animation.curAnim.curFrame >= 3))
					if (curBeat % idleBeat == 0 || dad.curCharacter == "priest-theborderpray" || dad.curCharacter == "table-default")
						dad.dance(idleToBeat);
			}
			// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

			//HARDCODING FOR ZOOMS
			if (FlxG.save.data.camzoom && camZooming && !resultsPresent && !inResults)
			{
				switch (curSong)
				{
					case "Up and Beyond":
						if (FlxG.save.data.camzoom && camZooming && camGame.zoom < 1.35 && curBeat % 4 == 1)
						{
							camGame.zoom += 0.020;
							camHUD.zoom += 0.015;
							//trace("Scroll Speed Multiplier = " + sustainHeightMultiplier);
						}
					case "Variegated Skylines":
						if (camGame.zoom < 1.35 && curBeat % 4 == 0 && curBeat != 383)
						{
							camGame.zoom += 0.025;
							camHUD.zoom += 0.020;
							//trace("Scroll Speed Multiplier = " + sustainHeightMultiplier);
						}
					default:
						if (camGame.zoom < 1.35 && curBeat % 4 == 0)
						{
							camGame.zoom += 0.028;
							camHUD.zoom += 0.014;
							//trace("Scroll Speed Multiplier = " + sustainHeightMultiplier);
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

			//Mid song Events - If statement is added to prevent them from playing in the ResultsScreen
			if (!inResults && !resultsPresent)
			{
				//Subtitle shits
				doSubtitleShit();

				if (!PlayStateChangeables.Optimize)
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
								case 207 | 247 | 279:
									if (accuracy > 30)
										dad.playAnim('cheer', true);
									else
										dad.playAnim('cheerFail', true);
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
								case 279:
									allowHeartBeatSounds = false;
									camZooming = false;
							}
						case 'Awkward Pauses':
							switch (curBeat)
							{
								case 31:
									camZooming = true;
								case 250:
									camFollowSpeed = 0.08;
									//camFollowing = false;
								case 254:
									dadCamFollowOffsetX = -60;
									dadCamFollowOffsetY = -60;
									dad.playAnim('badFingerStart', true);
									FlxTween.tween(camGame, {zoom: 1}, 0.1, {type: ONESHOT, ease: FlxEase.expoIn});
									allowHeartBeatSounds = false;
								case 255:
									//camFollowing = false;
									midsongCutscene = true;
									dad.playAnim('badFingerHold', true);
									boyfriend.playAnim('scared', false);
									gf.playAnim('scared', true);
									if (FlxG.save.data.distractions)
									{
										//Hides the HUD and zooms the camera out once daddy dearest flips off bf
										camHUD.alpha = 0;
										camZooming = false;
										camGame.zoom = 0.8;
									}
								case 256:
									camFollowSpeed = 0.04;
									dadCamFollowOffsetX = 0;
									dadCamFollowOffsetY = -40;
									allowHeartBeatSounds = true;
									gf.playAnim('danceRight', true);
									boyfriend.playAnim('scaredHOLD', false);
									//camFollowing = true;
									if (FlxG.save.data.distractions)
										FlxTween.tween(camHUD, {alpha: 1}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.quadIn});
								case 258:
									defaultCamZoom += 0.15;
									camZooming = true;
									boyfriend.playAnim('awkward', true);
									//trace("AWKWARD LMAO");
								case 260:
									midsongCutscene = false;
									defaultCamZoom -= 0.15;
								case 415:
									allowHeartBeatSounds = false;
									camZooming = false;
							}
						case 'Up and Beyond':
							//Hardcoding for Zooms
							if (FlxG.save.data.camzoom && camZooming && curBeat % 4 == 3 && curBeat > 193 && curBeat < 257)
							{
								if (FlxG.save.data.camzoom)
								{
									camGame.zoom += 0.021;
									camHUD.zoom += 0.017;
								}
							}
							if (FlxG.save.data.camzoom && camZooming && curBeat % 4 == 3 && curBeat > 389 && curBeat < 513)
							{
								if (FlxG.save.data.camzoom)
								{
									camGame.zoom += 0.022;
									camHUD.zoom += 0.0175;
								}
							}
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
								case 63:
									camZooming = true;
								case 175:
									camZooming = false;
									boyfriend.playAnim('awkward', true);
								case 176:
									camZooming = true;
								case 190:
									//VINE BOOM
									iconP2.animation.play('priest-theborderannoyed');
									dad.playAnim('gotPissed', true);
									boyfriend.playAnim('awkward', true);
									camZooming = false;
									midsongCutscene = true;
									stageOverlay.alpha = 0.65;
									if (FlxG.save.data.distractions)
									{
										camHUD.alpha = 0;
										camGame.zoom = 0.95;
										FlxTween.tween(camGame, {zoom: defaultCamZoom}, 1.0, 
											{type: ONESHOT, 
												ease: FlxEase.quadInOut,
											});
									}
								case 191:
									swapDadForNewChar(dadSwaperoo, 100, 315);
									camZooming = true;
									midsongCutscene = false;
									if (FlxG.save.data.distractions)
										camHUD.alpha = 1;
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
										camGame.zoom = 1.0;
										FlxTween.tween(camGame, {zoom: defaultCamZoom}, 1.3, 
											{type: ONESHOT, 
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
								case 159:
									dad.playAnim('gotPissed', true);
								case 186:
									dad.playAnim('gotPissed', true);
								case 191:
									boyfriend.playAnim('concerned', true);
								case 207:
									defaultCamZoom = 0.83;
									boyfriend.playAnim('singRIGHT', true);
									camFollowing = false;
									midsongCutscene = true;
									camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
								case 208:
									boyfriend.playAnim('singLEFTmiss', true);
									defaultCamZoom = 0.905;
								case 212:
									defaultCamZoom = 0.865;
									camFollowing = true;
									midsongCutscene = false;
								case 254:
									dad.playAnim('gotPissed', true);
								case 256:
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
									defaultCamZoom = 0.95;
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
									var blackShit:FlxSprite = new FlxSprite(-FlxG.width * camGame.zoom,
										-FlxG.height * camGame.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
									blackShit.scrollFactor.set();
									add(blackShit);
									camHUD.alpha = 0;
							}					
						case 'Retaliation':
							// HARDCODING FOR ZOOMS!
							if (FlxG.save.data.camzoom && camZooming && camGame.zoom < 1.35)
							{
								if (curBeat >= 160 && curBeat < 224)
								{
									camGame.zoom += 0.021;
									camHUD.zoom += 0.017;	
								}
								else if (curBeat >= 354 && curBeat < 416)
								{
									camGame.zoom += 0.025;
									camHUD.zoom += 0.02;
								}
							}
							else if (curBeat % 4 == 2 && curBeat > 316 && curBeat < 480)
							{
								if (camZooming && FlxG.save.data.camzoom && FlxG.save.data.flashing)
								{
									camGame.zoom += 0.024;
									camHUD.zoom += 0.018;
								}
							}			
							switch (curBeat)
							{
								case 31:
									camZooming = true;
								case 32:
									//trace("YOU BETTER BE CHANGED FROM " +  camFollowSpeed);
									camFollowSpeed = 0.04;
									defaultCamZoom = 1;
								case 155:
									camZooming = false;
									camFollowing = false;
									camGame.zoom -= 0.02;
									bfCamFollowOffsetY += 40;
								case 158:
									camFollow.x = gf.getGraphicMidpoint().x + 10;
									camFollow.y = gf.getGraphicMidpoint().y + 50;
								case 159:
									//glitchyGlitchEffect.active = true;
									dad.playAnim('midsongAnim', true);
									camZooming = true;
								case 160:
									camFollowing = true;
									defaultCamZoom = 0.815;
									camGame.zoom += 0.02;
									//glitchyGlitchEffect.active = false;
									if(FlxG.save.data.distractions)
									{
										FlxTween.tween(bgBoppers1, {alpha: 0.65, y: bgBoppers1.y - bgBoppers1.height / 1.2}, 0.5, {type: ONESHOT, ease: FlxEase.quadOut});
										FlxTween.tween(theBorderBG, {alpha: 0.3}, 0.5, {type: ONESHOT, ease: FlxEase.quadOut});
									}
									characterBlurEffect.alpha = 0.8;
									allowBGBopping = true;
									dadCamFollowOffsetY = -35;
									bfCamFollowOffsetY -= 20;
								case 223:
									//glitchyGlitchEffect.active = true;
									if(FlxG.save.data.distractions)
									{
										FlxTween.tween(bgBoppers1, {alpha: 0, y: 590}, 1, {type: ONESHOT, ease: FlxEase.quadIn});
										FlxTween.tween(theBorderBG, {alpha: 0.5}, 0.5, {type: ONESHOT, ease: FlxEase.quadOut});
									}
								case 224:
									//glitchyGlitchEffect.active = false;
									defaultCamZoom = 0.95;
									characterBlurEffect.alpha = 0.5;
									allowBGBopping = false;
									dadCamFollowOffsetY = -25;
									bfCamFollowOffsetY -= 20;
								case 288:
									defaultCamZoom = 0.99;
								case 347:
									camZooming = false;
									camGame.zoom -= 0.04;
								case 351:
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
									characterBlurEffect.alpha = 1;
									defaultCamZoom = 0.815;
									camGame.zoom += 0.02;
									allowBGBopping = true;
									if(FlxG.save.data.distractions)
									{
										FlxTween.tween(bgBoppers1, {alpha: 0.8, y: bgBoppers1.y - bgBoppers1.height / 1.2}, 0.5, {type: ONESHOT, ease: FlxEase.quadOut});
										FlxTween.tween(theBorderBG, {alpha: 0.3}, 0.5, {type: ONESHOT, ease: FlxEase.quadOut});
									}
								case 416:
									characterBlurEffect.alpha = 0.5;
									defaultCamZoom = 0.82;
									dadCamFollowOffsetY = -25;
									bfCamFollowOffsetY -= 10;
								case 479:
									allowHeartBeatSounds = false;
									camZooming = false;
								case 480:
									bfCamFollowOffsetY -= 10;
									allowBGBopping = false;
									allowNoteHitSounds = false;
									camFollowSpeed = 0.02;
									if(FlxG.save.data.distractions)
									{
										if(FlxG.save.data.distractions)
											FlxTween.tween(bgBoppers1, {alpha: -10, y: 690}, 4.1142, {type: ONESHOT, ease: FlxEase.quadIn});
										FlxTween.tween(camHUD, {alpha: 0.6}, 4.1142, {type: ONESHOT, ease: FlxEase.sineInOut, startDelay: 0.1});
										FlxTween.tween(theBorderBG, {alpha: 0.8}, 4.1142, {type: ONESHOT, ease: FlxEase.sineInOut, startDelay: 0.1});
										theBorderBG.alpha += 0.0035;
										//trace('HUD is now Translucent');
									}
									dadCamFollowOffsetY = -25;
								case 507:
									dadCamFollowOffsetY = -5;
								case 508:
									characterBlurEffect.alpha = 0.3;
									//glitchyGlitchEffect.active = true;
									camFollowSpeed = 0.04;
									boyfriend.playAnim('awkward', true);
									midsongCutscene = true;
									dad.playAnim('endsongAnim1', true);
									FlxTween.tween(camGame, {zoom: 1.65}, 2, {type: ONESHOT, ease: FlxEase.quadIn});
								case 509:
									//glitchyGlitchEffect.active = false;
									boyfriend.playAnim('concerned', true);
									dad.playAnim('endsongAnim1', true);
								case 510:
									dad.playAnim('endsongAnim2', true);
								case 511:
									boyfriend.playAnim('scared', true);
									dad.playAnim('endsongAnim3', true);
									camShake();
									theBorderBG.animation.play('lightning');
								case 512:
									remove(boyfriend);
									remove(dad);
									stageOverlay.kill();
									stageOverlay.destroy();
									characterBlurEffect.destroy();
									var blackShit:FlxSprite = new FlxSprite(-FlxG.width * camGame.zoom,
										-FlxG.height * camGame.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
									blackShit.scrollFactor.set();
									add(blackShit);
									camHUD.alpha = 1;
									camGame.flash(flashColor, 0.5);
									if (isStoryMode)
										camHUD.alpha = 0;
							}
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
								case 259:
									allowHeartBeatSounds = false;
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
										grpStrumLine.forEach(function(leStrussy:FlxSprite)
										{
											FlxTween.tween(leStrussy, {alpha: 0}, Conductor.crochet * 4 / 1000, {type: ONESHOT, ease: FlxEase.quadIn});
										});
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
									camShake(true);
									allowHeartBeatSounds = false;
									camFollowSpeed = 0.045;
								case 176:
									boyfriend.playAnim('scaredHOLD', false);
									gf.playAnim('cheerFail');
									camGame.zoom = 0.8;
								case 179:
									cpuStrums.forEach(function(babyArrow:FlxSprite)
									{
										FlxTween.tween(babyArrow, {alpha: 0.75}, 0.5, {type: ONESHOT, ease: FlxEase.quadIn});
									});
									playerStrums.forEach(function(babyArrow:FlxSprite)
									{
										FlxTween.tween(babyArrow, {alpha: 1}, 0.2, {type: ONESHOT, ease: FlxEase.quadIn});
									});
									if (FlxG.save.data.strumline)
										grpStrumLine.forEach(function(leStrussy:FlxSprite)
										{
											FlxTween.tween(leStrussy, {alpha: 0.45}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.quadIn});
										});
									gfSpeed = 1;
								case 180:
									camFollowSpeed = 0.04;
									allowHeartBeatSounds = true;
									midsongCutscene = false;
									camZooming = true;
								case 244:
									camFollowSpeed = 0.05;
								case 300:
									gfSpeed = 0;
									gf.playAnim('cheerFail');
								case 302:
									camFollowing = false;
									midsongCutscene = true;
									camFollow.x = gf.getGraphicMidpoint().x;
									camFollow.y = gf.getGraphicMidpoint().y - 30;
									camZooming = false;
									FlxTween.tween(camGame, {zoom: 1}, 0.5, {type: ONESHOT, ease: FlxEase.elasticInOut});
								case 304:
									if (FlxG.save.data.distractions)
									{
										//Hides the HUD and zooms the camera out once priest speaks
										//camHUD.visible = false;
										strumLineNotes.forEach(function(babyArrow:FlxSprite)
										{
											FlxTween.tween(babyArrow, {alpha: 0}, 0.2, {type: ONESHOT, ease: FlxEase.quadOut});
										});
										if (FlxG.save.data.strumline)
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
									//Priest: Yfou--
								case 305:
									//Priest: --can't
									gf.playAnim('singUP-alt', true);
								case 306:
									//Priest: --sing!
									dad.playAnim('gunPISSED', true);
									gf.playAnim('singUP-alt', true);
								case 307:
									camFollow.y -= 10;
									camFollowing = true;
									camGame.zoom = 0.9;
									boyfriend.playAnim('scared', true);
									dad.playAnim('gunWARNING', true);
									gf.playAnim('scared', true);
									camShake();
									//gf getting scared cause pico shoots a warning shot
								case 308:
									cpuStrums.forEach(function(babyArrow:FlxSprite)
									{
										FlxTween.tween(babyArrow, {alpha: 0.75}, 0.5, {type: ONESHOT, ease: FlxEase.quadIn});
									});
									playerStrums.forEach(function(babyArrow:FlxSprite)
									{
										FlxTween.tween(babyArrow, {alpha: 1}, 0.2, {type: ONESHOT, ease: FlxEase.quadIn});
									});
									if (FlxG.save.data.strumline)
										grpStrumLine.forEach(function(leStrussy:FlxSprite)
										{
											FlxTween.tween(leStrussy, {alpha: 0.45}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.quadIn});
										});
									camFollowSpeed = 0.04;
									camZooming = true;
									midsongCutscene = false;
									gfSpeed = 1;
								case 435:
									camFollowSpeed = 0.05;
								case 536:
									camShake();
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
							//Hardcoding for Zooms
							if (FlxG.save.data.camzoom && camZooming && curBeat % 4 == 2 && (curBeat > 96 && curBeat < 130 || curBeat > 192 && curBeat < 256))//curBeat >352 && curBeat < 382
							{
								if (FlxG.save.data.camzoom && FlxG.save.data.flashing)
								{
									camGame.zoom += 0.0265;
									camHUD.zoom += 0.0225;
									stageOverlay.animation.play('singleFlash');
								}
							}
							else if (FlxG.save.data.camzoom && camZooming && curBeat > 352 && curBeat < 416 && curBeat != 383)
							{
								if (FlxG.save.data.camzoom && FlxG.save.data.flashing)
								{
									camGame.zoom += 0.026;
									camHUD.zoom += 0.022;
									if (curBeat % 4 == 0)
										stageOverlay.animation.play('singleFlash');
								}
							}

							if (curBeat % 2 == 0 && stageParticles.visible)
								createStageParticle('theCityPortalOpen/effects/stageParticle');
							
							switch(curBeat)
							{
								case 31:
									camZooming = true;
								case 223:
									dad.blend = SUBTRACT;
									dummyBlackScreen.active = true;
									stageParticles.visible = false;
									FlxTween.tween(dummyBlackScreen, {alpha: 1}, Conductor.crochet / 900, {type: ONESHOT, ease: FlxEase.sineInOut});
								case 224:
									dad.blend = LIGHTEN;
								case 256:
									stageParticles.visible = true;
									camGame.flash(flashColor, Conductor.crochet * 4 / 1000);
									dummyBlackScreen.active = false;
									dummyBlackScreen.alpha = 0;
									dad.blend = NORMAL;
								case 351:
									camZooming = false;
								case 353:
									camZooming = true;
								case 416:
									FlxTween.tween(camGame, {zoom: 1}, Conductor.crochet * 30 / 1000, {type: ONESHOT, ease: FlxEase.sineInOut});
									allowHeartBeatSounds = false;
									camZooming = false;
									camHUD.zoom = 1;
								case 447:
									FlxTween.tween(camGame, {zoom: 0.85}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.expoIn});
									defaultCamZoom = 0.85;
								case 448:
									camShake(false);
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
						case 'Finale':
							playFinaleMusic();
					}
				}
			}

			if (gfSpeed > 0 && curBeat % gfSpeed == 0 && !midsongCutscene)
				gf.dance();

			//(IDK???)> (╯°□°）╯︵ ┻━┻
			if (((boyfriend.animation.curAnim.name != 'idleAfterSing' && !boyfriend.animation.curAnim.name.startsWith('sing') || boyfriend.animation.curAnim.finished) && (boyfriend.animation.curAnim.name != "hurt" && !boyfriend.animation.curAnim.name.startsWith("dodge") || boyfriend.animation.curAnim.finished)) && curBeat % idleBeat == 0 && !midsongCutscene)
				boyfriend.playAnim('idle', idleToBeat);
				//trace("Idle (line 8468)");

			switch (curStage)
			{
				case "border":
					if (FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset && FlxG.save.data.distractions && !midsongCutscene && !resultsPresent)
						lightningStrikeShit();
					
					if (FlxG.save.data.distractions && curSong == "Retaliation")
					{
						if (allowBGBopping)
							bgBoppers1.animation.play('dance', true);
						else if (!allowBGBopping && bgBoppers1.animation.curAnim.name != "idle")
							bgBoppers1.animation.play('idle', true);
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
		}
	}
}