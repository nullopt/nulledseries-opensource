local EM = {
    neutralCamps = {}
}

---@param range number
---@param unit GameObject
---@return GameObject[]
function EM:GetEnemies(range, unit, ignoreSelf)
    return self:GetUnits(ObjectManager:GetEnemyHeroes(), range, unit, ignoreSelf)
end

function EM:GetEnemiesWithBuff(range, buffHash, unit, ignoreSelf)
    unit = unit or myHero
    ignoreSelf = ignoreSelf or false

    local result = {}
    local enemies = self:GetEnemies(range, unit, ignoreSelf)
    for i = 1, #enemies do
        local enemy = enemies[i]
        if enemy.buffManager:HasBuff(buffHash) then
            table.insert(result, enemy)
        end
    end
    return result
end

---@param range number
---@param unit GameObject
---@return GameObject[]
function EM:GetAllEnemies(range, unit, ignoreSelf)
    local heroes = self:GetEnemies(range, unit)
    local minions = self:GetUnits(ObjectManager:GetEnemyMinions(), range, unit, ignoreSelf)

    local result = {}

    for i = 1, #heroes do
        local hero = heroes[i]
        table.insert(result, hero)
    end

    for i = 1, #minions do
        local minion = minions[i]
        table.insert(result, minion)
    end

    return result
end

function EM:GetAllies(range, unit)
    return self:GetUnits(ObjectManager:GetAllyHeroes(), range, unit)
end

function EM:GetJungleMobs(range)
    range = range or 25000
    local jungleMobs = {}

    for _, minion in pairs(ObjectManager:GetEnemyMinions()) do
        if (minion and SDK.Utility:IsValidTarget(minion, range) and not minion.isDead and minion.team == 300) then
            table.insert(jungleMobs, minion)
        end
    end

    return jungleMobs
end

function EM:GetDragonAndBaron(extras)
    extras = extras or nil
    local result = {
        ["dragon"] = nil,
        ["rift"] = nil,
        ["baron"] = nil
    }
    for _, minion in pairs(self:GetJungleMobs()) do
        local name = minion.name:lower()
        if (name:find("sru_dragon")) then
            result["dragon"] = minion
        end
        if (name:find("sru_rift")) then
            result["rift"] = minion
        end
        if (name:find("sru_baron")) then
            result["baron"] = minion
        end
        if (extras) then
            for _, extra in pairs(extras) do
                if (name:find(extra)) then
                    result[extra] = minion
                end
            end
        end
    end

    return result
end

function EM:GetUnits(unitTable, range, from, ignoreSelf)
    local units = {}
    from = from or myHero
    ignoreSelf = ignoreSelf or false
    if not range then
        units = unitTable
    else
        for _, unit in pairs(unitTable) do
            if unit and SDK.Vector(from.position):dist(SDK.Vector(unit.position)) < range and
                -- and unit.networkId ~= from.networkId
                SDK.Utility:IsValidTarget(unit) then
                if not (ignoreSelf and unit.networkId == from.networkId) then
                    table.insert(units, unit)
                end
            end
        end
    end
    return units
end

function EM:CountEnemiesInRange(range, unit)
    return #self:GetEnemies(range, unit)
end

function EM:CountAlliesInRange(range, unit)
    return #self:GetAllies(range, unit)
end

function EM:CountEnemiesInRangeOfPos(range, pos)
    local enemies = {}
    for _, enemy in pairs(ObjectManager:GetEnemyHeroes()) do
        if (SDK.Utility:IsValidTarget(enemy)) then
            local distance = SDK.Vector(enemy.position):dist(SDK.Vector(pos))
            if (distance <= range) then
                table.insert(enemies, enemy)
            end
        end
    end

    return #enemies
end

function EM:GetAlliesNearPos(range, pos)
    local allies = {}
    for _, ally in pairs(ObjectManager:GetAllyHeroes()) do
        if (SDK.Utility:IsValidTarget(ally)) then
            local distance = SDK.Vector(ally.position):dist(SDK.Vector(pos))
            if (distance <= range) then
                table.insert(allies, ally)
            end
        end
    end

    return allies
end

function EM:GetClosestEnemy(unit, range)
    local distance = 10000
    local closest = nil
    for _, enemy in pairs(self:GetEnemies(range)) do
        if (enemy and enemy.isVisible and enemy.networkId ~= unit.networkId) then
            local d = SDK.Vector(enemy.position):dist(SDK.Vector(unit.position))
            if (d < distance) then
                distance = d
                closest = enemy
            end
        end
    end
    return closest
end

function EM:GetAlly(charName)
    for _, ally in pairs(ObjectManager:GetAllyHeroes()) do
        if (ally.charName == charName) then
            return ally
        end
    end
    return nil
end

return EM
