
package shaders;
import flixel.system.FlxAssets.FlxShader;

class BloomShader extends FlxShader
{
	@:glFragmentSource('
    #pragma header  

    uniform float threshold;
    uniform float intensity;
    uniform float blurSize;

    vec4 BlurColor (in vec2 Coord, in sampler2D Tex, in float MipBias)
    {
        vec2 TexelSize = MipBias / vec2(1280, 720);
        
        vec4 Color = texture(Tex, Coord, MipBias);
        
        for (int i = 0; i < 2; i++) {
            float mul = (float(i)+1.0) / 2.0;
            
            Color += texture(Tex, Coord + vec2(TexelSize.x*mul,0.0), MipBias);
            Color += texture(Tex, Coord + vec2(-TexelSize.x*mul,0.0), MipBias);
            Color += texture(Tex, Coord + vec2(0.0,TexelSize.y*mul), MipBias);
            Color += texture(Tex, Coord + vec2(0.0,-TexelSize.y*mul), MipBias);
            Color += texture(Tex, Coord + vec2(TexelSize.x*mul,TexelSize.y*mul), MipBias);
            Color += texture(Tex, Coord + vec2(-TexelSize.x*mul,TexelSize.y*mul), MipBias);
            Color += texture(Tex, Coord + vec2(TexelSize.x*mul,-TexelSize.y*mul), MipBias);
            Color += texture(Tex, Coord + vec2(-TexelSize.x*mul,-TexelSize.y*mul), MipBias);
        }

        return Color/17.0;
    }

    void main()
    {
        vec2 uv = openfl_TextureCoordv;
        vec4 Color = texture(bitmap, uv);

        if (intensity > 0.0)
        {
            vec4 Highlight = clamp(BlurColor(uv, bitmap, blurSize)-threshold,0.0,1.0)*1.0/(1.0-threshold);
            gl_FragColor = 1.0-(1.0-Color)*(1.0-Highlight*intensity);
        }
        else
        {
            gl_FragColor = Color;
        }
    }')
	
    public function new(?thresh:Float = 0.4, ?intens:Float = 1.0, ?blurSiz:Float = 5)
	{
		super();

        threshold.value = [thresh];
        intensity.value = [intens];
        blurSize.value = [blurSiz];
	}
}