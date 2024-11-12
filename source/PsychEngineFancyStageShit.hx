import flixel.FlxSprite;
import flixel.util.FlxColor;
//import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.math.FlxMath;

class FancyStageParticle extends FlxSprite
{
	var lifeTime:Float = 0;
	var decay:Float = 0;
	var originalScale:Float = 1;
	var accelerationMultiplier:Float = 1;
	
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

		particleName = particleName + (min != max ? '_' + FlxG.random.int(min, max): '');
		loadGraphic(Paths.image(particleName, currentWeek));
		antialiasing = FlxG.save.data.hqnotesploosh;
		lifeTime = FlxG.random.float(1, 2);
		decay = FlxG.random.float(0.5, 1);
		angle = FlxG.random.float(0, 360);
		angularVelocity = FlxG.random.float(-50, 50) * particlePercentage;
		if(!FlxG.save.data.flashing)
			decay *= 0.5;

		originalScale = FlxG.random.float(0.25, 1);
		accelerationMultiplier = 1 + (1 - originalScale);
		scale.set(originalScale, originalScale);

		scrollFactor.set(FlxG.random.float(0.1, 0.3), FlxG.random.float(0.3, 0.5));
		velocity.set(165 - 25 * particlePercentage, FlxG.random.float(-200, -275));
		acceleration.set(50 - 5 * particlePercentage, -400 * accelerationMultiplier);
		
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed / 2);

		lifeTime -= elapsed * 2.5;
		if(lifeTime < 0)
		{
			lifeTime = 0;
			if (!isOnScreen(PlayState.instance.camGame))
				alpha = 0;
			else
			{
				alpha = FlxMath.lerp(0, alpha, CoolUtil.boundToInverted(1 - elapsed * decay, 0, 1));
				if(alpha > 0)
				{
					scale.set(originalScale * alpha, originalScale * alpha);
				}
			}
		}
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