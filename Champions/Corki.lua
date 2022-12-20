local Corki = {
    q = setmetatable(
        {
            type = "Circular",
            delay = 0.25,
            range = 825,
            radius = 250,
            speed = 1000,
            collision = {
                ["Wall"] = true
            }
        },
        {
            __index = function(self, key)
                if key == "level" then
                    return myHero.spellbook:Spell(SpellSlot.Q).level
                end
            end
        }
    ),
    e = setmetatable(
        {
            type = "Cone",
            delay = 0,
            angle = 70,
            speed = math.huge
        },
        {
            __index = function(self, key)
                if key == "range" then
                    return SDK.MenuManager.Menu.combo.erange.value
                end
            end
        }
    ),
    r = setmetatable(
        {
            type = "Linear",
            delay = 0.25,
            width = 80,
            speed = 2000,
            collision = {
                ["Wall"] = true,
                ["Hero"] = true,
                ["Minion"] = true
            }
        },
        {
            __index = function(self, key)
                if key == "range" then
                    return myHero.buffManager:HasBuff(0x1f3df184) and 1500 or 1300
                elseif key == "radius" then
                    return myHero.buffManager:HasBuff(0x1f3df184) and 300 or 200
                elseif key == "level" then
                    return myHero.spellbook:Spell(SpellSlot.R).level
                end
            end
        }
    ),
    castRates = {"instant", "slow", "very slow"},
    qBaseDamage = {75, 120, 165, 210, 255},
    rBaseDamage = {90, 125, 160},
    rScaleDamage = {0.15, 0.45, 0.75},
    AAs = {}
}

function Corki:__init()
    -- GENERATE MENU

    -- Combo Menu
    SDK.MenuManager.Menu:sub("combo", "[=] Combo")
    SDK.MenuManager.Menu.combo:label("sep0", "Q Settings", true, true)
    SDK.MenuManager.Menu.combo:checkbox("q", "Use Q", true)
    SDK.MenuManager.Menu.combo:label("sep2", "E Settings", true, true)
    SDK.MenuManager.Menu.combo:checkbox("e", "Use E", true)
    SDK.MenuManager.Menu.combo:slider("erange", "Max E Range", 100, 690, 400, 50)
    SDK.MenuManager.Menu.combo:checkbox("efacing", "Only E If Facing Target", true)
    SDK.MenuManager.Menu.combo:label("sep3", "R Settings", true, true)
    SDK.MenuManager.Menu.combo:checkbox("r", "Use R", true)

    -- Harass Menu
    SDK.MenuManager.Menu:sub("harass", "[=] Harass")
    SDK.MenuManager.Menu.harass:label("sep0", "Q Settings", true, true)
    SDK.MenuManager.Menu.harass:checkbox("q", "Auto Q", true, string.byte("G")):permashow(true)
    SDK.MenuManager.Menu.harass:checkbox("qturret", "Don't Q Under Tower", true)
    SDK.MenuManager.Menu.harass:checkbox("qdash", "Only Use Q On Dash/CC", true)
    SDK.MenuManager.Menu.harass:label("sep1", "R Settings", true, true)
    SDK.MenuManager.Menu.harass:checkbox("r", "Auto R", true, string.byte("T")):permashow(true)
    SDK.MenuManager.Menu.harass:slider("rstacks", "Min. R Stacks", 0, 7, 2, 1, true):tooltip("Saves X stacks for Combo")
    SDK.MenuManager.Menu.harass:checkbox("rturret", "Don't R Under Tower", true)
    SDK.MenuManager.Menu.harass:checkbox("rdash", "Only Use R On Dash/CC", true)
    SDK.MenuManager.Menu.harass:label("sep2", "Mana Settings", true, true)
    SDK.MenuManager.Menu.harass:slider("mana", "Min. Mana %", 0, 100, 50, 1, true)

    -- Killsteal Menu
    SDK.MenuManager.Menu:sub("ks", "[=] Killsteal")
    SDK.MenuManager.Menu.ks:checkbox("q", "Use Q", true)
    SDK.MenuManager.Menu.ks:checkbox("r", "Use R", true)

    -- Prediction Menu
    SDK.MenuManager.Menu:sub("pred", "[=] Prediction")
    SDK.MenuManager.Menu.pred:list("q", "Q Prediction", 2, self.castRates)
    SDK.MenuManager.Menu.pred:list("r", "R Combo/KS Prediction", 2, self.castRates)
    SDK.MenuManager.Menu.pred:list("qharass", "Q Harass Prediction", 2, self.castRates)
    SDK.MenuManager.Menu.pred:list("rharass", "R Harass Prediction", 2, self.castRates)

    -- Draw Menu
    SDK.MenuManager.Menu:sub("draw", "[=] Drawings")
    SDK.MenuManager.Menu.draw:sub("range", "[=] Range")
    SDK.MenuManager.Menu.draw.range:checkbox("q", "Draw Q", true)
    SDK.MenuManager.Menu.draw.range:checkbox("e", "Draw E", true)
    SDK.MenuManager.Menu.draw.range:checkbox("r", "Draw R", true)
    SDK.MenuManager.Menu.draw:sub("damage", "[=] Damage")
    SDK.MenuManager.Menu.draw.damage:checkbox("damage", "Draw Damage", true)
    SDK.MenuManager.Menu.draw.damage:label("sep0", "Q Damage", true, true)
    SDK.MenuManager.Menu.draw.damage:checkbox("q", "Include Q", true)
    SDK.MenuManager.Menu.draw.damage:label("sep1", "R Damage", true, true)
    SDK.MenuManager.Menu.draw.damage:checkbox("r", "Include R", true)
    SDK.MenuManager.Menu.draw.damage:label("sep3", "Auto Attack Damage", true, true)
    SDK.MenuManager.Menu.draw.damage:slider("aa", "Include X Autos", 1, 10, 4, 1, true)
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
end

