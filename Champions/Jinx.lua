local Jinx = {
    m = SDK.MenuManager.Menu,
    q = setmetatable(
        {},
        {
            __index = function(self, key)
                if key == "range" then
                    return 50 + (30 * SDK.Utility:GetSpellLevel(SpellSlot.Q)) + SDK.Utility:GetRange()
                end
            end
        }
    ),
    w = setmetatable(
        {
            type = "linear",
            range = 1450,
            width = 60,
            speed = 3300,
            collision = {
                ["Wall"] = true,
                ["Minion"] = true,
                ["Hero"] = true
            },
            baseDamage = {10, 60, 110, 150, 210}
        },
        {
            __index = function(self, key)
                if key == "delay" then
                    -- TODO: fix?
                    local bonus = (myHero.characterIntermediate.attackSpeedMod - 1) * 100
                    local count = bonus / 25
                    local final = math.max(0.4, 0.6 - (0.02 * count))
                    return final
                end
            end
        }
    ),
    e = {
        type = "circular",
        range = 920,
        delay = 1.2,
        radius = 100,
        speed = 1750
    },
    r = setmetatable(
        {
            type = "linear",
            delay = 0.6,
            width = 280,
            speed = 1700,
            collision = {
                ["Wall"] = true
            },
            baseDamage = {250, 350, 450},
            healthDamage = {0.2, 0.24, 0.28}
        },
        {
            __index = function(self, key)
                if key == "range" then
                    return SDK.MenuManager.Menu.r.maxr.value
                end
            end
        }
    ),
    QMANA = 0,
    WMANA = 0,
    EMANA = 0,
    RMANA = 0,
    QCastTime = 0,
    WCastTime = 0,
    lag = 0,
    DragonDmg = 0,
    DragonTime = 0,
    grabTime = 0,
    castModeOptions = {"instant", "slow", "very slow"},
    tickIndex = 0
}

