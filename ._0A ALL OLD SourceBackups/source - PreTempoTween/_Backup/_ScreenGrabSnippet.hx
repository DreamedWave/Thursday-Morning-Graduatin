import flixel.addons.plugin.screengrab.FlxScreenGrab;

FlxScreenGrab.defineCaptureRegion(0, 0, FlxG.width, FlxG.height);
FlxScreenGrab.grab(false, true);

var fakeScreen:FlxSprite = new FlxSprite().loadGraphic(FlxScreenGrab.screenshot.bitmapData);
fakeScreen.scrollFactor.set();
fakeScreen.updateHitbox();
fakeScreen.antialiasing = FlxG.save.data.antialiasing;
add(fakeScreen);

//VideoLoadingSnippet
if (!debug)
{
    trace('starting vid cache');
    var video = new VideoHandler();
    var vidSprite = new FlxSprite(0, 0);
    video.finishCallback = null;

    video.playMP4(Paths.video('bendy/1.5'), false, vidSprite, false, false, true);
    video.kill();
    trace('finished vid cache');
}

//Lowpass snippet - NVM
/*#if cpp
@:privateAccess
{
    lime.media.openal.AL.sourcef(styleSound._channel.__source.__backend.handle, lime.media.openal.AL.PITCH, FlxG.random.float(0.8, 1.2));
    //                      sound source             parameter https://api.haxeflixel.com/lime/media/openal/AL.html        value
}
#end*/

//howler sound loading snippet
import lime.media.howlerjs.Howl;
var metal_hit:Howl = new Howl({ src: [ 'assets/metal_hit.mp3' ], volume: 0.4 });
var id = metal_hit.play();
metal_hit.rate(1.get_random(0.5), id); //pitch