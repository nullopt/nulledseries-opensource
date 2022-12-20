local Draven = {
    axes = {}
}

function Draven:__init()
    self.axes = SDK.Queue.new()

    AddEvent(
        Events.OnCreateObject,
        function(...)
            self:OnCreateObject(...)
        end
    )
    AddEvent(
        Events.OnDeleteObject,
        function(...)
            self:OnDeleteObject(...)
        end
    )
    AddEvent(
        Events.OnBasicAttack,
        function(...)
            self:OnBasicAttack(...)
        end
    )
    AddEvent(
        Events.OnDraw,
        function()
            self:OnDraw()
        end
    )
end

---@param obj GameObject
---@param _ number
function Draven:OnCreateObject(obj, _)
    if obj and string.find(obj.name, "reticle_self") then
        self.axes:push({o = obj, t = GetTickCount() + 1500})
    end
end


---@param obj GameObject
---@param _ number
function Draven:OnDeleteObject(obj, _)
    if obj and string.find(obj.name, "reticle_self") then
        self.axes:pop()
    end
end

---@param source GameObject
---@param args SpellCastInfo
function Draven:OnBasicAttack(source, args)
    if source.networkId == myHero.networkId then
        if args.target.type == GameObjectType.AIHeroClient then
            myHero.spellbook:CastSpell(SpellSlot.Q, myHero.networkId)
        end
    end
end

function Draven:CanCatchAxe(axe)
    local time = axe.t
    -- outer distance
    local outsideEdge = SDK.Vector(axe.o.position) --:extended(SDK.Utility:HeroVPos(), 140)
    local d = SDK.Utility:HeroVPos():dist(outsideEdge)
    -- movement speed
    local s = myHero.characterIntermediate.movementSpeed
    -- time
    local t = d / s
    local timeLeft = (time - GetTickCount()) / 1000
    -- print("time: " .. tostring(time) .. " | t: " .. tostring(t) .. " | timeLeft: " .. tostring(timeLeft))
    return {
        catchable = t < timeLeft or d <= 140,
        radius = timeLeft * s
    }
end

function Draven:OnDraw()
    for i = 1, #self.axes.list do
        local axe = self.axes.list[i]
        local axeObj = axe.o
        local myPos = Renderer:WorldToScreen(myHero.position)
        local axePos = Renderer:WorldToScreen(axeObj.position)
        DrawHandler:Line(myPos, axePos, SDK.Utility.Color.White)
        local canCatch = self:CanCatchAxe(axe)
        SDK.Utility:DrawCircle(
            axeObj.position,
            math.max(140, canCatch.radius),
            10,
            canCatch.catchable and (i == 1 and SDK.Utility.Color.Green or SDK.Utility.Color.Yellow) or
                SDK.Utility.Color.Red
        )
        local nextAxe = self.axes.list[i + 1]
        if nextAxe then
            local aPos = Renderer:WorldToScreen(axeObj.position)
            local nPos = Renderer:WorldToScreen(nextAxe.o.position)
            DrawHandler:Line(aPos, nPos, SDK.Utility.Color.Red)
        end
    end
end

return Draven
