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
	var mods:Array<ModMetadata> = [];

	var checkboxes:Array<CheckboxThingie> = [];

	var curSelected:Int = 0;

	var items:TextMenuList;

	var noMods:FlxText;
	var statusText:FlxText;
	var hasNoMods:Bool = true;

	var menuCamera:FlxCamera;
	var camFollow:FlxObject;
	var descNameText:FlxText;
	var descText:FlxText;

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

		if (!hasNoMods)
			createMod('Mods', false, false);

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
				createMod(modsList[i][0], isEnabled, true);
			}
		}
		camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);

		if (enabled && !hasNoMods) {
			camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);
			if (items != null)
				camFollow.y = items.selectedItem.y;
	
			menuCamera.follow(camFollow, null, 0.06);
			var margin = 160;
			menuCamera.deadzone.set(0, margin, menuCamera.width, 40);
			menuCamera.minScrollY = -100;
	
			items.onChange.add(function(selected)
			{
				camFollow.y = selected.y;
			});
			var descBorder = new FlxSprite(0,0).makeGraphic(400, 720, 0x99000000);
			add(descBorder);
			var descBottom = new FlxSprite(0,720 - 18).makeGraphic(400, 20, 0xFF000000);
			add(descBottom);
			descBorder.x = FlxG.width - descBorder.width;
			descBottom.x = descBorder.x;
			descNameText = new FlxText(descBorder.x, 0, descBorder.width, '');
			descNameText.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE, LEFT);
			add(descNameText);
	
			descText = new FlxText(descBorder.x, 64, descBorder.width, '');
			descText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT);
			add(descText);
			descBorder.scrollFactor.set();
			descBottom.scrollFactor.set();
			descNameText.scrollFactor.set();
			descText.scrollFactor.set();
		}
		saveTxt();
	}

	override function update(elapsed:Float)
		{
			super.update(elapsed);
	
			// menuCamera.followLerp = CoolUtil.camLerpShit(0.05);
	
			items.forEach(function(daItem:TextMenuItem)
			{
				if (items.selectedItem == daItem && daItem.ID != 0) {
					daItem.x = 150;
					descNameText.text = mods[daItem.ID - 1].name;
					descText.text = mods[daItem.ID - 1].description;
					// descNameText.text = daItem.label.text;
					// descText.text = descs[daItem.ID];
				}
				else
					if (daItem.ID != 0)
						daItem.x = 120;
					else {
						descNameText.text = 'Mods';
						descText.text = 'Scroll down to view mod descriptions, if you can only see this in the menu, try adding more mods into to the /mods folder!!!';
						daItem.x = 40;
					}
			});
		}


	private function createMod(prefName:String, prefValue:Dynamic, ?changeable:Bool = true):Void
	{
		if (changeable) {
			var newMod:ModMetadata = new ModMetadata(prefName);
			mods.push(newMod);
		}

		items.createItem(0, (120 * items.length) + 30, (changeable ? mods[mods.length-1].name : prefName), (changeable ? AtlasFont.Default : AtlasFont.Bold), function()
		{
			if (changeable)
				toggle(prefName);
		});

		switch (Type.typeof(prefValue).getName())
		{
			case 'TBool':
				if (changeable)
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
				if (modsList[daItem.ID-1] != null) {
					var flippo = !modsList[daItem.ID - 1][1];
					modsList[daItem.ID - 1][1] = flippo;
					checkboxes[items.selectedIndex - 1].daValue = flippo;
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

class ModMetadata
{
	public var folder:String;
	public var name:String;
	public var description:String;
	public var color:FlxColor;
	public var restart:Bool = false;//trust me. this is very important
	public var alphabet:Alphabet;

	public function new(folder:String)
	{
		this.folder = folder;
		this.name = folder;
		this.description = "No description provided.";

		//Try loading json
		var path = Paths.mods(folder + '/pack.json');
		if(FileSystem.exists(path)) {
			var rawJson:String = File.getContent(path);
			if(rawJson != null && rawJson.length > 0) {
				var stuff:Dynamic = Json.parse(rawJson);
					//using reflects cuz for some odd reason my haxe hates the stuff.var shit
					var description:String = Reflect.getProperty(stuff, "description");
					var name:String = Reflect.getProperty(stuff, "name");
					var restart:Bool = Reflect.getProperty(stuff, "restart");

				if(name != null && name.length > 0)
				{
					this.name = name;
				}
				if(description != null && description.length > 0)
				{
					this.description = description;
				}
				if(name == 'Name')
				{
					this.name = folder;
				}
				if(description == 'Description')
				{
					this.description = "No description provided.";
				}

				if(restart == true)
				{
					this.restart = restart;
				}
			}
		}
	}
}