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