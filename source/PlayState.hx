package;

#if sys
import sys.io.File;
#end
import flixel.input.keyboard.FlxKey;
import flixel.graphics.FlxGraphic;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
//import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.plugin.screengrab.FlxScreenGrab;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.effects.particles.FlxEmitter;
import flixel.effects.particles.FlxParticle;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
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
import lime.media.openal.AL;
import lime.app.Application;
import openfl.Lib;
import openfl.ui.Keyboard;
import openfl.display.Bitmap;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.filters.BitmapFilter;
import openfl.filters.BlurFilter;
import openfl.filters.ShaderFilter;
import IndieCrossShaders;
import openfl.events.KeyboardEvent;
import shaders.WiggleEffect;
import flixel.util.FlxAxes;

#if windows
import Sys;
import sys.FileSystem;
#end

using StringTools;

class PlayState extends MusicBeatState
{
	public static var instance:PlayState;
	public var allowDeaths:Bool = false; //crash prevention

	public static var curStage:String = '';
	public static var stageSuffix:String = '';
	public static var gameOversWithIntros:Array<String> = ['-selfsert']; //never change this variable outside of playstate itself. thank you :3
	public static var SONG:SwagSong = null;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var songsCheatedOn:Array<Bool> = [];
	public static var playlistLength:Int = 0;
	public static var storyProgress:Int = 0;
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var weekScore:Int = 0;
	public var slips:Int = 0;
	public var bads:Int = 0;
	public var goods:Int = 0;
	public var sicks:Int = 0;

	var camGameFilters:Array<BitmapFilter> = [];
	//var camHUDFilters:Array<BitmapFilter> = [];

	// Less laggy controls
	private var keysArray:Array<Dynamic>;
	private var controlArray:Array<String>;

	var songPosGroup:FlxSpriteGroup = null;
	var songPosBG:FlxSprite;
	var songPosBar:FlxBar;
	var songPosDeathIndicator:FlxSprite;
	var songPosClock:FlxSprite;
	var songPosTxt:FlxText;
	private var songPositionBar:Float = 0;
	public var songLength:Float = 0;

	public var showedResults:Bool = false;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	//var songNameTXT:FlxText;

	#if windows
	// Discord RPC variables
	var storyDifficultyText:String = "";
	//var iconRPC:String = "";
	var detailsText:String = "";
	#end

	//VolumeShit
	//Transfered from HitSoundFunction
	var musicVolume:Float = 0;
	var vocalsVolume:Float = 0;
	var soundsVolume:Float = 0;
	var noteHitVolume:Float = 0;
	
	private var lowHPHeartBeat:FlxSound;
	private var lowHPOverlay:FlxSprite;
	var allowHeartBeatSounds:Bool = true;

	//Sound groups and shit
	public var musicGroup:FlxSoundGroup;
	var missSoundGroup:FlxSoundGroup;
	var noteHitSFXGroup:FlxSoundGroup;
	//var specilNoteHitSFXGroup:FlxSoundGroup;

	//Note Hit SFX
	private var noteHitSFX:FlxSound;
	private var noteHitSustainSFX:FlxSound;
	private var specialNoteHitSFX:FlxSound;

	//Sound filter shit
	var coolSoundFilter:FlxSoundFilter;
	var coolSoundFilterTween:FlxTween;

	//Note Hit SFX Shits
	public static var hitsoundType:String = "default"; //this gets set by loadingState everytime so uhh dw abt it lol
	var allowNoteHitSounds:Bool = true;

	//for the adaptive Music
	public var instLowHP:FlxSound;
	//For the FNF voices
	public var vocals:FlxSound;
	//For things such as Playing With Fire Guns and other shits that I am yet to do
	public var miscs:FlxSound;
	//ADAPTIVE MUSIC AAAAA FUKC
	//good god this has gYATT to be turned into a soundgroup LMFAO
	private var drums:FlxSound;
	private var taiko:FlxSound;
	private var choir:FlxSound;
	private var hats:FlxSound;
	private var adders:FlxSound;
	private var slayer:FlxSound;
	private var retalHats:FlxSound;
	private var bells:FlxSound;
	private var pads:FlxSound;
	private var danger:FlxSound;
	public static var pauseMusicName:String = "";
	//FINALE BATTLE SH THIT
	private var dangerLevel:Float = 0;
	var enemyHealth:Float = 100;

	public var dad:Character;
	public static var dadSwaperoo:String = ""; //BAD WAY BUT EH ILL JUST MAKE LOADINGSTATE RESET IT IDFK
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

	public var notes:FlxTypedGroup<Note>;//Notes Spritegroup
	private var unspawnNotes:Array<Note> = [];//Notes Array

	public var strumLine:FlxSprite;

	private var camFollow:FlxObject;
	private static var prevCamFollow:FlxObject;
	private var dadFollowOffset:Array<Float> = [0, 0];
	private var bfFollowOffset:Array<Float> = [0, 0];
	private var singFollowOffset:Array<Float> = [0, 0];
	private var singFollowMultiplier:Float = 1;
	private var camFollowSpeed:Float = 1; //The higher the number is, the faster the camera moves
	private var doCamFollowing:Bool = true;
	private var camTween:FlxTween;

	private var idleCamShakeTimer:Float = 0;

	//ratings layering
	var grpRatingsBG = new FlxSpriteGroup();
	var grpRatingsMG = new FlxSpriteGroup();
	var grpRatingsFG = new FlxSpriteGroup();

	public var strumLineNotes:FlxTypedGroup<FlxSprite> = null;
	public var playerStrums:FlxTypedGroup<FlxSprite> = null;
	public var cpuStrums:FlxTypedGroup<FlxSprite> = null;
	var grpStrumLine:FlxSpriteGroup = null;
	var strumLineBGTween:FlxTween;
	var doStrumLineBGTweening:Bool = false;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	var preventBFIdleAnim:Bool = false;

	private var camZooming:Bool = false;
	private var camZoomUsesTween:Bool = false;
	private var camGameZoomTwn:FlxTween;
	private var camHUDZoomTwn:FlxTween;
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
	var songBPMTween:FlxTween;

	public var health:Float = 1; // making public because sethealth doesnt work without it
	var targetHealth:Float = 1; //So that health changes are smoother
	static var prevHealth:Float = 1;
	var prevHealthTwn:FlxTween;
	public var causeOfDeath:String = '';

	public var allowHealthModifiers:Bool = true; //LAGSPIKE COMPENSATION AAAA
	public var allowLagComp:Bool = true;
	public var lagCompTimer:FlxTimer;

	private var combo:Int = 0;

	public var misses:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var campaignSlips:Int = 0;
	public static var campaignBads:Int = 0;
	public static var campaignGoods:Int = 0;
	public static var campaignSicks:Int = 0;

	public static var campaignDeaths:Int = 0;
	public static var songDeaths:Int = 0;
	public static var normalPityDeaths:Int = 0; //For death pity with health regen
	static var mechanicPityDeaths:Int = 0; //For death pity with mechanics such as pico's gun
	var doPityDeaths:Bool = false;
	public static var hasReset:Bool = false;

	public static var forceCoolIntro:Bool = false;

	public static var accuracy:Float = 0.00; //an internal-use only var keeping track of the player's accuracy
	public static var clearPercentage:Float = 0; //The var we ACTUALLY show to the player - how much we cleared the song
	static var totalCleared:Array<Float> = [0, 0]; //What we use for calculating the clearPercentage - updated in the popUpScore function
	var clearNumTwn:FlxTween;
	public static var campaignRatingArray:Array<String> = [];

	private var totalNotesHit:Float = 0;
	//private var totalNotesHitMax:Float = 0; //To allow for comparisons
	private var totalPlayed:Int = 0;

	private var healthAndScoreGroup:FlxSpriteGroup = null; //because yes

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	var iconP1:HealthIcon; // making these public again because i may be stupid
	var iconP2:HealthIcon; // what could go wrong?

	private var generatedSong:Bool = false;
	private var generatedArrows:Bool = false;

	public var camGame:FlxCamera;
	public var camHUD:FlxCamera;
	public var camEXT:FlxCamera;
	public var pauseBlurLol:BlurFilter;
	var gotShotBlurLol:BlurFilter;
	var gotShotBlurTwn:FlxTween;
	//public var testGLOWFILTER:GlowFilter;

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
	var stageOverlay1:FlxSprite; //Visual
	var stageOverlay2:FlxSprite; //Gameplay
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
	public var subtitleText:FlxText;
	public var subtitleBackground:FlxSprite;
	var defaultSubTxtY:Float = 0;
	var subtitleTimer:FlxTimer;
	var hasSubtitles:Bool = false;

	var endedSong:Bool = false;

	public static var campaignScore:Int = 0;

	//THE HIGHER THE NUMBER, THE CLOSER TO THE CAMERA IT IS, OK?
	var defaultCamZoom:Float = 1.05;

	//public static var theFunne:Bool = true;

	var inCutscene:Bool = false;
	public static var playedCutscene:Bool = false;
	var midsongCutscene:Bool = false;
	var skippingIntro:Bool = false;

	// Per song additive offset
	public static var songOffset:Float = 0;

	// BotPlay text
	private var botPlayText:FlxText;
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

	var loadingIcon:FlxSprite;
	var lagCompIcon:FlxSprite;

	public static var highestCombo:Int = 0;

	// Animation common suffixes
	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

	public static var startTime:Float = 0.0;

	var video:VideoHandler;
	var videoMusic:FlxSound;
	var videoSprite:FlxSprite;
	public static var videoPathArray:Array<String> = [];
	var videoArrayProgress:Int = 0;

	var inSongClimax:Bool = false;
	var triggeredAlready:Bool = false;
	var enemyCanFail:Bool = true;//temp, change to false later

	var compensationTimer:FlxTimer;
	var compensationTime:Float;

	var songLowercase = StringTools.replace(SONG.song, " ", "-").toLowerCase();

	var fakeCrochet:Float = 0;
	//private var dummyBeats:Int = 0;//A thing to allow for beat skip compensation
	
	public static var grabbedScreen:BitmapData;
	var fakeScreen:FlxSprite;

	//Mechanic Jam Time!
	/**What is "Mechanic Jam"?
	* Basically me seeing how many planned TMG Mechanics I can add within a limited amount of time!
	* (In today's [10/2/23] case, 2 or so hours before dad picks me up from school!)
	* Things will probably break! The game will probably crash!! But the thing is that it's a high risk high reward situation-
	* ...except the risk is gone because I BACKED UP THE SOURCE CODE BEFORE THIS!!! EPIC!!
	* So ready your keyboards and prime your singular braincells because the JAM. STARTS. NOW!!!
	**/
	var intimidationPTS:Int = 0; //Max is 10
	var intimidationBeats:Int = 0; //Beats remaining of selfsert being intimidated
	var missesInSection:Int = 0; //To reset the intimidationcombo without adding intimidation
	var notesHitInSection:Int = 0; //To see if theres actually notes to play
	var sectionsFCd:Int = 1; //sections that have been Full Combo'd
	var sectionsUntilReset:Int = 4; //Threshold for how many sections you want until it counts up one intimidation point or resets
	var sectionsTotal:Int = 1; //total sections - FC'd or not
	var intimidationPTSBar:FlxBar;
	var intimidationBeatsBar:FlxBar;

	override public function create():Void
	{
		instance = this;
		
		//FlxG.game.soundTray.silent = true;

		if (playlistLength < storyPlaylist.length)
			playlistLength = storyPlaylist.length;

		for (i in storyPlaylist)
			songsCheatedOn.push(false);
		
		#if debug
		trace(Paths.dumpExclusions);
		#end
		
		//Paths.clearUnusedMemory();
		//Paths.clearStoredMemory();

		//Update Saves
		SaveData.initSave();

		//SetVolumes
		musicVolume = FlxG.save.data.musicVol * 0.01;
		vocalsVolume = FlxG.save.data.vocalsVol * 0.01;
		soundsVolume = FlxG.save.data.gamesfxVol * 0.01;
		noteHitVolume = FlxG.save.data.notesfxVol * 0.01;

		if (FlxG.save.data.fpsCap > 290)
		{
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);
			FlxG.save.data.fpsCap = 290;
		}

