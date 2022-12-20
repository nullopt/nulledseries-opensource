local KogMaw = {
    lulu = {},
    q = {
        type = "linear",
        speed = 1650,
        range = 1130,
        delay = 0.25,
        width = 140,
        baseDamage = {90, 140, 190, 240, 290}
    },
    w = setmetatable({
        baseDamage = {3, 3.75, 4.5, 5.25, 6}
    }, {
        __index = function(self, key)
            if key == "range" then
                return (110 + (20 * SDK.Utility:GetSpellLevel(SpellSlot.W))) + SDK.Utility:GetRange()
            end
        end
    }),
    e = {
        type = "linear",
        speed = 1350,
        range = 1200,
        delay = 0.25, -- 0.25?
        width = 235,
        baseDamage = {75, 120, 165, 210, 255}
    },
    r = setmetatable({
        type = "circular",
        speed = math.huge,
        delay = 1.25,
        radius = 240,
        baseDamage = {100, 140, 180},
        predMode = {"none", "instant", "slow", "veryslow"}
    }, {
        __index = function(self, key)
            if key == "range" then
                local r = (1050 + (250 * SDK.Utility:GetSpellLevel(SpellSlot.R)))
                return r
            end
        end
    })
}

-------------------------------------------------------------------------------------------------------------------------------------
--                                                         Initialization                                                          --
-------------------------------------------------------------------------------------------------------------------------------------
function KogMaw:__init()
    -- GENERATE MENU
    -- Combo Menu
    SDK.MenuManager.Menu:sub("combo", "[=] Combo")
    SDK.MenuManager.Menu.combo:label("sep0", "Q Settings", true, true)
    SDK.MenuManager.Menu.combo:checkbox("q", "Use Q", true)
    SDK.MenuManager.Menu.combo:checkbox("qaa", "Only Q if target is in AA range", true)
    SDK.MenuManager.Menu.combo:checkbox("qw", "Don't use when W active", true)
    SDK.MenuManager.Menu.combo:label("sep1", "W Settings", true, true)
    SDK.MenuManager.Menu.combo:checkbox("w", "Use W", true)
    SDK.MenuManager.Menu.combo:label("sep2", "E Settings", true, true)
    SDK.MenuManager.Menu.combo:checkbox("e", "Use E", false)
    SDK.MenuManager.Menu.combo:checkbox("ew", "Don't use when W active", true)
    SDK.MenuManager.Menu.combo:key("semie", "Semi Auto E", string.byte("G"))
    SDK.MenuManager.Menu.combo:list("emode", "Semi Auto E - Mode", 1, {"Mode Damage", "Closest"})
    SDK.MenuManager.Menu.combo:label("sep3", "R Settings", true, true)
    SDK.MenuManager.Menu.combo:checkbox("r", "Use R", true)
    SDK.MenuManager.Menu.combo:checkbox("rrange", "Only outside AA range", true)
    SDK.MenuManager.Menu.combo:slider("rhps", "Only if target.hp <= X%", 0, 100, 30, 5, true)
    SDK.MenuManager.Menu.combo:list("rpred", "Pred Mode", 2, self.r.predMode)
    SDK.MenuManager.Menu.combo:key("semir", "Semi Auto R [Most Damage]", string.byte("T"))
    SDK.MenuManager.Menu.combo:slider("rstacks", "Max Stacks", 1, 9, 3, 1, true)

    local lulu = SDK.EntityManager:GetAlly("Lulu")
    if (lulu) then
        self.lulu = lulu

        -- Scripter Menu
        SDK.MenuManager.Menu:sub("scripter", "[=] Duo Scripter")
        SDK.MenuManager.Menu.scripter:checkbox("lulu", "Only W if Lulu's W/E is ready", false)
        SDK.MenuManager.Menu.scripter:label("sep", "If you can think of anymore Duo Scripter stuff, let me know")
    end

    -- Harass Menu
    SDK.MenuManager.Menu:sub("harass", "[=] Harass")
    SDK.MenuManager.Menu.harass:slider("q", "Use Q | Mana >= x%", 0, 100, 60, 1, false)
    SDK.MenuManager.Menu.harass:checkbox("qwaveclear", "Harass with Q in Waveclear", true)
    SDK.MenuManager.Menu.harass:slider("w", "Use W | Mana >= x%", 0, 100, 60, 1, false)
    SDK.MenuManager.Menu.harass:slider("e", "Use E | Mana >= x%", 0, 100, 60, 1, false)
    SDK.MenuManager.Menu.harass:slider("r", "Use R | Mana >= x%", 0, 100, 60, 1, false)

    -- Killsteal Menu
    SDK.MenuManager.Menu:sub("ks", "[=] Killsteal")
    SDK.MenuManager.Menu.ks:checkbox("q", "Use Q", true)
    SDK.MenuManager.Menu.ks:checkbox("e", "Use E", true)
    SDK.MenuManager.Menu.ks:label("sep0", "R Settings", true, true)
    SDK.MenuManager.Menu.ks:checkbox("r", "Use R", true)
    SDK.MenuManager.Menu.ks:checkbox("rrange", "Only outside AA range", true)
    SDK.MenuManager.Menu.ks:checkbox("rstacks", "Stack Management", true)

    -- Draw Menu
    SDK.MenuManager.Menu:sub("draw", "[=] Drawings")
    SDK.MenuManager.Menu.draw:sub("range", "[=] Range")
    SDK.MenuManager.Menu.draw.range:checkbox("q", "Draw Q Range", true)
    SDK.MenuManager.Menu.draw.range:checkbox("w", "Draw W Range", true)
    SDK.MenuManager.Menu.draw.range:checkbox("e", "Draw E Range", true)
    SDK.MenuManager.Menu.draw.range:checkbox("r", "Draw R Range", true)
    SDK.MenuManager.Menu.draw:sub("damage", "[=] Damage")
    SDK.MenuManager.Menu.draw.damage:checkbox("damage", "Draw Damage", true)
    SDK.MenuManager.Menu.draw.damage:label("sep0", "Q Damage", true, true)
    SDK.MenuManager.Menu.draw.damage:checkbox("q", "Include Q", false)
    SDK.MenuManager.Menu.draw.damage:label("sep1", "E Damage", true, true)
    SDK.MenuManager.Menu.draw.damage:checkbox("e", "Include E", true)
    SDK.MenuManager.Menu.draw.damage:label("sep2", "R Damage", true, true)
    SDK.MenuManager.Menu.draw.damage:checkbox("r", "Include R", true)
    SDK.MenuManager.Menu.draw.damage:label("sep3", "Auto Attack Damage", true, true)
    SDK.MenuManager.Menu.draw.damage:slider("aa", "Include X Autos", 1, 10, 4, 1, false)

    -- SUBSCRIBE TO EVENTS
    AddEvent(Events.OnTick, function()
        self:OnTick()
    end)
    AddEvent(Events.OnDraw, function()
        self:OnDraw()
    end)
    AddEvent(Events.OnExecuteCastFrame, function(...)
        self:OnExecuteCastFrame(...)
    end)
    SDK:Log("Loaded KogMaw - " .. GetUser())
