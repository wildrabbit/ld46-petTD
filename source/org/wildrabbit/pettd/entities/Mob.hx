package org.wildrabbit.pettd.entities;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxPoint;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.tile.FlxBaseTilemap.FlxTilemapDiagonalPolicy;
import flixel.util.FlxPath;
import flixel.util.FlxSignal;
import flixel.util.FlxTimer;
import org.wildrabbit.pettd.AssetPaths;
import org.wildrabbit.pettd.PlayState;
import org.wildrabbit.pettd.entities.Bullet;
import org.wildrabbit.pettd.entities.Character;
import org.wildrabbit.pettd.world.Level;

typedef MobData =
{
	var characterData:CharacterData;
	var damage:Int;
	var speed:Int;
	// TODO: Change to weighted list + types
	var nutrientSpawnChance:Float;
	var nutrientSpawnMin:Int;
	var nutrientSpawnMax:Int;
	var nutrientType:String;
}

/**
 * ...
 * @author wildrabbit
 */
class Mob extends Character 
{
	static  var maxID:Int = 0;
	var moving:Bool = false;
	public var damage:Int;
	public var speed:Int;
	
	public var spawnChance:Float;
	public var spawnMin:Int;
	public var spawnMax:Int;
	public var spawnType:String;
	
	public var mobUID:Int;
	
	public var oldSpeed:Int;
	
	public var destroyedByBullet:FlxTypedSignal<Mob->Void>;
	public var speedTimer:FlxTimer;
	
	var freezeVFX:FlxSprite;
	
	public function new(?X:Float=0, ?Y:Float=0, mobData:MobData, root:PlayState) 
	{
		super(X, Y, mobData.characterData, root);
		
		damage = mobData.damage;
		speed = mobData.speed;
		oldSpeed = -1;
		
		
		path = new FlxPath();
		moving = false;
		path.cancel();
		velocity.x = velocity.y = 0;

		spawnChance = mobData.nutrientSpawnChance;
		spawnMin = mobData.nutrientSpawnMin;
		spawnMax = mobData.nutrientSpawnMax;
		spawnType = mobData.nutrientType;
		
		speedTimer = new FlxTimer();
		
		mobUID = Mob.maxID++;
		
		destroyedByBullet = new FlxTypedSignal();
	}
	
	public function applySlow(percent:Int, duration:Float, gfx:FlxGraphicAsset):Void
	{
		if (oldSpeed == -1)
		{
			// set
			oldSpeed = speed;
			speed += Math.round(percent * 0.01 * speed);
			speedTimer.start(duration, speedIncreaseExpired);
			
			freezeVFX = new FlxSprite(0, 0, gfx);
			root.addMobVFX(freezeVFX, this);
			path.speed = speed;
		}
		else
		{
			// reset
			speedTimer.reset(duration);
		}
	}
	
	public function speedIncreaseExpired(timer:FlxTimer):Void
	{
		path.speed = oldSpeed;
		oldSpeed = -1;
		timer.cancel();
		root.removeMobVFX(this);
		freezeVFX.destroy();
		freezeVFX = null;
	}
	
	public function goTo(target:FlxSprite, level:Level):Void
	{
		var start:FlxPoint = getMidpoint();
		var end:FlxPoint = target.getMidpoint();
		var pathPoints:Array<FlxPoint> = level.navigationMap.findPath(start, end, true, false, FlxTilemapDiagonalPolicy.NONE);
		path.start(pathPoints,speed, FlxPath.FORWARD);
		
		moving = true;
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		
		if (moving )
		{
			if (path.finished)
			{
				path.cancel();
				velocity.x = velocity.y = 0;
				moving = false;
			}
			else
			{
				if (velocity.x >= 0) facing = FlxObject.RIGHT;
				else facing = FlxObject.LEFT;
				
			}
		}
	}
	
	public function hitByBullet(bullet:Bullet):Void
	{
		takeDamage(bullet.dmg);
		if (hp == 0)
		{
			destroyedByBullet.dispatch(this);
		}
	}
	
	public function petHit():Void
	{
		takeDamage(hp);
	}
	
	public function stop():Void
	{
		if (moving)
		{
			path.cancel();
			velocity.x = velocity.y = 0;
			moving = false;
		}
	}
	
		
	public override function takeDamage(dmg:Int):Void
	{
		var startHP:Int = hp;
		super.takeDamage(dmg);		
		if (hp == 0 && freezeVFX != null)
		{
			{
				speedTimer.cancel();
				root.removeMobVFX(this);
				freezeVFX.destroy();
				freezeVFX = null;
			}
		}

	}
}