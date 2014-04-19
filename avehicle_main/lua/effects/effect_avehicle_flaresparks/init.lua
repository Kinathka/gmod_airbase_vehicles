
function EFFECT:Init( data )

	self.StartPos= data:GetOrigin()
	local Pos = self.StartPos
	
	local Normal = Vector(0,0,1)
	
	Pos = Pos + Normal * 2
	
	local emitter = ParticleEmitter( Pos, true )
	
		for i = 1, 2 do
			local offset = Pos + Vector(math.sin(CurTime())*math.random(-60,60),math.cos(CurTime())*math.random(-60,60),math.sin(CurTime())*math.random(-60,60))
			local particle = emitter:Add( "effects/av_flare", offset)

			particle:SetVelocity( Vector(math.Rand(-55,55),math.Rand(-55,50),math.Rand(-80,1)) )
			particle:SetDieTime( math.Rand( 4, 7 ) )
			particle:SetStartAlpha( math.Rand( 230, 245 ) )
			particle:SetStartSize( math.Rand( 30, 40 ) )
			particle:SetEndSize( 1 )
			
			particle:SetRoll( math.Rand( 280, 350 ) )
			particle:SetRollDelta( math.Rand( -1, 1 ) )
			particle:SetColor( Color( 255, 255, 255 ) )
			particle:VelocityDecay( true )
			particle:SetAirResistance( 20 )
			
			particle:SetGravity( Vector( math.random(-37,37), math.random(-37,37), math.random( -255, 20 ) ) )
			
		end
		
	emitter:Finish()
	
end



function EFFECT:Think( )
	return false
end


function EFFECT:Render()
end



