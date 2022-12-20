local Janna = {
    q = {
        type = "linear",
        delay = 0,
        width = 200,
        speed = 910,
        range = 1000,
        maxrange = 1750,
        chargetime = 3000
    },
    w = setmetatable(
        {
            type = "targetted",
            delay = 0.245
        },
        {
            __index = function(self, key)
                if key == "range" then
                    return SDK.Utility:GetRange() + 30
                end
            end
        }
    ),
    e = {
        type = "targetted",
        range = 700
    },
    r = {}
}

function Janna:__init()
    local currentScripters = {}
    for _, ally in pairs(SDK.EntityManager:GetAllies()) do
        if (SDK.Utility.scripterSpells[ally.charName]) then
            currentScripters[ally.charName] = true
        end
    end
    SDK.MenuManager.Menu:sub("scripter", "[=] Duo Scripter")
    SDK.MenuManager.Menu.scripter:checkbox("lt", "Buff [E] On Lethal Tempo", false)
    SDK.MenuManager.Menu.scripter:checkbox("lt_champ", "On Champions Atk Only", true)
    SDK.MenuManager.Menu.scripter:sub("spells", "[=] Spells")
    for champ, data in pairs(SDK.Utility.scripterSpells) do
        if (currentScripters[champ]) then
            SDK.MenuManager.Menu.scripter.spells:label("sep" .. champ, champ .. " spells", true, true)
            for spell, default in pairs(data) do
                SDK.MenuManager.Menu.scripter.spells:checkbox("e." .. spell, "[Use E] | " .. spell, default)
            end
        end
    end
    SDK.MenuManager.Menu.scripter:sub("buffs", "[=] Buffs")
    for champ, data in pairs(SDK.Utility.scripterBuffs) do
        if (currentScripters[champ]) then
            SDK.MenuManager.Menu.scripter.buffs:label("sep" .. champ, champ .. " buffs", true, true)
            for buff, default in pairs(data) do
                SDK.MenuManager.Menu.scripter.buffs:checkbox("e." .. buff, "[Use E] | " .. buff, default)
            end
        end
    end
    SDK.MenuManager.Menu.scripter:slider("mana", "Mana Manager", 0, 100, 50, 5, true)

    SDK.MenuManager.Menu:sub("support", "[=] Support")
    SDK.MenuManager.Menu.support:label("sep0", "ADJUST THE WHITELIST FOR E, DISABLED BY DEFAULT", true, true)
    SDK.MenuManager:CreateAllyWhitelist(SDK.MenuManager.Menu.support, "Ally", false)
    SDK.MenuManager:CreateBoolWhiteList(SDK.MenuManager.Menu.support, "From", false)
    SDK.MenuManager.Menu.support:checkbox("e_dmg", "^ Use E On Allies Upcoming Dmg", true)
    SDK.MenuManager.Menu.support:key("buffally", "Buff [E] Closest Ally To Cursor", string.byte("G"))

    SDK.MenuManager.Menu:sub("combo", "[=] Combo")
    SDK.MenuManager.Menu.combo:checkbox("q", "Use Q", true)
    SDK.MenuManager.Menu.combo:checkbox("w", "Use W", true)

    SDK.MenuManager.Menu:sub("gap", "[=] Anti-Gapcloser")
    SDK.MenuManager.Menu.gap:checkbox("q", "Use Q", true)
    SDK.MenuManager:CreateBoolWhiteList(SDK.MenuManager.Menu.gap, "Q", true)
    SDK.MenuManager.Menu.gap:checkbox("r", "Use R", true)
    SDK.MenuManager:CreateBoolWhiteList(SDK.MenuManager.Menu.gap, "R", false)

    SDK.MenuManager.Menu:sub("interrupter", "[=] Interrupter")
    SDK.MenuManager.Menu.interrupter:checkbox("q", "Use Q", true)
    SDK.MenuManager:CreateBoolWhiteList(SDK.MenuManager.Menu.interrupter, "Q", true)
    SDK.MenuManager.Menu.interrupter:checkbox("r", "Use R", true)
    SDK.MenuManager:CreateBoolWhiteList(SDK.MenuManager.Menu.interrupter, "R", false)

    AddEvent(
        Events.OnTick,
        function()
            self:OnTick()
        end
    )

    AddEvent(
        Events.OnProcessSpell,
        function(...)
            self:OnProcessSpell(...)
        end
    )

    AddEvent(
        Events.OnCreateObject,
        function(...)
            self:OnCreateObject(...)
        end
    )

    AddEvent(
        Events.OnBasicAttack,
        function(...)
            self:OnBasicAttack(...)
        end
    )

    SDK:Log("Loaded Janna - " .. GetUser())
