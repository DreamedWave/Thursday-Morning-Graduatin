//This is from Indie Cross (3)
package shaders;
import flixel.system.FlxAssets.FlxShader;

class ChromAbb extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform float rOffset;
		uniform float gOffset;
		uniform float bOffset;

		void main()
		{
			vec4 col = vec4(1.0);
			
			col.r = texture2D(bitmap, openfl_TextureCoordv - vec2(rOffset, 0.0)).r;
			col.ga = texture2D(bitmap, openfl_TextureCoordv - vec2(gOffset, 0.0)).ga;
			col.b = texture2D(bitmap, openfl_TextureCoordv - vec2(bOffset, 0.0)).b;

			gl_FragColor = col;
		}')
	public function new(redOff:Float = 0, greenOff:Float = 0, blueOff:Float = 0)
	{
		super();

		rOffset.value = [redOff];
		gOffset.value = [greenOff];
		bOffset.value = [blueOff];
	}

    /*public function setValues(r:Float = 0, g:Float = 0, b:Float = 0)
    {
		rOffset.value = [r];
		gOffset.value = [g];
		bOffset.value = [b];
    }*/
}