local Tracker = {
  trackable = {},
  colors = {
    0xFF32CD32,
    0xFFFFFF00,
    0xFFFF8000,
    0xFFFF0000,
  },
  summoners = {
    ["summonerbarrier"] = "Barrier",
    ["summonerboost"] = "Cleanse",
    ["summonerexhaust"] = "Exhaust",
    ["summonerflash"] = "Flash",
    ["summonerhaste"] = "Ghost",
    ["summonerheal"] = "Heal",
    ["summonerdot"] = "Ignite",
    ["summonersmite"] = "Smite",
    ["summonerteleport"] = "Teleport"
  },
  sprites = {}
}

local function SmudgeColor(colorA, colorB, percent)
  local r, g, b = colorA.r-(colorA.r-colorB.r)*percent, colorA.g-(colorA.g-colorB.g)*percent, colorA.b-(colorA.b-colorB.b)*percent
  return {r=r,g=g,b=b}
end

local function RGBToHex(rgb)
  local hexadecimal = '0X'

	for key, value in pairs(rgb) do
		local hex = ''

		while(value > 0)do
			local index = math.fmod(value, 16) + 1
			value = math.floor(value / 16)
			hex = string.sub('0123456789ABCDEF', index, index)..hex
		end

		if(string.len(hex) == 0)then
			hex = '00'
		elseif(string.len(hex) == 1)then
			hex = '0'..hex
		end
		hexadecimal = hexadecimal..hex
	end
	return hexadecimal
end

function Tracker:__init()
  -- get enemies
  -- get enemySpellData

  -- get allies
  -- get allySpellData
  for _, enemy in pairs(ObjectManager:GetEnemyHeroes()) do
    local path = COMMON_PATH.."\\nulledSeries\\sprites\\"..string.gsub(enemy.charName, "%s+", "")..".png"
    local sprite = DrawHandler:CreateSprite(path, 50, 50)
    local t = { unit = enemy, sprite = sprite }
    table.insert(self.trackable, t)
  end
  for _, ally in pairs(ObjectManager:GetAllyHeroes()) do
    local t = { unit = ally, sprite = nil }
    table.insert(self.trackable, t)
  end
  
  self.font = DrawHandler:CreateFont("Arial", 8)

  AddEvent(Events.OnTick, function() self:OnTick() end)
  AddEvent(Events.OnDraw, function() self:OnDraw() end)
end

function Tracker:OnTick()
  local passiveTime = math.max(myHero.characterIntermediate.passiveCooldownEndTime - RiotClock.time, 0)
  -- print(passiveTime)
end

function Tracker:TrackPassive(unit)
  local passiveBaseCd = unit.characterIntermediate.passiveCooldownTotalTime
  if (passiveBaseCd == 0) then
    return false
  end

  local passiveCdLeft = math.max(unit.characterIntermediate.passiveCooldownEndTime - RiotClock.time, 0)
  local passiveBarLength = passiveCdLeft == 0 and 26 or (passiveCdLeft / passiveBaseCd) * 26

  local healthBarPosition = unit.infoComponent.hpBarScreenPosition
  local passiveBar = D3DXVECTOR4(healthBarPosition.x - 73, healthBarPosition.y - 3, passiveBarLength, 3)
  local passiveText = string.format("%.0f", passiveCdLeft)
  DrawHandler:FilledRect(passiveBar, SDK.Utility.Color.White)
  if (passiveCdLeft ~= 0) then
    DrawHandler:Text(self.font, D3DXVECTOR2(passiveBar.x, passiveBar.y + 4), passiveText, SDK.Utility.Color.White)
  end
  return true
end

function Tracker:GetSpellBarLength(unit, spellslot, maxBarLength)
  local spell = unit.spellbook:Spell(spellslot)
  if (spell.spellData) then
    local baseCd = spell.baseCdTime
    local cdLeft = spell.cooldownTimeRemaining
    local green = { r = 0, g = 1, b = 0 }
    local red = { r = 1, g = 0, b = 0 }
    local fade = SmudgeColor(red, green, cdLeft / baseCd)
    local fadeTable = { fade.r * 255, fade.g * 255, fade.b * 255 }
    local newColor = RGBToHex(fadeTable)
    local color = cdLeft == 0 and 0xFF00FF00 or 0xFF000000 + newColor
    local data = {
      cdLeft = cdLeft,
      barLength = cdLeft == 0 and maxBarLength or (cdLeft / baseCd) * maxBarLength,
      color = color
    }
    return data
  else
    return nil
  end
end

function Tracker:TrackSpells(unit)
  local healthBarPosition = unit.infoComponent.hpBarScreenPosition
  local trackPassive = false --self:TrackPassive(unit)
  local backgroundOffset = trackPassive and -73 or -46
  local length = trackPassive and 131 or 105
  local background = D3DXVECTOR4(healthBarPosition.x + backgroundOffset, healthBarPosition.y - 3, length, 3)
  DrawHandler:FilledRect(background, SDK.Utility.Color.Black)
  for i = 1, 4 do
    local xOffset = 27 * i - 73
    local x = healthBarPosition.x + xOffset
    local y = healthBarPosition.y - 3
    local data = self:GetSpellBarLength(unit, i - 1, 26)
    local barPos = D3DXVECTOR4(x, y, data.barLength, 3)
    local text = string.format("%.0f", data.cdLeft)
    DrawHandler:FilledRect(barPos, data.color)
    -- if (cdLeft ~= 0) then
      DrawHandler:Text(self.font, D3DXVECTOR2(x + (26 / 2) - (text:len() * 4), y + 6), text, SDK.Utility.Color.White)
    -- end
  end
