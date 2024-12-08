//IN PAIN - TOO LAZY TO FIX UP PATHS.JSON TO WORK WITH THIS SHIT AUGHHHH
package lore_minigames;

import flixel.FlxObject;
import flixel.FlxState;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.tile.FlxTilemap;
//import flixel.FlxG;
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
	var defaultCamZoom = 6;
	var camFollow:FlxObject;
	var doCamFollowing:Bool = false;


	var screen:LoadingScreen = null;

	//SoundStuff
	var preEscMusGroup:FlxSoundGroup;
	var preSuspenseMusGroup:FlxSoundGroup;

	var escapeTimer:FlxTimer;
	var escapeTimerTween:FlxTween;
	var defaultEscapeTime:Int = 120;
	var escapeTimerGroup:FlxSpriteGroup = null;
	var escapeTimerText:FlxText;
	var escTimeBG:FlxSprite;
	var escTimeBar:FlxBar;
	var escTimeClock:FlxSprite;
	var escBarTracker:Float = 0;

	var doorOpenSound:FlxSound;
	var doorCloseSound:FlxSound;

	public static var weekNum:Int = 0;

	override public function create()
	{
		#if windows
		// Updating Discord Rich Presence
		if (FlxG.save.data.showPresence)
			DiscordClient.changePresence("Somewhere Familiar...", null, "apppresence-strange");
		#end
		
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();
		Conductor.changeBPM(115);
		
		//Volume shits
		preEscMusGroup = new FlxSoundGroup(FlxG.sound.defaultMusicGroup.volume);
		preSuspenseMusGroup = new FlxSoundGroup(FlxG.sound.defaultMusicGroup.volume);

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
		
		darkenScreen = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 4, FlxG.height * 4, 0xFFFFFFFF);
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

		heartBeatLevel = 0;
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
				player.setPosition(entity.x, (entity.y + 32) - 28);
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
	private function followPlayer(elapsed:Float):Void
	{
		camMovementOffset[0] = (0.05 * player.velocity.x) + camHoldShakeAdditive[0];
		camMovementOffset[1] = (0.05 * player.velocity.y) + camHoldShakeAdditive[1];
		camMovementLerp[0] = FlxMath.lerp(camMovementOffset[0], camMovementLerp[0], calculateLerpTime(elapsed, 2.25, 0, 1));
		camMovementLerp[1] = FlxMath.lerp(camMovementOffset[1], camMovementLerp[1], calculateLerpTime(elapsed, 2.25, 0, 1));

		camFollow.setPosition(player.getMidpoint().x + camMovementLerp[0], player.getMidpoint().y - 5 + camMovementLerp[1]);
	}

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
		if (player.status != SNEAKING && !player.forceSneak)
			FlxG.overlap(player, clatterGroup, clatterFunct);
		FlxG.overlap(player, collectiblesGroup, pickupFunct);

		//EVIL ASS FUNCTION!!! FIX AND REMOVE THIS ASAP!!!!!
		if (lockTheNextDoorThePlayerOverlapsWith)
			FlxG.overlap(player, interactiblesGroup, uglyEvilWorkaroundFunction);
		
		if (doCamFollowing)
			followPlayer(elapsed);

		if (theManUpstairs != null && theManUpstairs.exists && inEscSeq)
		{
			//this updates every frame - is that alright??
			//shit way but ermm ermmm LMFAOOO erRRMMM ERMMM
			if (theManUpstairs.dadSNDNear.getActualVolume() > 0)
			//{
				camShake(false, false, 3, 0.05 * theManUpstairs.dadSNDNear.getActualVolume(), 0.05);
				//trace('vol ' + theManUpstairs.dadSNDNear.getActualVolume());
			//}

			FlxG.overlap(player, theManUpstairs, jumpscareGameOver);
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

		/*if (FlxG.keys.justPressed.P)
		{
			camShake(true, false, 0.05, 1);
		}*/

		if (controls.BACK && !movedBack)
		{
			//Week dependent Cancel Menu Sounds
			switch (FlxG.save.data.weekUnlocked)
			{
				case 2:
					FlxG.sound.play(Paths.sound('cancelMenu'));
				case 3:
					FlxG.sound.play(Paths.sound('cancelMenu'));
				case 6:
					FlxG.sound.play(Paths.sound('cancelMenu'));
				default:
					if (!FreeplayState.freeplayMusicPlaying)
						FlxG.sound.play(Paths.sound('cancelMenu'));
					else
						FlxG.sound.play(Paths.sound('cancelMenu'));
			}
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

	var droneDeterminator:Int = 1;
	var uniformDeterminator:Int = 1;
	var additionsDeterminator:Int = 1;
	var flavourDeterminator:Int = 0;
	var fakeBeat:Int = 0;

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

		trace('realBeat ' + curBeat + ' | fakeBeat ' + fakeBeat);

		switch (seqCheck)
		{
			//Normal
			case 0:
				if (!inEscSeq && clatter >= 0)
				{
					if (fakeBeat % 2 == 0)
					{
						camHoldShakeAdditive[0] = FlxG.random.int(-clatter, clatter) / 8;
						camHoldShakeAdditive[1] = FlxG.random.int(-clatter, clatter) / 8;
					}

					if (fakeBeat % 32 == 0)
					{
						//Randomise Tracks
						switch (clatter)
						{
							case 0:
								droneDeterminator = 1;
								additionsDeterminator = 1;
								uniformDeterminator = 0;
							case 1 | 2:
								uniformDeterminator = 1;
								if (FlxG.random.bool(50))
									droneDeterminator = FlxG.random.int(1, 2);
				
								if (FlxG.random.bool(50))
									additionsDeterminator = FlxG.random.int(1, 2);
							case 3:
								uniformDeterminator = 1;
								if (FlxG.random.bool(80))
									droneDeterminator = FlxG.random.int(1, 2);
								
								if (FlxG.random.bool(80))
									additionsDeterminator = FlxG.random.int(1, 2);
							case 4:
								uniformDeterminator = 2;
								droneDeterminator = FlxG.random.int(1, 2);
								additionsDeterminator = FlxG.random.int(1, 2);
							default:
								uniformDeterminator = 2;
								droneDeterminator = 2;
								additionsDeterminator = 2;
						}

						FlxG.sound.play('assets/minigame/music/map_1/PadsDrone' + droneDeterminator + '.ogg', 1, false, preEscMusGroup);
						if (uniformDeterminator > 0)
							FlxG.sound.play('assets/minigame/music/map_1/BackingPads' + uniformDeterminator + '.ogg', 0.75, false, preEscMusGroup);
						FlxG.sound.play('assets/minigame/music/map_1/Additions' + additionsDeterminator + '.ogg', 1, false, preEscMusGroup);
					}

					switch (clatter)
					{
						case 0:
							flavourDeterminator = 0;
						case 1 | 2 | 3:
							if (FlxG.random.bool(50))
								flavourDeterminator = FlxG.random.int(1, 2);
			
							if (FlxG.random.bool(50))
								flavourDeterminator = FlxG.random.int(1, 2);
						default:
							flavourDeterminator = FlxG.random.int(1, 4);
					}

					if (flavourDeterminator > 0)
					{
						if(FlxG.random.bool(0.85) && fakeBeat >= beatFlavoured + beatOffset)
						{
							beatFlavoured = fakeBeat;
							beatOffset = FlxG.random.int(0, 16);
							FlxG.sound.play('assets/minigame/music/map_1/FlavourSFX' + flavourDeterminator + '.ogg', FlxG.random.float(0.5, 0.8), false, preEscMusGroup);
						}
					}
				}
				fakeBeat++;
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
				fakeBeat++;
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
			player.primeForEscSeq();
			trace('run for your life');
			FlxG.sound.music.stop();
			FlxG.sound.playMusic('assets/minigame/music/ExitSequenceThemeIntro.ogg', 1, false, preSuspenseMusGroup);
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
			fakeBeat = 0;
			Conductor.songPosition = 0;
			seqCheck = 1;

			escapeTimerGroup.visible = true;
			FlxTween.tween(escapeTimerGroup, {y: timerGroupTargetY}, 3, {type: ONESHOT, ease: FlxEase.elasticOut});

			#if windows
			// Updating Discord Rich Presence
			if (FlxG.save.data.showPresence)
				DiscordClient.changePresence("The Clock is Ticking...", "(You might want to get going.)", "apppresence-strange");
			#end

			escapeTimer = new FlxTimer().start(defaultEscapeTime, function(tmr:FlxTimer)
				{
					#if windows
					// Updating Discord Rich Presence
					if (FlxG.save.data.showPresence)
						DiscordClient.changePresence("Time's Up!", "(Good luck.)", "apppresence-strange");
					#end

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
		if (!inEscSeq && clatter < 7)
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
					fakeBeat = 0;
					Conductor.songPosition = 0;
					FlxG.sound.playMusic('assets/minigame/music/ExitSequenceThemeLoop.ogg', 1, false, preSuspenseMusGroup);
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
					musicTween = FlxTween.tween(preSuspenseMusGroup, {volume: 0}, Conductor.crochet * 16 / 1000, 
					{	
						type: ONESHOT, 
						ease: FlxEase.smoothStepOut,
						onComplete: function(twn:FlxTween)
						{
							preSuspenseMusGroup.stop();
							musicTween = null;
						}
					});
				}
				
				cid = 2;

				suspenseEscMusicIntro = FlxG.sound.play('assets/minigame/music/ExitSequenceThemeSuspenseIntro.ogg', 1, FlxG.sound.defaultMusicGroup);
				suspenseEscMusicIntro.onComplete = getTheFuckOutMusic;
			case 2:
				trace ('HAUR?????');
				if (timerMultTween != null)
				{
					timerMultTween.cancel();
					timerMult = 1;
				}
				if (musicTween != null)
					musicTween.cancel();
				seqCheck = 3;
				FlxG.sound.music.stop();
				Conductor.changeBPM(240);
				curBeat = 0;
				fakeBeat = 0;
				Conductor.songPosition = 0;
				FlxG.sound.playMusic('assets/minigame/music/ExitSequenceThemeSuspenseDrop.ogg', 1, false, FlxG.sound.defaultMusicGroup);
				FlxG.sound.music.looped = false;
				FlxG.sound.music.onComplete = checkAndSwapMusic;
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
							if (preSuspenseMusGroup.containsPlaying())
							{
								if (musicTween != null)
									musicTween.cancel();
								musicTween = FlxTween.tween(preSuspenseMusGroup, {volume: 0}, 2.5, 
								{	
									type: ONESHOT, 
									ease: FlxEase.smoothStepOut,
									onComplete: function(twn:FlxTween)
									{
										preSuspenseMusGroup.stop();
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
										preSuspenseMusGroup.stop();
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

						player.stopAction(true, true);
						player.canMove = false;
						player.setPosition(object.x + 7, object.y + 3);
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
							player.setPosition(object.destination[0] + 7, object.destination[1] + 3);
							camFollow.setPosition(player.getMidpoint().x, player.getMidpoint().y - 5);
							player.canMove = true;
							lockTheNextDoorThePlayerOverlapsWith = true;
						}, true);
				}
					else
					{
						player.stopAction(true, true);
						player.setPosition(object.x + 7, object.y + 3);
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
								player.setPosition(object.destination[0] + 7, object.destination[1] + 3);
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
					player.stopAction(true, true);
					player.canMove = false;
					FlxTween.tween(preEscMusGroup, {volume: 0}, Conductor.crochet * 8 / 1000, 
					{	
						type: ONESHOT, 
						ease: FlxEase.smoothStepOut,
						onComplete: function(twn:FlxTween)
						{
							preEscMusGroup.stop();
						}
					});
					FlxTween.tween(this, {defaultCamZoom: 8}, 4, {type: ONESHOT, ease: FlxEase.smoothStepOut,
					onComplete: function(twn:FlxTween)
						{
							defaultCamZoom = 7;
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
				if (player.status != SNEAKING && !player.forceSneak)
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

	var stopActiveTweening:Bool = false;
	var jumpscareSprite:FlxSprite;
	var jumpscaredPlayer:Bool = false;
	function jumpscareGameOver(player:Player, him:TheManUpstairs)
	{
		if (him.aiStatus == 'chase' && player.canMove) //gotta make it fair lol
		{
			#if windows
			// Updating Discord Rich Presence
			if (FlxG.save.data.showPresence)
				DiscordClient.changePresence("(it wasn't your fault.)", null, "apppresence-dark");
			#end

			//camGame.shakeFlashSprite = false;
			//camHUD.shakeFlashSprite = false;
			him.aiStatus = 'inactive';
			him.kill();
			him.destroy();
			FlxG.sound.music.stop();
			darkenScreen.alpha = 1;
			player.canMove = false;
			camGame.visible = false;
			var dedSound:FlxSound;
			dedSound = FlxG.sound.play(Paths.sound("damageAlert_fail"), 0.75, false);
			dedSound.pitch = 0.5;

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

			var randJumpTimeLol:Float = FlxG.random.float(2.5, 5);

			new FlxTimer().start(randJumpTimeLol, function(tmr:FlxTimer)
			{
				FlxG.sound.play(Paths.sound('boh'), 1, false);
				jumpscareSprite.visible = true;
				jumpscaredPlayer = true;
				//camHUD.focusOn(jumpscareSprite.getPosition());
				camHUD.shake(0.075, 2, true);
				new FlxTimer().start(0.35, function(tmr:FlxTimer)
				{
					showGameoverScreen();
				});
			});
		}
	}
	
	var textAlpha:Float = 0;
	private function showGameoverScreen()
	{
		//PLACE OF HOLDER SDKBSFKB
		//jumpscareSprite.visible = false;
		//camHUD.stopFX();

		var dummyBlackScreen:FlxSprite = new FlxSprite(-FlxG.width * defaultCamZoom,
			-FlxG.height * defaultCamZoom).makeGraphic(FlxG.width * 4, FlxG.height * 4, 0xFF160025);
		dummyBlackScreen.scrollFactor.set();
		dummyBlackScreen.alpha = 0;
		dummyBlackScreen.screenCenter();
		dummyBlackScreen.cameras = [camHUD];
		add(dummyBlackScreen);

		var textLol:FlxText = new FlxText(0, 0, 0, "GAME OVER!", 80);
		textLol.setFormat(Paths.font("Times New Roman"), 100, FlxColor.WHITE, CENTER);
		textLol.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1.5);
		textLol.scale.set(15, 15);
		textLol.screenCenter();
		//textLol.scrollFactor(1, 1);
		textLol.alpha = 0;
		textLol.antialiasing = true;
		textLol.cameras = [camHUD];
		add(textLol);

		FlxG.sound.play('assets/minigame/sounds/SND_GameOver.ogg', 1, false);

		//a Whopping 3 TWEENS!!!
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
				jumpscareSprite.visible = false;
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
				new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					Conductor.songPosition = 0;
					isResetting = true;
					FlxG.resetState();
				});
			}
		});
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
		FlxG.sound.music.stop();
		if (!isResetting)
		{
			transIn.camera = FlxCamera.defaultCameras[FlxCamera.defaultCameras.length];
			transOut.camera = FlxCamera.defaultCameras[FlxCamera.defaultCameras.length];
		}
	}
}