end

-------------------------------------------------------------------------------------------------------------------------------------
--                                                             Spells                                                              --
-------------------------------------------------------------------------------------------------------------------------------------
function KogMaw:CastQ(target)
    local pred = _G.Prediction.GetPrediction(target, self.q, myHero)
    if (pred and pred.castPosition and SDK.Utility:HeroVPos():dist(SDK.Vector(pred.castPosition)) < self.q.range) then
        local dynamicRange = SDK.Utility:DynamicRange(pred, target, self.q)
        if dynamicRange and not pred:windWallCollision() and not pred:minionCollision() then
            myHero.spellbook:CastSpell(SpellSlot.Q, pred.castPosition)
        end
    end
end

function KogMaw:CastW()
    myHero.spellbook:CastSpell(SpellSlot.W, myHero.networkId)
end

function KogMaw:CastE(target, rate)
    rate = rate or "slow"
    local pred = _G.Prediction.GetPrediction(target, self.e, myHero)
    if (pred and pred.castPosition and pred.rates[rate] and SDK.Utility:HeroVPos():dist(SDK.Vector(pred.castPosition)) <
        self.e.range) then
        local dynamicRange = SDK.Utility:DynamicRange(pred, target, self.e)
        if dynamicRange and not pred:windWallCollision() then
            myHero.spellbook:CastSpell(SpellSlot.E, pred.castPosition)
        end
    end
