local Morde = {
  q = {
    type = "linear",
    delay = 0.5,
    range = 625,
    speed = 2000,
    width = 260
  },
  e = {
    type = "linear",
    delay = 0.5,
    range = 900,
    speed = 3000,
    width = 190,
  },
  r = {
    range = 650
  }
}


-------------------------------------------------------------------------------------------------------------------------------------
--                                                         Initialization                                                          --
-------------------------------------------------------------------------------------------------------------------------------------
function Morde:__init()
  -- GENERATE MENU
  SDK.MenuManager.Menu:sub("combo", "[=] Combo")
  SDK.MenuManager.Menu.combo:checkbox("q", "Use Q", true)

  SDK.MenuManager.Menu:sub("draw", "[=] Drawings")
  SDK.MenuManager.Menu.draw:sub("range", "[=] Ranges")
  SDK.MenuManager.Menu.draw.range:checkbox("e", "Draw E Range", true)
  SDK.MenuManager.Menu.draw:sub("damage", "[=] Damage")
  SDK.MenuManager.Menu.draw.damage:checkbox("damage", "Draw Damage", true)
  SDK.MenuManager.Menu.draw.damage:checkbox("q", "Draw Q Damage", true)
  SDK.MenuManager.Menu.draw.damage:checkbox("e", "Draw E Damage", true)
  SDK.MenuManager.Menu.draw.damage:slider("aa", "Include X Autos", 1, 10, 4, 1, false)

  -- SUBSCRIBE TO EVENTS
  AddEvent(Events.OnTick, function() self:OnTick() end)
  AddEvent(Events.OnDraw, function() self:OnDraw() end)
  -- AddEvent(Events.OnBuffGain, function(...) self:OnBuffGain(...) end)
  -- AddEvent(Events.OnProcessSpell, function(...) self:OnProcessSpell(...) end)
  -- AddEvent(Events.OnSpellbookCastSpell, function(...) self:OnSpellbookCastSpell(...) end)
  -- AddEvent(Events.OnBasicAttack, function(...) self:OnBasicAttack(...) end)
  -- AddEvent(Events.OnExecuteCastFrame, function(...) self:OnExecuteCastFrame(...) end)
  -- SDK:Log("Loaded Mordekaiser")
end


-------------------------------------------------------------------------------------------------------------------------------------
--                                                             Spells                                                              --
-------------------------------------------------------------------------------------------------------------------------------------
function Morde:CastQ(target)
  local pred = _G.Prediction.GetPrediction(target, self.q, myHero)
  if (pred
    and pred.castPosition
    and pred.rates["slow"]
    and SDK.Utility:HeroVPos():dist(SDK.Vector(pred.castPosition)) < self.q.range) then
    myHero.spellbook:CastSpell(SpellSlot.Q, pred.castPosition)
  end
end

function Morde:CastE(target)
  local pred = _G.Prediction.GetPrediction(target, self.e, myHero)
  if (pred
    and pred.castPosition
    and pred.rates["slow"]
    and SDK.Utility:HeroVPos():dist(SDK.Vector(pred.castPosition)) < self.e.range) then
    myHero.spellbook:CastSpell(SpellSlot.E, pred.castPosition)
  end
end

-------------------------------------------------------------------------------------------------------------------------------------
--                                                           Definitions                                                           --
-------------------------------------------------------------------------------------------------------------------------------------


-------------------------------------------------------------------------------------------------------------------------------------
--                                                             Damage                                                              --
-------------------------------------------------------------------------------------------------------------------------------------
function Morde:GetQDamage(target)
  return 1
end

-------------------------------------------------------------------------------------------------------------------------------------
--                                                           Combo Logic                                                           --
-------------------------------------------------------------------------------------------------------------------------------------

-------------------------------------------------------------------------------------------------------------------------------------
--                                                        Subscribed Events                                                        --
-------------------------------------------------------------------------------------------------------------------------------------
function Morde:OnTick()
  if not SDK.UOL then
    return
  end

  if SDK.UOL:GetMode() == "Combo" then
    if SDK.Utility:CanCastSpell(SpellSlot.E) then
      local e_targets, _ = SDK.MenuManager.TS:GetTargets(self.e, myHero)
      local target = e_targets[1]
      if target and SDK.Utility:IsValidTarget(target, self.e.range) then
        self:CastE(target)
      end
    end
    if SDK.Utility:CanCastSpell(SpellSlot.Q) then
      local q_targets, _ = SDK.MenuManager.TS:GetTargets(self.q, myHero)
      local target = q_targets[1]
      if target and SDK.Utility:IsValidTarget(target, self.q.range) then
        self:CastQ(target)
      end
    end
  end
end

function Morde:OnDraw()
  if (SDK.MenuManager.Menu.draw.range.e:get() and SDK.Utility:CanCastSpell(SpellSlot.E)) then
    DrawHandler:Circle3D(myHero.position, self.e.range, SDK.Utility.Color.Green)
  end

  for _, enemy in pairs(ObjectManager:GetEnemyHeroes()) do
    if (not SDK.MenuManager.Menu.draw.damage.damage:get()) then
      return
    end
    local damage = 0
    if (SDK.MenuManager.Menu.draw.damage.q:get() and SDK.Utility:CanCastSpell(SpellSlot.Q)) then
      damage = damage + self:GetQDamage(enemy)
    end
    if (SDK.MenuManager.Menu.draw.damage.e:get() and SDK.Utility:CanCastSpell(SpellSlot.E)) then
      -- damage = damage + self:GetEDamage(enemy)
    end
    if (SDK.MenuManager.Menu.draw.damage.aa:get()) then
      damage = damage + (SDK.DamageLib:GetAutoAttackDamage(myHero, enemy) * SDK.MenuManager.Menu.draw.damage.aa.value)
    end
    if (enemy and SDK.Utility:IsValidTarget(enemy, 2000)) then
      SDK.Utility:DrawDamage(enemy, damage)
    end
  end
end

return Morde