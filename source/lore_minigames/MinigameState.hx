package lore_minigames;

import flixel.math.FlxPoint;
import flixel.math.FlxRandom;
import flixel.FlxObject;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxBar;
import flixel.util.FlxTimer;
import flixel.util.FlxAxes;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxSoundGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import openfl.filters.BitmapFilter;
import openfl.filters.ShaderFilter;

import flixel.util.FlxStringUtil;

//import lore_minigames.Interactibles;
//import lore_minigames.Clatterer;
//import lore_minigames.Collectibles;

//Light 
import flixel.util.FlxSpriteUtil;
import flash.geom.Rectangle;
import flash.geom.ColorTransform;
import flash.geom.Point;
import flash.display.BitmapData;
import flash.display.BitmapDataChannel;

class MinigameState extends MusicBeatState
{
	var targetFrameTime:Float = 1/120;
	var frameTimeMult:Float = 1;

	public static var player:Player;
	var map:FlxOgmo3Loader;

	var walls:FlxTilemap;
	var interactiblesGroup:FlxTypedGroup<Interactibles>;
	var doorsLocationMap:Map<String, Array<Float>> = new Map<String, Array<Float>>(); //Format (PortalID_PortalDestination, [PortalX, PortalY])
	var clatterGroup:FlxTypedGroup<Clatterer>;
	var collectiblesGroup:FlxTypedGroup<Collectibles>;
	//var deadliesGroup:FlxTypedGroup<Enemies>;
	var theManUpstairs:TheManUpstairs;

	var movedBack:Bool = false;

	var clatterCoyote:FlxTimer;//A timer that gives time before you make any nosie
	var clatter:Int = 0; //basically the decked out clank system :))) | set to -2 until we can reliably calc adaptive caps (check out what you did for the enemy dmg in pico week)
	var risk:Int = 0; //basically the decked hazard system :DDD

	var heartBeatLevel:Int = 0;

	var pseudoCamFade:FlxSprite;
	var darkenScreen:FlxSprite;

	public static var camGame:FlxCamera;
	public static var camHUD:FlxCamera;
	var defaultCamZoom:Float = 5;
	var camFollow:FlxObject;
	var doCamFollowing:Bool = false;


	var screen:LoadingScreen = null;

	//SoundStuff
	var preEscMusGroup:FlxSoundGroup;
	var preSusMusGroup:FlxSoundGroup;

	var escapeTimer:FlxTimer;
	var escapeTimerTween:FlxTween;
	var defaultEscapeTime:Int = 170;
	var escapeTimerGroup:FlxSpriteGroup = null;
	var escapeTimerText:FlxText;
	var escTimeBG:FlxSprite;
	var escTimeBar:FlxBar;
	var escTimeClock:FlxSprite;
	var escBarTracker:Float = 0;

	var doorOpenSound:FlxSound;
	var doorCloseSound:FlxSound;

	public static var weekNum:Int = 0;

	var killDepth:Float = 720; //what height to kill the player in
	var playerResetPos:Array<Float> = [];

	var camGameFilters:Array<BitmapFilter> = [];

	var noiseFilter:shaders.Grain;

	//Light Shit
	var _stageDarkness:FlxSprite;
	var _stageDarkRect:FlxSprite;

	override public function create()
	{
		#if windows
		// Updating Discord Rich Presence
		if (FlxG.save.data.showPresence)
			DiscordClient.changePresence("Testing the Minigames!!!", null, "apppresence-strange");
		//DiscordClient.changePresence("Somewhere Familiar...", null, "apppresence-strange");
		#end

		if (FlxG.save.data.fpsCap < 120)
			targetFrameTime = 1 / FlxG.save.data.fpsCap;
		initSkipFrames = Math.round(FlxG.save.data.fpsCap / 60);
		noiseSkipFrames = initSkipFrames;
		trace('noiseSkipFrames: ' + initSkipFrames);
		
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		Conductor.changeBPM(115);

		//FlxG.fixedTimestep = true;
		
		//Volume shits
		preEscMusGroup = new FlxSoundGroup(FlxG.sound.defaultMusicGroup.volume);
		preSusMusGroup = new FlxSoundGroup(FlxG.sound.defaultMusicGroup.volume);

		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);

		//camGame.shakeFlashSprite = true;

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		transIn.camera = camHUD;
		transOut.camera = camHUD;

		//trace('mmm');
		map = new FlxOgmo3Loader('assets/minigame/rooms/minigame.ogmo', 'assets/minigame/rooms/room_0.json');
		//trace("buh");
		walls = map.loadTilemap("assets/minigame/images/tilemap.png", "tiles");
		//trace("bruh");
		walls.follow();
		walls.setTileProperties(1, NONE);
		walls.setTileProperties(2, NONE);
		walls.setTileProperties(3, ANY);
		walls.setTileProperties(4, ANY);
		walls.setTileProperties(5, ANY);
		walls.setTileProperties(6, ANY);
		walls.setTileProperties(7, ANY);
		walls.setTileProperties(8, NONE);
		walls.setTileProperties(9, NONE);
		//trace("???");
		add(walls);

		interactiblesGroup = new FlxTypedGroup<Interactibles>();
		add(interactiblesGroup);
		
		clatterGroup = new FlxTypedGroup<Clatterer>();
		add(clatterGroup);

		collectiblesGroup = new FlxTypedGroup<Collectibles>();
		add(collectiblesGroup);

		player = new Player();
		//player.shader = new shaders.TestShader();
		map.loadEntities(placeEntities, "entities");

		add(player);

		//CamfollowData
		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		camGame.zoom = defaultCamZoom;
		camGame.focusOn(camFollow.getPosition());
		camGame.follow(camFollow, LOCKON);
		//camGame.followLerp = camFollowSpeed;
		camGame.followLerp = 50;
		camGame.filters = camGameFilters;
		//var bloom:ShaderFilter = new ShaderFilter(new shaders.BloomShader(0.3, 0.75, 3));
		//camGameFilters.push(bloom);
		//var poster = new ShaderFilter(new shaders.PosterizeShaderTest());
		//camGameFilters.push(poster);
		noiseFilter = new shaders.Grain(2.5, 0.05, 0.3);
		camGameFilters.push(new ShaderFilter(noiseFilter));
		camGameFilters.push(new ShaderFilter(new shaders.ChromAbb(0.0015, 0, -0.0015)));

		//For CamHUD to fix itself after shake
		/*var camHUDFollow:FlxObject = new FlxObject(0, 0, 1, 1);
		camHUDFollow.screenCenter();
		camHUD.focusOn(camHUDFollow.getPosition());
		camHUD.follow(camHUDFollow, LOCKON);
		camHUD.followLerp = 2;*/

		//trace("finally");

