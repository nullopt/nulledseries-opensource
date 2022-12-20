local Lulu = {
    q = {
        type = "linear",
        delay = 0.25,
        speed = 1500,
        width = 60,
        range = 925,
        collision = {
            ["Wall"] = true
        }
    },
    w = setmetatable({
        type = "targetted",
        delay = 0.245
    }, {
        __index = function(self, key)
            if key == "range" then
                return SDK.Utility:GetRange() + 30
            end
        end
    }),
    e = setmetatable({
        type = "targetted",
        delay = 0.245
    }, {
        __index = function(self, key)
            if key == "range" then
                return SDK.Utility:GetRange() + 30
            end
        end
    }),
    r = {
        type = "targetted",
        delay = 0.25,
        range = 900
    },
    pix = nil,
    kog = nil
}

-- q mana slider
--

function Lulu:__init()
    local currentScripters = {}
    for _, ally in pairs(SDK.EntityManager:GetAllies()) do
        if (SDK.Utility.scripterSpells[ally.charName]) then
            currentScripters[ally.charName] = true
        end
    end
    SDK.MenuManager.Menu:sub("scripter", "[=] Duo Scripter")
    SDK.MenuManager.Menu.scripter:checkbox("lt", "Buff [W/E] On Lethal Tempo", false)
    SDK.MenuManager.Menu.scripter:checkbox("lt_champ", "On Champions Atk Only", true)
    SDK.MenuManager.Menu.scripter:sub("spells", "[=] Spells")
    for champ, data in pairs(SDK.Utility.scripterSpells) do
        if (currentScripters[champ]) then
            SDK.MenuManager.Menu.scripter.spells:label("sep" .. champ, champ .. " spells", true, true)
            for spell, default in pairs(data) do
                SDK.MenuManager.Menu.scripter.spells:checkbox("w." .. spell, "[Use W] | " .. spell, false)
                SDK.MenuManager.Menu.scripter.spells:checkbox("e." .. spell, "[Use E] | " .. spell, default)
            end
        end
    end
    SDK.MenuManager.Menu.scripter:sub("buffs", "[=] Buffs")
    for champ, data in pairs(SDK.Utility.scripterBuffs) do
        if (currentScripters[champ]) then
            SDK.MenuManager.Menu.scripter.buffs:label("sep" .. champ, champ .. " buffs", true, true)
            for buff, default in pairs(data) do
                SDK.MenuManager.Menu.scripter.buffs:checkbox("w." .. buff, "[Use W] | " .. buff, false)
                SDK.MenuManager.Menu.scripter.buffs:checkbox("e." .. buff, "[Use E] | " .. buff, default)
            end
        end
    end
    SDK.MenuManager.Menu.scripter:slider("mana", "Mana Manager", 0, 100, 50, 5, true)

    SDK.MenuManager.Menu:sub("support", "[=] Support")
    -- SDK.MenuManager.Menu.support:checkbox("w", "Use W On Allies", true)
    -- SDK.MenuManager:CreateBoolWhiteList(SDK.MenuManager.Menu.support, "W", false)
    -- SDK.MenuManager.Menu.support:checkbox("e", "Use E On Allies", true)
    -- SDK.MenuManager:CreateBoolWhiteList(SDK.MenuManager.Menu.support, "E", true)
    -- SDK.MenuManager.Menu.support:label("sep0", "-", true, true)
    -- SDK.MenuManager.Menu.support:checkbox("eadc", "Only E Ally ADCs", false)
    SDK.MenuManager.Menu.support:label("sep0", "ADJUST THE WHITELIST FOR E, DISABLED BY DEFAULT", true, true)
    SDK.MenuManager:CreateAllyWhitelist(SDK.MenuManager.Menu.support, "Ally", false)
    SDK.MenuManager:CreateBoolWhiteList(SDK.MenuManager.Menu.support, "From", false)
    SDK.MenuManager.Menu.support:checkbox("e_dmg", "^ Use E On Allies Upcoming Dmg", true)
    SDK.MenuManager.Menu.support:key("buffally", "Buff [W/E] Closest Ally To Cursor", string.byte("G"))
    SDK.MenuManager:CreateAllyWhitelist(SDK.MenuManager.Menu.support, "Buff", false)
    SDK.MenuManager.Menu.support:checkbox("w", "^ Use W", false)
    SDK.MenuManager.Menu.support:checkbox("e", "^ Use E", true)
    SDK.MenuManager.Menu.support:checkbox("self", "^ Include Self?", false)
    SDK.MenuManager.Menu.support:key("rcast", "Use R On Closest Ally To Cursor", string.byte("T"))

    SDK.MenuManager.Menu:sub("combo", "[=] Combo")
    SDK.MenuManager.Menu.combo:checkbox("q", "Use Q [Automatically extended]", true)
    SDK.MenuManager.Menu.combo:slider("qmana", "^ Mana Manager", 0, 100, 40, 5, true)
    SDK.MenuManager.Menu.combo:checkbox("w", "Use W", true)
    SDK.MenuManager.Menu.combo:label("sep0", "ADJUST THE WHITELIST, DISABLED BY DEFAULT", true, true)
    SDK.MenuManager:CreateBoolWhiteList(SDK.MenuManager.Menu.combo, "W", false)
    SDK.MenuManager.Menu.combo:checkbox("e", "Use E", false)
    SDK.MenuManager:CreateBoolWhiteList(SDK.MenuManager.Menu.combo, "E", true)
    SDK.MenuManager.Menu.combo:slider("r", "Multi Knockup R on X Champs", 1, 5, 2, 1, true)

    SDK.MenuManager.Menu:sub("gap", "[=] Anti-Gapcloser")
    SDK.MenuManager.Menu.gap:checkbox("w", "Use W", true)
    SDK.MenuManager:CreateBoolWhiteList(SDK.MenuManager.Menu.gap, "W", true)
    SDK.MenuManager.Menu.gap:checkbox("r", "Use R", true)
    SDK.MenuManager:CreateBoolWhiteList(SDK.MenuManager.Menu.gap, "R", true)
    SDK.MenuManager:CreateAllyWhitelist(SDK.MenuManager.Menu.gap, "RAlly", true)

    SDK.MenuManager.Menu:sub("interrupter", "[=] Interrupter")
    SDK.MenuManager.Menu.interrupter:checkbox("w", "Use W", true)
    SDK.MenuManager:CreateBoolWhiteList(SDK.MenuManager.Menu.interrupter, "W", true)
    SDK.MenuManager.Menu.interrupter:checkbox("r", "Use R", true)
    SDK.MenuManager:CreateBoolWhiteList(SDK.MenuManager.Menu.interrupter, "R", true)

    SDK.MenuManager.Menu:sub("draw", "[=] Drawings")
    SDK.MenuManager.Menu.draw:checkbox("q", "Draw Q Range", true)

    SDK.MenuManager.Menu:sub("misc", "[=] Misc")
    SDK.MenuManager.Menu.misc:checkbox("disrespect", "Disrespect Enemies", true)

    AddEvent(Events.OnTick, function()
        self:OnTick()
    end)
    AddEvent(Events.OnDraw, function()
        self:OnDraw()
    end)
    AddEvent(Events.OnProcessSpell, function(...)
        self:OnProcessSpell(...)
    end)

    AddEvent(Events.OnCreateObject, function(...)
        self:OnCreateObject(...)
    end)

    AddEvent(Events.OnBasicAttack, function(...)
        self:OnBasicAttack(...)
    end)

    AddEvent(Events.OnBuffGain, function(...)
        self:OnBuffGain(...)
    end)

    SDK:Log("Loaded Lulu... finally - " .. GetUser())

    -- init pix
    --[[ for _, min in pairs(_G.ObjectManager:GetObjectsByType(_G.GameObjectType.obj_GeneralParticleEmitter)) do
        if (string.match(min.name, "Pix_idle_green")) then
            self.pix = min
        end
    end --]]
    self.pix = myHero.pet
