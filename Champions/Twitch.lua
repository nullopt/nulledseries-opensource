local Twitch = {
    q = {
        targetRange = 600,
        mana = 40,
        duration = {10, 11, 12, 13, 14}
    },
    w = {
        type = "circular",
        range = 950,
        speed = 1400,
        delay = 0.25,
        radius = 150,
        mana = 70
    },
    e = {
        range = 1200,
        baseDamage = {20, 30, 40, 50, 60},
        stackDamage = {15, 20, 25, 30, 35},
        mana = {50, 60, 70, 80, 90}
    },
    r = {
        range = 300,
        radius = 60,
        speed = 1750,
        mana = 100,
        duration = 6
    },
    crab = "sru_crab",
    AAs = {},
    buffs = {}
}

-------------------------------------------------------------------------------------------------------------------------------------
--                                                         Initialization                                                          --
-------------------------------------------------------------------------------------------------------------------------------------
function Twitch:__init()
    -- GENERATE MENU
    -- COMBO
    SDK.MenuManager.Menu:sub("combo", "[=] Combo")
    SDK.MenuManager.Menu.combo:label("sep0", "Q Settings", true, true)
    SDK.MenuManager.Menu.combo:list("q", "Q Usage", 2, {"Before Auto Attack", "Always", "Never"})
    SDK.MenuManager.Menu.combo:slider("qrange", "Use Q If Enemies in X Range", 400, 2000, 700, 50)
    SDK.MenuManager.Menu.combo:label("sep1", "W Settings", true, true)
    SDK.MenuManager.Menu.combo:list("w", "W Usage", 1, {"After Auto Attack", "Never"})
    SDK.MenuManager.Menu.combo:key("whk", "W Hotkey", string.byte("G"))
    SDK.MenuManager.Menu.combo:checkbox("wturret", "Don't W Under Turret", true)
    SDK.MenuManager.Menu.combo:slider("waa", "Don't W If Killable In X AA", 0, 5, 2, 1, true)
    SDK.MenuManager.Menu.combo:checkbox("wr", "Don't W If R Active", true)
    SDK.MenuManager.Menu.combo:label("sep2", "E Settings", true, true)
    SDK.MenuManager.Menu.combo:checkbox("e", "Use E", true)
    SDK.MenuManager.Menu.combo:checkbox("eaa", "Include Last Auto Attack", true)
    SDK.MenuManager.Menu.combo:checkbox("emana", "Save Mana for E")
    SDK.MenuManager.Menu.combo:slider("estacks", "Use E at X stacks", 1, 6, 6, 1, false)
    SDK.MenuManager:CreateBoolWhiteList(SDK.MenuManager.Menu.combo, "E", true)
    SDK.MenuManager.Menu.combo:slider("multie", "Only E if >= X are killable", 1, 6, 1, 1, false)
    SDK.MenuManager.Menu.combo:checkbox("onevone", "^ Use E in 1v1 situation", true)

    SDK.MenuManager.Menu:sub("harass", "[=] Harass")
    SDK.MenuManager.Menu.harass:checkbox("w", "Use W", true)
    SDK.MenuManager.Menu.harass:slider("mana", "Min. Mana", 0, 100, 60, 5)

    SDK.MenuManager.Menu:sub("jungle", "[=] Jungle")
    SDK.MenuManager.Menu.jungle:checkbox("steal", "Steal with E", true)
    SDK.MenuManager.Menu.jungle:label("sep0", "Whitelist", true, true)
    SDK.MenuManager.Menu.jungle:checkbox("dragon", "Dragon", true)
    SDK.MenuManager.Menu.jungle:checkbox("rift", "Rift Herald", true)
    SDK.MenuManager.Menu.jungle:checkbox("baron", "Baron", true)
    SDK.MenuManager.Menu.jungle:checkbox("sru_crab", "Crab", false)

    -- ANTIGAPCLOSER
    -- SDK.MenuManager.Menu:sub("antigap", "[=] Anti-Gapcloser [NOT ENABLED]")
    -- SDK.MenuManager.Menu.antigap:checkbox("w", "Use W")
    -- SDK.MenuManager:CreateBoolWhiteList(SDK.MenuManager.Menu.antigap, "W", true)

    SDK.MenuManager.Menu:key("stealthrecall", "Stealth Recall", string.byte("B"))

    -- DRAWINGS
    SDK.MenuManager.Menu:sub("draw", "[=] Drawings")
    SDK.MenuManager.Menu.draw:label("sep0", "Timers", true, true)
    SDK.MenuManager.Menu.draw:checkbox("q", "Draw Q Timer", true)
    SDK.MenuManager.Menu.draw:checkbox("r", "Draw R Timer", true)
    SDK.MenuManager.Menu.draw:checkbox("p", "Draw Passive Timer", true)
    SDK.MenuManager.Menu.draw:checkbox("debug", "DEBUG", false)
    SDK.MenuManager.Menu.draw:sub("range", "[=] Range")
    SDK.MenuManager.Menu.draw.range:checkbox("q", "Draw Q Range", true)
    SDK.MenuManager.Menu.draw.range:checkbox("qmap", "Draw Q Range On Minimap", true)
    SDK.MenuManager.Menu.draw.range:color("qcolor", "^ Color", SDK.Utility.Color.Red)
    SDK.MenuManager.Menu.draw.range:checkbox("w", "Draw W Range", false)
    SDK.MenuManager.Menu.draw.range:checkbox("e", "Draw E Range", true)
    SDK.MenuManager.Menu.draw.range:checkbox("r", "Draw R Range", false)
    SDK.MenuManager.Menu.draw:sub("damage", "[=] Damage")
    SDK.MenuManager.Menu.draw.damage:checkbox("e", "Draw E Damage", true)
    SDK.MenuManager.Menu.draw.damage:checkbox("edebug", "[DEBUG] E Damage", false)
    SDK.MenuManager.Menu.draw.damage:checkbox("eminion", "Draw E Damage on Minions", true)
    SDK.MenuManager.Menu.draw.damage:slider("aa", "Include X Autos", 1, 10, 4, 1, false)

    -- SUBSCRIBE TO EVENTS
    AddEvent(Events.OnTick, function()
        self:OnTick()
    end)
    AddEvent(Events.OnDraw, function()
        self:OnDraw()
    end)
    AddEvent(Events.OnBasicAttack, function(...)
        self:OnBasicAttack(...)
    end)
    AddEvent(Events.OnCreateObject, function(...)
        self:OnCreateObject(...)
    end)
    AddEvent(Events.OnDeleteObject, function(...)
        self:OnDeleteObject(...)
    end)
    AddEvent(Events.OnBuffGain, function(...)
        self:OnBuffGain(...)
    end)
    AddEvent(Events.OnBuffLost, function(...)
        self:OnBuffLost(...)
    end)
    -- AddEvent(
    --     Events.OnExecuteCastFrame,
    --     function(...)
    --         self:OnExecuteCastFrame(...)
    --     end
    -- )
    self.font = DrawHandler:CreateFont("consolas", 15)
    SDK:Log("Loaded Twitch")
