package ui;

import ui.PreferencesMenu.CheckboxThingie;
import flixel.FlxObject;
import flixel.FlxCamera;
#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxButtonPlus;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flixel.system.FlxSound;
import openfl.utils.Assets as OpenFlAssets;
import sys.io.File;
import sys.FileSystem;
import haxe.Json;
import haxe.format.JsonParser;
import openfl.display.BitmapData;
import flash.geom.Rectangle;
import flixel.ui.FlxButton;
import flixel.FlxBasic;
import sys.io.File;
import ui.AtlasText.AtlasFont;
import ui.TextMenuList.TextMenuItem;

class ModMenu extends ui.OptionsState.Page
{
	var modsList:Array<Dynamic> = [];

	var checkboxes:Array<CheckboxThingie> = [];

	var curSelected:Int = 0;

	var items:TextMenuList;

	var noMods:FlxText;
	var statusText:FlxText;
	var hasNoMods:Bool = true;

	var menuCamera:FlxCamera;
	var camFollow:FlxObject;

	public function new():Void
	{
		super();

		menuCamera = new SwagCamera();
		FlxG.cameras.add(menuCamera, false);
		menuCamera.bgColor = 0x0;
		camera = menuCamera;

		add(items = new TextMenuList());

		hasNoMods = (!FileSystem.exists('modsList.txt'));

		noMods = new FlxText(0,100, 1280, 'There seems to be no mods here. \n Press BACK to exit and install a mod!');
		if(FlxG.random.bool(0.1)) noMods.text += '\nDUMBASS!!!.'; //diabolical
		noMods.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
		add(noMods);
		noMods.scrollFactor.set();
		noMods.visible = hasNoMods;

		var path:String = 'modsList.txt';
		if(FileSystem.exists(path))
		{
			var leMods:Array<String> = CoolUtil.coolTextFile(path);
			for (i in 0...leMods.length)
			{
				if(leMods.length > 1 && leMods[0].length > 0) {
					var modSplit:Array<String> = leMods[i].split('|');
					if(!Paths.ignoreModFolders.contains(modSplit[0].toLowerCase()))
					{
						addToModsList([modSplit[0], (modSplit[1] == '1')]);
						//trace(modSplit[1]);
					}
				}
			}
		}

		// FIND MOD FOLDERS
		var boolshit = true;
		if (FileSystem.exists("modsList.txt")){
			for (folder in Paths.getModDirectories())
			{
				if(!Paths.ignoreModFolders.contains(folder))
				{
					addToModsList([folder, true]); //i like it false by default. -bb //Well, i like it True! -Shadow
				}
			}
		}
		if (!hasNoMods) {
			for (i in 0 ... modsList.length) {
				var isEnabled = (modsList[i][1] == 1);
				createMod(modsList[i][0], isEnabled);
			}
		}
		camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);
		if (modsList == [] && !hasNoMods) {
			noMods.visible = true;
			noMods.text = 'There seems to be no mods within your /mods directory!\nInstall some mods!!';
		}
		saveTxt();
	}

	override function update(elapsed:Float)
		{
			super.update(elapsed);
	
			// menuCamera.followLerp = CoolUtil.camLerpShit(0.05);
	
			items.forEach(function(daItem:TextMenuItem)
			{
				if (items.selectedItem == daItem) {
					daItem.x = 150;
					// descNameText.text = daItem.label.text;
					// descText.text = descs[daItem.ID];
				}
				else
					daItem.x = 120;
			});
		}


	private function createMod(prefName:String, prefValue:Dynamic):Void
	{
		items.createItem(220, (120 * items.length) + 30, prefName, AtlasFont.Default, function()
		{
			toggle(prefName);
		});

		switch (Type.typeof(prefValue).getName())
		{
			case 'TBool':
				createCheckbox(prefValue);

			default:
				trace('swag');
		}

		trace(Type.typeof(prefValue).getName());
	}

	private function toggle(prefName:String)
	{
		items.forEach(function(daItem:TextMenuItem) {
			if (items.selectedItem == daItem) {
				if (modsList[daItem.ID] != null) {
					var flippo = !modsList[daItem.ID][1];
					modsList[daItem.ID][1] = flippo;
					checkboxes[items.selectedIndex].daValue = flippo;
					saveTxt();
				}
			}
		});
	}

	function createCheckbox(prefValue:Dynamic)
	{
		var checkbox:CheckboxThingie = new CheckboxThingie(0, 120 * (items.length - 1), prefValue);
		checkboxes.push(checkbox);
		add(checkbox);
	}

	function saveTxt() {
		var fileStr:String = '';
		for (values in modsList)
		{
			if(fileStr.length > 0) fileStr += '\n';
			fileStr += values[0] + '|' + (values[1] ? '1' : '0');
		}

		var path:String = 'modsList.txt';
		File.saveContent(path, fileStr);
		Paths.pushGlobalMods();
	}

	

	function addToModsList(values:Array<Dynamic>)
	{
		for (i in 0...modsList.length)
		{
			if(modsList[i][0] == values[0])
			{
				//trace(modsList[i][0], values[0]);
				return;
			}
		}
		modsList.push(values);
	}
}