function Jinx:__init()
    -- init menu
    SDK.MenuManager.Menu:sub("q", "Q Config")
    SDK.MenuManager.Menu.q:checkbox("autoq", "Auto Q", true)
    SDK.MenuManager.Menu.q:checkbox("qharass", "Harass Q", true)

    SDK.MenuManager.Menu:sub("w", "W Config")
    SDK.MenuManager.Menu.w:checkbox("autow", "Auto W", true)
    SDK.MenuManager.Menu.w:list("pred", "Pred Rate", 2, self.castModeOptions)
    SDK.MenuManager.Menu.w:sub("safety", "Safety Checks")
    SDK.MenuManager.Menu.w.safety:checkbox("aarange", "Only Outside AA Range", true)
    SDK.MenuManager.Menu.w.safety:checkbox("enemiesnear", "Don't Cast If Enemies Near You", true)
    -- TODO:
    -- m.w:sub("harass", "Harass")
    -- SDK.MenuManager:CreateBoolWhiteList(m.w.harass, "W")

    SDK.MenuManager.Menu:sub("e", "E Config")
    SDK.MenuManager.Menu.e:checkbox("autoe", "Auto E on CC", true)
    SDK.MenuManager.Menu.e:checkbox("comboe", "Auto E in Combo BETA", true)
    SDK.MenuManager.Menu.e:checkbox("antimelee", "Anti Melee BETA", false)
    SDK.MenuManager.Menu.e:checkbox("gap", "Anti Gapcloser E", true)
    SDK.MenuManager.Menu.e:checkbox("opse", "OnProcessSpellCast E", true)
    -- TODO:
    -- m.e:checkbox("tele", "Auto E Teleport", true)

    SDK.MenuManager.Menu:sub("r", "R Config")
    SDK.MenuManager.Menu.r:checkbox("autor", "Auto R", true)
    SDK.MenuManager.Menu.r:slider("maxr", "Max Range", 1000, 5000, 3000, 100)
    SDK.MenuManager.Menu.r:list("rate", "Hit Chance R", 2, self.castModeOptions)
    SDK.MenuManager.Menu.r:key("user", "OneKeyToCast R", string.byte("T"))
    SDK.MenuManager.Menu.r:sub("safety", "Safety Checks")
    SDK.MenuManager.Menu.r.safety:checkbox("rturret", "Don't Cast Under Turret", true)
    SDK.MenuManager.Menu.r.safety:checkbox("aarange", "Only Outside AA Range", true)
    SDK.MenuManager.Menu.r.safety:checkbox("alliesnear", "Don't Cast If Allies Near Target", true)
    SDK.MenuManager.Menu.r.safety:checkbox("enemiesnear", "Don't Cast If Enemies Near You", true)
    -- TODO:
    -- SDK.MenuManager.Menu.r:sub("jungle", "R Jungle Stealer")
    -- SDK.MenuManager.Menu.r.jungle:checkbox("rjungle", "R Jungle Stealer", true)
    -- SDK.MenuManager.Menu.r.jungle:checkbox("rdragon", "Dragon", true)
    -- SDK.MenuManager.Menu.r.jungle:checkbox("rbaron", "Baron", true)

    SDK.MenuManager.Menu:sub("farm", "Farm")
    SDK.MenuManager.Menu.farm:checkbox("farmqout", "Q Farm out range AA", true)
    SDK.MenuManager.Menu.farm:checkbox("farmq", "Q Laneclear Q", true)
    SDK.MenuManager.Menu.farm:slider("mana", "LaneClear Q Mana", 0, 100, 80, 1)

    SDK.MenuManager.Menu:sub("draw", "Drawings")
    SDK.MenuManager.Menu.draw:sub("range", "[=] Ranges")
    SDK.MenuManager.Menu.draw.range:checkbox("q", "Draw Q Range", true)
    SDK.MenuManager.Menu.draw.range:checkbox("w", "Draw W Range", true)
    SDK.MenuManager.Menu.draw.range:checkbox("r", "Draw R Range", true)
    SDK.MenuManager.Menu.draw:sub("damage", "[=] Damage")
    SDK.MenuManager.Menu.draw.damage:checkbox("damage", "Draw Damage", true)
    SDK.MenuManager.Menu.draw.damage:checkbox("w", "Draw W Damage", false)
    SDK.MenuManager.Menu.draw.damage:checkbox("r", "Draw R Damage", true)
    SDK.MenuManager.Menu.draw.damage:slider("aa", "Include X Autos", 1, 10, 4, 1, false)

    self.font = DrawHandler:CreateFont("consolas", 13)

    AddEvent(
        Events.OnTick,
        function()
            self:OnTick()
        end
    )
    SDK.UOL:AddCallback(
        "OnBeforeAttack",
        function(...)
            self:OnBeforeAttack(...)
        end
    )
    AddEvent(
        Events.OnProcessSpell,
        function(...)
            self:OnProcessSpell(...)
        end
    )
    AddEvent(
        Events.OnDraw,
        function()
            self:OnDraw()
        end
    )
end

function Jinx:CastQ()
    myHero.spellbook:CastSpell(SpellSlot.Q, myHero.networkId)
end

function Jinx:CastW(target)
    local pred = _G.Prediction.GetPrediction(target, self.w, myHero)
    if
        (pred and pred.rates[self.castModeOptions[SDK.MenuManager.Menu.w.pred.value]] and pred.castPosition and
            SDK.Utility:HeroVPos():dist(SDK.Vector(pred.castPosition)) < self.w.range)
     then
        if (not pred:windWallCollision() and not pred:minionCollision()) then
            myHero.spellbook:CastSpell(SpellSlot.W, pred.castPosition)
        end
    end
end

function Jinx:CastE(pos)
    myHero.spellbook:CastSpell(SpellSlot.E, pos)
end

function Jinx:CastR(pos)
    myHero.spellbook:CastSpell(SpellSlot.R, pos)
end

function Jinx:SemiCastR()
    if (SDK.MenuManager.Menu.r.user:get() and SDK.Utility:CanCastSpell(SpellSlot.R)) then
        local target = nil
        local damage = 0

        for _, enemy in pairs(ObjectManager:GetEnemyHeroes()) do
            if (SDK.Utility:IsValidTarget(enemy, self.r.range)) then
                local d = self:GetRDamage(enemy)
                if (d >= enemy.health) then
                    if (SDK.Utility:IsValidTarget(enemy, self.r.range)) then
                        local pred = _G.Prediction.GetPrediction(enemy, self.r, myHero)
                        if
                            (pred and pred.castPosition and
                                SDK.Utility:HeroVPos():dist(SDK.Vector(pred.castPosition)) < self.r.range)
                         then
                            myHero.spellbook:CastSpell(SpellSlot.R, pred.castPosition)
                        end
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
            local pred = _G.Prediction.GetPrediction(target, self.r, myHero)
            if
                (pred and pred.castPosition and
                    SDK.Utility:HeroVPos():dist(SDK.Vector(pred.castPosition)) < self.r.range)
             then
                myHero.spellbook:CastSpell(SpellSlot.R, pred.castPosition)
            end
        end
    end
