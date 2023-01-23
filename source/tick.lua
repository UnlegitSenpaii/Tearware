-- tearware on top

-- called once per frame (dt is a dynamic float value between 0 and .0(3), 60fps = 0.1(6) )
function tick(dt) 
    if PauseMenuButton(fProjectName) then
		openMenu = "tearware"
    end

    if InputPressed("insert") then
        if openMenu ~= nil then 
            openMenu = nil 
        else 
            openMenu = "tearware"
        end
    end

    UpdateAllFeatureStates()

    -- delta time scaled, .5 = 120fps, 1 = 60fps, 2 = 30fps
    local dts = dt / fixed_update_rate

    -- universal features
    Timer()
    ForceUpdateAllBodies()
    DisablePhysics()
    ColoredFog()
    PostProcessing()

    if GetPlayerVehicle() ~= 0 then
        -- in vehicle
        return
    end

    -- strict
    Spider() 
    Speedhack()
    Jesus()
    Floorstrafe()
    Jetpack(dts)
    Fly()
    NoClip(dts)
    Teleport()
    ExplosionBrush()
    FireBrush()
    Quickstop()
    SuperStrength()
    SpinningTool()
end

function Timer()
    if not AdvGetBool(fBulletTime) then 
        if #activeBodyCache > 0 then
			activeBodyCache = {}
		end
        return 
    end

    local scale = GetSubFloat(fBulletTime, fBulletTimeScale)/100
    SetTimeScale(scale)

    local patch = GetSubBool(fBulletTime, fBulletTimePatch)
    if not patch then 
        return 
    end

    -- prevent the engine from freezing the objects.
	local bodies = FindBodies(nil,true)
	for i=1,#bodies do
		local body = bodies[i]
		if IsBodyActive(body) then
            local exists = false
            for i=1, #activeBodyCache do
                local item = activeBodyCache[i]
                if body == item then
                    exists = true
                end
            end
            if not exists then
                table.insert(activeBodyCache,body)
            end
		end
	end

	if #activeBodyCache > 0 then
        for i=1, #activeBodyCache do
            local body = activeBodyCache[i]
            if not IsHandleValid(body) then 
                -- DebugPrint("trying to update a broken body! cleaning up")
                table.remove(activeBodyCache, i)
            else 
                local velLength = VecLength(GetBodyVelocity(body))
                local angLength = VecLength(GetBodyAngularVelocity(body))
                
                -- completely arbitrary numbers!
                if velLength > 0.01 or angLength > 0.01 then 
                    -- DrawBodyOutline(body, 1, 0, 0, 1)

                    SetBodyActive(body, true)
                else 
                    -- DebugPrint("removing a body that is already inactive.")
                    -- DrawBodyOutline(body, 0, 1, 0, 1)

                    SetBodyActive(body, false)
                    table.remove(activeBodyCache, i)
                end
            end
        end
	end

    -- DebugPrint(#activeBodyCache)
end

function ForceUpdateAllBodies()
    if not AdvGetBool(fForceUpdatePhysics) then
        return 
    end

    local bodies = FindBodies(nil,true)
    for i=1,#bodies do
        SetBodyActive(bodies[i], true)
    end
end

function DisablePhysics()
    if not AdvGetBool(fDisablePhysics) then
        return 
    end

	local bodies = FindBodies(nil,true)
    for i=1,#bodies do
        SetBodyActive(bodies[i], false)
    end
end

function Spider() 
    if not AdvGetBool(fSpider) then 
        return 
    end

    local hit = QueryRaycast(GetPlayerPos(), Vec(0, -1, 0), 0.1, 0.7)

    if not hit or not InputDown("jump") then 
        return 
    end

    local vel = GetPlayerVelocity()
    vel[2] = 4
    SetPlayerVelocity(vel)
end

function Speedhack()
    if not AdvGetBool(fSpeed) then 
        return 
    end

    if not IsDirectionalInputDown() then
        return 
    end 

    local velocity = GetPlayerVelocity()

    local TargetVel = GetSubFloat(fSpeed, fSubSpeed)
    if InputDown("shift") then 
        TargetVel = GetSubFloat(fSpeed, fSubBoost)
    end

    -- scary math below, run.

    -- get scary quat
    local rot = GetCameraTransform().rot
    -- convert to cool angles
    local x, backupy, z = GetQuatEuler(rot)
    local y = TransformYawByInput(backupy)

    -- euler to vector
    local rady = math.rad(y)
	local siny = math.sin(rady)
	local cosy = math.cos(rady)

    -- change our cool math to something the game can use
    local forward = Vec(0,0,0)
    forward[3] = -cosy
    forward[1] = -siny

    -- apply velocity scale
    velocity = VecScale(forward, TargetVel)

    -- make sure we didn't mess up on the axis we don't care about
    velocity[2] = GetPlayerVelocity()[2]

    SetPlayerVelocity(velocity)
end

function Jesus()
	if not AdvGetBool(fJesus) then
        return
    end
    local transform = GetPlayerTransform()
    local inWater, depth = IsPointInWater(transform.pos)

    if not inWater then 
        return 
    end

    local velocity = GetPlayerVelocity()
    
    if InputDown("jump") then 
        velocity[2] = 5
    elseif depth > 0.1 then 
        velocity[2] = 6
    else
        velocity[2] = depth*20
    end

    SetPlayerVelocity(velocity)
end

function Floorstrafe() 
    if not AdvGetBool(fFloorStrafe) then 
        return 
    end

    local velocity = GetPlayerVelocity()

    velocity[2] = 1

    SetPlayerGroundVelocity(velocity)

end

function Jetpack(dts) 
    if not AdvGetBool(fJetpack) then 
        return 
    end

    if InputDown("jump") then 
        local velocity = GetPlayerVelocity()

        velocity[2] = velocity[2] + (0.5 * dts)
        if velocity[2] > 7 then 
            velocity[2] = 7 
        end

        SetPlayerVelocity(velocity) 
    end

end

function Fly()
    if not AdvGetBool(fFly) then 
        return 
    end

    SetPlayerVelocity(Vec(0, 0, 0))

    local TargetVel = GetSubFloat(fFly, fSubSpeed)
    if InputDown("shift") then 
        TargetVel = GetSubFloat(fFly, fSubBoost)
    end

    if not IsDirectionalInputDown() then

        local ohno = 0
        if InputDown("jump") then 
            ohno = TargetVel
        end 
        
        if InputDown("crouch") then 
            ohno = ohno -TargetVel
        end
    
        SetPlayerVelocity(Vec(0, ohno, 0))

        return 
    end 

    local velocity = GetPlayerVelocity()

    -- scary math below, run.

    -- get scary quat
    local rot = GetCameraTransform().rot
    -- convert to cool angles
    local x, backupy, z = GetQuatEuler(rot)
    local y = TransformYawByInput(backupy)

    -- euler to vector
    local rady = math.rad(y)
	local siny = math.sin(rady)
	local cosy = math.cos(rady)

    -- change our cool math to something the game can use
    local forward = Vec(0,0,0)
    forward[3] = -cosy
    forward[1] = -siny

    -- apply velocity scale
    velocity = VecScale(forward, TargetVel)

        
    local ohno = 0
    if InputDown("jump") then 
        ohno = TargetVel
    end 
    
    if InputDown("crouch") then 
        ohno = ohno - TargetVel
    end

    velocity[2] = ohno

    SetPlayerVelocity(velocity)
end

function NoClip(dts)
    if not AdvGetBool(fNoclip) then
        noclipbackuppos = {}
        return 
    end

    local trans = GetPlayerTransform(true)

    -- teleport/edge of map/respawn detection
    local delta = VecLength( VecSub(noclipbackuppos, trans.pos) )

    if delta > 1 or #noclipbackuppos == 0 then 
        noclipbackuppos = trans.pos
    end

    trans.pos = noclipbackuppos

    local speed = GetSubFloat(fNoclip, fSubSpeed)/10
    if InputDown("shift") then 
        speed = GetSubFloat(fNoclip, fSubBoost)/10
    end

    -- scale by update rate
    speed = speed * dts

    if IsDirectionalInputDown() then

        local x, y, z = GetQuatEuler(trans.rot) 
        local dir = TransformYawByInput(y)

        trans.rot = QuatEuler(x, dir, z)

        local parentpoint = TransformToParentPoint(trans, Vec(0, 0, -1))

        trans.rot = QuatEuler(x, y, z)
        
        local direction = VecScale(VecNormalize(VecSub(parentpoint, trans.pos)), speed)

        trans.pos[1] = trans.pos[1] + direction[1]
        trans.pos[3] = trans.pos[3] + direction[3]
    end 
    
    if InputDown("jump") then
        trans.pos[2] = trans.pos[2] + speed
    end 

    if InputDown("crouch") then
        trans.pos[2] = trans.pos[2] - speed
    end 

    SetPlayerTransform(trans, true)
end

function Teleport() 
    if not AdvGetBool(fTeleport) then 
        return 
    end

    local TargetPos = GetPosWeAreLookingAt()

    if TargetPos ~= nil then 
        local t = Transform(TargetPos, GetCameraTransform().rot)
            
        SetPlayerTransform(t, true)
    end
        
    SetBool(cfgstr .. fTeleport[2], false)
end

function ExplosionBrush() 
    if not AdvGetBool(fExplosionBrush) then 
        return 
    end
    
    local Size = GetSubFloat(fExplosionBrush, fExplosionBrushSize)
    local TargetPos = GetPosWeAreLookingAt()
    if TargetPos ~= nil then 
        Explosion(TargetPos, Size)
    end
end

function FireBrush() 
    if not AdvGetBool(fFireBrush) then 
        return 
    end
    
    local TargetPos = GetPosWeAreLookingAt()
    if TargetPos ~= nil then 
        SpawnFire(TargetPos)
        PointLight(TargetPos, 0.7, 0.2, 0.2, 1)
    end
end

function Quickstop() 
    if not AdvGetBool(fQuickstop) then 
        return 
    end

    if IsDirectionalInputDown() then
        return 
    end

    local velocity = {0, 0, 0}
    velocity[2] = GetPlayerVelocity()[2]
    SetPlayerVelocity(velocity) 
end

-- todo:
-- account for where we grabbed the object (instead of using body center)
function SuperStrength()
    if not AdvGetBool(fSuperStrength) then 
        return 
    end

    -- engine grab, haha, no
    ReleasePlayerGrab()

    if not InputDown("rmb") then 
        ss_object.obj = nil
        if ss_last_tool ~= nil then 
            SetString("game.player.tool", ss_last_tool)
            ss_last_tool = nil
        end
        return
    end

    if InputPressed("rmb") then 
        local object, dist = GetObjectWeAreLookingAt()
        ss_last_tool = GetString("game.player.tool")

        if ss_object.obj == nil then 
            if object ~= nil then 
                ss_object.obj = object 
                ss_object.dist = dist
            else 
                return 
            end
        end
    end

    SetString("game.player.tool", "tearware_prop")
    SetInt("game.tool.tearware_prop.ammo", 9999)

    if not IsHandleValid(ss_object.obj) then 
        ss_object.obj = nil
        return
    end

    if not IsBodyDynamic(ss_object.obj) then 
        ss_object.obj = nil
        return
    end

    if InputDown("lmb") then 
        -- LAUNCH!
        if ss_object.obj ~= nil then 
            local dir = GetForwardDirection()
            local velocity = GetBodyVelocity(ss_object.obj)
            
            velocity = VecAdd(velocity, VecScale(dir, 50))

            SetBodyVelocity(ss_object.obj, velocity)
            ss_object.obj = nil
        end
        return
    end

    local scrollPos = InputValue("mousewheel")
    if scrollPos ~= 0 then 
        if InputDown("shift") then 
            scrollPos = scrollPos * 5
        end
        ss_object.dist = ss_object.dist + scrollPos
    end

    DrawBodyOutline(ss_object.obj, 1, 1, 1, 1)

    local direction, camera = GetForwardDirection()
    local targetLocation = VecAdd(camera.pos, VecScale(direction, ss_object.dist))
    
    -- local objTransform = GetBodyTransform(ss_object.obj)
    -- objTransform.pos = targetLocation
    -- SetBodyTransform(ss_object.obj, objTransform)
    -- SetBodyActive(ss_object.obj, false)

    local vel = VecSub(targetLocation, GetBodyCenter(ss_object.obj))
    vel = VecScale(vel, VecLength(vel))
    SetBodyVelocity(ss_object.obj, vel)

    -- angular velocity is cringe
    SetBodyAngularVelocity( {0,0,0} )
end

function ColoredFog() 
    if not AdvGetBool(fRainbowFog) then 
        if #cached_fog_color > 0 then 
            SetEnvironmentProperty("fogcolor", cached_fog_color[1], cached_fog_color[2], cached_fog_color[3])
            cached_fog_color = {}
        end
        return 
    end

    -- cache fog color
    if #cached_fog_color == 0 then 
        cached_fog_color[1], cached_fog_color[2], cached_fog_color[3] = GetEnvironmentProperty("fogcolor")
    else
        local color = GetColor(fRainbowFog, GetTime())
        SetEnvironmentProperty("fogcolor", color.red, color.green, color.blue)
    end
end

function PostProcessing()
    if not AdvGetBool(fPostProcess) then 
        if #cached_post_process > 0 then 
            SetPostProcessingProperty("colorbalance", cached_post_process[1], cached_post_process[2], cached_post_process[3])
            SetPostProcessingProperty("saturation", cached_post_process[4])
        end
        return
    end

    -- cache post process
    if #cached_post_process == 0 then 
        cached_post_process[1], cached_post_process[2], cached_post_process[3] = GetPostProcessingProperty("colorbalance")
        cached_post_process[4] = GetPostProcessingProperty("saturation")
    else
        local color = GetColor(fPostProcess, GetTime())
        SetPostProcessingProperty("colorbalance", color.red * 2, color.green * 2, color.blue * 2)
        SetPostProcessingProperty("saturation", color.alpha * 2)
    end
end

function SpinningTool()
    if not AdvGetBool(fSpinnyTool) then 
        return
    end
    
    local toolBody = GetToolBody()
    if toolBody == nil then 
        return 
    end

    -- color to spin! science!
    local rgb = seedToRGB(GetTime())

    local rot = QuatEuler(rgb.R * 360, rgb.G* 360, rgb.B* 360)
    local offset = Transform( Vec(0, 0, -2), rot)

    SetToolTransform(offset)
end