end

function KogMaw:GetCastRate()
    return self.r.predMode[SDK.MenuManager.Menu.combo.rpred.value]
end

function KogMaw:CastR(target)
    local pred = _G.Prediction.GetPrediction(target, self.r, myHero)
    if (pred and pred.castPosition and SDK.Utility:HeroVPos():dist(SDK.Vector(pred.castPosition)) < self.r.range) then
        if (self:GetCastRate() == "none") then
            myHero.spellbook:CastSpell(SpellSlot.R, pred.castPosition)
        else
            if (pred.rates[self:GetCastRate()]) then
                myHero.spellbook:CastSpell(SpellSlot.R, pred.castPosition)
            end
        end
    end
end

function KogMaw:SemiCastEDamage()
    local target = nil
    local damage = 0

    for _, enemy in pairs(ObjectManager:GetEnemyHeroes()) do
        if SDK.Utility:IsValidTarget(enemy, self.e.range) then
            local d = self:GetEDamage(enemy)
            if (d >= enemy.health) then
                if SDK.Utility:IsValidTarget(enemy, self.e.range) then
                    self:CastE(enemy)
                end
                return
            end
            if d > damage then
                damage = d
                target = enemy
            end
        end
    end
    if SDK.Utility:IsValidTarget(target, self.e.range) then
        self:CastE(target)
    end
end

function KogMaw:SemiCastEClosest()
    local closest = SDK.EntityManager:GetClosestEnemy(myHero, self.e.range)

    if SDK.Utility:IsValidTarget(closest, self.e.range) then
        self:CastE(closest)
    end
end

function KogMaw:SemiCastE()
    if not SDK.Utility:CanCastSpell(SpellSlot.E) then
        return
    end
    if not SDK.MenuManager.Menu.combo.semie:get() then
        return
    end

    if SDK.MenuManager.Menu.combo.emode.value == 1 then
        self:SemiCastEDamage()
    else
        self:SemiCastEClosest()
    end
end

function KogMaw:SemiCastR()
    if (SDK.MenuManager.Menu.combo.semir:get() and SDK.Utility:CanCastSpell(SpellSlot.R)) then
        local target = nil
        local damage = 0

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

-------------------------------------------------------------------------------------------------------------------------------------
--                                                           Definitions                                                           --
-------------------------------------------------------------------------------------------------------------------------------------
function KogMaw:HasLTActive()
    return SDK.Utility:HasLT(myHero)
end

function KogMaw:HasWActive()
    return myHero.buffManager:HasBuff(0xf12c3953)
end

function KogMaw:GetRStacks()
    return SDK.Utility:GetBuffStacks(myHero, 0xb32e2a55)
end

function KogMaw:WaitForLulu()
    if (not self.lulu) then
        return false
    end

    if (not SDK.MenuManager.Menu.scripter.lulu) then
        return false
    end

    if (not SDK.MenuManager.Menu.scripter.lulu:get()) then
        return false
    end

    if (not SDK.Utility:IsValidTarget(self.lulu, 650)) then
        return false
    end

    return self.lulu.spellbook:CanUseSpell(SpellSlot.W) == 0 or self.lulu.spellbook:CanUseSpell(SpellSlot.E) == 0