end

function Jinx:LogicQ()
    if
        (SDK.UOL:GetMode() == "Waveclear" and not self:FishBonesActive() and not myHero.isWindingUp and
            SDK.UOL:GetCurrentTarget() == nil and
            SDK.UOL:CanAttack() and
            SDK.MenuManager.Menu.farm.farmqout:get() and
            _G.myHero.mana > self.RMANA + self.WMANA + self.EMANA + 20)
     then
        local minions = SDK.EntityManager:GetUnits(ObjectManager:GetEnemyMinions(), self:BonusRange() + 30, myHero)
        for i = 1, #minions do
            local minion = minions[i]
            if (minion and SDK.Utility:IsValidTarget(minion)) then
                if
                    (SDK.Utility:HeroVPos():dist(SDK.Vector(minion.position)) > SDK.Utility:GetRange() and
                        self:GetRealPowPowRange(minion) < self:GetRealDistance(minion) and
                        self:BonusRange() < self:GetRealDistance(minion))
                 then
                    local hpPred = SDK.UOL:HpPred(minion, 400)
                    if (hpPred < SDK.DamageLib:GetAutoAttackDamage(myHero, minion) * 1.1 and hpPred > 5) then
                        self:CastQ()
                        return
                    end
                end
            end
        end
    end

    -- local t = SDK.UOL:GetTarget(self:BonusRange() + 60, myHero.position)
    local tsTargets, _ =
        SDK.MenuManager.TS:update(
        function(unit)
            return SDK.Utility:IsValidTarget(unit, self:BonusRange() + 60)
        end
    )
    local t = tsTargets[1]
    if not t then
        return
    end
    DrawHandler:Circle3D(t.position, 60, SDK.Utility.Color.Yellow)
    if (SDK.Utility:IsValidTarget(t, self:BonusRange() + 60)) then
        local FishBoneActive = self:FishBonesActive()
        local InAutoAttackRange = SDK.Utility:InAutoAttackRange(t)
        local EnemiesInRange = SDK.EntityManager:CountEnemiesInRange(150, t) >= 2

        if (not FishBoneActive and (not InAutoAttackRange or EnemiesInRange)) then
            local distance = self:GetRealDistance(t)
            if
                (SDK.UOL:GetMode() == "Combo" and
                    (myHero.mana > self.RMANA + self.WMANA + 20 or
                        SDK.DamageLib:GetAutoAttackDamage(myHero, t) * 3 > t.health))
             then
                self:CastQ()
            elseif
                (SDK.UOL:GetMode() == "Harass" and not SDK.UOL:IsAttacking() and SDK.UOL:CanAttack() and
                    SDK.MenuManager.Menu.q.qharass:get() and
                    not SDK.Utility:IsUnderTurret() and
                    myHero.mana > self.RMANA + self.WMANA + self.EMANA + 20 and
                    distance < self:BonusRange() + t.boundingRadius + myHero.boundingRadius)
             then
                self:CastQ()
            end
        end
    elseif
        (not self:FishBonesActive() and SDK.UOL:GetMode() == "Combo" and myHero.mana > self.RMANA + self.WMANA + 20 and
            SDK.EntityManager:CountEnemiesInRange(2000, myHero) > 0)
     then
        self:CastQ()
    elseif (self:FishBonesActive() and SDK.UOL:GetMode() == "Combo" and myHero.mana < self.RMANA + self.WMANA + 20) then
        self:CastQ()
    elseif
        (self:FishBonesActive() and SDK.UOL:GetMode() == "Combo" and
            SDK.EntityManager:CountEnemiesInRange(2000, myHero) == 0)
     then
        self:CastQ()
    elseif (self:FishBonesActive() and (SDK.UOL:GetMode() == "Waveclear" or SDK.UOL:GetMode() == "Lasthit")) then
        self:CastQ()
    end
end