end

-------------------------------------------------------------------------------------------------------------------------------------
--                                                             Spells                                                              --
-------------------------------------------------------------------------------------------------------------------------------------
-- Q CAST
function Twitch:CastQ()
    if (self:SaveEMana(self.q.mana)) then
        myHero.spellbook:CastSpell(SpellSlot.Q, myHero.networkId)
    end
end

function Twitch:CastW(target)
    local pred = _G.Prediction.GetPrediction(target, self.w, myHero)
    if (pred and pred.castPosition and SDK.Utility:HeroVPos():dist(SDK.Vector(pred.castPosition)) < self.w.range) then
        if (not pred:windWallCollision()) then
            myHero.spellbook:CastSpell(SpellSlot.W, pred.castPosition)
        end
    end
end

-- W CAST
function Twitch:ComboW(target)
    if (not target) then
        return
    end
    if (not self:SaveEMana(self.w.mana)) then
        return
    end

    if (SDK.MenuManager.Menu.combo.wturret:get() and SDK.Utility:IsUnderTurret()) then
        return
    end

    local aaDamage = SDK.DamageLib:GetAutoAttackDamage(myHero, target)
    if (SDK.MenuManager.Menu.combo.waa:get() and
        ((aaDamage * SDK.MenuManager.Menu.combo.waa.value) >= target:GetRealHealth(SDK.DamageType.PHYSICAL))) then
        return
    end

    if (SDK.MenuManager.Menu.combo.wr:get() and self:IsRActive()) then
        return
    end

    self:CastW(target)