function Corki:IsBigOne()
    return myHero.buffManager:HasBuff(0x1f3df184)
end

function Corki:GetCastRate(spell)
    return self.castRates[SDK.MenuManager.Menu.pred[spell].value]
end

function Corki:GetQDamage(unit)
    if self.q.level == 0 then
        return 0
    end
    local base = self.qBaseDamage[self.q.level]
    local total = base + (0.7 * SDK.Utility:GetBonusAD()) + (0.5 * SDK.Utility:GetTotalAP())
    return SDK.DamageLib:CalculateMagicDamage(myHero, unit, total)
end

function Corki:GetRDamage(unit)
    if self.r.level == 0 then
        return 0
    end
    local base = self.rBaseDamage[self.r.level]
    local total = base + (self.rScaleDamage[self.r.level] * SDK.Utility:GetTotalAD()) + (0.2 * SDK.Utility:GetTotalAP())
    if self:IsBigOne() then
        total = total * 2
    end

    return SDK.DamageLib:CalculateMagicDamage(myHero, unit, total)
end

function Corki:CastQ(target, forcedPred)
    local pred = _G.Prediction.GetPrediction(target, self.q, myHero)

    if pred then
        local validPos = pred.castPosition
        forcedPred = forcedPred or "q"
        local validRate = pred.rates[self:GetCastRate(forcedPred)]
        local validDist = SDK.Utility:HeroVPos():dist(SDK.Vector(validPos)) < self.q.range
        local windWall = pred:windWallCollision()

        if validRate and validDist and not windWall then
            myHero.spellbook:CastSpell(SpellSlot.Q, pred.castPosition)
        end
    end
end

function Corki:CastR(target, forcedPred)
    -- get prediction
    local pred = _G.Prediction.GetPrediction(target, self.r, myHero)

    if pred then
        -- if it's valid pred
        local validPos = pred.castPosition
        forcedPred = forcedPred or "r"
        local validRate = pred.rates[self:GetCastRate(forcedPred)]
        local validDist = SDK.Utility:HeroVPos():dist(SDK.Vector(validPos)) < self.r.range

        if validPos and validRate and validDist then
            if not pred:windWallCollision() then
                -- if there is minion collision then we need to check if we can hit with explosion
                if pred:minionCollision() then
                    -- get collisions in self.r.radius from unit
                    local collisions =
                        pred:unitTableCollision(
                        SDK.EntityManager:GetUnits(ObjectManager:GetEnemyMinions(), self.r.radius, unit),
                        1
                    )
                    -- if collisions then we can hit with explosion
                    if collisions then
                        myHero.spellbook:CastSpell(SpellSlot.R, pred.castPosition)
                    end
                else
                    -- no minion collision, so will hit
                    myHero.spellbook:CastSpell(SpellSlot.R, pred.castPosition)
                end
            end
        end
    end
