local Viktor = {
    q = {
        type = "targetted",
        range = 675,
        speed = 2000,
        delay = 0.25,
        baseDamage = {60, 75, 90, 105, 120},
        extraDamage = {20, 45, 70, 95, 120}
    },
    w = {
        type = "circular",
        range = 800,
        radius = 300,
        speed = math.huge,
        delay = 0.25
    },
    e = {
        name = "viktore",
        augName = "viktoreaug",
        type = "linear",
        initialRange = 550,
        range = 1100,
        width = 90,
        speed = 1050,
        delay = 0.0,
        baseDamage = {70, 110, 150, 190, 230},
        extraDamage = {20, 50, 80, 110, 140}
    },
    r = setmetatable(
        {
            type = "circular",
            width = 350,
            delay = 0.25,
            baseDamage = {100, 175, 250},
            tickDamage = {65, 105, 145}
        },
        {
            __index = function(self, key)
                if key == "speed" then
                    -- todo: calculate the speed
                    -- normal: min 200, max 300
                    -- upgraded: min 250, max 375
                    return 250 -- get the spell name and check 1 or 2
                end
            end
        }
    ),
    menu = {}
}

function Viktor:__init()
    SDK.DreamTS.Damage = SDK.DreamTS.Damages.AP
    -- init menu
    SDK.MenuManager.Menu:sub("combo", "[=] Combo")
    SDK.MenuManager.Menu.combo:label("sep0", "Q Settings", true, true)
    SDK.MenuManager.Menu.combo:checkbox("q", "Use Q", true) -- animation cancel
    SDK.MenuManager.Menu.combo:label("sep1", "W Settings", true, true)
    SDK.MenuManager.Menu.combo:checkbox("w", "Use W", true)
    SDK.MenuManager.Menu.combo:checkbox("wcc", "^ On CC", true)
    SDK.MenuManager.Menu.combo:list("wmode", "Mode", 1, {"Always", "Only If R Active", "Never"})
    SDK.MenuManager.Menu.combo:label("sep2", "E Settings", true, true)
    SDK.MenuManager.Menu.combo:checkbox("e", "Use E", true)
    SDK.MenuManager.Menu.combo:label("sep3", "R Settings", true, true)
    SDK.MenuManager.Menu.combo:checkbox("r", "Use R", true)
    SDK.MenuManager.Menu.combo:key("semir", "Semi R", string.byte("T")):permashow(true)
    SDK.MenuManager.Menu.combo:slider("rhits", "Only if hits >= X", 1, 5, 2, 1, true):permashow(true)

    -- TODO: harass
    SDK.MenuManager.Menu:sub("harass", "[=] Harass")

    -- TODO: laneclear
    SDK.MenuManager.Menu:sub("laneclear", "[=] Laneclear")

    -- Draw Menu
    SDK.MenuManager.Menu:sub("draw", "[=] Drawings")
    SDK.MenuManager.Menu.draw:sub("range", "[=] Range")
    SDK.MenuManager.Menu.draw.range:checkbox("q", "Draw Q", false)
    SDK.MenuManager.Menu.draw.range:checkbox("w", "Draw W", false)
    SDK.MenuManager.Menu.draw.range:checkbox("e", "Draw E", true)
    SDK.MenuManager.Menu.draw.range:checkbox("r", "Draw R", false)
    SDK.MenuManager.Menu.draw:sub("damage", "[=] Damage")
    SDK.MenuManager.Menu.draw.damage:checkbox("damage", "Draw Damage", true)
    SDK.MenuManager.Menu.draw.damage:label("sep0", "Q Damage", true, true)
    SDK.MenuManager.Menu.draw.damage:checkbox("q", "Include Q", true)
    SDK.MenuManager.Menu.draw.damage:label("sep1", "E Damage", true, true)
    SDK.MenuManager.Menu.draw.damage:checkbox("e", "Include R", true)
    SDK.MenuManager.Menu.draw.damage:label("sep3", "Auto Attack Damage", true, true)
    SDK.MenuManager.Menu.draw.damage:slider("aa", "Include X Autos", 1, 10, 2, 1, true)

    -- credits
    SDK.MenuManager.Menu:label("sep1", "Commissioned by:", true, true)
    SDK.MenuManager.Menu:label("sep2", "tony oscar", true, false)
    SDK.MenuManager.Menu:label("sep3", "benn", true, false)
    SDK.MenuManager.Menu:label("sep4", "PriorGeologist", true, false)
    SDK.MenuManager.Menu:label("sep5", "Korain", true, false)

    -- TODO: init events
    self.font = DrawHandler:CreateFont("consolas", 13)
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
end

