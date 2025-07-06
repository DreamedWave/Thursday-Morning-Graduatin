import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.util.FlxColor;


//Im gonna be honest, I didn't wanna make this script but uhh it's to allow recycling so yea :3

class Rating extends FlxSprite
{
	var leTwn:FlxTween;
	var isDoingCoolKill:Bool = false;
	var floatTime:Float = Conductor.stepCrochet * 2;
	
	public function new()
	{
		super(x, y);
	}

	public function initialize(x:Float, y:Float, daRating:String, ?isParent:Bool = false, ?ratingStartDelay:Float = 0, ?susLength:Float = 1)
	{
		this.x = x;
		this.y = y;

		alpha = 1;
		active = true;
		visible = true;
		isDoingCoolKill = false;

		switch (daRating)
		{
			case 'style':
				loadGraphic(Paths.image("rating_style"));
				acceleration.y = 700;
				velocity.y -= FlxG.random.int(150, 180);
				velocity.x -= FlxG.random.int(-15, 20);
				antialiasing = FlxG.save.data.antialiasing;
				leTwn = FlxTween.tween(this, {alpha: 0}, 0.1, {type: ONESHOT, ease: FlxEase.quadIn, startDelay: Conductor.crochet * 0.001 / 2});

			default:
				loadGraphic(Paths.image("rating_" + daRating));
				//timer is longer if the note is a parent to multiple sustain children
				if (isParent)
				{
					acceleration.y = 200 + (30 - (5 * susLength)) * (Conductor.bpm * 0.01); //idfk lol
					velocity.y -= 50 + (50 - (5 * susLength)) * (Conductor.bpm * 0.01) - (daRating != 'sick' && daRating != 'good' ? 30 : 0); //idfk lol //idfk lol part 2
				}
				else
				{
					acceleration.y = 400 + (30 * (Conductor.bpm * 0.01));
					velocity.y -= FlxG.random.int(100, 160) - (daRating != 'sick' && daRating != 'good' ? 30 : 0);
				}

				velocity.x -= FlxG.random.int(0, 10);
				antialiasing = FlxG.save.data.antialiasing;
				angularVelocity = FlxG.random.float(-7.5, 7.5);

				if (daRating != 'miss')
					leTwn = FlxTween.tween(this, {alpha: 0}, 0.175, {type: ONESHOT, ease: FlxEase.quadIn, startDelay: ratingStartDelay});
				else
					leTwn = FlxTween.tween(this, {alpha: 0}, 0.3, {type: ONESHOT, startDelay: ratingStartDelay});
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		
		if (floatTime > 0)
			floatTime -= elapsed;
		else if (velocity.y > 0)
			velocity.y = CoolUtil.freyaLerp(velocity.y, 0, 16, elapsed);

		if (alpha == 0)
			getRidOf();
	}

	//this resets everything to normal then kills it
	public function getRidOf()
	{
		if (alive && !isDoingCoolKill)
		{
			blend = NORMAL;
			angle = 0;
			velocity.set(0, 0);
			acceleration.set(0, 0);
			angularVelocity = 0;
			if (leTwn != null)
				leTwn.cancel();
			color = 0x00FFFFFF;
			kill();
		}
	}

	//this adds a fade out transition but doesnt kill it itself - that is handled by update() lol :3
	public function coolGetRidOf(combo:Int)
	{
		if (alive && !isDoingCoolKill)
		{
			var alphaCalc:Float;

			isDoingCoolKill = true;
			blend = ADD;
			if (velocity.y < 0)
				velocity.y = 0;
			else
				velocity.y += 20;
			
			if (combo < 200)
			{
				alphaCalc = 0.25 + (0.125 * (combo * 0.01 - 2));

				if (alpha > alphaCalc)
				{
					alpha = alphaCalc;

					if (leTwn != null)
						leTwn.cancel();
					leTwn = FlxTween.tween(this, {alpha: 0}, 0.3, {type: ONESHOT});
				}

				color = 0xFFC08A39;
				acceleration.y += 200;
			}
			else if (combo < 300)
			{
				alphaCalc = 0.375 + (0.125 * (combo * 0.01 - 3));

				if (alpha > alphaCalc)
				{
					alpha = alphaCalc;

					if (leTwn != null)
						leTwn.cancel();
					leTwn = FlxTween.tween(this, {alpha: 0}, 0.5, {type: ONESHOT});
				}

				color = 0xFF2DC12A;
				acceleration.y += 150;
			}
			else
			{
				if (alpha > 0.425)
					alpha = 0.425;

				color = 0xFF00CBCB;
				acceleration.y += 100;
			}
		}
	}
}

class Num extends FlxSprite
{
	var leTwn:FlxTween;
	var isDoingCoolKill:Bool = false;
	
	public function new()
	{
		super(x, y);
	}

	public function initialize(x:Float, y:Float, no:Int = 0, ?isParent:Bool = false, ?isSus:Bool = false)
	{
		this.x = x;
		this.y = y;
		alpha = 1;
		active = true;
		visible = true;
		isDoingCoolKill = false;

		loadGraphic(Paths.image('num' + no));
		if (no != 0)
			angle = FlxG.random.float(-0.825, 0.825) * no;
		angularVelocity = angle;
		antialiasing = FlxG.save.data.antialiasing;
		//guys are more heavy to avoid coverin up the top
		if (!isSus)
		{
			acceleration.y = 400 + (25 * (Conductor.bpm * 0.01));
			velocity.y -= FlxG.random.int(100, 150);
		}
		else
		{
			acceleration.y = 425 + (25 * (Conductor.bpm * 0.01));
			velocity.y -= FlxG.random.int(80, 130);
		}
		velocity.x = FlxG.random.float(-2.5, 2.5);

		leTwn = FlxTween.tween(this, {alpha: 0}, 0.15, {type: ONESHOT, startDelay: Conductor.crochet * (!isParent ? 0.00125 : 0.001)});
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (alpha <= 0)
			getRidOf();
	}

	public function getRidOf()
	{
		if (alive && !isDoingCoolKill)
		{
			blend = NORMAL;
			angle = 0;
			velocity.set(0, 0);
			acceleration.set(0, 0);
			angularVelocity = 0;
			if (leTwn != null)
				leTwn.cancel();
			color = 0x00FFFFFF;
			kill();
		}
	}

	public function coolGetRidOf(combo:Int)
	{
		if (alive && !isDoingCoolKill)
		{
			isDoingCoolKill = true;
			blend = ADD;
			if (velocity.y < 0)
				velocity.y = 0;
			else
				velocity.y += 20;
			
			if (combo < 200)
			{
				if (alpha > 0.25)
				{
					alpha = 0.25;

					if (leTwn != null)
						leTwn.cancel();
					leTwn = FlxTween.tween(this, {alpha: 0}, 0.3, {type: ONESHOT});
				}

				//color = 0xFFC08A39; //not coloured for now lets try it out cmon cmon yeeaaahhh cmon cmon yeahhhh
				acceleration.y += 300;
			}
			else if (combo < 300)
			{
				if (alpha > 0.375)
				{
					alpha = 0.375;

					if (leTwn != null)
						leTwn.cancel();
					leTwn = FlxTween.tween(this, {alpha: 0}, 0.5, {type: ONESHOT});
				}

				color = 0xFF2DC12A;
				acceleration.y += 100;
			}
			else
			{
				if (alpha > 0.425)
					alpha = 0.425;

				color = 0xFF00CBCB;
				acceleration.y += 100;
			}
		}
	}
}