function Jinx:LogicW()
    for _, enemy in ipairs(SDK.EntityManager:GetEnemies(self.w.range, myHero)) do
        local distance = SDK.Utility:HeroVPos():dist(SDK.Vector(enemy.position))
        local outsideRange =
            (SDK.MenuManager.Menu.w.safety.aarange:get() and distance > self:GetRealPowPowRange(enemy)) or
            not SDK.MenuManager.Menu.w.safety.aarange:get()
        if (SDK.Utility:IsValidTarget(enemy, self.w.range) and outsideRange) then
            local comboDmg = self:GetWDamage(enemy)
            if (SDK.Utility:CanCastSpell(SpellSlot.R) and myHero.mana > self.RMANA + self.WMANA + 20) then
                comboDmg = comboDmg + self:GetRDamage(enemy)
            end
            if (comboDmg > enemy.health) then
                self:CastW(enemy)
                return
            end
        end
    end

    local enemyCheck =
        (SDK.MenuManager.Menu.w.safety.enemiesnear:get() and
        SDK.EntityManager:CountEnemiesInRange(self:BonusRange(), myHero) == 0) or
        not SDK.MenuManager.Menu.w.safety.enemiesnear:get()
    if (enemyCheck) then
        if (SDK.UOL:GetMode() == "Combo" and myHero.mana > self.RMANA + self.WMANA + 10) then
            local w_target, _ = SDK.MenuManager.TS:GetTarget(self.w, myHero)
            if (w_target and SDK.Utility:IsValidTarget(w_target, self.w.range)) then
                self:CastW(w_target)
            end
        end
    end
end

function Jinx:LogicE()
    if
        (myHero.mana > self.RMANA + self.EMANA and SDK.MenuManager.Menu.e.autoe:get() and
            _G.RiotClock.time - self.grabTime > 1)
     then
        for _, enemy in pairs(SDK.EntityManager:GetEnemies(self.e.range, myHero)) do
            if (SDK.Utility:IsValidTarget(enemy, self.e.range) and not SDK.Utility:CanMove(enemy)) then
                self:CastE(enemy.position)
                return
            end
        end
    -- TODO: Trap pos
    -- if (m.e.tele:get()) then
    --   local trapPos = nil
    -- end
    end

    if (SDK.MenuManager.Menu.e.antimelee:get() and SDK.EntityManager:CountEnemiesInRange(300) > 0) then
        self:CastE(myHero.position)
        return
    end

    if
        (SDK.UOL:GetMode() == "Combo" and SDK.UOL:IsOrbWalking() and SDK.MenuManager.Menu.e.comboe:get() and
            myHero.mana > self.RMANA + self.EMANA + self.WMANA)
     then
        local t, pred = SDK.MenuManager.TS:GetTarget(self.e, myHero)
        if
            (t and pred and SDK.Utility:IsValidTarget(t, self.e.range) and
                SDK.Vector(t.position):dist(SDK.Vector(pred.castPosition)) > 200 and
                pred.rates["slow"])
         then
            if (t.buffManager:HasBuffOfType(BuffType.Slow)) then
                self:CastE(pred.castPosition)
            else
                self:CastE(pred.castPosition)
            end
        end
    end
end

function Jinx:LogicR()
    -- if (SDK.MenuManager.Menu.r.safety.rturret:get() and SDK.Utility:IsUnderTurret()) then
    --     return
    -- end

    if (SDK.MenuManager.Menu.r.autor:get()) then
        local r_targets, r_preds = SDK.MenuManager.TS:GetTargets(self.r, myHero)
        for i = 1, #r_targets do
            local unit = r_targets[i]
            local pred = r_preds[unit.networkId]

            local predRate = self.castModeOptions[SDK.MenuManager.Menu.r.rate.value]

            if
                (SDK.Utility:IsValidTarget(unit, self.r.range) and SDK.Utility:ValidUlt(unit) and pred and
                    pred.rates[predRate])
             then
                local health = unit.health
                local Rdmg = self:GetRDamage(unit)
                local killable = Rdmg > health
                local outsideRange =
                    (SDK.MenuManager.Menu.r.safety.aarange:get() and
                    self:GetRealDistance(unit) > self:BonusRange() + 200) or
                    not SDK.MenuManager.Menu.r.safety.aarange:get()
                -- print("Name: "..unit.charName.." | killable: "..tostring(killable).." | outsideRange: "..tostring(outsideRange))
                if (killable and outsideRange) then
                    local allyCheck =
                        (SDK.MenuManager.Menu.r.safety.alliesnear:get() and
                        SDK.EntityManager:CountAlliesInRange(600, unit) == 0) or
                        not SDK.MenuManager.Menu.r.safety.alliesnear:get()
                    local enemyCheck =
                        (SDK.MenuManager.Menu.r.safety.enemiesnear:get() and
                        SDK.EntityManager:CountEnemiesInRange(400, myHero) == 0) or
                        not SDK.MenuManager.Menu.r.safety.enemiesnear:get()
                    local multiHit = SDK.EntityManager:CountEnemiesInRange(200, unit) > 2
                    -- print("Name: "..unit.charName.." | allyCheck: "..tostring(allyCheck).." | enemyCheck: "..tostring(enemyCheck).." | multiHit: "..tostring(multiHit))
                    if (allyCheck and enemyCheck) then
                        self:CastR(pred.castPosition)
                    elseif (multiHit) then
                        self:CastR(pred.castPosition)
                    end
                end
            end
        end
    end
