SDK = {
    UOL = {},
    OrbAPI = {},
    AuroraAPI = {},
    DreamTS = {},
    DamageLib = {},
    Menu = {},
    Vector = {},
    Circle = {},
    Polygon = {},
    LineSegment = {},
    Prediction = {},
    Utility = {},
    DamageType = {},
    MenuManager = {},
    EntityManager = {},
    Queue = {}
}

function SDK:__init()
    self.DreamTS = require("DreamTS")
    self.DamageLib = require("FF15DamageLib")
    self.Menu = require("FF15Menu")
    self.Vector = require("GeometryLib").Vector
    self.Circle = require("GeometryLib").Circle
    self.Polygon = require("GeometryLib").Polygon
    self.LineSegment = require("GeometryLib").LineSegment

    self.Utility, self.DamageType = require("nulledSeries.Utility.Utility")()
    self.MenuManager = require("nulledSeries.Utility.MenuManager")
    self.EntityManager = require("nulledSeries.Utility.EntityManager")

    -- self.Queue = require("nulledSeries.Utility.Queue")

    self.font = DrawHandler:CreateFont("consolas", 10)
end

function SDK:Log(text, color)
    color = color or "#00ff00"
    PrintChat('<font color="' .. color .. '">[nulledSeries] - [' .. myHero.charName .. "] " .. text .. "</font>")
end
