package;

#if windows
import Sys.sleep;
import discord_rpc.DiscordRpc;
import flixel.FlxG;

using StringTools;

class DiscordClient
{

	public function new()
	{
		if (FlxG.save.data.showPresence)
		{
			trace("Discord Client starting...");
			DiscordRpc.start({
				clientID: "877073843028635670", //Discord app id
				onReady: onReady,
				onError: onError,
				onDisconnected: onDisconnected
			});
			trace("Discord Client started.");
			OptionsMenu.discordClientStarted = true;

			while (true)
			{
				DiscordRpc.process();
				sleep(2);
				//trace("Discord Client Update");
			}
		}

		DiscordRpc.shutdown();
		trace("shut down..?");
		//trace AH THIS IS SMART CAUSE IT LIKE STOPS AND SHUTS DOWN WHEN IT LIKE TURNS FALSE DAMN
	}

	public static function shutdown()
	{
		DiscordRpc.shutdown();
	}

	static function onReady()
	{
		DiscordRpc.presence({
			details: "",
			state: null,
			largeImageKey: 'apppresence-loading',
			largeImageText: "Thursday Morning Graduatin'"
		});
	}

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
		var DiscordDaemon = sys.thread.Thread.create(() ->
		{
			new DiscordClient();
		});
		trace("Discord Client initialized");
	}

	public static function changePresence(details:String, state:Null<String>, ?hasStartTimestamp:Bool, ?endTimestamp:Float, ?givenLargeImageKey:String = "apppresence-default", ?givenSmallImageKey:String, ?givenSmallImageText:String)
	{
		var startTimestamp:Float = (hasStartTimestamp ? Date.now().getTime() : 0);

		if (endTimestamp > 0)
			endTimestamp = startTimestamp + endTimestamp;

		DiscordRpc.presence(
		{
			details: details,
			state: state,
			largeImageKey: givenLargeImageKey,
			largeImageText: "Thursday Morning Graduatin'",
			smallImageKey: givenSmallImageKey,
			smallImageText: givenSmallImageText,
			// Obtained times are in milliseconds so they are divided so Discord can use it
			startTimestamp : Std.int(startTimestamp / 1000),
            endTimestamp : Std.int(endTimestamp / 1000)
		});

		//trace('Discord RPC Updated. Arguments: $details, $state, $smallImageKey, $hasStartTimestamp, $endTimestamp');
	}
}
#end