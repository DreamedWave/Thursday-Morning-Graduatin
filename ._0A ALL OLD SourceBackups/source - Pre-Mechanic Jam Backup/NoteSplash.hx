package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

class NoteSplash extends FlxSprite
{
	public function new(x:Float = 0, y:Float = 0, ?note:Int = 0)
	{
		
		super(x, y);

		visible = false;

		switch (FlxG.save.data.notesfxType)
		{
			case "chill":
				var tex:flixel.graphics.frames.FlxAtlasFrames = Paths.getSparrowAtlas('NOTE_assets', 'shared');
				frames = tex;
				animation.addByPrefix('splash 0 0', 'left 1 splash', 25, false);
				animation.addByPrefix('splash 0 1', 'down 1 splash', 25, false);
				animation.addByPrefix('splash 0 2', 'up 1 splash', 25, false);
				animation.addByPrefix('splash 0 3', 'right 1 splash', 25, false);
				animation.addByPrefix('splash 1 0', 'left 2 splash', 24, false);
				animation.addByPrefix('splash 1 1', 'down 2 splash', 24, false);
				animation.addByPrefix('splash 1 2', 'up 2 splash', 24, false);
				animation.addByPrefix('splash 1 3', 'right 2 splash', 24, false);
				animation.addByPrefix('splash 2 0', 'left 2 splash', 26, false);
				animation.addByPrefix('splash 2 1', 'down 2 splash', 26, false);
				animation.addByPrefix('splash 2 2', 'up 2 splash', 26, false);
				animation.addByPrefix('splash 2 3', 'right 2 splash', 26, false);
				animation.addByPrefix('splash 0 mine', 'mine note 1 splash', 24, false);
				animation.addByPrefix('splash 1 mine', 'mine note 2 splash', 25, false);
				animation.addByPrefix('splash 2 mine', 'mine note 3 splash', 26, false);
				animation.addByPrefix('splash 0 trigger', 'trigger note 1 splash', 24, false);
				animation.addByPrefix('splash 1 trigger', 'trigger note 2 splash', 25, false);
				animation.addByPrefix('splash 2 trigger', 'trigger note 3 splash', 26, false);
			default:
				var tex:flixel.graphics.frames.FlxAtlasFrames = Paths.getSparrowAtlas('noteSplashes', 'shared');
				frames = tex;
				animation.addByPrefix('splash 0 0', 'note impact 1 purple', 27, false);
				animation.addByPrefix('splash 0 1', 'note impact 1 blue', 27, false);
				animation.addByPrefix('splash 0 2', 'note impact 1 green', 27, false);
				animation.addByPrefix('splash 0 3', 'note impact 1 red', 27, false);
				animation.addByPrefix('splash 1 0', 'note impact 2 purple', 26, false);
				animation.addByPrefix('splash 1 1', 'note impact 2 blue', 26, false);
				animation.addByPrefix('splash 1 2', 'note impact 2 green', 26, false);
				animation.addByPrefix('splash 1 3', 'note impact 2 red', 26, false);
				animation.addByPrefix('splash 0 mine', 'note impact 1 mine', 24, false);
				animation.addByPrefix('splash 1 mine', 'note impact 2 mine', 23, false);
				animation.addByPrefix('splash 0 trigger', 'note impact 1 trigger', 24, false);
				animation.addByPrefix('splash 1 trigger', 'note impact 2 trigger', 23, false);
				animation.addByPrefix('splash 0 shit', 'note impact 1 shit', 16, false);
				animation.addByPrefix('splash 1 shit', 'note impact 2 shit', 16, false);
		}

		setupNoteSplash(x, y, 'sick', 'normal', note);
		antialiasing = FlxG.save.data.hqnotesploosh;
	}

