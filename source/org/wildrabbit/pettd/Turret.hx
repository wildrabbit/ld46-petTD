package org.wildrabbit.pettd;

import flixel.FlxSprite;
import flixel.addons.display.FlxNestedSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxVector;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import org.wildrabbit.pettd.Character;
import org.wildrabbit.pettd.Mob;
import org.wildrabbit.pettd.PlayState;

typedef ProjectileData =
{
	var graphic:FlxGraphicAsset;
	var speed: Float;
	var dmg:Int;
	var ttl:Float;
	var ?homing:Bool;
}

typedef TurretData = {
	var baseGraphic:FlxGraphicAsset;
	var cannonGraphic:FlxGraphicAsset;
	var fireRate:Float;
	var detectionRadius:Float;
	var width:Int;
	var height:Int;
	
	var ?bulletData:ProjectileData;	
}

/**
 * ...
 * @author wildrabbit
 */
class Turret extends FlxNestedSprite 
{

	//var baseSprite:FlxSprite;
	var cannonSprite:FlxNestedSprite;
	var root:PlayState;
	var mobs:FlxTypedGroup<Mob>;
	var bulletData:ProjectileData;
	
	var fireRate:Float;
	var detectionRadius:Float;
	
	var currentTarget:Mob;
	
	var fireTimer:FlxTimer;
	var fireReady:Bool;
	var detection:FlxNestedSprite;
	
	public function new(X:Float=0, Y:Float=0, turretData:TurretData, state:PlayState) 
	{
		super(X, Y);
		loadGraphic(turretData.baseGraphic);
		
		
		root = state;
		this.fireRate = turretData.fireRate;
		this.detectionRadius = turretData.detectionRadius;
		
		
		if (turretData.bulletData != null)
		{
			bulletData = turretData.bulletData;			
		}
		
		cannonSprite = new FlxNestedSprite(X,Y);
		add(cannonSprite);
		cannonSprite.x = cannonSprite.y = 0;
		cannonSprite.loadRotatedGraphic(turretData.cannonGraphic, 360);
		cannonSprite.angle = 0;
		
		
		detection = new FlxNestedSprite();
		detection.makeGraphic(2 * Math.round(detectionRadius), 2 * Math.round(detectionRadius), FlxColor.TRANSPARENT);
		add(detection);
		
		var lineStyle:LineStyle = {
			thickness:1,
			color:FlxColor.WHITE
		};
		
		FlxSpriteUtil.drawCircle(detection, detectionRadius, detectionRadius, detectionRadius, FlxColor.TRANSPARENT, lineStyle);
		detection.relativeX = detection.relativeY = -(detectionRadius - width/2);
		
		
		
		this.mobs = root.mobs;
		
		fireTimer = new FlxTimer();
		fireReady = true;
	}
	
	override public function update(elapsed:Float):Void 
	{
		var lastAngle:Float = cannonSprite.relativeAngle;
		super.update(elapsed);
		
		var minMobDistance:Float = Math.POSITIVE_INFINITY;
		var targetCandidate:Mob = null;
		var center:FlxPoint = getMidpoint();
		for (mob in mobs)
		{
			var mobDistance = FlxMath.distanceBetween(mob, this);
			if (mobDistance > detectionRadius) continue;
			if (mobDistance < minMobDistance)
			{
				minMobDistance = mobDistance;
				targetCandidate = mob;
			}
		}
		
		if (targetCandidate!= null)
		{
			var targetAngle:Float = center.angleBetween(targetCandidate.getMidpoint());
			cannonSprite.relativeAngle = targetAngle;
			trace('target + cannon rot: ${cannonSprite.angle}');
		}
		else
		{
			cannonSprite.relativeAngle = lastAngle;
		}
		currentTarget = targetCandidate;
		
		if (canFire())
		{
			fire();
		}
	}
	
	function canFire():Bool
	{
		return currentTarget != null && fireReady;
	}
	
	function fire():Void
	{
		trace('Turret at (${x},${y}) goes pew, pew!');
		var point:FlxPoint = getMidpoint();
		point.y -= height / 2;
		point.rotate(getMidpoint(), cannonSprite.relativeAngle);
		// spawn projectile
		root.shootBullet(point, currentTarget, bulletData);
		fireReady = false;
		fireTimer.start(fireRate, onTimerSet);
	}
	
	function onTimerSet(timer:FlxTimer):Void
	{
		fireTimer.cancel();
		fireReady = true;
	}
}