end

local contains = function(s, f)
    return string.find(string.lower(s), f)
end

function Jinx:KsJungle()
    local mobs = ObjectManager:GetEnemyMinions()
    for _, mob in pairs(mobs) do
        DrawHandler:Circle3D(mob.position, 50, SDK.Utility.Color.Red)
        local alliesInRange = SDK.EntityManager:CountAlliesInRange(1000, mob)
        local distance = SDK.Utility:HeroVPos():dist(SDK.Vector(mob.position)) > 1000
        if
            (mob.health < mob.maxHealth and
                ((contains(mob.skinName, "dragon")) and SDK.MenuManager.Menu.r.jungle.rdragon:get()) or
                (mob.skinName == "SRU_Baron" and SDK.MenuManager.Menu.r.jungle.rbaron:get()) and alliesInRange and
                    distance)
         then
            if (self.DragonDmg == 0) then
                self.DragonDmg = mob.health
            end

            DrawHandler:Text(
                self.font,
                Renderer:WorldToScreen(myHero.position),
                "DragonTime: " .. self.DragonTime,
                SDK.Utility.Color.Red
            )
            if (_G.RiotClock.time - self.DragonTime > 4) then
                -- print("DragonTime: " .. self.DragonTime)
                if (self.DragonDmg - mob.health > 0) then
                    self.DragonDmg = mob.health
                end
                self.DragonTime = _G.RiotClock.time
            else
                local DmgSec = (mob.health - self.DragonDmg) * (math.abs(self.DragonTime - _G.RiotClock.time) / 4)
                -- print("DragonDmg: " .. DmgSec)
                if (mob.health - self.DragonDmg > 0) then
                    local timeTravel = self:GetUltTravelTime(myHero, self.r.speed, self.r.delay, mob.position)
                    local dmg = (250 + (100 * SDK.Utility:GetSpellLevel(SpellSlot.R)) + SDK.Utility:GetBonusAD() + 300)
                    local pos = Renderer:WorldToScreen(mob.position)
                    DrawHandler:Text(self.font, pos, "Damage: " .. dmg, SDK.Utility.Color.Red)
                    local timeR = (self:GetRDamage(mob) * 0.8) / (DmgSec / 4)
                    pos.y = pos.y + 30
                    DrawHandler:Text(
                        self.font,
                        pos,
                        "timeTravel: " .. timeTravel .. " | timeR: " .. timeR,
                        SDK.Utility.Color.Red
                    )
                    if (timeTravel > timeR) then
                        self:CastR(mob.position)
                    end
                else
                    self.DragonDmg = mob.health
                end
            end
        end
    end
end

function Jinx:GetWDamage(target)
    local wLevel = SDK.Utility:GetSpellLevel(SpellSlot.W)
    if (wLevel == 0) then
        return 0
    end

    local wBaseDamage = self.w.baseDamage[wLevel] + SDK.Utility:GetTotalAD() * 1.6

    return SDK.DamageLib:CalculatePhysicalDamage(myHero, target, wBaseDamage)
end

function Jinx:GetRDamage(target)
    local rLevel = SDK.Utility:GetSpellLevel(SpellSlot.R)
    if (rLevel == 0) then
        return 0
    end

    local pos = Renderer:WorldToScreen(target.position)
    local distance = SDK.Utility:HeroVPos():dist(SDK.Vector(target.position))
    local distancePercentage = ((distance / 100) % 100) * 0.06
    local finalPercentage = math.min(distancePercentage, 0.9) + 0.1

    local rBaseDamage = (self.r.baseDamage[rLevel] + SDK.Utility:GetBonusAD() * 1.5) * finalPercentage

    local healthDamage = self.r.healthDamage[rLevel] * SDK.Utility:MissingHealth(target)

    local totalDamage = rBaseDamage + healthDamage

    return SDK.DamageLib:CalculatePhysicalDamage(myHero, target, totalDamage)
