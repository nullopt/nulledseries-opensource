local Ezreal = {
    q = {
        type = "linear",
        range = 1150,
        width = 120,
        speed = 2000,
        delay = 0.25,
				collision = {
						["Wall"] = true,
						["Hero"] = true,
						["Minion"] = true
				},
        baseDamage = {20, 45, 70, 95, 120}
    },
    w = {
        type = "linear",
        range = 1150,
        width = 160,
        speed = 1700,
        delay = 0.25,
        collision = {
            ["Wall"] = true,
            ["Hero"] = true
        },
        baseDamage = {80, 135, 190, 245, 300},
        scaleDamage = {0.7, 0.75, 0.8, 0.85, 0.9}
    },
    r = setmetatable({
        type = "linear",
        width = 320,
        speed = 2000,
        delay = 1.0,
        baseDamage = {350, 500, 650}
    }, {
        __index = function(_, key)
            if key == "range" then
                return SDK.MenuManager.Menu.combo.rrange.value
            end
        end
    })
}

function Ezreal:__init()
    -- GENERATE MENU
    -- Combo Menu
    SDK.MenuManager.Menu:sub("combo", "[=] Combo")
    SDK.MenuManager.Menu.combo:label("sep0", "Q Settings", true, true)
    SDK.MenuManager.Menu.combo:checkbox("q", "Use Q", true)
    SDK.MenuManager.Menu.combo:label("sep1", "W Settings", true, true)
    SDK.MenuManager.Menu.combo:checkbox("w", "Use W", true)
    SDK.MenuManager.Menu.combo:checkbox("wq", "Prioritize W over Q", true)
    SDK.MenuManager.Menu.combo:label("sep3", "R Settings", true, true)
    SDK.MenuManager.Menu.combo:slider("rrange", "Range", 100, 5000, 2000, 100, true)
    SDK.MenuManager.Menu.combo:key("semir", "Semi Auto R [Most Damage]", string.byte("T"))

    -- Harass Menu
    SDK.MenuManager.Menu:sub("harass", "[=] Harass")
    SDK.MenuManager.Menu.harass:label("sep0", "Q Settings", true, true)
    SDK.MenuManager.Menu.harass:checkbox("q", "Use Q", true)
    SDK.MenuManager.Menu.harass:checkbox("qauto", "Auto Q", true)
    SDK.MenuManager.Menu.harass:label("sep1", "Mana Settings", true, true)
    SDK.MenuManager.Menu.harass:slider("mana", "Min. Mana %", 0, 100, 50, 1, true)

    -- Lane Menu
    SDK.MenuManager.Menu:sub("laneclear", "[=] Lane Clear")
    SDK.MenuManager.Menu.laneclear:label("sep0", "Q Settings", true, true)
    SDK.MenuManager.Menu.laneclear:checkbox("q", "Use Q on Unkillable", true)
    SDK.MenuManager.Menu.laneclear:label("sep1", "Mana Settings", true, true)
    SDK.MenuManager.Menu.laneclear:slider("mana", "Min. Mana %", 0, 100, 50, 1, true)

    AddEvent(Events.OnTick, function()
        self:OnTick()
    end)
    AddEvent(Events.OnDraw, function()
        self:OnDraw()
    end)
    AddEvent(Events.OnBuffGain, function(...)
        self:OnBuffGain(...)
    end)
    SDK.UOL:AddCallback("OnUnKillable", function(...)
        self:OnUnKillable(...)
    end)
end

function Ezreal:GetQDamage(unit)
    local qLevel = SDK.Utility:GetSpellLevel(SpellSlot.Q)
    if (qLevel == 0) then
        return 0
    end
    local qBaseDamage = self.q.baseDamage[qLevel] + (1.2 * SDK.Utility:GetTotalAD()) + (0.15 * SDK.Utility:GetTotalAP())
    return SDK.DamageLib:CalculatePhysicalDamage(myHero, unit, qBaseDamage)
end

function Ezreal:GetWDamage(unit)
    local wLevel = SDK.Utility:GetSpellLevel(SpellSlot.W)
    if (wLevel == 0) then
        return 0
    end
    local wBaseDamage = self.w.baseDamage[wLevel] + (0.6 * SDK.Utility:GetBonusAD()) +
                            (self.w.scaleDamage[wLevel] * SDK.Utility:GetTotalAP())
    return SDK.DamageLib:CalculateMagicDamage(myHero, unit, wBaseDamage)
end

function Ezreal:GetRDamage(unit)
    local rLevel = SDK.Utility:GetSpellLevel(SpellSlot.R)
    if (rLevel == 0) then
        return 0
    end
    local rBaseDamage = self.r.baseDamage[rLevel] + SDK.Utility:GetBonusAD() + (0.9 * SDK.Utility:GetTotalAP())
    return SDK.DamageLib:CalculateMagicDamage(myHero, unit, rBaseDamage)
end

