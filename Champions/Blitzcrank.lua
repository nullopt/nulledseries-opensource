local Blitzcrank = {
  q = {
    type = "linear",
    delay = 0.25,
    range = 1150,
    width = 70,
    speed = 1800
  },
  pred = {"instant", "slow", "very slow"}
}

function Blitzcrank:__init()
  SDK.MenuManager.Menu:sub("combo", "[=] Combo")
  SDK.MenuManager.Menu.combo:checkbox("q", "Use Q", true)
  SDK.MenuManager.Menu.combo:list("pred", "Pred", 2, self.pred)

  SDK.MenuManager.Menu:sub("gap", "[=] Anti-Gapcloser")
  SDK.MenuManager.Menu.gap:checkbox("q", "Use Q", true)
  SDK.MenuManager:CreateBoolWhiteList(SDK.MenuManager.Menu.gap, "Q", true)

  AddEvent(Events.OnTick, function() self:OnTick() end)
  SDK:Log("Loaded Blitzcrank - "..GetUser())
end

function Blitzcrank:GetCastRate()
    return self.pred[SDK.MenuManager.Menu.combo.pred.value]
end

function Blitzcrank:CastQ(target)
  local pred = _G.Prediction.GetPrediction(target, self.q, myHero)
  if (pred
    and pred.rates[self:GetCastRate()]
    and pred.castPosition
    and SDK.Utility:HeroVPos():dist(SDK.Vector(pred.castPosition)) < self.q.range) then
    if (not pred:windWallCollision() and not pred:minionCollision()) then
      myHero.spellbook:CastSpell(SpellSlot.Q, pred.castPosition)
    end
  end
end

function Blitzcrank:OnTick()
  if not SDK.UOL then
    return
  end

  local qTargets, qPreds = SDK.MenuManager.TS:GetTargets(self.q, myHero, function(unit) return SDK.Utility:IsValidTarget(unit, self.q.range) end)
  for _, target in pairs(qTargets) do
    local pred = qPreds[target.networkId]
    if (pred and pred.targetDashing) then
      local useQ = SDK.MenuManager.Menu.gap.q:get()
      local shouldQEnemy = SDK.MenuManager.Menu.gap.qwhitelist[target.charName]:get()
      if (useQ and
          shouldQEnemy and
          SDK.Utility:HeroVPos():dist(SDK.Vector(pred.castPosition)) < self.q.range and
          SDK.Utility:CanCastSpell(SpellSlot.Q)) then
        myHero.spellbook:CastSpell(SpellSlot.Q, pred.castPosition)
      end
    end
  end

  if SDK.UOL:GetMode() == "Combo" then
    if not SDK.MenuManager.Menu.combo.q:get() then
      return
    end

    if not SDK.Utility:CanCastSpell(SpellSlot.Q) then
      return
    end

    local qTarget = qTargets[1]
    if qTarget and SDK.Utility:IsValidTarget(qTarget, self.q.range) then
      self:CastQ(qTarget)
    end
  end
end

return Blitzcrank