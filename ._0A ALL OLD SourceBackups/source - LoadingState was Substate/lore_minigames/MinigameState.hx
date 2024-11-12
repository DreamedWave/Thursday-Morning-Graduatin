package lore_minigames;

import flixel.FlxState;
import flixel.FlxCamera;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.tile.FlxTilemap;
import flixel.FlxG;
import flixel.util.FlxTimer;

import lore_minigames.DoorPortal;

class MinigameState extends MusicBeatState
{
	var player:Player;
	var map:FlxOgmo3Loader;

	var walls:FlxTilemap;
	var doorsGroup:FlxTypedGroup<DoorPortal>;
	var doorsLocationMap:Map<String, Array<Float>> = new Map<String, Array<Float>>(); //Format ([PortalID, PortalDestination], [PortalX, PortalY])
	var clatterGroup:FlxTypedGroup<FlxSprite>;

	var movedBack:Bool = false;
	public static var shakeCam:Bool = false;

	var clatter:Int = 0; //basically the decked out clank system :)))
	var risk:Int = 0; //basically the decked hazard system :DDD

	var blackScreen:FlxSprite;

	var camGame:FlxCamera;
	var camHUD:FlxCamera;

	override public function create()
	{
		camGame = new FlxCamera();
		camHUD = new FlxCamera();

		camHUD.bgColor.alpha = 0;
		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxCamera.defaultCameras = [camGame];

		transIn.camera = camHUD;
		transOut.camera = camHUD;

		camGame.zoom = 6;
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

		doorsGroup = new FlxTypedGroup<DoorPortal>();
		add(doorsGroup);
		
		clatterGroup = new FlxTypedGroup<FlxSprite>();
		add(clatterGroup);

		player = new Player();
		map.loadEntities(placeEntities, "entities");

		add(player);

		//trace("finally");
		FlxG.camera.follow(player, LOCKON, 1);

		blackScreen = new FlxSprite(0, 0).makeGraphic(FlxG.width * 3, FlxG.height * 3, 0xFF000000);
		blackScreen.scrollFactor.set();
		blackScreen.alpha = 0;
		blackScreen.cameras = [camHUD];
		add(blackScreen);

		var minigameSFX:Array<String> = ["walk0", "walk1", "walk2", "walk3", "walk4", "walk5", "jump0", "jump1", "jump2", "jump3", "jump4", "jump5"]; //, "land0", "land1", "land2", "land3", "land4", "land5", "landHard0", "landHard1", "landHard2", "landHard3", "landHard4", "landHard5"];
		for (i in minigameSFX)
		{
			FlxG.sound.load('assets/minigame/sounds/' + i + '.ogg');
		}
		
		super.create();
	}

	var totalDone:Int = 0;
	
	private function placeEntities(entity:EntityData, totalItems:Int)
	{
		if (entity.name == "player")
			player.setPosition(entity.x, (entity.y - 32) + player.height);
		else if (entity.name == "portal_door")
		{
			//definitely make a class for this
			var door:DoorPortal = new DoorPortal();
			door.setPosition(entity.x, entity.y);
			door.destinationID = entity.values.destinationInt;
			door.emitParticles = entity.values.emitParticles;
			door.locationID = entity.values.portal_ID + '_' + entity.values.destinationInt;
			doorsLocationMap.set(door.locationID, [entity.x, entity.y]);
			doorsGroup.add(door);
		}
		else if (entity.name == "clatter_producer")
		{
			//definitely make a class for this
			var clatterers:FlxSprite = new FlxSprite();
			clatterers.makeGraphic(32, 32, 0xFF640000);
			clatterers.setPosition(entity.x, entity.y);
			clatterers.alpha = 0.15;
			clatterGroup.add(clatterers);
			//clatterProducer.type = entity.type;
		}
		totalDone++;

		if (totalDone < totalItems)
			return;

		//Goes through every item in doorsGroup!
		doorsGroup.forEach(function(bobuxDoors:DoorPortal)
		{
			//get Location ID and split
			var split:Array<String> = bobuxDoors.locationID.split('_');
			//THEN invert the shit
			var loadID:String = '';
			if (Std.parseInt(split[1]) == 0)
				loadID = split[0] + '_1';
			else if (Std.parseInt(split[1]) == 1)
				loadID = split[0] + '_0';

			//Then retrieve the coords to place the player in!
			var locationArray:Array<Float> = doorsLocationMap.get(loadID);
			switch (Std.parseInt(split[1]))
			{
				case 0 | 1:
					bobuxDoors.destination[0] = Std.int(locationArray[0]);
					bobuxDoors.destination[1] = Std.int(locationArray[1]);
					trace ('set door ' + bobuxDoors.locationID + "'s tp coords to [" + locationArray[0] + ', ' + locationArray[1] + '].');
				default:
					//do nada for now >:))
			}
		});
	}

	var canDoor:Bool = true; //determines if player can interact withd doors
	var canClatter:Bool = true;

	override public function update(elapsed:Float)
	{
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
			isResetting = true;
			FlxG.resetState();
		}

		super.update(elapsed);

		if (FlxG.keys.justPressed.E && canDoor)
		{
			doorsGroup.forEach(function(bobuxDoor:DoorPortal)
			{
				if (player.overlaps(bobuxDoor))
				{
					canDoor = false;
					FlxG.sound.play('assets/minigame/sounds/doorSND_Placeholder.ogg', 1);
					new FlxTimer().start(Conductor.stepCrochet / 1000, function(tmr:FlxTimer)
					{
						if (blackScreen.alpha < 1)
							blackScreen.alpha += 0.25;
						else
						{
							player.setPosition(bobuxDoor.destination[0], bobuxDoor.destination[1]);
							new FlxTimer().start(Conductor.stepCrochet / 2 / 1000, function(tmr:FlxTimer)
							{
								if (blackScreen.alpha > 0)
									blackScreen.alpha -= 0.25;
								else
									canDoor = true;
							}, 5);
						}
					}, 5);
				}
			});
		}

		if (canClatter)
		{
			clatterGroup.forEach(function(clutterer:FlxSprite)
			{
				if (player.overlaps(clutterer))
				{
					canClatter = false;
					clatter++;
					FlxG.sound.play('assets/minigame/sounds/clatterSND_Placeholder.ogg', 1);
					new FlxTimer().start(5, function(tmr:FlxTimer)
					{
						canClatter = true;
					});
				}
			});
		}

		if (shakeCam)
		{
			shakeCam = false;
			FlxG.camera.shake(0.01, 0.2);
		}

		FlxG.collide(player, walls);
	}

	var isResetting:Bool = false;
	override function destroy()
	{
		if (!isResetting)
		{
			transIn.camera = FlxCamera.defaultCameras[FlxCamera.defaultCameras.length];
			transOut.camera = FlxCamera.defaultCameras[FlxCamera.defaultCameras.length];
		}
	}
}