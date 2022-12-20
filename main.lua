-- PATHS
local SDK_PATH = "nulledSeries.SDK"
-- local TRACKER_PATH = "nulledSeries.Utility.Tracker"
local CHAMPION_PATH = "nulledSeries.Champions." .. myHero.charName

local testFunc = function()
    return true
end

local getCurrentUser = function()
    -- debug checks

    -- DEBUG CHECKS REMOVED - ADD YOUR OWN

    return _G.GetUser()
end

local CURRENT_USER = getCurrentUser()

if CURRENT_USER == "INVALID" then
    PrintChat('<font color="#ff0000">[nulledSeries] - Error 666 - Please contact nullopt.</font>')
    return
end

local PrintTime = function()
    print(os.time())
end

local SUPPORTED_CHAMPS = {
    ["Ashe"] = true,
    -- ["Blitzcrank"] = true,
    ["Corki"] = true,
    -- ["Draven"] = true,
    ["Ezreal"] = true,
    ["Janna"] = true,
    ["Jinx"] = true,
    ["KogMaw"] = true,
    ["Lucian"] = true,
    ["Lulu"] = true,
    -- ["Mordekaiser"] = true,
    ["Tristana"] = true,
    ["Twitch"] = true
    -- ["Viktor"] = true,
    -- ["Riven"] = true
}

local PAID_CHAMPIONS = {
    -- ["Ashe"] = true,
    -- ["Twitch"] = true,
    -- ["KogMaw"] = true,
    -- ["Tristana"] = true,
    -- ["Jinx"] = true,
    -- ["Lulu"] = true,
    -- ["Corki"] = true

    ["Ashe"] = true,
    ["Blitzcrank"] = true,
    ["Corki"] = true,
    -- ["Draven"] = true,
    ["Ezreal"] = true,
    ["Janna"] = true,
    ["Jinx"] = true,
    ["KogMaw"] = true,
    ["Lucian"] = true,
    ["Lulu"] = true,
    -- ["Mordekaiser"] = true,
    ["Tristana"] = true,
    ["Twitch"] = true
    -- ["Viktor"] = true
}

local GetTimeRemaining = function(time)
    return tostring(math.floor((os.difftime(time, os.time()) / (24 * 60 * 60))))
end

-- REQUIRE
require(SDK_PATH)

local dependencies = {{"DreamPred", PaidScript.DREAM_PRED, function()
    return _G.Prediction
end}}

local loadNulledSeries = function()
    _G.LoadDependenciesAsync(dependencies, function(success)
        if success then
            SDK.UOL = require("ModernUOL")
            if not SDK.UOL then -- UOL not present on the computer we download it
                DownloadInternalFileAsync("ModernUOL.lua", COMMON_PATH, function(successTwo)
                    if successTwo then
                        PrintChat("[nulledSeries] Updated: Press F6 to reload")
                    end
                end)
            else -- UOL Present we can load our script
                SDK.UOL:SetDefaultOrbwalker(_G.PaidScript.MED, 15) -- Will load MED if no orb loaded after 5 secondes
                SDK.UOL:OnOrbLoad(function()
                    -- INITIALIZE CHAMPION
                    if (SUPPORTED_CHAMPS[myHero.charName]) then
                        -- INITIALIZE SDK
                        SDK:__init()
                        SDK.OrbAPI = SDK.UOL:GetOrbApi(_G.PaidScript.AURORA_ORB)
                        -- INITIALIZE TRACKER
                        -- local Tracker = require(TRACKER_PATH)
                        -- Tracker:__init()
                        -- INITIALIZE MENU
                        SDK.MenuManager:__init()
                        local Champion = require(CHAMPION_PATH)
                        if (Champion) then
                            Champion:__init()
                        end
                    else
                        PrintChat('<font color="#ff0000">[nulledSeries] - [' .. myHero.charName ..
                                      "] is not supported by nulledSeries.</font>")
                    end
                end)
            end
        end
    end)
end

local serverAuth = function()
    local SCRIPT_NAME = "nulledSeries"
    local URL = "AUTH SERVER HERE"

    if myHero.charName == "Riven" then
        loadNulledSeries()
        return
    end

    GetWebResultAsync(URL, function(result)
        if (result == "Lifetime.") then
            -- life time user
            PrintChat('<font color="#00ffff">[nulledSeries] - ' .. CURRENT_USER .. ", you're a VIP.</font>")
            loadNulledSeries()
            return
        end
        if (result == "Subscription Expired.") then
            -- did have subscription, but it expired
            -- prompt them to resubscribe
            PrintChat('<font color="#ff0000">[nulledSeries] - ' .. CURRENT_USER ..
                          ", your subscription has expired, please purchase another key if you wish to continue using nulledSeries.</font>")
            return
        end
        if (result == "Subscription not found.") then
            -- they have never bought sub
            -- prompt them to buy
            PrintChat('<font color="#ff0000">[nulledSeries] - ' .. CURRENT_USER ..
                          ", in order to use this script, you must purchase a subscription.</font>")
            return
        end
        if tonumber(result) > 0 then
            -- they have a current subscription
            -- tonumber(result) is expiry date in seconds
            local remainingTime = string.format("%.1f", result)
            PrintChat("<font color=\"#00ff00\">[nulledSeries] - " .. CURRENT_USER .. ", you have " .. remainingTime ..
                          " days left on your subscription - thank you for your continued support <3. Enjoy!</font>")
            loadNulledSeries()
            return
        end
    end)
end

-- Auth check
-- serverAuth()

loadNulledSeries()