end

function Corki:ComboQ(target)
    if (not target) then
        return
    end

    if (not SDK.MenuManager.Menu.combo.q:get()) then
        return
    end

    if (not SDK.Utility:CanCastSpell(SpellSlot.Q)) then
        return
    end

    if (not SDK.Utility:IsValidTarget(target, self.q.range)) then
        return
    end

    self:CastQ(target)
end

function Corki:ComboE(target)
    if not target then
        return
    end

    if not SDK.MenuManager.Menu.combo.e:get() then
        return
    end

    if not SDK.Utility:CanCastSpell(SpellSlot.E) then
        return
    end

    if not SDK.Utility:IsValidTarget(target, self.e.range) then
        return
    end

    if SDK.MenuManager.Menu.combo.efacing:get() then
        if _G.Prediction.IsFacing(myHero, target.position, self.e.angle) then
            myHero.spellbook:CastSpell(SpellSlot.E, target.position)
        end
    else
        myHero.spellbook:CastSpell(SpellSlot.E, target.position)
    end
end

function Corki:ComboR(target)
    if (not target) then
        return
    end

    if (not SDK.MenuManager.Menu.combo.r:get()) then
        return
    end

    if (not SDK.Utility:CanCastSpell(SpellSlot.R)) then
        return
    end

    if (not SDK.Utility:IsValidTarget(target, self.r.range)) then
        return
    end

    self:CastR(target)
end

function Corki:HarassQ(target)
    if (not SDK.Utility:CanCastSpell(SpellSlot.Q)) then
        return
    end

    if (not SDK.MenuManager.Menu.harass.q:get() or myHero.manaPercent < SDK.MenuManager.Menu.harass.mana.value) then
        return
    end

    if SDK.MenuManager.Menu.harass.qturret:get() and SDK.Utility:IsUnderTurret() then
        return
    end

    if (not target) then
        return
    end

    if (not SDK.Utility:IsValidTarget(target, self.q.range)) then
        return
    end

    self:CastQ(target, "qharass")
end

function Corki:HarassR(target)
    if (not SDK.Utility:CanCastSpell(SpellSlot.R)) then
        return
    end

    if (not SDK.MenuManager.Menu.harass.r:get() or myHero.manaPercent < SDK.MenuManager.Menu.harass.mana.value) then
        return
    end

    if SDK.MenuManager.Menu.harass.rstacks:get() then
        if SDK.MenuManager.Menu.harass.rstacks.value >= myHero.spellbook:Spell(SpellSlot.R).currentAmmoCount then
            return
        end
    end

    if SDK.MenuManager.Menu.harass.rturret:get() and SDK.Utility:IsUnderTurret() then
        return
    end

    if (not target) then
        return
    end

    if (not SDK.Utility:IsValidTarget(target, self.r.range)) then
        return
    end

    self:CastR(target, "rharass")
end

