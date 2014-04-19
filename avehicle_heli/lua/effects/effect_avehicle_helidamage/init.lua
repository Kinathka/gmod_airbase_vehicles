
function EFFECT:Init(data)

local scale = data:GetScale()
local mag = data:GetMagnitude()

local Pos = data:GetOrigin() + Vector( 0,0,10 )
	local emitter = ParticleEmitter( Pos, true )

	local effectdata = EffectData()
	effectdata:SetOrigin( Pos )
	effectdata:SetNormal( Vector(0,0,0) )
	effectdata:SetMagnitude( mag *2)
	effectdata:SetScale(scale *2)
	effectdata:SetRadius( 100 )
	util.Effect( "Sparks", effectdata, true, true )

	

	--smoke puff
	for i = 1, (6*scale) do
		local particle = emitter:Add("particles/smokey",Pos+(Vector(math.random(-15,150),math.random(-150,15),math.random(-30,10))*scale))
		particle:SetVelocity(Vector(math.random(-60,70),math.random(-100,70),math.random(70,180)))
		particle:SetDieTime(math.Rand(2.9,3.3))
		particle:SetStartAlpha(math.Rand(205,255))
		particle:SetStartSize(math.Rand(100,130)*mag)
		particle:SetEndSize(math.Rand(192,256)*mag)
		particle:SetRoll(math.Rand(360,480))
		particle:SetRollDelta(math.Rand(-1,1))
		particle:SetColor(Color(170,160,160,255))
		particle:VelocityDecay(true)
		particle:SetGravity(Vector(0,0,math.random(-30,-10)))
	end

	--big smoke cloud
	for i = 1, (6*scale) do
		local particle = emitter:Add("particles/smokey",Pos+(Vector(math.random(-80,70),math.random(-30,80),math.random(20,280))*scale))
		particle:SetVelocity(Vector(math.random(-60,70),math.random(-100,70),math.random(70,180)))
		particle:SetDieTime(math.Rand(2.5,3.7))
		particle:SetStartAlpha(math.Rand(90,100))
		particle:SetStartSize(math.Rand(55,66)*mag)
		particle:SetEndSize(math.Rand(192,256)*mag)
		particle:SetRoll(math.Rand(480,540))
		particle:SetRollDelta(math.Rand(-1,1))
		particle:SetColor(Color(170,170,170,255))
		particle:VelocityDecay(true)
		particle:SetGravity(Vector(0,0,math.random(-30,-10)))
	end

	self.Refract = 0
	
	self.Size = 4
	
	self:SetRenderBounds( Vector()*-256, Vector()*256 )
	
	
end


function EFFECT:Think()
	return false	
end



function EFFECT:Render()

end