end

-- E CAST
function Twitch:CastE()
    myHero.spellbook:CastSpell(SpellSlot.E, myHero.networkId)
end

-------------------------------------------------------------------------------------------------------------------------------------
--                                                           Definitions                                                           --
-------------------------------------------------------------------------------------------------------------------------------------
function Twitch:IsRActive()
    return myHero.buffManager:HasBuff(0x936a439e)
end

function Twitch:SaveEMana(mana)
    if (not SDK.MenuManager.Menu.combo.emana:get()) then
        return true
    end
    local level = SDK.Utility:GetSpellLevel(SpellSlot.E)
    if (level == 0) then
        return true
    end
    local manaAfterCast = myHero.mana - mana
    local eCost = self.e.mana[level]
    return manaAfterCast >= eCost
end

-------------------------------------------------------------------------------------------------------------------------------------
--                                                             Damage                                                              --
-------------------------------------------------------------------------------------------------------------------------------------
function Twitch:GetEDamage(unit)
    local eLevel = SDK.Utility:GetSpellLevel(SpellSlot.E)
    if (eLevel == 0) then
        return 0
    end

    local stacks = SDK.Utility:GetBuffStacks(unit, "TwitchDeadlyVenom")
    if (stacks == 0) then
        return 0
    end

    local eBaseDamage = self.e.baseDamage[eLevel]

    local eStackDamage = self.e.stackDamage[eLevel] + (SDK.Utility:GetBonusAD() * 0.35)

    local adDamage = stacks * eStackDamage
    local apDamage = stacks * (SDK.Utility:GetTotalAP() * 0.35)

    local physicalDamage = eBaseDamage + adDamage

    local total = SDK.DamageLib:CalculateMixedDamage(myHero, unit, physicalDamage, apDamage)

    total = total * SDK.Utility:GetPTADamage(unit)
    total = total * SDK.Utility:GetPerkDamage(unit)

    local exhausted = SDK.Utility:HasExhaust()

    return exhausted and total * 0.6 or total
end

-------------------------------------------------------------------------------------------------------------------------------------
--                                                           Combo Logic                                                           --
-------------------------------------------------------------------------------------------------------------------------------------
function Twitch:ComboQ()
    if (SDK.MenuManager.Menu.combo.q.value == 2 and SDK.Utility:CanCastSpell(SpellSlot.Q)) then
        local castRange = SDK.MenuManager.Menu.combo.qrange.value
        local enemyCount = SDK.EntityManager:CountEnemiesInRange(castRange)
        if (enemyCount ~= 0) then
            self:CastQ()
        end
    end
end

function Twitch:HarassW()
    if not SDK.Utility:CanCastSpell(SpellSlot.W) then
        return
    end
    if (not SDK.MenuManager.Menu.harass.w:get()) then
        return
    end

    if (SDK.MenuManager.Menu.harass.mana.value >= myHero.manaPercent) then
        return
    end

    local wTargets, _ = SDK.MenuManager.TS:GetTargets(self.w, myHero, function(unit)
        return _G.Prediction.IsValidTarget(unit, self.w.range, myHero)
    end)
    local target = wTargets[1]
    if (target and SDK.Utility:IsValidTarget(target)) then
        self:CastW(target)
    end
