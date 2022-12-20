local Utility = require "nulledSeries.Utility.Utility"
local Tristana = {
    w = {
        range = 900,
        delay = 0.75,
        radius = 60,
        speed = 1000,
        type = "circular",
        baseDamage = {95, 145, 195, 245, 295}
    },
    e = setmetatable({
        type = "targetted",
        speed = 2400,
        unitRadius = 200,
        turretRadius = 500,
        baseDamage = {70, 80, 90, 100, 110},
        baseScale = {0.5, 0.75, 1, 1.25, 1.5},
        bonusDamage = {21, 24, 27, 30, 33},
        bonusScale = {0.15, 0.225, 0.3, 0.375, 0.45}
    }, {
        __index = function(self, key)
            if key == "delay" then
                return (myHero.characterIntermediate.baseAttackSpeed + myHero.characterIntermediate.attackSpeedMod) *
                           0.14801
            end
            if key == "range" then
                return SDK.Utility:GetRange() + 30
            end
        end
    }),
    r = setmetatable({
        delay = 0.25,
        radius = 200,
        speed = 2400,
        type = "targetted",
        baseDamage = {300, 400, 500}
    }, {
        __index = function(self, key)
            if key == "delay" then
                return (myHero.characterIntermediate.baseAttackSpeed + myHero.characterIntermediate.attackSpeedMod) *
                           0.14801
            end
            if key == "range" then
                return SDK.Utility:GetRange() + 30
            end
            if key == "knockback" then
                local dist = {600, 800, 1000}
                return dist[SDK.Utility:GetSpellLevel(SpellSlot.R)]
            end
        end
    }),
    eTarget = nil,
    ePos = nil,
    possibleTargets = nil,
    killableTargets = nil,
    flash = nil
}

