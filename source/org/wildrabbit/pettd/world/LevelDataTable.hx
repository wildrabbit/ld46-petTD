package org.wildrabbit.pettd.world;

import openfl.Assets;
import haxe.Json;

typedef FloatVec2 =
{
	var x:Float;
	var y:Float;
}

typedef IntVec2 =
{
	var x:Int;
	var y:Int;
}

typedef IntRect =
{
	var x:Int;
	var y:Int;
	var w:Int;
	var h:Int;
}

typedef WaveData =
{
	var spawnDelay:Float;
	var timeMarker:Float;
	var mobs:Array<Int>;
	var mobSpawn:String;
}

typedef LevelJson = 
 {
	var id:Int;
	var name:String;
	
	var levelTMXPath:String;

	var waves: Array<WaveData>;
	var startFood:Int;
	var allowedTurrets:Array<Int>;
	var ?feedDisabled:Bool;
 }

/**
 * ...
 * @author Ithil
 */
class LevelDataTable 
{
	var table:Array<LevelJson>;
		
	public function new(path:String) 
	{
		var levelFile:String = Assets.getText(path);
		table = Json.parse(levelFile);
	}
	
	public var numLevels(get, null):Int;
	
	function get_numLevels()
	{
		return table.length;
	}
	
	public function getLevelAt(idx:Int):LevelJson
	{
		if (idx < 0 || idx >= table.length)
		{
			trace('Invalid level table idx $idx');
		}
		return table[idx];
	}	
}