end

function Twitch:QuickE(target)
    if (not SDK.MenuManager.Menu.combo.e:get() or not SDK.MenuManager.Menu.combo.eaa:get()) then
        return
    end

    if (SDK.MenuManager.Menu.combo.ewhitelist[target.charName] and
        SDK.MenuManager.Menu.combo.ewhitelist[target.charName]:get()) then
        local dmg = SDK.DamageLib:GetAutoAttackDamage(myHero, target) + self:GetEDamage(target)
        if SDK.Utility:IsValidTarget(target, self.e.range) and target:IsKillable(dmg) then
            self:CastE()
        end
    end
end

---@param enemy GameObject
function Twitch:KSE(enemy)
    if enemy == nil then
        return
    end

    if enemy.type == GameObjectType.AIHeroClient and SDK.MenuManager.Menu.combo.ewhitelist[enemy.charName] and
        not SDK.MenuManager.Menu.combo.ewhitelist[enemy.charName]:get() then
        return
    end

    if SDK.Utility:IsValidTarget(enemy, self.e.range) then
        if enemy:IsKillable(self:GetEDamage(enemy)) then
            self:CastE()
        end
    end
end

-------------------------------------------------------------------------------------------------------------------------------------
--                                                        Subscribed Events                                                        --
-------------------------------------------------------------------------------------------------------------------------------------
function Twitch:OnBasicAttack(source, spellInfo)
    if not SDK.UOL then
        return
    end

    if (source.charName ~= myHero.charName) then
        return
    end

    -- Combo
    if (SDK.UOL:GetMode() ~= "Combo") then
        return
    end

    local target = spellInfo.target
    if (not SDK.Utility:IsValidTarget(target, self.e.range)) then
        return
    end

    if (target.type ~= GameObjectType.AIHeroClient) then
        return
    end

    if (not spellInfo.isAutoAttack) then
        return
    end

    if (SDK.MenuManager.Menu.combo.q.value == 1) then
        self:CastQ()
    end
end

function Twitch:OnCreateObject(object, nId)
    if SDK.MenuManager.Menu.combo.multie:get() then
        return
    end

    if object and (object.name:find("TwitchBasicAttack") or object.name:find("TwitchSprayAndPrayAttack")) and
        object.asMissile.spellCaster.networkId == myHero.networkId and object.asMissile.target and
        object.asMissile.target.type == GameObjectType.AIHeroClient then
        self.AAs[object.networkId] = object.asMissile.target

        if (SDK.Utility:IsValidTarget(object.asMissile.target, self.e.range)) then
            self:QuickE(object.asMissile.target)
        end
    end
end

function Twitch:OnDeleteObject(object)
    local target = self.AAs[object.networkId]

    if (target and target.type == GameObjectType.AIHeroClient) then
        if (SDK.Utility:IsValidTarget(target, SDK.Utility:GetRange())) then
            if (SDK.UOL:GetMode() == "Combo") then
                if (SDK.MenuManager.Menu.combo.w.value == 1) then
                    self:ComboW(target)
                end
            end
        end
    end
end

