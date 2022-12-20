local Ashe = {
    q = {},
    w = {
        type = "cone",
        delay = 0.25,
        range = 1200,
        width = 50,
        speed = 902,
        baseDamage = {20, 35, 50, 65, 80},
        collision = {
            ["Wall"] = true
        }
    },
    wmissile = {
        type = "linear",
        speed = 1500,
        range = 1200,
        delay = 0.25,
        width = 60
    },
    e = {
        dragon = _G.D3DXVECTOR3(9824, -71.240600585938, 4428),
        baron = _G.D3DXVECTOR3(4964, -71.240600585938, 10422)
    },
    r = {
        type = "linear",
        delay = 0.25,
        range = math.huge,
        width = 260,
        speed = 1600,
        baseDamage = {200, 400, 600},
        collision = {
            ["Wall"] = true,
            ["Hero"] = true
        }
    },
    AAs = {}
}

-------------------------------------------------------------------------------------------------------------------------------------
--                                                         Initialization                                                          --
-------------------------------------------------------------------------------------------------------------------------------------
function Ashe:__init()
    -- GENERATE MENU
    SDK.MenuManager.Menu:sub("combo", "[=] Combo")
    SDK.MenuManager.Menu.combo:label("sep2", "R Settings", true, true)
    SDK.MenuManager.Menu.combo:key("semir", "Semi-Auto R", string.byte("T"))
    SDK.MenuManager.Menu.combo:sub("rts", "R Target Selector")
    self.r.ts =
        SDK.DreamTS(
        SDK.MenuManager.Menu.combo.rts,
        {
            Damage = function(unit)
                return SDK.DamageLib:CalculatePhysicalDamage(myHero, unit, 100)
            end,
            ValidTarget = function(unit)
                return _G.Prediction.IsValidTarget(unit)
            end
        }
    )
    SDK.MenuManager.Menu.combo:slider("maxr", "Max R Range", 1000, 10000, 2500, 500)
    SDK.MenuManager:CreateBoolWhiteList(SDK.MenuManager.Menu.combo, "R", true)
    SDK.MenuManager.Menu.combo:label("sep0", "Q Settings", true, true)
    SDK.MenuManager.Menu.combo:checkbox("q", "Use Q", true)
    SDK.MenuManager.Menu.combo:label("sep1", "W Settings", true, true)
    SDK.MenuManager.Menu.combo:checkbox("w", "Use W", true)
    SDK.MenuManager.Menu.combo:checkbox("waa", "Don't use W in AA range", true)
    SDK.MenuManager.Menu.combo:checkbox("wlt", "Don't use W when LT is active", true)

    SDK.MenuManager.Menu:sub("harass", "[=] Harass")
    SDK.MenuManager.Menu.harass:slider("w", "Use W [Min. Mana %]", 1, 100, 60, 5, true)

    SDK.MenuManager.Menu:sub("ks", "[=] KS")
    SDK.MenuManager.Menu.ks:checkbox("w", "Use W", true)
    SDK.MenuManager.Menu.ks:checkbox("r", "Use R", true)

    -- Gapcloser Menu
    SDK.MenuManager.Menu:sub("gap", "[=] Anti-Gapcloser")
    SDK.MenuManager.Menu.gap:checkbox("r", "Use R", true)
    SDK.MenuManager:CreateBoolWhiteList(SDK.MenuManager.Menu.gap, "R", true)

    -- Misc Menu
    SDK.MenuManager.Menu:sub("chain", "[=] CC Chain")
    SDK.MenuManager.Menu.chain:label("sep0", "Will use R to chain CC", true, true)
    SDK.MenuManager.Menu.chain:checkbox("r", "Use R", false)
    SDK.MenuManager:CreateBoolWhiteList(SDK.MenuManager.Menu.chain, "R", false)

    SDK.MenuManager.Menu:sub("misc", "[=] Misc")
    SDK.MenuManager.Menu.misc:label("sep0", "E Settings", true, true)
    SDK.MenuManager.Menu.misc:key("drage", "Cast E At Dragon", string.byte("G"))
    SDK.MenuManager.Menu.misc:key("barone", "Cast E At Baron/Herald", string.byte("H"))

    SDK.MenuManager.Menu:sub("draw", "[=] Drawings")
    SDK.MenuManager.Menu.draw:sub("range", "[=] Ranges")
    SDK.MenuManager.Menu.draw.range:checkbox("w", "Draw W Range", true)
    SDK.MenuManager.Menu.draw.range:checkbox("r", "Draw R Range", true)
    SDK.MenuManager.Menu.draw:sub("damage", "[=] Damage")
    SDK.MenuManager.Menu.draw.damage:checkbox("damage", "Draw Damage", true)
    SDK.MenuManager.Menu.draw.damage:checkbox("w", "Draw W Damage", true)
    SDK.MenuManager.Menu.draw.damage:checkbox("r", "Draw R Damage", true)
    SDK.MenuManager.Menu.draw.damage:slider("aa", "Include X Autos", 1, 10, 4, 1, true)

    -- SUBSCRIBE TO EVENTS
    AddEvent(
        Events.OnTick,
        function()
            self:OnTick()
        end
    )
    AddEvent(
        Events.OnDraw,
        function()
            self:OnDraw()
        end
    )
    AddEvent(
        Events.OnBuffGain,
        function(...)
            self:OnBuffGain(...)
        end
    )
    AddEvent(
        Events.OnProcessSpell,
        function(...)
            self:OnProcessSpell(...)
        end
    )
    -- SDK.UOL:AddCallback("OnAfterAttack", function(...) self:OnAfterAttack(...) end)
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
    SDK:Log("Loaded Ashe")
