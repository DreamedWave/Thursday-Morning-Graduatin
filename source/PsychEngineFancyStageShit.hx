import flixel.FlxSprite;
import flixel.util.FlxColor;
//import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;

class FancyStageParticle extends FlxSprite
{
	var lifeTime:Float = 0;
	var decay:Float = 1;
	var originalScale:Float = 1;
	var accelerationMultiplier:Float = 1;
	//var frameTimeMult:Float = 1;
	//var frameRateMult:Float = 1;
	var partPercent:Float = 0;
	
	public function new()
	{
		super(x, y);
	}

	public function initialize(particleName:String, currentWeek:String, particlePercentage:Float = 1, min:Int, max:Int, x:Float, y:Float, color:FlxColor, nextColor:FlxColor)
	{
		this.x = x;
		this.y = y;

		if (color != FlxColor.WHITE)
			this.color = color;

		//frameRateMult = 1 / FlxG.save.data.fpsCap;

		particleName = particleName + (min != max ? '_' + FlxG.random.int(min, max): '');
		loadGraphic(Paths.image(particleName, currentWeek));
		antialiasing = FlxG.save.data.hqnotesploosh;
		lifeTime = FlxG.random.float(1, 1.25);
		angle = FlxG.random.float(0, 360);
		angularVelocity = FlxG.random.float(-10, 10) * particlePercentage;
		originalScale = FlxG.random.float(0.25, 1);
		accelerationMultiplier = 1.4 + (1 - originalScale);
		scale.set(originalScale, originalScale);

		scrollFactor.set(0.5 * originalScale, (originalScale / 2) * 0.5);
		velocity.set((-60 * particlePercentage) + 30, FlxG.random.float(-100, -150));
		acceleration.set((-200 * particlePercentage) + 100, -200 * accelerationMultiplier);
		partPercent = particlePercentage; //got lazy typing lol
	}

	var alphaTwn:FlxTween;
	var oneTimeBool:Bool = false;
	override function update(elapsed:Float)
	{
		super.update(elapsed);
		//frameTimeMult = elapsed / frameRateMult;
		//trace('e - ' + elapsed + ' | ftm: ' + frameTimeMult);

		if(lifeTime <= 0)
		{
			lifeTime = 0;
			velocity.y = CoolUtil.freyaLerp(velocity.y, -25, 3, elapsed);
			if (!oneTimeBool)
			{
				oneTimeBool = true;
				acceleration.set((-400 * partPercent) + 200, -200 * accelerationMultiplier);
			}

			if (!isOnScreen(PlayState.instance.camGame))
			{
				if (alphaTwn != null)
					alphaTwn.cancel();
				alpha = 0;
			}
			else
			{
				//Not a lerp because idk how to do an easeIn with lerps cuz im dumb
				if (alphaTwn == null)
					alphaTwn = FlxTween.num(alpha, 0, 1.2, {type: ONESHOT, ease: FlxEase.quartIn}, function(num:Float){alpha = num; scale.set(originalScale * alpha, originalScale * alpha);});
			}
		}
		else
			lifeTime = CoolUtil.freyaLerp(Math.floor(lifeTime * 1000) / 1000, 0, 5, elapsed);
	}
}

class FancyStageGradient extends FlxSprite
{
	public var originalY:Float;
	public var originalHeight:Int = 400;
	public var intendedAlpha:Float = 1;
	public function new(path:String, x:Float, y:Float)
	{
		super(x, y);
		originalY = y;

		loadGraphic(path + '/stageGradient');
		antialiasing = FlxG.save.data.antialiasing;
		scrollFactor.set(0, 0.75);
		setGraphicSize(2000, originalHeight);
		updateHitbox();
	}

	override function update(elapsed:Float)
	{
		var newHeight:Int = Math.round(height - 1000 * elapsed);
		if(newHeight > 0)
		{
			alpha = intendedAlpha;
			setGraphicSize(2000, newHeight);
			updateHitbox();
			y = originalY + (originalHeight - height);
		}
		else
		{
			alpha = 0;
			y = -5000;
		}

		super.update(elapsed);
	}

	public function bop()
	{
		setGraphicSize(2000, originalHeight);
		updateHitbox();
		y = originalY;
		alpha = intendedAlpha;
	}
}