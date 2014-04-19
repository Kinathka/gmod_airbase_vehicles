

EFFECT.Mat = Material( "effects/select_ring" )

/*---------------------------------------------------------
   Initializes the effect. The data is a table of data 
   which was passed from the server.
---------------------------------------------------------*/
function EFFECT:Init( data )
	
	local vOffset = data:GetOrigin() 
 	local tscale = data:GetScale() * data:GetMagnitude()
 	local NumParticles = 20	 * tscale
 	local emitter = ParticleEmitter( vOffset, true ) 
 	 
 		for i=0, NumParticles do 
 		 
 			local particle = emitter:Add( "effects/spark", vOffset ) 
 			if (particle) then  
 				particle:SetVelocity( VectorRand() * math.Rand(1, 100) * tscale )  
 				particle:SetLifeTime( 0 ) 
 				particle:SetDieTime( math.Rand(0, 1) ) 	 
 				particle:SetStartAlpha( 255 ) 
 				particle:SetEndAlpha( 0 )
				local colorval = math.Rand(80,255)
				particle:SetColor(Color(colorval,colorval,colorval,255))
 				particle:SetStartSize( 0.8 * tscale ) 
 				particle:SetEndSize( 0 ) 
 				particle:SetRoll( math.Rand(0, 360) ) 
 				particle:SetRollDelta( math.Rand(-5, 5) ) 
 				particle:SetAirResistance( 2 ) 
 				particle:SetGravity( Vector( 0, 0, -300 ) ) 
 			 
 			end 
			
		end 
		
		 	local particle = emitter:Add( "particles/AR2Explosion", vOffset ) 
 			if (particle) then 
 				--particle:SetVelocity( VectorRand() * math.Rand(-1, 1) * tscale ) 
 				particle:SetPos(data:GetOrigin())
				particle:SetCollide(true)
				particle:SetLifeTime( 0 ) 
 				particle:SetDieTime( math.Rand(0.1, 1) ) 
 				particle:SetStartAlpha( 255 ) 
 				particle:SetEndAlpha( 0 ) 
 				particle:SetStartSize(20 * tscale ) 
 				particle:SetEndSize( 0 )
 				particle:SetRoll( math.Rand(-10, 10) ) 
 				--particle:SetRollDelta( math.Rand(-5, 5) ) 
 				particle:SetAirResistance( 2 ) 
 				particle:SetGravity( Vector( 0, 0, 100 ) ) 
 			end 
 		 
 	emitter:Finish() 
	
end


/*---------------------------------------------------------
   THINK
---------------------------------------------------------*/
function EFFECT:Think( )
	return false
end

/*---------------------------------------------------------
   Draw the effect
---------------------------------------------------------*/
function EFFECT:Render()
end