end

-------------------------------------------------------------------------------------------------------------------------------------
--                                                             Damage                                                              --
-------------------------------------------------------------------------------------------------------------------------------------
function KogMaw:GetQDamage(unit)
    local qLevel = SDK.Utility:GetSpellLevel(SpellSlot.Q)
    if (qLevel == 0) then
        return 0
    end
    local qBaseDamage = self.q.baseDamage[qLevel] + 0.7 * SDK.Utility:GetTotalAP()

    return SDK.DamageLib:CalculateMagicDamage(myHero, unit, qBaseDamage)
end

function KogMaw:GetWDamage(unit)
    local wLevel = SDK.Utility:GetSpellLevel(SpellSlot.W)
    if (wLevel == 0) then
        return 0
    end

    local wBaseDamage = self.w.baseDamage[wLevel] + math.fmod(SDK.Utility:GetTotalAP(), 100)

    local percentOfHp = wBaseDamage / 100 * unit.maxHealth

    if (unit.type == GameObjectType.obj_AI_Minion) then
        percentOfHp = math.min(100, percentOfHp)
    end

    local aaDamage = SDK.DamageLib:GetAutoAttackDamage(myHero, unit)

    return aaDamage + SDK.DamageLib:CalculateMagicDamage(myHero, unit, percentOfHp)
end

function KogMaw:GetEDamage(unit)
    local eLevel = SDK.Utility:GetSpellLevel(SpellSlot.E)
    if (eLevel == 0) then
        return 0
    end

    local eBaseDamage = self.e.baseDamage[eLevel] + 0.5 * SDK.Utility:GetTotalAP()

    return SDK.DamageLib:CalculateMagicDamage(myHero, unit, eBaseDamage)
end

function KogMaw:GetRDamage(unit)
    local rLevel = SDK.Utility:GetSpellLevel(SpellSlot.R)
    if (rLevel == 0) then
        return 0
    end

    local rBaseDamage = self.r.baseDamage[rLevel] + 0.65 * SDK.Utility:GetBonusAD() + 0.35 * SDK.Utility:GetTotalAP()

    if (unit.healthPercent < 40) then
        rBaseDamage = rBaseDamage * 2
    else
        rBaseDamage = rBaseDamage * (1 + 0.833 * SDK.Utility:MissingHPPercent())
    end

    return SDK.DamageLib:CalculateMagicDamage(myHero, unit, rBaseDamage)
end

-------------------------------------------------------------------------------------------------------------------------------------
--                                                           Combo Logic                                                           --
-------------------------------------------------------------------------------------------------------------------------------------
function KogMaw:ComboQ(target)
    if (not SDK.MenuManager.Menu.combo.q:get()) then
        return
    end

    if (not SDK.Utility:CanCastSpell(SpellSlot.Q)) then
        return
    end

    if (SDK.Utility:HeroVPos():dist(SDK.Vector(target.position)) > SDK.Utility:GetRange() and
        SDK.MenuManager.Menu.combo.qaa:get()) then
        return
    end

    if (SDK.MenuManager.Menu.combo.qw:get() and self:HasWActive()) then
        return
    end

    if (not target) then
        return
    end

    if (not SDK.Utility:IsValidTarget(target, self.q.range)) then
        return
    end

    self:CastQ(target)
end

function KogMaw:ComboW(target)
    if (not SDK.MenuManager.Menu.combo.w:get()) then
        return
    end

    if (not SDK.Utility:CanCastSpell(SpellSlot.W)) then
        return
    end

    if (not target) then
        return
    end

    -- if (self:WaitForLulu()) then
    --   return
    -- end

    if (not SDK.Utility:IsValidTarget(target, self.w.range)) then
        return
    end

    if not myHero.isWindingUp then
        self:CastW()
    end

end