-------------------------------------------------------------------------------------------------------------------------------------
--                                                         Initialization                                                          --
-------------------------------------------------------------------------------------------------------------------------------------
function Tristana:__init()
    -- GENERATE MENU
    -- COMBO
    SDK.MenuManager.Menu:sub("combo", "[=] Combo")
    SDK.MenuManager.Menu.combo:label("sep0", "Q Settings", true, true)
    SDK.MenuManager.Menu.combo:checkbox("q", "Use Q", true)
    SDK.MenuManager.Menu.combo:checkbox("eq", "Use when you use E", true)
    SDK.MenuManager.Menu.combo:checkbox("qlogic", "Don't use Q if HoB [?]", false):tooltip(
        "Don't use Q if HoB & Enemy doesn't have E")
    SDK.MenuManager.Menu.combo:label("sep2", "E Settings", true, true)
    SDK.MenuManager.Menu.combo:checkbox("e", "Use E", true)
    SDK.MenuManager.Menu.combo:checkbox("focuse", "Focus E Target", true)
    SDK.MenuManager.Menu.combo:slider("echeck", "Don't use E if can kill in X AA", 1, 5, 3, 1, false)
    SDK.MenuManager:CreateBoolWhiteList(SDK.MenuManager.Menu.combo, "E", true)
    SDK.MenuManager.Menu.combo:slider("smarte", "Smart E Range [?]", 100, 2000, 800, 100, true):tooltip(
        "Will ignore whitelist if no other enemies are in X range")
    SDK.MenuManager.Menu.combo:checkbox("crit", "Include crit in calcs", true)
    SDK.MenuManager.Menu.combo:label("sep3", "R Settings", true, true)
    SDK.MenuManager.Menu.combo:checkbox("r", "Use R", true)
    SDK.MenuManager.Menu.combo:checkbox("delivery", "Use DeliveryTM", true)
    SDK.MenuManager.Menu.combo:checkbox("galeforce", "Include Galeforce", true)
    SDK.MenuManager.Menu.combo:key("semir", "Semi Auto R [Closest]", string.byte("T"))
    -- SDK.MenuManager.Menu.combo:key("semir", "R Semi-Automatic Cast", string.byte("T"))
    SDK.MenuManager:CreateBoolWhiteList(SDK.MenuManager.Menu.combo, "R", true)

    -- KS Menu
    SDK.MenuManager.Menu:sub("ks", "[=] Killsteal")
    SDK.MenuManager.Menu.ks:checkbox("r", "Use R", true)
    SDK.MenuManager:CreateBoolWhiteList(SDK.MenuManager.Menu.ks, "R", true)
    SDK.MenuManager.Menu.ks:slider("rcheck", "Don't use R if can kill in X AA", 1, 5, 2, 1, false)

    -- Misc Menu
    -- SDK.MenuManager.Menu:sub("misc", "[=] Misc")
    -- SDK.MenuManager.Menu.misc:checkbox("antigrab", "W to cancel grabs [WIP]", false)
    -- SDK.MenuManager.Menu.misc:list("direction", "Direction", 2, {"Away from grabber", "To Cursor"})
    -- SDK.MenuManager.Menu.misc:slider("peel", "Use R to self-peel | if HP <= x%", 0, 100, 10, 5, truea

    -- Gapcloser Menu
    SDK.MenuManager.Menu:sub("gap", "[=] Anti-Gapcloser")
    SDK.MenuManager.Menu.gap:checkbox("w", "Use W")
    SDK.MenuManager:CreateBoolWhiteList(SDK.MenuManager.Menu.gap, "W", true)
    SDK.MenuManager.Menu.gap:checkbox("r", "Use R", true)
    SDK.MenuManager:CreateBoolWhiteList(SDK.MenuManager.Menu.gap, "R", true)

    -- Interrupter Menu
    SDK.MenuManager.Menu:sub("interrupter", "[=] Interrupter")
    SDK.MenuManager.Menu.interrupter:checkbox("r", "Use R", true)
    SDK.MenuManager:CreateBoolWhiteList(SDK.MenuManager.Menu.interrupter, "R", true)

    -- Draw Menu
    SDK.MenuManager.Menu:sub("draw", "[=] Drawings")
    SDK.MenuManager.Menu.draw:sub("range", "[=] Range")
    SDK.MenuManager.Menu.draw.range:checkbox("w", "Draw W Range", true)
    SDK.MenuManager.Menu.draw.range:checkbox("erlines", "Draw DeliveryTM Lines", true)
    SDK.MenuManager.Menu.draw.range:checkbox("ercircles", "Draw DeliveryTM Circles", true)
    SDK.MenuManager.Menu.draw:sub("damage", "[=] Damage")
    SDK.MenuManager.Menu.draw.damage:checkbox("damage", "Draw Damage", true)
    SDK.MenuManager.Menu.draw.damage:label("sep0", "W Damage", true, true)
    SDK.MenuManager.Menu.draw.damage:checkbox("w", "Include W", false)
    SDK.MenuManager.Menu.draw.damage:label("sep1", "E Damage", true, true)
    SDK.MenuManager.Menu.draw.damage:checkbox("e", "Include E", true)
    SDK.MenuManager.Menu.draw.damage:label("sep2", "R Damage", true, true)
    SDK.MenuManager.Menu.draw.damage:checkbox("r", "Include R", true)
    SDK.MenuManager.Menu.draw.damage:label("sep3", "Galeforce Damage", true, true)
    SDK.MenuManager.Menu.draw.damage:checkbox("gf", "Include Galeforce", true)
    SDK.MenuManager.Menu.draw.damage:label("sep4", "Auto Attack Damage", true, true)
    SDK.MenuManager.Menu.draw.damage:slider("aa", "Include X Autos", 1, 10, 4, 1, false)

    self.font = DrawHandler:CreateFont("Consolas", 13)
    self.flash = (myHero.spellbook:Spell(SpellSlot.Summoner1).name:lower():find("flash") and SpellSlot.Summoner1) or
                     (myHero.spellbook:Spell(SpellSlot.Summoner2).name:lower():find("flash") and SpellSlot.Summoner2) or
                     nil

    -- SUBSCRIBE TO EVENTS
    AddEvent(Events.OnTick, function()
        self:OnTick()
    end)
    AddEvent(Events.OnDraw, function()
        self:OnDraw()
    end)
    AddEvent(Events.OnProcessSpell, function(...)
        self:OnProcessSpell(...)
    end)
    AddEvent(Events.OnSpellbookCastSpell, function(...)
        self:OnSpellbookCastSpell(...)
    end)
    SDK.UOL:AddCallback("OnBeforeAttack", function(target)
        self:OnBeforeAttack(target)
    end)
    AddEvent(Events.OnBuffGain, function(source, buff)
        -- print(source.charName .. " - " .. tostring(buff.name))
    end)
    AddEvent(Events.OnExecuteCastFrame, function(...)
        self:OnExecuteCastFrame(...)
    end)
    SDK:Log("Loaded Tristana")
end

-------------------------------------------------------------------------------------------------------------------------------------
--                                                             Spells                                                              --
-------------------------------------------------------------------------------------------------------------------------------------
function Tristana:CastQ()
    myHero.spellbook:CastSpell(SpellSlot.Q, myHero.networkId)
end

function Tristana:CastW(position)
    myHero.spellbook:CastSpell(SpellSlot.W, position)
end

function Tristana:CastE(target)
    myHero.spellbook:CastSpell(SpellSlot.E, target.networkId)
end

function Tristana:CastR(target)
    myHero.spellbook:CastSpell(SpellSlot.R, target.networkId)
end

function Tristana:CastGaleforce(target)
    if SDK.MenuManager.Menu.combo.galeforce:get() then
        local itemNode = myHero.inventory:HasItem(6671)
        local item = myHero.inventory:FindItemSlot(6671)
        if itemNode and myHero.spellbook:CanUseSpell(item) == 0 then
            myHero.spellbook:CastSpellFast(item, target.position)
        end
    end
end

function Tristana:CastEBomb(buffTime, dist, targets)
    local meDist = SDK.Utility:HeroVPos():dist(SDK.Vector(self.eTarget.position))
    for _, target in pairs(targets) do
        local ndist = SDK.Vector(target.position):dist(SDK.Vector(self.eTarget.position))
        local npos = SDK.Vector(target.position):extended(SDK.Vector(self.eTarget.position), meDist + ndist)
        local isCloseToCastPos = SDK.Utility:HeroVPos():dist(npos) < self.e.unitRadius - 50
        if (SDK.MenuManager.Menu.draw.range.erlines:get()) then
            DrawHandler:Line(Renderer:WorldToScreen(target.position), Renderer:WorldToScreen(npos:toDX3()),
                isCloseToCastPos and SDK.Utility.Color.Green or SDK.Utility.Color.Red)
            DrawHandler:Line(Renderer:WorldToScreen(myHero.position), Renderer:WorldToScreen(npos:toDX3()),
                isCloseToCastPos and SDK.Utility.Color.Green or SDK.Utility.Color.Red)
        end
        if (SDK.MenuManager.Menu.draw.range.ercircles:get()) then
            DrawHandler:Circle3D(npos:toDX3(), 50, isCloseToCastPos and SDK.Utility.Color.Green or SDK.Utility.Color.Red)
        end
        local s = 1500
        local d = self.ePos:dist(SDK.Vector(self.eTarget.position))
        local t = d / s
        if (buffTime <= t and isCloseToCastPos) then
            self:CastR(self.eTarget)
            return
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------
--                                                           Definitions                                                           --
-------------------------------------------------------------------------------------------------------------------------------------
function Tristana:GetEBuffCount(unit)
    return SDK.Utility:GetBuffStacks(unit, 0xea8d1790)
end

function Tristana:HasEBuff(unit)
    return unit.buffManager:HasBuff(0xea8d1790)
end

function Tristana:GetPossibleERTargets(eTarget, pos)
    local possibleTargets = {}
    local killableTargets = {}
    for _, enemy in pairs(ObjectManager:GetEnemyHeroes()) do
        if not enemy.isInvulnerable and not enemy.isDead and not enemy.buffManager:HasBuff(0xb600518b) and
            enemy.isTargetable then
            if (SDK.Vector(enemy.position):dist(eTarget) < 1000 + self.e.unitRadius) then
                if enemy:IsKillable(self:GetEBombDamage(eTarget, enemy), SDK.DamageType.PHYSICAL) then
                    table.insert(killableTargets, enemy)
                else
                    table.insert(possibleTargets, enemy)
                end
            end
        end
    end
    return possibleTargets, killableTargets
end

-------------------------------------------------------------------------------------------------------------------------------------
--                                                             Damage                                                              --
-------------------------------------------------------------------------------------------------------------------------------------

function Tristana:GetWDamage(unit)
    local wLevel = SDK.Utility:GetSpellLevel(SpellSlot.W)
    if (wLevel == 0) then
        return 0
    end

    local wBaseDamage = self.w.baseDamage[wLevel] + 0.5 * SDK.Utility:GetTotalAP()

    wBaseDamage = wBaseDamage * SDK.Utility:GetPTADamage(unit)
    wBaseDamage = wBaseDamage * SDK.Utility:GetPerkDamage(unit)

    return SDK.DamageLib:CalculateMagicDamage(myHero, unit, wBaseDamage)
end

function Tristana:GetEBombDamage(eTarget, unit)
    return SDK.DamageLib:CalculateMagicDamage(myHero, unit, self:GetEDamage(eTarget, true))
end

function Tristana:GetEDamage(unit, trueDamage)
    local eLevel = SDK.Utility:GetSpellLevel(SpellSlot.E)
    if (eLevel == 0) then
        return 0
    end

    local stacks = self:GetEBuffCount(unit)

    local eBaseDamage = self.e.baseDamage[eLevel] + (self.e.baseScale[eLevel] * SDK.Utility:GetBonusAD()) +
                            (0.5 * SDK.Utility:GetTotalAP())

    if (stacks == 0) then
        if (self:HasEBuff(unit)) then
            return SDK.DamageLib:CalculateMagicDamage(myHero, unit, eBaseDamage)
        end
        return 0
    end

    local eBonusDamage = self.e.bonusDamage[eLevel] + (self.e.bonusScale[eLevel] * SDK.Utility:GetBonusAD()) +
                             (0.15 * SDK.Utility:GetTotalAP())

    eBonusDamage = eBonusDamage * stacks

    local totalDamage = (eBaseDamage + eBonusDamage)
    if (SDK.MenuManager.Menu.combo.crit:get()) then
        local critDamage = math.min(0.333 * myHero.characterIntermediate.crit, 0.333) + 1
        totalDamage = totalDamage * critDamage
    end

    totalDamage = totalDamage * SDK.Utility:GetPTADamage(unit)

    totalDamage = totalDamage * SDK.Utility:GetPerkDamage(unit)

    if (trueDamage) then
        return totalDamage
    end

    return SDK.DamageLib:CalculatePhysicalDamage(myHero, unit, totalDamage)
end

function Tristana:GetRDamage(unit)
    local rLevel = SDK.Utility:GetSpellLevel(SpellSlot.R)
    if (rLevel == 0) then
        return 0
    end

    local rBaseDamage = self.r.baseDamage[rLevel] + SDK.Utility:GetTotalAP()

    rBaseDamage = rBaseDamage * SDK.Utility:GetPTADamage(unit)
    rBaseDamage = rBaseDamage * SDK.Utility:GetPerkDamage(unit)

    return SDK.DamageLib:CalculateMagicDamage(myHero, unit, rBaseDamage)
end

function Tristana:GetGaleforceDamage(unit)
    local magicDamage = 0
    local healthDamage = 0
    if myHero.experience.level < 10 then
        magicDamage = 60
    else
        magicDamage = (math.max(myHero.experience.level, 18) * 5) + 15
    end

    magicDamage = (magicDamage + (SDK.Utility:GetBonusAD() * 0.15)) * 3

    healthDamage = (math.max(0.7, SDK.Utility:MissingHPPercent(unit)) % 7) * 0.05

    return SDK.DamageLib:CalculateMagicDamage(myHero, unit, magicDamage + healthDamage)
end

-------------------------------------------------------------------------------------------------------------------------------------
--                                                           Combo Logic                                                           --
-------------------------------------------------------------------------------------------------------------------------------------
function Tristana:Combo(target)
    if not target then
        return
    end
    self:ExecuteQ(target)
    if SDK.MenuManager.Menu.combo.ewhitelist[target.charName] and not SDK.MenuManager.Menu.combo.ewhitelist[target.charName]:get() then
        local menu = SDK.MenuManager.Menu.combo.smarte
        if menu:get() then
            local enemies = SDK.EntityManager:GetEnemies(menu.value, myHero)
            for i = 1, #enemies do
                local enemy = enemies[i]
                if SDK.MenuManager.Menu.combo.ewhitelist[enemy.charName] and SDK.MenuManager.Menu.combo.ewhitelist[enemy.charName]:get() then
                    return
                end
            end
        else
            return
        end
    end

    if (SDK.MenuManager.Menu.combo.echeck:get()) then
        if (target:GetRealHealth(SDK.DamageType.PHYSICAL) < SDK.DamageLib:GetAutoAttackDamage(myHero, target) *
            SDK.MenuManager.Menu.combo.echeck.value) then
            return
        end
    end
    self:ExecuteE(target)
end

function Tristana:ExecuteQ(target)
    if not SDK.MenuManager.Menu.combo.q:get() then
        return
    end

    if not SDK.Utility:CanCastSpell(SpellSlot.Q) then
        return
    end

    if SDK.MenuManager.Menu.combo.qlogic:get() and SDK.Utility:HasHobBuff(myHero) and not self:HasEBuff(target) then
        return
    end

    self:CastQ()
end

function Tristana:ExecuteE(target)
    if (SDK.Utility:IsValidTarget(target, self.e.range)) then
        if (SDK.MenuManager.Menu.combo.e:get() and SDK.Utility:CanCastSpell(SpellSlot.E)) then
            self:CastE(target) -- myHero.spellbook:CastSpell(SpellSlot.E, target.networkId)
        end
    end
end

function Tristana:ExecuteR(target, ks)
    if (SDK.Utility:IsValidTarget(target, self.r.range)) then
        if (ks) then
            self:SmartR(target)
            return
        end
        if (SDK.MenuManager.Menu.combo.r:get() and SDK.Utility:CanCastSpell(SpellSlot.R)) then
            if (SDK.MenuManager.Menu.combo.rwhitelist[target.charName]) then
                if (SDK.MenuManager.Menu.combo.rwhitelist[target.charName]:get()) then
                    self:SmartR(target)
                end
            end
        end
    end
end

---@param target GameObject
function Tristana:SmartR(target)
    local eDamage = self:GetEDamage(target)
    local rDamage = self:GetRDamage(target)
    local menu = SDK.MenuManager.Menu.ks.rcheck
    if menu:get() then
        if target:GetRealHealth(SDK.DamageType.PHYSICAL) < SDK.DamageLib:GetAutoAttackDamage(myHero, target) *
            menu.value then
            return
        end
    end
    local damage = eDamage + rDamage
    local castGf = SDK.MenuManager.Menu.combo.galeforce:get() and myHero.inventory:HasItem(6671) and
                       not self:IsJumping()
    if (castGf) then
        local gfDamage = self:GetGaleforceDamage(target)
        damage = damage + gfDamage
    end
    if (target:IsKillable(damage) and SDK.Utility:CanCastSpell(SpellSlot.R)) then
        self:CastR(target)
        if castGf then
            self:CastGaleforce(target)
        end
    end
end

function Tristana:CanInsec()
    return SDK.Utility:CanCastSpell(SpellSlot.W) and SDK.Utility:CanCastSpell(SpellSlot.R)
end

function Tristana:IsJumping()
    return myHero.buffManager:HasBuff(0xa4cdc73a)
end

function Tristana:GetInsecPosition(target)
    local mode = SDK.MenuManager.Menu.combo.insecmode.value
    local bestPosition = nil
    if (mode == 1) then
        -- loop through allies
        -- get best 'cluster' (definied as > 1 in 600 range of one another)
        local bestCluster = 0
        for _, ally in pairs(SDK.EntityManager:GetAllies(1500, target)) do
            if (ally.networkId ~= myHero.networkId) then
                local count = SDK.EntityManager:CountAlliesInRange(600, ally)
                if (count > bestCluster) then
                    bestCluster = count
                    bestPosition = ally.position -- TODO: needs to be improved here
                end
            end
        end
        return SDK.Vector(target.position):extended(SDK.Vector(bestPosition), -100)
    end
    if (mode == 2) then
        return SDK.Vector(target.position):extended(SDK.Utility:HeroVPos(), -100)
    end
end

local stage = "not started"
local insecPosition = nil
local jumpPosition = nil
function Tristana:Insec(target)
    if (stage == "not started" and self:CanInsec()) then
        insecPosition = myHero.position
        stage = "starting"
        return
    end
    if (stage == "starting") then
        if (myHero.buffManager:HasBuff(0xa4cdc73a)) then
            stage = "jumping"
        end
        jumpPosition = self:GetInsecPosition(target)
        if (jumpPosition:dist(SDK.Utility:HeroVPos()) < self.w.range) then
            self:CastW(jumpPosition:toDX3())
            if (SDK.Utility:CanCastSpell(SpellSlot.E)) then
                self:CastE(target)
            end
        end
        return
    end
    if (stage == "jumping") then
        if (not myHero.buffManager:HasBuff(0xa4cdc73a)) then
            stage = "landed"
        elseif (SDK.Utility:CanCastSpell(self.flash) and SDK.MenuManager.Menu.combo.flash:get()) then
            if (SDK.Utility:HeroVPos():dist(jumpPosition) < 400) then
                myHero.spellbook:CastSpell(SpellSlot.Summoner1, jumpPosition:toDX3())
                stage = "landed"
            end
        end
    end
    if (stage == "landed") then
        self:CastR(target)
        self:CastW(insecPosition)
        stage = "not started"
        insecPosition = nil
        return
    end
end

-------------------------------------------------------------------------------------------------------------------------------------
--                                                        Subscribed Events                                                        --
-------------------------------------------------------------------------------------------------------------------------------------
function Tristana:OnTick()
    if not SDK.UOL or not _G.Prediction then
        return
    end

    -- print(tostring(self.r.baseDamage[SDK.Utility:GetSpellLevel(SpellSlot.R)]) .. " + " .. tostring(SDK.Utility:GetTotalAP()))

    if SDK.MenuManager.Menu.combo.semir:get() and SDK.Utility:CanCastSpell(SpellSlot.R) then
        local closest = SDK.EntityManager:GetClosestEnemy(myHero, self.r.range)
        if closest and SDK.Utility:IsValidTarget(closest, self.r.range) then
            self:CastR(closest)
        end
    end

    if (SDK.MenuManager.Menu.combo.focuse:get()) then
        local enemies = SDK.EntityManager:GetEnemies(SDK.Utility:GetRange(true))
        for i = 1, #enemies do
            local enemy = enemies[i]
            if (enemy) then
                if (self:HasEBuff(enemy)) then
                    SDK.UOL:SetTarget(enemy)
                    return
                else
                    SDK.UOL:UnSetTarget()
                end
            end
        end
    end

    -- if (SDK.MenuManager.Menu.combo.insec:get()) then
    --     SDK.UOL:MoveTo(pwHud.hudManager.virtualCursorPos)
    --     local insecTarget = SDK.UOL:GetForcedTarget()
    --     if (insecTarget and SDK.Utility:IsValidTarget(insecTarget, 900)) then
    --         self:Insec(insecTarget)
    --     end
    -- end

    -- enemy loop
    -- ks
    -- deliveryTM
    for _, enemy in pairs(ObjectManager:GetEnemyHeroes()) do
        if not enemy.isInvulnerable and not enemy.isDead and not enemy.buffManager:HasBuff(0xb600518b) and
            enemy.isTargetable then
            if (SDK.MenuManager.Menu.ks.rwhitelist[enemy.charName]) then
                if (SDK.MenuManager.Menu.ks.rwhitelist[enemy.charName]:get() and SDK.MenuManager.Menu.ks.r:get()) then
                    self:ExecuteR(enemy, true)
                end
            end

            if (SDK.MenuManager.Menu.combo.delivery:get() and SDK.Utility:CanCastSpell(SpellSlot.R)) then
                -- E R into group
                -- check if they have e buff
                local eBuff = self:HasEBuff(enemy)
                if (eBuff) then
                    self.eTarget = enemy
                    local dist = SDK.Utility:HeroVPos():dist(SDK.Vector(self.eTarget.position))
                    local buffTime = eBuff.remainingTime - self.r.delay - (NetClient.ping / 1000)
                    local speed = 1500 -- roughly
                    local maxDistance = self.r.knockback
                    local actualDistance = math.min(speed * buffTime, maxDistance)
                    -- position at which e explodes
                    self.ePos = SDK.Utility:HeroVPos()
                        :extended(SDK.Vector(self.eTarget.position), actualDistance + dist)
                    if (SDK.MenuManager.Menu.draw.range.erlines:get()) then
                        DrawHandler:Line(Renderer:WorldToScreen(myHero.position),
                            Renderer:WorldToScreen(self.ePos:toDX3()), SDK.Utility.Color.Red)
                    end
                    if (SDK.MenuManager.Menu.draw.range.ercircles:get()) then
                        DrawHandler:Circle3D(self.ePos:toDX3(), 50, SDK.Utility.Color.Red)
                    end
                    -- get all units in (300) range of position
                    self.possibleTargets, self.killableTargets = self:GetPossibleERTargets(self.eTarget, self.ePos)
                    if (self.killableTargets) then
                        if (#self.killableTargets >= 1 and SDK.Utility:IsValidTarget(self.eTarget, self.r.range)) then
                            self:CastEBomb(buffTime, actualDistance, self.killableTargets)
                        end
                    end
                    if (self.possibleTargets) then
                        if (#self.possibleTargets >= 2 and SDK.Utility:IsValidTarget(self.eTarget, self.r.range)) then
                            self:CastEBomb(buffTime, actualDistance, self.possibleTargets)
                        end
                    end
                    self.killableTargets = nil
                    self.possibleTargets = nil
                else
                    self.eTarget = nil
                    self.ePos = nil
                end
            end
        end
    end

    -- antigapcloser
    local rTargets, rPreds = SDK.MenuManager.TS:GetTargets(self.r, myHero, function(unit)
        return SDK.Utility:IsValidTarget(unit, self.r.range)
    end)
    for _, target in pairs(rTargets) do
        local pred = rPreds[target.networkId]
        if (pred and pred.targetDashing) then
            local useW = SDK.MenuManager.Menu.gap.w:get()
            local useR = SDK.MenuManager.Menu.gap.r:get()
            local shouldWEnemy = SDK.MenuManager.Menu.gap.wwhitelist[target.charName]:get()
            local shouldREnemy = SDK.MenuManager.Menu.gap.rwhitelist[target.charName]:get()
            if (useW and shouldWEnemy and SDK.Utility:HeroVPos():dist(SDK.Vector(pred.castPosition)) < 400 and
                SDK.Utility:CanCastSpell(SpellSlot.W)) then
                local jumpPos = SDK.Utility:HeroVPos():extended(SDK.Vector(pred.castPosition), -self.w.range):toDX3()
                self:CastW(jumpPos)
            end
            if (useR and shouldREnemy and SDK.Utility:HeroVPos():dist(SDK.Vector(pred.castPosition)) < 400 and
                SDK.Utility:CanCastSpell(SpellSlot.R) and not SDK.Utility:HasHookBuffs(target)) then
                self:CastR(target)
            end
        end
        if pred and pred.isInterrupt then
            -- TODO
            local useR = SDK.MenuManager.Menu.interrupter.r:get()
            local canR = SDK.Utility:CanCastSpell(SpellSlot.R)
            local shouldREnemy = SDK.MenuManager.Menu.interrupter.rwhitelist[target.charName]:get()
            local dist = SDK.Utility:HeroVPos():dist(SDK.Vector(target.position)) < self.r.range

            if useR and canR and shouldREnemy and dist then
                self:CastR(target)
            end
        end
    end
end

function Tristana:OnProcessSpell(source, args)
    -- if (_G.Evade360 and _G.Evade360:IsEvading()) then
    --     return
    -- end
    -- local spell = args.spellData
    -- if (spell.name == "ThreshQ" or spell.name == "RocketGrab") then
    --     if (SDK.Utility:HeroVPos():dist(SDK.Vector(args.endPos)) <= 140 + 5) then
    --         local jumpPos = nil
    --         if (SDK.MenuManager.Menu.misc.direction.value == 1) then
    --             jumpPos = pwHud.hudManager.virtualCursorPos
    --         else
    --             jumpPos = SDK.Utility:HeroVPos():extended(SDK.Vector(source.position), -600):toDX3()
    --         end
    --         local distance = SDK.Utility:HeroVPos():dist(SDK.Vector(source.position))
    --         local speed = 1800
    --         local time = distance / speed
    --         SDK.OrbAPI.Timer:DelayAction(
    --             function()
    --                 self:CastW(jumpPos)
    --             end,
    --             time + (NetClient.ping / 1000)
    --         )
    --     end
    -- end

    if (source.networkId ~= myHero.networkId) then
        return
    end

    if (args.spellSlot == SpellSlot.W) then -- if you cast W
        if (SDK.Utility:CanCastSpell(SpellSlot.E)) then
            -- if (SDK.UOL:GetMode() == "Combo") then -- and you're holding space
            if (SDK.MenuManager.Menu.combo.e:get()) then -- and you have the option ticked in the menu
                local target, _ = SDK.MenuManager.TS:GetTarget(self.e, myHero)
                if (target and SDK.Utility:HeroVPos():dist(SDK.Vector(target.position)) < self.e.range) then -- if the target is in range
                    self:ExecuteE(target) -- cast e on them
                end
            end
            -- end
        end
    end
end

function Tristana:OnSpellbookCastSpell(slot, startPos, endPos, target)
    if (slot == SpellSlot.E) then
        if (SDK.MenuManager.Menu.combo.eq:get()) then
            if (SDK.Utility:IsValidTarget(target, self.e.range)) then
                self:ExecuteQ(target)
            end
        end
    end
end

---@param target GameObject
function Tristana:OnBeforeAttack(target)
    local orbMode = SDK.UOL:GetMode()

    if not target then
        return
    end

    if target.type ~= GameObjectType.AIHeroClient then
        return
    end

    if (orbMode == "Combo") then
        self:Combo(target)
    end

    if (SDK.MenuManager.Menu.combo.focuse:get()) then
        local enemies = SDK.EntityManager:GetEnemies(SDK.Utility:GetRange(true))
        for i = 1, #enemies do
            local enemy = enemies[i]
            if (enemy) then
                if (self:HasEBuff(enemy)) then
                    SDK.UOL:SetTarget(enemy)
                    return
                else
                    SDK.UOL:UnSetTarget()
                end
            end
        end
    end
end

function Tristana:OnExecuteCastFrame(source, spellCastInfo)
    if not SDK.UOL then
        return
    end

    if (source.charName ~= myHero.charName) then
        return
    end

    local target = spellCastInfo.target
    if not target then
        return
    end
    if target.type ~= GameObjectType.AIHeroClient then
        return
    end
    if (not SDK.Utility:IsValidTarget(target, myHero.characterIntermediate.attackRange)) then
        return
    end

    if (not spellCastInfo.isAutoAttack) then
        return
    end

    local orbMode = SDK.UOL:GetMode()

    if (orbMode == "Combo") then
        self:Combo(target)
    end
end

function Tristana:OnDraw()
    if (SDK.MenuManager.Menu.draw.range.w:get() and SDK.Utility:CanCastSpell(SpellSlot.W)) then
        DrawHandler:Circle3D(myHero.position, self.w.range, SDK.Utility.Color.Green)
        DrawHandler:Circle3D(myHero.position, self.e.range, SDK.Utility.Color.Red)
    end

    for _, enemy in pairs(ObjectManager:GetEnemyHeroes()) do
        if (not SDK.MenuManager.Menu.draw.damage.damage:get()) then
            return
        end

        local damage = 0
        if (SDK.MenuManager.Menu.draw.damage.w:get() and SDK.Utility:CanCastSpell(SpellSlot.W)) then
            damage = damage + self:GetWDamage(enemy)
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
        if (SDK.MenuManager.Menu.draw.damage.gf:get()) then
            damage = damage + self:GetGaleforceDamage(enemy)
        end
        if (enemy and SDK.Utility:IsValidTarget(enemy, 2000)) then
            SDK.Utility:DrawDamage(enemy, damage)
        end
    end
end

return Tristana
