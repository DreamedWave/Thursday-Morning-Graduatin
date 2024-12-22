package lore_minigames;

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

import flixel.util.FlxStringUtil;

//import lore_minigames.Interactibles;
//import lore_minigames.Clatterer;
//import lore_minigames.Collectibles;

class MinigameState extends MusicBeatState
{
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

	override public function create()
	{
		#if windows
		// Updating Discord Rich Presence
		if (FlxG.save.data.showPresence)
			DiscordClient.changePresence("Testing the Minigames!!!", null, "apppresence-strange");
		//DiscordClient.changePresence("Somewhere Familiar...", null, "apppresence-strange");
		#end
		
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
				player.setPosition(entity.x, (entity.y));
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

	//dont judge my var naming skills >:CC
	var camMovementLerp:Array<Float> = [0, 0];//the value tht gets tweened
	var camMovementOffset:Array<Float> = [0, 0]; //the ACTUAL value that instantly gets updated
	var camHoldShakeAdditive:Array<Float> = [0, 0];

	var timeLeftChecker:Float = 4364;
	var fatherElapsedCheck:Int = 0;
	override public function update(elapsed:Float)
	{		
		super.update(elapsed);

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
		{
			camMovementOffset[0] = (0.05 * player.velocity.x) + camHoldShakeAdditive[0];
			camMovementOffset[1] = (0.05 * player.velocity.y) + camHoldShakeAdditive[1];
			camMovementLerp[0] = FlxMath.lerp(camMovementOffset[0], camMovementLerp[0], calculateLerpTime(elapsed, 2.25, 0, 1));
			camMovementLerp[1] = FlxMath.lerp(camMovementOffset[1], camMovementLerp[1], calculateLerpTime(elapsed, 2.25, 0, 1));
	
			camFollow.setPosition(player.getMidpoint().x + camMovementLerp[0], player.getMidpoint().y - 15 + camMovementLerp[1]);
		}

		if (theManUpstairs != null && theManUpstairs.exists && inEscSeq)
		{
			//this updates every frame - is that alright??
			//shit way but ermm ermmm LMFAOOO erRRMMM ERMMM
			if (theManUpstairs.dadSNDNear.getActualVolume() > 0)
			//{
				camShake(false, false, 3, 0.05 * theManUpstairs.dadSNDNear.getActualVolume(), 0.05);
				//trace('vol ' + theManUpstairs.dadSNDNear.getActualVolume());
			//}

			//FlxG.overlap(player, theManUpstairs, playerDied);
			if (fatherElapsedCheck < 1)
			{
				theManUpstairs.playerPosition = player.getMidpoint();
				fatherElapsedCheck = 1;
			}
			else
				fatherElapsedCheck--;
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
			playerDied();

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
		
		if (clatter > 7)
			clatter = 7;

		if (seqCheck > 1 && !stopActiveTweening)
		{
			camGame.zoom = FlxMath.lerp(defaultCamZoom, camGame.zoom, calculateLerpTime(elapsed, 3, 0, 1));
			darkenScreen.alpha = FlxMath.lerp(0.15, darkenScreen.alpha, calculateLerpTime(elapsed, 1.5, 0, 1));
		}
	}

	var stopActiveTweening:Bool = false;
	//var fakeBeat:Int = 0;

	var beatOffset:Int = 0;
	var beatFlavoured:Int = 0;
	
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
				if (curBeat % 32 == 0)
				{
					FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_Layer' + clatter + '.ogg', 1, false, preEscMusGroup);
					switch (clatter)
					{
						case 1:
							if (FlxG.random.bool(30))
								FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_PianoCue0.ogg', 1, false, preEscMusGroup);
							else if (FlxG.random.bool(20))
								FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_PianoCue1.ogg', 1, false, preEscMusGroup);


						case 2 | 3:
							if (FlxG.random.bool(50))
								FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_PianoCue0.ogg', 0.8, false, preEscMusGroup);
							else if (FlxG.random.bool(30))
								FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_PianoCue1.ogg', 0.9, false, preEscMusGroup);

							if (clatter == 3 && FlxG.random.bool(20))
								FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_ChiptuneCue0.ogg', 0.65, false, preEscMusGroup);


						case 4 | 5:
							if (FlxG.random.bool(50))
								FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_PianoCue1.ogg', 0.6, false, preEscMusGroup);
							else if (FlxG.random.bool(50))
								FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_PianoCue0.ogg', 0.7, false, preEscMusGroup);

							if (FlxG.random.bool(30))
								FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_ChiptuneCue0.ogg', 0.75, false, preEscMusGroup);
							else if (clatter == 5 && FlxG.random.bool(20))
								FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_ChiptuneCue0.ogg', 0.65, false, preEscMusGroup);


							case 6 | 7:
							if (clatter ==6)
							{
								if (FlxG.random.bool(50))
									FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_PianoCue1.ogg', 0.3, false, preEscMusGroup);
								else if (FlxG.random.bool(60))
									FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_PianoCue0.ogg', 0.5, false, preEscMusGroup);
							}

							if (FlxG.random.bool(50))
								FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_ChiptuneCue0.ogg', 0.75, false, preEscMusGroup);
							else if (clatter == 7 && FlxG.random.bool(35))
								FlxG.sound.play('assets/minigame/music/map_1/AmbTheme_ChiptuneCue0.ogg', 0.65, false, preEscMusGroup);


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
		trace('sequenceCheck' + seqCheck);
		if (!inEscSeq)
		{
			if (heartBeatLevel < clatter)
			{
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
			switch (seqCheck)
			{
				case 0:
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
				FlxTween.tween(this, {defaultCamZoom: 5}, 4, {type: ONESHOT, ease: FlxEase.smoothStepOut});
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
						player.setPosition(object.x, object.y - (player.height - object.height));
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
							player.setPosition(object.destination[0], object.destination[1] - (player.height - object.height));
							camFollow.setPosition(player.getMidpoint().x, player.getMidpoint().y - 5);
							player.canMove = true;
							lockTheNextDoorThePlayerOverlapsWith = true;
						}, true);
					}
					else
					{
						//player.stopAction(true, true);
						player.setPosition(object.x, object.y - (player.height - object.height));
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
								player.setPosition(object.destination[0], object.destination[1] - (player.height - object.height));
								camFollow.setPosition(player.getMidpoint().x, player.getMidpoint().y - 5);
								/*if (theManUpstairs != null && theManUpstairs.exists)
								{
									theManUpstairs.x = player.x - (theManUpstairs.width - player.width / 2);
									theManUpstairs.y = player.y - ((theManUpstairs.height - player.height) / 2);
									theManUpstairs.quellTheDemon(2, true);
								}*/
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
		dedSound = FlxG.sound.play(Paths.sound("damageAlert_fail"), 0.75, false);
		dedSound.pitch = 1.5;
		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			showGameoverScreen();
		});
	}

	var textAlpha:Float = 0;
	private function showGameoverScreen()
	{
		//PLACE OF HOLDER SDKBSFKB
		//jumpscareSprite.visible = false;
		//camHUD.stopFX();
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
		textLol.angle = randAngle;
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
		FlxTween.tween(textLol, {angle: -randAngle}, 0.4, {type: ONESHOT, ease: FlxEase.elasticOut});
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
				camHUD.stopFX();
				camShake('camHUD', true, true, 2, 0.4, 0.5);
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
					FlxG.sound.play('assets/minigame/sounds/doorSND_Placeholder.ogg', 0.5);
			}
		}
	}

	function clatterFunct(player:Player, clatterer:Clatterer)
	{
		if ((player.velocity.x > 15 || player.velocity.x < -15) && clatterer.canClatter)
		{
			if (clatterCoyote != null && clatterCoyote.active)
				clatterCoyote.cancel();
			
			clatterCoyote = new FlxTimer().start(0.01, function(tmr:FlxTimer)
			{
				if (player.curAction != SNEAK && player.curAction != SLIDE)
				{
					clatterer.canClatter = false;
					clatter += clatterer.clatterAmt;
					clatterer.playerMadeNoise();
					new FlxTimer().start(3, function(tmr:FlxTimer)
					{
						clatterer.canClatter = true;
						clatterer.alpha = 0.25;
					});
		
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
					trace ('saved by the clatter coyote time');
			});
		}
	}

	//Copied from playstate :33
	function calculateLerpTime(timeElapsed:Float, durationMultiplier:Float, ?min:Int = 0, ?max:Int = 1):Float
	{
		var returnLerpTime:Float = CoolUtil.boundTo(1 - (timeElapsed * durationMultiplier), min, max);
		return returnLerpTime;
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