		pseudoCamFade = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 4, FlxG.height * 4, 0xFF000000);
		pseudoCamFade.scrollFactor.set();
		pseudoCamFade.alpha = 0;
		pseudoCamFade.cameras = [camHUD];
		add(pseudoCamFade);
		
		darkenScreen = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.WHITE);
		darkenScreen.scrollFactor.set();
		darkenScreen.alpha = 0;
		darkenScreen.cameras = [camGame];
		darkenScreen.blend = SUBTRACT;
		add(darkenScreen);


		escapeTimerGroup = new FlxSpriteGroup();
		escapeTimerGroup.cameras = [camHUD];
		escapeTimerGroup.visible = false;
		add(escapeTimerGroup);

		escTimeBG = new FlxSprite(0, 30).loadGraphic('assets/minigame/images/escapeBarBorder.png');
		escTimeBG.screenCenter(X);

		escTimeBar = new FlxBar(escTimeBG.x
			+ 4, escTimeBG.y
			+ 4, LEFT_TO_RIGHT, Std.int(escTimeBG.width - 8), Std.int(escTimeBG.height - 8), this,
			'escBarTracker', 0, defaultEscapeTime);
		escTimeBar.numDivisions = 800;
		escTimeBar.createImageBar('assets/minigame/images/escapeBarEmpty.png', 'assets/minigame/images/escapeBarFilled.png');
		escapeTimerGroup.add(escTimeBar);
		escapeTimerGroup.add(escTimeBG);

		escTimeClock = new FlxSprite(escTimeBG.x - 20, escTimeBG.y - 3).loadGraphic('assets/minigame/images/escapeBarClock.png');
		escapeTimerGroup.add(escTimeClock);

		escapeTimerText = new FlxText(0, escTimeBG.y - 3, 0, "--:--", 40);
		escapeTimerText.screenCenter(X);
		escapeTimerText.setFormat(Paths.font("vcr.ttf"), 40, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		escapeTimerText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 3, 3);
		escapeTimerGroup.add(escapeTimerText);

		escapeTimerGroup.y -= 100;

		var staminaBar:FlxBar = new FlxBar(10, FlxG.height - 30, LEFT_TO_RIGHT, 120, 20, player, 'stamina', 0, 100);
		staminaBar.createFilledBar(0xFF5A003C, 0xFF33FFE4);
		staminaBar.antialiasing = FlxG.save.data.antialiasing;
		staminaBar.angle = 2;
		staminaBar.cameras = [camHUD];
		add(staminaBar);

		/*var healthBar:FlxBar = new FlxBar(10, FlxG.height - 50, LEFT_TO_RIGHT, 120, 20, player, 'health', 0, 100);
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		healthBar.antialiasing = FlxG.save.data.antialiasing;
		healthBar.angle = 2;
		healthBar.cameras = [camHUD];
		add(healthBar);*/

		//Light Shit
		_stageDarkness = new FlxSprite();
		_stageDarkness.makeGraphic(FlxG.stage.stageWidth, FlxG.stage.stageHeight, 0xFFFFFFFF);
		_stageDarkness.blend = SUBTRACT;
		_stageDarkness.alpha = 0.3;
		//_stageDarkness.antialiasing = true;
		add(_stageDarkness);

		_stageDarkRect = new FlxSprite();
		_stageDarkRect.makeGraphic(0, 0, 0x00000000);
		//_stageDarkRect.blend = ADD;
		//add(_stageDarkRect);

		super.create();

		FlxG.sound.playMusic('assets/minigame/music/map_1/HeartbeatLoop' + heartBeatLevel + '.ogg', 1, false);
		FlxG.sound.music.looped = true;
		FlxG.sound.music.autoDestroy = false;
		FlxG.sound.music.onComplete = checkAndSwapMusic;
	}

	var inEscSeq:Bool = false;
	var seqCheck:Int = 0;
	var suspenseEscMusicIntro:FlxSound;
	var musicTween:FlxTween;

	var totalDone:Int = 0;
	
	private function placeEntities(entity:EntityData, totalItems:Int)
	{
		switch (entity.name)
		{
			case 'player':
				player.setPosition(entity.x, entity.y);
				playerResetPos = [player.x, player.y];
				doCamFollowing = true;
			case 'portal_door':
				//definitely make a class for this
				var door:Interactibles = new Interactibles(entity.x, entity.y, DOOR);
				door.destProgInt = entity.values.destinationInt;
				door.specialAnimType = entity.values.specialAnimType;
				door.doorID = entity.values.portal_ID;
				door.isLocked = entity.values.isLocked;
				doorsLocationMap.set(door.doorID + "_" + door.destProgInt, [entity.x, entity.y]);
				interactiblesGroup.add(door);
			case 'interactibles':
				var interactibles:Interactibles = new Interactibles(entity.x, entity.y, OTHER);
				interactibles.spriteID = entity.values.spriteID;
				interactibles.dialogueArray = entity.values.dialogue.split('+');
				interactiblesGroup.add(interactibles);
				trace(interactibles.dialogueArray);
			case 'memory_collectible':
				var secretPickup:Collectibles = new Collectibles(entity.x, entity.y, SECRET);
				collectiblesGroup.add(secretPickup);
			case 'final_collectible':
				var finalPickup:Collectibles = new Collectibles(entity.x, entity.y, FINAL);
				collectiblesGroup.add(finalPickup);
				finalCollectLocation = [entity.x, entity.y];
			case 'clatter_producer':
				//definitely make a class for this
				var clatterers:Clatterer = new Clatterer(entity.x, entity.y);
				clatterers.x += 4;
				clatterers.y += 16;
				clatterGroup.add(clatterers);
			case 'enemy':
				//enemyType
			case 'out-of-bounds-checker':
				//this is TEMP!!!
				killDepth = entity.y;
		}
		totalDone++;

		if (totalDone < totalItems)
			return;

		//Goes through every item in interactiblesGroup!
		//Set door locations
		interactiblesGroup.forEach(function(bobuxDoors:Interactibles)
		{
			if (bobuxDoors.type == DOOR)
			{
				//Swap destProgInt values
				//Wait so why do we need to do this when we have destProgInt
				//Ok so im gonna try something
				//SURELY we can just make destination and location separate RIGHT?!
				//heh,,,, it crashed,,,
				//Oki trying it again
				//              stringifyier
				var loadID:String = "" + bobuxDoors.doorID;
				if (bobuxDoors.destProgInt == 0)
					loadID += "_1";
				else if (bobuxDoors.destProgInt == 1)
					loadID += "_0";

				//Then retrieve the coords to place the player in!
				//Gurl I know I wrote the code but this is lowk making my head spin LMFAO
				var locationArray:Array<Float> = doorsLocationMap.get(loadID);
				switch (bobuxDoors.destProgInt)
				{
					case 0 | 1:
						bobuxDoors.destination[0] = Std.int(locationArray[0]);
						bobuxDoors.destination[1] = Std.int(locationArray[1]);
						trace ('set door ' + bobuxDoors.doorID + "'s tp coords to [" + locationArray[0] + ', ' + locationArray[1] + '].');
				}
			}
		});
	}

	function camFollowFunction(objectToFollow:FlxObject):Void
	{
		if (objectToFollow != null)
		{
			camMovementOffset[0] = Math.round((0.05 * player.velocity.x) + camHoldShakeAdditive[0]);
			camMovementOffset[1] = Math.round((player.velocity.y > 0 ? 0.2 * player.velocity.y : 0.075 * player.velocity.y) + camHoldShakeAdditive[1]);
			camMovementLerp[0] = FlxMath.lerp(camMovementOffset[0], camMovementLerp[0], calculateLerpTime(FlxG.elapsed, 2.25, 0, 1));
			camMovementLerp[1] = FlxMath.lerp(camMovementOffset[1], camMovementLerp[1], calculateLerpTime(FlxG.elapsed, 2.25, 0, 1));
	
			camFollow.setPosition(Math.round(player.getMidpoint().x) + camMovementLerp[0], Math.round(player.getMidpoint().y - 5) + camMovementLerp[1]);
		}
	}

	//dont judge my var naming skills >:CC
	var camMovementLerp:Array<Float> = [0, 0];//the value tht gets tweened
	var camMovementOffset:Array<Float> = [0, 0]; //the ACTUAL value that instantly gets updated
	var camHoldShakeAdditive:Array<Float> = [0, 0];

	var timeLeftChecker:Float = 4364;
	var fatherElapsedCheck:Int = 0;
	var noiseElapsed:Float = 0;
	var noiseSkipFrames:Int = 1;
	var initSkipFrames:Int = 1;

	override public function update(elapsed:Float)
	{		
		super.update(elapsed);

		/*if (noiseSkipFrames > 0)
			noiseSkipFrames--;
		else
		{
			noiseSkipFrames = initSkipFrames;
			noiseElapsed += elapsed;
			noiseFilter.uTime.value = [noiseElapsed];
		}*/

		noiseElapsed += (elapsed / 8) * FlxG.timeScale;
		noiseFilter.uTime.value = [noiseElapsed];

		frameTimeMult = elapsed/targetFrameTime;
		player.updateFrameTimeMult(frameTimeMult);
		FlxG.watch.addQuick("frameTimeMult", frameTimeMult);

		if (FlxG.keys.justPressed.ONE)
		{
			if (theManUpstairs != null)
			{
				theManUpstairs.setChaseSpeed(8000);
			}
			else
			{
				preEscMusGroup.stop();
				defaultEscapeTime = 5;
				escTimeBar.setRange(0, defaultEscapeTime);
				triggerEscapeSeq();
			}
		}
		if (!FlxG.keys.pressed.FIVE && player.velocity.x != 0 && player.velocity.y != 0)
			updateLighting(); //This is really intensive so I'll probably just make it so that the player doesn't have a flashlight - or replace this with a regular mask thingy

		if (FlxG.sound.music.playing)
			Conductor.songPosition += FlxG.elapsed * 1000;

		//Collides
		FlxG.collide(player, walls);
		//Overlaps
		if (FlxG.keys.justPressed.UP)
			FlxG.overlap(player, interactiblesGroup, interactFunct);
		if (player.curAction != SNEAK && player.curAction != SLIDE)
			FlxG.overlap(player, clatterGroup, clatterFunct);
		FlxG.overlap(player, collectiblesGroup, pickupFunct);

		//EVIL ASS FUNCTION!!! FIX AND REMOVE THIS ASAP!!!!!
		if (lockTheNextDoorThePlayerOverlapsWith)
			FlxG.overlap(player, interactiblesGroup, uglyEvilWorkaroundFunction);
		
		if (doCamFollowing)
			camFollowFunction(player);

		if (theManUpstairs != null && theManUpstairs.exists && inEscSeq && !jumpscaredPlayer)
		{
			//this updates every frame - is that alright??
			//shit way but ermm ermmm LMFAOOO erRRMMM ERMMM
			if (theManUpstairs.dadSNDNear.getActualVolume() > 0)
			{
				camShake(true, false, 3, 0.3 * theManUpstairs.dadSNDNear.getActualVolume() * 0.75, 0.05);
				FlxG.timeScale = 1 - (0.5 * theManUpstairs.dadSNDNear.getActualVolume()); //celeste ttype sjhit
				//trace('vol ' + theManUpstairs.dadSNDNear.getActualVolume());
			}
			else if (FlxG.timeScale != 1)
			{
				FlxG.timeScale = 1;
			}

			FlxG.overlap(player, theManUpstairs, jumpscareGameOver);
			
			//FlxG.overlap(player, theManUpstairs, playerDied);
			if (fatherElapsedCheck < 1)
			{
				theManUpstairs.playerPosition = player.getMidpoint();
				fatherElapsedCheck = 1;
			}
			else
				fatherElapsedCheck--;
		}

		if (jumpscaredPlayer)
		{
			if (jumpscareSprite != null && jumpscareSprite.exists)
			{
				var mult1:Float = FlxMath.lerp(1, jumpscareSprite.scale.x, 0.9);
				var mult2:Float = FlxMath.lerp(7, jumpscareSprite.angle, calculateLerpTime(elapsed * 2.5, 1, 0, 1));
				jumpscareSprite.scale.set(mult1, mult1);
				jumpscareSprite.angle = mult2;
				jumpscareSprite.updateHitbox();
				jumpscareSprite.screenCenter();
			}
			else
				trace('hey, if you turned on this bool before making the jumpscare sprite then you messed up buddy!! :D');
		}

		if (inEscSeq && escapeTimer != null)
		{
			//Only lower the shake when the time reaches 30 seconds
			if (escapeTimer.timeLeft <= 30)
				timerMult = (escapeTimer.timeLeft / 30);
			
			if (timeLeftChecker > escapeTimer.timeLeft)
			{
				timeLeftChecker = escapeTimer.timeLeft;

				if(escapeTimer.timeLeft >= 0)
					escapeTimerText.text = FlxStringUtil.formatTime(Math.floor(escapeTimer.timeLeft), false);
				escBarTracker = FlxMath.lerp(defaultEscapeTime - escapeTimer.timeLeft, escBarTracker, 0.965);
			}

			if (cid == 0 && escapeTimer.timeLeft <= 70)
			{
				trace ('OOP SHIT THIMER OUT OF TIME !!!!');
				cid = 1;
				getTheFuckOutMusic();
			}
		}

		if (player.y >= killDepth && player.canMove)
			playerFell();

		if (controls.BACK && !movedBack)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				FlxG.switchState(new MainMenuState());
			});
		}
		
		if (FlxG.keys.justPressed.R)
		{
			Conductor.songPosition = 0;
			isResetting = true;
			FlxG.resetState();
		}
		
		if (clatter > 8)
			clatter = 8;

		if (seqCheck > 1 && !stopActiveTweening)
		{
			camGame.zoom = FlxMath.lerp(defaultCamZoom, camGame.zoom, calculateLerpTime(elapsed, 3, 0, 1));
			darkenScreen.alpha = FlxMath.lerp(0.15, darkenScreen.alpha, calculateLerpTime(elapsed, 1.5, 0, 1));
		}
	}

	var stopActiveTweening:Bool = false;

	//var fakeBeat:Int = 0;

	//var beatOffset:Int = 0;
	//var beatFlavoured:Int = 0;
	
	//Ripped from playstate???\
	//stfu im very prouc of this function it is cool
	//chuu~
	public static function camShake(camToShake:String = 'camGame', force:Bool = true, decay:Bool = false, ?holdFor:Int = 1, intensity:Float = 0.03, duration:Float = 0.25, axis:FlxAxes = XY):Void
	{
		if (decay)
		{
			intensity *= 2;
			duration *= 2;
		}

		switch(camToShake)
		{
			case 'camHUD':
				camHUD.shake(holdFor, intensity, duration, force, decay, axis);
			default:
				camGame.shake(holdFor, intensity, duration, force, decay, axis);
		}
	}

	var timerMult:Float = 0;
	override function stepHit()
	{
		super.stepHit();
		
		if (inEscSeq)
		{
			//trace (timerMult);
			camHoldShakeAdditive[0] = FlxG.random.int(8, -8) * timerMult;
			camHoldShakeAdditive[1] = FlxG.random.int(-4, 4) * timerMult;
		}
	}

    override function beatHit()
	{
		super.beatHit();

		switch (seqCheck)
		{
			//Normal
			case 0:
				//trace('realBeat ' + curBeat + ' | fakeBeat ' + fakeBeat);
				if (curBeat % 4 == 0)
				{
					camHoldShakeAdditive[0] = FlxG.random.float(0.5, -0.5) * clatter;
					camHoldShakeAdditive[1] = FlxG.random.float(-0.5, 0.5) * clatter;
				}

				if (curBeat % 32 == 0)
				{
					FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_Layer' + heartBeatLevel + '.ogg', 1, false, preEscMusGroup);
					switch (heartBeatLevel)
					{
						case 1:
							if (FlxG.random.bool(20))
								FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_PianoCue0.ogg', 1, false, preEscMusGroup);
							else if (FlxG.random.bool(10))
								FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_PianoCue1.ogg', 0.5, false, preEscMusGroup);


						case 2 | 3:
							if (FlxG.random.bool(30))
								FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_PianoCue0.ogg', 1, false, preEscMusGroup);
							else if (FlxG.random.bool(20))
								FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_PianoCue1.ogg', 0.6, false, preEscMusGroup);

							if (heartBeatLevel == 3 && FlxG.random.bool(20))
								FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_ChiptuneCue0.ogg', 0.65, false, preEscMusGroup);


						case 4 | 5:
							if (FlxG.random.bool(40))
								FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_PianoCue1.ogg', 0.7, false, preEscMusGroup);
							else if (FlxG.random.bool(50))
								FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_PianoCue0.ogg', 0.8, false, preEscMusGroup);

							if (FlxG.random.bool(30))
								FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_ChiptuneCue0.ogg', 0.75, false, preEscMusGroup);
							else if (heartBeatLevel == 5 && FlxG.random.bool(20))
								FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_ChiptuneCue0.ogg', 0.65, false, preEscMusGroup);


							case 6 | 7:
							if (heartBeatLevel == 6)
							{
								if (FlxG.random.bool(50))
									FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_PianoCue1.ogg', 0.5, false, preEscMusGroup);
								else if (FlxG.random.bool(60))
									FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_PianoCue0.ogg', 0.5, false, preEscMusGroup);
							}

							if (FlxG.random.bool(50))
								FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_ChiptuneCue0.ogg', 1, false, preEscMusGroup);
							else if (heartBeatLevel == 7 && FlxG.random.bool(35))
								FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_ChiptuneCue0.ogg', 0.9, false, preEscMusGroup);


						default:
							if (FlxG.random.bool(30))
								FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_PianoCue0.ogg', 1, false, preEscMusGroup);
					}
				}
				//fakeBeat++;
			case 2 | 3:
				//camShake(false, false, 0.01 * timerMult, Conductor.crochet / 1200);
				if (curBeat % 4 == 0)
				{
					if (FlxG.sound.music != null)
					{
						camGame.zoom += FlxG.sound.music.volume * 0.25;
						darkenScreen.alpha = 0.25 * FlxG.sound.music.volume;
					}
				}
		}
	}

	var timesUp:Bool = false;
	var timerGroupTargetY:Float;
	var timerMultTween:FlxTween;

	var finalCollectLocation:Array<Float> = [];
	var tempCamAngleEscTwn:FlxTween;

	function triggerEscapeSeq():Void
	{
		if (!inEscSeq)
		{
			inEscSeq = true;
			trace('run for your life');
			FlxG.sound.music.stop();
			FlxG.sound.playMusic('assets/minigame/music/ExitSequenceThemeIntro.ogg', 1, false, preSusMusGroup);
			FlxG.sound.music.looped = false;
			FlxG.sound.music.onComplete = checkAndSwapMusic;
			trace('seqCheck ' + seqCheck);

			timerMultTween = FlxTween.tween(this, {timerMult: 0.5}, Conductor.crochet * 16 / 1000, 
			{	
				type: ONESHOT, 
				ease: FlxEase.smoothStepInOut,
				onComplete: function(twn:FlxTween)
				{
					timerMultTween = null;
				}
			});

			curBeat = 0;
			//fakeBeat = 0;
			Conductor.songPosition = 0;
			seqCheck = 1;

			escapeTimerGroup.visible = true;
			FlxTween.tween(escapeTimerGroup, {y: timerGroupTargetY}, 3, {type: ONESHOT, ease: FlxEase.elasticOut});

			//#if windows
			// Updating Discord Rich Presence
			//if (FlxG.save.data.showPresence)
				//DiscordClient.changePresence("The Clock is Ticking...", "(You might want to get going.)", "apppresence-strange");
			//#end

			escapeTimer = new FlxTimer().start(defaultEscapeTime, function(tmr:FlxTimer)
				{
					//#if windows
					// Updating Discord Rich Presence
					//if (FlxG.save.data.showPresence)
						//DiscordClient.changePresence("Time's Up!", "(Good luck.)", "apppresence-strange");
					//#end

					//Times Up Function
					timesUp = true;
					FlxG.sound.play(Paths.sound("damageAlert_3"), 1, false);
					FlxTween.tween(escapeTimerGroup, {y: -100}, 3, 
					{	
						type: ONESHOT, 
						ease: FlxEase.smootherStepIn,
						onComplete: function(twn:FlxTween)
						{
							escapeTimerGroup.visible = false;
						},
						startDelay: 2
					});

					//theManUpstairs = new TheManUpstairs(player.x - (48 - player.width / 2), player.y - ((48 - player.height) / 2), NORMAL);
					theManUpstairs = new TheManUpstairs(finalCollectLocation[0], finalCollectLocation[1], NORMAL);
					add(theManUpstairs);
					trace('SUMMONED THE BIG BAD :CC');
				});

			//incase of secquence breaking shit
			if (tempCamAngleEscTwn != null)
				tempCamAngleEscTwn.cancel();
			tempCamAngleEscTwn = FlxTween.tween(camGame, {angle: -1.25, zoom: camGame.zoom + 0.45}, Conductor.crochet * 16 / 1000, 
			{
				type: ONESHOT,
				ease: FlxEase.smoothStepOut,
				onComplete: function(twn:FlxTween)
				{
					tempCamAngleEscTwn = FlxTween.tween(camGame, {angle: 1.25}, Conductor.crochet * 16 / 1000, {type: PINGPONG, ease: FlxEase.smoothStepOut});
				}
			});
			FlxTween.tween(darkenScreen, {alpha: 0.15}, Conductor.crochet * 6 / 1000, {type: ONESHOT, ease: FlxEase.smoothStepOut, startDelay: Conductor.crochet * 6 / 1000});
		}
	}

	private function checkAndSwapMusic()
	{
		if (!inEscSeq)
		{
			if (clatter < 8)
			{
				if (heartBeatLevel < clatter)
				{
					trace('sequenceCheck' + seqCheck);
					trace('increased heartrate');
					heartBeatLevel = clatter;
					FlxG.sound.music.stop();
					FlxG.sound.playMusic('assets/minigame/music/map_1/HeartbeatLoop' + heartBeatLevel + '.ogg', 1, false);
					FlxG.sound.music.looped = true;
					FlxG.sound.music.onComplete = checkAndSwapMusic;
				}
			}
			else
			{
				//chromAbb.setValues(0.2, 0, 0.25);
				//Moved to a funct for easy??
				defaultEscapeTime = 60;
				escTimeBar.setRange(0, defaultEscapeTime);
				FlxG.sound.play('assets/minigame/sounds/MaxClatter.ogg', 1, false);
				FlxTween.tween(preEscMusGroup, {volume: 0}, Conductor.crochet * 4 / 1000, 
				{	
					type: ONESHOT, 
					ease: FlxEase.smoothStepOut,
					onComplete: function(twn:FlxTween)
					{
						preEscMusGroup.stop();
					}
				});
				triggerEscapeSeq();
			}
		}
		else
		{
			trace('sequenceCheck' + seqCheck);
			switch (seqCheck)
			{
				case 1:
					trace('SKIBIDI !!!!!');
					if (timerMultTween != null)
						timerMultTween.cancel();
					timerMult = 1;
					seqCheck = 2;
					FlxG.sound.music.stop();
					Conductor.changeBPM(180);
					curBeat = 0;
					//fakeBeat = 0;
					Conductor.songPosition = 0;
					FlxG.sound.playMusic('assets/minigame/music/ExitSequenceThemeLoop.ogg', 1, false, preSusMusGroup);
					FlxG.sound.music.looped = true;
					FlxG.sound.music.onComplete = checkAndSwapMusic;
					if (FlxG.random.bool(50))
						FlxG.sound.music.time = FlxG.sound.music.length / 2;
			}
		}
	}

	//check id - just a counter for this function to allow reusability
	var cid:Int = 0;
	private function getTheFuckOutMusic()
	{
		switch (cid)
		{
			case 1:
				if (timerMultTween != null)
				{
					timerMultTween.cancel();
					timerMultTween = FlxTween.tween(this, {timerMult: 0}, Conductor.crochet * 7 / 1000, 
					{	
						type: ONESHOT, 
						ease: FlxEase.smoothStepOut,
						onComplete: function(twn:FlxTween)
						{
							timerMultTween = null;
						}
					});
				}

				if (FlxG.sound.music.playing)
				{
					musicTween = FlxTween.tween(preSusMusGroup, {volume: 0}, Conductor.crochet * 16 / 1000, 
					{	
						type: ONESHOT, 
						ease: FlxEase.smoothStepOut,
						onComplete: function(twn:FlxTween)
						{
							preSusMusGroup.stop();
							musicTween = null;
						}
					});
				}
				
				cid = 2;

				suspenseEscMusicIntro = FlxG.sound.play('assets/minigame/music/ExitSequenceThemeSuspenseIntro.ogg', 1, FlxG.sound.defaultMusicGroup);
				FlxTween.tween(this, {defaultCamZoom: 4.5}, Conductor.crochet * 8 / 1000, {type: ONESHOT, ease: FlxEase.smoothStepOut});
				suspenseEscMusicIntro.onComplete = getTheFuckOutMusic;
			case 2:
				trace ('HAUR?????');
				if (timerMultTween != null)
				{
					timerMultTween.cancel();
				}
				if (musicTween != null)
					musicTween.cancel();
				timerMult = 1;
				seqCheck = 3;
				FlxG.sound.music.stop();
				Conductor.changeBPM(240);
				curBeat = 0;
				//fakeBeat = 0;
				Conductor.songPosition = 0;
				FlxG.sound.playMusic('assets/minigame/music/ExitSequenceThemeSuspenseDrop.ogg', 1, false, FlxG.sound.defaultMusicGroup);
				FlxG.sound.music.looped = false;
				FlxG.sound.music.onComplete = checkAndSwapMusic;
				defaultCamZoom = 3.8;
		}
	}

	var lockTheNextDoorThePlayerOverlapsWith:Bool = false; //absolutely EVIL and MISCHEVIOUS ASS BOOL!!!
	//followed by an ABSOLUTELY VILE AND DISGUSTING FUNCTION
	private function uglyEvilWorkaroundFunction(player:Player, object:Interactibles)
	{
		if (object.type == DOOR)
		{
			lockTheNextDoorThePlayerOverlapsWith = false;
			object.isLocked = true;
			doorCloseSound = FlxG.sound.load('assets/minigame/sounds/doorClose-wood_' + FlxG.random.int(1, 4) + '.ogg', FlxG.random.float(0.6, 0.75));
			doorCloseSound.pitch = FlxG.random.float(0.4, 0.6);
			doorCloseSound.play(true);
		}
	}

	//Interact Functions
	function interactFunct(player:Player, object:Interactibles)
	{
		switch (object.type)
		{
			case DOOR:
				if (player.canMove && !object.isLocked)
				{
					//Room-dependent Door Shit
					//Maybe turn this into switch(){case:} one day
					if (object.doorID == 0 && inEscSeq)
					{
						//A check to allow us to play the correct ending sound - default to true cuz there's only 1 if statement for false - meaning lesser vars to set for me, meaning less writing, meaning more time to do other stuff, meaning- 
						var musicWasSuspense:Bool = true;

						//FadeOut esc musics - whicheverthefuck is currently playing
						//Not elseIfs because multiple of them can play atOnce
						//dontAsk me why imTyping thisWay
						//guh, so much if statements just to fade out music - it's not gunna tank performance much but it is a lil hard to read :3
						//eitherway, it works (i think) - and hey we get sick ass adaptive music for it so yea why not :3
						if (cid == 2 && seqCheck == 3)
						{
							//Stops suspense loop
							FlxTween.tween(FlxG.sound.music, {volume: 0}, 2.5, 
							{	
								type: ONESHOT, 
								ease: FlxEase.smoothStepOut,
								onComplete: function(twn:FlxTween)
								{
									FlxG.sound.music.stop();
									musicTween = null;
								}
							});
						}
						else //Stops normal and suspense intro escape music
						{
							if (preSusMusGroup.containsPlaying())
							{
								if (musicTween != null)
									musicTween.cancel();
								musicTween = FlxTween.tween(preSusMusGroup, {volume: 0}, 2.5, 
								{	
									type: ONESHOT, 
									ease: FlxEase.smoothStepOut,
									onComplete: function(twn:FlxTween)
									{
										preSusMusGroup.stop();
										musicTween = null;
									}
								});

								musicWasSuspense = false;
							}

							if (suspenseEscMusicIntro != null && suspenseEscMusicIntro.playing)
							{
								FlxTween.tween(suspenseEscMusicIntro, {volume: 0}, 2.5, 
								{	
									type: ONESHOT, 
									ease: FlxEase.smoothStepOut,
									onComplete: function(twn:FlxTween)
									{
										suspenseEscMusicIntro.stop();
										preSusMusGroup.stop();
										musicTween = null;
									}
								});
							}
						}

						if (!timesUp)
						{
							//Stop timer and tween timer thingy
							if (escapeTimer != null)
								escapeTimer.cancel();
							FlxTween.tween(escapeTimerGroup, {y: -100}, 1.5, 
								{	
									type: ONESHOT, 
									ease: FlxEase.smootherStepIn,
									onComplete: function(twn:FlxTween)
									{
										escapeTimerGroup.visible = false;
									},
									startDelay: 0.5
								});
						}

						//then wes plays the sound s
						if (musicWasSuspense)
							FlxG.sound.play('assets/minigame/music/ExitSequenceThemeSuspenseEnd.ogg', 1, FlxG.sound.defaultMusicGroup);
						else
							FlxG.sound.play('assets/minigame/music/ExitSequenceThemeEnd.ogg', 1, FlxG.sound.defaultMusicGroup);

						//then we actually do shits LMFAO
						object.isLocked = true;
						//we should change the doorID system to something more robust
						//something like object.otherDoor or sum shit like that so that they're actually linked to eachj other
						//for now, have this shitty horrible ass fix LMFAOOO

						//player.stopAction(true, true);
						player.canMove = false;
						player.setPosition(object.x - (player.width - object.width), object.y - (player.height - object.height));
						playerResetPos = [object.destination[0] - (player.width - object.width), object.destination[1] - (player.height - object.height)];
						if (theManUpstairs != null && theManUpstairs.exists)
						{
							//he dont know what hit em
							theManUpstairs.quellTheDemon(100, true, true);
							//a whopping 4 FLXTWEENS!!! AGAIN!!!!
							FlxTween.tween(theManUpstairs.dadSuspenseMusFar, {volume: 0}, 2.5, {type: ONESHOT, ease: FlxEase.smoothStepInOut});
							FlxTween.tween(theManUpstairs.dadSuspenseMusNear, {volume: 0}, 2.5, {type: ONESHOT, ease: FlxEase.smoothStepInOut});
							FlxTween.tween(theManUpstairs.dadSNDFar, {volume: 0}, 2.5, {type: ONESHOT, ease: FlxEase.smoothStepInOut});
							FlxTween.tween(theManUpstairs.dadSNDNear, {volume: 0}, 2.5, {type: ONESHOT, ease: FlxEase.smoothStepInOut});
						}
						//DoorSounds
						if (doorCloseSound != null && doorCloseSound.playing)
							doorCloseSound.stop();
						//Open
						doorOpenSound = FlxG.sound.load('assets/minigame/sounds/doorOpen-wood_' + FlxG.random.int(1, 4) + '.ogg', FlxG.random.float(0.9, 1));
						doorOpenSound.pitch = FlxG.random.float(0.35, 0.55);
						doorOpenSound.play(true);
						camHUD.fade(FlxColor.WHITE, 2.5, false, function()
						{
							camHUD.stopFX();
							camHUD.flash(FlxColor.WHITE, 1);
							if (tempCamAngleEscTwn != null)
								tempCamAngleEscTwn.cancel();
							camGame.angle = 0;
							darkenScreen.alpha = 0;
							camMovementOffset[0] = 0;
							camMovementOffset[1] = 0;
							camMovementLerp[0] = 0;
							camMovementLerp[1] = 0;
							player.setPosition(object.destination[0] - (player.width - object.width), object.destination[1] - (player.height - object.height));
							//camFollow.setPosition(player.getMidpoint().x, player.getMidpoint().y - 5);
							player.canMove = true;
							lockTheNextDoorThePlayerOverlapsWith = true;
						}, true);
					}
					else
					{
						//player.stopAction(true, true);
						player.setPosition(object.x - (player.width - object.width), object.y - (player.height - object.height));
						playerResetPos = [object.destination[0] - (player.width - object.width), object.destination[1] - (player.height - object.height)];
						//if (theManUpstairs != null && theManUpstairs.exists)
							//theManUpstairs.quellTheDemon(15, true, true);
						player.canMove = false;
						//DoorSounds
						if (doorCloseSound != null && doorCloseSound.playing)
							doorCloseSound.stop();
						//Open
						doorOpenSound = FlxG.sound.load('assets/minigame/sounds/doorOpen-wood_' + FlxG.random.int(1, 4) + '.ogg', FlxG.random.float(0.9, 1));
						doorOpenSound.pitch = FlxG.random.float(0.8, 1.2);
						doorOpenSound.play(true);
						new FlxTimer().start(Conductor.stepCrochet / 1000, function(tmr:FlxTimer)
						{
							if (pseudoCamFade.alpha < 1)
								pseudoCamFade.alpha += 0.25;
							else
							{
								camMovementOffset[0] = 0;
								camMovementOffset[1] = 0;
								camMovementLerp[0] = 0;
								camMovementLerp[1] = 0;
								player.setPosition(object.destination[0] - (player.width - object.width), object.destination[1] - (player.height - object.height));
								camFollow.setPosition(player.getMidpoint().x, player.getMidpoint().y - 5);
								/*if (theManUpstairs != null && theManUpstairs.exists)
								{
									theManUpstairs.x = player.x - (theManUpstairs.width - player.width / 2);
									theManUpstairs.y = player.y - ((theManUpstairs.height - player.height) / 2);
									theManUpstairs.quellTheDemon(2, true);
								}*/
								if (theManUpstairs != null && theManUpstairs.exists)
									theManUpstairs.quellTheDemon(1, true);
								new FlxTimer().start(Conductor.stepCrochet / 2 / 1000, function(tmr:FlxTimer)
								{
									if (pseudoCamFade.alpha > 0)
										pseudoCamFade.alpha -= 0.25;
									else
									{
										player.canMove = true;
										//Close
										doorCloseSound = FlxG.sound.load('assets/minigame/sounds/doorClose-wood_' + FlxG.random.int(1, 4) + '.ogg', FlxG.random.float(0.6, 0.75));
										doorCloseSound.pitch = FlxG.random.float(0.8, 1.2);
										doorCloseSound.play(true);
									}
								}, 5);
							}
						}, 5);
					}
				}
				else if (player.canMove)
				{
					//Replace with locked door sound!!!!!
					FlxG.sound.play(Paths.sound('confirmMenuLocked'), 0.5);
				}
			case OTHER:
				var placeholderTXT:FlxText = new FlxText(0, FlxG.height - 80, FlxG.width - 100, '', 25);
				placeholderTXT.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
				placeholderTXT.scrollFactor.set();
				placeholderTXT.screenCenter(X);
				placeholderTXT.borderSize = 1.25;
				placeholderTXT.cameras = [camHUD];
				add(placeholderTXT);

				var placeHolderCount:Int = 0;
				placeholderTXT.text = object.dialogueArray[0];
				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					placeHolderCount++;
					if (placeHolderCount != object.dialogueArray.length)
						placeholderTXT.text = object.dialogueArray[placeHolderCount];
					else
						placeholderTXT.destroy();
				}, object.dialogueArray.length + 1);
		}
	}
	
	private function playerFell():Void
	{
		player.canMove = false;
		//player.hurt(10);
		//if (player.health <= 0)
			//playerDied();
		//else
		//{
			//placeholder snd
			FlxG.sound.play('assets/minigame/sounds/playerDie.ogg', 0.75, false);
			FlxTween.tween(darkenScreen, {alpha: 1}, 0.5, {type: ONESHOT, ease: FlxEase.cubeOut, onComplete: 
				function(twn:FlxTween)
				{
					player.setPosition(playerResetPos[0], playerResetPos[1]);
					camFollow.setPosition(player.getMidpoint().x, player.getMidpoint().y - 20);
					camMovementLerp[1] *= -0.5;
					FlxG.sound.play('assets/minigame/sounds/playerRespawn.ogg', 0.75, false);
					FlxTween.tween(darkenScreen, {alpha: 0}, 0.35, {type: ONESHOT, ease: FlxEase.cubeOut});
					player.canMove = true;
				}});
		//}
	}

	private function playerDied()
	{
		if (theManUpstairs != null && theManUpstairs.exists)
		{
			theManUpstairs.aiStatus = 'inactive';
			theManUpstairs.kill();
			theManUpstairs.destroy();
		}
		FlxG.sound.music.stop();
		preSusMusGroup.stop();
		preEscMusGroup.stop();
		darkenScreen.alpha = 0.15;
		player.canMove = false;
		var dedSound:FlxSound;
		//placeholder snd
		dedSound = FlxG.sound.play('assets/minigame/sounds/playerDie.ogg', 0.75, false);
		dedSound.pitch = 1.5;
		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			showGameoverScreen();
		});
	}

	var jumpscareSprite:FlxSprite;
	var jumpscaredPlayer:Bool = false;
	function jumpscareGameOver(player:Player, him:TheManUpstairs)
	{
		if (!jumpscaredPlayer)
		{
			trace('whuh');
			if (him.aiStatus == 'chase' && player.canMove) //gotta make it fair lol
			{
				jumpscaredPlayer = true;
				player.canMove = false;

				#if windows
				// Updating Discord Rich Presence
				if (FlxG.save.data.showPresence)
					DiscordClient.changePresence("(it wasn't your fault.)", null, "apppresence-dark");
				#end
				
				him.kill();
				him.destroy();

				camHUD.flash(FlxColor.RED, 0.125);

				/*CoolGameFeelThings.HitStop.doSlowDown(1, 0.125, true, function()
					{
						//After the slowdown finishes - ermm idk if this works -AWH
						defaultCamZoom *= 1.5;
						darkenScreen.alpha = 1;
						var jumpScareSnd:FlxSound = FlxG.sound.play(Paths.sound('boh'), 0.5, false);
						if (theManUpstairs != null && theManUpstairs.exists)
							theManUpstairs.quellTheDemon(1, true);
						camShake(true, false, 0.075, 1);
						new FlxTimer().start(0.5, function (tmr:FlxTimer)
						{
							jumpScareSnd.stop();
							him.kill();
							him.destroy();
							FlxG.sound.music.stop();
							camGame.visible = false;
							showGameoverScreen();
						});
					}
				);*/

				//camGame.shakeFlashSprite = false;
				//camHUD.shakeFlashSprite = false;

				/*var dedSound:FlxSound;
				dedSound = FlxG.sound.play(Paths.sound("damageAlert_fail"), 0.75, false);
				dedSound.pitch = 0.5;*/

				//Jumpscare Shit
				jumpscareSprite = new FlxSprite(0, 0).loadGraphic(Paths.image('jumpscare'));
				jumpscareSprite.angle = -6;
				jumpscareSprite.antialiasing = FlxG.save.data.antialiasing;
				jumpscareSprite.setGraphicSize(Std.int(jumpscareSprite.width * 0.1));
				jumpscareSprite.scrollFactor.set(1, 1);
				jumpscareSprite.updateHitbox();
				jumpscareSprite.screenCenter();
				jumpscareSprite.cameras = [camHUD];
				jumpscareSprite.visible = false;
				add(jumpscareSprite);

				//var randJumpTimeLol:Float = FlxG.random.float(2.5, 5);

				//new FlxTimer().start(randJumpTimeLol, function(tmr:FlxTimer)
				//{
					FlxG.sound.play(Paths.sound('boh'), 1, false);
					jumpscareSprite.visible = true;
					jumpscaredPlayer = true;
					//camHUD.focusOn(jumpscareSprite.getPosition());
					camHUD.shake(0.075, 2, true);
					new FlxTimer().start(0.35, function(tmr:FlxTimer)
					{
						new FlxTimer().start(0.35, function(tmr:FlxTimer){jumpscareSprite.alpha = 0.15;});
						showGameoverScreen();
					});
				//});
			}
		}
	}

	var textAlpha:Float = 0;
	private function showGameoverScreen()
	{
		player.visible = false;

		var dummyBlackScreen:FlxSprite = new FlxSprite(-FlxG.width * defaultCamZoom,
			-FlxG.height * defaultCamZoom).makeGraphic(FlxG.width * 4, FlxG.height * 4, 0xFF160025);
		dummyBlackScreen.scrollFactor.set();
		dummyBlackScreen.alpha = 0;
		dummyBlackScreen.screenCenter();
		dummyBlackScreen.cameras = [camHUD];
		add(dummyBlackScreen);

		var randAngle:Float = FlxG.random.float(3, -5);

		var textLol:FlxText = new FlxText(0, 0, 0, "GAME OVER!", 80);
		textLol.setFormat(Paths.font("Times New Roman"), 100, FlxColor.WHITE, CENTER);
		textLol.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1.5);
		textLol.scale.set(15, 15);
		textLol.screenCenter();
		//textLol.scrollFactor(1, 1);
		textLol.alpha = 0;
		textLol.antialiasing = true;
		textLol.cameras = [camHUD];
		textLol.angularVelocity = -randAngle * 1.5;
		add(textLol);

		FlxG.sound.play('assets/minigame/sounds/SND_GameOver.ogg', 1, false);

		//a Whopping 4 TWEENS!!!
		FlxTween.tween(dummyBlackScreen, {alpha: 0.5}, 0.35, {type: ONESHOT, ease: FlxEase.cubeOut, startDelay: 0.25});
		FlxTween.tween(this, {textAlpha: 1}, 0.35,
		{
			type: ONESHOT, 
			ease: FlxEase.smoothStepInOut, 
			startDelay: 0.5,
			onUpdate: function(twn:FlxTween)
			{
				textLol.alpha = textAlpha;
			},
		});
		FlxTween.tween(textLol.scale, {x: 0.8,  y: 0.8}, 0.25, 
		{
			type: ONESHOT,
			ease: FlxEase.quartIn,
			startDelay: 0.5,

			onUpdate: function(twn:FlxTween)
			{
				textLol.screenCenter();
			},

			onComplete: function(twn:FlxTween)
			{
				dummyBlackScreen.alpha = 0.25;
				FlxTween.tween(textLol.scale, {x: 1, y: 1}, 0.35,
				{
					type: ONESHOT,
					ease: FlxEase.elasticOut,
					onUpdate: function(twn:FlxTween)
					{
						textLol.screenCenter();
					},
				});
				textLol.angularVelocity = 0;
				FlxTween.tween(textLol, {angle: randAngle}, 0.5, {type: ONESHOT, ease: FlxEase.elasticOut});
				camHUD.stopFX();
				camShake('camHUD', true, true, 2, 0.4, 0.25);
				camHUD.flash(FlxColor.RED, 1);
				camGame.visible = false;
				new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					Conductor.songPosition = 0;
					isResetting = true;
					FlxG.resetState();
				});
			}
		});
	}

	function pickupFunct(player:Player, object:Collectibles)
	{
		if (object.isActive)
		{
			object.isActive = false;
			switch (object.type)
			{
				case FINAL:
					object.kill();
					FlxG.sound.play('assets/minigame/sounds/getFinalPickup.ogg', 1);
					//player.stopAction(true, true);
					player.canMove = false;
					if (seqCheck != 3)
						FlxG.sound.music.fadeOut(3.8);
					FlxTween.tween(preEscMusGroup, {volume: 0}, Conductor.crochet * 8 / 1000, 
					{	
						type: ONESHOT, 
						ease: FlxEase.smoothStepOut,
						onComplete: function(twn:FlxTween)
						{
							preEscMusGroup.stop();
						}
					});
					FlxTween.tween(this, {defaultCamZoom: 6}, 4, {type: ONESHOT, ease: FlxEase.smoothStepOut,
					onComplete: function(twn:FlxTween)
						{
							defaultCamZoom = 4;
							player.canMove = true;
							FlxG.camera.flash(DisclaimerState.flashColor, Conductor.crochet * 4 / 1000);
							triggerEscapeSeq();
						}});
				case SECRET:
					object.kill();
					FlxG.sound.play(Paths.sound('confirmMenu'), 0.5);
			}
		}
	}

	function clatterFunct(player:Player, clatterer:Clatterer)
	{
		if ((player.velocity.x > 15 || player.velocity.x < -15) && clatterer.canClatter)
		{
			clatterer.canClatter = false;
			/*if (clatterCoyote != null && clatterCoyote.active)
			{
				trace('le cancel');
				clatterCoyote.cancel();
			}*/
			
			clatterCoyote = new FlxTimer().start(0.1, function(tmr:FlxTimer)
			{
				if (player.curAction != SNEAK && player.curAction != SLIDE)
				{
					clatter += clatterer.clatterAmt;
					clatterer.playerMadeNoise();
		
					//Subtract some time from the timer
					if (inEscSeq)
					{
						if (escapeTimer.timeLeft >= 75)
						{
							escapeTimer.reset(escapeTimer.timeLeft - 15 > 0 ? escapeTimer.timeLeft - 15 : 3);
							if (escapeTimerTween != null)
								escapeTimerTween.cancel();				
							escapeTimerTween = FlxTween.color(escapeTimerText, 1.5, FlxColor.RED, 0xFFFFFFFF, 
							{
								type: ONESHOT,
								ease: FlxEase.smoothStepOut,
								onComplete: function(twn:FlxTween)
								{
									escapeTimerTween = null;
								}
							});
						}
					}
				}
				else
				{
					clatterer.canClatter = true;
					trace ('saved by the clatter coyote time');
				}
			});
		}
	}

	//Copied from playstate :33
	function calculateLerpTime(timeElapsed:Float, durationMultiplier:Float, ?min:Int = 0, ?max:Int = 1):Float
	{
		var returnLerpTime:Float = CoolUtil.boundTo(1 - (timeElapsed * durationMultiplier), min, max);
		return returnLerpTime;
	}

	
	//Lighting Shit Here
	//Code by WY Leong
	//But I was dumb enough to break it so I just did a work around involving blend modes...
	function updateLighting():Void
	{
		// In each update, create a new stageDarkRect based on the original
		// _stageDarkness's uncut rectangle, then cut a circle into it.
		var newMask = new FlxSprite();
 
		// Instead of cloning pixels (which will result in cached image)
		// we copy the cached _stageDarkness's bitmapData, then directly "reset"
		// the pixel data by drawing a fresh rectangle over it.
		newMask.loadGraphicFromSprite(_stageDarkness);
		newMask.pixels.fillRect(new Rectangle(0, 0, _stageDarkRect.width,_stageDarkRect.height), 0xFFFFFFFF);
 
		//A fading light effect because i am dumb
		FlxSpriteUtil.drawCircle(newMask, player.getMidpoint().x, player.getMidpoint().y, 60, 0xFFDCDCDC);
		FlxSpriteUtil.drawCircle(newMask, player.getMidpoint().x, player.getMidpoint().y, 40, 0xFF5A5A5A);
		FlxSpriteUtil.drawCircle(newMask, player.getMidpoint().x, player.getMidpoint().y, 30, 0xFF000000);
 
		// Draw onto the _stageDarkRect
		invertedAlphastageDarkRectFlxSprite(_stageDarkness, newMask, _stageDarkRect);
	}


	//Code also by WY Leong (bless them)
	function invertedAlphastageDarkRectFlxSprite(sprite:FlxSprite, stageDarkRect:FlxSprite, output:FlxSprite):FlxSprite
	{
		// Solution based on the discussion here:
		// https://groups.google.com/forum/#!topic/haxeflixel/fq7_Y6X2ngY
 
		// NOTE: The code below is the same as FlxSpriteUtil.alphastageDarkRectFlxSprite(),
		// except it has an EXTRA section below.
 
		sprite.drawFrame();
		var data:BitmapData = sprite.pixels.clone();
		data.copyChannel(stageDarkRect.pixels, new Rectangle(0, 0, sprite.width, sprite.height), new Point(), BitmapDataChannel.ALPHA, BitmapDataChannel.ALPHA);
 
		// EXTRA:
		// this code applies a -1 multiplier to the alpha channel,
		// turning the opaque circle into a transparent circle.
		data.colorTransform(new Rectangle(0, 0, sprite.width, sprite.height), new ColorTransform(0,0,0,-1,0,0,0,255));
		// end EXTRA
 
		output.pixels = data;
		return output;
	}


	var isResetting:Bool = false;
	override function destroy()
	{
		if (!isResetting)
		{
			FlxG.sound.music.stop();

			transIn.camera = FlxCamera.defaultCameras[FlxCamera.defaultCameras.length];
			transOut.camera = FlxCamera.defaultCameras[FlxCamera.defaultCameras.length];

			//Dumping of cache
			Paths.clearStoredMemory();
			Paths.clearUnusedMemory();
		}
	}
}