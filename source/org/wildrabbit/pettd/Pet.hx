package org.wildrabbit.pettd;

import flixel.FlxSprite;
import org.wildrabbit.pettd.AssetPaths;


/**
 * ...
 * @author wildrabbit
 */
class Pet extends Character 
{

	public function new(?X:Float=0, ?Y:Float=0) 
	{
		var petData = {
			"sheetFile":AssetPaths.proto_pet__png,
			"atlasFile":AssetPaths.proto_pet__json,
			"prefix":"proto-pet",
			"postfix":".aseprite",
			"anims":[{"name":"idle", "frames":[0,1], "fps":3}],
			"defaultAnim":"idle"
		};
		super(X, Y, petData);
	}
	
}