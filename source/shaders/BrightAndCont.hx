//This is from Indie Cross (2)
package shaders;
import flixel.system.FlxAssets.FlxShader;

class BrightAndCont extends FlxShader
{
	@:glFragmentSource('
		#pragma header

		uniform float brightness;
		uniform float contrast;

		void main()
		{
			vec4 col = texture2D(bitmap, openfl_TextureCoordv);
			col.rgb = col.rgb * contrast;
			col.rgb = col.rgb + brightness;

			gl_FragColor = col;
		}')
    
	public function new(bright:Float = 0, cont:Float = 1)
	{
		super();

        brightness.value = [bright];
        contrast.value = [cont];
	}

	/*public function setValues(b:Float = 0, c:Float = 1)
	{
		brightness.value = [b];
        contrast.value = [c];
	}*/
}