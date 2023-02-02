package;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSave;
import flixel.util.FlxTimer;
import lime.app.Application;
import openfl.Assets;
import openfl.Lib;

// stole from https://github.com/TheWorldMachinima/FunkinCocoa/blob/main/source/FunkinScript.hx lol!!

final class FunkinScript extends SScript
{
	override public function new(?scriptFile:String = "", ?preset:Bool = true, ?startExecute:Bool = true)
	{
		super(scriptFile, preset, false);

		traces = false;
		privateAccess = true;
		
		execute();
	}

	override function preset():Void
	{
		super.preset();

		set('Boyfriend', Boyfriend);
		set('Character', Character);
		set('FlxG', FlxG);
		set('FlxSprite', FlxSprite);
		set('game', PlayState.instance);
		set('GameOverSubstate', GameOverSubstate);
		set('gameover', GameOverSubstate.instance);
		set('Main', Main);
		set('Note', Note);
		set('Paths', Paths);
		set('PlayState', PlayState);
		set('this', this);

		set('get', function(id:String)
		{
			var dotList:Array<String> = id.split('.');
			if (dotList.length > 1)
			{
				var property:Dynamic = Reflect.getProperty(PlayState.instance, dotList[0]);
				for (i in 1...dotList.length - 1)
				{
					property = Reflect.getProperty(property, dotList[i]);
				}

				return Reflect.getProperty(property, dotList[dotList.length - 1]);
			}
			return Reflect.getProperty(PlayState.instance, id);
		});

		set('set', function(id:String, value:Dynamic)
		{
			var dotList:Array<String> = id.split('.');
			if (dotList.length > 1)
			{
				var property:Dynamic = Reflect.getProperty(PlayState.instance, dotList[0]);
				for (i in 1...dotList.length - 1)
				{
					property = Reflect.getProperty(property, dotList[i]);
				}

				return Reflect.setProperty(property, dotList[dotList.length - 1], value);
			}
			return Reflect.setProperty(PlayState.instance, id, value);
		});

		set('getColorFromRGB', function(r:Int, g:Int, b:Int)
		{
			return FlxColor.fromRGB(r, b, g);
		});
	}
}