function Corki:OnTick()
    if not SDK.UOL then
        return
    end

    for _, enemy in pairs(ObjectManager:GetEnemyHeroes()) do
        if (SDK.Utility:IsValidTarget(enemy, self.r.range) and SDK.MenuManager.Menu.ks.r:get()) then
            if (enemy.health <= self:GetRDamage(enemy) and SDK.Utility:CanCastSpell(SpellSlot.R)) then
                self:CastR(enemy)
            end
        end
        if (SDK.Utility:IsValidTarget(enemy, self.q.range) and SDK.MenuManager.Menu.ks.q:get()) then
            if (enemy.health <= self:GetQDamage(enemy) and SDK.Utility:CanCastSpell(SpellSlot.Q)) then
                self:CastQ(enemy)
            end
        end
    end

    if SDK.UOL:IsAttacking() then
        return
    end

    local qTargets, _ =
        SDK.MenuManager.TS:GetTargets(
        self.q,
        myHero,
        function(unit)
            return _G.Prediction.IsValidTarget(unit, self.q.range, myHero)
        end
    )

    local qTarget = qTargets[1]

    local rTargets, _ =
        SDK.MenuManager.TS:GetTargets(
        self.r,
        myHero,
        function(unit)
            return _G.Prediction.IsValidTarget(unit, self.r.range, myHero)
        end
    )
    local rTarget = rTargets[1]

    if SDK.UOL:GetMode() == "Combo" then
        if (rTarget) then
            self:ComboR(rTarget)
        end

        local eTargets, _ =
            SDK.MenuManager.TS:GetTargets(
            self.e,
            myHero,
            function(unit)
                return _G.Prediction.IsValidTarget(unit, self.e.range, myHero)
            end
        )

        local eTarget = eTargets[1]
        if eTarget then
            self:ComboE(eTarget)
        end

        if (qTarget) then
            self:ComboQ(qTarget)
        end
    end

    if SDK.MenuManager.Menu.harass.rdash:get() then
        local r_targets, r_preds = SDK.MenuManager.TS:GetTargets(self.r, myHero)
        for i = 1, #r_targets do
            local unit = r_targets[i]
            local pred = r_preds[unit.networkId]

            if (pred) then
                if
                    ((pred.targetDashing or not SDK.Utility:CanMove(unit)) and
                        SDK.Utility:HeroVPos():dist(SDK.Vector(pred.castPosition)) < self.q.range)
                 then
                    self:HarassR(unit)
                end
            end
        end
    else
        self:HarassR(rTarget)
    end

    if SDK.MenuManager.Menu.harass.qdash:get() then
        local q_targets, q_preds = SDK.MenuManager.TS:GetTargets(self.q, myHero)
        for i = 1, #q_targets do
            local unit = q_targets[i]
            local pred = q_preds[unit.networkId]

            if (pred) then
                if
                    ((pred.targetDashing or not SDK.Utility:CanMove(unit)) and
                        SDK.Utility:HeroVPos():dist(SDK.Vector(pred.castPosition)) < self.q.range)
                 then
                    self:HarassR(unit)
                end
            end
        end
    else
        self:HarassQ(qTarget)
    end
end
function Corki:OnCreateObject(object, nId)
    if
        object and object.name:find("CorkiBasicAttack") and object.asMissile.spellCaster.networkId == myHero.networkId and
            object.asMissile.target and
            object.asMissile.target.type == GameObjectType.AIHeroClient
     then
        self.AAs[object.networkId] = object.asMissile.target
    end
end

function Corki:OnDeleteObject(object)
    if (SDK.UOL:GetMode() == "Combo") then
        local target = self.AAs[object.networkId]

        if (target and target.type == GameObjectType.AIHeroClient) then
            if (SDK.Utility:IsValidTarget(target, self.r.range)) then
                if SDK.Utility:IsValidTarget(target, self.r.range) then
                    if SDK.DamageLib:GetAutoAttackDamage(myHero, target) < target.health then
                        self:CastR(target)
                    end
                else
                    self:CastR(target)
                end
            end
        end
    end
end

function Corki:OnDraw()
    if SDK.MenuManager.Menu.draw.range.q:get() and SDK.Utility:CanCastSpell(SpellSlot.Q) then
        DrawHandler:Circle3D(myHero.position, self.q.range, SDK.Utility.Color.Red)
    end

    if SDK.MenuManager.Menu.draw.range.e:get() then
        DrawHandler:Circle3D(myHero.position, self.e.range, SDK.Utility.Color.White)
    -- SDK.Utility:DrawCone(myHero.position, myHero.direction, self.e.angle, self.e.range, SDK.Utility.Color.White)
    end

    if SDK.MenuManager.Menu.draw.range.r:get() then
        DrawHandler:Circle3D(myHero.position, self.r.range, SDK.Utility.Color.Orange)
    end

    for _, enemy in pairs(ObjectManager:GetEnemyHeroes()) do
        if (not SDK.MenuManager.Menu.draw.damage.damage:get()) then
            return
        end
        local damage = 0
        if (SDK.MenuManager.Menu.draw.damage.q:get() and SDK.Utility:CanCastSpell(SpellSlot.Q)) then
            damage = damage + self:GetQDamage(enemy)
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

return Corki