end

function Lulu:CastQ(position)
    myHero.spellbook:CastSpell(SpellSlot.Q, position)
end

function Lulu:CastW(unit)
    myHero.spellbook:CastSpell(SpellSlot.W, unit.networkId)
end

function Lulu:CastE(unit)
    myHero.spellbook:CastSpell(SpellSlot.E, unit.networkId)
end

function Lulu:CastR(unit)
    myHero.spellbook:CastSpell(SpellSlot.R, unit.networkId)
end

function Lulu:ComboQ()
    local q_targets, q_preds = SDK.MenuManager.TS:GetTargets(self.q, self.pix)
    for i = 1, #q_targets do
        local unit = q_targets[i]
        local pred = q_preds[unit.networkId]

        if (pred and pred.rates["slow"] and SDK.Vector(self.pix.position):dist(SDK.Vector(pred.castPosition)) <
            self.q.range) then
            self:CastQ(pred.castPosition)
        end
    end
end

-- TODO: Clean this shit up later
function Lulu:BuffBuffs()
    if (SDK.MenuManager.Menu.scripter.mana:get() and _G.myHero.manaPercent < SDK.MenuManager.Menu.scripter.mana.value) then
        return
    end
    for _, ally in pairs(SDK.EntityManager:GetAllies(self.e.range)) do
        local ltBuff = SDK.Utility:HasLT(ally)
        if (ltBuff and ltBuff.count == 6 and SDK.MenuManager.Menu.scripter.lt:get()) then
            if (SDK.MenuManager.Menu.scripter.lt_champ:get() and SDK.Utility:AutoAttackTargetType(ally) ==
                GameObjectType.AIHeroClient) then
                if (SDK.Utility:CanCastSpell(SpellSlot.W) and SDK.Utility:IsValidTarget(ally, self.w.range)) then
                    self:CastW(ally)
                end
                if (SDK.Utility:CanCastSpell(SpellSlot.E) and SDK.Utility:IsValidTarget(ally, self.e.range)) then
                    self:CastE(ally)
                end
            elseif (not SDK.MenuManager.Menu.scripter.lt_champ:get()) then
                if (SDK.Utility:CanCastSpell(SpellSlot.W) and SDK.Utility:IsValidTarget(ally, self.w.range)) then
                    self:CastW(ally)
                end
                if (SDK.Utility:CanCastSpell(SpellSlot.E) and SDK.Utility:IsValidTarget(ally, self.e.range)) then
                    self:CastE(ally)
                end
            end
        end
        for _, buff in pairs(ally.buffManager.buffs) do
            -- check if buff exists in table
            if (SDK.Utility.scripterBuffs[ally.charName]) then
                if (SDK.Utility.scripterBuffs[ally.charName][buff.name]) then
                    -- cast w on buff
                    if (SDK.MenuManager.Menu.scripter.buffs["w." .. buff.name]:get()) then
                        if (SDK.Utility:CanCastSpell(SpellSlot.W) and SDK.Utility:IsValidTarget(ally, self.w.range)) then
                            self:CastW(ally)
                        end
                    end
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

