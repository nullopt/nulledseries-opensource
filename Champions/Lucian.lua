local qDelay = {
    0.40000000596046,
    0.38999998569489,
    0.37999999523163,
    0.37999999523163,
    0.36000001430511,
    0.36000001430511,
    0.34000000357628,
    0.33000001311302,
    0.31999999284744,
    0.31000000238419,
    0.30000001192093,
    0.28999999165535,
    0.28000000119209,
    0.27000001072884,
    0.27000001072884,
    0.25999999046326,
    0.25,
    0.25
}

local Lucian = {
    -- setup spells
    q = setmetatable(
        {
            slot = SpellSlot.Q,
            type = "linear",
            speed = math.huge,
            width = 65,
            baseDamage = {95, 130, 165, 200, 235},
            multiplier = {0.60, 0.75, 0.90, 1.05, 1.20}
        },
        {
            __index = function(self, key)
                if (key == "delay") then
                    return qDelay[math.min(myHero.experience.level, 18)]
                end
                if (key == "range") then
                    return 550 + myHero.boundingRadius
                end
            end
        }
    ),
    extendedQ = setmetatable(
        {
            slot = SpellSlot.Q,
            type = "linear",
            speed = math.huge,
            range = 900,
            width = 65,
            baseDamage = {95, 130, 165, 200, 235},
            multiplier = {0.60, 0.75, 0.90, 1.05, 1.20}
        },
        {
            __index = function(self, key)
                if (key == "delay") then
                    return qDelay[math.min(myHero.experience.level, 18)]
                end
            end
        }
    ),
    w = {
        slot = SpellSlot.W,
        type = "linear",
        speed = 1600,
        range = 900,
        delay = 0.25,
        width = 100,
        baseDamage = {75, 110, 145, 180, 215}
    },
    e = {
        slot = SpellSlot.E,
        type = "linear",
        range = 440,
        lastFailure = ""
    },
    r = {
        range = 1200
    },
    lastCast = 0,
    eModes = {"Dynamic Range", "Always Short", "Always Long", "Don't use E"}
}

