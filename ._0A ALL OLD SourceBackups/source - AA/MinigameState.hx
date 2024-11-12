package;

import flixel.FlxState;
import flixel.addons.editors.ogmo.FlxOgmo3Loader;
import flixel.tile.FlxTilemap;
import flixel.FlxG;
import flixel.util.FlxTimer;

class MinigameState extends MusicBeatState
{
	var player:MinigamePlayer;
	var map:FlxOgmo3Loader;
	var walls:FlxTilemap;
	var movedBack:Bool = false;
	public static var shakeCam:Bool = false;

	override public function create()
	{
		FlxG.camera.zoom = 6;
		trace('mmm');
		map = new FlxOgmo3Loader('assets/minigame/rooms/minigame.ogmo', 'assets/minigame/rooms/room_0.json');
		trace("buh");
		walls = map.loadTilemap("assets/minigame/images/tilemap.png", "tiles");
		trace("bruh");
		walls.follow();
		walls.setTileProperties(1, NONE);
		walls.setTileProperties(2, NONE);
		walls.setTileProperties(3, ANY);
		walls.setTileProperties(4, ANY);
		walls.setTileProperties(5, ANY);
		walls.setTileProperties(6, ANY);
		walls.setTileProperties(7, ANY);
		//walls.setTileProperties(8, NONE);
		//walls.setTileProperties(9, NONE);
		trace("???");
		add(walls);

		player = new MinigamePlayer();
		map.loadEntities(placeEntities, "entities");
		add(player);

		trace("finally");
		FlxG.camera.follow(player, LOCKON, 1);
		
		super.create();
	}

	function placeEntities(entity:EntityData)
	{
		if (entity.name == "player")
		{
			player.setPosition(entity.x, entity.y);
		}
	}

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
					FlxG.sound.play(Paths.sound('cancelMenu' + MainMenuState.curKey));
				default:
					if (!FreeplayState.freeplayMusicPlaying)
						FlxG.sound.play(Paths.sound('cancelMenu' + MainMenuState.curKey));
					else
						FlxG.sound.play(Paths.sound('cancelMenu'));
			}
			movedBack = true;
			new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				FlxG.switchState(new MainMenuState());
			});
		}

		super.update(elapsed);

		if (shakeCam)
		{
			shakeCam = false;
			FlxG.camera.shake(0.0025, 0.2);
		}

		FlxG.collide(player, walls);
	}
}