	public function setupNoteSplash(x:Float, y:Float, rating:String, noteStyle:String, note:Int = 0, staticArrowY:Float = 0) 
	{
		visible = false;
		var wasMissed:Bool = false;
		//Making sure the rating isn't something the game doesn't recognise
		switch(rating)
		{
			case 'sick' | 'good' | 'bad' | 'shit':
				//do Nothin
			case 'miss':
				wasMissed = true;
			default:
				rating = 'sick';
				//"In the event that the programme slips up, I would rather reward the player rather than unfairly punishing them."
				// - DreamedWave 2022
		}
		if (y < -10 && !wasMissed)
			y = -10;
		else if (wasMissed)
			y = staticArrowY;
		setPosition(x - 75, y - 85);
		var animNum:Int;

		acceleration.y = 0;
		velocity.y = 0;
		velocity.x = 0;

		switch (FlxG.save.data.notesfxType)
		{
			case "chill":
				animNum = FlxG.random.int(0, 2);
				var tex:flixel.graphics.frames.FlxAtlasFrames = Paths.getSparrowAtlas('NOTE_assets', 'shared');
				frames = tex;
				animation.addByPrefix('splash 0 0', 'left 1 splash', 25, false);
				animation.addByPrefix('splash 0 1', 'down 1 splash', 25, false);
				animation.addByPrefix('splash 0 2', 'up 1 splash', 25, false);
				animation.addByPrefix('splash 0 3', 'right 1 splash', 25, false);
				animation.addByPrefix('splash 1 0', 'left 2 splash', 24, false);
				animation.addByPrefix('splash 1 1', 'down 2 splash', 24, false);
				animation.addByPrefix('splash 1 2', 'up 2 splash', 24, false);
				animation.addByPrefix('splash 1 3', 'right 2 splash', 24, false);
				animation.addByPrefix('splash 2 0', 'left 2 splash', 26, false);
				animation.addByPrefix('splash 2 1', 'down 2 splash', 26, false);
				animation.addByPrefix('splash 2 2', 'up 2 splash', 26, false);
				animation.addByPrefix('splash 2 3', 'right 2 splash', 26, false);
				animation.addByPrefix('splash 0 mine', 'note impact 1 mine', 24, false);
				animation.addByPrefix('splash 1 mine', 'note impact 2 mine', 23, false);
				animation.addByPrefix('splash 0 trigger', 'note impact 1 trigger', 24, false);
				animation.addByPrefix('splash 1 trigger', 'note impact 2 trigger', 23, false);
				animation.addByPrefix('splash 0 shit', 'note impact 1 shit', 16, false);
				animation.addByPrefix('splash 1 shit', 'note impact 2 shit', 16, false);
			default:
				animNum = FlxG.random.int(0, 1);
				var tex:flixel.graphics.frames.FlxAtlasFrames = Paths.getSparrowAtlas('noteSplashes', 'shared');
				frames = tex;
				animation.addByPrefix('splash 0 0', 'note impact 1 purple', 27, false);
				animation.addByPrefix('splash 0 1', 'note impact 1 blue', 27, false);
				animation.addByPrefix('splash 0 2', 'note impact 1 green', 27, false);
				animation.addByPrefix('splash 0 3', 'note impact 1 red', 27, false);
				animation.addByPrefix('splash 1 0', 'note impact 2 purple', 26, false);
				animation.addByPrefix('splash 1 1', 'note impact 2 blue', 26, false);
				animation.addByPrefix('splash 1 2', 'note impact 2 green', 26, false);
				animation.addByPrefix('splash 1 3', 'note impact 2 red', 26, false);
				animation.addByPrefix('splash 0 mine', 'note impact 1 mine', 24, false);
				animation.addByPrefix('splash 1 mine', 'note impact 2 mine', 23, false);
				animation.addByPrefix('splash 0 trigger', 'note impact 1 trigger', 24, false);
				animation.addByPrefix('splash 1 trigger', 'note impact 2 trigger', 23, false);
				animation.addByPrefix('splash 0 shit', 'note impact 1 shit', 16, false);
				animation.addByPrefix('splash 1 shit', 'note impact 2 shit', 16, false);
		}

		switch (noteStyle)
		{
			case "mine":
				switch (rating)
				{
					case "sick" | "good" | "bad":
						visible = true;
						alpha = 1;
						animation.play('splash ' + animNum + ' mine', true);
						if(animation.curAnim != null)
							animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
					case "miss":
						//do nada
				}
			case "trigger":
				switch (rating)
				{
					case "sick" | "good" | "bad":
						visible = true;
						alpha = 1;
						animation.play('splash ' + animNum + ' trigger', true);
						if(animation.curAnim != null)
							animation.curAnim.frameRate = 25 + FlxG.random.int(-2, 2);
					case "miss":
						visible = true;
						alpha = 1;
						animation.play('splash ' + animNum + ' mine', true);
						if(animation.curAnim != null)
							animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
				}
			default:
				switch (rating)
				{
					case "sick":
						visible = true;
						alpha = 1;
						setGraphicSize(Std.int(width * 0.9));
						animation.play('splash ' + animNum + ' ' + note, true);
						if(animation.curAnim != null)
							animation.curAnim.frameRate = 24 + FlxG.random.int(-2, 2);
					case "shit" | "miss":
						if (FlxG.save.data.notesfxType != "chill")
						{
							visible = true;
							setGraphicSize(Std.int(width * 0.9));
							acceleration.y = 500;
							velocity.y -= FlxG.random.int(140, 175);
							velocity.x -= FlxG.random.int(0, 5);
							animation.play('splash ' + animNum + ' shit', true);
							alpha = 0.8;
							if(animation.curAnim != null)
								animation.curAnim.frameRate = 16 + FlxG.random.int(-1, 1);
						}
					default:
						kill();
				}
		}
	}

	override function update(elapsed:Float) 
	{
		if(animation.curAnim != null)
		{
			if(animation.curAnim.finished) 
				kill();
		}
		else
			kill();

		super.update(elapsed);
	}
}