end

function Janna:CastQ(pos)
    myHero.spellbook:CastSpell(SpellSlot.Q, pos)
end

function Janna:CastW(unit)
    myHero.spellbook:CastSpell(SpellSlot.W, unit.networkId)
end

function Janna:CastE(unit)
    myHero.spellbook:CastSpell(SpellSlot.E, unit.networkId)
end

function Janna:ComboQ()
    if SDK.Utility:CanCastSpell(SpellSlot.Q) and SDK.MenuManager.Menu.combo.q:get() then
        local q_targets, q_preds =
            SDK.MenuManager.TS:GetTargets(
            self.q,
            myHero,
            function(unit)
                return SDK.Utility:IsValidTarget(unit, self.q.range)
            end
        )
        for i = 1, #q_targets do
            local unit = q_targets[i]
            local pred = q_preds[unit.networkId]

            if (pred and pred.rates["slow"]) then
                self:CastQ(pred.castPosition)
            end
        end
    end
end

function Janna:ComboW()
    if (not SDK.MenuManager.Menu.combo.w:get()) then
        return
    end
    if (not SDK.Utility:CanCastSpell(SpellSlot.W)) then
        return
    end
    local wTargets, _ =
        SDK.MenuManager.TS:GetTargets(
        self.w,
        myHero,
        function(unit)
            return _G.Prediction.IsValidTarget(unit, self.w.range, myHero)
        end
    )
    local wTarget = wTargets[1]

    if (not wTarget) then
        return
    end
    if (not SDK.Utility:IsValidTarget(wTarget, self.w.range)) then
        return
    end
    self:CastW(wTarget)
end

function Janna:BuffBuffs()
    if (SDK.MenuManager.Menu.scripter.mana:get() and _G.myHero.manaPercent < SDK.MenuManager.Menu.scripter.mana.value) then
        return
    end
    for _, ally in pairs(SDK.EntityManager:GetAllies(self.e.range)) do
        if (SDK.Utility:HasLT(ally) and SDK.MenuManager.Menu.scripter.lt:get()) then
            if
                (SDK.MenuManager.Menu.scripter.lt_champ:get() and
                    SDK.Utility:AutoAttackTargetType(ally) == GameObjectType.AIHeroClient)
             then
                if (SDK.Utility:CanCastSpell(SpellSlot.E) and SDK.Utility:IsValidTarget(ally, self.e.range)) then
                    self:CastE(ally)
                end
            elseif (not SDK.MenuManager.Menu.scripter.lt_champ:get()) then
                if (SDK.Utility:CanCastSpell(SpellSlot.E) and SDK.Utility:IsValidTarget(ally, self.e.range)) then
                    self:CastE(ally)
                end
            end
        end
        for _, buff in pairs(ally.buffManager.buffs) do
            -- check if buff exists in table
            if (SDK.Utility.scripterBuffs[ally.charName]) then
                if (SDK.Utility.scripterBuffs[ally.charName][buff.name]) then
                    -- cast e on buff
                    if (SDK.MenuManager.Menu.scripter.buffs["e." .. buff.name]:get()) then
                        if (SDK.Utility:CanCastSpell(SpellSlot.E) and SDK.Utility:IsValidTarget(ally, self.e.range)) then
                            self:CastE(ally)
                        end
                    end
                end
            end
        end
    end
end

function Janna:AntiGapcloser()
    if SDK.Utility:CanCastSpell(SpellSlot.Q) then
        local q_targets, q_preds =
            SDK.MenuManager.TS:GetTargets(
            self.q,
            myHero,
            function(unit)
                return SDK.Utility:IsValidTarget(unit, self.q.range)
            end
        )

        for i = 1, #q_targets do
            local unit = q_targets[i]
            local pred = q_preds[unit.networkId]

            if pred then
                if pred.targetDashing and SDK.MenuManager.Menu.gap.q:get() then
                    if pred.rates["slow"] and SDK.MenuManager.Menu.gap.qwhitelist[unit.charName]:get() then
                        self:CastQ(pred.position)
                    end
                end

                if pred.isInterrupt and SDK.MenuManager.Menu.interrupter.q:get() then
                    if pred.rates["slow"] and SDK.MenuManager.Menu.interrupter.qwhitelist[unit.charName]:get() then
                        self:CastQ(pred.position)
                    end
                end
            end
        end
    end