function Twitch:OnTick()
    if not SDK.UOL then
        return
    end

    if (_G.myHero.isRecalling) then
        return
    end

    if SDK.MenuManager.Menu.combo.whk:get() and SDK.Utility:CanCastSpell(SpellSlot.W) then
        local w_targets, _ = SDK.MenuManager.TS:GetTargets(self.w, myHero)
        for i = 1, #w_targets do
            local unit = w_targets[i]
            if unit and SDK.Utility:IsValidTarget(unit, self.w.range) then
                self:CastW(unit)
            end
        end
    end

    if (SDK.MenuManager.Menu.stealthrecall:get() and SDK.Utility:CanCastSpell(SpellSlot.Q)) then
        myHero.spellbook:CastSpell(SpellSlot.Q, myHero.networkId)
        SDK.Utility:DelayAction(function()
            myHero.spellbook:CastSpell(SpellSlot.Recall, myHero.networkId)
        end, 0.15)
    end

    if (SDK.MenuManager.Menu.jungle.steal:get()) then
        for i, minion in pairs(SDK.EntityManager:GetDragonAndBaron({self.crab})) do
            if (SDK.MenuManager.Menu.jungle[i]:get()) then
                self:KSE(minion)
            end
        end
    end

    local killable = 0
    -- KS
    if (SDK.MenuManager.Menu.combo.e:get()) then
        local enemies = SDK.EntityManager:GetEnemiesWithBuff(self.e.range, 0x7f7378f4)
        local count = #enemies
        for _, enemy in pairs(enemies) do
            if SDK.MenuManager.Menu.combo.multie:get() then
                if enemy:IsKillable(self:GetEDamage(enemy)) and SDK.Utility:IsValidTarget(enemy, self.e.range) then
                    if count == 1 and SDK.MenuManager.Menu.combo.onevone:get() then
                        killable = 9999
                    else
                        killable = killable + 1
                    end
                end
            else
                self:KSE(enemy)
                local eStacks = SDK.MenuManager.Menu.combo.estacks
                if (eStacks:get()) then
                    local stacks = SDK.Utility:GetBuffStacks(enemy, "TwitchDeadlyVenom")
                    if (stacks >= eStacks.value) and SDK.Utility:IsValidTarget(enemy, self.e.range) then
                        self:CastE()
                    end
                end
            end
        end
    end

    if killable >= SDK.MenuManager.Menu.combo.multie.value then
        self:CastE()
    end

    -- Combo
    if (SDK.UOL:GetMode() == "Combo") then
        self:ComboQ()
    end

    if (SDK.UOL:GetMode() == "Harass") then
        self:HarassW()
    end
end

function Twitch:DrawPassiveTimer(unit, time)
    local text = "P: " .. tostring(math.ceil(time)) .. "/6"
    local pos = Renderer:WorldToScreen(unit.position)
    pos.x = pos.x + 30
    pos.y = pos.y - 40
    DrawHandler:Text(self.font, pos, text, SDK.Utility.Color.Green)
end