end

function Jinx:FishBonesActive()
    return myHero.buffManager:HasBuff(0xd2a0ed81)
end

function Jinx:BonusRange()
    return 670 + myHero.boundingRadius + (25 * SDK.Utility:GetSpellLevel(SpellSlot.Q))
end

function Jinx:GetRealPowPowRange(target)
    return 640 + myHero.boundingRadius + target.boundingRadius
end

function Jinx:GetRealDistance(target)
    local pos, _ = _G.Prediction.GetUnitPosition(target, 0.05)
    return SDK.Utility:HeroVPos():dist(SDK.Vector(pos)) + myHero.boundingRadius + target.boundingRadius
end

function Jinx:GetUltTravelTime(source, speed, delay, targetPos)
    local distance = SDK.Vector(source.position):dist(SDK.Vector(targetPos))
    local missileSpeed = speed

    if (source.charName == "Jinx" and distance > 1350) then
        local accelerationRate = 0.3
        local accelDifference = distance - 1350
        if (accelDifference > 150) then
            accelDifference = 150
        end
        local difference = distance - 1500
        missileSpeed =
            (1350 * speed + accelDifference * (speed + accelerationRate * accelDifference) + difference * 2200) /
            distance
    end
    return (distance / missileSpeed + delay)
end

function Jinx:SetMana()
    if (_G.myHero.healthPercent < 20) then
        self.QMANA = 0
        self.WMANA = 0
        self.EMANA = 0
        self.RMANA = 0
        return
    end

    self.QMANA = 20
    self.WMANA = 40 + (10 * SDK.Utility:GetSpellLevel(SpellSlot.W))
    self.EMANA = 70

    if (SDK.Utility:CanCastSpell(SpellSlot.R)) then
        self.RMANA =
            self.WMANA -
            _G.myHero.characterIntermediate.parRegenRate * _G.myHero.spellbook:Spell(SpellSlot.W).cooldownTimeRemaining
    else
        self.RMANA = 100
    end
end

function Jinx:ShouldUseE(spellName)
    local spells = {
        ["ThreshQ"] = true,
        ["KatarinaR"] = true,
        ["AlZaharNetherGrasp"] = true,
        ["LuxMaliceCannon"] = true,
        ["MissFortuneBulletTime"] = true,
        ["RocketGrabMissile"] = true,
        ["CaitlynPiltoverPeacemaker"] = true,
        ["EzrealTrueshotBarrage"] = true,
        ["InfiniteDuress"] = true,
        ["VelkozR"] = true
    }

    return spells[spellName] or false
end

function Jinx:Swap(target)
    if
        (not SDK.Utility:CanCastSpell(SpellSlot.Q) or not SDK.MenuManager.Menu.q.autoq:get() or
            not self:FishBonesActive())
     then
        return
    end

    if (not target) then
        return
    end

    if (target.type == GameObjectType.AIHeroClient) then
        local realDistance = self:GetRealDistance(target) - 50
        if
            (SDK.UOL:GetMode() == "Combo" and
                (realDistance < self:GetRealPowPowRange(target) or
                    (_G.myHero.mana < self.RMANA + 20 and
                        SDK.DamageLib:GetAutoAttackDamage(myHero, target) * 3 < target.health)))
         then
            self:CastQ()
        elseif
            (SDK.UOL:GetMode() == "Harass" and SDK.MenuManager.Menu.q.qharass:get() and
                (realDistance > self:BonusRange() or realDistance < self:GetRealPowPowRange(target) or
                    myHero.mana < self.RMANA + self.EMANA + self.WMANA + self.WMANA))
         then
            self:CastQ()
        end
    end

    if (target.type == GameObjectType.obj_AI_Minion) then
        local realDistance = self:GetRealDistance(target)
        if (SDK.UOL:GetMode() == "Waveclear") then
            if
                (realDistance < self:GetRealPowPowRange(target) or
                    _G.myHero.manaPercent < SDK.MenuManager.Menu.farm.mana.value)
             then
                self:CastQ()
            end
        elseif
            (SDK.UOL:GetMode() == "Harass" and SDK.MenuManager.Menu.q.qharass:get() and
                (realDistance > self:BonusRange() or realDistance < self:GetRealPowPowRange(target) or
                    myHero.mana < self.RMANA + self.EMANA + self.WMANA + self.WMANA))
         then
            self:CastQ()
        end
    end
