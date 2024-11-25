package;

#if windows
import Sys.sleep;
import discord_rpc.DiscordRpc;
//import flixel.FlxG;

using StringTools;

class DiscordClient
{
	static var startingTime:Int = 0;//Unchangable Variable

	public function new()
	{
		if (FlxG.save.data.showPresence)
		{
			startingTime = Std.int(Date.now().getTime() / 1000);
			trace("Discord Client starting...");
			DiscordRpc.start({
				clientID: "877073843028635670", //Discord app id
				onError: onError,
				onDisconnected: onDisconnected
			});
			trace("Discord Client started.");
			OptionsMenu.discordClientStarted = true;

			//onReady funct moved to here
			DiscordRpc.presence({
				details: "",
				state: null,
				largeImageKey: 'apppresence-dark',
				largeImageText: "Thursday Morning Graduatin'",
				startTimestamp: startingTime
			});

			while (true)
			{
				DiscordRpc.process();
				sleep(2);
				//trace("Discord Client Update");
			}

			DiscordRpc.shutdown();
			trace("shut down..?");
			//trace AH THIS IS SMART CAUSE IT LIKE STOPS AND SHUTS DOWN WHEN IT LIKE TURNS FALSE DAMN
		}
	}

	public static function shutdown()
	{
		DiscordRpc.shutdown();
	}

	//static function onReady()
	//{
		/*DiscordRpc.presence({
			details: "",
			state: null,
			largeImageKey: 'apppresence-dark',
			largeImageText: "Thursday Morning Graduatin'"
		});*/
	//}

	static function onError(_code:Int, _message:String)
	{
		trace('Error! $_code : $_message');
	}

	static function onDisconnected(_code:Int, _message:String)
	{
		trace('Disconnected! $_code : $_message');
	}

	public static function initialize()
	{
		if (FlxG.save.data.showPresence)
		{
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new DiscordClient();
		});
		trace("Discord Client initialized");
		}
		else
		{
			trace("CANT START PRESENCE - DENIED LMFAO!!!!!");
		}
	}

	public static function changePresence(details:String, state:Null<String>, ?givenLargeImageKey:String = "apppresence-default", ?givenSmallImageKey:String, ?givenSmallImageText:String)
	{
		//no timestamp bull shit
		DiscordRpc.presence(
		{
			details: details,
			state: state,
			largeImageKey: givenLargeImageKey,
			largeImageText: "Thursday Morning Graduatin'",
			smallImageKey: givenSmallImageKey,
			smallImageText: givenSmallImageText,
			startTimestamp: startingTime
		});
	}
}
#end