function Viktor:HasQBuff()
    return myHero.buffManager:HasBuff("ViktorPowerTransferReturn")
end

---@param unit GameObject
---@return integer
function Viktor:GetQDamage(unit)
    local level = myHero.spellbook:Spell(SpellSlot.Q).level

    if (level == 0) then
        return 0
    end

    if self:HasQBuff() then
        local extraDamage = self.q.extraDamage[level] + SDK.Utility:GetTotalAD() + (SDK.Utility:GetTotalAP() * 0.6)
        return SDK.DamageLib:CalculateMagicDamage(myHero, unit, extraDamage)
    end

    local baseDamage = self.q.baseDamage[level] + (SDK.Utility:GetTotalAP() * 0.4)

    return SDK.DamageLib:CalculateMagicDamage(myHero, unit, baseDamage)
end

function Viktor:GetEDamage(unit)
    local spell = myHero.spellbook:Spell(SpellSlot.E)
    local level = spell.level
    if level == 0 then
        return 0
    end

    local baseDamage = self.e.baseDamage[level] + (SDK.Utility:GetTotalAP() * 0.5)

    -- TODO: check if upgraded
    local extraDamage = 0
    if spell.name:lower() == self.e.augName then
        extraDamage = self.e.extraDamage[level] + (SDK.Utility:GetTotalAP() * 0.8)
    end

    local totalDamage = baseDamage + extraDamage

    return SDK.DamageLib:CalculateMagicDamage(myHero, unit, totalDamage)
end

---@param unit GameObject
---@param time number time in ticks
---@return integer
function Viktor:GetRDamage(unit, time)
    local level = myHero.spellbook:Spell(SpellSlot.R).level

    if level == 0 then
        return 0
    end

    local baseDamage = self.r.baseDamage[level] + (SDK.Utility:GetTotalAP() * 0.5)
    local tickDamage = (self.r.tickDamage[level] + (SDK.Utility:GetTotalAP() * 0.45) * time)

    local totalDamage = baseDamage + tickDamage

    return SDK.DamageLib:CalculateMagicDamage(myHero, unit, baseDamage + totalDamage)
end

function Viktor:ComboQ()
    if not SDK.MenuManager.Menu.combo.q:get() then
        return
    end

    local q_targets, _ =
        SDK.MenuManager.TS:GetTargets(
        self.q,
        myHero,
        function(unit)
            return _G.Prediction.IsValidTarget(unit, self.q.range, myHero)
        end
    )

    local target = q_targets[1]

    if target then
        myHero.spellbook:CastSpell(SpellSlot.Q, target.networkId)
    end
end