end

function Janna:OnTick()
    if not SDK.UOL then
        return
    end

    self:BuffBuffs()

    self:AntiGapcloser()

    if (SDK.UOL:GetMode() == "Combo") then
        self:ComboQ()
        self:ComboW()
    end

	if (SDK.MenuManager.Menu.support.buffally:get()) then
        local closest = self:GetClosestToCursor(self.e.range)
        if closest and SDK.Utility:IsValidTarget(closest, self.e.range) then
            if SDK.Utility:CanCastSpell(SpellSlot.E) then
                self:CastE(closest)
                return
            end
        end
    end
end

function Janna:GetClosestToCursor(range, includeSelf)
    local dist = 10000
    local closest = nil
    for _, ally in pairs(SDK.EntityManager:GetAllies(range, myHero)) do
        if (not includeSelf and ally.networkId == myHero.networkId) then
            goto continue
        end

        if (not SDK.MenuManager.Menu.support.allywhitelist[ally.charName]:get()) then
            goto continue
        end

        if (SDK.Utility:IsValidTarget(ally, range)) then
            local d = SDK.Utility:MousePos():dist(SDK.Vector(ally.position))
            if (d < dist) then
                dist = d
                closest = ally
            end
        end
        ::continue::
    end
    return closest
end

function Janna:OnProcessSpell(source, spellInfo)
    if (source.team ~= myHero.team or source.networkId == myHero.networkId) then
        return
    end

    local spell = spellInfo.spellData
    local scripter = SDK.Utility.scripterSpells[source.charName]
    if (scripter == nil) then
        return
    end

    if (scripter[spell.name] == nil) then
        return
    end

    if (SDK.MenuManager.Menu.scripter.mana:get() and _G.myHero.manaPercent < SDK.MenuManager.Menu.scripter.mana.value) then
        return
    end

    if (SDK.Utility:HeroVPos():dist(SDK.Vector(source.position)) > self.e.range) then
        return
    end

    if (SDK.MenuManager.Menu.scripter.spells["e." .. spell.name]:get()) then
        self:CastE(source)
    end
end

function Janna:OnCreateObject(obj, netid)
    if (obj.type ~= GameObjectType.MissileClient) then
        return
    end

    if (not SDK.MenuManager.Menu.support.e_dmg:get()) then
        return
    end

    local allyTarget = obj.asMissile.spellCastInfo.target
    local attacker = obj.asMissile.spellCaster

    if
        (allyTarget and allyTarget.team == myHero.team and allyTarget.type == GameObjectType.AIHeroClient and attacker and
            attacker.team ~= myHero.team and
            attacker.type == GameObjectType.AIHeroClient)
     then
        local shouldEAlly =
            (SDK.MenuManager.Menu.support.allywhitelist[allyTarget.charName]:get() and
            SDK.MenuManager.Menu.support.fromwhitelist[attacker.charName]:get())

        if
            (shouldEAlly and attacker ~= nil and attacker.type == GameObjectType.AIHeroClient and
                SDK.Utility:IsValidTarget(allyTarget, self.e.range))
         then
            self:CastE(allyTarget)
        end
    end
end

function Janna:OnBasicAttack(source, spellInfo)
    if (source.team == myHero.team) then
        return
    end

    if (source.type ~= GameObjectType.AIHeroClient and source.type ~= GameObjectType.obj_AI_Turret) then
        return
    end

    if (not SDK.MenuManager.Menu.support.e_dmg:get()) then
        return
    end

    local allyTarget = spellInfo.target

    if (allyTarget and allyTarget.team == myHero.team and allyTarget.type == GameObjectType.AIHeroClient) then
        local attacker = source
        local shouldEAlly =
            (SDK.MenuManager.Menu.support.allywhitelist[allyTarget.charName]:get() and
            (source.type == GameObjectType.obj_AI_Turret or
                SDK.MenuManager.Menu.support.fromwhitelist[attacker.charName]:get()))

        if (shouldEAlly and attacker ~= nil and SDK.Utility:IsValidTarget(allyTarget, self.e.range)) then
            self:CastE(allyTarget)
        end
    end
end

return Janna