-------------------------------------------------------------------------------------------------------------------------------------
--                                                         Initialization                                                          --
-------------------------------------------------------------------------------------------------------------------------------------
function Lucian:__init()
    -- GENERATE MENU

    -- Combo Menu
    SDK.MenuManager.Menu:sub("combo", "[=] Combo")
    -- SDK.MenuManager.Menu.combo:list("mode", "Combo Mode", 1, self.comboModes)
    SDK.MenuManager.Menu.combo:label("sep0", "Q Settings", true, true)
    SDK.MenuManager.Menu.combo:checkbox("q", "Use Q", true)
    SDK.MenuManager.Menu.combo:checkbox("extendedq", "Use Extended Q (OnTick)", true)
    SDK.MenuManager.Menu.combo:label("sep1", "W Settings", true, true)
    SDK.MenuManager.Menu.combo:checkbox("w", "Use W", true)
    SDK.MenuManager.Menu.combo:checkbox("smartw", "Ignore collion if target is in AA range", true)
    SDK.MenuManager.Menu.combo:label("sep2", "E Settings", true, true)
    SDK.MenuManager.Menu.combo:checkbox("e", "Use E", true)
    SDK.MenuManager.Menu.combo:list("emode", "E Mode", 1, self.eModes)
    SDK.MenuManager.Menu.combo:checkbox("onlyifmouseoutaarange", "Only E if mouse out of self AA range", false)
    -- SDK.MenuManager.Menu.combo:checkbox("stayinrange", "Stay in AA range to target [WIP]", false)
    SDK.MenuManager.Menu.combo:checkbox("turretcheck", "Don't E under turret", true)
    SDK.MenuManager.Menu.combo:checkbox("prioritizee", "Prioritize E for mobility", false)
    SDK.MenuManager.Menu.combo:label("sep3", "Weaving", true, true)
    SDK.MenuManager.Menu.combo:checkbox("weave", "Include manually used abilities in weave", true)

    -- Harass Menu
    SDK.MenuManager.Menu:sub("harass", "[=] Harass")
    SDK.MenuManager.Menu.harass:label("sep0", "Q Settings", true, true)
    SDK.MenuManager.Menu.harass:checkbox("q", "Use Q", true)
    SDK.MenuManager.Menu.harass:label("sep1", "Extended Q Settings", true, true)
    SDK.MenuManager.Menu.harass:checkbox("extendedq", "Use Extended Q", true)
    SDK.MenuManager.Menu.harass:checkbox("autoq", "Auto Cast", true)
    SDK.MenuManager.Menu.harass:label("sep2", "W Settings", true, true)
    SDK.MenuManager.Menu.harass:checkbox("w", "Use W", true)
    SDK.MenuManager.Menu.harass:label("sep3", "Mana Settings", true, true)
    SDK.MenuManager.Menu.harass:slider("mana", "Min. Mana %", 0, 100, 50, 1, true)

    -- Killsteal Menu
    SDK.MenuManager.Menu:sub("ks", "[=] Killsteal")
    SDK.MenuManager.Menu.ks:checkbox("q", "Use Q", true)
    SDK.MenuManager.Menu.ks:checkbox("w", "Use W", true)

    -- Draw Menu
    SDK.MenuManager.Menu:sub("draw", "[=] Drawings")
    SDK.MenuManager.Menu.draw:checkbox("emode", "Draw E Mode", true)
    SDK.MenuManager.Menu.draw:sub("range", "[=] Range")
    SDK.MenuManager.Menu.draw.range:checkbox("q", "Draw Q", true)
    SDK.MenuManager.Menu.draw.range:checkbox("w", "Draw W", true)
    SDK.MenuManager.Menu.draw.range:checkbox("e", "Draw E", true)
    SDK.MenuManager.Menu.draw.range:checkbox("r", "Draw R", true)
    SDK.MenuManager.Menu.draw:sub("damage", "[=] Damage")
    SDK.MenuManager.Menu.draw.damage:checkbox("damage", "Draw Damage", true)
    SDK.MenuManager.Menu.draw.damage:label("sep0", "Q Damage", true, true)
    SDK.MenuManager.Menu.draw.damage:checkbox("q", "Include Q", true)
    SDK.MenuManager.Menu.draw.damage:label("sep1", "W Damage", true, true)
    SDK.MenuManager.Menu.draw.damage:checkbox("w", "Include W", true)
    SDK.MenuManager.Menu.draw.damage:label("sep3", "Auto Attack Damage", true, true)
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
        Events.OnProcessSpell,
        function(...)
            self:OnProcessSpell(...)
        end
    )
    AddEvent(
        Events.OnExecuteCastFrame,
        function(...)
            self:OnExecuteCastFrame(...)
        end
    )

    self.font = DrawHandler:CreateFont("consolas", 13)
    SDK.Utility:DebugChat("Loaded Lucian.", "#00ff00")
end

-------------------------------------------------------------------------------------------------------------------------------------
--                                                             Spells                                                              --
-------------------------------------------------------------------------------------------------------------------------------------
function Lucian:CastQ(target)
    if (SDK.Utility:HeroVPos():dist(SDK.Vector(target.position)) < self.q.range) then
        if (SDK.Utility:IsValidTarget(target, self.q.range)) then
            myHero.spellbook:CastSpell(self.q.slot, target.networkId)
        end
    end

    if (SDK.Utility:IsValidTarget(target, self.extendedQ.range)) then
        Lucian:__CastExtendedQ(target)
    end
end

function Lucian:__CastExtendedQ(target)
    local pred = _G.Prediction.GetPrediction(target, self.extendedQ, myHero)
    if (pred and pred.castPosition) then
        pred:draw()
        local extendedTargetPos = SDK.Utility:HeroVPos():extended(SDK.Vector(pred.castPosition), self.extendedQ.range)
        for _, minion in pairs(ObjectManager:GetEnemyMinions()) do
            local minPos = SDK.Utility:HeroVPos():extended(SDK.Vector(minion.position), self.extendedQ.range)
            if
                (extendedTargetPos:dist(minPos) <= self.extendedQ.width + (target.boundingRadius * 0.5) and
                    SDK.Utility:HeroVPos():dist(minion.position) < self.q.range)
             then
                myHero.spellbook:CastSpell(self.extendedQ.slot, minion.networkId)
            end
        end
    end

    -- if all else fails, just cast q on target
    if (SDK.Utility:IsValidTarget(target, self.q.range)) then
        myHero.spellbook:CastSpell(self.q.slot, target.networkId)
    end