function Viktor:ComboE()
    local e_targets, e_preds =
        SDK.MenuManager.TS:GetTargets(
        self.e,
        myHero,
        function(unit)
            return _G.Prediction.IsValidTarget(unit, self.e.range, myHero)
        end
    )

    ---@type GameObject
    local target = e_targets[1]

    if target then
        local pred = e_preds[target.networkId]

        if pred then
            local targetInInitialRange = SDK.Vector(target.serverPos):dist(myHero.position) < self.e.initialRange
            local predicInInitialRange = SDK.Vector(pred.castPosition):dist(myHero.position) < self.e.initialRange
            local predicInRange = SDK.Vector(pred.castPosition):dist(myHero.position) < self.e.range

            -- local extendedTargetPos = SDK.Utility:HeroVPos():extended(SDK.Vector(target.serverPos), 550)

            -- local potentialEnemies = SDK.EntityManager:GetEnemies(550, target, true)
            -- for i = 1, #potentialEnemies do
            --     local enemy = potentialEnemies[i] ---@type GameObject
            --     if enemy then
            --         local minPos = SDK.Utility:HeroVPos():extended(SDK.Vector(enemy.serverPos), 550)
            --         if
            --             (extendedTargetPos:dist(minPos) <= self.e.width + (target.boundingRadius * 0.5) and
            --                 SDK.Utility:HeroVPos():dist(enemy.position) < self.e.range)
            --          then
            --             myHero.spellbook:CastSpell(SpellSlot.E, target.serverPos, enemy.serverPos)
            --         end
            --     end
            -- end

            if targetInInitialRange then
                -- TODO: find best end pos
                myHero.spellbook:CastSpell(SpellSlot.E, target.serverPos, pred.castPosition)
            elseif predicInInitialRange then
                myHero.spellbook:CastSpell(SpellSlot.E, pred.castPosition, target.serverPos)
            elseif predicInRange then
                local init = SDK.Utility:HeroVPos():extended(SDK.Vector(target.serverPos), self.e.initialRange - 10)
                myHero.spellbook:CastSpell(SpellSlot.E, init:toDX3(), pred.castPosition)
            end
        end

    -- myHero.spellbook:CastSpell(SpellSlot.Q, pred.castPosition, --[[TODO]]nil)
    end
end

function Viktor:OnTick()
    if myHero.isDead or not SDK.UOL then
        return
    end

    -- TODO: combo logic
    if SDK.UOL:GetMode() == "Combo" then
        if SDK.Utility:CanCastSpell(SpellSlot.Q) then
            self:ComboQ()
        end
        if SDK.Utility:CanCastSpell(SpellSlot.E) then
            self:ComboE()
        end
    end
end

function Viktor:OnDraw()
    if SDK.MenuManager.Menu.draw.range.q:get() and SDK.Utility:CanCastSpell(SpellSlot.Q) then
        DrawHandler:Circle3D(myHero.position, self.q.range, SDK.Utility.Color.Red)
    end

    if SDK.MenuManager.Menu.draw.range.e:get() then
        DrawHandler:Circle3D(myHero.position, self.e.initialRange, SDK.Utility.Color.White)
        DrawHandler:Circle3D(myHero.position, self.e.range, SDK.Utility.Color.White)
    end

    if SDK.MenuManager.Menu.draw.range.r:get() then
        DrawHandler:Circle3D(myHero.position, self.r.range, SDK.Utility.Color.Orange)
    end

    -- ! Draw buffs on myHero to check for upgraded spells + buffs
    -- local pos = Renderer:WorldToScreen(myHero.position)
    -- pos.x = pos.x + 80
    -- local buffs = myHero.buffManager.buffs
    -- for i = 1, #buffs do
    --     local buff = buffs[i]
    --     local text = "name: " .. buff.name .. " | count: " .. tostring(buff.count)
    --     DrawHandler:Text(self.font, pos, text, 0xFFFFFFFF)
    --     pos.y = pos.y + 20
    -- end

    -- local enemies = ObjectManager:GetEnemyHeroes()
    -- for i = 1, #enemies do
    --     local enemy = enemies[i]
    --     if enemy then
    --         local ePos = Renderer:WorldToScreen(enemy.position)
    --         ePos.x = ePos.x + 80
    --         local qDamage = self:GetQDamage(enemy)
    --         local eDamage = self:GetEDamage(enemy)

    --         DrawHandler:Text(self.font, ePos, tostring(qDamage), 0xFFFFFFFF)
    --         ePos.y = ePos.y + 20
    --         DrawHandler:Text(self.font, ePos, tostring(eDamage), 0xFFFFFFFF)
    --     end
    -- end
end

return Viktor