function KogMaw:ComboE(target)
    if (not SDK.MenuManager.Menu.combo.e:get()) then
        return
    end

    if (not SDK.Utility:CanCastSpell(SpellSlot.E)) then
        return
    end

    if (SDK.MenuManager.Menu.combo.ew:get() and self:HasWActive()) then
        return
    end

    if (not target) then
        return
    end

    if (not SDK.Utility:IsValidTarget(target, self.e.range)) then
        return
    end

    self:CastE(target)
end

function KogMaw:ComboR(target)
    if (not SDK.MenuManager.Menu.combo.r:get()) then
        return
    end

    if (not SDK.Utility:CanCastSpell(SpellSlot.R)) then
        return
    end

    if (self:GetRStacks() > SDK.MenuManager.Menu.combo.rstacks.value and SDK.MenuManager.Menu.combo.rstacks:get()) then
        return
    end

    if (not target) then
        return
    end

    if (not SDK.Utility:IsValidTarget(target, self.r.range)) then
        return
    end

    if (SDK.MenuManager.Menu.combo.rhps:get() and target.healthPercent > SDK.MenuManager.Menu.combo.rhps.value) then
        return
    end

    if (SDK.MenuManager.Menu.combo.rrange:get() and
        SDK.Utility:IsValidTarget(target, SDK.Utility:GetRange() + target.boundingRadius)) then
        return
    end

    self:CastR(target)
end

-------------------------------------------------------------------------------------------------------------------------------------
--                                                          Harass Logic                                                           --
-------------------------------------------------------------------------------------------------------------------------------------
function KogMaw:HarassQ(target)
    if (not SDK.Utility:CanCastSpell(SpellSlot.Q)) then
        return
    end

    if (not SDK.MenuManager.Menu.harass.q:get() or myHero.manaPercent < SDK.MenuManager.Menu.harass.q.value) then
        return
    end

    if (not target) then
        return
    end

    if (not SDK.Utility:IsValidTarget(target, self.q.range)) then
        return
    end

    self:CastQ(target)
end

function KogMaw:HarassW(target)
    if (not SDK.Utility:CanCastSpell(SpellSlot.W)) then
        return
    end

    if (not SDK.MenuManager.Menu.harass.w:get() or myHero.manaPercent < SDK.MenuManager.Menu.harass.w.value) then
        return
    end

    if (not target) then
        return
    end

    if not SDK.UOL:CanAttack() then
        return
    end

    if (not SDK.Utility:IsValidTarget(target, self.w.range)) then
        return
    end

    self:CastW()
end

function KogMaw:HarassE(target)
    if (not SDK.Utility:CanCastSpell(SpellSlot.E)) then
        return
    end

    if (not SDK.MenuManager.Menu.harass.e:get() or myHero.manaPercent < SDK.MenuManager.Menu.harass.e.value) then
        return
    end

    if (not target) then
        return
    end

    if (not SDK.Utility:IsValidTarget(target, self.e.range)) then
        return
    end

    self:CastE(target)
end

function KogMaw:HarassR(target)
    if (not SDK.Utility:CanCastSpell(SpellSlot.R)) then
        return
    end

    if (not SDK.MenuManager.Menu.harass.r:get() or myHero.manaPercent < SDK.MenuManager.Menu.harass.r.value) then
        return
    end

    if (not target) then
        return
    end

    if (not SDK.Utility:IsValidTarget(target, self.r.range)) then
        return
    end

    self:CastR(target)
end

-------------------------------------------------------------------------------------------------------------------------------------
--                                                        Subscribed Events                                                        --
-------------------------------------------------------------------------------------------------------------------------------------
function KogMaw:OnBasicAttack(source, spellInfo)
end