function Ezreal:CastQ(target)
    local pred = _G.Prediction.GetPrediction(target, self.q, myHero)
    if pred and pred.rates["slow"] and pred.castPosition and SDK.Utility:HeroVPos():dist(SDK.Vector(pred.castPosition)) <
        self.q.range then
        local dynamicRange = SDK.Utility:DynamicRange(pred, target, self.q)
        if dynamicRange and not pred:windWallCollision() and not pred:minionCollision() then
            myHero.spellbook:CastSpell(SpellSlot.Q, pred.castPosition)
        end
    end
end

function Ezreal:CastW(target)
    local pred = _G.Prediction.GetPrediction(target, self.w, myHero)
    if (pred and pred.rates["slow"] and pred.castPosition and SDK.Utility:HeroVPos():dist(SDK.Vector(pred.castPosition)) <
        self.q.range and not pred:windWallCollision()) then
        local dynamicRange = SDK.Utility:DynamicRange(pred, target, self.w)

        if not dynamicRange then
            return
        end

        myHero.spellbook:CastSpell(SpellSlot.W, pred.castPosition)
    end
end

function Ezreal:CastR(target)
    local pred = _G.Prediction.GetPrediction(target, self.r, myHero)
    if (pred and pred.castPosition and pred.rates["slow"] and not pred:windWallCollision() and
        SDK.Utility:HeroVPos():dist(SDK.Vector(pred.castPosition)) < self.r.range) then
        myHero.spellbook:CastSpell(SpellSlot.R, pred.castPosition)
    end
end

function Ezreal:ComboQ(target)
    if (not target) then
        return
    end

    if (not SDK.MenuManager.Menu.combo.q:get()) then
        return
    end

    if (not SDK.Utility:CanCastSpell(SpellSlot.Q)) then
        return
    end

    if (SDK.MenuManager.Menu.combo.wq:get() and SDK.Utility:CanCastSpell(SpellSlot.W)) then
        return
    end

    if (not SDK.Utility:IsValidTarget(target, self.q.range)) then
        return
    end

    self:CastQ(target)
end

function Ezreal:ComboW(target)
    if (not target) then
        return
    end

    if (not SDK.MenuManager.Menu.combo.w:get()) then
        return
    end

    if (not SDK.Utility:CanCastSpell(SpellSlot.W)) then
        return
    end

    if (not SDK.Utility:IsValidTarget(target, self.w.range)) then
        return
    end

    self:CastW(target)
end

function Ezreal:SemiCastR()
    if (SDK.MenuManager.Menu.combo.semir:get() and SDK.Utility:CanCastSpell(SpellSlot.R)) then
        local target = nil
        local damage = 0

        local forced_target = SDK.UOL:GetForcedTarget()
        if (forced_target) then
            return self:CastR(forced_target)
        end

        for _, enemy in pairs(ObjectManager:GetEnemyHeroes()) do
            if (SDK.Utility:IsValidTarget(enemy, self.r.range)) then
                local d = self:GetRDamage(enemy)
                if (d >= enemy.health) then
                    if (SDK.Utility:IsValidTarget(enemy, self.r.range)) then
                        self:CastR(enemy)
                    end
                    return
                end
                if (d > damage) then
                    damage = d
                    target = enemy
                end
            end
        end
        if (SDK.Utility:IsValidTarget(target, self.r.range)) then
            self:CastR(target)
        end
    end
end

function Ezreal:OnTick()
    if (not SDK.UOL) then
        return
    end

    self:SemiCastR()

    if (SDK.UOL:IsAttacking()) then
        return
    end

    if (SDK.UOL:GetMode() == "Combo") then
        local q_targets, _ = SDK.MenuManager.TS:GetTargets(self.q, myHero)
        local w_target = SDK.MenuManager.TS:GetTarget(self.w, myHero)
        if (w_target) then
            self:ComboW(w_target)
        end
        -- prioritize targets with w
        for i = 1, #q_targets do
            local target = q_targets[i]
            if (target and target.buffManager:HasBuff(0xdd330ca6)) then
                return self:ComboQ(target)
            end
        end

        -- catch case
        if (q_targets[1]) then
            self:ComboQ(q_targets[1])
        end
    end
end

function Ezreal:OnDraw()
    if (SDK.Utility:CanCastSpell(SpellSlot.Q)) then
        DrawHandler:Circle3D(myHero.position, self.q.range, SDK.Utility.Color.White)
    end

    if (SDK.Utility:CanCastSpell(SpellSlot.W)) then
        DrawHandler:Circle3D(myHero.position, self.w.range, SDK.Utility.Color.Red)
    end
end

function Ezreal:OnBuffGain(source, buff)
    -- print(buff.name)
end

function Ezreal:OnUnKillable(minion)
    if minion then
        -- check minion range
        local rangeCheck = SDK.Utility:IsValidTarget(minion, self.q.range)
        -- check minion health
        local healthCheck = self:GetQDamage(minion) >= minion.health
    end
end

return Ezreal