end

function Lucian:CastW(target)
    if (not SDK.Utility:IsValidTarget(target, self.w.range)) then
        return
    end

    local pred = _G.Prediction.GetPrediction(target, self.w, myHero)
    if (pred and pred.castPosition and SDK.Utility:HeroVPos():dist(SDK.Vector(pred.castPosition)) < self.w.range) then
        if (not pred:windWallCollision()) then
            if (pred:minionCollision()) then
                if
                    (SDK.Utility:HeroVPos():dist(SDK.Vector(target.positon)) < myHero.characterIntermediate.attackRange and
                        SDK.MenuManager.Menu.combo.smartw:get())
                 then
                    myHero.spellbook:CastSpell(SpellSlot.W, pred.castPosition)
                end
            else
                myHero.spellbook:CastSpell(SpellSlot.W, pred.castPosition)
            end
        end
    end
end

function Lucian:CastE(pos)
    myHero.spellbook:CastSpell(self.e.slot, pos)
end

function Lucian:CanCastE(target)
    local aaRange = myHero.characterIntermediate.attackRange
    local onlyAAOutside = SDK.MenuManager.Menu.combo.onlyifmouseoutaarange:get()
    if (SDK.Utility:IsMouseInsideRange(aaRange) and onlyAAOutside) then
        self.lastFailure = "IsMouseInsideRange"
        return false
    end

    local heroPos = SDK.Utility:HeroVPos()
    local posAfterE = heroPos:extended(SDK.Utility:MousePos(), self.e.range)

    if (SDK.MenuManager.Menu.combo.turretcheck:get() and SDK.Utility:IsUnderTurret(posAfterE)) then
        self.lastFailure = "Under Turret"
        return false
    end

    return true
end

function Lucian:ChooseE(target)
    local switchEMode = {
        [1] = function()
            self:CastDynamicE(target)
        end,
        [2] = function()
            self:ShortECast(target)
        end,
        [3] = function()
            self:LongECast(target)
        end,
        [4] = function()
            return
        end
    }
    switchEMode[SDK.MenuManager.Menu.combo.emode.value]()
    if (self.lastFailure ~= nil) then
        print("[nulledSeries] Failed to cast E due to: " .. self.lastFailure)
    end
end

function Lucian:GetEPos(radius, target)
    local hPos = SDK.Utility:HeroVPos()
    local mPos = SDK.Utility:MousePos()

    local finalPos = hPos:extended(mPos, radius)

    -- if (SDK.MenuManager.Menu.combo.stayinrange:get()) then
    --   local a = SDK.Vector(target)
    --   local ab = a:dist(hPos)
    --   local ac = a:dist(finalPos)
    --   if (ac > ab) then
    --     finalPos = finalPos:extended(hPos, ac - ab)
    --   end
    -- end
    return finalPos:toDX3()
end

function Lucian:ShortECast()
    self:CastE(self:GetEPos(myHero.boundingRadius))
end

function Lucian:LongECast()
    self:CastE(self:GetEPos(self.e.range))
end

function Lucian:CastDynamicE()
    if
        (SDK.Utility:IsUnderTurret(SDK.Utility:HeroVPos()) or
            SDK.Utility:IsMouseInsideRange(myHero.characterIntermediate.attackRange))
     then
        self:ShortECast()
    else
        self:LongECast()
    end
end

-------------------------------------------------------------------------------------------------------------------------------------
--                                                           Definitions                                                           --
-------------------------------------------------------------------------------------------------------------------------------------
function Lucian:HasPassiveBuff()
    return myHero.buffManager:HasBuff(0xa38e6d27)
end

-------------------------------------------------------------------------------------------------------------------------------------
--                                                             Damage                                                              --
-------------------------------------------------------------------------------------------------------------------------------------
function Lucian:GetQDamage(unit)
    local qLevel = myHero.spellbook:Spell(SpellSlot.Q).level
    if (qLevel == 0) then
        return 0
    end

    local qBaseDamage = self.q.baseDamage[qLevel] + self.q.multiplier[qLevel] * SDK.Utility:GetBonusAD()

    qBaseDamage = qBaseDamage * SDK.Utility:GetPTADamage(unit)

    return SDK.DamageLib:CalculatePhysicalDamage(myHero, unit, qBaseDamage)
