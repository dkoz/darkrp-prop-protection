hook.Add("PhysgunPickup", "PropProtectPickup", function(ply, ent)
	if dpp.physTouch then
		if (ent:GetClass() != "prop_physics") then return end

		ent.oldColor = ent:GetColor()
		ent.oldMat = ent:GetMaterial()

		ent:SetColor(dpp.propColor)
		ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
		ent:SetRenderMode(RENDERMODE_TRANSALPHA)
	end
end)

hook.Add("PhysgunDrop", "PropProtectThrow", function(ply, ent)
	if dpp.propVelocity then
		if not IsValid(ent) then return end
		ent:SetPos(ent:GetPos())
	end
end)

hook.Add("EntityTakeDamage", "PropProtectDmg", function(ent, dmginfo)
	if dpp.propDamage then
		if ent:IsPlayer() and dmginfo:GetDamageType() == DMG_CRUSH then
			dmginfo:ScaleDamage(0.0)
		end
	end
	
	if dpp.vehicleDamage then
		local attacker = dmginfo:GetInflictor()
		if attacker:IsVehicle() then
			dmginfo:SetDamage(0.0)
		end
	end
end)

hook.Add("PlayerSpawnedVehicle", "PropProtectCollide", function(ply, victim)
	-- Needs to be tested
	if dpp.vehicleCollide then
		victim:SetCollisionGroup(COLLISION_GROUP_WEAPON and COLLISION_GROUP_DEBRIS)
	end
end)

local function freezeReal(ent)
	if (timer.Exists(ent:EntIndex().."_waitForPlayersToLeaveToFreezeReal")) then
		timer.Destroy(ent:EntIndex().."_waitForPlayersToLeaveToFreezeReal")
	end
	
	local oldColorFreeze = Color(255, 255, 255)
	
	ent:SetColor(oldColorFreeze)
	ent:SetMaterial(ent.oldMat)
	ent:SetCollisionGroup(COLLISION_GROUP_NONE)
end

local function waitForPlayersToLeave(ent)
	timer.Create(ent:EntIndex().."_waitForPlayersToLeaveToFreezeReal", 1, 0, function()
		local min = ent:LocalToWorld(ent:OBBMins())
		local max = ent:LocalToWorld(ent:OBBMaxs())
		local entities = ents.FindInBox(min, max)
		for k,v in ipairs(entities) do
			if (v:IsPlayer()) then
				return
			end
		end
		
		freezeReal(ent)
	end)
end

hook.Add("OnPhysgunFreeze", "PropProtectFreeze", function(weap, physobj, ent, ply)
	if (ent:GetClass() != "prop_physics") then return end
	
	local min = ent:LocalToWorld(ent:OBBMins())
	local max = ent:LocalToWorld(ent:OBBMaxs())
	local foundEnts = ents.FindInBox(min, max)
	
	for k,v in ipairs(foundEnts) do
		if (v:IsPlayer()) then
			waitForPlayersToLeave(ent)
			return
		end
	end	
	
	freezeReal(ent)
end)

hook.Add("OnEntityCreated", "PropProtectSpawn", function(ent)
	if dpp.propSpawn then
		if (ent:GetClass() != "prop_physics") then return end
		
		ent.oldColor = ent.oldColor or ent:GetColor()
		ent.oldMat = ent.oldMat or ent:GetMaterial()

		ent:SetRenderMode(RENDERMODE_TRANSALPHA)
		ent:SetColor(dpp.propColor)
		ent:SetCollisionGroup(COLLISION_GROUP_WORLD)
	end
end)

-- Old blacklisted prop exploit
hook.Add("PlayerSpawnedProp", "PropProtectExploit", function(ply, model, ent)
	if dpp.propExploit then
		if string.match( model,  ".+%/../" ) and IsValid( ent ) then
			ent:Remove()
			DarkRP.notify( ply, 1, 4, "Please don't be a minge!" )
		end
	end
end)