package fx.shaders;
import flixel.FlxSprite;
import flixel.util.typeLimit.OneOfTwo;
import openfl.Assets;
import openfl.display.BitmapData;
import openfl.display.Shader;

/**
 * ...
 * @see https://github.com/mattdesl/lwjgl-basics/wiki/ShaderLesson6
 */
class DynamicLighting extends Shader
{
	public var parent:FlxSprite;
	
	public function new(sprite:FlxSprite, normalMap:OneOfTwo<String, BitmapData>) 
	{
		super();
		
		parent = sprite;
		sprite.shader = this;
		
		if (Std.is(normalMap, String)) this.NormalMap = Assets.getBitmapData(normalMap);
		else if (Std.is(normalMap, BitmapData))	this.NormalMap = normalMap;
		
		this.Resolution = [parent.width, parent.height];
		this.LightPos = [0, 0, 0.075];
		this.LightColor = [1, 0.8, 0.6, 1];
		this.AmbientColor = [0.6, 0.6, 1, 0.2];
		this.Falloff = [0.4, 3, 20];
	}
	
	public function setLightingPosition(x:Float, y:Float) {
		// Change world coordinates to local
		this.LightPos[0] = (x - parent.x) / parent.width;
		this.LightPos[1] = (y - parent.y) / parent.height;
	}

@fragment var code = '
uniform sampler2D NormalMap;  //normal map texture
uniform vec2 Resolution;	  //resolution of screen
uniform vec3 LightPos;        //light position, normalized
uniform vec4 LightColor;      //light RGBA -- alpha is intensity
uniform vec4 AmbientColor;    //ambient RGBA -- alpha is intensity 
uniform vec3 Falloff;         //attenuation coefficients

void main() {
	//RGBA of our diffuse color
	vec4 DiffuseColor = texture2D(${Shader.uSampler}, ${Shader.vTexCoord});
	
	//RGB of our normal map
	vec4 NormalRGBA = texture2D(NormalMap, ${Shader.vTexCoord});
	vec3 NormalColor = NormalRGBA.rgb;
	
	// Total sum of all lights
	vec3 Sum = vec3(0, 0, 0);
	
	//The delta position of light
	vec3 LightDir = vec3(LightPos.xy - ${Shader.vTexCoord}.xy, LightPos.z);

        //Determine distance (used for attenuation) BEFORE we normalize our LightDir
        float D = length(LightDir);

        //normalize our vectors (with scale transformation for normal)
        vec3 N = normalize(NormalColor * 2.0 - 1.0);
        vec3 L = normalize(LightDir);

        //Pre-multiply light color with intensity
        //Then perform "N dot L" to determine our diffuse term
        vec3 Diffuse = (LightColor.rgb * LightColor.a) * max(dot(N, L), 0.0);

        //pre-multiply ambient color with intensity
        vec3 Ambient = AmbientColor.rgb * AmbientColor.a;

        //calculate attenuation
        float Attenuation = 1.0 / ( Falloff.x + (Falloff.y*D) + (Falloff.z*D*D) );

        //the calculation which brings it all together
        vec3 Intensity = Ambient + Diffuse * Attenuation;
        vec3 FinalColor = DiffuseColor.rgb * Intensity;
	
	gl_FragColor = vec4(FinalColor, DiffuseColor.a);
}
';
	
}