function KogMaw:OnExecuteCastFrame(source, spellInfo)
    if (source.charName ~= myHero.charName) then
        return
    end

    local target = spellInfo.target
    if (target == nil or target.type ~= GameObjectType.AIHeroClient or
        not SDK.Utility:IsValidTarget(target, self.q.range)) then
        return
    end

    local spell = spellInfo.spellData
    if (not spell.name:find("Attack")) then
        return
    end

    -- switch orbwalker
    if (SDK.UOL:GetMode() == "Combo") then
        self:ComboQ(target)
        self:ComboE(target)
    end
end

function KogMaw:OnTick()
    if not SDK.UOL then
        return
    end

    KogMaw:SemiCastE()
    KogMaw:SemiCastR()

    -- killsteal
    for _, enemy in pairs(ObjectManager:GetEnemyHeroes()) do
        if (SDK.Utility:IsValidTarget(enemy, self.q.range) and SDK.MenuManager.Menu.ks.q:get()) then
            if (enemy.health <= self:GetQDamage(enemy) and SDK.Utility:CanCastSpell(SpellSlot.Q)) then
                self:CastQ(enemy)
            end
        end
        if (SDK.Utility:IsValidTarget(enemy, self.e.range) and SDK.MenuManager.Menu.ks.e:get()) then
            if (enemy.health <= self:GetEDamage(enemy) and SDK.Utility:CanCastSpell(SpellSlot.E)) then
                self:CastE(enemy)
            end
        end

        if (not SDK.MenuManager.Menu.ks.r:get()) then
            goto continue
        end

        if (enemy.health > self:GetRDamage(enemy) or not SDK.Utility:CanCastSpell(SpellSlot.R)) then
            goto continue
        end

        if (not SDK.Utility:IsValidTarget(enemy, self.r.range)) then
            goto continue
        end

        if (SDK.MenuManager.Menu.ks.rstacks:get() and self:GetRStacks() > SDK.MenuManager.Menu.combo.rstacks.value + 1) then
            goto continue
        end

        if (SDK.MenuManager.Menu.ks.rrange:get() and SDK.Utility:HeroVPos():dist(SDK.Vector(enemy.position)) <=
            SDK.Utility:GetRange(true)) then
            goto continue
        end

        self:CastR(enemy)

        ::continue::
    end

    -- switch orbwalker
    if (SDK.UOL:GetMode() == "Combo") then
        if (SDK.MenuManager.Menu.combo.r:get()) then
            local rTargets, _ = SDK.MenuManager.TS:GetTargets(self.r, myHero, function(unit)
                return _G.Prediction.IsValidTarget(unit, self.r.range, myHero)
            end)
            local rTarget = rTargets[1]
            if (rTarget and SDK.Utility:IsValidTarget(rTarget, self.r.range)) then
                self:ComboR(rTarget)
            end
        end

        if (SDK.MenuManager.Menu.combo.e:get()) then
            local eTargets, _ = SDK.MenuManager.TS:GetTargets(self.e, myHero, function(unit)
                return _G.Prediction.IsValidTarget(unit, self.e.range, myHero)
            end)
            local eTarget = eTargets[1]

            if (eTarget and SDK.Utility:IsValidTarget(eTarget, self.e.range)) then
                self:CastE(eTarget)
            end
        end

        local wTarget = SDK.EntityManager:GetClosestEnemy(myHero, self.w.range)

        if (wTarget and SDK.Utility:IsValidTarget(wTarget, self.w.range)) then
            self:ComboW(wTarget)
        end

        local qTargets, _ = SDK.MenuManager.TS:GetTargets(self.q, myHero, function(unit)
            return _G.Prediction.IsValidTarget(unit, self.q.range, myHero)
        end)
        local qTarget = qTargets[1]

        if (not qTarget) then
            return
        end
        if (not SDK.Utility:IsValidTarget(qTarget, self.q.range)) then
            return
        end

        if (SDK.Utility:HeroVPos():dist(SDK.Vector(qTarget.position)) < SDK.Utility:GetRange(true) and
            SDK.MenuManager.Menu.combo.qaa:get()) then
            return
        end
        self:ComboQ(qTarget)
    elseif (SDK.UOL:GetMode() == "Harass") then
        local rTargets, _ = SDK.MenuManager.TS:GetTargets(self.r, myHero, function(unit)
            return _G.Prediction.IsValidTarget(unit, self.r.range, myHero)
        end)

        local rTarget = rTargets[1]
        if (rTarget and SDK.Utility:IsValidTarget(rTarget, self.r.range)) then
            self:HarassR(rTarget)
        end

        local wTarget = SDK.EntityManager:GetClosestEnemy(myHero, self.w.range)

        if (wTarget and SDK.Utility:IsValidTarget(wTarget, self.w.range)) then
            self:HarassW(wTarget)
        end

        local qTargets, _ = SDK.MenuManager.TS:GetTargets(self.q, myHero, function(unit)
            return _G.Prediction.IsValidTarget(unit, self.q.range, myHero)
        end)
        local qTarget = qTargets[1]

        if (qTarget and SDK.Utility:IsValidTarget(qTarget, self.q.range)) then
            self:HarassQ(qTarget)
        end
        self:HarassE(qTarget)
    elseif SDK.UOL:GetMode() == "Waveclear" and SDK.MenuManager.Menu.harass.qwaveclear:get() then
        local qTargets, _ = SDK.MenuManager.TS:GetTargets(self.q, myHero, function(unit)
            return _G.Prediction.IsValidTarget(unit, self.q.range, myHero)
        end)
        local qTarget = qTargets[1]

        if (qTarget and SDK.Utility:IsValidTarget(qTarget, self.q.range)) then
            self:HarassQ(qTarget)
        end
    end
