--Light Smoke effect
--effect_av_lightsmokes

function EFFECT:Init( data )
	self.StartPos = data:GetOrigin()
	local Pos = self.StartPos
	
	local obj = data:GetEntity()
	
	if (not IsValid( obj ) ) then
		return
	end
	
	local scale = data:GetScale() or 1
	local mag = data:GetMagnitude() or 1
	local Normal = obj:GetForward()
	Pos = Pos + Normal * 30
	local emitter = ParticleEmitter( Pos, true )
	local particle = emitter:Add( "effects/av_lightsmokes", Pos + Vector(math.random(-10,10)*mag,math.random(-10,10)*mag,math.random(-10,10)*mag))

	particle:SetVelocity( obj:GetVelocity() )
	particle:SetDieTime( math.Rand( 0.4, 1.7 ) )
	particle:SetStartAlpha( math.Rand( 150, 225 ) )
	particle:SetStartSize( math.Rand( 22, 38 ) * scale )
	particle:SetEndSize( math.Rand( 102, 130 ) * scale )
	particle:SetRoll( math.Rand( -1,1 ) )
	particle:SetRollDelta( math.Rand( -1, 1 ) )
	particle:SetColor(  Color( 255, 255, 255,255) )
	particle:VelocityDecay( true )
	particle:SetAirResistance( 10 )
	particle:SetGravity( Vector( math.sin(CurTime()) * 25, math.cos(CurTime()) * 25, math.random(1,100) ) * ( scale / 2 ) )

	emitter:Finish()
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render()
end