function Lulu:MultiKnockUp()
    if (not SDK.MenuManager.Menu.combo.r:get()) then
        return
    end

    if (not SDK.Utility:CanCastSpell(SpellSlot.R)) then
        return
    end

    local enemiesHit = 0
    local bestAlly = {}
    for _, ally in pairs(SDK.EntityManager:GetAllies(self.r.range, myHero)) do
        if (SDK.Utility:IsValidTarget(ally, self.r.range)) then
            local hit = SDK.EntityManager:CountEnemiesInRange(300, ally)
            if (hit > enemiesHit) then
                enemiesHit = hit
                bestAlly = ally
            end
        end
    end
    if (bestAlly and SDK.Utility:IsValidTarget(bestAlly, self.r.range) and enemiesHit >=
        SDK.MenuManager.Menu.combo.r.value) then
        self:CastR(bestAlly)
    end
end

function Lulu:OnTick()
    self:BuffBuffs()

    self:MultiKnockUp()

    -- w antigapcloser
    local w_targets, w_preds = SDK.MenuManager.TS:GetTargets(self.w, myHero, function(unit)
        return SDK.Utility:IsValidTarget(unit, self.w.range)
    end)
    for _, target in pairs(w_targets) do
        local pred = w_preds[target.networkId]
        if (pred and pred.targetDashing) then
            local useW = SDK.MenuManager.Menu.gap.w:get()
            local shouldWEnemy = SDK.MenuManager.Menu.gap.wwhitelist[target.charName]:get()
            if (useW and shouldWEnemy and SDK.Utility:HeroVPos():dist(SDK.Vector(pred.castPosition)) < 400 and
                SDK.Utility:CanCastSpell(SpellSlot.W)) then
                if SDK.MenuManager.Menu.misc.disrespect:get() then
                    MenuGUI:SendChat("/l")
                end
                self:CastW(target)
            end
        end
        if (pred and pred.isInterrupt) then
            local useW = SDK.MenuManager.Menu.interrupter.w:get()
            local shouldWEnemy = SDK.MenuManager.Menu.interrupter.wwhitelist[target.charName]:get()
            if (useW and shouldWEnemy and SDK.Utility:HeroVPos():dist(SDK.Vector(pred.castPosition)) < 400 and
                SDK.Utility:CanCastSpell(SpellSlot.W)) then
                if SDK.MenuManager.Menu.misc.disrespect:get() then
                    MenuGUI:SendChat("/l")
                end
                self:CastW(target)
            end
        end
    end

    -- TODO:
    -- -- r antigapcloser
    local r_targets, r_preds = SDK.MenuManager.TS:GetTargets(self.r, myHero, function(unit)
        return SDK.Utility:IsValidTarget(unit, self.r.range)
    end)
    for _, target in pairs(r_targets) do
        local pred = r_preds[target.networkId]
        if (pred and pred.targetDashing) then
            local useR = SDK.MenuManager.Menu.gap.r:get()
            local shouldREnemy = SDK.MenuManager.Menu.gap.rwhitelist[target.charName]:get()
            local alliesNearPos = SDK.EntityManager:GetAlliesNearPos(300, pred.targetPosition)
            if (useR and shouldREnemy and #alliesNearPos >= 1 and SDK.Utility:CanCastSpell(SpellSlot.R)) then
                local hp = 10000
                local bestAlly = {}
                for _, ally in pairs(alliesNearPos) do
                    if (ally.health < hp and SDK.MenuManager.Menu.gap.rallywhitelist[ally.charName]:get() and
                        SDK.Utility:IsValidTarget(ally, self.r.range)) then
                        hp = ally.health
                        bestAlly = ally
                    end
                end
                if (bestAlly and SDK.Utility:IsValidTarget(bestAlly, self.r.range)) then
                    self:CastR(bestAlly)
                end
            end
        end
    end

    -- Buff [W/E] Closest Ally To Cursor
    if (SDK.MenuManager.Menu.support.buffally:get()) then
        local closest = self:GetClosestToCursor(self.e.range)
        if (closest and SDK.Utility:IsValidTarget(closest, self.e.range)) then
            if (SDK.Utility:CanCastSpell(SpellSlot.E) and SDK.MenuManager.Menu.support.e:get()) then
                self:CastE(closest)
                return
            end

            if (SDK.Utility:CanCastSpell(SpellSlot.W) and SDK.MenuManager.Menu.support.w:get()) then
                self:CastW(closest)
                return
            end
        end
    end

    if (SDK.MenuManager.Menu.support.rcast:get()) then
        local closest = self:GetClosestToCursor(self.r.range)
        if (closest and SDK.Utility:IsValidTarget(closest, self.r.range)) then
            if (SDK.Utility:CanCastSpell(SpellSlot.R)) then
                self:CastR(closest)
                return
            end
        end
    end

    if not SDK.UOL then
        return
    end

    if (SDK.UOL:GetMode() == "Combo") then
        if (SDK.MenuManager.Menu.combo.q:get()) then
            if (SDK.Utility:CanCastSpell(SpellSlot.Q)) then
                if (SDK.MenuManager.Menu.combo.qmana:get()) then
                    if (SDK.MenuManager.Menu.combo.qmana.value < myHero.manaPercent) then
                        self:ComboQ()
                    end
                else
                    self:ComboQ()
                end
            end
        end
        -- TODO: for loop for w and e
        if (SDK.MenuManager.Menu.combo.w:get()) then
            if (SDK.Utility:CanCastSpell(SpellSlot.W)) then
                local w_targets, _ = SDK.MenuManager.TS:GetTargets(self.w, myHero)
                for i = 1, #w_targets do
                    local unit = w_targets[i]
                    if (SDK.MenuManager.Menu.combo.wwhitelist[unit.charName]:get()) then
                        if (SDK.Utility:IsValidTarget(unit, self.w.range)) then
                            self:CastW(unit)
                            return
                        end
                    end
                end
            end
        end

        if (SDK.MenuManager.Menu.combo.e:get()) then
            if (SDK.Utility:CanCastSpell(SpellSlot.E)) then
                local e_targets, _ = SDK.MenuManager.TS:GetTargets(self.e, myHero)
                for i = 1, #e_targets do
                    local unit = e_targets[i]
                    if (SDK.MenuManager.Menu.combo.ewhitelist[unit.charName]:get()) then
                        if (SDK.Utility:IsValidTarget(unit, self.e.range)) then
                            self:CastE(unit)
                            return
                        end
                    end
                end
            end
        end
    end
end

function Lulu:GetClosestToCursor(range, includeSelf)
    local dist = 10000
    local closest = nil
    for _, ally in pairs(SDK.EntityManager:GetAllies(range, myHero)) do
        if (not includeSelf and ally.networkId == myHero.networkId) then
            goto continue
        end

        if (not SDK.MenuManager.Menu.support.buffwhitelist[ally.charName]:get()) then
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

function Lulu:OnDraw()
    if (SDK.Utility:CanCastSpell(SpellSlot.Q) and SDK.MenuManager.Menu.draw.q:get()) then
        DrawHandler:Circle3D(myHero.position, self.q.range, SDK.Utility.Color.Green)
        if (self.pix) then
            DrawHandler:Circle3D(self.pix.position, 30, SDK.Utility.Color.Green)
            DrawHandler:Circle3D(self.pix.position, self.q.range, SDK.Utility.Color.Green)
        end
    end
end

function Lulu:OnProcessSpell(source, spellInfo)
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

    if (SDK.MenuManager.Menu.scripter.spells["w." .. spell.name]:get()) then
        self:CastW(source)
    end
end

function Lulu:OnCreateObject(obj, netid)
    if (obj.type ~= GameObjectType.MissileClient) then
        return
    end

    if (not SDK.MenuManager.Menu.support.e_dmg:get()) then
        return
    end

    local allyTarget = obj.asMissile.spellCastInfo.target
    local attacker = obj.asMissile.spellCaster

    if (allyTarget and allyTarget.team == myHero.team and allyTarget.type == GameObjectType.AIHeroClient and attacker and
        attacker.team ~= myHero.team and attacker.type == GameObjectType.AIHeroClient) then
        local shouldEAlly = (SDK.MenuManager.Menu.support.allywhitelist[allyTarget.charName]:get() and
                                SDK.MenuManager.Menu.support.fromwhitelist[attacker.charName]:get())

        if (shouldEAlly and attacker ~= nil and attacker.type == GameObjectType.AIHeroClient and
            SDK.Utility:IsValidTarget(allyTarget, self.e.range)) then
            self:CastE(allyTarget)
        end
    end
end

function Lulu:OnBasicAttack(source, spellInfo)
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
        local shouldEAlly = (SDK.MenuManager.Menu.support.allywhitelist[allyTarget.charName]:get() and
                                (source.type == GameObjectType.obj_AI_Turret or
                                    SDK.MenuManager.Menu.support.fromwhitelist[attacker.charName]:get()))

        if (shouldEAlly and attacker ~= nil and SDK.Utility:IsValidTarget(allyTarget, self.e.range)) then
            self:CastE(allyTarget)
        end
    end
end

function Lulu:OnBuffGain(obj, buff)
    if not SDK.MenuManager.Menu.misc.disrespect:get() then
        return
    end

    if (obj.team ~= myHero.team) then
        return
    end

    if (buff.hash ~= 0x32c50fa4) then
        return
    end

    MenuGUI:SendChat("/l")
end

return Lulu
