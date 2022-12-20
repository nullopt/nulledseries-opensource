local MM = {
    Menu = {},
    Champ = {},
    TS = {}
}

function MM:__init()
    self.Menu = Menu("nulledseries." .. myHero.charName, "[+] nulledSeries - " .. myHero.charName)
    -- Target Selector
    self.Menu:label("sep0", "Target Selector", true, true)
    self.Menu:checkbox("humanizer", "Follow TS Humanizers", false)
    self.Menu:sub("dreamTs", "Target Selector")

    self.TS =
        SDK.DreamTS(
        self.Menu.dreamTs,
        {
            Damage = SDK.DreamTS.Damages.AD -- Remember to set in script if AP 'SDK.DreamTS.Damage = SDK.DreamTS.Damages.AP'
        }
    )

    self.Menu:label(myHero.charName, "[=] " .. myHero.charName, true, true)
    self.Champ = self.Menu[myHero.charName]
end

---@param menu any
---@param spell string
---@param default boolean
function MM:CreateBoolWhiteList(menu, spell, default)
    local menuKey = spell:lower() .. "whitelist"
    menu:sub(menuKey, "[=] " .. spell .. " Whitelist")
    for _, enemy in pairs(SDK.EntityManager:GetEnemies()) do
        menu[menuKey]:checkbox(enemy.charName, enemy.charName, default)
    end
end

function MM:CreateAllyWhitelist(menu, spell, default)
    local menuKey = spell:lower() .. "whitelist"
    menu:sub(menuKey, "[=] " .. spell .. " Whitelist")
    for _, ally in pairs(SDK.EntityManager:GetAllies()) do
        menu[menuKey]:checkbox(ally.charName, ally.charName, default)
    end
end

return MM