function Twitch:OnDraw()
    if (SDK.MenuManager.Menu.draw.range.qmap:get() and SDK.Utility:CanCastSpell(SpellSlot.Q)) then
        local spellLevel = SDK.Utility:GetSpellLevel(SpellSlot.Q) or 1
        local buffTime = self.q.duration[spellLevel]
        local radius = myHero.characterIntermediate.movementSpeed * buffTime
        SDK.Utility:DrawMinimapCircle(myHero.position, radius, SDK.MenuManager.Menu.draw.range.qcolor:get())
    end
    if (SDK.MenuManager.Menu.draw.range.q:get()) then
        if (not myHero.buffManager:HasBuff(0x39190976)) then
            DrawHandler:Circle3D(myHero.position, SDK.MenuManager.Menu.combo.qrange.value,
                SDK.MenuManager.Menu.draw.range.qcolor:get())
        else
            local buffTime = SDK.Utility:GetBuffTime(myHero, 0x39190976)
            local radius = myHero.characterIntermediate.movementSpeed * buffTime
            local pos = SDK.Utility:HeroVPos():extended(SDK.Utility:MousePos(), radius):toDX3()
            DrawHandler:Circle3D(myHero.position, radius, SDK.MenuManager.Menu.draw.range.qcolor:get())
            DrawHandler:Circle3D(pos, 50, SDK.MenuManager.Menu.draw.range.qcolor:get())
        end
    end

    if (SDK.MenuManager.Menu.draw.range.w:get() and SDK.Utility:CanCastSpell(SpellSlot.W)) then
        DrawHandler:Circle3D(myHero.position, self.w.range, SDK.Utility.Color.Green)
    end

    if (SDK.MenuManager.Menu.draw.range.e:get()) then
        DrawHandler:Circle3D(myHero.position, self.e.range, SDK.Utility.Color.Blue)
    end

    if (SDK.MenuManager.Menu.draw.range.r:get() and SDK.Utility:CanCastSpell(SpellSlot.R)) then
        DrawHandler:Circle3D(myHero.position,
            self.r.range + myHero.boundingRadius + myHero.characterIntermediate.attackRange, SDK.Utility.Color.Orange)
    end

    if (SDK.MenuManager.Menu.draw.damage.eminion:get()) then
        for _, minion in pairs(SDK.EntityManager:GetUnits(ObjectManager:GetEnemyMinions(), 2000)) do
            if (minion and minion.buffManager:HasBuff(0x7f7378f4)) then
                local damage = self:GetEDamage(minion)
                SDK.Utility:DrawMinionDamage(minion, damage)
            end
        end
    end

    for _, enemy in pairs(SDK.EntityManager:GetEnemies(2000)) do
        local damage = 0
        if (SDK.MenuManager.Menu.draw.damage.e:get() and SDK.Utility:CanCastSpell(SpellSlot.E)) then
            damage = damage + self:GetEDamage(enemy)
        end
        if (SDK.MenuManager.Menu.draw.damage.aa:get()) then
            damage = damage +
                         (SDK.DamageLib:GetAutoAttackDamage(myHero, enemy) * SDK.MenuManager.Menu.draw.damage.aa.value)
        end
        if (enemy) then
            SDK.Utility:DrawDamage(enemy, damage)
        end

        if SDK.MenuManager.Menu.draw.debug:get() then
            local buffs = enemy.buffManager.buffs
            local pos = Renderer:WorldToScreen(enemy.position)

            for _, buff in pairs(buffs) do
                if buff and buff.remainingTime > 0 then
                    local t = buff.name
                    if t then
                        DrawHandler:Text(self.font, pos, t .. " | " .. tostring(buff.type), SDK.Utility.Color.White)
                        -- pos.y = pos.y + 20
                    end
                end
            end
        end
    end

    local pos = Renderer:WorldToScreen(myHero.position)
    pos.x = pos.x - 40
    if SDK.MenuManager.Menu.draw.q:get() and myHero.buffManager:HasBuff(0x39190976) then
        local buffTime = SDK.Utility:GetBuffTime(myHero, 0x39190976)
        pos.y = pos.y + 30
        local text = "Q: " .. string.format("%.2f", buffTime) .. "/" ..
                         tostring(self.q.duration[SDK.Utility:GetSpellLevel(SpellSlot.Q)])
        DrawHandler:Text(self.font, pos, text, SDK.Utility.Color.White)
    end

    if SDK.MenuManager.Menu.draw.r:get() and self:IsRActive() then
        local buffTime = SDK.Utility:GetBuffTime(myHero, 0x936a439e)
        pos.y = pos.y + 30
        local text = "R: " .. string.format("%.2f", buffTime) .. "/6"
        DrawHandler:Text(self.font, pos, text, SDK.Utility.Color.White)
    end

    if SDK.MenuManager.Menu.draw.p:get() then
        for _, pair in pairs(self.buffs) do
            if pair.obj and pair.buff.remainingTime > 0.0 then
                self:DrawPassiveTimer(pair.obj, pair.buff.remainingTime)
            end
        end
    end
end

---@param source GameObject
---@param buff BuffInstance
function Twitch:OnBuffGain(source, buff)
    if source and source.team ~= myHero.team and source.type == GameObjectType.AIHeroClient then
        if buff.hash == 0x7f7378f4 then
            self.buffs[source.networkId] = {
                obj = source,
                buff = buff
            }
        end
    end
end

---@param source GameObject
---@param buff BuffInstance
function Twitch:OnBuffLost(source, buff)
    if source and source.team ~= myHero.team and source.type == GameObjectType.AIHeroClient then
        if buff.hash == 0x7f7378f4 then
            self.buffs[source.networkId] = nil
        end
    end
end

return Twitch