end

function Tracker:TrackSummoners(unit)
  local healthBarPosition = unit.infoComponent.hpBarScreenPosition
  local firstSummoner = unit.spellbook:Spell(4)
  local secondSummoner = unit.spellbook:Spell(5)
  if (firstSummoner.spellData) then
    local name = self.summoners[firstSummoner.name:lower()]:sub(1, 1)
    local cd = firstSummoner.cooldownTimeRemaining
    local text = name..": "..string.format("%.0f", cd)
    local x = healthBarPosition.x + 65
    local y = healthBarPosition.y - 28
    local pos = D3DXVECTOR2(x, y)
    DrawHandler:Text(self.font, pos, text, cd == 0 and SDK.Utility.Color.White or SDK.Utility.Color.Red)
  end
  if (secondSummoner.spellData) then
    local name = self.summoners[secondSummoner.name:lower()]:sub(1, 1)
    local cd = secondSummoner.cooldownTimeRemaining
    local text = name..": "..string.format("%.0f", cd)
    local x = healthBarPosition.x + 64
    local y = healthBarPosition.y - 14
    local pos = D3DXVECTOR2(x, y)
    DrawHandler:Text(self.font, pos, text, cd == 0 and SDK.Utility.Color.White or SDK.Utility.Color.Red)
  end
end

function Tracker:GetHealthOffset(unit, x, y)
end

function Tracker:Hud(i, unit)
  if (not SDK.MenuManager.Menu.tracker.hud.enable:get()) then
    return
  end
  if (unit.sprite) then
    local u = unit.unit
    local MAX_BAR_LENGTH = 160
    local BAR_HEIGHT = 20
    local SPRITE_POSITION = D3DXVECTOR2(1920 - 70, (1080 / 2) - (i * 70) + 120)
    -- draw sprites
    DrawHandler:Sprite(unit.sprite, SPRITE_POSITION, 1)
    -- get health bar calcs
    local healthBackground = D3DXVECTOR4(SPRITE_POSITION.x - MAX_BAR_LENGTH - 20, SPRITE_POSITION.y, MAX_BAR_LENGTH, BAR_HEIGHT)
    local hp = u.health / u.maxHealth * MAX_BAR_LENGTH
    local healthBar = D3DXVECTOR4(SPRITE_POSITION.x - MAX_BAR_LENGTH - 20, SPRITE_POSITION.y, hp, BAR_HEIGHT)
    local hpText = string.format("%.0f", u.health).." / "..string.format("%.0f", u.maxHealth)
    local hpTextPos = D3DXVECTOR2(SPRITE_POSITION.x - (MAX_BAR_LENGTH / 2) - (hpText:len() * 4), SPRITE_POSITION.y + 4)
    -- get mana bar calcs
    local manaBackground = D3DXVECTOR4(SPRITE_POSITION.x - MAX_BAR_LENGTH - 20, SPRITE_POSITION.y + BAR_HEIGHT + 5, MAX_BAR_LENGTH, BAR_HEIGHT)
    local mana = u.mana / u.maxMana * MAX_BAR_LENGTH
    local manaBar = D3DXVECTOR4(SPRITE_POSITION.x - MAX_BAR_LENGTH - 20, SPRITE_POSITION.y + BAR_HEIGHT + 5, mana, BAR_HEIGHT)
    local manaText = string.format("%.0f", u.mana).." / "..string.format("%.0f", u.maxMana)
    local manaTextPos = D3DXVECTOR2(SPRITE_POSITION.x - (MAX_BAR_LENGTH / 2) - (manaText:len() * 4), SPRITE_POSITION.y + BAR_HEIGHT + 8)

    -- draw hp bar
    DrawHandler:FilledRect(healthBackground, 0xFF872727)
    DrawHandler:FilledRect(healthBar, 0xFF478727)
    DrawHandler:Text(self.font, hpTextPos, hpText, SDK.Utility.Color.White)

    -- draw mana bar
    DrawHandler:FilledRect(manaBackground, 0xFF777777)
    DrawHandler:FilledRect(manaBar, 0xFF5CA9E0)
    DrawHandler:Text(self.font, manaTextPos, manaText, SDK.Utility.Color.White)
  end
end

function Tracker:OnDraw()
  if (SDK.MenuManager.Menu.tracker.enable:get()) then
    for i, unit in pairs(self.trackable) do
      local u = unit.unit
      if (not u.isDead and u.isVisible) then
        self:TrackSpells(u)
        self:TrackSummoners(u)
      end
      self:Hud(i, unit)
    end
  end
end

return Tracker