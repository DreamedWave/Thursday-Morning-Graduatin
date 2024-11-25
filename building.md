# Building Thursday Morning Graduatin'

(This is literally just a modified version of Kade Engine 1.6's Building Guide but we ball!!!)

**Please note** that these instructions are for compiling/building Thursday Morning Graduatin'. If you just want to play the mod, just download it from [here](https://www.youtube.com/watch?v=dQw4w9WgXcQ)!

**Also note**: you should be familiar with the commandline. If not, read this [quick guide by ninjamuffin](https://ninjamuffin99.newgrounds.com/news/post/1090480).

**Also ALSO note**: This is unfortunately only for **Windows** only, as I unfortunately don't really have the time nor resources to mod for multiple platforms as I am just one person who is currently studying in college... Sorry!

## Dependencies
 1. [Install Haxe 4.1.5](https://haxe.org/download/version/4.1.5/). You should use 4.1.5 instead of the latest version because the foundations of [this mod](https://github.com/DreamedWave/Thursday-Morning-Graduatin) (Kade Engine 1.6) was built using this verwsion of Haxe, and updating it would be too much of a timesink for this mod (which already is 3 years or so in development btw!).
 2. After installing Haxe, [Install HaxeFlixel](https://haxeflixel.com/documentation/install-haxeflixel/).
 3. Install `git`.
	 - Windows: install from the [git-scm](https://git-scm.com/downloads) website.
	 - Linux: install the `git` package: `sudo apt install git` (ubuntu), `sudo pacman -S git` (arch), etc... (you probably already have it)
 4. Install and set up the necessary libraries:
	 - `haxelib install lime 7.9.0`
	 - `haxelib install openfl`
	 - `haxelib install flixel`
	 - `haxelib run lime setup`
	 - `haxelib run lime setup flixel`
	 - `haxelib install flixel-tools`
	 - `haxelib run flixel-tools setup`
	 - `haxelib install flixel-addons`
	 - `haxelib install flixel-ui`
	 - `haxelib install hscript`
	 - `haxelib install newgrounds`
	 - `haxelib install linc_luajit`
	 - `haxelib git faxe https://github.com/uhrobots/faxe`
	 - `haxelib git polymod https://github.com/larsiusprime/polymod.git`
	 - `haxelib git discord_rpc https://github.com/Aidan63/linc_discord-rpc`
	 - `haxelib install actuate`
	 - `haxelib git extension-webm https://github.com/KadeDev/extension-webm`
	 - `lime rebuild extension-webm <ie. windows, macos, linux>`
	 - `haxelib git flxsoundfilters https://github.com/TheZoroForce240/FlxSoundFilters`
	 - `ADD THE FUCKING GIT VER OF YOUR MODIFIED DISCORD RPC THINGY`

### Required Dependencies
You also need to install **Visual Studio 2019**. While installing it, *don't click on any of the options to install workloads*. Instead, go to the **individual components** tab and choose the following:

-   MSVC v142 - VS 2019 C++ x64/x86 build tools
-   MSVC v141 - VS 2017 C++ x64/x86 build tools
-   Windows SDK (10.0.17763.0)
-   C++ Profiling tools
-   C++ CMake tools for windows
-   C++ ATL for v142 build tools (x86 & x64)

This will install about 7 GB of crap, but is necessary for a build to work at all.

## Building
Finally, we are ready to build.

- Open Windows Powershell in this current folder (e.g. `within 'Thursday-Morning-Graduatin', outside of folders like 'source/'`).
- Run `lime build windows` (if you'd like to not include trace messages, write `lime build windows -no-traces` instead).
- If you'd like to play the game as it finishes compiling, run `lime test windows` instead!	(`-no-traces` still applies).
- After a bit of waiting, the build will be in `Thursday-Morning-Graduatin/export/windows/bin`.
- Only the `bin` folder is necessary to run the game. The other ones in `export/windows` are not.
