function Speedhack()
    if not AdvGetBool(fSpeed) then 
        return 
    end

    if not IsDirectionalInputDown() then
        return 
    end 

    local velocity = GetPlayerVelocity()

    local TargetVel = GetSubFloat(fSpeed, fSubSpeed)
    if TWInputDown("shift") then 
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