end

-------------------------------------------------------------------------------------------------------------------------------------
--                                                             Spells                                                              --
-------------------------------------------------------------------------------------------------------------------------------------
function Ashe:CastQ()
    myHero.spellbook:CastSpell(SpellSlot.Q, myHero.networkId)
end

function Ashe:CastW(target)
    if (not SDK.Utility:IsValidTarget(target, self.w.range)) then
        return
    end

    local pred = _G.Prediction.GetPrediction(target, self.w, myHero)
    if (pred and pred.castPosition and SDK.Utility:HeroVPos():dist(SDK.Vector(pred.castPosition)) < self.w.range) then
        if (not pred:minionCollision()) then
            myHero.spellbook:CastSpell(SpellSlot.W, pred.castPosition)
            return
        end
        local points = {}

        local max_angle = math.pi / 180 * 40

        local point = SDK.Utility:HeroVPos()
        local direction = (SDK.Vector(pred.castPosition) - point):normalized()
        for angle = -max_angle / 2, max_angle / 2, max_angle / self:GetArrowCount() do
            points[#points + 1] = point + direction:RotatedRad(angle) * self.w.range
        end

        for _, pt in pairs(points) do
            if (not _G.Prediction.IsCollision(self.wmissile, SDK.Utility:HeroVPos(), pt, target)) then
                myHero.spellbook:CastSpell(SpellSlot.W, pred.castPosition)
                return
            end
        end
    end
end

function Ashe:CastR(target, rate)
    rate = rate or "slow"
    if (not SDK.Utility:IsValidTarget(target, SDK.MenuManager.Menu.combo.maxr.value)) then
        return
    end

    local pred = _G.Prediction.GetPrediction(target, self.r, myHero)
    if
        (pred and pred.castPosition and pred.rates[rate] and
            SDK.Utility:HeroVPos():dist(SDK.Vector(pred.castPosition)) < SDK.MenuManager.Menu.combo.maxr.value)
     then
        myHero.spellbook:CastSpell(SpellSlot.R, pred.castPosition)
    end
end

function Ashe:CastE()
    if (not SDK.Utility:CanCastSpell(SpellSlot.E)) then
        return
    end

    if (SDK.MenuManager.Menu.misc.drage:get()) then
        myHero.spellbook:CastSpell(SpellSlot.E, self.e.dragon)
    end

    if (SDK.MenuManager.Menu.misc.barone:get()) then
        myHero.spellbook:CastSpell(SpellSlot.E, self.e.baron)
    end
end

function Ashe:SemiCastR()
    if (SDK.MenuManager.Menu.combo.semir:get() and SDK.Utility:CanCastSpell(SpellSlot.R)) then
        local forcedTarget = SDK.UOL:GetForcedTarget()
        if (forcedTarget and SDK.Utility:IsValidTarget(forcedTarget, SDK.MenuManager.Menu.combo.maxr.value)) then
            self:CastR(forcedTarget)
            return
        end
        local targets, preds =
            self.r.ts:GetTargets(
            self.r,
            myHero,
            function(unit)
                return SDK.Utility:IsValidTarget(unit, SDK.MenuManager.Menu.combo.maxr.value)
            end
        )
        local target = targets[1]
        if (target) then
            local pred = preds[target.networkId]

            if (pred) then
                self:CastR(target)
            end
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------
--                                                           Definitions                                                           --
-------------------------------------------------------------------------------------------------------------------------------------
function Ashe:GetArrowCount()
    return SDK.Utility:GetSpellLevel(SpellSlot.W) + 6
end

-------------------------------------------------------------------------------------------------------------------------------------
--                                                             Damage                                                              --
-------------------------------------------------------------------------------------------------------------------------------------
function Ashe:GetWDamage(unit)
    local wLevel = SDK.Utility:GetSpellLevel(SpellSlot.W)
    if (wLevel == 0) then
        return 0
    end

    local wBaseDamage = self.w.baseDamage[wLevel] + SDK.Utility:GetTotalAD()

    wBaseDamage = wBaseDamage * SDK.Utility:GetPTADamage(unit)

    return SDK.DamageLib:CalculatePhysicalDamage(myHero, unit, wBaseDamage)
end

function Ashe:GetRDamage(unit)
    local rLevel = SDK.Utility:GetSpellLevel(SpellSlot.R)
    if (rLevel == 0) then
        return 0
    end

    local rBaseDamage = self.r.baseDamage[rLevel] + SDK.Utility:GetTotalAP()

    rBaseDamage = rBaseDamage * SDK.Utility:GetPTADamage(unit)

    return SDK.DamageLib:CalculatePhysicalDamage(myHero, unit, rBaseDamage)
end

-------------------------------------------------------------------------------------------------------------------------------------
--                                                           Combo Logic                                                           --
-------------------------------------------------------------------------------------------------------------------------------------
function Ashe:ComboW(target)
    if (SDK.Utility:HasLT() and SDK.MenuManager.Menu.combo.wlt:get()) then
        return
    end

    if (SDK.MenuManager.Menu.combo.waa:get() and SDK.Utility:IsValidTarget(target, SDK.Utility:GetRange())) then
        return
    end

    self:CastW(target)
end

-------------------------------------------------------------------------------------------------------------------------------------
--                                                        Subscribed Events                                                        --
-------------------------------------------------------------------------------------------------------------------------------------
function Ashe:OnAfterAttack(target)
    if not SDK.UOL then
        return
    end

    if (not target or target.type ~= GameObjectType.AIHeroClient) then
        return
    end

    if (not SDK.Utility:IsValidTarget(target, SDK.Utility:GetRange())) then
        return
    end

    if (SDK.DamageLib:GetAutoAttackDamage(myHero, target) > target.health) then
        return
    end

    local orbMode = SDK.UOL:GetMode()

    if (orbMode == "Combo") then
        if (SDK.MenuManager.Menu.combo.q:get() and SDK.Utility:CanCastSpell(SpellSlot.Q)) then
            self:CastQ()
        end

        if (SDK.MenuManager.Menu.combo.w:get() and SDK.Utility:CanCastSpell(SpellSlot.W)) then
            self:ComboW(target)
        end
    end
end

function Ashe:OnProcessSpell(source, spellInfo)
end

function Ashe:OnTick()
    if not SDK.UOL then
        return
    end

    if (myHero.isDead or myHero.isRecalling) then
        return
    end

    self:CastE()
    self:SemiCastR()

    -- killsteal
    for _, enemy in pairs(ObjectManager:GetEnemyHeroes()) do
        if (SDK.Utility:IsValidTarget(enemy, self.w.range) and SDK.MenuManager.Menu.ks.w:get()) then
            if (enemy.health <= self:GetWDamage(enemy) and SDK.Utility:CanCastSpell(SpellSlot.W)) then
                self:CastW(enemy)
            end
        end
        if (SDK.Utility:IsValidTarget(enemy, self.r.range) and SDK.MenuManager.Menu.ks.r:get()) then
            if (enemy.health <= self:GetRDamage(enemy) and SDK.Utility:CanCastSpell(SpellSlot.R)) then
                self:CastR(enemy)
            end
        end
    end

    -- antigapcloser
    local rTargets, rPreds =
        SDK.MenuManager.TS:GetTargets(
        self.r,
        myHero,
        function(unit)
            return SDK.Utility:IsValidTarget(unit, SDK.MenuManager.Menu.combo.maxr.value)
        end
    )
    for _, target in pairs(rTargets) do
        local pred = rPreds[target.networkId]
        if (pred and pred.targetDashing) then
            local useR = SDK.MenuManager.Menu.gap.r:get()
            local shouldREnemy = SDK.MenuManager.Menu.gap.rwhitelist[target.charName]:get()
            if
                (useR and shouldREnemy and
                    SDK.Utility:HeroVPos():dist(SDK.Vector(pred.castPosition)) < SDK.MenuManager.Menu.combo.maxr.value and
                    SDK.Utility:CanCastSpell(SpellSlot.R))
             then
                myHero.spellbook:CastSpell(SpellSlot.R, pred.castPosition)
            end
        end
    end

    if
        ((SDK.UOL:GetMode() == "Combo" and SDK.MenuManager.Menu.combo.w:get()) or
            (SDK.UOL:GetMode() == "Harass" and SDK.MenuManager.Menu.harass.w:get() and
                SDK.MenuManager.Menu.harass.w.value < myHero.manaPercent))
     then
        if (SDK.Utility:CanCastSpell(SpellSlot.W)) then
            local targets, _ =
                SDK.MenuManager.TS:GetTargets(
                self.w,
                myHero,
                function(unit)
                    return _G.Prediction.IsValidTarget(unit, self.w.range, myHero)
                end
            )
            local target = targets[1]
            if (target and SDK.Utility:IsValidTarget(target, self.w.range) and not SDK.UOL:IsAttacking()) then
                self:ComboW(target)
            end
        end
    end
end

function Ashe:OnBuffGain(source, buff)
    if (not source) then
        return
    end

    if (source.type ~= GameObjectType.AIHeroClient) then
        return
    end

    if (source.team == myHero.team) then
        return
    end

    if (not SDK.MenuManager.Menu.chain.r:get()) then
        return
    end

    if (not SDK.MenuManager.Menu.chain.rwhitelist[source.charName]:get()) then
        return
    end

    if (not SDK.Utility:CanCastSpell(SpellSlot.R)) then
        return
    end

    if
        (buff.type ~= BuffType.Stun and buff.type ~= BuffType.Taunt and buff.type ~= BuffType.Snare and
            buff.type ~= BuffType.Charm and
            buff.type ~= BuffType.Suppression and
            buff.type ~= BuffType.Knockup)
     then
        return
    end

    if (not SDK.Utility:IsValidTarget(source, SDK.MenuManager.Menu.combo.maxr.value)) then
        return
    end

    self:CastR(source)
end

function Ashe:OnCreateObject(object, nId)
    if
        object and object.name:find("AsheBasicAttack") and object.asMissile.spellCaster.networkId == myHero.networkId and
            object.asMissile.target and
            object.asMissile.target.type == GameObjectType.AIHeroClient
     then
        self.AAs[object.networkId] = object.asMissile.target
    end
end

function Ashe:OnDeleteObject(object)
    if (SDK.UOL:GetMode() == "Combo") then
        local target = self.AAs[object.networkId]

        if (target and target.type == GameObjectType.AIHeroClient) then
            if (SDK.Utility:IsValidTarget(target, SDK.Utility:GetRange())) then
                if (SDK.DamageLib:GetAutoAttackDamage(myHero, target) < target.health) then
                    self:CastQ()
                end
            end
        end
    end
end

function Ashe:OnDraw()
    if (SDK.MenuManager.Menu.draw.range.w:get() and SDK.Utility:CanCastSpell(SpellSlot.W)) then
        DrawHandler:Circle3D(myHero.position, self.w.range, SDK.Utility.Color.Green)
    end

    if (SDK.MenuManager.Menu.draw.range.r:get() and SDK.Utility:CanCastSpell(SpellSlot.R)) then
        DrawHandler:Circle3D(myHero.position, SDK.MenuManager.Menu.combo.maxr.value, SDK.Utility.Color.Red)
    end

    for _, enemy in pairs(ObjectManager:GetEnemyHeroes()) do
        if (not SDK.MenuManager.Menu.draw.damage.damage:get()) then
            return
        end
        local damage = 0
        if (SDK.MenuManager.Menu.draw.damage.w:get() and SDK.Utility:CanCastSpell(SpellSlot.W)) then
            damage = damage + self:GetWDamage(enemy)
        end
        if (SDK.MenuManager.Menu.draw.damage.r:get() and SDK.Utility:CanCastSpell(SpellSlot.R)) then
            damage = damage + self:GetRDamage(enemy)
        end
        if (SDK.MenuManager.Menu.draw.damage.aa:get()) then
            damage =
                damage + (SDK.DamageLib:GetAutoAttackDamage(myHero, enemy) * SDK.MenuManager.Menu.draw.damage.aa.value)
        end
        if (enemy and SDK.Utility:IsValidTarget(enemy, 2000)) then
            SDK.Utility:DrawDamage(enemy, damage)
        end
    end
end

return Ashe