end

function KogMaw:OnDraw()
    if (SDK.MenuManager.Menu.draw.range.q:get() and SDK.Utility:CanCastSpell(SpellSlot.Q)) then
        DrawHandler:Circle3D(myHero.position, self.q.range, SDK.Utility.Color.Red)
    end

    if SDK.MenuManager.Menu.draw.range.w:get() then
        local range = SDK.Utility:CanCastSpell(SpellSlot.W) and self.w.range or SDK.Utility:GetRange()
        DrawHandler:Circle3D(myHero.position, range, SDK.Utility.Color.Green)
    end

    if (SDK.MenuManager.Menu.draw.range.e:get() and SDK.Utility:CanCastSpell(SpellSlot.E)) then
        DrawHandler:Circle3D(myHero.position, self.e.range, SDK.Utility.Color.Blue)
    end

    if (SDK.MenuManager.Menu.draw.range.r:get() and SDK.Utility:CanCastSpell(SpellSlot.R)) then
        DrawHandler:Circle3D(myHero.position, self.r.range, SDK.Utility.Color.Orange)
    end

    for _, enemy in pairs(SDK.EntityManager:GetEnemies(2000)) do
        if (not SDK.MenuManager.Menu.draw.damage.damage:get()) then
            return
        end

        local damage = 0
        if (SDK.MenuManager.Menu.draw.damage.q:get() and SDK.Utility:CanCastSpell(SpellSlot.Q)) then
            damage = damage + self:GetQDamage(enemy)
        end
        if (SDK.MenuManager.Menu.draw.damage.e:get() and SDK.Utility:CanCastSpell(SpellSlot.E)) then
            damage = damage + self:GetEDamage(enemy)
        end
        if (SDK.MenuManager.Menu.draw.damage.r:get() and SDK.Utility:CanCastSpell(SpellSlot.R)) then
            damage = damage + self:GetRDamage(enemy)
        end
        if (SDK.MenuManager.Menu.draw.damage.aa:get()) then
            damage = damage +
                         (SDK.DamageLib:GetAutoAttackDamage(myHero, enemy) * SDK.MenuManager.Menu.draw.damage.aa.value)
        end
        if (enemy) then
            SDK.Utility:DrawDamage(enemy, damage)
        end
    end
end

return KogMaw