		//Startup Shit
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
				detailsText = "Story (Part " + storyWeek + "): ";
			else
				detailsText = "Freeplay: ";
		}
		#end

		bgColor = 0xFF000000;

		pauseBlurLol = new BlurFilter(0, 0, 2);

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camEXT = new FlxCamera();

		camHUD.bgColor.alpha = 0;
		camEXT.bgColor.alpha = 0;

		blackScreenFadeTo = !Main.nightMode && !FlxG.save.data.nightmode ? 0 : 0.1;

		//Reset this shit
		defaultMashingThreshold = -storyDifficulty * 5 + (10 + Math.round(DiffCalc.CalculateDiff(SONG)));
		mashPressThreshold = defaultMashingThreshold;
		totalCleared[0] = 0;
		totalCleared[1] = DiffCalc.totalPlayableNotes;

		if (isStoryMode)
		{
			if (storyProgress == 0)
			{
				accuracy = 0.0;
				clearPercentage = 0;
				if(campaignDeaths == 0 && songDeaths == 0 && !hasReset && storyWeek != 0) //we dont have a hasVideo field, so we gotta manually add weeks here LMAOOO
				{
					//trace('me mama');
					blackScreenAlpha = 1;
				}
			}
			else
			{
				if (campaignDeaths == 0 && songDeaths == 0 && !hasReset && storyWeek != 0)
				{
					if (clearNumTwn != null)
						clearNumTwn.cancel();
					clearNumTwn = FlxTween.num(clearPercentage, 0, Conductor.crochet * 4 / 1000, {type: ONESHOT, ease: FlxEase.quadOut}, function(f:Float){clearPercentage = f;});
				}
				else
					clearPercentage = 0;
				blackScreenAlpha = blackScreenFadeTo;
				if (!playedCutscene && songDeaths == 0 && !hasReset)
					health = prevHealth;
				//trace('startupHealth = ' + health);
			}
		}
		else
		{
			clearPercentage = 0;
			blackScreenAlpha = blackScreenFadeTo;
			accuracy = 0.0;
		}

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camEXT);

		FlxCamera.defaultCameras = [camGame];

		camGame.filters = camGameFilters;
		camGameFilters.push(pauseBlurLol);
		camGame.filtersEnabled = false;

		//Preloading of music stuff becuz uhhh yes
		//Paths.inst(key);
		//if (PlayState.SONG.needsVoices)
			//Paths.voices(key);
		
		//NoteHitSFX
		noteHitSFX = new FlxSound();
		noteHitSustainSFX = new FlxSound();
		specialNoteHitSFX = new FlxSound();
		FlxG.sound.list.add(noteHitSFX);
		FlxG.sound.list.add(noteHitSustainSFX);
		FlxG.sound.list.add(specialNoteHitSFX);

		lowHPHeartBeat = new FlxSound();
		styleSound = new FlxSound().loadEmbedded(Paths.sound('styleOnEm'));
		FlxG.sound.list.add(lowHPHeartBeat);
		FlxG.sound.list.add(styleSound);
		//ermmm does this work..? theehee~
		//FlxG.sound.music = new FlxSound().loadEmbedded(Paths.inst(SONG.song));

		//SoundGroupShit
		//Move this to an initializing state and when you update options bcuz yea :33
		//done!
		//FlxG.sound.defaultMusicGroup.volume = musicVolume;
		//FlxG.sound.defaultSoundGroup.volume = soundsVolume;
		musicGroup = new FlxSoundGroup(musicVolume);
		//specilNoteHitSFXGroup = new FlxSoundGroup(soundsVolume);
		if(FlxG.save.data.missSounds)
			missSoundGroup = new FlxSoundGroup(soundsVolume);
		if (FlxG.save.data.notesfx)
		//{
			noteHitSFXGroup = new FlxSoundGroup(noteHitVolume);
			//susNoteHitSFXGroup = new FlxSoundGroup(noteHitVolume * soundsVolume);
		//}

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial', 'tutorial');

		Conductor.changeBPM(SONG.bpm);
		fakeCrochet = (60 / SONG.bpm) * 1000;
		idleCamShakeTimer = Conductor.crochet / 1000 - 0.01;
		compensationTime = Conductor.crochet * 2 / 1000;

		defaultScroll = SONG.speed * FlxG.save.data.scrollSpeed;
		defaultScroll += (storyDifficulty - 2) * 0.1;
		curScroll = defaultScroll;
		prevScroll = defaultScroll;
		newScroll = defaultScroll;

		if (SONG.eventObjects == null || SONG.eventObjects.length == 0)
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

			convertedStuff.push(new Song.Event(name,pos,value,type));
		}
		SONG.eventObjects = convertedStuff;

		Conductor.mapBPMChanges(SONG);

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

		var camPos:FlxPoint = new FlxPoint();
		if (!PlayStateChangeables.Optimize)
		{
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

			camPos.x = dad.getGraphicMidpoint().x;
			camPos.y = dad.getGraphicMidpoint().y;

			//Dad REPOSITIONING PER CHAR OF OFFSETS AND CAMFOLLOW OFFSETS
			switch (SONG.player2)
			{
				case 'joki-lmao':
					dadFollowOffset[0] += 120;
					dadFollowOffset[1] += 200;
					dad.y += 80;

				case 'demon-dad':
					dadFollowOffset[1] = -40;
					camPos.x += 400;
				case 'table-default':
					dadFollowOffset[0] = -30;
					dad.setPosition(gf.x, gf.y);
					gf.visible = false;
					if (SONG.song == "Mic Test")
					{
						camPos.x -= 650;
						camPos.y -= 200;
					}
				case "priest-theborderpray" |  "priest-theborderannoyed" | "priest-theborderangry":
					dadFollowOffset[0] = -75;
					dadFollowOffset[1] = 15;	
					dad.y += 215;
				case 'pico-default':
					dadFollowOffset[0] = -120;
					dadFollowOffset[1] = 30;
					camPos.x += 600;
					dad.y += 300;
				case 'pico-stressed':
					dadFollowOffset[0] = -120;
					camPos.x += 600;
					dad.y += 300;
				case 'selfsert-default':
					camPos.x += 200;
					camPos.y += 20;
					dadFollowOffset[1] = 15;
					dad.y += 260;
					dad.x -= 15;
				case 'guy-default':
					dad.y += 350;
					dad.x -= 10;
			}

			boyfriend = new Boyfriend(770, 450, SONG.player1);

			// BF REPOSITIONING PER CHAR OF OFFSETS AND CAMFOLLOW OFFSETS
			switch (SONG.player1)
			{
				case 'guy-theborder':
					bfFollowOffset[0] = 30;
					switch (storyProgress)
					{
						case 1:
							bfFollowOffset[1] = 0;
						case 2:
							bfFollowOffset[1] = -10;
						default:
							bfFollowOffset[1] = 10;
					}
				case 'selfsert-default':
					boyfriend.y = 360;
					bfFollowOffset[1] = 15;
					//selfsert player y
				default:
					bfFollowOffset[0] = 30;
					bfFollowOffset[1] = 10;
					if (songLowercase == 'sudden-confrontation')
						boyfriend.x += 15;
				//bfFollowOffset
			}

			//Stages LOL
			switch (stageCheck)
			{
				//Fun fact about TMG's development: I was searching for 'theBorder' once and I accidentally typed 'theBorger' instead. That's kind of funny I think
				case 'theBorder':
					curStage = 'border';

					//REMINDERS ABOUT HAXEFLIXEL X AND Y POSITIONS :33
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
					theBorderBG.antialiasing = FlxG.save.data.antialiasing;
					add(theBorderBG);

					switch (songLowercase)
					{
						case 'disagreement':
							defaultCamZoom = 0.865;
							stageOverlay1 = new FlxSprite();
							stageOverlay1.setGraphicSize(Math.round(stageOverlay1.width * 0.7));
							stageOverlay1.alpha = 0.6;
							theBorderBG.alpha = 0.75;
							stageAmbColour = 0xFF13070D;
							stageAmbAlpha = 0.1;

						case 'retaliation':
							defaultCamZoom = 0.815;
							stageOverlay1 = new FlxSprite();
							stageOverlay1.setGraphicSize(Math.round(stageOverlay1.width * 0.65));
							stageOverlay1.alpha = 1;
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
							stageOverlay1 = new FlxSprite();
							stageOverlay1.setGraphicSize(Std.int(stageOverlay1.width * 0.75));
							stageOverlay1.alpha = 0.35;
							theBorderBG.alpha = 1;
							stageAmbColour = 0xFF140A13;
							stageAmbAlpha = 0.025;
					}
					stageOverlay1.scrollFactor.set();
					stageAmbBlend = MULTIPLY;

					var theborderFloor:FlxSprite = new FlxSprite(-650, 590).loadGraphic(Paths.image('theborder_floor', 'week2'));
					//theborderFloor.setGraphicSize(Std.int(theborderFloor.width * 1.0));
					theborderFloor.updateHitbox();
					theborderFloor.antialiasing = FlxG.save.data.antialiasing;
					theborderFloor.scrollFactor.set(0.9, 0.9);
					theborderFloor.active = false;
					add(theborderFloor);

					stageOverlay1.frames = Paths.getSparrowAtlas('vignette_black', 'week2');
					stageOverlay1.antialiasing = FlxG.save.data.antialiasing;
					stageOverlay1.scrollFactor.set(0.1, 0.1);
					stageOverlay1.animation.addByPrefix('vignette', 'vignette', 1, true);
					stageOverlay1.animation.play('vignette');
					stageOverlay1.updateHitbox();
					stageOverlay1.screenCenter();
					stageOverlay1.active = false;


				case 'theCity':
					curStage = 'cityskyline';
					defaultCamZoom = 0.85;

					//X [LEFT or RIGHT]: Negative is LEFT, while postitive is RIGHT. (Same as the Cartesian Plane's)
					//Y [UP or DOWN]: Negative is UP, while positive is DOWN. (Inverted as the Cartesian Plane's)

					//                                 X    Y
					var bg:FlxSprite = new FlxSprite(-140, -80).loadGraphic(Paths.image('theCity/sky', 'week3'));
					bg.scrollFactor.set(0.1, 0.1);
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.active = false;
					add(bg);

					city = new FlxSprite(-120, -85).loadGraphic(Paths.image('theCity/city', 'week3'));
					city.scrollFactor.set(0.2, 0.2);
					//city.setGraphicSize(Std.int(city.width * 0.85));
					city.antialiasing = FlxG.save.data.antialiasing;
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
						light.antialiasing = FlxG.save.data.antialiasing;
						cityLights.add(light);
					}

					var streetBehind:FlxSprite = new FlxSprite(-160, 0).loadGraphic(Paths.image('theCity/behindStreet', 'week3'));
					streetBehind.scrollFactor.set(0.65, 0.65);
					streetBehind.setGraphicSize(Std.int(streetBehind.width * 1.1));
					//streetBehind.updateHitbox();
					streetBehind.antialiasing = FlxG.save.data.antialiasing;
					streetBehind.active = false;
					add(streetBehind);

					cityStreets = new FlxSprite(-150, 70);
					cityStreets.frames = Paths.getSparrowAtlas('theCity/street', 'week3');
					cityStreets.scrollFactor.set(0.9, 0.9);
					cityStreets.setGraphicSize(Std.int(cityStreets.width * 1.15));
					cityStreets.animation.addByPrefix('street', 'street', 1, true);
					cityStreets.animation.play('street');
					cityStreets.antialiasing = FlxG.save.data.antialiasing;

					stageOverlay2 = new FlxSprite();
					stageOverlay2.frames = Paths.getSparrowAtlas('deathWarnVignette', 'week3');
					stageOverlay2.scrollFactor.set();
					stageOverlay2.setGraphicSize(Std.int(stageOverlay2.width * 0.75));
					stageOverlay2.animation.addByPrefix('none', 'dmgVigNone_');
					stageOverlay2.animation.addByPrefix('warn0', 'dmgVigStage0_', 24, true);
					stageOverlay2.animation.addByPrefix('warn1', 'dmgVigStage1_', 24, true);
					stageOverlay2.animation.addByPrefix('warn2', 'dmgVigStage2_', 24, true);
					stageOverlay2.blend = ADD;
					stageOverlay2.alpha = 0;
					stageOverlay2.animation.play('warn0');
					stageOverlay2.updateHitbox();
					stageOverlay2.screenCenter();
					stageOverlay2.alpha = 1;
					stageOverlay2.animation.play('none');
					stageOverlay2.antialiasing = FlxG.save.data.antialiasing;

					stageOverlay1 = new FlxSprite();
					stageOverlay1.frames = Paths.getSparrowAtlas('theCity/vignette', 'week3');
					stageOverlay1.scrollFactor.set();
					stageOverlay1.setGraphicSize(Std.int(stageOverlay1.width * 0.75));
					stageOverlay1.animation.addByPrefix('static', 'vignette justBlack');
					if (FlxG.save.data.flashing)
						stageOverlay1.animation.addByPrefix('warning', 'vignette warnPlayer flashRed', 24, true);
					else
						stageOverlay1.animation.addByPrefix('warning', 'vignette warnPlayer flashRed', 15, false);
					stageOverlay1.animation.addByPrefix('singleFlash', 'vignette warnPlayer flashRed', 12, false);
					//stageOverlay1.blend = MULTIPLY;
					stageOverlay1.animation.play('static');
					stageOverlay1.updateHitbox();
					stageOverlay1.screenCenter();
					stageOverlay1.antialiasing = FlxG.save.data.antialiasing;
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
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.active = false;
					add(bg);

					city = new FlxSprite(-120, -85);
					city.scrollFactor.set(0.2, 0.2);
					city.frames = Paths.getSparrowAtlas('theCityPortalOpen/city_portal', 'week3');
					city.animation.addByPrefix('cityPortal', 'portal_CityIdle', 14, true);
					city.animation.play('cityPortal');
					//city.setGraphicSize(Std.int(city.width * 0.85));
					city.antialiasing = FlxG.save.data.antialiasing;
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
					streetBehind.antialiasing = FlxG.save.data.antialiasing;
					add(streetBehind);

					cityStreets = new FlxSprite(-150, 70);
					cityStreets.frames = Paths.getSparrowAtlas('theCityPortalOpen/street_portal', 'week3');
					cityStreets.scrollFactor.set(0.9, 0.9);
					cityStreets.setGraphicSize(Std.int(cityStreets.width * 1.15));
					cityStreets.animation.addByPrefix('street', 'streetIdle', 20, true);
					cityStreets.animation.play('street');
					cityStreets.antialiasing = FlxG.save.data.antialiasing;

					stageOverlay2 = new FlxSprite();
					stageOverlay2.frames = Paths.getSparrowAtlas('deathWarnVignette', 'week3');
					stageOverlay2.scrollFactor.set();
					stageOverlay2.setGraphicSize(Std.int(stageOverlay2.width * 0.75));
					stageOverlay2.animation.addByPrefix('none', 'dmgVigNone_');
					stageOverlay2.animation.addByPrefix('warn0', 'dmgVigStage0_', 24, true);
					stageOverlay2.animation.addByPrefix('warn1', 'dmgVigStage1_', 24, true);
					stageOverlay2.animation.addByPrefix('warn2', 'dmgVigStage2_', 24, true);
					stageOverlay2.blend = ADD;
					stageOverlay2.alpha = 0;
					stageOverlay2.animation.play('warn0');
					stageOverlay2.updateHitbox();
					stageOverlay2.screenCenter();
					stageOverlay2.alpha = 1;
					stageOverlay2.animation.play('none');
					stageOverlay2.antialiasing = FlxG.save.data.antialiasing;

					//ANIMATE THE VIGNETTE
					stageOverlay1 = new FlxSprite();
					stageOverlay1.frames = Paths.getSparrowAtlas('theCity/vignette', 'week3');
					stageOverlay1.scrollFactor.set();
					stageOverlay1.setGraphicSize(Std.int(stageOverlay1.width * 0.675));
					stageOverlay1.animation.addByPrefix('static', 'vignette justBlack');
					if (FlxG.save.data.flashing)
						stageOverlay1.animation.addByPrefix('warning', 'vignette warnPlayer flashRed', 24, true);
					else
						stageOverlay1.animation.addByPrefix('warning', 'vignette warnPlayer flashRed', 15, false);
					stageOverlay1.animation.addByPrefix('singleFlash', 'vignette warnPlayer flashRed', 12, false);
					stageOverlay1.animation.play('static');
					stageOverlay1.updateHitbox();
					stageOverlay1.screenCenter();
					stageOverlay1.antialiasing = FlxG.save.data.antialiasing;
					stageAmbColour = 0xFF1A002C;
					stageAmbAlpha = 0.65;


				case 'theHouse':
					bfFollowOffset[1] += 15;
					dadFollowOffset[1] += 15;
					boyfriend.x += 25;
					boyfriend.y -= 20;
					dad.x += 20;
					dad.y -= 20;
					defaultCamZoom = 0.98;
					curStage = 'house';

					var baseBG:FlxSprite = new FlxSprite(-400, -200).loadGraphic(Paths.image('house/HouseBG', 'week4'));
					baseBG.setGraphicSize(Std.int(baseBG.width * 0.75));
					baseBG.updateHitbox();
					baseBG.antialiasing = FlxG.save.data.antialiasing;
					baseBG.scrollFactor.set(0.3, 0.3);
					baseBG.active = false;
					add(baseBG);

					var parralax1:FlxSprite = new FlxSprite(-400, -200).loadGraphic(Paths.image('house/ParralaxObjects1', 'week4'));
					parralax1.setGraphicSize(Std.int(parralax1.width * 0.77));
					parralax1.updateHitbox();
					parralax1.antialiasing = FlxG.save.data.antialiasing;
					parralax1.scrollFactor.set(0.3, 0.3);
					parralax1.active = false;
					add(parralax1);

					var baseFloor:FlxSprite = new FlxSprite(-740, -290).loadGraphic(Paths.image('house/ParralaxFloor', 'week4'));
					baseFloor.setGraphicSize(Std.int(baseFloor.width * 0.95));
					baseFloor.antialiasing = FlxG.save.data.antialiasing;
					baseFloor.scrollFactor.set(0.95, 0.95);
					baseFloor.active = false;
					add(baseFloor);

					var parralax2Shadow:FlxSprite = new FlxSprite(-980, -200).loadGraphic(Paths.image('house/ParralaxObjects2Shadow', 'week4'));
					parralax2Shadow.setGraphicSize(Std.int(parralax2Shadow.width * 0.60));
					parralax2Shadow.antialiasing = FlxG.save.data.antialiasing;
					parralax2Shadow.scrollFactor.set(0.9, 0.9);
					parralax2Shadow.blend = SUBTRACT;
					parralax2Shadow.alpha = 0.3;
					parralax2Shadow.active = false;
					add(parralax2Shadow);

					var parralax2:FlxSprite = new FlxSprite(-950, -200).loadGraphic(Paths.image('house/ParralaxObjects2', 'week4'));
					parralax2.setGraphicSize(Std.int(parralax2.width * 0.60));
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

					stageOverlay1 = new FlxSprite(-490, -300).loadGraphic(Paths.image('graduation/graduation_overlay', 'week1'));
					stageOverlay1.setGraphicSize(Std.int(stageOverlay1.width * 0.9));
					stageOverlay1.updateHitbox();
					stageOverlay1.antialiasing = FlxG.save.data.antialiasing;
					stageOverlay1.scrollFactor.set(1.3, 1.3);
					stageOverlay1.active = false;
					stageAmbColour = 0xFF09130E;
			}

			//Layering for stages LOL
			switch (curStage)
			{
				case 'cityskyline' | 'cityskylineVariegated':
					add(gf);
					add(cityStreets);

					gotShotBlurLol = new BlurFilter(0, 0, 2);
					camGameFilters.push(gotShotBlurLol);
				case 'house':
					//do nada
				default:
					add(gf);
			}

			dummyBlackScreen = new FlxSprite(-FlxG.width * defaultCamZoom,
				-FlxG.height * defaultCamZoom).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.WHITE);
			dummyBlackScreen.scrollFactor.set();
			dummyBlackScreen.alpha = 0;
			dummyBlackScreen.blend = SUBTRACT;
			dummyBlackScreen.screenCenter();
			add(dummyBlackScreen);

			add(dad);
			add(boyfriend);

			colourWash = new FlxSprite(-FlxG.width * defaultCamZoom,
				-FlxG.height * defaultCamZoom).makeGraphic(FlxG.width * 4, FlxG.height * 4, stageAmbColour);
			colourWash.scrollFactor.set();
			if (stageAmbColour == FlxColor.TRANSPARENT)
				colourWash.visible = false;
			colourWash.alpha = stageAmbAlpha;
			colourWash.blend = stageAmbBlend;
			colourWash.screenCenter();
			add(colourWash);

			stageOverlayGroup = new FlxSpriteGroup();
			add(stageOverlayGroup);

			//Stage dependent shit
			switch (curStage)
			{
				case 'stage':
					stageOverlayGroup.add(stageOverlay1);
				case 'border':
					stageOverlayGroup.add(stageOverlay1);
					stageOverlayGroup.cameras = [camHUD];
				case 'cityskyline':
					stageOverlayGroup.add(stageOverlay2);
					stageOverlayGroup.add(stageOverlay1);
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
					windEffect.alpha = 0.05;
					windEffect.antialiasing = FlxG.save.data.antialiasing;
					stageOverlayGroup.add(windEffect);
					FlxTween.tween(windEffect, {alpha: 1}, Conductor.crochet * 256 / 1000, {type: ONESHOT, ease: FlxEase.expoOut, startDelay: Conductor.crochet * 4 / 1000});
					stageOverlayGroup.add(stageOverlay2);
					stageOverlayGroup.add(stageOverlay1);
					stageOverlayGroup.cameras = [camHUD];
					if (FlxG.save.data.distractions)
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

			//Opponent Character dependent shit
			switch (SONG.player2)
			{
				case "priest-theborderangry":
					objectTrailShader = new FlxTrail(dad, null, 3, 8, 0.4, 0.08);
					objectTrailShader.alpha = 0.65;
					add(objectTrailShader);

					updateWiggleShader = true;
					objectWiggleShader = new WiggleEffect();
					objectWiggleShader.effectType = WiggleEffectType.DREAMY;
					objectWiggleShader.waveAmplitude = 0.0008;
					objectWiggleShader.waveFrequency = 300;
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
					stageBG.alpha = 0.2;

					if (stageCheck == "theCityPortal")
					{
						objectWiggleShader = new WiggleEffect();
						objectWiggleShader.effectType = WiggleEffectType.WAVY;
						updateWiggleShader = true;
						objectWiggleShader.waveAmplitude = 0.0008;
						objectWiggleShader.waveFrequency = 20;
						objectWiggleShader.waveSpeed = 16;
						stageBG.shader = objectWiggleShader.shader;
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

		blackScreen = new FlxSprite(-FlxG.width * 2,
			-FlxG.height * 2).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.WHITE);
		blackScreen.screenCenter();
		blackScreen.scrollFactor.set();
		blackScreen.alpha = blackScreenAlpha;
		blackScreen.blend = SUBTRACT;
		blackScreen.cameras = [camEXT];
		add(blackScreen);

		coolSoundFilter = new FlxSoundFilter();
		coolSoundFilter.filterType = FlxSoundFilterType.BANDPASS;
		coolSoundFilter.gainHF = 1;
		coolSoundFilter.gainLF = 1;

		//UI Vignettes
		//The detail thing that appears when you get shot
		hurtVignette = new FlxSprite().loadGraphic(Paths.image('gotShot', 'week3'));
		hurtVignette.scale.x *= 0.75;
		hurtVignette.scale.y *= 0.75;
		hurtVignette.scrollFactor.set();
		hurtVignette.updateHitbox();
		hurtVignette.antialiasing = FlxG.save.data.antialiasing;
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
		lowHPOverlay.antialiasing = FlxG.save.data.antialiasing;
		lowHPOverlay.screenCenter();
		lowHPOverlay.alpha = 0;
		add(lowHPOverlay);

		//The detail thing that appears when you cant die
		safeVignette = new FlxSprite().loadGraphic(Paths.image('cannotDie', 'tutorial'));
		safeVignette.y = 30;
		safeVignette.scale.x *= 0.7;
		safeVignette.scale.y *= 0.7;
		safeVignette.scrollFactor.set();
		safeVignette.antialiasing = FlxG.save.data.antialiasing;
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
					if ((storyWeek < FlxG.save.data.weekUnlocked || (songDeaths > 0 || hasReset)) || !isStoryMode)
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

		Conductor.songPosition = -Conductor.crochet * 5;

		//Centering Offset Shit (1) V Doink
		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		//strumLine.scrollFactor.set();

		if (PlayStateChangeables.useDownscroll)
			strumLine.y = FlxG.height - 165;

		grpStrumLine = new FlxSpriteGroup();
		grpStrumLine.alpha = 0.4;
		add(grpStrumLine);

		//ratings layering
		add(grpRatingsBG);
		add(grpRatingsMG);
		add(grpRatingsFG);

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		cpuStrums = new FlxTypedGroup<FlxSprite>();

		#if debug
		if (SONG.song == null)
			trace('song is null???');
		else
			trace('song looks gucci');
		#end

		healthAndScoreGroup = new FlxSpriteGroup();
		if (storyProgress <= 0 && !hasReset && campaignDeaths == 0)
			healthAndScoreGroup.alpha = 0;
		healthAndScoreGroup.cameras = [camHUD];
		add(healthAndScoreGroup);

		//this was where the cameradata was

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		//FlxG.fixedTimestep = false;

		//Adding Offsets Again      V //Ploink
		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		if (PlayStateChangeables.useDownscroll)
			healthBarBG.y = 50;
		healthBarBG.screenCenter(X);
		healthBarBG.antialiasing = FlxG.save.data.antialiasing;
		healthBarBG.color = FlxColor.BLACK;
		healthAndScoreGroup.add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		healthBar.antialiasing = FlxG.save.data.antialiasing;
		healthAndScoreGroup.add(healthBar);

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - 75;
		healthAndScoreGroup.add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - 75;
		healthAndScoreGroup.add(iconP2);

		scoreTxt = new FlxText(healthBarBG.x - 35 + healthBar.width / 4, healthBarBG.y + 40, 0, setScoreText(Math.round(dummySongScore)), 20);
		scoreTxt.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER);
		scoreTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1.5);
		scoreTxt.screenCenter(X);
		healthAndScoreGroup.add(scoreTxt);

		// Literally copy-paste of the above, fu-- (frick)
		botPlayText = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 60 : -70), 0,
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

		subtitleText = new FlxText(healthBarBG.x - 10, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 80 : -80), FlxG.save.data.centersubtitles ? 0 : healthBarBG.width + 20);
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
		/*songNameTXT = new FlxText(4, 0, 0,
			SONG.song
			+ " - "
			+ CoolUtil.difficultyFromInt(storyDifficulty), 16);
		songNameTXT.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);
		songNameTXT.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1.3);
		songNameTXT.y = (!PlayStateChangeables.useDownscroll ? FlxG.height - songNameTXT.height - 4 : songNameTXT.height - 10);
		add(songNameTXT);*/

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
				//tutorialGraphicA.scrollFactor.set();
				tutorialGraphicA.updateHitbox();
				tutorialGraphicA.antialiasing = FlxG.save.data.antialiasing;
				tutorialGraphicA.screenCenter();
				tutorialGraphicA.alpha = 0;

				//	For the second tutorial popup
				tutorialGraphicB = new FlxSprite().loadGraphic(Paths.image('infocards/TutorialTipB', 'tutorial'));
				//tutorialGraphicB.scrollFactor.set();
				tutorialGraphicB.updateHitbox();
				tutorialGraphicB.antialiasing = FlxG.save.data.antialiasing;
				tutorialGraphicB.screenCenter();
				tutorialGraphicB.alpha = 0;
				
				//	For the third tutorial popup
				tutorialGraphicC = new FlxSprite().loadGraphic(Paths.image('infocards/TutorialTipC', 'tutorial'));
				//tutorialGraphicC.scrollFactor.set();
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
				bindTxtLeft.antialiasing = FlxG.save.data.antialiasing;
				bindTxtLeft.setFormat(Paths.font("playtime.ttf"), 50, CENTER);
				bindTxtLeft.color = FlxColor.YELLOW;
				bindTxtLeft.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 6, 6);

				bindTxtDown = new FlxText(0, 0, -0);
				bindTxtDown.text = '${FlxG.save.data.downBind}';
				bindTxtDown.antialiasing = FlxG.save.data.antialiasing;
				bindTxtDown.setFormat(Paths.font("playtime.ttf"), 50, CENTER);
				bindTxtDown.color = FlxColor.YELLOW;
				bindTxtDown.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 6, 6);

				bindTxtUp = new FlxText(0, 0, -0);
				bindTxtUp.text = '${FlxG.save.data.upBind}';
				bindTxtUp.antialiasing = FlxG.save.data.antialiasing;
				bindTxtUp.setFormat(Paths.font("playtime.ttf"), 50, CENTER);
				bindTxtUp.color = FlxColor.YELLOW;
				bindTxtUp.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 6, 6);

				bindTxtRight = new FlxText(0, 0, -0);
				bindTxtRight.text = '${FlxG.save.data.rightBind}';
				bindTxtRight.antialiasing = FlxG.save.data.antialiasing;
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
				//avoidBulletTipGraphic.scrollFactor.set();
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


			case 'finale' | 'sudden-confrontation' | 'sprouting-irritation' | 'striking-tribulation':
				var wipText = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 70 : -70), 0,
				"[WIP LEVEL - (NOT FINAL!)]",25);
				wipText.setFormat(Paths.font("vcr.ttf"), 25, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				wipText.scrollFactor.set();
				wipText.borderSize = 4;
				wipText.borderQuality = 2;
				wipText.antialiasing = false;
				wipText.screenCenter(X);
				wipText.cameras = [camHUD];
				wipText.updateHitbox();
				if (PlayStateChangeables.botPlay)
					wipText.y = botPlayText.y + (PlayStateChangeables.useDownscroll ? botPlayText.height : -(botPlayText.height - 10));
				add(wipText);

				if (songLowercase != 'finale')
				{
					//TEMP Intimidation Bars
					intimidationPTSBar = new FlxBar(FlxG.width - 30, 0, BOTTOM_TO_TOP, 10, 200, this,
						'intimidationPTS', 0, 16);
					intimidationPTSBar.createFilledBar(0xFF303030, 0xFF33A3FF);
					intimidationPTSBar.antialiasing = FlxG.save.data.antialiasing;
					intimidationPTSBar.screenCenter(Y);
					add(intimidationPTSBar);

					intimidationBeatsBar = new FlxBar(FlxG.width - 40, 0, BOTTOM_TO_TOP, 10, 200, this,
						'intimidationBeats', 0, 64);
					intimidationBeatsBar.createFilledBar(0xFF1B1B1B, 0xFFFF33EE);
					intimidationBeatsBar.antialiasing = FlxG.save.data.antialiasing;
					intimidationBeatsBar.screenCenter(Y);

					intimidationBeatsBar.cameras = [camHUD];
					intimidationPTSBar.cameras = [camHUD];
					
					add(intimidationBeatsBar);
				}

				//SO that run does not count in story mode
				if (isStoryMode)
					toggledPracticeMode = true;
		}

		resetText = new FlxText(0, 0, 0, "[Double tap [R] to Reset]", 40);
		resetText.setFormat(Paths.font("vcr.ttf"), 45, 0xFFFF0000, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		resetText.scrollFactor.set();
		resetText.borderSize = 4;
		resetText.antialiasing = false;
		resetText.screenCenter();
		resetText.cameras = [camHUD];
		resetText.updateHitbox();
		resetText.alpha = 0;
		add(resetText);

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
		//if (songDeaths <= 0 && !hasReset)
			//loadingIcon.alpha = 1;
		//else
		loadingIcon.alpha = 0;
		add(loadingIcon);

		if (FlxG.save.data.lagCompensation)
		{
			lagCompIcon = new FlxSprite().loadGraphic(Paths.image('compensaTurtle'));
			lagCompIcon.x = FlxG.width - lagCompIcon.width * 1.1;
			lagCompIcon.y = (PlayStateChangeables.useDownscroll ? 20 : FlxG.height - lagCompIcon.height * 1.1);
			lagCompIcon.scrollFactor.set();
			lagCompIcon.updateHitbox();
			lagCompIcon.blend = LIGHTEN;
			lagCompIcon.alpha = 0;
			lagCompIcon.antialiasing = FlxG.save.data.antialiasing;
			lagCompIcon.cameras = [camEXT];
			add(lagCompIcon);
		}

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>(16);
		add(grpNoteSplashes);

		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0;

		hurtVignette.cameras = [camHUD];
		lowHPOverlay.cameras = [camHUD];
		safeVignette.cameras = [camHUD];
		grpStrumLine.cameras = [camHUD];
		grpRatingsMG.cameras = [camHUD];
		grpRatingsBG.cameras = [camHUD];
		grpRatingsFG.cameras = [camHUD];
		tutorialText.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		//replayTxt.cameras = [camHUD];
		botPlayText.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		grpNoteSplashes.cameras = [camHUD];
		//doof.cameras = [camHUD];
		//songNameTXT.cameras = [camHUD];

		songPosGroup = new FlxSpriteGroup(0, 1);
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
		camGame.followLerp = camFollowSpeed;

		//For CamHUD to fix itself after shake
		//var camHUDFollow:FlxObject = new FlxObject(0, 0, 1, 1);
		//camHUDFollow.screenCenter();
		//camHUD.focusOn(camHUDFollow.getPosition());
		//camHUD.follow(camHUDFollow, LOCKON);
		//camHUD.followLerp = 25;

		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);

		video = new VideoHandler();
		video.allowSkip = true;

		videoSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		videoSprite.antialiasing = true;
		videoSprite.visible = false;	
		videoSprite.cameras = [camEXT];
		add(videoSprite);

		transIn.camera = camEXT;
		transOut.camera = camEXT;
		//trace('set transInCam to camHUD');

		super.create();

		timesShot = -mechanicPityDeaths;

		generateSong();

		//Song Start Events
		//trace("Song Startup Shit");
		//trace("'Played Cutscene' is " + playedCutscene);
		switch (songLowercase)
		{
			case 'oo-ee-ii-aa-ee':
				hasSubtitles = true;
				startCountdown();
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
					videoSprite.visible = true;	
					video.playMP4(Paths.video(videoPathArray[videoArrayProgress]), false, videoSprite, false, false);
					video.finishCallback = function()
					{
						videoSprite.visible = false;
						startCountdown(true);
					}
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
					videoSprite.visible = true;	
					video.playMP4(Paths.video(videoPathArray[videoArrayProgress]), false, videoSprite, false, false);
					video.finishCallback = function()
					{
						videoSprite.visible = false;
						if (!PlayStateChangeables.Optimize)
							desperationIntro();
						else
							startCountdown(true);
					}
				}
				else
					startCountdown();
			case 'disagreement':
				hasSubtitles = true;
				if (isStoryMode && !playedCutscene)
				{
					health = 1;
					blackScreen.alpha = 1;
					inCutscene = true;
					playedCutscene = true;
					videoSprite.visible = true;	
					video.playMP4(Paths.video(videoPathArray[videoArrayProgress]), false, videoSprite, false, false);
					video.finishCallback = function()
					{
						videoSprite.visible = false;
						startCountdown(true);
					}
				}
				else
					startCountdown();
				camZooming = true;
			case 'retaliation':
				//trace("YOU BETTER BE CHANGED FROM " + camFollowSpeed);
				health = 1;
				camFollowSpeed = 0.25;
				hasSubtitles = true;
				//trace("TO " + camFollowSpeed);
				if (isStoryMode && !playedCutscene)
				{
					camFollow.x = dad.getGraphicMidpoint().x;
					camFollow.y = dad.getGraphicMidpoint().y - 50;
					blackScreen.alpha = 1;
					inCutscene = true;
					playedCutscene = true;
					videoMusic = FlxG.sound.play(Paths.videoMusic('week2/midcutscene2-MUSIC'), 0.7);
					videoMusic.autoDestroy = true;
					videoMusic.looped = false;
					videoSprite.visible = true;	
					video.playMP4(Paths.video(videoPathArray[videoArrayProgress]), false, videoSprite, false, false);
					video.finishCallback = function()
					{
						videoSprite.visible = false;
						videoArrayProgress++;
						if (!PlayStateChangeables.Optimize)
							lightningStrikeShit();

						camEXT.flash(FlxColor.WHITE, Conductor.crochet * 2 / 1000);
						blackScreen.alpha = 0;
						camGame.zoom += 0.45;
						FlxTween.tween(camGame, {zoom: camGame.zoom - 0.45}, Conductor.crochet * 8 / 1000, {type: ONESHOT, ease: FlxEase.expoOut});
						camShake(true, true, 'camGame', 2, 0.015, Conductor.crochet * 2 / 1000);
						videoMusic.fadeOut(0.8);
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
				camFollowSpeed = 0.875;
				add(avoidBulletTipGraphic);
				startCountdown();
			case 'variegated-skylines':
				doPityDeaths = true;
				if (!PlayStateChangeables.Optimize && curStage == 'cityskylineVariegated')
					stageParticles.visible = true;
				hasSubtitles = true;
				startCountdown();
			case 'sudden-confrontation' | 'sprouting-irritation' | 'striking-tribulation':
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

		if (FlxG.save.data.subtitles)
		{
			add(subtitleBackground);
			add(subtitleText);

			startVideoSubtitles(videoPathArray[videoArrayProgress]);
		}
	}

	function startVideoSubtitles(key:String = ''):Void
	{
		switch (key)
		{
			case 'week2/startcutscene':
				setTimedSubtitle('[Screaming]', 0xFF5ce766, 5.8);
				setTimedSubtitle('Oof-', 0xFF5ce766, 7.1, 8.15);
				setTimedSubtitle('W-where are we..?', 0xFF5ce766, 9.1);
				setTimedSubtitle('What is this place?!', 0xFF5ce766, 10.64);
				setTimedSubtitle('Well, wherever we are, it sure doesnt look safe...', 0xFF5ce766, 12.85, 15.90);
				setTimedSubtitle('..I guess all we can do now is pray to God-', 0xFF5ce766, 18.1);
				setTimedSubtitle('Lets hope he hears us', 0xFF5ce766, 20.9, 24.9);

			case 'week2/midcutscene1':
		}
	}

	function desperationIntro():Void
	{
		clearSubtitles();
		
		if (fakeScreen != null)
		{
			fakeScreen.kill();
			fakeScreen.destroy();
		}

		//loadingIcon.alpha = 0;
		generateStaticArrows(false, true);
		generateStaticArrows(true, true);
		
		if (blackScreen.alpha > 0 || camHUD.alpha <= 0)
		{
			FlxTween.tween(camHUD, {alpha: 1}, 1, {type: ONESHOT, ease: FlxEase.quadOut, startDelay: 0.3});
			FlxTween.tween(blackScreen, {alpha: (!Main.nightMode && !FlxG.save.data.nightmode ? 0 : 0.25)}, 1, {type: ONESHOT, ease: FlxEase.quadOut, startDelay: 0.3});
		}
		inCutscene = true;
		canPause = false;
		gf.playAnim('none', true);
		camFollow.x = gf.getGraphicMidpoint().x;
		camFollow.y = gf.getGraphicMidpoint().y - 30;
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
				ready.antialiasing = FlxG.save.data.antialiasing;
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
						camShake(true, true, 'camGame', 2, 0.15, 0.55);
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

	function changeSubtitles(?isVideoSubtitles:Bool = false, text:String, color:FlxColor = 0xFFFFFFFF, borderColour:FlxColor = 0xFF000000, blendMode:String = "NORMAL", alpha:Float = 1, bgAlpha:Float = 0.45, font:String = 'Playtime With Hot Toddies', isBold:Bool = false, isItalic:Bool = false):Void
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

			if (isVideoSubtitles)
				subtitleText.y = FlxG.height - subtitleText.height - 50;

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
			if (StringTools.contains(text, prevText) && prevText != '')
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
				subBGWidthTween = FlxTween.tween(subtitleBackground.scale, {x: subBGTargetWidth}, 0.03, {type: ONESHOT, ease: FlxEase.quartOut, onComplete:
					function (twn:FlxTween)
					{
						subBGWidthTween = null;
						subtitleBackground.updateHitbox();
					}
				});
				subtitleBackground.updateHitbox();
	
				if (subBGXTween != null)
					subBGXTween.cancel();
				subBGXTween = FlxTween.tween(subtitleBackground, {x: subTxtTargetX - 10}, 0.25, {type: ONESHOT, ease: FlxEase.quartOut, onComplete:
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
				botPlayText.alpha = 0.75;
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

	var vidSubTmrArray:Array<FlxTimer> = [];
	function setTimedSubtitle(text:String, textColour:FlxColor, ?textBorderColor:FlxColor = FlxColor.BLACK, occurTime:Float, ?endTime:Float = 0)
	{
		//do a better way of stoppin these lol
		var videoSubtitleTimer = new FlxTimer().start(occurTime, function(tmr:FlxTimer)
		{
			if (video.isPlaying && !songStarted)
			{
				changeSubtitles(true, text, textColour, textBorderColor);
				
				if (endTime != 0)
				{
					new FlxTimer().start(endTime - occurTime, function(tmr:FlxTimer)
					{
						clearSubtitles();
					});
				}
			}
		});
		vidSubTmrArray.push (videoSubtitleTimer);
	}

	var startTimer:FlxTimer;
	function startCountdown(?justFinishedVideo:Bool = false, altSuffix:String = ""):Void
	{
		startedCountdown = true;

		var swagCounter:Int = 0;
		var startTimerTime:Float = Conductor.crochet / 1000;
		var startTimerLoops:Int = 5;

		if (!songStarted)
		{
			clearSubtitles();

			if (justFinishedVideo)
			{
				//loadingIcon.alpha = 0;
				if (fakeScreen != null)
				{
					fakeScreen.kill();
					fakeScreen.destroy();
				}
			}

			//DC.beginProfile("CountdownShit");
			#if debug
			trace("StartCountdown");
			#end

			allowDeaths = true;

			#if windows
			// Updating Discord Rich Presence
			DiscordClient.changePresence("Get Ready-!", null);
			#end

			botPlayText.visible = true;

			if (justFinishedVideo)
				forceCoolIntro = true;

			//trace ('intro will be: ' + forceCoolIntro);

			if (!generatedArrows)
			{
				if (!PlayStateChangeables.Optimize)
					generateStaticArrows(false, forceCoolIntro);
				generateStaticArrows(true, forceCoolIntro);
			}

			forceCoolIntro = false;

			/*if (loadingIcon.alpha != 0)
				FlxTween.tween(loadingIcon, {alpha: 0}, 0.3, {type: ONESHOT, ease: FlxEase.smootherStepIn, startDelay: 0.1});*/

			if (blackScreen.alpha != blackScreenFadeTo)
				FlxTween.tween(blackScreen, {alpha: blackScreenFadeTo}, 0.8, {type: ONESHOT, ease: FlxEase.quadOut, startDelay: 0.3});

			if (!PlayStateChangeables.Optimize)
			{
				if (!isStoryMode || (storyProgress > 0 && (SONG.song != 'Mic Test' || !hasReset && songDeaths <= 0)))
				{
					camFollowShit();
				}
				else
				{
					camFollow.x = gf.getGraphicMidpoint().x;
					camFollow.y = gf.getGraphicMidpoint().y;
				}
			}
			
			for (daNote in notes) 
			{
				if (daNote.scrollSpeed != defaultScroll)
					daNote.scrollSpeed = defaultScroll;
			}
	
			if (health != 1 && prevHealth != 1)
				prevHealthTwn = FlxTween.tween(this, {health: 1}, Conductor.crochet * 3.8 / 1000, {ease: FlxEase.expoOut});

			if (skipCountdown)
			{
				Conductor.songPosition = 0;
				startTimerTime = 0;
				startTimerLoops = 1;
				startSong();
			}
			else
				Conductor.songPosition = -Conductor.crochet * 5;
		}

		startTimer = new FlxTimer().start(startTimerTime, function(tmr:FlxTimer)
		{
			if (!skipCountdown)
			{
				//trace('Countdown = ' + swagCounter);
				
				if (!PlayStateChangeables.Optimize)
				{
					switch(songLowercase)
					{
						//case "tech.-difficulties":
							//if (swagCounter == 1 || swagCounter == 3)
								//dad.dance();
							//gf.dance();
							//if (boyfriend.animation.curAnim.name != 'phoneHide')
							//boyfriend.playAnim('idle'); //to add phone hide animation
						case "disagreement" | "retaliation" | "playing-with-fire":
							if (gfSpeed > 0 && swagCounter % gfSpeed == 0)
								gf.dance();

							if (swagCounter % idleBeat == 0 || dad.curCharacter == "priest-theborderpray" || dad.curCharacter == "table-default")
								dad.dance(idleToBeat);

							boyfriend.playAnim('scaredHOLD');
						case "variegated-skylines":
							camShake(false, false, 'camGame', 2, 0.0075, idleCamShakeTimer);
							camShake(false, false, 'camHUD', 2, 0.002, idleCamShakeTimer);
							if (swagCounter == 0 || swagCounter == 2)
								createStageParticle('theCityPortalOpen/effects/stageParticle');
							
							if (gfSpeed > 0 && swagCounter % gfSpeed == 0)
								gf.dance();

							if (swagCounter % idleBeat == 0 || dad.curCharacter == "priest-theborderpray" || dad.curCharacter == "table-default")
								dad.dance(idleToBeat);

							boyfriend.playAnim('scaredHOLD');
						default:
							if (gfSpeed > 0 && swagCounter % gfSpeed == 0)
								gf.dance();

							if (swagCounter % idleBeat == 0 || dad.curCharacter == "priest-theborderpray" || dad.curCharacter == "table-default")
								dad.dance(idleToBeat);

							if (swagCounter % idleBeat == 0)
								boyfriend.playAnim('idle', idleToBeat);
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
						ready.antialiasing = FlxG.save.data.antialiasing;		
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
						set.antialiasing = FlxG.save.data.antialiasing;	
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
						go.antialiasing = FlxG.save.data.antialiasing;
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
					case 5:
						startSong();
				}
			}
		}, startTimerLoops);
		//DC.endProfile("CountdownShit");
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
						if (!epicNote.delayedDeath && epicNote.enabled)
						{
							goodNoteHit(epicNote, true);
							pressNotes.push(epicNote);
							var noteDiff:Float = -(epicNote.strumTime - Conductor.songPosition);
						}
					}
				}
			}
			else if (songStarted && allowHealthModifiers)
			{
				if (!FlxG.save.data.ghost)
				{
					//Literal copy paste
					causeOfDeath = 'no-ghost-tapping';
					singFollowOffset = [0, 0];
					
					//NOTE MISS SOUND
					if(FlxG.save.data.missSounds)
					{
						//vocals.volume = 0;
						missSoundGroup.stop();
						FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.2, 0.25), false, missSoundGroup);
					}
		
					// Whole switch statement replaced with a single line :)
					if (!PlayStateChangeables.Optimize)
						if ((boyfriend.animation.curAnim.name != 'hurt' && !boyfriend.animation.curAnim.name.startsWith("dodge")) || boyfriend.animation.curAnim.curFrame >= 3)
							boyfriend.playAnim('sing' + dataSuffix[key] + 'miss', true);

					songScore -= 50;
					//uhh what happens if i-
					if (allowHealthModifiers)
					{
						if (targetHealth >= 0.25)
							targetHealth -= 0.05;
						else
							targetHealth -= 0.025;
					}
				}
				else if (allowHealthModifiers && nearestNoteUpcoming)
				{
					//Ghost Tapping Antimash
					mashPresses++;
					trace('mash detection increased (' + mashPresses + '|' + mashPressThreshold + ')');
				
					if (mashPresses > mashPressThreshold)
					{
						mashing = true;
						targetHealth += calculateHealth(9);
						songScore -= 10;
						//Starts filling your accuracy with duds, causing you to have issues with score and health
						updateAccuracy(1 - (0.025 * mashPresses));
						//#if debug
						trace("BRO STOP SPAMMING");
						//#end
					}
					else
					{
						if (causeOfDeath == 'note-spam')
						causeOfDeath = '';
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

	public var songStarted = false;
	//1 beat before music end
	var musicTimeCusp:Float = 0;
	var musicBeatCusp:Int = 0;
	var tempAddedSongPosShit:Bool = false;

	private function startSong():Void
	{
		//trace('starting song?');
		//tempDisableResyncVocals = false;
		if (prevHealthTwn != null)
		{
			prevHealthTwn.cancel();
			health = 1;
		}

		if (clearNumTwn != null)
		{
			clearNumTwn.cancel();
			clearPercentage = 0;
		}

		doStrumLineBGTweening = true;
		songStarted = true;

		inCutscene = false;
		doCamFollowing = true;

		//if (!FlxG.sound.music.playing) //don't restart the music if it's already playing
		//{
			//FlxG.sound.music.play(true);
			//FlxG.sound.music.volume = 1;
			if (SONG.song != "Finale")
			{
				FlxG.sound.music.looped = false;
				FlxG.sound.music.onComplete = endSong;
				FlxG.sound.playMusic();
				//trace('playedMusic');
			}
			else
			{
				drums = new FlxSound();
				FlxG.sound.list.add(drums);
				taiko = new FlxSound();
				FlxG.sound.list.add(taiko);
				choir = new FlxSound();
				FlxG.sound.list.add(choir);
				hats = new FlxSound();
				FlxG.sound.list.add(hats);
				adders = new FlxSound();
				FlxG.sound.list.add(adders);
				slayer = new FlxSound();
				FlxG.sound.list.add(slayer);
				retalHats = new FlxSound();
				FlxG.sound.list.add(retalHats);
				bells = new FlxSound();
				FlxG.sound.list.add(bells);
				pads = new FlxSound();
				FlxG.sound.list.add(pads);
				danger = new FlxSound();
				FlxG.sound.list.add(danger);

				FlxG.sound.music.looped = true;
				FlxG.sound.music.autoDestroy = false;
				FlxG.sound.music.onComplete = generateSong;
				FlxG.sound.playMusic();
				playFinaleMusic();
			}
		//}

		musicTimeCusp = FlxG.sound.music.length - Conductor.crochet;
		musicBeatCusp = Math.round(musicTimeCusp / Conductor.crochet);
		//#if debug
		trace('1 Beat before music end = ' + musicTimeCusp + ' (in miliseconds) | ' + musicBeatCusp + ' (in beats)');
		//#end

		//Beat 0 Events (cause beathit doesnt update properly lmao)
		doSubtitleShit();

		//trace('isMusicPlaying? = ' + FlxG.sound.music.playing);
		
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

		if (SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				isBFTurn = true;
				//Correctly sets sectionBool
				sectionBool = false;
				if (!sectionBool)
					sectionHit();
			}
			else
			{
				isBFTurn = false;
				//ditto
				sectionBool = true;
				if (sectionBool)
					sectionHit();
			}
		}
		else
		{
			sectionBool = true;
			if (sectionBool)
				sectionHit();
		}

		instLowHP.time = FlxG.sound.music.time;
		instLowHP.play();
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

		if (!tempAddedSongPosShit)
		{
			tempAddedSongPosShit = true;
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
				songPosDeathIndicator.antialiasing = FlxG.save.data.antialiasing;

				songPosClock = new FlxSprite(songPosBG.x - 20, songPosBG.y - 6).loadGraphic(Paths.image('timePosClock'));

				songPosTxt = new FlxText(songPosBG.x, songPosBG.y - 8, 0, "--:--", 16);
				songPosTxt.screenCenter(X);
				songPosTxt.setFormat(Paths.font("vcr.ttf"), 35, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				songPosTxt.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3, 3);
				//songPosTxt.antialiasing = true;
				//songPosTxt.scrollFactor.set();

				songPosBG.cameras = [camHUD];
				songPosBar.cameras = [camHUD];
				songPosDeathIndicator.cameras = [camHUD];
				songPosClock.cameras = [camHUD];
				songPosTxt.cameras = [camHUD];
				songPosGroup.cameras = [camHUD];

				songPosGroup.add(songPosBG);
				songPosGroup.add(songPosBar);
				songPosGroup.add(songPosDeathIndicator);
				songPosGroup.add(songPosClock);
				songPosGroup.add(songPosTxt);

				songPosGroup.forEach(function(blep:FlxSprite)
				{
					blep.alpha = 0;
					blep.y -= 15;
					FlxTween.tween(blep, {alpha: 1, y: blep.y + 15}, 1, {type: ONESHOT, ease: FlxEase.elasticOut});
				});
			}
			else
				strumLine.y -= 15;
		}

		/*if (useVideo)
			GlobalVideo.get().resume();*/

		#if windows
		if (FlxG.save.data.showPresence)
		{
			// Updating Discord Rich Presence (with Time Left)
			DiscordClient.changePresence(detailsText
				+ SONG.song + " (" + storyDifficultyText + ")",
				"Score: " + songScore
				+ " | RIPs: " + (misses + slips)
				+ " | Rating: " + Ratings.GenerateLetterRank(accuracy) + " (" + HelperFunctions.truncateFloat(accuracy, 2)
				+ "%)");
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
			skipButton.antialiasing = FlxG.save.data.antialiasing;
			skipButton.updateHitbox();
			skipButton.cameras = [camHUD];
			skipButton.alpha = 0;
			add(skipButton);
			FlxTween.tween(skipButton, {alpha: 1, y: skipButton.y - 5}, 0.2, {type: ONESHOT, ease: FlxEase.sineInOut});
		}
	}

	public function generateSong():Void
	{
		if (!generatedSong)
		{
			FlxG.sound.loadMusic(Paths.inst(SONG.song), musicVolume, false, musicGroup);
			if (SONG.needsVoices)
				vocals = new FlxSound().loadEmbedded(Paths.voices(SONG.song));
			else
				vocals = new FlxSound();
			vocals.volume = vocalsVolume;
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
			musicGroup.add(instLowHP);

			if (coolSoundFilter != null)
			{
				coolSoundFilter.applyFilter(FlxG.sound.music);
				if (SONG.needsMiscs)
					coolSoundFilter.applyFilter(miscs);
			}
	
	
			switch (SONG.song)
			{
				case "Finale":
					vocals.looped = true;
			}
	
			notes = new FlxTypedGroup<Note>();
			notes.cameras = [camHUD];
			add(notes);
	
			generatedSong = true;
		}
		else
		{
			//Fixed faulty looping code!
			//Merged with GenerateSong!
			setSongTime(0, true);
			clearNotesBefore(0);
			vocals.play();
			playFinaleMusic();
		}

		// pre lowercasing the song name (generateSong)
		var songPath = 'assets/data/' + songLowercase + '/';
		generateChart(songPath);
	}

	function generateChart(chartPath:String = '')
	{
		if (chartPath == '')
		{
			trace('Hello, please add a path, thank you!');
			FlxG.log.warn('[generateChart()] Hello, please add a path, thank you!');
			return;
		}

		var songData = SONG;
		curSong = songData.song;

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		// Per song offset check
		#if windows
		for (file in sys.FileSystem.readDirectory(chartPath))
		{
			var path = haxe.io.Path.join([chartPath, file]);
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
					//trace('Offset file not found. Creating one @: ' + chartPath);
					sys.io.File.saveContent(chartPath + songOffset + '.offset', '');
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
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	var funnyRatingCheckStart:Float = 0;
	var funnyRatingCheckEnd:Float = 0;
	var daBabyArrowY:Float = 0;
	
	private function generateStaticArrows(player:Bool = false, forceIntro:Bool = false):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			//Sloink                                V
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y + (!PlayStateChangeables.useDownscroll ? -10 : 10));

			if (PlayStateChangeables.Optimize && player)
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

			babyArrow.antialiasing = FlxG.save.data.antialiasing;
			babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

			babyArrow.updateHitbox();
			//babyArrow.scrollFactor.set();


			if (forceIntro || (storyProgress <= 0 && !hasReset))
			{
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + (!PlayStateChangeables.useDownscroll ? 10 : -10), alpha: 1}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.circOut, startDelay: Conductor.crochet / 1000 + (0.2 * i)});
			}
			else 
				babyArrow.y += (!PlayStateChangeables.useDownscroll ? 10 : -10);

			babyArrow.ID = i;

			babyArrow.animation.play('static');
			if(!PlayStateChangeables.Optimize)
				babyArrow.x += 40;
			else
				babyArrow.x -= 225;

			if (player)
				babyArrow.x += (FlxG.width / 2);

			cpuStrums.forEach(function(spr:FlxSprite)
			{
				spr.centerOffsets(); //CPU arrows start out slightly off-center
			});

			if(player)
			{
				if (FlxG.save.data.strumline)
				{
					var strumlineBG:FlxSprite = new FlxSprite(babyArrow.x - 1, (!PlayStateChangeables.useDownscroll ? -10 : 10)).loadGraphic(Paths.image('strumline', 'week' + (storyWeek > 0 ? storyWeek : 1)));
					strumlineBG.antialiasing = FlxG.save.data.antialiasing;

					if (forceIntro || (storyProgress <= 0 && !hasReset))
					{
						strumlineBG.alpha = 0;
						FlxTween.tween(strumlineBG, {y: 0, alpha: 0.4}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.expoOut, startDelay: Conductor.crochet / 500 + (0.2 * i)});
					}
					else
						strumlineBG.y = 0;
					
					if (PlayStateChangeables.useDownscroll)
						strumlineBG.flipY = true;

					grpStrumLine.add(strumlineBG);
				}
				playerStrums.add(babyArrow);
				generatedArrows = true;



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
			else
			{
				babyArrow.color = 0xFFD8D7D2;
				cpuStrums.add(babyArrow);
			}

			strumLineNotes.add(babyArrow);
		}

		if (player && (forceIntro || healthAndScoreGroup.alpha == 0))
		{
			healthAndScoreGroup.alpha = 0;
			healthAndScoreGroup.y += 100;
			FlxTween.tween(healthAndScoreGroup, {alpha: 1, y: healthAndScoreGroup.y - 100}, Conductor.crochet * 4 / 1000, {type: ONESHOT, ease: FlxEase.expoOut, startDelay: Conductor.stepCrochet / 1000});
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
		{
			grpStrumLine.forEach(function(strumlineBG:FlxSprite)
			{
				strumlineBG.acceleration.y = 1100;
				strumlineBG.velocity.y -= FlxG.random.int(20, 75);
				strumlineBG.velocity.x -= FlxG.random.int(-20, 20); 
				FlxTween.tween(strumlineBG, {alpha: 0}, 0.5, {type: ONESHOT, ease: FlxEase.expoIn});
			});
		}
		FlxTween.tween(healthBarBG, {alpha: 0}, 0.5 * delayMultiplier, {type: ONESHOT, ease: FlxEase.quadOut});
		FlxTween.tween(healthBar, {alpha: 0}, 0.5 * delayMultiplier, {type: ONESHOT, ease: FlxEase.quadOut});
		FlxTween.tween(iconP1, {alpha: 0}, 0.5 * delayMultiplier, {type: ONESHOT, ease: FlxEase.quadOut});
		FlxTween.tween(iconP2, {alpha: 0}, 0.5 * delayMultiplier, {type: ONESHOT, ease: FlxEase.quadOut});
		FlxTween.tween(scoreTxt, {alpha: 0}, 0.5 * delayMultiplier, {type: ONESHOT, ease: FlxEase.quadOut});
		//FlxTween.tween(songNameTXT, {alpha: 0}, 0.5 * delayMultiplier, {type: ONESHOT, ease: FlxEase.quadOut});
		finishedHUDFadeOutFunction = true;
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (!endedSong)
		{
			if (startTimer != null && !startTimer.finished && startTimer.active)
				startTimer.active = false;

			if (paused && !died)
			{
				if (FlxG.sound.music != null)
					FlxG.sound.music.pause();

				musicGroup.pause();
				vocals.pause();
				miscs.pause();

				switch (curSong)
				{
					case "Desperation" | "Disagreement" | "Retaliation":
						if (!startedCountdown && songStarted)
							if (stageSound != null && stageSound.playing)
								stageSound.pause();
				}

				#if windows
				if (FlxG.save.data.showPresence)
				{
					DiscordClient.changePresence("[PAUSED] "
						+ SONG.song + " (" + storyDifficultyText + ")",
						"Score: " + songScore
						+ " | RIPs: " + (misses + slips)
						+ " | Rating: " + Ratings.GenerateLetterRank(accuracy) + " (" + HelperFunctions.truncateFloat(accuracy, 2)
						+ "%)");
				}
				#end
			}
			else if (paused && died)
			{
				#if windows
				// Game Over doesn't get his own variable because it's only used here
				if (FlxG.save.data.showPresence)
				{
					DiscordClient.changePresence("[GAME OVER] " + SONG.song + " (" + storyDifficultyText + ")", "Score: " + songScore, "apppresence-dark");
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
			if (startTimer != null && !startTimer.finished && !startTimer.active)
				startTimer.active = true;
			
			if (paused && !died)
			{
				if (FlxG.sound.music != null && songStarted)
				{
					if (!showedResults && !inCutscene)
						resyncVocals();
				}

				switch (curSong)
				{
					case "Desperation" | "Disagreement" | "Retaliation":
						if (!startedCountdown && songStarted)
							if (stageSound != null && !stageSound.playing)
								stageSound.resume();
				}
		
				paused = false;
		
				#if windows
				if (FlxG.save.data.showPresence)
				{
					if (startTimer != null && startTimer.finished && !paused)
					{
						DiscordClient.changePresence(detailsText
							+ SONG.song + " (" + storyDifficultyText + ")",
							"Score: " + songScore
							+ " | RIPs: " + (misses + slips)
							+ " | Rating: " + Ratings.GenerateLetterRank(accuracy) + " (" + HelperFunctions.truncateFloat(accuracy, 2)
							+ "%)");
					}
				}
				#end
			}
		}
		
		super.closeSubState();
	}

	function setScoreText(score:Int):String
	{
		//Default text is the botplay's
		var funnyReturn:String = "(Press [1] to hide HUD) | BotPlay Score: " + score;
		//if we aren't in botplay, we actually change the text to the player's preferences.
		if (!PlayStateChangeables.botPlay)
		{
			//NPS shit
			funnyReturn = (FlxG.save.data.npsDisplay ? "NPS:" + nps + "/" + maxNps + " | " : "");
			//Score, Combo Breaks, and Rating
			funnyReturn +="Score:" + (score + campaignScore) + " | RIPs:" + (misses + campaignMisses + slips + campaignSlips) + " (" + Ratings.GenerateLetterRank(accuracy, keeledOver) + ")";
			//Clear Percentage
			if (FlxG.save.data.accuracyDisplay)
				funnyReturn += " | Clear:" + Math.floor(clearPercentage) + "%";// + " | [TEMP] Acc:" + accuracy + "%";
		}
		return funnyReturn;
	}

	function resyncVocals():Void
	{
		if (!endedSong && Conductor.songPosition < musicTimeCusp)
		{
			if (FlxG.sound.music.time - Conductor.songPosition > 150 && FlxG.save.data.lagCompensation && !endedSong && !PlayStateChangeables.botPlay)
			{
				allowHealthModifiers = false;
				lagCompIcon.alpha = 0.5;
			}

			if (PauseSubState.resyncToLastPos && songStarted)
			{
				PauseSubState.resyncToLastPos = false;
				setSongTime(Conductor.stepCrochet * curStep);
			}
			else
			{
				if (FlxG.sound.music.time > 10)
					Conductor.songPosition = FlxG.sound.music.time;
				vocals.time = Conductor.songPosition;
				miscs.time = Conductor.songPosition;
				instLowHP.time = FlxG.sound.music.time;
				vocals.play();
				miscs.play();
				instLowHP.play();
				FlxG.sound.music.play();
			}
		}
	}

	private var paused:Bool = false;
	var died:Bool = false;
	var startedCountdown:Bool = false;
	var skipCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNps:Int = 0;

	//var lagspikeDetectionThreshold = FlxG.save.data.fpsCap * 0.35; //maybe 0.3 is fine but I'm testing out 0.35
	var compensatedViaLagSpike:Bool = false;
	public var keeledOver:Bool = false;

	var styleSound:FlxSound;
	var goodStyleHits:Int = 0;
	var improvStyleHits:Int = 0;
	var badStyleHits:Int = 0;
	var stylePresses:Int = 0;

	function styleOnEm(ms:Float, styleToIntimidate:Bool = false):Void
	{
		#if debug
		trace('beatOffset: ' + ms);
		#end
		var styleRating:String = Ratings.CalculateRating(ms);
		//Placeholder Anims - I'll add rating dependent ones in the future maybe
		if (!PlayStateChangeables.Optimize)
			boyfriend.playAnim('style', true);

		if (intimidationPTS > 0)
		{
			if (intimidationPTS < 8)
			{
				if (intimidationBeats > 0)
					intimidationBeats += 4;
				else
					intimidationBeats = 8; //Limit intmidation stacking
				intimidationPTS--;
				//Play a sound here lol
			}
			else if (intimidationPTS >= 8)
			{
				intimidationPTS -= 8;
				intimidationBeats += 32; //Yes this is stackable
				if (targetHealth < 1)
					targetHealth = 1;
				targetHealth += 0.15;
				//Play a MEGA sound here lol
			}
		}

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
					else if (improvStyleHits >= 2 && improvStyleHits < 16)
						improvStyleHits++;
			default:
				if (stylePresses >= goodStyleHits + 4)
					badStyleHits++;
				else if (goodStyleHits >= 4)
					goodStyleHits++;
				else if (improvStyleHits >= 4 && improvStyleHits < 16)
					improvStyleHits++;
		}
		styleSound.play(true);
		styleSound.volume = 0.35;
		styleSound.pitch = FlxG.random.float(0.8, 1.2);
		/*#if cpp
		@:privateAccess
		{
			lime.media.openal.AL.sourcef(styleSound._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, FlxG.random.float(0.8, 1.2));
		}
		#end*/
	}

	private function styleCheck():Void
	{
		if (badStyleHits < 8)
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
			targetHealth += calculateHealth(14, (FlxMath.isOdd(goodStyleHits) ? health : health / 2), accuracy, goodStyleHits);
		}
		goodStyleHits = 0;
		improvStyleHits = 0;
	}

	private function tweenScroll():Void
	{
		if (songSpeedTween != null)
			songSpeedTween.cancel(true);

		songSpeedTween = FlxTween.tween(this, {curScroll: newScroll}, Conductor.crochet * 2 / 1000, {ease: FlxEase.smootherStepOut,
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

	var curBPM:Float;
	private function tweenBPM(givenValues:Array<Float>):Void
	{
		if (songBPMTween != null)
			songBPMTween.cancel(true);

		//These aren't necessary but they're for clarity's sake-!
		curBPM = Conductor.bpm;
		var newBPM:Float = givenValues[1];
		var tweenDuration:Float = givenValues[2];

		trace('bpm change tween in seconds: ' + tweenDuration);
		songBPMTween = FlxTween.tween(this, {curBPM: newBPM}, tweenDuration, {ease: FlxEase.linear,
			onUpdate: function(twn:FlxTween)
			{
				Conductor.changeBPM(curBPM);
				fakeCrochet = (60 / curBPM) * 1000;
				idleCamShakeTimer = Conductor.crochet / 1000 - 0.01;
				compensationTime = Conductor.crochet * 2 / 1000;
				//trace('DAPEEPEEEM UPDATE: ' + Conductor.bpm);
			},
			
			onComplete: function(twn:FlxTween) 
			{
				//Failsafe
				Conductor.changeBPM(newBPM);
				fakeCrochet = (60 / curBPM) * 1000;
				idleCamShakeTimer = Conductor.crochet / 1000 - 0.01;
				compensationTime = Conductor.crochet * 2 / 1000;
				trace('! DAPEEPEEEM FEENESH: ' + Conductor.bpm);
				songBPMTween = null;
			}
		});
	}

	var holdArray:Array<Bool> = [false, false, false, false];
	var switchTest:Bool = false;
	//var tempDisableResyncVocals:Bool = false;

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.mouse.visible && !paused)
			FlxG.mouse.visible = false;

		if (songStarted && !switchTest && FlxG.keys.justPressed.TAB)
		{
			switchTest = true;
			//tempDisableResyncVocals = true;
			trace("time to break the game!!!!!");
			SONG = FreeplayState.songData.get("Technical Difficulties")[2];
			Conductor.changeBPM(SONG.bpm);
			songLowercase = StringTools.replace(SONG.song, " ", "-").toLowerCase();
			generatedSong = false;
			vocals.stop();
			miscs.stop();
			musicGroup.stop();
			clearAllNotes();
			generateSong();
			startSong();
		}

		if (SONG.song == "Finale" && FlxG.keys.justPressed.SPACE)
		{
			setSongTime(FlxG.sound.music.length / 2);
			clearNotesBefore(FlxG.sound.music.length / 2);
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

		if (FlxG.sound.music.playing)
		{
			if (!showedResults && !endedSong)
			{		
				//Sound/Music Filter List Shit! :33
				if (coolSoundFilter != null)
				{
					coolSoundFilter.applyFilter(FlxG.sound.music);
					if (SONG.needsMiscs)
						coolSoundFilter.applyFilter(miscs);
				}		

				if (SONG.eventObjects != null && SONG.eventObjects.length != 0)
				{
					for (i in SONG.eventObjects)
					{
						if (!i.triggerCheck)
						{
							//gonna use timed values rather than beats cuz it's more precise and less prone to fucking up - gurlie's not an expert coder-
							if (i.type == "BPM Tween" && i.value[0] <= Conductor.songPosition)
							{
								i.triggerCheck = true;
								// `i.value` contains these vars in order: position of event in ms, tempo to tween to, length of tween
								// couldn't find a better way to do this without doing 7 different unreliable things that break the game so manual it is-
								//im not gonna code different tween types sorry ill just work with linear cuz good lord my heard hurts-
								tweenBPM(i.value);
							}
							else if (i.position <= curDecimalBeat)
							{
								i.triggerCheck = true;
								switch(i.type)
								{
									//To Do: move mid song anims and events here
									//For example: case "Play Character Animation":x
									case "Scroll Speed Change":
										prevScrollCheck = false;
										prevScroll = newScroll;
										newScroll = (i.value * diffSpeedMult) * FlxG.save.data.scrollSpeed;
										tweenScroll();
									case "BPM Change":
										Conductor.changeBPM(i.value, false);
										fakeCrochet = (60 / i.value) * 1000;
										idleCamShakeTimer = Conductor.crochet / 1000 - 0.01;
										compensationTime = Conductor.crochet * 2 / 1000;
								}
							}
						}
					}
				}

				notes.sort(FlxSort.byY, (PlayStateChangeables.useDownscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));

				if (!PlayStateChangeables.Optimize && songStarted && generatedSong && !paused)
					camFollowShit();

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
					if (nps > maxNps)
						maxNps = nps;
				}
			}
		}

		if (!cannotDie && !endedSong)
			safeVignette.visible = false;
		else if (!endedSong && canPause)
			safeVignette.visible = true;

		if (controls.PAUSE && !skippingIntro && !video.isPlaying && allowDeaths && canPause && !paused && (FlxG.sound.music.time < musicTimeCusp || !FlxG.sound.music.playing))
			pauseGame();

		if ((FlxG.sound.music.playing && FlxMath.roundDecimal(health, 3) <= 0) || (FlxG.keys.justPressed.R && !skippingIntro && FlxG.save.data.resetButton))
		{
			if (!showedResults && !video.isPlaying && allowDeaths && !PlayStateChangeables.botPlay)
			{
				if (!cannotDie)
				{
					if (!allowHealthModifiers && !FlxG.keys.justPressed.R)
						targetHealth = 0.05;
					else
					{
						if (FlxG.keys.justPressed.R)
						{
							resetButtonFailSafe++;
						
							if (resetButtonFailSafe <= 1)
							{
								FlxG.sound.play(Paths.sound('GitarooHover'), 0.7);
								if (resetTextTwn != null)
									resetTextTwn.cancel();
								resetText.alpha = 1;
								resetText.borderColor = 0xFF600000;
								resetButtonTimer = new FlxTimer().start(0.35, function(tmr:FlxTimer)
								{
									resetText.borderColor = 0xFF000000;
									resetButtonTimer.active = false;
									resetButtonFailSafe = 0;
									resetTextTwn = FlxTween.tween(resetText, {alpha: 0}, 1, {type: ONESHOT, ease: FlxEase.sineInOut, onComplete:
										function (twn:FlxTween)
										{
											resetTextTwn = null;
										}
									});
								});
							}
							else if (resetButtonTimer.active && !resetButtonTimer.finished)
							{
								causeOfDeath = 'intentional-reset';
								literallyFuckingDie();
							}
						}
						else
						{
							//Natural Deaths
							literallyFuckingDie();
							if (doPityDeaths)
							{
								normalPityDeaths++;
								mechanicPityDeaths++;
							}
						}
					}
				}
				else if (!FlxG.keys.justPressed.R)
				{
					if (camGame.finishedFade)
					{
						if (!keeledOver)
						{
							keeledOver = true;
							camGame.fade(FlxColor.RED, Conductor.crochet / 500, true);
							FlxG.sound.play(Paths.sound('deathsound-practice'));
							//preventRepeatDeaths = true;
							campaignDeaths++;
							songDeaths++;
							camShake(true, false);
							
							if (FlxG.save.data.songPosition)
								songPosDeathIndicator.x = songPosBar.x + (songPosBar.width * (songPosBar.percent * 0.01)) - (songPosDeathIndicator.width - 26) - 6;
							safeVignette.color = 0xFFFF0000;
							safeVignette.blend = MULTIPLY;
							safeVignette.alpha = 1;
							if (!PlayStateChangeables.Optimize)
							{
								boyfriend.alpha = 0.75;
								boyfriend.color = 0xFF00F7FF;
							}
							blackScreen.alpha = (!Main.nightMode && !FlxG.save.data.nightmode ? 0.15 : 0.4);
							changeBarColors(healthBar, FlxColor.RED, FlxColor.ORANGE);
							healthBar.alpha = 0.8;
							iconP1.color = 0xFFBEBEBE;
							if (FlxG.save.data.strumline)
								grpStrumLine.blend = MULTIPLY;
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
		#end

		if (FlxG.keys.justPressed.SEVEN && !video.isPlaying && !isStoryMode)
		{
			campaignDeaths = 0;
			songDeaths = 0;
			hasReset = false;
			cannotDie = true;
			canPause = false;
			Main.updateTimeStuffs();
			FlxG.switchState(new ChartingState());
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
		}

		if (FlxG.keys.justPressed.NINE)
			iconP1.swapOldIcon();

		if (PlayStateChangeables.botPlay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;

		//DC.beginProfile("NoteShits");
		if (generatedSong && startedCountdown)
		{
			//Updating of alphas
			if (FlxG.save.data.lagCompensation) //Prevents crash if lag compensation is off
				if (lagCompIcon.alpha != 0)
					lagCompIcon.alpha = FlxMath.lerp(0, lagCompIcon.alpha, calculateLerpTime(elapsed, 5));

			if (!paused && !endedSong)
			{
				holdArray = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];

				notes.forEachAlive(function(daNote:Note)
				{
					if (!daNote.tooLate)
					{
						daNote.visible = true;
						daNote.active = true;
					}
		
					var center:Float = strumLineNotes.members[daNote.noteData].y + Note.swagWidth / 2;
		
					if (PlayStateChangeables.useDownscroll)
					{
						if (daNote.mustPress)
						{
							daNote.y = (playerStrums.members[daNote.noteData].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * daNote.scrollSpeed);
							if (daNote.y > playerStrums.members[daNote.noteData].y + 50 && !daNote.startSpeeding && (!daNote.wasGoodHit || !holdArray[daNote.noteData]) && !PlayStateChangeables.botPlay)
							{
								daNote.startSpeeding = true;
								if (daNote.isParent)
									for (i in daNote.children)
										i.startSpeeding = true;
								else if (daNote.isSustainNote)
									for (i in daNote.parent.children){i.startSpeeding = true; i.speedingSustainSlip = true;}
							}
						}
						else
						{
							daNote.y = (cpuStrums.members[daNote.noteData].y + 0.45 * (Conductor.songPosition - daNote.strumTime) * daNote.scrollSpeed);
							if (daNote.y > cpuStrums.members[daNote.noteData].y + 50 && !daNote.startSpeeding && daNote.forceMiss)
							{
								daNote.startSpeeding = true;
								if (daNote.isParent)
									for (i in daNote.children)
										i.startSpeeding = true;
							}
						}

						if (daNote.missAdditiveY != 0)
							daNote.y += daNote.missAdditiveY * daNote.scrollSpeed;
		
						if (daNote.isSustainNote)
						{
							//daNote.fixPossibleGaps();
							// Remember = minus makes notes go up, plus makes them go down
							daNote.y += (Note.swagWidth / 2) - (60.5 * (daNote.scrollSpeed - 1));
							daNote.y += 27.5 * ((SONG.bpm / 100) - 1) * (daNote.scrollSpeed - 1);
							daNote.y -= 10;

							//SUSTAIN FIXINS (downscroll)
							//YOINKED FROM PSYCH
							//STILL BROKEN FOR DOWNSCROLL BUT I GIVE UP IT WORKS CLOSE ENOUGH LMAO
							if (daNote.isSustainTail)
							{
								daNote.y += 10.5 * (fakeCrochet / 400) * 1.5 * daNote.scrollSpeed + (46 * (daNote.scrollSpeed - 1));
								daNote.y -= 46 * (1 - (fakeCrochet / 600)) * daNote.scrollSpeed;
							}
							//daNote.y += 30 * (1 - (fakeCrochet / 600)) * daNote.scrollSpeed;
		
							// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
							if ((daNote.mustPress && ((daNote.parent.wasGoodHit && holdArray[daNote.noteData] && daNote.sustainActive) || PlayStateChangeables.botPlay)) || (!daNote.mustPress && !daNote.forceMiss))
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
						{
							daNote.y = (playerStrums.members[daNote.noteData].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * daNote.scrollSpeed);
							if (daNote.y < playerStrums.members[daNote.noteData].y - 50 && !daNote.startSpeeding && (!daNote.wasGoodHit || !holdArray[daNote.noteData]) && !PlayStateChangeables.botPlay)
							{
								daNote.startSpeeding = true;
								if (daNote.isParent)
									for (i in daNote.children)
										i.startSpeeding = true;
								else if (daNote.isSustainNote)
									for (i in daNote.parent.children){i.startSpeeding = true; i.speedingSustainSlip = true;}
							}
						}
						else
						{
							daNote.y = (cpuStrums.members[daNote.noteData].y - 0.45 * (Conductor.songPosition - daNote.strumTime) * daNote.scrollSpeed);
							if (!daNote.startSpeeding && daNote.y < cpuStrums.members[daNote.noteData].y - 50 && daNote.forceMiss)
							{
								daNote.startSpeeding = true;
								if (daNote.isParent)
									for (i in daNote.children)
										i.startSpeeding = true;
							}
						}

						if (daNote.missAdditiveY != 0)
							daNote.y -= daNote.missAdditiveY * daNote.scrollSpeed;
		
						//Offset akgsgkdksg
						//daNote.y += daNote.offsetY;
		
						if (daNote.isSustainNote)
						{
							//Prevents the sustain notes from beign separated from it's parents
							daNote.y -= 10.5 * (fakeCrochet / 400) * 1.5 * daNote.scrollSpeed + (46 * (daNote.scrollSpeed - 1));
							daNote.y += 46 * (1 - (fakeCrochet / 600)) * daNote.scrollSpeed;
							daNote.y += 40;
		
							//Summarizing the if statement for my small ahh brain
							//Clip the note if it needs to be pressed and all of these is true - if not, still do it regardless if the note isn't forced to be missed
							//                                             ^ if sustain is active and being held and it's parent was a good hit or if botplay
							//if ((daNote.mustPress && ((daNote.sustainActive && holdArray[daNote.noteData] && daNote.parent.wasGoodHit) || PlayStateChangeables.botPlay)) || !daNote.forceMiss)
							
							//Clip the note if dad note that isnt forced missed or a player note that has active sustain, hold array, and good hit parent or if its botplay
							//absolute gibberish
							//help im fucking confused lmao
							//am throwin shit into daWall and seein what sticks here i go!!
							//if this dont work fix it tommorow i cant be bothered lmao
							//OMFG YES@!!! IT FUCKING WORKED  S S S  G ! ! ! QJGDJSGKDSGKSDGKSGKSGKSKSKGKJWS (forcemiss on botplay)
							//nvfm it clips everytime now
							//im trying this one now
							//YESS FINALLY!!!
							if ((daNote.mustPress && ((daNote.parent.wasGoodHit && holdArray[daNote.noteData] && daNote.sustainActive) || PlayStateChangeables.botPlay)) || (!daNote.mustPress && !daNote.forceMiss))
							{
								// Clip to strumline
								if (daNote.y + daNote.offset.y * daNote.scale.y <= center)
								{
									var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
									swagRect.y = (center - daNote.y) / daNote.scale.y;
									if (!PlayStateChangeables.botPlay)
										swagRect.height -= swagRect.y;
									swagRect.bottom = swagRect.y + daNote.height + 30; //basically playing it safe
		
									daNote.clipRect = swagRect;
								}
							}
						}
					}

					if (daNote.mustPress && daNote.toggledSurpriseNote && !daNote.triggeredNoteEvent)
					{
						daNote.triggeredNoteEvent = true;
						if (!PlayStateChangeables.Optimize)
						{
							if (!dad.animation.curAnim.name.startsWith("gun") || dad.animation.curAnim.curFrame >= 3)
								dad.playAnim('gunLOAD', false);

							if (stageOverlay1 != null)
								stageOverlay1.animation.play('warning');
						}
					}

					//if a player's note, update until deleted
					if (daNote.mustPress)
					{
						//horrible way(?) but it works i guess
						//no actually it works wonders i will give myself a kiss and a pat
						//for mashing check
						if ((daNote.overlaps(grpStrumLine) && FlxG.save.data.ghost || daNote.overlaps(playerStrums) && !FlxG.save.data.ghost) && !daNote.isSustainNote)
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
					}
					//otherwise, update until a good hit. don't stop updating if it's a forcemiss
					else if (!daNote.wasGoodHit || daNote.forceMiss)
					{
						//trace ("test");
						daNote.visible = cpuStrums.members[daNote.noteData].visible;
						if (daNote.x != cpuStrums.members[daNote.noteData].x)
						{
							daNote.x = cpuStrums.members[daNote.noteData].x;
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
					}

					if (daNote.sustainActive && !daNote.withinCompensation)
						daNote.alpha = daNote.baseAlpha * (daNote.mustPress ? playerStrums.members[daNote.noteData].alpha : cpuStrums.members[daNote.noteData].alpha);

					if (!daNote.noteWasActive && !daNote.canBeHit && !daNote.isOnScreen(camHUD)) //testing an early return that skips all this shit when it's far away from being seen on camera
						return;
		
					if (!daNote.mustPress && daNote.wasGoodHit && daNote.enabled)		
						enemyNoteHit(daNote);
		
					if (daNote.tooLate)
					{
						if (!daNote.delayedDeath && daNote.enabled)
						{
							if (daNote.mustPress && !daNote.withinCompensation && !PlayStateChangeables.botPlay)
							{
								if (!daNote.isSustainNote)
								{
									switch (daNote.noteType)
									{
										case 'mine':
											//totalCleared[0]++;
											dodgeFuckingShot(false, daNote.noteData);
											//la health none for mine
											updateAccuracy(1);
											//sicks++;

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
													targetHealth += calculateHealth(1, targetHealth, accuracy);

													//trace("hold fell over at the start");
													for (i in daNote.children)
													{
														i.alpha = 0.3;
														i.baseAlpha = 0.3;
														i.sustainActive = false;
														maxSongScore += calculateScore('sick', true);
													}
												}
												else
												{
													//Health Drain for Non-Sustain
													targetHealth += calculateHealth(0, targetHealth, accuracy);
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
											targetHealth += calculateHealth(2, targetHealth, accuracy);
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
													sploshThisShitUp(daNote, 'miss');
												popUpScore('', daNote);
												trace('failed sus popup');
												if(FlxG.save.data.missSounds)
												{
													missSoundGroup.stop();
													FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.3, 0.4), false, missSoundGroup);
												}
												vocals.volume = 0;

												//Add failure to clear calculations
												totalCleared[0]--;
												trace('wuh??');
											}
											else if (daNote.isSustainTail || daNote.isBeforeTail)
											{
												trace('begone, TAIL!');
												daNote.visible = false;
												daNote.kill();
												notes.remove(daNote, true);
											}
											
										}
										else
										{
											//Health Drain for Sustain Children
											targetHealth += calculateHealth(3, targetHealth, accuracy);
										}

										updateAccuracy();
									}
								}
		
								if (!daNote.isOnScreen(camHUD))
								{
									daNote.visible = false;
									//daNote.finnaBeKilled = true;
									daNote.kill();
									notes.remove(daNote, true);
									//trace ('deleted non sus note');
								}
								else if (daNote.enabled)
									daNote.enabled = false;
							}
							else
							{
								//Compensation/Botplay Notes
								if (!daNote.isSustainNote)
								{
									switch (daNote.noteType)
									{
										case 'mine':
											dodgeFuckingShot(false, daNote.noteData);
										case 'trigger':
											getFuckingShot(true);
									}
								}
		
								//daNote.finnaBeKilled = true;
								if (!daNote.isOnScreen(camHUD))
								{
									daNote.visible = false;
									daNote.kill();
									notes.remove(daNote, true);
								}
								else if (daNote.enabled)
									daNote.enabled = false;
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
		
					if (daNote.forceAlpha && !daNote.isSustainNote) //!daNote.mustPress is a given since this variable is turned on within Note.hx and could only be activated if it's not a player note
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
		
					if (!allowHealthModifiers && !daNote.withinCompensation && !daNote.delayedDeath && daNote.enabled && daNote.isOnScreen(camHUD))
					{
						daNote.withinCompensation = true;
						if ((daNote.strumTime <= Conductor.songPosition - Conductor.safeZoneOffset * Conductor.timeScale))
						{
							if (daNote.isSustainNote && daNote.sustainActive && daNote.spotInLine != daNote.parent.children.length)
							{
								for (i in daNote.parent.children)
								{
									i.alpha = 0.1;
									i.sustainActive = false;
								}
							}
							daNote.enabled = false;
						}
					}
				});
				if (songStarted && !inCutscene)
					keyShit();
			}	

			//Do this like parappa/scratchin where you have a bar you need to follow on top of the health bar
			/*if (!endedSong && !showedResults && !startingSong && !PlayStateChangeables.botPlay)
			{
				if (controls.STYLE && generatedSong)
				{
					stylePresses++;
					if ((!boyfriend.animation.curAnim.name.startsWith('style') || boyfriend.animation.curAnim.curFrame >= 3) && !boyfriend.animation.curAnim.name.startsWith('dodge') && !boyfriend.animation.curAnim.name.startsWith('hurt') && !boyfriend.stunned)
					{
						var bpmMult:Float = Conductor.songPosition * (Conductor.bpm * 0.01);
						var beatOffset = Std.int(bpmMult % 600);
						beatOffset = (beatOffset >= 300) ? beatOffset - 600 : beatOffset;
						styleOnEm(beatOffset, FlxG.keys.justPressed.C);
					}
					else
					{
						//Play a sound for this
						badStyleHits++;
						if (stylePresses >= goodStyleHits + 8)
							goodStyleHits--;
					}
				}
			}*/

			//Particles and stage updates
			switch (curStage)
			{
				case 'border':
					if (updateWiggleShader)
						objectWiggleShader.update(elapsed);
				case 'cityskyline':
					//this was once disabled, i enabled it to see what happens
					//hehehe I made it work!!11!
					cityLights.members[curLight].alpha = FlxMath.lerp(0, cityLights.members[curLight].alpha, calculateLerpTime(elapsed, 3 * (Conductor.bpm * 0.01)));
				case 'cityskylineVariegated':
					if (updateWiggleShader)
						objectWiggleShader.update(elapsed);

					if(!PlayStateChangeables.Optimize && stageParticles != null)
					{
						/*var i:Int = stageParticles.length - 1;
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
						}*/
						stageParticles.forEachAlive(function(particle:PsychEngineFancyStageShit.FancyStageParticle)
						{
							if (particle.alpha < 0)
							{
								particle.kill();
								stageParticles.remove(particle, true);
								particle.destroy();
							}
						});
					}
			}

			//HurtVignette
			if (hurtDelay == 0)
			{
				if (hurtVignette.alpha > 0)
				{
					resetHurtFxScale = false;
					hurtVignette.alpha = FlxMath.lerp(0, hurtVignette.alpha, calculateLerpTime(elapsed, (Conductor.bpm * 0.01)));
					var hurtScaleAmt:Float = 0.75 - (0.07 * hurtVignette.alpha);
					hurtVignette.scale.set(hurtScaleAmt, hurtScaleAmt);
					hurtVignette.screenCenter();
										
					hurtVignette.updateHitbox();
				}
				else if (!resetHurtFxScale)
				{
					resetHurtFxScale = true;
					hurtVignette.scale.set(0.68, 0.68);
					hurtVignette.screenCenter();
										
					hurtVignette.updateHitbox();
				}
			}

			//Low-Health Suspense
			lowHPEffectVol = 1 - health;
			lowHPHeartBeat.volume = FlxMath.lerp(lowHPEffectVol, lowHPHeartBeat.volume, calculateLerpTime(elapsed, 15));
			
			if (lowHPOverlay.alpha > 0)
			{
				
				if (FlxG.save.data.flashing)
					lowHPOverlay.alpha = FlxMath.lerp(0, lowHPOverlay.alpha, calculateLerpTime(elapsed, 4.5 * (Conductor.bpm * 0.01)));
				else
					lowHPOverlay.alpha = FlxMath.lerp(lowHPEffectVol, lowHPOverlay.alpha, calculateLerpTime(elapsed, 6 * (Conductor.bpm * 0.01)));
			}

			//Low HP Effects
			if (!skippingIntro)
			{
				switch (songLowercase)
				{
					case 'mic-test':
						if (health < 1)
							coolSoundFilter.gainLF = ((lowHPEffectVol * 0.7) - 1) * -1;
						else if (coolSoundFilter.gainLF < 1)
							coolSoundFilter.gainLF = 1;

					default:
						if (SONG.needsAdaptiveMus)
						{
							if (health < 1)
							{
								FlxG.sound.music.volume = FlxMath.lerp((health - 0.3), FlxG.sound.music.volume, calculateLerpTime(elapsed, 15));
								instLowHP.volume = FlxMath.lerp((lowHPEffectVol + 0.3), instLowHP.volume, calculateLerpTime(elapsed, 15));
							}
							else if (FlxG.sound.music.volume < 1)
							{
								FlxG.sound.music.volume = 1;
								instLowHP.volume = 0;
								lowHPOverlay.alpha = 0;
							}
						}
				}
			}

			dummySongScore = FlxMath.lerp(dummySongScore, songScore, 0.15);
			scoreTxt.screenCenter(X);
		}
		//Might aswell update this every frame lmao
		scoreTxt.text = setScoreText(Math.round(dummySongScore)); //why was this in another fucking state LMFAO
		//And here we see a local devgirl using scoretext as a testing visual aid
		//scoreTxt.text = "Gain HighFreq: " + FlxMath.roundDecimal(FlxG.sound.music.filter.gainHF, 3) + " | Gain LowFreq: " + FlxMath.roundDecimal(FlxG.sound.music.filter.gainLF, 3);
		//scoreTxt.text = 'fucking dearths: ' + FlxMath.roundDecimal(songDeaths, 5);
		//scoreTxt.text = 'CurBeat: ' + curBeat + ' | CurStep: ' + curStep + ' |  curBPM: ' + Conductor.bpm;
		//scoreTxt.text = 'ConductorPos: ' + Conductor.songPosition + ' | songPos: ' + FlxG.sound.music.time;

		if (FlxG.save.data.distractions)
		{
			var mult1:Float = FlxMath.lerp(1, iconP1.scale.x, calculateLerpTime(elapsed, 7.5 * (Conductor.bpm * 0.01)));
			iconP1.scale.set(mult1, mult1);
			iconP1.updateHitbox();
	
			var mult2:Float = FlxMath.lerp(1, iconP2.scale.x, calculateLerpTime(elapsed, 7.5 * (Conductor.bpm * 0.01)));
			iconP2.scale.set(mult2, mult2);
			iconP2.updateHitbox();
		}

		iconP1.x = healthBar.x + 5 + (healthBar.width * (FlxMath.remapToRange(CoolUtil.getPercentOfNumber(health, 2, 3), 0, 100, 100, 0) * 0.01)) + (150 * iconP1.scale.x - 150) / 2 - 26;
		iconP2.x = healthBar.x - 5 + (healthBar.width * (FlxMath.remapToRange(CoolUtil.getPercentOfNumber(health, 2, 3), 0, 100, 100, 0) * 0.01)) - (150 * iconP2.scale.x) / 2 - 26 * 2;

		//Health Caps
		if (health > 2.05)
			health = 2.05;
		else if (health < 0 && cannotDie)
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
					if (skipButton != null)
						skipButton.destroy();
				}
			});
		}
	
		if (FlxG.keys.justPressed.SPACE && skipActive && generatedSong && startedCountdown && curBeat >= 0)
		{
			needSkip = false;
			skippingIntro = true;
			skipActive = false;
			preventTutorialTips = true;
			FlxG.sound.play(Paths.sound('skipSongIntro'));
			FlxG.sound.music.volume = 0;
			//Play Camera Animation Here
			if (!PlayStateChangeables.Optimize)
			{
				dummyBlackScreen.alpha = 1;
				grpStrumLine.visible = false;
				playerStrums.forEach(function(playurShite:FlxSprite)
				{
					playurShite.visible = false;
				});
				cpuStrums.forEach(function(opponentShite:FlxSprite)
				{
					opponentShite.visible = false;
				});
				//camHUD.visible = false;
			}

			if (songLowercase == 'mic-test')
			{
				if (camTween != null)
					camTween.cancel();
				camGame.zoom = 1.5;

				for (twn in tutorialTweenArray)
					if (twn != null && twn.active)
						twn.cancel();

				//This Keeps Crashing ugh
				if (tutorialGraphicA != null)
					tutorialGraphicA.destroy();
				if (tutorialGraphicB != null)
					tutorialGraphicB.destroy();
				if (tutorialGraphicC != null)
					tutorialGraphicC.destroy();

				if (tutorialText != null)
					tutorialText.destroy();
			}

			if (skipButton != null)
				FlxTween.shake(skipButton, 0.05, 0.3, X, {ease: FlxEase.sineIn});

			new FlxTimer().start(0.32, function(tmr:FlxTimer)
			{
				skippingIntro = false;
				if (skipButton != null)
					skipButton.destroy();
				if (!PlayStateChangeables.Optimize)
				{
					dummyBlackScreen.alpha = 0;
					grpStrumLine.visible = true;
					playerStrums.forEach(function(playurShite:FlxSprite)
					{
						playurShite.visible = true;
					});
					cpuStrums.forEach(function(opponentShite:FlxSprite)
					{
						opponentShite.visible = true;
					});
					//camHUD.visible = true;
				}
				if (songPosClock != null)
					FlxTween.shake(songPosClock, 0.05, Conductor.crochet / 1000, XY, {ease: FlxEase.sineOut});
				setSongTime(skipTo);
				clearNotesBefore(skipTo);
				FlxG.sound.music.volume = 1;
			});
		}

		if (songStarted)
		{
			if (!paused && !showedResults)
			{
				//Health lerp shits
				health = FlxMath.lerp(targetHealth, health, calculateLerpTime(elapsed, 16));
				if (Conductor.songPosition < FlxG.sound.music.length)
					Conductor.songPosition += FlxG.elapsed * 1000;
				//else if (Conductor.songPosition != songLength)
					//Conductor.songPosition = songLength;

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
					songPosTxt.text = FlxStringUtil.formatTime(secondsTotal, false);
					songPosTxt.screenCenter(X);
				}

				// Interpolation type beat
				//if (Conductor.lastSongPos != Conductor.songPosition)
					//Conductor.lastSongPos = Conductor.songPosition;

				//CONVERTED TO ELSE IFS
				//NEVERMIND-??
				if (FlxG.save.data.lagCompensation && generatedSong)
				{
					//LagSpike Compensation Attempt
					if (allowLagComp && !PlayStateChangeables.botPlay)
					{
						//if (FlxG.updateFramerate < lagspikeDetectionThreshold && curBeat > 4 && !endedSong && allowHealthModifiers)
						//A better way to check the fps
						if (Main.fpsCounter.gameGoinThruIt)
						{
							if (!endedSong && allowHealthModifiers)
							{
								lagCompIcon.alpha = 1;
								allowHealthModifiers = false;
								compensatedViaLagSpike = true;
							}
						}
						else if (!compensatedViaLagSpike && !allowHealthModifiers)
							allowHealthModifiers = true;
					}

					if (compensatedViaLagSpike)
					{
						compensatedViaLagSpike = false;
						if (compensationTimer != null && compensationTimer.active)
							compensationTimer.cancel();

						compensationTimer = new FlxTimer().start(compensationTime, function(tmr:FlxTimer)
						{
							allowHealthModifiers = true;
						});
					}
				}
			}
		}
		else if (!endedSong && startedCountdown)
			Conductor.songPosition += FlxG.elapsed * 1000;

		if (!paused && camZooming && !camZoomUsesTween)
		{
			camGame.zoom = FlxMath.lerp(defaultCamZoom, camGame.zoom, calculateLerpTime(elapsed, 2.5 * (Conductor.bpm * 0.01)));
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, calculateLerpTime(elapsed, 3 * (Conductor.bpm * 0.01)));
		}

		#if debug
		FlxG.watch.addQuick("Game is Going Thru It", Main.fpsCounter.gameGoinThruIt);
		FlxG.watch.addQuick("Allow Health Modifiers", allowHealthModifiers);
		FlxG.watch.addQuick("Compensated Via Lagspike", compensatedViaLagSpike);
		FlxG.watch.addQuick("Compensation Timer Active", (compensationTimer != null ? compensationTimer.active : "currently NULL!"));
		FlxG.watch.addQuick("curBPM", Conductor.bpm);
		//Broken for some hecking reason
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

	function camShake(force:Bool = true, decay:Bool = false, camToShake:String = 'camGame', ?holdFor:Int = 1, intensity:Float = 0.03, duration:Float = 0.25, axis:FlxAxes = XY):Void
	{
		if (decay)
		{
			intensity *= 2;
			duration *= 2;
		}

		switch (camToShake)
		{
			case 'camHUD':
				camHUD.shake(holdFor, intensity, duration, force, decay, axis);
			default:
				camGame.shake(holdFor, intensity, duration, force, decay, axis);
		}
	}

	function changeBarColors(bar:FlxBar, emptyColor:FlxColor, fillColor:FlxColor):Void
	{
		bar.createFilledBar(emptyColor, fillColor);
		bar.updateBar();
	}

	var vignetteChecker:Int = 0;
	var gotShotBlurVal:Float = 0;
	var iconTrailTimer:FlxTimer;
	//Turned them into functions for consistency's sake :3
	function getFuckingShot(purelyVisual:Bool = false):Void
	{
		vocals.volume = 0;
		//Cool Lowpass Shit
		coolSoundFilter.gainHF = 0;
		if (coolSoundFilterTween != null)
			coolSoundFilterTween.cancel();
		coolSoundFilterTween = FlxTween.tween(coolSoundFilter, {gainHF: 1}, Conductor.crochet * 8 / 1000,
			{
				ease: FlxEase.smootherStepInOut,
				startDelay: Conductor.crochet * (timesShot < 5 ? timesShot : 4) / 1000,
				onComplete: function(twn:FlxTween) 
				{
					coolSoundFilterTween = null;
				}
			});
		
		if (!PlayStateChangeables.Optimize)
		{
			dad.playAnim('gunSHOOT', true);
			boyfriend.playAnim('hurt', true);
			if (stageOverlay1 != null && stageOverlay1.animation.curAnim.name.toLowerCase() == 'warning')
				stageOverlay1.animation.play('static');
		}

		if (specialNoteHitSFX.playing)
			specialNoteHitSFX.stop();
		specialNoteHitSFX = FlxG.sound.load(Paths.sound('Note_Mine'), false);
		specialNoteHitSFX.play();
		camShake(true, false, 'camGame', 0.2, Conductor.crochet / 1000);
		camShake(true, true, 'camHUD', 0.05, Conductor.crochet / 800, X);
		
		//mmm complex system ahf h
		if (!purelyVisual && allowHealthModifiers)
		{
			iconP1.playAnimation('lowHP'); //PlaceholderAnim
			if (health >= 0.5)
			{
				if (iconTrailTimer != null && iconTrailTimer.active)
					iconTrailTimer.cancel();
				iconTrail1.active = true;
				iconTrail2.active = true;
				iconTrailTimer = new FlxTimer().start(0.3, function(tmr:FlxTimer)
				{
					iconTrail1.active = false;
					iconTrail1.resetTrail();
					iconTrail2.active = false;
					iconTrail2.resetTrail();
				});
			}
			hurtVignette.alpha = 1;
			camGame.filtersEnabled = true;
			gotShotBlurLol.blurX = 2;
			gotShotBlurLol.blurY = 2;
			gotShotBlurVal = 2;
			if (hurtDelay < 8)
				hurtDelay += 2;

			if (gotShotBlurTwn != null)
				gotShotBlurTwn.cancel();
			gotShotBlurTwn = FlxTween.tween(this, {gotShotBlurVal: 0}, Conductor.crochet * 8 / 1000,
			{
				ease: FlxEase.cubeOut,
				onUpdate: function(twn:FlxTween) 
				{
					gotShotBlurLol.blurX = gotShotBlurVal;
					gotShotBlurLol.blurY = gotShotBlurVal;
				},
				
				onComplete: function(twn:FlxTween) 
				{
					if (!paused)
						camGame.filtersEnabled = false;
					gotShotBlurTwn = null;
				}
			});

			timesShot++;
			//trace("ate " + timesShot + ' bullet/s');

			causeOfDeath = 'ate-bullet';
			
			//la health drain for failed specil	
			//Minushealth - not instakill
			if (timesShot <= 3 - storyDifficulty && timesClutched <= 5 + mechanicPityDeaths - 2)
			{
				//I redid this cuz the previous way was effing convoluted as heck LMFAO
				if (health > 0.15)
				{
					if (timesShot <= 1) //Takes care of values lower than 1
						targetHealth = 0.1;
					else if (timesShot == 2) //Can only reach up to 2 anyway here
						targetHealth = 0.025;
					else //We handle this then by subbing for values higher than 2
						targetHealth -= 0.025;
				}
				else
				{
					if (health >= 0.125)
						targetHealth -= 0.05;
					else
						targetHealth -= 0.025;
				}
			}
			else //instakill if the player fails enough times
			{
				if (timesClutched < 5 + mechanicPityDeaths - 2 && timesClutched < 10) //Caps clutching to 10 so that it dont go up infinitely LMAO
				{
					timesShot = 0;
					timesClutched++;
					//trace("clutched " + timesClutched + ' death/s');

					targetHealth = 0;
					//IDEA! MAKE IT DEPENDENT ON HOW CLOSE YOU ARE TO DYING!!!
					//LIKE Paths.sound('damageAlert_' + timesClutched)!! !!!
					//d0ne HEHEHEHEHEHEH!!
					FlxG.sound.play(Paths.sound('damageAlert_' + (timesClutched < 5 ? timesClutched : 5)), 0.65 + 0.05 * timesClutched, false);
					//Before you say "woAH, theres LORE hidden in the code!!!!11!!1!", only the city has the weird glitchy overlay thanng, no it aint lore i just dont wanna add that var on any other stage calm yoself lol
					if (stageOverlay2 != null && stageOverlay2.exists)
					{
						vignetteChecker = (5 + mechanicPityDeaths - 2) - timesClutched;
						//trace (vignetteChecker);
						//DONT JUDGE ME!!! THE CODE WORKS FINE!!!!
						switch(vignetteChecker)
						{
							case 2:
								stageOverlay2.animation.play('warn0');
							case 1:
								stageOverlay2.animation.play('warn1');
							case 0:
								stageOverlay2.animation.play('warn2');
							default:
								stageOverlay2.animation.play('none');
						}
					}
				}
				else if (!cannotDie)
				{
					causeOfDeath = 'ate-many-bullets';
					FlxG.sound.play(Paths.sound('damageAlert_fail'), 0.7, false);
					targetHealth = -100;
					health = -100;
				}
			}
		}
	}

	function dodgeFuckingShot(?playDodgeSound:Bool = true, arrowDir:Int):Void
	{
		if (!PlayStateChangeables.Optimize)
			{
				if (stageOverlay1 != null)
					stageOverlay1.animation.play('static');
				dad.playAnim('gunSHOOT', true);
				switch (arrowDir)
				{
					case 0 | 1:
						boyfriend.playAnim('dodgeB', true);
						singFollowOffset = [-15, -2];
					case 2 | 3:
						boyfriend.playAnim('dodgeA', true);
						singFollowOffset = [15, 2];
				}
			}
			camShake(true, true, 0.035, Conductor.crochet / 1000);
			camShake(true, true, 'camHUD', 0.01, Conductor.crochet / 1000);

			if (playDodgeSound)
			{
				if (specialNoteHitSFX.playing)
					specialNoteHitSFX.stop();
				specialNoteHitSFX = FlxG.sound.play(Paths.sound('Note_Trigger'), false);
				specialNoteHitSFX.play();
			}
	}

	var loadingNextSong:Bool = false;

	function endSong():Void
	{
		//trace("ended song");
		endedSong = true;
		generatedSong = false;

		vocals.stop();
		miscs.stop();
		musicGroup.stop();

		if (Ratings.GenerateLetterRank(accuracy) == 'RETRY' && !cannotDie && !PauseSubState.skippedSong)
		{
			doCamFollowing = false;
			if(doPityDeaths)
			{
				normalPityDeaths++;
				mechanicPityDeaths++;
			}
			literallyFuckingDie();
			return;
		}

		if (FlxG.save.data.fpsCap > 290)
		{
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);
			FlxG.save.data.fpsCap = 290;
		}

		songDeaths = 0;
		mechanicPityDeaths = 0;
		normalPityDeaths = 0;

		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);

		if(hasSubtitles && subtitleText != null)
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

		/*if (FlxG.save.data.shitBreaksCombo)
			campaignMisses += misses + slips;
		else*/
		campaignMisses += misses;
		misses = 0;
		campaignSlips += slips;
		slips = 0;
		campaignBads += bads;
		bads = 0;
		campaignGoods += goods;
		goods = 0;
		campaignSicks += sicks;
		sicks = 0;

		playedCutscene = false;
		if (!toggledPracticeMode)
			cannotDie = false;

		PlayStateChangeables.botPlay = false;
		PlayStateChangeables.useDownscroll = false;

		canPause = false;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG.validScore && !toggledPracticeMode && !PlayStateChangeables.botPlay)
		{
			var songHighscore = StringTools.replace(SONG.song, " ", "-");

			Highscore.saveScore(songHighscore, songScore, storyDifficulty);
			if (!PauseSubState.skippedSong)
				Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
			campaignRatingArray.push(Ratings.GenerateLetterRank(accuracy));
		}

		//Ending
		if (isStoryMode)
		{
			campaignScore += songScore;

			if (playlistLength > 1 && songsCheatedOn.length >= storyProgress + 1)
			{
				songsCheatedOn[storyProgress] = toggledPracticeMode;
				if (songsCheatedOn[storyProgress] == false)
					songsCheatedOn[storyProgress] = PlayStateChangeables.botPlay;
			}
			storyPlaylist.remove(storyPlaylist[0]);
			storyProgress++;

			//for week ending
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
					vocals.stop();
					if (FlxG.save.data.scoreScreen)
					{
						if (!finishedHUDFadeOutFunction)
							fadeOutGameplayHUD(1);

						showedResults = true;
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
							showedResults = true;
							FlxG.switchState(new ResultsScreen());
						}
						else
							FlxG.switchState(new StoryMenuState());
					}
				}

				if (SONG.validScore && !songsCheatedOn.contains(true) && !PlayStateChangeables.botPlay)
				{
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					Highscore.saveWeekCombo(storyWeek, Ratings.DetermineWeekRating(campaignRatingArray), storyDifficulty);
					if (storyWeek + 1 > FlxG.save.data.weekUnlocked && storyWeek < 4)
						StoryMenuState.unlockNextWeek(storyWeek);
				}
			}
			else
			{
				var skippedSong:Bool = PauseSubState.skippedSong;
				PauseSubState.skippedSong = false;
				
				nextStateIsPlayState = true;

				if (storyProgress > 0)
				{
					FlxTransitionableState.skipNextTransOut = true;
					FlxTransitionableState.skipNextTransIn = true;
					
					prevHealth = health;

					if (!skippedSong)
					{
						//For loadingState
						LoadingState.doScreenshotShit = true;
						FlxScreenGrab.defineCaptureRegion(Math.round(FlxG.scaleMode.offset.x), Math.round(FlxG.scaleMode.offset.y), Math.round(FlxG.scaleMode.gameSize.x), Math.round(FlxG.scaleMode.gameSize.y));
						FlxScreenGrab.grab(false, true);
						grabbedScreen = FlxScreenGrab.screenshot.bitmapData;
					}
				}
				else
				{
					FlxTransitionableState.skipNextTransOut = false;
					FlxTransitionableState.skipNextTransIn = false;
				}

				prevCamFollow = camFollow;

				#if debug
				trace('LOADING NEXT SONG');
				#end
				//trace(poop);

				lagCompIcon.alpha = 0;
				loadingNextSong = true;

				songDeaths = 0;
				hasReset = false;

				FlxTween.tween(loadingIcon, {alpha: 1}, 0.25, {type: ONESHOT, ease: FlxEase.smootherStepIn, onComplete: function(twn:FlxTween)
				{
					// adjusting the song name to be compatible
					var songFormat = StringTools.replace(storyPlaylist[0], " ", "-");
					var poop:String = Highscore.formatSong(songFormat, storyDifficulty);
					SONG = Song.loadFromJson(poop, storyPlaylist[0]);

					LoadingState.target = new PlayState();
					FlxG.switchState(new LoadingState(true));
				}});
			}
		}
		else
		{
			#if debug
			trace('WENT BACK TO FREEPLAY');
			#end

			if (FlxG.save.data.scoreScreen)
			{
				if (!finishedHUDFadeOutFunction)
					fadeOutGameplayHUD(1);
				openSubState(new ResultsScreen());
				showedResults = true;
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

	public var nextStateIsPlayState:Bool = false;

	override function destroy()
	{
		Conductor.songPosition = 0;

		if (!nextStateIsPlayState)
		{
			trace ('CLEARING PLAYSTATE DATA!!!!!!');
			Paths.clearCurrentLevel();

			accuracy = 0;

			if (grabbedScreen != null)
				grabbedScreen.dispose();
			
			FlxG.mouse.visible = true;
			//FlxG.game.soundTray.silent = false;

			videoPathArray = [];

			//Clearing of campaign accuracy and resetting of bools
			startTime = 0;
			PauseSubState.skippedSong = false;
			PauseSubState.randomMusicTime = false;

			if (ChartingState.lastSection != 0)
				ChartingState.lastSection = 0;

			if (clearNumTwn != null)
				clearNumTwn.cancel();

			songDeaths = 0;
			mechanicPityDeaths = 0;
			normalPityDeaths = 0;
			storyPlaylist = [];
			songsCheatedOn = [];
			playlistLength = 0;
			storyProgress = 0;

			campaignScore = 0;
			campaignMisses = 0;
			campaignSlips = 0;
			campaignBads = 0;
			campaignGoods = 0;
			campaignSicks = 0;
			clearPercentage = 0;
			totalCleared = [0, 0];
			campaignDeaths = 0;
			campaignRatingArray = [];
			highestCombo = 0;

			camEXT.visible = false;
			prevHealth = 1;
			hasReset = false;
			toggledPracticeMode = false;
			playedCutscene = false;
			cannotDie = false;

			showedResults = false;

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;
			transIn.camera = FlxCamera.defaultCameras[FlxCamera.defaultCameras.length];
			transOut.camera = FlxCamera.defaultCameras[FlxCamera.defaultCameras.length];

			PauseSubState.randomMusicTime = false;
			
			//Dumping of cache
			Paths.clearStoredMemory();
			Paths.clearUnusedMemory();

			Main.doFocusShit = true;

			FlxG.sound.music.stop(); //Unloads the preloaded music

			//We uhhh we uhhh ermm uhhhhhh;;;
			//FlxG.fixedTimestep = true;
		}

		super.destroy();
	}

	function playEndCutscene():Void
	{
		video = new VideoHandler();

		vocals.stop();
		miscs.stop();
		musicGroup.stop();
		
		/*if (FlxG.sound.music.playing)
			trace("BRO MUSIC PLAYING?!");
		else
			trace("BRO NO MUSIC PLAYING?!");*/

		FlxTransitionableState.skipNextTransOut = true;

		switch (songLowercase)
		{
			case 'up-and-beyond' | 'retaliation':	
				if (FlxG.save.data.scoreScreen)
				{
					//FlxG.switchState(new MinigameState());
					inCutscene = true;
					video.playMP4(Paths.video(videoPathArray[videoArrayProgress]), false, videoSprite, false, false);
					videoSprite.visible = true;
					camGame.visible = false;
					camGame.active = false;
					video.finishCallback = function()
					{
						videoSprite.visible = false;
						openSubState(new ResultsScreen());
					}
				}
				else
				{
					FlxTransitionableState.skipNextTransOut = true;
					inCutscene = true;
					video.finishCallback = function()
					{
						FlxG.switchState(new StoryMenuState());
					}
					video.playMP4(Paths.video(videoPathArray[videoArrayProgress]), false, videoSprite, false, false);
					videoSprite.visible = true;
					video.finishCallback = function()
					{
						videoSprite.visible = false;
					}
				}
			//Placeholder for Final Song, change when Final Song is added
			case 'thorns':
				FlxTransitionableState.skipNextTransOut = true;
				inCutscene = true;
				video.playMP4(Paths.video(videoPathArray[videoArrayProgress]), false, videoSprite, false, false);
				videoSprite.visible = true;
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
				if (FlxG.save.data.scoreScreen && !showedResults)
				{
					if (!finishedHUDFadeOutFunction)
						fadeOutGameplayHUD(1);

					openSubState(new ResultsScreen());
					showedResults = true;
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
	var showNumShit:Bool = false;
	var nonSustainCombo:Int = 0;//Internal for ratings only - i dunno if this is gonna stay or not but slay

	private function popUpScore(type:String, daNote:Note = null, ?noteDiff:Float = 0, ?isJack:Bool = false):Void
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
				rating.antialiasing = FlxG.save.data.antialiasing;
				rating.updateHitbox();
				rating.cameras = [camHUD];
				grpRatingsFG.add(rating);

				FlxTween.tween(rating, {alpha: 0}, 0.1, 
				{
					type: ONESHOT, 
					onComplete: function(tween:FlxTween)
					{
						rating.destroy();
					},
					startDelay: Conductor.crochet * 0.001 / 2
				});


			case 'sustain':
				if (daNote == null)
					return;

				var daRating = daNote.rating;
				if (daRating == null)
					return;

				if (combo >= 20 && daRating != 'miss' && daRating != 'slip')
					showNumShit = true;

				if (allowHealthModifiers && !daNote.withinCompensation)
					updateAccuracy(daNote.parentWife);

				if (!PlayStateChangeables.botPlay && showNumShit && !daNote.isBehindParent)
				{
					//Early return for no combo
					if (combo <= 0)
						return;
					
					grpRatingsMG.forEachAlive(function(prevNum:FlxSprite)
					{
						prevNum.acceleration.y += 25 * (Conductor.bpm * 0.01);
						if (prevNum.color != FlxColor.RED && prevNum.color != 0xFFEA417C)
						{
							prevNum.color = 0xFFd7d1e6;
							if (prevNum.alpha == 1)
								prevNum.alpha = 0.5;
						}
						else
							prevNum.color = 0xFFEA417C;
					});

					var separatedScore:Array<Int> = [];
					var daLoop2:Int = 0;
					var comboSplit:Array<String> = (combo + "").split('');
					var thousandAdditive:Float = 0; //For making thousands actually look good
	
					if (combo > highestCombo)
						highestCombo = combo;
	
					// make sure we have 3 digits to display (looks weird otherwise lol)
					//idk i just wanted to make this look neater lol
					if (comboSplit.length < 3)
						for (i in 0...3 - comboSplit.length)
							separatedScore.push(0);
					else if (comboSplit.length > 3)
						for (i in 0...comboSplit.length - 3)
							thousandAdditive -= 37;
	
					for (i in 0...comboSplit.length)
					{
						var str:String = comboSplit[i];
						separatedScore.push(Std.parseInt(str));
					}

					for (i in separatedScore)
					{
						var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num' + Std.int(i)));
						numScore.x = FlxG.save.data.changedHitX + (37 * daLoop2) + thousandAdditive;
						numScore.y =  FlxG.save.data.changedHitY + 80;
						if (i != 0)
							numScore.angle = FlxG.random.float(-7.5, 7.5);
						//numScore.angularVelocity = FlxG.random.float(-25, 25);
						numScore.cameras = [camHUD];
						numScore.antialiasing = FlxG.save.data.antialiasing;
						numScore.updateHitbox();
						//guys are more heavy to avoid coverin up the top
						numScore.acceleration.y = FlxG.random.int(750, 850);
						numScore.velocity.y -= FlxG.random.int(140, 160);
						numScore.velocity.x = FlxG.random.float(-2.5, 2.5);
	
						grpRatingsMG.add(numScore);
	
						FlxTween.tween(numScore, {alpha: 0}, 0.15, {type: ONESHOT, 
							onComplete: function(tween:FlxTween)
							{
								numScore.destroy();
							},
							startDelay: Conductor.crochet * 0.001
						});
	
						daLoop2++;
					}
				}


			default:
				if (daNote == null)
					return;

				var daRating = daNote.rating;
				if (daRating == null)
					return;
				
				var timingColour:FlxColor = 0xFF88979c;
		
				if (daRating != 'miss')
				{
					//Clear Percent Calculations
					if (daRating == 'sick' || daRating == 'good' || daRating == 'bad')
						totalCleared[0]++;
					else if (daRating == 'slip')
						totalCleared[0] += 0.25;
					clearPercentage = (totalCleared[0] / totalCleared[1]) * 100;
					//trace ('clearcalced all over the place??? ' + clearPercentage + ' | ' + totalCleared + ' out of ' + totalPlayed);

					var wife:Float = EtternaFunctions.wife3(-noteDiff, Conductor.timeScale);
					updateAccuracy(wife);

					if (daNote.isParent)
						for (i in daNote.children)
							i.parentWife = wife;
				}
		
				if (combo >= 10 && daRating != 'miss' && daRating != 'slip')
					showNumShit = true;
		
				if (allowHealthModifiers && !daNote.withinCompensation)
				{
					//trace (songScore);
					songScore += calculateScore(daRating);
					maxSongScore += calculateScore('sick');

					switch (daRating)
					{
						//To do: Add difficulty-dependent health drains as well as customization
						//uhh i already did that
						//To did: Add(ed) difficulty-dependent health drains
						//oh oop i have not done customization yet
						case 'miss':
							if (allowHealthModifiers && !daNote.withinCompensation)
							{
								timingColour = FlxColor.RED;
								breakCombo();
								//noteMiss() handles this mostly lol
							}
						case 'shit':
							if (allowHealthModifiers && !daNote.withinCompensation)
							{
								bypassOppMissCheck++;
								timingColour = FlxColor.RED;
								breakCombo();
								slips++;
								missesInSection++;
								//Health Drain
								targetHealth += calculateHealth(4, targetHealth, accuracy);
							}
						case 'bad':
							//Health Drain
							targetHealth += calculateHealth(5, targetHealth, accuracy);
							bads++;
							timingColour = FlxColor.YELLOW;
						case 'good':
							bypassOppMissCheck--;
							//Health Gain
							targetHealth += !mashing ? calculateHealth(6, targetHealth, accuracy) * (isJack ? 1.25 : 1) : calculateHealth(6, targetHealth, accuracy) / (4 * mashPresses - mashPressThreshold);
							goods++;
							timingColour = FlxColor.LIME;
						case 'sick':
							bypassOppMissCheck -= 2;
							//Health Gain
							targetHealth += !mashing ? calculateHealth(7, targetHealth, accuracy, hurtVignette.alpha) * (isJack ? 1.25 : 1) : calculateHealth(7, targetHealth, accuracy, hurtVignette.alpha) / (4 * mashPresses - mashPressThreshold);
							sicks++;
							timingColour = FlxColor.CYAN;
					}
				}
		
				if (!PlayStateChangeables.botPlay)
				{
					//trace('huh????');
					grpRatingsBG.forEachAlive(function(prevRating:FlxSprite)
					{
						prevRating.acceleration.y += 25 * (Conductor.bpm * 0.01);
						if (prevRating.color != 0xFFD09A9C)
						{
							prevRating.color = 0xFFB1A9C3;
							if (prevRating.alpha == 1)
								prevRating.alpha = 0.5;
						}
						else
							prevRating.color = 0xFFD09A9C;
					});
					
					var rating:FlxSprite = new FlxSprite().loadGraphic(Paths.image("rating_" + daRating));
					var ratingStartDelay:Float = Conductor.crochet * 0.001;
					rating.x = FlxG.save.data.changedHitX;
					rating.y = FlxG.save.data.changedHitY;
					rating.y -= 10;
					//timer is longer if the note is a parent to multiple sustain children
					if (daNote.isParent)
					{
						//ratingStartDelay = Conductor.crochet * (0.001 * (daNote.children.length * 0.25));
						ratingStartDelay += Conductor.stepCrochet * (0.001 * daNote.children.length);
						rating.acceleration.y = 250 - (5 * daNote.children.length); //idfk lol
						rating.velocity.y -= FlxG.random.int(90, 120); //idfk lol part 2
					}
					else
					{
						rating.acceleration.y = 650;
						rating.velocity.y -= FlxG.random.int(170, 210);
					}

					rating.velocity.x -= FlxG.random.int(0, 10);
					rating.antialiasing = FlxG.save.data.antialiasing;
					rating.updateHitbox();
					rating.angularVelocity = FlxG.random.float(-10, 10);
					rating.cameras = [camHUD];
					grpRatingsBG.add(rating);
		
					if (currentTimingShown != null)
						grpRatingsFG.remove(currentTimingShown);

					if (daRating != 'miss')
					{
						var msTiming = HelperFunctions.truncateFloat(noteDiff, 2);
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
						currentTimingShown.y = rating.y + 10 + 95;
						currentTimingShown.updateHitbox();
						currentTimingShown.cameras = [camHUD];
						if (currentTimingShown.alpha != 1)
							currentTimingShown.alpha = 1;
						if (currentTimingShown != null)
							grpRatingsFG.add(currentTimingShown);
					}
		
					if (showNumShit)
					{
						if (daRating != 'shit' && daRating != 'miss')
						{
							grpRatingsMG.forEachAlive(function(prevNum:FlxSprite)
							{
								prevNum.acceleration.y += 25 * (Conductor.bpm * 0.01);
								if (prevNum.color != FlxColor.RED && prevNum.color != 0xFFEA417C)
								{
									prevNum.color = 0xFFd7d1e6;
									if (prevNum.alpha == 1)
										prevNum.alpha = 0.5;
								}
								else
									prevNum.color = 0xFFEA417C;
							});
						}
						
						var separatedScore:Array<Int> = [];
						var daLoop:Int = 0;
						var comboSplit:Array<String> = (combo + "").split('');
						var thousandAdditive:Float = 0; //For making thousands actually look good
		
						if (combo > highestCombo)
							highestCombo = combo;
		
						// make sure we have 3 digits to display (looks weird otherwise lol)
						//idk i just wanted to make this look neater lol
						if (comboSplit.length < 3)
							for (i in 0...3 - comboSplit.length)
								separatedScore.push(0);
						else if (comboSplit.length > 3)
							for (i in 0...comboSplit.length - 3)
								thousandAdditive -= 37;
		
						for (i in 0...comboSplit.length)
						{
							var str:String = comboSplit[i];
							separatedScore.push(Std.parseInt(str));
						}
		
						for (i in separatedScore)
						{
							var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num' + Std.int(i)));
							numScore.x = rating.x + (37 * daLoop) + thousandAdditive;
							numScore.y = rating.y + 95;
							numScore.cameras = [camHUD];
							numScore.antialiasing = FlxG.save.data.antialiasing;
							numScore.updateHitbox();
							switch (daRating)
							{
								case 'shit' | 'miss':
									if (allowHealthModifiers && !daNote.withinCompensation)
									{
										//if (daRating != 'shit' || FlxG.save.data.shitBreaksCombo)
										numScore.color = timingColour;
										rating.color = 0xFFFFC7C7;
									}
									else
									{
										//if (daRating != 'shit' || FlxG.save.data.shitBreaksCombo)
										//{
										rating.color = timingColour;
										rating.alpha = 0.75;
										//}
									}
							}
		
							numScore.acceleration.y = FlxG.random.int(350, 450);
							numScore.velocity.y -= FlxG.random.int(130, 150);
							numScore.velocity.x = FlxG.random.float(-5, 5);
							if (i != 0)
								numScore.angle = FlxG.random.float(-7.5, 7.5);
							numScore.angularVelocity = FlxG.random.float(-25, 25);
		
							grpRatingsMG.add(numScore);
		
							//Not affected by ratingStartDelay
							FlxTween.tween(numScore, {alpha: 0}, 0.175, {type: ONESHOT, 
								onComplete: function(tween:FlxTween)
								{
									numScore.destroy();
									//if (currentTimingShown != null)
									//	currentTimingShown.alpha = 0;
								},
								startDelay: Conductor.crochet * (!daNote.isParent ? 0.00125 : 0.001)
							});
		
							daLoop++;
						}
					}
		
					if (daRating != 'miss')
					{
						FlxTween.tween(currentTimingShown, {alpha: 0}, 0.175, {type: ONESHOT, startDelay: Conductor.crochet * (daNote.isParent ? 0.00125 : 0.001)});
						FlxTween.tween(rating, {alpha: 0}, 0.3, {type: ONESHOT, 
							/*onUpdate: function(twn:FlxTween)
							{
								trace('test lol');
								rating.velocity.y += -0.75 + (0.75 * twn.percent);
							},*/

							onComplete: function(tween:FlxTween)
							{
								if (currentTimingShown != null && timeShown >= 20)
								{
									grpRatingsFG.remove(currentTimingShown);
									currentTimingShown = null;
								}
								rating.destroy();
							},
							startDelay: ratingStartDelay
						});
					}
					else
					{
						FlxTween.tween(rating, {alpha: 0}, 0.175, {type: ONESHOT, 
							onComplete: function(tween:FlxTween)
							{
								rating.destroy();
							},
							startDelay: ratingStartDelay
						});
					}
				}
				//else
					//trace ('botplay wife: ' + wife);
		
				//Note splash stuff
				if (allowHealthModifiers && !daNote.withinCompensation && daRating != 'miss' && daNote.noteType != 'mine' && daNote.noteType != 'trigger')
				{
					if (FlxG.save.data.notesplash && !PlayStateChangeables.botPlay && !daNote.isSustainNote)
						sploshThisShitUp(daNote, daRating);
					else
						adjustVocVolOnNoteHit(daNote);
				}
		}
	}

	var comboBreakSound:FlxSound;
	function breakCombo():Void //Breaks combo and plays combobreak noise
	{
		//The cool 000 effect when breaking a combo
		if (combo > 0 && showNumShit)
		{
			//Clears combo
			grpRatingsBG.forEachAlive(function(prevRating:FlxSprite)
			{
				prevRating.kill();
				prevRating.destroy();
			});
			grpRatingsMG.forEachAlive(function(prevNum:FlxSprite)
			{
				prevNum.kill();
				prevNum.destroy();
			});

			var separatedScore:Array<Int> = [0, 0, 0];
			var daPoop:Int = 0;
			for (i in separatedScore)
			{
				//trace('what??? ' + i);
				var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image('num' + Std.int(i)));
				numScore.x = FlxG.save.data.changedHitX + (37 * daPoop);
				numScore.y = FlxG.save.data.changedHitY + 95 - 10;
				numScore.cameras = [camHUD];
				numScore.antialiasing = FlxG.save.data.antialiasing;
				numScore.updateHitbox();
				numScore.color = FlxColor.RED;
				numScore.acceleration.y = FlxG.random.int(400, 450);
				numScore.velocity.y -= FlxG.random.int(130, 150);
				numScore.velocity.x = FlxG.random.float(-5, 5);
				numScore.angle = FlxG.random.float(-7.5, 7.5);

				grpRatingsMG.add(numScore);

				//Not affected by ratingStartDelay
				FlxTween.tween(numScore, {alpha: 0}, 0.15, {type: ONESHOT,
					onComplete: function(tween:FlxTween)
					{
						numScore.destroy();
					},
					startDelay: Conductor.crochet * 0.00125
				});
				daPoop++;
			}
		}

		showNumShit = false;

		if (combo >= 100 || nonSustainCombo >= 50)
		{
			if (comboBreakSound != null && comboBreakSound.playing)
				comboBreakSound.stop();

			comboBreakSound = FlxG.sound.play(Paths.soundRandom('comboBreakBig', 1, 3), 1);
			comboBreakSound.pitch = FlxG.random.float(0.8, 1.2);
		}
		else if (combo >= 50 || nonSustainCombo >= 10)
		{
			if (comboBreakSound != null && comboBreakSound.playing)
				comboBreakSound.stop();
			comboBreakSound = FlxG.sound.play(Paths.soundRandom('comboBreak', 1, 3), 1);
			(FlxG.random.float(0.75, 1.25));
		}
		
		combo = 0;
		nonSustainCombo = 0;
	}

	function sploshThisShitUp(daNote:Note, daRating:String):Void
	{
		if ((allowHealthModifiers && !daNote.withinCompensation) || ((daRating != 'shit' && daRating != 'miss')))
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

		// HOLDS, check for sustain notes
		if (holdArray.contains(true) && generatedSong)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && (daNote.parent == null || daNote.parent.wasGoodHit) && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && daNote.sustainActive)
				{
					//trace(daNote.sustainActive);
					if (!daNote.delayedDeath && daNote.enabled)
						goodNoteHit(daNote);
				}
			});
		}

		if ((KeyBinds.gamepad && !FlxG.keys.justPressed.ANY))
		{
			// PRESSES, check for note hits
			if (pressArray.contains(true) && generatedSong)
			{
				if (!PlayStateChangeables.Optimize)
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
						if (pressArray[coolNote.noteData] && !hit[coolNote.noteData] && !coolNote.delayedDeath && coolNote.enabled)
						{
							//if (mashViolations != 0)
							//	mashViolations--;
							hit[coolNote.noteData] = true;
							scoreTxt.color = FlxColor.WHITE;
							var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
							goodNoteHit(coolNote);
						}
					}
				};
				
				if (!PlayStateChangeables.Optimize && boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
				{
					if ((boyfriend.animation.curAnim.name.startsWith('sing') && boyfriend.animation.curAnim.curFrame >= 10 && ((boyfriend.animation.curAnim.name != "hurt" && !boyfriend.animation.curAnim.name.startsWith("dodge")) || boyfriend.animation.curAnim.finished)) && !boyfriend.animation.curAnim.name.endsWith('miss'))
					{
						boyfriend.playAnim('idleAfterSing');
						singFollowOffset = [0, 0];
					}
				}
				else if (!FlxG.save.data.ghost)
				{
					for (shit in 0...pressArray.length)
						if (pressArray[shit])
							noteMiss(shit, null);
				}
			}
		}
		
		notes.forEachAlive(function(daNote:Note)
		{
			if (PlayStateChangeables.useDownscroll && daNote.y > strumLine.y || !PlayStateChangeables.useDownscroll && daNote.y < strumLine.y)
			{
				// Force good note hit regardless if it's too late to hit it or not as a fail safe
				if (PlayStateChangeables.botPlay && daNote.canBeHit && daNote.mustPress || PlayStateChangeables.botPlay && daNote.tooLate && daNote.mustPress)
				{
					if (!daNote.delayedDeath && daNote.enabled)
						goodNoteHit(daNote);
					if (!PlayStateChangeables.Optimize)
						boyfriend.holdTimer = daNote.sustainLength;
				}
			}
		});

		if (!PlayStateChangeables.Optimize && boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && (!holdArray.contains(true) || PlayStateChangeables.botPlay))
		{
			if (((boyfriend.animation.curAnim.name.startsWith('sing') && boyfriend.animation.curAnim.curFrame >= 10) && ((boyfriend.animation.curAnim.name != "hurt" && !boyfriend.animation.curAnim.name.startsWith("dodge")) || boyfriend.animation.curAnim.finished)) && !boyfriend.animation.curAnim.name.endsWith('miss'))
			{
				boyfriend.playAnim('idleAfterSing');
				singFollowOffset = [0, 0];
				//trace("Idle (line 5601)");
			}
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			if (keys[spr.ID] && spr.animation.curAnim.name != 'confirm' && spr.animation.curAnim.name != 'pressed')
				spr.animation.play('pressed');
			if (!keys[spr.ID] && (spr.animation.curAnim.name != 'confirm' || spr.animation.curAnim.curFrame >= 6) && spr.animation.curAnim.name != 'static')
			{
				spr.animation.play('static');
				preventBFIdleAnim = false;
			}

			if (spr.animation.curAnim.name.startsWith('confirm'))
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
			else
				spr.centerOffsets();
		});
	}

	//focus function to be called in main
	//default is focusin - set it to `1` and it will be focusOut
	public function focusFunction(?checker:Int):Void
	{
		if (songStarted && generatedSong && !endedSong && !paused)
		{
			switch (checker)
			{
				//FocusOut
				case 1:
					if (lagCompTimer != null && lagCompTimer.active)
						lagCompTimer.cancel();
					allowLagComp = false;

					#if windows
					if (FlxG.save.data.showPresence)
					{
						DiscordClient.changePresence("[AUTO-PAUSED] "
						+ SONG.song + " (" + storyDifficultyText + ")",
						"Score: " + songScore
						+ " | RIPs: " + (misses + slips)
						+ " | Rating: " + Ratings.GenerateLetterRank(accuracy) + " (" + HelperFunctions.truncateFloat(accuracy, 2)
						+ "%)");
					}
					#end

				//FocusIn
				default:

					lagCompTimer = new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						allowLagComp = true;
					});

					#if windows
					if (FlxG.save.data.showPresence)
					{
						DiscordClient.changePresence(detailsText
							+ SONG.song + " (" + storyDifficultyText + ")",
							"Score: " + songScore
							+ " | RIPs: " + (misses + slips)
							+ " | Rating: " + Ratings.GenerateLetterRank(accuracy) + " (" + HelperFunctions.truncateFloat(accuracy, 2)
							+ "%)");
					}
					#end
			}
		}
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		if (causeOfDeath != 'note-spam' && causeOfDeath != 'ate-bullet')
			causeOfDeath = '';
		singFollowOffset = [0, 0];

		if (allowHealthModifiers && !daNote.withinCompensation)
		{
			bypassOppMissCheck++;

			if (!PlayStateChangeables.Optimize && showNumShit)
			{
				if (gf.animOffsets.exists('sad') && curSong != "Mic Test")
					gf.playAnim('sad');
				else if (dad.animOffsets.exists('sad') && curSong == "Mic Test")
					dad.playAnim('sad');
			}

			daNote.rating = 'miss';
			if (daNote.noteType != "trigger")
			//{
				popUpScore('', daNote);
				//trace('noteMiss popupscore');
			//}
			if (FlxG.save.data.notesplash && !PlayStateChangeables.botPlay)
				sploshThisShitUp(daNote, daNote.rating);

			if (daNote != null)
			{
				songScore += calculateScore('miss', daNote.isSustainNote);
				maxSongScore += calculateScore('sick', daNote.isSustainNote);
			}

			//NOTE MISS SOUND
			if(FlxG.save.data.missSounds && daNote.noteType != 'trigger')
			{
				vocals.volume = 0;
				missSoundGroup.stop();
				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.3, 0.4), false, missSoundGroup);
			}

			// Whole switch statement replaced with a single line :)
			// not that that does a whole lot - premature optimization claims another
			if (!PlayStateChangeables.Optimize)
				if ((boyfriend.animation.curAnim.name != 'hurt' && !boyfriend.animation.curAnim.name.startsWith("dodge")) || boyfriend.animation.curAnim.curFrame >= 3)
					boyfriend.playAnim('sing' + dataSuffix[direction] + 'miss', true);

			misses++;
			missesInSection++;

			updateAccuracy();
		}
	}

	var bypassOppMiss:Bool = false;
	var bypassOppMissCheck:Int = 0;
	var curEnemyNote:Int = 0;

	private function enemyNoteMiss(noteDirection, isSustain:Bool = false, ?curEnemyNoteCheck:Int = 0):Void
	{
		singFollowOffset = [0, 0];
		miscs.volume = 0;
		if ((!dad.animation.curAnim.name.startsWith("sing") || dad.animation.curAnim.curFrame >= 2) && (dad.animation.curAnim.name != "gunSHOOT" && !dad.animation.curAnim.name.startsWith("cheer") || dad.animation.curAnim.curFrame >= 3) && (dad.animation.curAnim.name != "gunLOAD" || dad.animation.curAnim.finished))
			dad.playAnim('sing' + noteDirection + "miss", true);

		if (!isSustain)
		{
			if(FlxG.save.data.missSounds)
			{
				//Unsure if I should put this in a sound group or not lol :3
				FlxG.sound.play(Paths.soundRandom('enemyMiss', 1, 3), FlxG.random.float(0.15, 0.2), missSoundGroup);
			}
			
			if (healthBar.percent < 85)
				targetHealth += calculateHealth(10, targetHealth, accuracy);
		}
		else
		{
			if (curEnemyNote == curEnemyNoteCheck)
			{	
				if (healthBar.percent < 85)
				{
					if (!isSustain)
						targetHealth -= calculateHealth(10, targetHealth, accuracy) * 2;
					else
						targetHealth -= calculateHealth(11, targetHealth, accuracy) * 2;
				}
			}
		}
		dad.holdTimer = 0;
	}

	//Making this void (4)
	function updateAccuracy(?amt:Float = 0):Void
	{
		totalNotesHit += amt;
		totalPlayed += 1;
		//totalNotesHitMax = totalPlayed;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
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
				drums = FlxG.sound.play(Paths.musicRandom('finaleAdaptiveMus/drums_', 0, 1, 'week2'), 1, false, musicGroup);
				taiko = FlxG.sound.play(Paths.musicRandom('finaleAdaptiveMus/taiko_', 0, 2, 'week2'), 1, false, musicGroup);
				taiko.time = drums.time;
				//trace("Le Drummos");
			}
			else if (dangerLevel >= 50 && enemyHealth > 30)
			{
				drums = FlxG.sound.play(Paths.musicRandom('finaleAdaptiveMus/drums_', 2, 3, 'week2'), 1, false, musicGroup);
				taiko = FlxG.sound.play(Paths.musicRandom('finaleAdaptiveMus/taiko_', 0, 5, 'week2'), 1, false, musicGroup);
				taiko.time = drums.time;
				//trace("Le Drummos but Epico");
			}
			else
			{
				drums = FlxG.sound.play(Paths.music('finaleAdaptiveMus/drums_climax', 'week2'), 1, false, musicGroup);
				taiko = FlxG.sound.play(Paths.musicRandom('finaleAdaptiveMus/taiko_', 4, 5, 'week2'), 1, false, musicGroup);
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
				choir = FlxG.sound.play(Paths.music('finaleAdaptiveMus/choir_0', 'week2'), 1, false, musicGroup);
				hats = FlxG.sound.play(Paths.music('finaleAdaptiveMus/hats_0', 'week2'), 1, false, musicGroup);
				if (!isBFTurn)
					adders = FlxG.sound.play(Paths.music('finaleAdaptiveMus/woodwinds', 'week2'), 1, false, musicGroup);
			}
			else if (dangerLevel >= 50 && enemyHealth > 30)
			{
				adders.stop();
				choir = FlxG.sound.play(Paths.music('finaleAdaptiveMus/choir_1', 'week2'), 1, false, musicGroup);
				hats = FlxG.sound.play(Paths.music('finaleAdaptiveMus/hats_1', 'week2'), 1, false, musicGroup);
				adders = FlxG.sound.play(Paths.music('finaleAdaptiveMus/violin', 'week2'), 1, false, musicGroup);
			}
			else
			{
				adders.stop();
				pads.stop();
				choir = FlxG.sound.play(Paths.music('finaleAdaptiveMus/choir_1', 'week2'), 1, false, musicGroup);
				hats = FlxG.sound.play(Paths.music('finaleAdaptiveMus/hats_1', 'week2'), 1, false, musicGroup);
				adders = FlxG.sound.play(Paths.music('finaleAdaptiveMus/elecpiano_climax', 'week2'), 1, false, musicGroup);
				pads = FlxG.sound.play(Paths.music('finaleAdaptiveMus/pads_climax', 'week2'), 1, false, musicGroup);
			}

			if (dangerLevel < 50 && enemyHealth > 30 && !isBFTurn)
				slayer = FlxG.sound.play(Paths.music('finaleAdaptiveMus/slayer_0', 'week2'), 1, false, musicGroup);
			else if (dangerLevel < 50 && enemyHealth > 30 && !isBFTurn)
			{
				slayer = FlxG.sound.play(Paths.music('finaleAdaptiveMus/slayer_1', 'week2'), 1, false, musicGroup);
				//if (dangerLevel < 50)
				//	dangerLevel = 50;
			}
			else if (enemyHealth <= 30)
			{
				slayer.stop();
				slayer = FlxG.sound.play(Paths.music('finaleAdaptiveMus/slayer_climax', 'week2'), 1, false, musicGroup);
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
			FlxG.sound.play(Paths.music('finaleAdaptiveMus/stab', 'week2'), 0.9, false, musicGroup);
			if (dangerLevel < 50 && !isBFTurn)
				retalHats = FlxG.sound.play(Paths.music('finaleAdaptiveMus/retal-hats_0', 'week2'), 1, false, musicGroup);
			else if (dangerLevel < 50 && !isBFTurn)
				retalHats = FlxG.sound.play(Paths.music('finaleAdaptiveMus/retal-hats_1', 'week2'), 1, false, musicGroup);
			else
				retalHats = FlxG.sound.play(Paths.music('finaleAdaptiveMus/retal-hats_0', 'week2'), 1, false, musicGroup);
		}
		//Bells, and Pads
		if (curBeat % 64 == 32)
		{
			if (dangerLevel < 50)
			{
				bells.stop();
				bells = FlxG.sound.play(Paths.music('finaleAdaptiveMus/bells_0', 'week2'), 1, false, musicGroup);
				if (!isBFTurn && FlxG.random.bool(50))
					pads = FlxG.sound.play(Paths.music('finaleAdaptiveMus/pads_0', 'week2'), 1, false, musicGroup);
			}
			else if (enemyHealth > 30)
			{
				if (FlxG.random.bool(75))
				{
					bells.stop();
					bells = FlxG.sound.play(Paths.music('finaleAdaptiveMus/bells_1', 'week2'), 1, false, musicGroup);
				}
				pads = FlxG.sound.play(Paths.music('finaleAdaptiveMus/pads_1', 'week2'), 1, false, musicGroup);
			}
			else
			{
				bells.stop();
				bells = FlxG.sound.play(Paths.music('finaleAdaptiveMus/bells_1', 'week2'), 1, false, musicGroup);
			}
		}
		if (curBeat % 128 == 0)
		{
			danger.stop();
			danger = FlxG.sound.play(Paths.music('finaleAdaptiveMus/danger-loop', 'week2'), 0, false, musicGroup);
		}
	}

	//Making this void (5)
	function playNoteHitSound(note:Note):Void
	{
		if (!note.isSustainNote)
		{
			var rating = note.rating;
			//	SFX for hitting notes (such as SICK, GOOD, BAD, SHIT, and SPECIAL NOTEs);
			if (!PlayStateChangeables.botPlay && !note.withinCompensation)
			{
				//Converted from nested if-else statements and 2 switch statements to a one switch! You're welcome!
				switch (rating)
				{
					case 'sick':
						//For Sick Rating
						if (noteHitSFX.playing)
							noteHitSFX.stop();
						noteHitSFX = FlxG.sound.load(Paths.sound("Note_" + hitsoundType + "_Sick"), false, noteHitSFXGroup);
						//Vocal Shit
						vocals.volume = vocalsVolume;

					case 'good':
						if (noteHitSFX.playing)
							noteHitSFX.stop();
						//For Good Rating
						noteHitSFX = FlxG.sound.load(Paths.sound("Note_" + hitsoundType + "_Good"), false, noteHitSFXGroup);
						//Vocal Shit
						vocals.volume = vocalsVolume * 0.85;

					case 'bad':
						if (noteHitSFX.playing)
							noteHitSFX.stop();
						//For Bad Rating
						noteHitSFX = FlxG.sound.load(Paths.sound("Note_" + hitsoundType + "_Bad"), false, noteHitSFXGroup);
						//Vocal Shit
						vocals.volume = vocalsVolume * 0.55;

					case 'shit':
						if (noteHitSFX.playing)
							noteHitSFX.stop();
						//For Shit Rating
						if (allowHealthModifiers && !note.withinCompensation)
							noteHitSFX = FlxG.sound.load(Paths.sound("Note_" + hitsoundType + "_Crap"), false, noteHitSFXGroup);
						else
							noteHitSFX = FlxG.sound.load(Paths.sound("Note_" + hitsoundType + "_Bad"), false, noteHitSFXGroup);
						//Vocal Shit
						//if (FlxG.save.data.shitBreaksCombo)
						vocals.volume = vocalsVolume * 0.1;
						//else
							//vocals.volume = vocalsVolume * 0.55;

					case 'miss':
						//For Miss Rating
						//Vocal Shit
						vocals.volume = 0;
				}
				noteHitSFX.play();
			}
			else
			{
				if (noteHitSFX.playing)
					noteHitSFX.stop();
				noteHitSFX = FlxG.sound.load(Paths.sound("Note_botplay"), false, noteHitSFXGroup);
				noteHitSFX.play();
				vocals.volume = vocalsVolume;
			}
		}
		else if (!PlayStateChangeables.botPlay)
		{
			if (noteHitSustainSFX.playing)
				noteHitSustainSFX.stop();
			noteHitSustainSFX = FlxG.sound.load(Paths.sound('Note_' + hitsoundType + '_Sustain'), false, noteHitSFXGroup);
			noteHitSustainSFX.play();
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
					vocals.volume = vocalsVolume;
				case 'good':
					//For Good Rating
					//Vocal Shit
					if (!note.isSustainNote)
						vocals.volume = vocalsVolume * 0.85;
				case 'bad':
					//For Bad Rating
					//Vocal Shit
					if (!note.isSustainNote)
						vocals.volume = vocalsVolume * 0.55;
				case 'shit':
					//For Shit Rating
					//Vocal Shit
					if (!note.isSustainNote)
						vocals.volume = vocalsVolume * 0.1;
				case 'miss':
					vocals.volume = 0;
			}
		}
		else if (PlayStateChangeables.botPlay)
			vocals.volume = vocalsVolume;
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
			case "Sudden Confrontation" | "Sprouting Irritation" | "Striking Tribulation":
				//trace ("Enemy miss is " + enemyMissRandomizer);
				if (bypassOppMissCheck < 0)
				{
					bypassOppMissCheck = 0;
					bypassOppMiss = false;
				}
				else if (bypassOppMissCheck > 15 / (storyDifficulty + 1))
					bypassOppMiss = true;

				if (enemyCanFail && !bypassOppMiss && health < 85)
				{
					if (!note.forceMiss && !note.isSustainNote)
					{
						curEnemyNote++;
						if (intimidationBeats <= 0)
						{
							if (!note.isParent)
								enemyMissRandomizer = FlxG.random.bool(accuracy / 4);
							else
							{
								enemyMissRandomizer = FlxG.random.bool(accuracy / 8);
								note.parentID = curEnemyNote;
							}
						}
						else
						{
							enemyMissRandomizer = true;
							if (note.isParent)
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
			trace('force miss returning');
			singFollowOffset = [0, 0];
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
			if (SONG.needsMiscs)
				miscs.volume = vocalsVolume;
			else if (SONG.needsVoices)
				vocals.volume = vocalsVolume;
			switch (SONG.song)
			{
				case "Sudden Confrontation" | "Sprouting Irritation" | "Striking Tribulation":
					//"Enemy Sing" health drain
					if (healthBar.percent >= 25 && allowHealthModifiers && !note.withinCompensation)
					{
						if (!note.isSustainNote)
							targetHealth -= calculateHealth(10, targetHealth, accuracy);
						else
							targetHealth -= calculateHealth(11, targetHealth, accuracy);
					}
			}

			if (!PlayStateChangeables.Optimize)
			{
				//Weird double anim prevention attempt?
				if (((!dad.animation.curAnim.name.startsWith("sing") && !dad.animation.curAnim.name.contains("miss")) || dad.animation.curAnim.curFrame >= 1) && (dad.animation.curAnim.name != "gunSHOOT" && !dad.animation.curAnim.name.startsWith("cheer") || dad.animation.curAnim.curFrame >= 3) && (dad.animation.curAnim.name != "gunLOAD" || dad.animation.curAnim.finished))
					dad.playAnim('sing' + dataSuffix[singData] + altAnim, true);

				if (!isBFTurn && FlxG.save.data.distractions)
				{
					switch (singData)
					{
						case 0:
							//Left
							singFollowOffset = [-5, 1];
						case 1:
							//Down
							singFollowOffset = [-1, 5];
						case 2:
							//Up
							singFollowOffset = [1, -5];
						case 3:
							//Right
							singFollowOffset = [5, -1];
					}
					singFollowOffset[0] *= singFollowMultiplier;
					singFollowOffset[1] *= singFollowMultiplier;

					singFollowOffset[0] /= camGame.zoom;
					singFollowOffset[1] /= camGame.zoom;
				}
			}

			if (FlxG.save.data.cpuStrums)
			{
				cpuStrums.forEach(function(spr:FlxSprite)
				{
					if (note.noteData == spr.ID)
					{
						spr.animation.play('confirm', true);
						spr.centerOffsets();
						spr.offset.x -= 13;
						spr.offset.y -= 13;
					}
				});
			}

			dad.holdTimer = 0;

			//trace ("OK NOW enemy miss is " + enemyMissRandomizer);
			//note.finnaBeKilled = true

			//trace('deleted nenemy note. The fucker missed = ' + enemyMissRandomizer);
			//OK so it aint deleting the note, find out why.
		}

		if (!note.forceMiss && !note.isSustainNote || (!note.isOnScreen(camHUD) && note.tooLate))
		{
			note.active = false;
			note.kill();
			notes.remove(note, true);
			note.destroy();
		}
		else if (note.isSustainNote)
			note.enabled = false;
	}

	var sustainSoundBool:Bool = false; //reduction of the amount of sounds the sustainnotes play

	function goodNoteHit(note:Note, ?isJack:Bool = false):Void
	{
		//double-count prevention
		if (!note.wasGoodHit)
		{
			if (accuracy > 50 || causeOfDeath != 'note-spam')
				causeOfDeath = '';

			// Accessing the animation name directly to play it
			var singData:Int = Std.int(note.noteData);

			if (note.mustPress && note.noteType != 'mine')
				note.wasGoodHit = true;

			var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

			if (note.rating == "miss")
				return;

			//NOTE RATING CALCULATIONS
			if (!note.isSustainNote)
			{
				note.rating = Ratings.CalculateRating(noteDiff);
				for (i in note.children)
				{
					i.tempRating = note.rating;
				}
			}
			else
				note.rating = note.tempRating;

			// add newest note to front of notesHitArray
			// the oldest notes are at the end and are removed first
			if (!note.isSustainNote)
			{
				if (note.noteType != 'mine')
				{
					if (note.rating != 'shit')
					{
						notesHitInSection++;
						mashPressThreshold++;
						combo++;
						nonSustainCombo++;
					}
					notesHitArray.unshift(Date.now());
					popUpScore('', note, noteDiff, isJack);
					//trace('goodnotehit nonsustain popupscore');
				}
				else if (FlxG.save.data.notesplash && !PlayStateChangeables.botPlay && allowHealthModifiers && !note.withinCompensation)
					sploshThisShitUp(note, note.rating);

				note.startSpeeding = false;
				note.missAdditiveY = 0;
				if (note.isParent)
				{
					for (i in note.children)
					{
						i.startSpeeding = false;
						i.missAdditiveY = 0;
					}
				}
			}
			else
			{
				for (i in note.parent.children)
				{
					i.startSpeeding = false;
					i.missAdditiveY = 0;
				}

				//sustain combo cuz why not :3
				if (!note.isBehindParent && note.rating != 'shit' && note.tempRating != 'shit')
					combo++;

				//Experimental showing your numbers for sustain notes
				//It works so we keepin it >:33
				popUpScore('sustain', note, noteDiff);
				//trace('goodnotehit sustain popupscore');

				//Health Gain for Sustain
				if (allowHealthModifiers)
					targetHealth += !mashing ? calculateHealth(8, targetHealth, accuracy) : calculateHealth(8, targetHealth, accuracy) / 4;
				//trace (note.rating);
				songScore += calculateScore(note.rating, note.isSustainNote);
				maxSongScore += calculateScore('sick', note.isSustainNote);
				vocals.volume = vocalsVolume;
			}

			switch (note.noteType)
			{
				case 'mine':
					if (!PlayStateChangeables.botPlay)
					{
						if (!note.isSustainNote)
							getFuckingShot();
					}
					else
					{
						note.forceMiss = true;
						return;
					}
				case 'trigger':
					dodgeFuckingShot(note.noteData);
					if (timesShot > 0 && note.rating == 'sick')
						timesShot--;
					targetHealth += calculateHealth(12, targetHealth, accuracy);
				default:
					if (allowNoteHitSounds && FlxG.save.data.notesfx)
						playNoteHitSound(note);
					else
						adjustVocVolOnNoteHit(note);	

					if (!midsongCutscene && !PlayStateChangeables.Optimize)
					{
						if (boyfriend.animation.curAnim.name != 'hey' || boyfriend.animation.curAnim.curFrame >= 5)
						{
							//Weird double anim prevention attempt?
							if ((!boyfriend.animation.curAnim.name.startsWith("sing") && !boyfriend.animation.curAnim.name.contains("miss")) || boyfriend.animation.curAnim.curFrame >= 1)
								boyfriend.playAnim('sing' + dataSuffix[singData], true);
							if (isBFTurn && FlxG.save.data.distractions)
							{
								switch (singData)
								{
									case 0:
										//Left
										singFollowOffset = [-10, -2];
									case 1:
										//Down
										singFollowOffset = [2, 10];
									case 2:
										//Up
										singFollowOffset = [-2, -10];
									case 3:
										//Right
										singFollowOffset = [10, 2];
								}

								singFollowOffset[0] *= singFollowMultiplier;
								singFollowOffset[1] *= singFollowMultiplier;

								singFollowOffset[0] /= camGame.zoom;
								singFollowOffset[1] /= camGame.zoom;
							}
						}
					}
			}

			if (note.mustPress)
			{
				var array = [note.strumTime, note.sustainLength, note.noteData, noteDiff];
				if (note.isSustainNote)
					array[1] = -1;
			}

			if (note.noteType != 'mine')
			{
				playerStrums.forEach(function(spr:FlxSprite)
				{
					if (note.noteData == spr.ID)
					{
						spr.animation.play('confirm', true);
						preventBFIdleAnim = true;
					}
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

			//if (allowHealthModifiers && !note.withinCompensation)
				//updateAccuracy();
		}
	}

	function pauseGame():Void
	{
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if (FlxG.sound.music != null)
			FlxG.sound.music.pause();

		musicGroup.pause();
		vocals.pause();
		miscs.pause();

		switch (curSong)
		{
			case "Desperation" | "Disagreement" | "Retaliation":
				if (!startedCountdown && songStarted)
					if (stageSound != null && stageSound.playing)
						stageSound.pause();
		}

		// 5 / 1000 chance for Gitaroo Man easter egg
		//debating if i should remove this or not
		if (!FlxG.random.bool(0.5))
		{
			if (!PlayStateChangeables.Optimize)
				openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			else
				openSubState(new PauseSubState(770, 450));
		}
		else
			openSubState(new GitarooPause());	
	}

	var resetButtonFailSafe:Int = 0;
	var resetButtonTimer:FlxTimer;
	var resetText:FlxText;
	var resetTextTwn:FlxTween;

	function literallyFuckingDie():Void
	{
		if (songStarted)
		{
			vocals.stop();
			miscs.stop();
			musicGroup.stop();
		}
		
		if (resetTextTwn != null)
			resetTextTwn.cancel();

		if (startTimer != null && !startTimer.finished)
			startTimer.active = false;

		if (causeOfDeath == '')
			causeOfDeath = 'skill-issue';

		camGame.stopFX();
		camHUD.stopFX();

		//specilNoteHitSFXGroup.volume *= 0.65;

		if (!PlayStateChangeables.Optimize)
			boyfriend.stunned = true;
		prevHealth = 1;

		persistentUpdate = false;
		persistentDraw = false;
		paused = true;
		died = true;

		campaignDeaths++;
		songDeaths++;
		hasReset = true;

		if (!PlayStateChangeables.Optimize)
			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		else
			openSubState(new GameOverSubstate(FlxG.width / 2 - 100, FlxG.height / 3));
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
	var sectionBool:Bool = false;

	private function sectionHit()
	{
		sectionBool = !sectionBool;
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

		singFollowOffset = [0, 0];

		if (isBFTurn)
		{
			if (curSong == 'Mic Test' && !PlayStateChangeables.Optimize && generatedSong)
			{
				if (camTween != null)
					camTween.cancel();
				camTween = FlxTween.tween(camGame, {zoom: 1.2}, (Conductor.crochet / 1000), {type: ONESHOT, ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						camTween = null;
					}
				});
			}
		}
		else
		{
			if (curSong == 'Mic Test' && !PlayStateChangeables.Optimize && generatedSong)
			{
				if (camTween != null)
					camTween.cancel();
				camTween = FlxTween.tween(camGame, {zoom: 1.5}, (Conductor.crochet / 1000), {type: ONESHOT, ease: FlxEase.elasticInOut, onComplete:
					function (twn:FlxTween)
					{
						camTween = null;
					}
				});
			}
		}
	}

	override function stepHit()
	{
		super.stepHit();

		//nudging the player to win to avoid frustration
		if (healthBar.percent < 50 && normalPityDeaths - storyDifficulty > 0 && targetHealth > 0)
			targetHealth += (normalPityDeaths * 0.00025);

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
					strumLineBGTween = FlxTween.tween(grpStrumLine, {alpha: 0.6}, (Conductor.stepCrochet / 1000), {type: ONESHOT, ease: FlxEase.smootherStepOut, onComplete:
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
					strumLineBGTween = FlxTween.tween(grpStrumLine, {alpha: 0.4}, Conductor.crochet * 2 / 1000, {type: ONESHOT, ease: FlxEase.quadOut, startDelay: Conductor.crochet * 2 / 1000, onComplete:
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
		if (!skippingIntro && Math.abs(FlxG.sound.music.time - (Conductor.songPosition)) > 20
		|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition)) > 20))
		{
			if (!showedResults && !inCutscene && generatedSong && songStarted && !endedSong)
				resyncVocals();
		}

		if (SONG.notes[Std.int(curStep / 16)] != null && generatedSong)
		{
			if (SONG.notes[Std.int(curStep / 16)].mustHitSection)
			{
				isBFTurn = true;
				//if the var 'sectionBool' is off, it switches it on and does the function once
				if (!sectionBool)
					sectionHit();
			}
			else
			{
				isBFTurn = false;
				//vice versa for this one
				if (sectionBool)
					sectionHit();
			}
			
			// Make sure Girlfriend cheers only for certain songs
			if (!showedResults && !endedSong)
			{
				// Per song treatment since some songs will only have the 'Hey' at certain times
				switch (curSong)
				{
					case 'Tech. Difficulties':
						// General duration of the song
						if(curBeat < 280 && !PlayStateChangeables.Optimize)
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
						if(curBeat < 410 && !PlayStateChangeables.Optimize)
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
							if (!inSongClimax && normalPityDeaths < 1)
								targetHealth -= 0.001 * (storyDifficulty + 1); 
							else if (inSongClimax && normalPityDeaths < 5)
								targetHealth -= 0.005 * (storyDifficulty + 1); 
						}
				}
			}
			
			//camFollowShit();

			// yes this updates every ~~step~~ beat.
			// yes this is bad (but less bad compared to updating every step)
			// but i'm doing it to update misses and accuracy (bro it's discord, nobody would mind)
			//I have learned why it needs to be every step, I have reverted this change.
			#if windows
			// Updating Discord Rich Presence (with Time Left)
			if (FlxG.save.data.showPresence && !paused && !showedResults && !endedSong)
			{
				DiscordClient.changePresence(detailsText
					+ SONG.song + " (" + storyDifficultyText + ")",
					"Score: " + songScore
					+ " | RIPs: " + (misses + slips)
					+ " | Rating: " + Ratings.GenerateLetterRank(accuracy) + " (" + HelperFunctions.truncateFloat(accuracy, 2)
					+ "%)");
			}
			#end
		}
		//camFollowShit();
		//DC.endProfile("stepShit");
	}

	var isBFTurn:Bool = false;

	//Removed from void, does this fix doCamFollowing?
	//No
	//bro it's the charts
	function camFollowShit():Void
	{	
		if (SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (doCamFollowing)
			{
				if (!isBFTurn && camFollow.x != (dad.getMidpoint().x + 150 + dadFollowOffset[0]) + singFollowOffset[0] && camFollow.y != (dad.getMidpoint().y - 100 + dadFollowOffset[1]) + singFollowOffset[1])
					camFollow.setPosition((dad.getMidpoint().x + 150 + dadFollowOffset[0]) + singFollowOffset[0], (dad.getMidpoint().y - 100 + dadFollowOffset[1]) + singFollowOffset[1]);
				else if (isBFTurn && camFollow.x != (boyfriend.getMidpoint().x - 100 + bfFollowOffset[0]) + singFollowOffset[0] && camFollow.y != (boyfriend.getMidpoint().y - 100 + bfFollowOffset[1]) + singFollowOffset[1])
					camFollow.setPosition((boyfriend.getMidpoint().x - 100 + bfFollowOffset[0]) + singFollowOffset[0], (boyfriend.getMidpoint().y - 100 + bfFollowOffset[1]) + singFollowOffset[1]);
			}
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;
	var lowHPEffectVol:Float = 0;
	var tutorialTweenArray:Array<FlxTween> = [];
	var TutorialTipTwn:FlxTween;		

	function doSubtitleShit():Void
	{
		if (hasSubtitles && FlxG.save.data.subtitles && songStarted)
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
							if (!preventTutorialTips)
							{
								
								var TutorialTipTwn = FlxTween.tween(tutorialGraphicA, {alpha: 1}, 0.3, {type: ONESHOT, ease: FlxEase.smoothStepOut, onComplete: function(twn:FlxTween){TutorialTipTwn = null;}});
								tutorialTweenArray.push(TutorialTipTwn);
								tutorialText.forEach(function(text:FlxSprite)
								{
									var Twn:FlxTween;
									Twn = FlxTween.tween(text, {alpha: 1}, 0.35, {type: ONESHOT, ease: FlxEase.smoothStepOut, onComplete: function(twn:FlxTween){tutorialTweenArray.remove(Twn);}});
									tutorialTweenArray.push(Twn);
								});
							}
						case 20:
							if (!preventTutorialTips)
							{
								TutorialTipTwn = FlxTween.tween(tutorialGraphicA, {alpha: 0}, 0.5, {type: ONESHOT, ease: FlxEase.smoothStepOut,
									onComplete: function(twn:FlxTween)
									{
										TutorialTipTwn = null;
										if (tutorialGraphicA != null)
											tutorialGraphicA.destroy();
									}
								});

								if (tutorialText != null)
								{
									tutorialText.forEachAlive(function(text:FlxSprite)
									{
										var Twn:FlxTween;
										Twn = FlxTween.tween(text, {alpha: 0}, 0.5, {type: ONESHOT, ease: FlxEase.smoothStepOut, onComplete:
											function(twn:FlxTween)
											{
												tutorialTweenArray.remove(Twn);
												text.kill();
												text.destroy();
												//FlxG.log.add('this might cause a crash ermm ermmm');
												if (tutorialText != null)
													tutorialText.destroy();
											}
										});
										tutorialTweenArray.push(Twn);
									});
								}
							}
						case 22:
							changeSubtitles("Ok, here we go.", 0xFFfff300);
						case 24:
							clearSubtitles();
							if (!preventTutorialTips)
								TutorialTipTwn = FlxTween.tween(tutorialGraphicB, {alpha: 1}, 0.3, {type: ONESHOT, ease: FlxEase.smoothStepOut, onComplete: function(twn:FlxTween){TutorialTipTwn = null;}});
						case 39:
							if (!preventTutorialTips)
							{
								TutorialTipTwn = FlxTween.tween(tutorialGraphicB, {alpha: 0}, 0.5, {type: ONESHOT, ease: FlxEase.smoothStepOut,
									onComplete: function(twn:FlxTween)
									{
										TutorialTipTwn = null;
										if (tutorialGraphicB != null)
											tutorialGraphicB.destroy();
									}
								});
							}
						case 40:
							if (!preventTutorialTips)
								TutorialTipTwn = FlxTween.tween(tutorialGraphicC, {alpha: 1}, 0.3, {type: ONESHOT, ease: FlxEase.smoothStepOut, onComplete: function(twn:FlxTween){TutorialTipTwn = null;}});
						case 52:
							if (!preventTutorialTips)
							{
								TutorialTipTwn = FlxTween.tween(tutorialGraphicC, {alpha: 0}, 0.5, {type: ONESHOT, ease: FlxEase.smoothStepOut,
									onComplete: function(twn:FlxTween)
									{
										TutorialTipTwn = null;
										tutorialTweenArray.remove(TutorialTipTwn);
										if (tutorialGraphicC != null)
											tutorialGraphicC.destroy();
									}
								});
							}
						case 53:
							changeSubtitles("Ok, do as I say!", 0xFFfff300);
						case 56:
							changeSubtitles("Left,", 0xFFfff300);
						case 58:
							changeSubtitles("Left, Right.", 0xFFfff300);
						case 59:
							changeSubtitles("Everyone, left", 0xFFfff300);
						case 61:
							changeSubtitles("Everyone, right!", 0xFFfff300);
						case 64:
							clearSubtitles();
						case 70:
							if (vocals.volume > 0.5)
								changeSubtitles("Good job!", 0xFFfff300);
						case 72:
							if (PlayStateChangeables.Optimize)
								vocals.volume = 1;
							changeSubtitles("Up,", 0xFFfff300);
						case 74:
							changeSubtitles("Up, Down.", 0xFFfff300);
						case 75:
							changeSubtitles("Everyone, up", 0xFFfff300);
						case 77:
							changeSubtitles("Everyone, down!", 0xFFfff300);
						case 80:
							clearSubtitles();
						case 86:
							if (vocals.volume > 0.5)
								changeSubtitles("Yes, good job!", 0xFFfff300);
						case 88:
							if (PlayStateChangeables.Optimize)
								vocals.volume = 1;
							changeSubtitles("Left,", 0xFFfff300);
						case 90:
							changeSubtitles("Left, Up.", 0xFFfff300);
						case 91:
							changeSubtitles("Everyone, down", 0xFFfff300);
						case 93:
							changeSubtitles("Everyone, right!", 0xFFfff300);
						case 96:
							clearSubtitles();
						case 102:
							if (vocals.volume > 0.5)
								changeSubtitles("That's how you do it!", 0xFFfff300);
						case 104:
							vocals.volume = 1;
							changeSubtitles("Right,", 0xFFfff300);
						case 106:
							changeSubtitles("Right, Down.", 0xFFfff300);
						case 107:
							changeSubtitles("Everyone, left", 0xFFfff300);
						case 109:
							changeSubtitles("Everyone, up!", 0xFFfff300);
						case 112:
							clearSubtitles();
						case 118:
							vocals.volume = 1;
							changeSubtitles("Now, free-style it!", 0xFFfff300);
						case 120:
							clearSubtitles();
						case 150:
							vocals.volume = 1;
							changeSubtitles("Ok, here we go-", 0xFFfff300);
						case 152:
							vocals.volume = 1;
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
							if (vocals.volume > 0.5)
								changeSubtitles("That's how you do it, good job!", 0xFFfff300);
						case 184:
							vocals.volume = 1;
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
							if (vocals.volume > 0.5)
								changeSubtitles("That's how you do it!", 0xFFfff300);
						case 214:
							if (PlayStateChangeables.Optimize)
								vocals.volume = 1;
							changeSubtitles("Ok here we go.", 0xFFfff300);
						case 216:
							clearSubtitles();
						case 278:
							if (vocals.volume > 0.5)
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
							changeSubtitles("[Speaking in tounges]", 0xff9feea4);
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
							changeSubtitles("[Speaking in tounges]", 0xff9feea4);
						case 68:
							clearSubtitles();
						case 96:
							changeSubtitles("[Speaking in tounges]", 0xff9feea4);
						case 100:
							clearSubtitles();
						case 128:
							changeSubtitles("Lord, please help us!", 0xFF5ce766);
						case 132:
							changeSubtitles("Oh Lord, please help us!", 0xFF5ce766);
						case 136:
							changeSubtitles("Lord, Lord, please help us!", 0xFF5ce766);
						case 140:
							changeSubtitles("[Speaking in tounges]", 0xff9feea4);
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
							changeSubtitles("(that's a little...)", 0xFF4adaff);
						case 188:
							changeSubtitles("(that's a little much for me-)", 0xFF4adaff);
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
							changeSubtitles("(that's part's outside my capabilities-)", 0xFF4adaff);
						case 224:
							changeSubtitles("OH, HELP 'US'.", 0xFF5ce766);
						case 228:
							changeSubtitles("LORD. PLEASE. HELP. 'US'.", 0xFF5ce766);
						case 232:
							changeSubtitles("LORD. 'PLEASE'. HELP. 'US'.", 0xFF5ce766);
						case 236:
							changeSubtitles("PLEASE LORD HELP 'US', OH.", 0xFF5ce766);
						case 240:
							changeSubtitles("(Please just listen-)", 0xFF4adaff);
						case 244:
							changeSubtitles("(I didn't mean to offend you.)", 0xFF4adaff);
						case 248:
							changeSubtitles("(Honestly I don't know)", 0xFF4adaff);
						case 252:
							changeSubtitles("{how I can help you-}", 0xFF4adaff);	
						case 255:
							subtitleTimer = new FlxTimer().start(0.1, function(tmr:FlxTimer)
							{
								changeSubtitles("(uh-)", 0xFF4adaff);
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
							changeSubtitles("(You just like watching me sink.)", 0xFF4adaff, FlxColor.BLACK, NORMAL, 0.5);
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
							vocals.volume = vocalsVolume;
							subtitleTimer = new FlxTimer().start(0.176, function(tmr:FlxTimer)
							{
								subtitleText.alpha = 1;
								subtitleBackground.alpha = 0.45;
								changeSubtitles("YOU", 0xFF5ce766);
							});
							//Priest: You--
						case 305:
							//Priest: --can't
							vocals.volume = vocalsVolume;
							changeSubtitles("YOU CAN'T", 0xFF5ce766);
						case 306:
							//Priest: --sing!
							vocals.volume = vocalsVolume;
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

	private function calculateScore(daRating:String, isSus:Bool = false):Int
    {
        switch(daRating)
		{
			case 'miss':
				if (!isSus)
					return -300;
				else
					return -100;
			case 'shit':
				if (!isSus)
					return -150;
				else
					return -50;
			case 'bad':
				if (!isSus)
					return 50;
				else
					return 0;
			case 'good':
				if (!isSus)
					return 200;
				else
					return 50;
			case 'sick':
				if (!isSus)
					return 350;
				else
					return 150;
		}
        return 0;
    }

    private function calculateHealth(hpDrainType:Int, ?health:Float = 1, ?accuracy:Float = 90, ?externalValue:Float = 0):Float
    {
        var feedbackHealth:Float = 0.00;
        switch (hpDrainType)
        {
            //Health Drain for Non-Sustain
            case 0:
                //trace ('Non Sus Loss');
                switch (storyDifficulty)
                {
                    case 0:
                        if (health <= 0.25)
                            feedbackHealth = -0.1;
                        else
                            feedbackHealth = -0.175;
                    case 1:
                        if (health <= 0.25)
                            feedbackHealth = -0.125;
                        else
                            feedbackHealth = -0.2;
                    default:
                        if (health <= 0.25)
                            feedbackHealth = -0.15;
                        else
                            feedbackHealth = -0.225;
                }
            //Heath Drain for Sustain Parent
            case 1:
                //trace ('Sus Parent Loss');
                switch (storyDifficulty)
                {
                    case 0:
                        if (health <= 0.25)
                            feedbackHealth = -0.175;
                        else
                            feedbackHealth = -0.25;
                    case 1:
                        if (health <= 0.25)
                            feedbackHealth = -0.2;
                        else
                            feedbackHealth = -0.275;
                    default:
                        if (health <= 0.25)
                            feedbackHealth = -0.225;
                        else
                            feedbackHealth = -0.3;
                }
            //Health Drain for Sustain Initial Slip
            case 2:
                //trace ('Sus Init Slip Loss');
                switch (storyDifficulty)
                {
                    case 0:
                        if (health <= 0.35)
                            feedbackHealth = -0.025;
                        else
                            feedbackHealth = -0.05;
                    case 1:
                        if (health <= 0.35)
                            feedbackHealth = -0.05;
                        else
                            feedbackHealth = -0.075;
                    default:
                        if (health <= 0.35)
                            feedbackHealth = -0.075;
                        else
                            feedbackHealth = -0.1;
                }
            //Health Drain for Sustain Children
            case 3:
                //trace ('Sus Hold Loss');
                switch (storyDifficulty)
                {
                    case 0:
                        if (health > 0.35)
                            feedbackHealth = -0.025;
                    case 1:
                        if (health <= 0.35)
                            feedbackHealth = -0.025;
                        else
                            feedbackHealth = -0.035;
                    default:
                        if (health <= 0.35)
                            feedbackHealth = -0.035;
                        else
                            feedbackHealth = -0.05;
                }
            //Shit Rating
            case 4:
                //trace ('Shit Loss');
                switch (storyDifficulty)
                {
                    case 0:
                        if (accuracy < 50)
                            feedbackHealth = -0.075;
                        else
                            feedbackHealth = -0.025;
                    case 1:
                        if (accuracy < 60)
                            feedbackHealth = -0.08;
                        else
                            feedbackHealth = -0.05;
                    default:
                        if (accuracy < 70)
                            feedbackHealth = -0.1;
                        else
                            feedbackHealth = -0.08;
                }
            //Bad Rating
            case 5:
                //trace ('Bad Loss');
                switch (storyDifficulty)
                {
                    case 0:
                        if (accuracy < 50)
                            feedbackHealth = -0.04;
                        else
                            feedbackHealth = -0.03;
                    case 1:
                        if (accuracy < 60)
                            feedbackHealth = -0.06;
                        else
                            feedbackHealth = -0.045;
                    default:
                        if (accuracy < 70)
                            feedbackHealth = -0.08;
                        else
                            feedbackHealth = -0.06;
                }
            //Good Rating
            case 6:
                //trace ('Good Gain');
                switch (storyDifficulty)
                {
                    case 0:
                        if (health < 0.7 && accuracy > 50)
                            feedbackHealth = 0.07;
                        else if (accuracy < 50)
                            feedbackHealth = -0.05;
                    case 1:
                        if (health < 0.7 && accuracy > 60)
                            feedbackHealth = 0.05;
                        else if (accuracy < 60)
                            feedbackHealth = -0.03;
                    default:
                        if (health < 0.7 && accuracy > 70)
                            feedbackHealth = 0.03;
                        else if (accuracy < 70)
                            feedbackHealth = -0.01;
                }
            //Sick Rating
            case 7:
                //trace ('Sick Gain');
				switch (storyDifficulty)
				{
					case 0:
						if (health < 0.7 && accuracy > 50)
							feedbackHealth = 0.09;
						else if (externalValue > 0 && accuracy > 20)
							feedbackHealth = 0.055;
						else
							feedbackHealth = 0.075;
					case 1:
						if (health < 0.7 && accuracy > 60)
							feedbackHealth = 0.075;
						else if (externalValue > 0 && accuracy > 35)
							feedbackHealth = 0.045;
						else
							feedbackHealth = 0.060;
					default:
						if (health < 0.7 && accuracy > 70)
							feedbackHealth = 0.07;
						else if (externalValue > 0 && accuracy > 50)
							feedbackHealth = 0.035;
						else
							feedbackHealth = 0.055;
				}
            //Health Gain for Sustain
            case 8:
                //trace ('Health Gain for Sus');
                switch(storyDifficulty)
                {
                    case 0:
                        if (health < 0.8 && accuracy > 50)
                            feedbackHealth = 0.013;
                        else if (accuracy > 20)
                            feedbackHealth = 0.011;
                    case 1:
                        if (health < 0.8 && accuracy > 60)
                            feedbackHealth = 0.012;
                        else if (accuracy > 35)
                            feedbackHealth = 0.01;
                    default:
                        if (health < 0.8 && accuracy > 70)
                            feedbackHealth = 0.011;
                        else if (accuracy > 50)
                            feedbackHealth = 0.009;
                }
            //Health Penalty for note mashing
            case 9:
				causeOfDeath = 'note-spam';
                feedbackHealth = ((storyDifficulty + 1) / accuracy) * 0.125;
            //Enemy Sing
            case 10:
                switch (storyDifficulty)
                {
                    case 0:
                        if (health >= 1)
                            feedbackHealth = 0.0175;
                        else 
                            feedbackHealth = 0.015;
                    case 1:
                        if (health >= 1)
                            feedbackHealth = 0.02;
                        else
                            feedbackHealth = 0.0175;
                    default:
                        if (health >= 1)
                            feedbackHealth = 0.025;
                        else
                            feedbackHealth = 0.02;
                }
            //Enemy Sing Sustain
            case 11:
                switch (storyDifficulty)
                {
                    case 0:
                        if (health >= 1)
                            feedbackHealth = 0.01;
                        else 
                            feedbackHealth = 0.008;
                    case 1:
                        if (health >= 1)
                            feedbackHealth = 0.0125;
                        else
                            feedbackHealth = 0.009;
                    default:
                        if (health >= 1)
                            feedbackHealth = 0.015;
                        else
                            feedbackHealth = 0.01;
                }
            //Trigger Note Health Gain
            case 12:
                if (health < 0.2)
                    feedbackHealth = 0.15;
                if (health < 0.5)
                    feedbackHealth = 0.08;
                else
                    feedbackHealth = 0.03;
            case 13:
                //e
            //Taunt Health Gain
            case 14:
                var styleHitMult:Float = externalValue / 4;
                if (health < 2)
                  feedbackHealth = ((2 - health) / 4) * styleHitMult;
        }
        return feedbackHealth;
    }

	//This is here cuz the coolutil is a little confusing for me :33
	function calculateLerpTime(timeElapsed:Float, durationMultiplier:Float, ?min:Int = 0, ?max:Int = 1):Float
	{
		var returnLerpTime:Float = CoolUtil.boundTo(1 - (timeElapsed * durationMultiplier), min, max);
		return returnLerpTime;
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

	//This one I wrote myself!!
	function swapDadForNewChar(failSafe:String = "", X:Float = -0.32145678, Y:Float = -0.54332179):Void
	{
		if (dad.curCharacter != dadSwaperoo)
		{
			if (dadSwaperoo == "")
			{
				failSafe == dad.curCharacter;
				//#if debug
				trace("NO DAD WAS SPECIFIED! Go check Song Start Events and put a 'dadSwaperoo = [charactername]' there!");
				//#end
			}
			if (failSafe == "")
				failSafe == dadSwaperoo;

			if (X == -0.32145678)
				X = dad.x;
			if (Y == -0.54332179)
				Y = dad.y;

			remove(dad);
			//#if debug
			trace("if you the game crashes and you see this, it means that you did a typo, or the dad replacement you specified doesn't exist!");
			//#end
			dad = new Character(X, Y, failSafe);
			add(dad);
		}
	}
	
	//Ok now these are all psych's again
	public function setSongTime(time:Float, setForConductorToo:Bool = false)
	{
		if(time < 0)
			time = 0;

		musicGroup.pause();
		vocals.pause();
		miscs.pause();

		FlxG.sound.music.pause();
		//dummyBeats = Std.int(time / Conductor.crochet);
		if (setForConductorToo) //Relying on this function to check if it can set the time or not is unreliable - made it a toggleable bool instead
			Conductor.songPosition = time; //mightve forghotten this LMFAO WHOOP MB
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

		changeTime(time);
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
				var particle:PsychEngineFancyStageShit.FancyStageParticle = stageParticles.recycle(PsychEngineFancyStageShit.FancyStageParticle);
				particle.initialize(particlePath, currentWeek, particlePercentage, minFileNum, maxFileNum, -400 + width * i + FlxG.random.float(-width / 5, width / 5), (cityStreets.y + 250) - (FlxG.random.float(0, 50)), color, nextColor);
				stageParticles.add(particle);
			}
		}
	}
	//end of psych engine codes

	private function altCamZoom(time:Float = 0, twnType:String = 'smoothStep')
	{
		if (time == 0)
			time = Conductor.crochet * 4 / 1000;
		
		if (camGameZoomTwn != null)
			camGameZoomTwn.cancel();

		if (camHUDZoomTwn != null)
			camHUDZoomTwn.cancel();

		//uidfk how to do function-to-flxtweenoption shit god help me
		switch (twnType)
		{
			case 'expo':
				camGameZoomTwn = FlxTween.tween(camGame, {zoom: defaultCamZoom}, time, {ease: FlxEase.expoOut,
					onComplete: function(twn:FlxTween) 
					{
						camGameZoomTwn = null;
					}
				});
		
				camHUDZoomTwn = FlxTween.tween(camHUD, {zoom: 1}, time, {ease: FlxEase.expoOut,
					onComplete: function(twn:FlxTween) 
					{
						camHUDZoomTwn = null;
					}
				});
			case 'elastic':
				camGameZoomTwn = FlxTween.tween(camGame, {zoom: defaultCamZoom}, time, {ease: FlxEase.elasticOut,
					onComplete: function(twn:FlxTween) 
					{
						camGameZoomTwn = null;
					}
				});
		
				camHUDZoomTwn = FlxTween.tween(camHUD, {zoom: 1}, time, {ease: FlxEase.elasticOut,
					onComplete: function(twn:FlxTween) 
					{
						camHUDZoomTwn = null;
					}
				});

			default:
				camGameZoomTwn = FlxTween.tween(camGame, {zoom: defaultCamZoom}, time, {ease: FlxEase.smoothStepOut,
					onComplete: function(twn:FlxTween) 
					{
						camGameZoomTwn = null;
					}
				});
		
				camHUDZoomTwn = FlxTween.tween(camHUD, {zoom: 1}, time, {ease: FlxEase.smoothStepOut,
					onComplete: function(twn:FlxTween) 
					{
						camHUDZoomTwn = null;
					}
				});
		}
	}
	
	override function beatHit()
	{
		super.beatHit();

		/*if (curBeat == dummyBeats + 1)
			dummyBeats = curBeat;
		else if (curBeat > dummyBeats && curBeat != 0 && curBeat != 1)
		{
			trace ('whoop- gotta catch up!');
			catchUpBeats(Conductor.songPosition, dummyBeats);
			dummyBeats = curBeat;
		}*/

		//DC.beginProfile("beatShit");
		if (generatedSong && !loadingNextSong)
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

			//if (SONG.notes[Std.int(curStep / 16)] != null)
			//{
				//Mid song Events - If statement is added to prevent them from playing in the ResultsScreen
				if (!showedResults)
				{
					//Subtitle shits
					doSubtitleShit();

					if (!PlayStateChangeables.Optimize && FlxG.save.data.distractions)
					{
						switch (curSong)
						{
							case 'Oo Ee Ii Aa Ee':
								switch (curBeat)
								{
									case 1:
										clearSubtitles();
									case 47 | 71 | 79:
										dad.doIdle = false;
										dad.playAnim('cheer', true);
									case 48 | 72 | 80:
										dad.doIdle = true;
									case 63:
										changeSubtitles("Fuck.", 0xffc0c7ff);
									case 64: 
										clearSubtitles();
									case 96:
										dad.doIdle = false;
										doCamFollowing = false;
										camFollow.setPosition(dad.getMidpoint().x, dad.getMidpoint().y);
										dad.playAnim('cheer', true);
										changeSubtitles("ARGH, RED PING!!!", 0xffff0000);
										camShake(true, true, 'camGame', Conductor.crochet * 2 / 1000, 0.05);
										camShake(true, true, 'camHUD', Conductor.crochet * 1 / 1000, 0.025);
									case 98:
										clearSubtitles();
										boyfriend.playAnim('awkward', false);
										camEXT.fade(DisclaimerState.flashColor, Conductor.crochet * 2 / 1000, false);
									case 100:
										camGame.visible = false;
										camHUD.visible = false;
										camEXT.stopFX();
										camEXT.flash(DisclaimerState.flashColor, Conductor.crochet * 2 / 1000);
								}

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
									case 150:
										dad.playAnim('singLEFT-alt', true);
										new FlxTimer().start(0.3, function(tmr:FlxTimer)
										{
											dad.playAnim('singRIGHT-alt', true);
										});
									case 151:
										dad.playAnim('singUP-alt', true);
										new FlxTimer().start(0.3, function(tmr:FlxTimer)
										{
											dad.playAnim('singUP-alt', true);
										});
									case 183:
										if (accuracy > 30)
											boyfriend.playAnim('hey', true);
										else
											boyfriend.playAnim('awkward', true);
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
										camFollowSpeed = 2;
										//doCamFollowing = false;
									case 254:
										dadFollowOffset[0] = -60;
										dadFollowOffset[1] = -60;
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
										if (FlxG.save.data.strumline)
										{
											doStrumLineBGTweening = false;
											grpStrumLine.alpha = 0;
										}
										playerStrums.forEach(function(strumNote:FlxSprite)
										{
											strumNote.alpha = 0;
										});
										camZooming = false;
										camGame.zoom = 0.8;
									case 256:
										camFollowSpeed = 1;
										dadFollowOffset[0] = 0;
										dadFollowOffset[1] = -40;
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
										if (FlxG.save.data.strumline)
										{
											strumLineBGTween = FlxTween.tween(grpStrumLine, {alpha: 0.4}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.quadOut,
											onComplete: function (twn:FlxTween)
											{
												strumLineBGTween = null;
												doStrumLineBGTweening = true;
											}});
										}
										playerStrums.forEach(function(strumNote:FlxSprite)
										{
											FlxTween.tween(strumNote, {alpha: 1}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.quadOut});
										});
										midsongCutscene = false;
										defaultCamZoom = 0.9;
									case 416:
										allowHeartBeatSounds = false;
										camZooming = false;
								}


							case 'Up and Beyond':
								switch (curBeat)
								{
									case 0 | 1:
										camFollowSpeed = 0.5;
									case 32:
										camZooming = true;
										camFollowSpeed = 1;
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
										dadFollowOffset[0] = -70;
										dadFollowOffset[1] = -30;
										camFollowSpeed = 0.5;
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
										stageOverlay1.alpha = 0.65;
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
										midsongCutscene = true;
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
										boyfriend.playAnim('awkward', true);
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
										camZoomUsesTween = true;
									case 207:
										boyfriend.playAnim('singRIGHT', true);
										doCamFollowing = false;
										boyfriend.doIdle = false;
										camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
									case 208:
										boyfriend.playAnim('singLEFTmiss', true);
										defaultCamZoom = 1.3;
									case 212:
										defaultCamZoom = 1.15;
										doCamFollowing = true;
										boyfriend.doIdle = true;
									case 254:
										dad.playAnim('gotPissed', true);
									case 256:
										defaultCamZoom = 0.925;
										camZoomUsesTween = false;
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
										camZoomUsesTween = true;
									case 400:
										dad.doIdle = false;
										defaultCamZoom = 1;
										dadFollowOffset[1] += 10;
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
										stageOverlay1.kill();
										stageOverlay1.destroy();
										dummyBlackScreen.alpha = 1;
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
										camZoomUsesTween = true;
										camFollowSpeed = 1;
										defaultCamZoom = 1;
									case 155:
										camZooming = false;
										doCamFollowing = false;
										camZoomUsesTween = false;
										camGame.zoom -= 1;
										bfFollowOffset[1] -= 40;
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
										objectWiggleShader.waveSpeed = 32;
										objectWiggleShader.waveAmplitude = 0.00125;
										objectTrailShader.blend = ADD;
										objectTrailShader.color = 0xff8080;
										FlxTween.tween(bgBopper, {alpha: 0.65, y: 590 - (bgBopper.height - 80)}, 0.5, {type: ONESHOT, ease: FlxEase.quadOut});
										FlxTween.tween(theBorderBG, {alpha: 0.3}, 0.5, {type: ONESHOT, ease: FlxEase.quadOut});
										dadFollowOffset[1] = 15;
										bfFollowOffset[1] += 20;
										inSongClimax = true;
										singFollowMultiplier = 2;
										if (FlxG.save.data.flashing)
										{
											colourWash.alpha = 0;
											FlxTween.tween(colourWash, {alpha: 0.1}, Conductor.crochet * 4 / 1000, {type: ONESHOT, ease: FlxEase.smootherStepOut});
										}
									case 223:
										FlxTween.tween(bgBopper, {alpha: 0, y: 590}, 1, {type: ONESHOT, ease: FlxEase.quadIn});
										FlxTween.tween(theBorderBG, {alpha: 0.5}, 0.5, {type: ONESHOT, ease: FlxEase.quadOut});
										objectWiggleShader.waveSpeed = 16;
										objectWiggleShader.waveAmplitude = 0.0009;
										objectTrailShader.alpha = 0.65;
										objectTrailShader.blend = NORMAL;
										objectTrailShader.color = 0xffffff;
										inSongClimax = false;
										singFollowMultiplier = 1;
										if (FlxG.save.data.flashing)
											FlxTween.tween(colourWash, {alpha: stageAmbAlpha}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.smootherStepOut});
									case 224:
										//glitchyGlitchEffect.active = false;
										defaultCamZoom = 0.95;
										dadFollowOffset[1] = 20;
										bfFollowOffset[1] += 20;
									case 287:
										dad.playAnim('midsongAnim', true);
									case 288:
										defaultCamZoom = 1;
										objectWiggleShader.waveSpeed = 24;
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
										objectWiggleShader.waveSpeed = 40;
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
										dadFollowOffset[1] = 15;
										bfFollowOffset[1] -= 20;
									case 353:
										camZooming = true;
									case 354:
										objectWiggleShader.waveSpeed = 24;
										objectWiggleShader.waveAmplitude = 0.00125;
										objectTrailShader.alpha = 0.65;
										objectTrailShader.blend = ADD;
										objectTrailShader.color = 0xffffff;
										objectTrailShader.alpha = 1;
										defaultCamZoom = 0.815;
										camGame.zoom += 0.02;
										FlxTween.tween(bgBopper, {alpha: 0.8, y: 590 - (bgBopper.height - 80)}, 0.5, {type: ONESHOT, ease: FlxEase.quadOut});
										FlxTween.tween(theBorderBG, {alpha: 0.3}, 0.5, {type: ONESHOT, ease: FlxEase.quadOut});
										inSongClimax = true;
										singFollowMultiplier = 2.25;
										if (FlxG.save.data.flashing)
										{
											colourWash.blend = ADD;
											FlxTween.color(colourWash, Conductor.crochet * 4 / 1000, FlxColor.WHITE, stageAmbColour, {type: ONESHOT, ease: FlxEase.smootherStepOut});
										}
									case 416:
										objectTrailShader.alpha = 0.5;
										objectWiggleShader.waveSpeed = 10;
										objectTrailShader.blend = NORMAL;
										objectWiggleShader.waveAmplitude = 0.00075;
										defaultCamZoom = 0.82;
										dadFollowOffset[1] = 10;
										bfFollowOffset[1] -= 10;
									case 479:
										allowHeartBeatSounds = false;
									case 480:
										objectWiggleShader.waveSpeed = 2;
										bfFollowOffset[1] -= 10;
										allowNoteHitSounds = false;
										camFollowSpeed = 0.5;
										FlxTween.tween(bgBopper, {alpha: -10, y: 690}, 4.1142, {type: ONESHOT, ease: FlxEase.quadIn});
										FlxTween.tween(camHUD, {alpha: 0.75}, 4.1142, {type: ONESHOT, ease: FlxEase.sineInOut, startDelay: 0.1});
										FlxTween.tween(theBorderBG, {alpha: 0.8}, 4.1142, {type: ONESHOT, ease: FlxEase.sineInOut, startDelay: 0.1});
										theBorderBG.alpha += 0.0035;
										dadFollowOffset[1] = -25;
										inSongClimax = false;
										singFollowMultiplier = 1.5;
										if (FlxG.save.data.flashing)
										{
											colourWash.blend = SCREEN;
											colourWash.alpha = 0;
											FlxTween.tween(colourWash, {alpha: stageAmbAlpha}, Conductor.crochet * 4 / 1000, {type: ONESHOT, ease: FlxEase.smootherStepOut});
										}
									case 507:
										dadFollowOffset[1] = 5;
										camZooming = false;
									case 508:
										objectWiggleShader.waveSpeed = 4;
										objectTrailShader.alpha = 0.3;
										//glitchyGlitchEffect.active = true;
										camFollowSpeed = 1;
										boyfriend.playAnim('awkward', true);
										midsongCutscene = true;
										dad.playAnim('endsongAnim1', true);
										camShake(true, true, 'camGame', 0.03, idleCamShakeTimer - 0.05);
										FlxTween.tween(camGame, {zoom: 1.65}, 2, {type: ONESHOT, ease: FlxEase.quadIn});
									case 509:
										//glitchyGlitchEffect.active = false;
										boyfriend.playAnim('concerned', true);
										dad.playAnim('endsongAnim1', true);
										camShake(true, true, 'camGame', 0.05, idleCamShakeTimer - 0.05);
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
										stageOverlay1.kill();
										stageOverlay1.destroy();
										objectTrailShader.destroy();
										dummyBlackScreen.alpha = 1;
										camGame.flash(DisclaimerState.flashColor, 0.5);
										if (isStoryMode)
											camHUD.alpha = 0;
										else
											camHUD.alpha = 1;
								}


								if (inSongClimax)
								{
									camShake(true, false, 'camGame', 1, 0.005, idleCamShakeTimer);
									camShake(false, false, 'camHUD', 1, 0.002, idleCamShakeTimer);
								}

							case 'Kid With a Gun':
								switch(curBeat)
								{
									case 3:
										camZooming = true;
									case 169:
										boyfriend.doIdle = false;
										boyfriend.playAnim('scaredHOLD', false);
									case 172:
										boyfriend.doIdle = true;
									case 192:
										camZooming = false;
										defaultCamZoom = 0.82;
										altCamZoom(Conductor.crochet * 1 / 1000, 'expo');
									case 196:
										defaultCamZoom = 0.85;
										camZooming = true;
									case 260:
										allowHeartBeatSounds = false;
									case 261:
										camZooming = false;
								}


							case 'Playing With Fire':
								if (FlxG.save.data.flashing)
								{
									if (curBeat % 2 == 1 && curBeat > 276 && curBeat < 309)
										stageOverlay1.animation.play('singleFlash');
									else if ((curBeat % 8 == 5 || curBeat % 8 == 7) && curBeat > 372 && curBeat < 404)
										stageOverlay1.animation.play('singleFlash');
								}
								switch (curBeat)
								{
									case 0 | 1:
										gfSpeed = 2;
									case 32:
										camZooming = true;
									case 108:
										boyfriend.doIdle = false;
										boyfriend.playAnim('scaredHOLD', false);
									case 112:
										boyfriend.doIdle = true;
									case 140:
										boyfriend.doIdle = false;
										boyfriend.playAnim('scared', false);
										gf.playAnim('cheerFail');
									case 144:
										boyfriend.doIdle = true;
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
											strumLineBGTween = FlxTween.tween(grpStrumLine, {alpha: 0}, Conductor.crochet * 4 / 1000, {type: ONESHOT, ease: FlxEase.quadIn, onComplete: function(twn:FlxTween){strumLineBGTween = null;}});
										}
										camFollowSpeed = 0.875;
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
										camShake(true, true, 'camHUD', 0.005, Conductor.crochet / 1000);
										allowHeartBeatSounds = false;
										camFollowSpeed = 1.125;
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
										{
											strumLineBGTween = FlxTween.tween(grpStrumLine, {alpha: 0.4}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.quadOut, onComplete: 
												function(twn:FlxTween)
												{
													strumLineBGTween = null;
													doStrumLineBGTweening = true;
												}
											});
										}
										gfSpeed = 1;
									case 180:
										doPityDeaths = true;
										camFollowSpeed = 1;
										allowHeartBeatSounds = true;
										midsongCutscene = false;
										camZooming = true;
									case 244:
										camFollowSpeed = 1.25;
										defaultCamZoom = 0.9;
									case 276:
										defaultCamZoom = 0.95;
									case 300:
										gfSpeed = 0;
										gf.playAnim('cheerFail');
									case 302:
										doCamFollowing = false;
										midsongCutscene = true;
										camFollow.x = gf.getGraphicMidpoint().x + 50;
										camFollow.y = gf.getGraphicMidpoint().y - 50;
										camZooming = false;
										FlxTween.tween(camGame, {zoom: 1}, 0.5, {type: ONESHOT, ease: FlxEase.elasticInOut});
									case 304:
										//Hides the HUD and zooms the camera out once priest speaks
										camTween = FlxTween.tween(camGame, {zoom: 1.2}, (Conductor.crochet / 1000), {type: ONESHOT, ease: FlxEase.elasticInOut, onComplete:
											function (twn:FlxTween)
											{
												camTween = null;
											}
										});
										strumLineNotes.forEach(function(babyArrow:FlxSprite)
										{
											FlxTween.tween(babyArrow, {alpha: 0}, 0.2, {type: ONESHOT, ease: FlxEase.quadOut});
										});
										if (FlxG.save.data.strumline)
										{
											doStrumLineBGTweening = false;
											strumLineBGTween = FlxTween.tween(grpStrumLine, {alpha: 0}, 0.2, {type: ONESHOT, ease: FlxEase.quadIn, onComplete: function(twn:FlxTween){strumLineBGTween = null;}});
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
										camFollow.x = gf.getGraphicMidpoint().x;
									case 307:
										camFollow.y -= 10;
										doCamFollowing = true;
										camFollowSpeed = 2.25;
										camGame.zoom = 0.9;
										boyfriend.playAnim('scared', true);
										dad.playAnim('gunWARNING', true);
										gf.playAnim('scared', true);
										camShake(true, false, 0.035, Conductor.crochet / 1000);
										camShake(true, true, 'camHUD', 0.01, Conductor.crochet / 1000);
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
										{
											strumLineBGTween = FlxTween.tween(grpStrumLine, {alpha: 0.4}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.quadOut, onComplete:
											function(twn:FlxTween)
											{
												strumLineBGTween = null;
												doStrumLineBGTweening = true;
											}
											});
										}
										camFollowSpeed = 1;
										camZooming = true;
										gfSpeed = 1;
									case 435:
										camFollowSpeed = 1.25;
									case 538:
										new FlxTimer().start(0.176, function(tmr:FlxTimer)
										{
											dad.playAnim('gunSHOOT', true);
										});
									case 563:
										camFollowSpeed = 0.875;
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
										singFollowMultiplier = 1.75;
									case 128:
										defaultCamZoom = 0.95;
										inSongClimax = false;
										singFollowMultiplier = 1;
									case 192:
										defaultCamZoom = 0.8;
										inSongClimax = true;
										singFollowMultiplier = 2;
									case 223:
										dad.blend = SUBTRACT;
										FlxTween.tween(dummyBlackScreen, {alpha: 1}, Conductor.crochet / 900, {type: ONESHOT, ease: FlxEase.sineInOut});
									case 224:
										stageParticles.visible = false;
										inSongClimax = false;
										singFollowMultiplier = 1;
										dad.blend = LIGHTEN;
									case 256:
										defaultCamZoom = 0.85;
										stageParticles.visible = true;
										camGame.flash(DisclaimerState.flashColor, Conductor.crochet * 4 / 1000);
										dummyBlackScreen.alpha = 0;
										dad.blend = NORMAL;
									case 288:
										defaultCamZoom = 1;
									case 351:
										defaultCamZoom = 0.85;
										camZooming = false;
									case 352:
										inSongClimax = true;
										singFollowMultiplier = 2.25;
										defaultCamZoom = 0.8;
									case 353:
										camZooming = true;
									case 416:
										FlxTween.tween(camGame, {zoom: 1}, Conductor.crochet * 30 / 1000, {type: ONESHOT, ease: FlxEase.sineInOut});
										allowHeartBeatSounds = false;
										camZooming = false;
										inSongClimax = false;
										singFollowMultiplier = 1;
										camHUD.zoom = 1;
									case 447:
										FlxTween.tween(camGame, {zoom: 0.85}, Conductor.crochet / 1000, {type: ONESHOT, ease: FlxEase.expoIn});
									case 448:
										defaultCamZoom = 0.85;
										boyfriend.active = false;
										boyfriend.alpha = 0;
										dad.active = false;
										dad.alpha = 0;
										stageOverlayGroup.destroy();
										dummyBlackScreen.alpha = 1;
										if (isStoryMode)
											camHUD.alpha = 0;
										else
											camHUD.alpha = 1;
								}

								//Variegated Skylines idle Camshake
								if (stageParticles.visible)
								{
									if (!inSongClimax)
									{
										camShake(false, false, 'camGame', 2, 0.0075, idleCamShakeTimer);
										camShake(false, false, 'camHUD', 2, 0.001, idleCamShakeTimer);
									}
									else
									{
										camShake(false, false, 'camGame', 2, 0.0115, idleCamShakeTimer);
										camShake(false, false, 'camHUD', 2, 0.002, idleCamShakeTimer);
									}
									
									if (skipActive || (curBeat > (skipTo / Conductor.crochet)) && curBeat % 2 == 0)
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

							case 'Striking Tribulation':
								switch (curBeat)
								{
									case 16:
										camZooming = true;
									case 864:
										iconP2.color = 0xFFBEBEBE;
										health = 2;
										camHUD.alpha = 0;
										camZooming = false;
										midsongCutscene = true;
										boyfriend.playAnim('scaredHOLD', true);
										boyfriend.alpha = 0;
										dad.playAnim('firstDeath', true);
										dadFollowOffset[0] -= 100;
										dadFollowOffset[1] += 60;
										dummyBlackScreen.alpha = 1;
										camGame.shake(0.05, 0.3, true, true);
										miscs.volume = vocalsVolume;
									case 896:
										FlxTween.tween(boyfriend, {alpha: 1}, Conductor.crochet / 4000, {type: ONESHOT, ease: FlxEase.smoothStepOut});
										camFollowSpeed = 0.5;
										//FlxTween.tween(camHUD, {alpha: 1}, 3, {type: ONESHOT, ease: FlxEase.quadOut});
									case 932:
										miscs.volume = vocalsVolume;
										remove(boyfriend);
										remove(dad);
										if (!isStoryMode)
											camHUD.alpha = 1;
								}


							case 'Finale': //ADAPTIVE MUSIC!! WOOOOO!!!
								//SPHAGETTI CODE INCOMING CAUSE FLIXEL DON'T HAVE A WELL DOCUMENTED WAY OF FRICKINJ SOUND GROUPSAFA
								//Drums/Taiko
								//Choir, Taiko, Drums, Hats, Bells
								//this shit is so ass
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

				//LowHP Shits
				switch (curSong)
				{
					case "Mic Test" | "Sudden Confrontation" | "Sprouting Irritation" | "Striking Tribulation":
						//do NATHIN
					default:
						if (health < 1 && lowHPEffectVol > 0 && !midsongCutscene && allowHeartBeatSounds && !showedResults && !inCutscene && !cannotDie && allowHealthModifiers)
						{
							if (Conductor.bpm > 250 && (health >= 0.7 && curBeat % 4 == 0 || curBeat % 2 == 0) || (health >= 0.7 && curBeat % 4 == 0 || health > 0.5 && curBeat % 2 == 0 || health < 0.5))
							{
								if (lowHPHeartBeat.playing)
									lowHPHeartBeat.stop();
								lowHPHeartBeat = FlxG.sound.play(Paths.sound('lowHP'), lowHPEffectVol);
								lowHPHeartBeat.pitch = FlxG.random.float(0.85, 1.15);
								
								if (FlxG.save.data.flashing)
									lowHPOverlay.alpha = lowHPEffectVol;
							}
						}
				}

				//Idle shits
				if (songStarted && !midsongCutscene && !endedSong && !PlayStateChangeables.Optimize)
				{
					if (gfSpeed > 0 && curBeat % gfSpeed == 0 && gf.doIdle)
						gf.dance();

					//(IDK???)> (╯°□°）╯︵ ┻━┻
					if (!boyfriend.animation.curAnim.name.startsWith('sing') && preventBFIdleAnim)
						preventBFIdleAnim = false;

					if (((boyfriend.animation.curAnim.name != 'idleAfterSing' && !boyfriend.animation.curAnim.name.startsWith('sing') && boyfriend.animation.curAnim.name != "hurt" && !boyfriend.animation.curAnim.name.startsWith("dodge") || boyfriend.animation.curAnim.finished) && (boyfriend.animation.curAnim.name != 'hey' && boyfriend.animation.curAnim.name != 'style' || boyfriend.animation.curAnim.curFrame >= 5)) && curBeat % idleBeat == 0 && boyfriend.doIdle)
					{
						//Let players hold the anim if they want lol
						if (!holdArray.contains(true) || !preventBFIdleAnim || PlayStateChangeables.botPlay)
						{
							boyfriend.playAnim('idle', idleToBeat);
							if (isBFTurn)
								singFollowOffset = [0, 0];
						}
					}
						//trace("Idle (line 8468)");

					// Here so that Dad doesnt interrupt his own notes
					if (!dad.animation.curAnim.name.startsWith("sing") && (!dad.animation.curAnim.name.startsWith("gun") && !dad.animation.curAnim.name.startsWith("cheer") || dad.animation.curAnim.curFrame >= 3) && dad.doIdle)
					{
						if (curBeat % idleBeat == 0 || dad.curCharacter == "priest-theborderpray" || dad.curCharacter == "table-default")
						{
							dad.dance(idleToBeat);
							if (!isBFTurn)
								singFollowOffset = [0, 0];
						}
					}
				}

				//HARDCODING FOR ZOOMS
				if (!showedResults && !skippingIntro)
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

						case "Disagreement":
							if (FlxG.save.data.camzoom && camZooming)
							{
								if (curBeat % 4 == 0)
								{
									camGame.zoom += 0.025;
									camHUD.zoom += 0.015;
									if (camZoomUsesTween)
										altCamZoom(Conductor.crochet * 2.5 / 1000, 'elastic');
								}

								if (curBeat % 4 == 2)
								{
									if (curBeat > 64 && curBeat < 126)
									{
										camGame.zoom += 0.025;
										camHUD.zoom += 0.015;
									}
									else if (curBeat > 256 && curBeat < 315)
									{
										camGame.zoom += 0.025;
										camHUD.zoom += 0.015;
									}
								}
								
								if (curBeat > 320 && curBeat < 380 && curBeat != 344 && curBeat != 345 && curBeat != 346 && curBeat != 347 && curBeat != 348 && curBeat != 349 && curBeat != 350 && curBeat != 351)
								{
									camGame.zoom += 0.025;
									camHUD.zoom += 0.015;
								}

								if (curBeat % 8 == 0)
									styleCheck();
							}
							else if (camZooming)
							{
								if (curBeat % 8 == 0)
									styleCheck();
							}

						case "Retaliation":
							if (FlxG.save.data.camzoom && camZooming)
							{
								if (curBeat % 8 == 0)
									styleCheck();

								if (curBeat > 316 && curBeat < 354)
								{
									if (curBeat % 4 == 2)
									{
										camGame.zoom +=  0.025;
										camHUD.zoom += 0.015;
									}
								}	
								else
								{
									if (curBeat % 4 == 0)
									{
										camGame.zoom += 0.025;
										camHUD.zoom += 0.015;
										if (camZoomUsesTween)
											altCamZoom(Conductor.crochet * 3 / 1000, 'elastic');
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
									if (!PlayStateChangeables.Optimize)
										if (stageOverlay1 != null && FlxG.save.data.flashing && FlxG.save.data.distractions)
											stageOverlay1.animation.play('singleFlash');
								}	

								if (curBeat > 352 && curBeat < 416 && curBeat != 383)
								{
									camGame.zoom += 0.0255;
									camHUD.zoom += 0.0155;
									if (PlayStateChangeables.Optimize)
										if (stageOverlay1 != null && curBeat % 2 == 0 && FlxG.save.data.flashing && FlxG.save.data.distractions)
											stageOverlay1.animation.play('singleFlash');
								}
							}
							else
							{
								if (curBeat % 8 == 0)
									styleCheck();
								
								if (PlayStateChangeables.Optimize)
									if (stageOverlay1 != null && curBeat % 4 == 2 && curBeat > 96 && curBeat < 130 || curBeat > 192 && curBeat < 256 && FlxG.save.data.flashing && FlxG.save.data.distractions)
										stageOverlay1.animation.play('singleFlash');

								if (PlayStateChangeables.Optimize)
									if (stageOverlay1 != null && curBeat > 352 && curBeat < 416 && curBeat != 383 && curBeat % 2 == 0 && FlxG.save.data.flashing && FlxG.save.data.distractions)
										stageOverlay1.animation.play('singleFlash');
							}

						case "Sudden Confrontation" | "Sprouting Irritation":
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

							if (intimidationBeats > 0)
								intimidationBeats--;
							else
							{
								if (curBeat % 16 == 0 && curBeat > 8)
								{
									if (missesInSection <= 0 && (notesHitInSection > 4 || (notesHitInSection != 0 && isBFTurn)))
									{
										trace('increase sections');
										sectionsFCd++;
										sectionsTotal++;
										if (sectionsTotal < sectionsUntilReset)
										{
											if (sectionsFCd <= sectionsUntilReset)
											{
												trace('increase intimidation');
												//Maybe play a sound here
												if (intimidationPTS < 16)
													intimidationPTS++;
											}
											//resets every 2 sections after intimidation check
											sectionsFCd = 1;
											sectionsTotal = 1;
										}
									}
									//resets every section
									missesInSection = 0;
									notesHitInSection = 0;
									trace('reset');
								}
							}

						case "Striking Tribulation":
							if (FlxG.save.data.camzoom && camZooming)
							{
								if (curBeat % 4 == 0)
								{
									camGame.zoom += 0.025;
									camHUD.zoom += 0.015;
								}

								if ((curBeat > 408 && curBeat < 470 || curBeat > 736 && curBeat < 860) && curBeat != 438 && curBeat != 439 && curBeat != 764 && curBeat != 765 && curBeat != 766 && curBeat != 767 && curBeat != 798 && curBeat != 799 && curBeat != 831 && curBeat != 846 && curBeat != 847)
								{
									camGame.zoom += 0.025;
									camHUD.zoom += 0.015;
								}

								if (curBeat % 8 == 0)
									styleCheck();
							}
							else if (camZooming)
							{
								if (curBeat % 8 == 0)
									styleCheck();
							}

							if (intimidationBeats > 0)
								intimidationBeats--;
							else
							{
								if (curBeat % 16 == 0 && curBeat > 8)
								{
									if (missesInSection <= 0 && (notesHitInSection > 4 || (notesHitInSection != 0 && isBFTurn)))
									{
										trace('increase sections');
										sectionsFCd++;
										sectionsTotal++;
										if (sectionsTotal < sectionsUntilReset)
										{
											if (sectionsFCd <= sectionsUntilReset)
											{
												trace('increase intimidation');
												//Maybe play a sound here
												if (intimidationPTS < 16)
													intimidationPTS++;
											}
											//resets every 2 sections after intimidation check
											sectionsFCd = 1;
											sectionsTotal = 1;
										}
									}
									//resets every section
									missesInSection = 0;
									notesHitInSection = 0;
									trace('reset');
								}
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

				if (FlxG.save.data.distractions && generatedSong && songStarted)
				{
					iconP1.scale.set(1.2, 1.2);
					iconP2.scale.set(1.2, 1.2);
			
					iconP1.updateHitbox();
					iconP2.updateHitbox();
				}

				switch (curStage)
				{
					case "border":
						if (!midsongCutscene && !showedResults)
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
			//}
		}
		//DC.endProfile("beatShit");
	}
}