end

function Jinx:OnBeforeAttack(target)
    if myHero.isWindingUp then
        return
    end
    self:Swap(target)
end

function Jinx:LagFree(offset)
    return self.tickIndex == offset
end

function Jinx:OnTick()
    if (not SDK.UOL) then
        return
    end

    if (myHero.isRecalling) then
        return
    end

    self:SemiCastR()

    -- if (SDK.MenuManager.Menu.r.jungle.rjungle:get()) then
    --   self:KsJungle()
    -- end

    if
        (SDK.MenuManager.Menu.e.gap:get() and SDK.Utility:CanCastSpell(SpellSlot.E) and
            myHero.mana > self.RMANA + self.EMANA)
     then
        local e_targets, e_preds = SDK.MenuManager.TS:GetTargets(self.e, myHero)
        for i = 1, #e_targets do
            local unit = e_targets[i]
            local pred = e_preds[unit.networkId]

            if (pred) then
                if (pred.targetDashing and SDK.Utility:HeroVPos():dist(SDK.Vector(pred.castPosition)) < self.e.range) then
                    self:CastE(pred.castPosition)
                end
            end
        end
    end

    if self:LagFree(0) then
        self:SetMana()
    end

    if (SDK.Utility:CanCastSpell(SpellSlot.E)) then
        self:LogicE()
    end

    if (self:LagFree(2) and SDK.Utility:CanCastSpell(SpellSlot.Q) and SDK.MenuManager.Menu.q.autoq:get()) then
        self:LogicQ()
    end

    if
        (self:LagFree(3) and SDK.Utility:CanCastSpell(SpellSlot.W) and not SDK.UOL:IsAttacking() and
            SDK.MenuManager.Menu.w.autow:get())
     then
        self:LogicW()
    end

    if (self:LagFree(4) and SDK.Utility:CanCastSpell(SpellSlot.R)) then
        self:LogicR()
    end

    self.tickIndex = self.tickIndex + 1
    if self.tickIndex > 4 then
        self.tickIndex = 0
    end
end

---@param source GameObject
---@param spellInfo SpellCastInfo
function Jinx:OnProcessSpell(source, spellInfo)
    if (source.type == GameObjectType.obj_AI_Minion) then
        return
    end

    if (source.networkId == myHero.networkId) then
        if (spellInfo.spellData.name == "JinxWMissile") then
            self.WCastTime = _G.RiotClock.time
        end
    end

    if (SDK.Utility:CanCastSpell(SpellSlot.E)) then
        if
            (source.team ~= _G.myHero.team and SDK.MenuManager.Menu.e.opse:get() and
                SDK.Utility:IsValidTarget(source, self.e.range) and
                self:ShouldUseE(spellInfo.spellData.name))
         then
            self:CastE(source.position)
        end
        if
            (source.team == _G.myHero.team and spellInfo.spellData.name == "RocketGrab" and
                SDK.Utility:HeroVPos():dist(SDK.Vector(source.position)) < self.e.range)
         then
            self.grabTime = _G.RiotClock.time
        end
    end
end

function Jinx:OnDraw()
    -- TODO: Drawings
    if (SDK.MenuManager.Menu.draw.range.q:get() and SDK.Utility:CanCastSpell(SpellSlot.Q)) then
        DrawHandler:Circle3D(
            myHero.position,
            self:FishBonesActive() and self:GetRealPowPowRange(myHero) or self:BonusRange(),
            SDK.Utility.Color.Yellow
        )
    end
    if (SDK.MenuManager.Menu.draw.range.w:get() and SDK.Utility:CanCastSpell(SpellSlot.W)) then
        DrawHandler:Circle3D(myHero.position, self.w.range, SDK.Utility.Color.Green)
    end

    if (SDK.MenuManager.Menu.draw.range.r:get() and SDK.Utility:CanCastSpell(SpellSlot.R)) then
        -- SDK.Utility:DrawMinimapCircle(myHero, self.r.range, SDK.Utility.Color.White)
        DrawHandler:Circle3D(myHero.position, SDK.MenuManager.Menu.r.maxr.value, SDK.Utility.Color.Red)
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

return Jinx