end

function Lucian:GetWDamage(unit)
    local wLevel = myHero.spellbook:Spell(SpellSlot.W).level
    if (wLevel == 0) then
        return 0
    end

    local wBaseDamage = self.w.baseDamage[wLevel] + 0.9 * SDK.Utility:GetBonusAP()

    wBaseDamage = wBaseDamage * SDK.Utility:GetPTADamage(unit)

    return SDK.DamageLib:CalculateMagicDamage(myHero, unit, wBaseDamage)
end

-------------------------------------------------------------------------------------------------------------------------------------
--                                                           Combo Logic                                                           --
-------------------------------------------------------------------------------------------------------------------------------------
function Lucian:ExecuteW(target)
    local pred = _G.Prediction.GetPrediction(target, self.w, myHero)
    if (pred and pred.castPosition and SDK.Utility:HeroVPos():dist(SDK.Vector(pred.castPosition)) < self.w.range) then
        if (not pred:windWallCollision()) then
            if (pred:minionCollision()) then
                if
                    (SDK.Utility:HeroVPos():dist(SDK.Vector(target.positon)) < myHero.characterIntermediate.attackRange and
                        SDK.MenuManager.Menu.combo.smartw:get())
                 then
                    myHero.spellbook:CastSpell(SpellSlot.W, target.position)
                end
            else
                myHero.spellbook:CastSpell(SpellSlot.W, pred.castPosition)
            end
        end
    end
end

function Lucian:ComboWeave(target)
    if
        (SDK.MenuManager.Menu.combo.q:get() and SDK.Utility:HasPTADebuff(target) and
            not SDK.MenuManager.Menu.combo.prioritizee:get())
     then
        if (SDK.Utility:CanCastSpell(SpellSlot.Q)) then
            self:CastQ(target)
            return
        end
    end

    if (SDK.MenuManager.Menu.combo.e:get()) then
        if (SDK.Utility:CanCastSpell(SpellSlot.E) and self:CanCastE(target)) then
            self:ChooseE(target)
            return
        end
    end

    if (SDK.MenuManager.Menu.combo.w:get()) then
        if (SDK.Utility:CanCastSpell(SpellSlot.W)) then
            self:CastW(target)
            return
        end
    end

    if (SDK.MenuManager.Menu.combo.q:get()) then
        if (SDK.Utility:CanCastSpell(SpellSlot.Q)) then
            self:CastQ(target)
            return
        end
    end
end

function Lucian:ExecuteQ(target)
    self:CastQ(target)
end

-------------------------------------------------------------------------------------------------------------------------------------
--                                                        Subscribed Events                                                        --
-------------------------------------------------------------------------------------------------------------------------------------
function Lucian:OnProcessSpell(source, args)
    if (source.charName ~= myHero.charName) then
        return
    end

    if (args.spellSlot >= 0 and args.spellSlot <= 3) then
        self.lastCast = RiotClock.time
    end
end

function Lucian:OnExecuteCastFrame(source, spellInfo)
    if not SDK.UOL then
        return
    end

    if (source.charName ~= myHero.charName) then
        return
    end

    local target = spellInfo.target
    if (target == nil) then
        return
    end

    if (not spellInfo.isAutoAttack) then
        return
    end

    local switchCombo = {
        ["Combo"] = function(t)
            self:ComboWeave(t)
        end,
        ["Harass"] = function(t)
            return
        end,
        ["Waveclear"] = function(t)
            return
        end, -- TODO: jungle clear
        ["Lasthit"] = function(t)
            return
        end,
        ["none"] = function(t)
            return
        end
    }
    switchCombo[SDK.UOL:GetMode()](target)
end

function Lucian:OnTick()
    if not SDK.UOL or not _G.Prediction then
        return
    end

    for _, enemy in pairs(ObjectManager:GetEnemyHeroes()) do
        if (enemy) then
            if (SDK.Utility:IsValidTarget(enemy, self.extendedQ.range) and SDK.MenuManager.Menu.ks.q:get()) then
                if (enemy.health < self:GetQDamage(enemy) and SDK.Utility:CanCastSpell(SpellSlot.Q)) then
                    self:CastQ(enemy)
                end
            end
            if (SDK.Utility:IsValidTarget(enemy, self.w.range) and SDK.MenuManager.Menu.ks.w:get()) then
                if (enemy.health < self:GetWDamage(enemy) and SDK.Utility:CanCastSpell(SpellSlot.W)) then
                    self:CastW(enemy)
                end
            end
        end
    end

    if ((SDK.MenuManager.Menu.combo.weave:get() and self:HasPassiveBuff()) or RiotClock.time - self.lastCast < 0.5) then
        return
    end

    if (SDK.UOL:GetMode() == "Combo") then
        local targets, pred =
            SDK.MenuManager.TS:GetTargets(
            self.w,
            myHero,
            function(unit)
                return _G.Prediction.IsValidTarget(unit, self.w.range, myHero)
            end
        )
        local target = targets[1]

        if (target) then
            if (SDK.Utility:IsValidTarget(target, self.w.range) and SDK.Utility:CanCastSpell(SpellSlot.W)) then
                self:ExecuteW(target)
            end
        end
    end

    if
        ((((SDK.UOL:GetMode() == "Harass" and SDK.MenuManager.Menu.harass.q:get()) or
            SDK.MenuManager.Menu.harass.autoq:get()) and
            SDK.MenuManager.Menu.harass.mana.value < myHero.manaPercent and
            not SDK.Utility:IsUnderTurret()) or
            (SDK.UOL:GetMode() == "Combo" and SDK.MenuManager.Menu.combo.extendedq:get() and
                SDK.Utility:CanCastSpell(SpellSlot.Q)))
     then
        local q_targets, q_preds =
            SDK.MenuManager.TS:GetTargets(
            self.extendedQ,
            myHero,
            function(unit)
                return _G.Prediction.IsValidTarget(unit, self.extendedQ.range, myHero)
            end
        )
        local target = q_targets[1]

        if (not target) then
            return
        end
        -- DrawHandler:Circle3D(target.position, 80, SDK.Utility.Color.Red)
        self:ExecuteQ(target)
    end
end

function Lucian:OnDraw()
    local pos = Renderer:WorldToScreen(myHero.position)
    pos.y = pos.y + 80
    pos.x = pos.x - 80

    if (SDK.MenuManager.Menu.draw.range.q:get() and SDK.Utility:CanCastSpell(SpellSlot.Q)) then
        DrawHandler:Circle3D(myHero.position, self.q.range, SDK.Utility.Color.Red)
        DrawHandler:Circle3D(myHero.position, self.extendedQ.range, SDK.Utility.Color.Red)
    end

    if (SDK.MenuManager.Menu.draw.range.w:get() and SDK.Utility:CanCastSpell(SpellSlot.W)) then
        DrawHandler:Circle3D(myHero.position, self.w.range, SDK.Utility.Color.Green)
    end

    if (SDK.MenuManager.Menu.draw.range.e:get() and SDK.Utility:CanCastSpell(SpellSlot.E)) then
        DrawHandler:Circle3D(myHero.position, self.e.range, SDK.Utility.Color.Blue)
    end

    if (SDK.MenuManager.Menu.draw.range.r:get() and SDK.Utility:CanCastSpell(SpellSlot.R)) then
        DrawHandler:Circle3D(myHero.position, self.r.range, SDK.Utility.Color.Orange)
    end

    if (SDK.MenuManager.Menu.draw.emode:get()) then
        local eModeText = "E Mode: " .. self.eModes[SDK.MenuManager.Menu.combo.emode.value]
        DrawHandler:Text(self.font, pos, eModeText, SDK.Utility.Color.White)
    end

    for _, enemy in pairs(ObjectManager:GetEnemyHeroes()) do
        if (not SDK.MenuManager.Menu.draw.damage.damage:get()) then
            return
        end
        local damage = 0
        if (SDK.MenuManager.Menu.draw.damage.q:get() and SDK.Utility:CanCastSpell(SpellSlot.Q)) then
            damage = damage + self:GetQDamage(enemy)
        end
        if (SDK.MenuManager.Menu.draw.damage.w:get() and SDK.Utility:CanCastSpell(SpellSlot.W)) then
            damage = damage + self:GetWDamage(enemy)
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

return Lucian
