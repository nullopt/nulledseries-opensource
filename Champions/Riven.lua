local Riven = {
    slots = {
        q1 = 0,
        q2 = 1,
        q3 = 2,
        w = 3,
        e = 4,
        r1 = 5,
        r2 = 6,
        flash = 7
    },
    availableSpells = 0,
    combos = {
        -- burst_flash = 31,
        -- burst = 15,
        ["full_combo_r2"] = 89,
        ["full_combo_r1"] = 57,
        ["full_harass"] = 25,
        ["shield_harass"] = 17,
        ["basic_stun"] = 9,
        ["basic_q3"] = 4,
        ["basic_q2"] = 2,
        ["basic_q1"] = 1
    },
    buffs = {
        qBuff = 0x7ed43c82,
        r1Buff = 0x14454eb8,
        r2Buff = 0xd08d7baf
    },
    q = {
        type = "targetted",
        delay = 0,
        range = 255,
        speed = math.huge,
        width = 150,
        lastCast = 0
    },
    target = nil,
    canQ = true,
    last_spell = 0,
    last_e = 0,
    f_spell_map = {}
}

local on_cast_qx = {}
local on_end_qx = {}
local f_spell_map = {}
local on_end_func = nil
local on_end_time = 0
local last_e = 0
local last_spell = 0

local lerp = function(a, b, t)
    local ax = a.x
    local ay = a.y
    local az = a.z

    local vec = SDK.Vector(ax + t * (b.x - ax), ay + t * (b.y - ay), az + t * (b.z - az))
    return vec
end 

local get_q_stacks = function()
    local buff = myHero.buffManager:HasBuff(Riven.buffs.qBuff)
    if not buff then
        return 0
    end

    -- limit it so it doesn't overflow into W
    return buff.count
end

local get_action = function()
	if on_end_func then
		if os.clock() + NetClient.ping / 2000 > on_end_time then
			on_end_func()
		end
	end
end

local move_to_mouse = function(d)
    local p1 = SDK.Utility:MousePos()
    local p2 = SDK.Utility:HeroVPos()
    if p1 == p2 then
        if SDK.UOL:GetCurrentTarget() then
            p1 = SDK.Vector(SDK.UOL:GetCurrentTarget().serverPos)
        end
        -- if menu.push:get() then
        --     local res = pred.aa.get_push_result()
        --     if res then
        --         p1 = res.obj.path.serverPos
        --     end
        -- end
        if p1 == p2 then
            p1 = SDK.Vector(p1.x + math.random() * 10, p1.y, p1.z + math.random() * 10)
        end
    end
    local pos = lerp(p2, p1, d / p1:dist(p2)):toDX3()
    myHero:IssueOrderFast(GameObjectOrder.MoveTo, pos)
end

local on_end_q1 = function()
    on_end_func = nil
	SDK.UOL:ResetAA()
    -- orb.core.reset()
    -- orb.core.set_pause(0)
    print("end_q1 " .. os.clock())
    -- if pred.r2_dmg.get_action_state() then
    --     pred.r2_dmg.invoke_action(true)
    --     return true
    -- end
    -- if not orb.combat.target then
    --     if pred.w.get_action_state() then
    --         pred.w.invoke_action(true)
    --     end
    -- end
end

local on_move_q1 = function()
    -- print('move q1')
    move_to_mouse(400)
    on_end_func = on_end_q1
    on_end_time = on_end_time + 0.150 + 0.125
end

local on_move_q2 = function()
    -- print('move q2')
    move_to_mouse(400)
    on_end_func = on_end_q2
    on_end_time = on_end_time + 0.150 + 0.125
end

local on_move_q3 = function()
    -- print('move q3')
    move_to_mouse(400)
    on_end_func = on_end_q3
    on_end_time = on_end_time + 0.250 + 0.125
end

local on_cast_q1 = function()
    on_end_func = on_move_q1
    on_end_time = os.clock() + 0.15
end

local on_cast_q2 = function()
    on_end_func = on_move_q2
    on_end_time = os.clock() + 0.15
end

local on_cast_q3 = function()
    on_end_func = on_move_q3
    on_end_time = os.clock() + 0.25
end

local on_cast_q = function()
    last_e = 0
    -- orb.core.set_pause(2)
	local stacks = get_q_stacks()
    print("casting q - " .. stacks)
    on_cast_qx[stacks]()
end

---@param spell SpellDataInst
local on_recv_spell = function(spell)
    if f_spell_map[spell.name] then
        f_spell_map[spell.name]()
        last_spell = os.clock()
    end
end

function Riven:__init()
    self.font = DrawHandler:CreateFont("Consolas", 13)

    AddEvent(Events.OnTick, function()
        self:OnTick()
    end)
    AddEvent(Events.OnProcessSpell, function(...)
        self:OnProcessSpell(...)
    end)
    AddEvent(Events.OnSpellbookCastSpell, function(...)
        self:OnSpellbookCastSpell(...)
    end)
    AddEvent(Events.OnDraw, function()
        self:OnDraw()
    end)

    SDK.UOL:AddCallback("OnAfterAttack", function(...)
        self:OnAfterAttack(...)
    end)

    self.f_spell_map['RivenTriCleave'] = self.on_cast_q
    self.f_spell_map['RivenMartyr'] = self.on_cast_w
    self.f_spell_map['RivenFeint'] = self.on_cast_e
    self.f_spell_map['RivenFengShuiEngine'] = self.on_cast_r1
    self.f_spell_map['RivenIzunaBlade'] = self.on_cast_r2
    self.f_spell_map['ItemTiamatCleave'] = self.on_cast_r_hydra
end

function Riven:byte2bin(n)
    local t = {}
    for i = 7, 0, -1 do
        t[#t + 1] = math.floor(n / 2 ^ i)
        n = n % 2 ^ i
    end
    return table.concat(t)
end

function Riven:UpdateSpell(spellSlot, available)
    if available then
        self.availableSpells = bit.bor(self.availableSpells, bit.lshift(1, spellSlot))
    else
        self.availableSpells = bit.band(self.availableSpells, bit.bnot(bit.lshift(1, spellSlot)))
    end
end

function Riven:UpdateSpells()
    self:UpdateQSpell()

    self:UpdateSpell(self.slots.w, SDK.Utility:CanCastSpell(SpellSlot.W))
    self:UpdateSpell(self.slots.e, SDK.Utility:CanCastSpell(SpellSlot.E))

    self:UpdateRSpell()
end

function Riven:UpdateQSpell()
    if SDK.Utility:CanCastSpell(SpellSlot.Q) then
        -- get spell slot for current q state
        local qSpell = self:GetQSpell()
        self:UpdateSpell(qSpell, true)
    else
        -- reset all q values if spell in on cd
        -- 	also reset in between casts due to spell
        -- 	being on cd for a short period of time
        self:UpdateSpell(self.slots.q1, false)
        self:UpdateSpell(self.slots.q2, false)
        self:UpdateSpell(self.slots.q3, false)
    end
end

function Riven:UpdateRSpell()
    if SDK.Utility:CanCastSpell(SpellSlot.R) then
        local r2Buff = myHero.buffManager:HasBuff(self.buffs.r2Buff)
        self:UpdateSpell(self.slots.r1, r2Buff == nil)
        self:UpdateSpell(self.slots.r2, r2Buff ~= nil)
    else
        self:UpdateSpell(self.slots.r1, false)
        self:UpdateSpell(self.slots.r2, false)
    end
end

function Riven:GetQSpell()
    return math.min(get_q_stacks(), 2)
end

function Riven:GetBestCombo()
    for k, v in pairs(self.combos) do
        if v == self.availableSpells then
            return k
        end
    end

    return "no_combo_found"
end

function Riven:CastQ(target)
    -- if SDK.UOL:IsAttacking() or myHero.isWindingUp then--or (RiotClock.time - self.q.lastCast) < 0.8 then
    --     return
    -- end
    myHero.spellbook:CastSpell(SpellSlot.Q, target.networkId)
end

function Riven:OnTick()
    self:UpdateSpells()

	get_action()
    -- if SDK.UOL then
    --     if SDK.UOL:GetMode() == "Combo" then
    --         -- local targets, pred = SDK.MenuManager.TS:GetTargets(self.q)
    --         -- self.target = targets[1]

    --         -- if (self.target) then
    --         --     if (SDK.Utility:IsValidTarget(self.target, self.q.range) and SDK.Utility:CanCastSpell(SpellSlot.Q)) then
    --         --         self:CastQ(self.target)
    --         --     end
    --         -- end
    --     end
    -- end
end

function Riven:GetQDelay()
    return (NetClient.ping / 1000) + 0.15
end

function Riven:ResetQ()
    -- SDK.UOL:BlockAttack(true)
    -- -- move
    -- local pos = SDK.Utility:HeroVPos():extended(SDK.Vector(self.target.position), -150)
    -- myHero:IssueOrder(GameObjectOrder.MoveTo, pos:toDX3())
    -- DrawHandler:Circle3D(pos:toDX3(), 150, SDK.Utility.Color.Pink)

    -- -- attack unit
    -- SDK.Utility:DelayAction(function()
    --     myHero:IssueOrder(GameObjectOrder.AttackUnit, self.target)
    -- 	SDK.UOL:BlockAttack(false)
    -- end, self:GetQDelay())
end

---@param source GameObject
---@param args SpellCastInfo
function Riven:OnProcessSpell(source, args)
    -- if self.target == nil then
    --     return
    -- end

    -- if source.networkId ~= myHero.networkId then
    --     return
    -- end

    -- if args.spellSlot == SpellSlot.Q then
    --     self:ResetQ()
    -- end
end

---@param spellSlot SpellSlot
---@param startPos D3DXVECTOR3
---@param endPos D3DXVECTOR3
---@param target GameObject
function Riven:OnSpellbookCastSpell(spellSlot, startPos, endPos, target)
    local spell = myHero.spellbook:Spell(spellSlot)
	if spell then
		on_recv_spell(spell)
	end
end

---@param target GameObject
function Riven:OnAfterAttack(target)
    -- if (target) then
    -- 	self.target = target
    --     if (SDK.Utility:IsValidTarget(target, self.q.range) and SDK.Utility:CanCastSpell(SpellSlot.Q)) then
    --         self:CastQ(target)
    --     end
    -- end
end

f_spell_map['RivenTriCleave'] = on_cast_q
-- f_spell_map['RivenMartyr'] = on_cast_w
-- f_spell_map['RivenFeint'] = on_cast_e
-- f_spell_map['RivenFengShuiEngine'] = on_cast_r1
-- f_spell_map['RivenIzunaBlade'] = on_cast_r2
-- f_spell_map['ItemTiamatCleave'] = on_cast_r_hydra

on_cast_qx[0] = on_cast_q1
on_cast_qx[1] = on_cast_q2
on_cast_qx[2] = on_cast_q3
on_cast_qx[3] = on_cast_q3

function Riven:OnDraw()
    if self.target then
        DrawHandler:Circle3D(self.target.position, 100, SDK.Utility.Color.Green)
    end
    local pos = Renderer:WorldToScreen(myHero.position)
    local text = "Available Spells: " .. self:byte2bin(self.availableSpells)

    DrawHandler:Text(self.font, pos, text, SDK.Utility.Color.White)

    -- pos.y = pos.y + 20
    -- text = "q1: " .. tostring(bit.band(self.availableSpells, bit.lshift(1, self.slots.q1)) ~= 0)
    -- DrawHandler:Text(self.font, pos, text, SDK.Utility.Color.White)

    -- pos.y = pos.y + 20
    -- text = "q2: " .. tostring(bit.band(self.availableSpells, bit.lshift(1, self.slots.q2)) ~= 0)
    -- DrawHandler:Text(self.font, pos, text, SDK.Utility.Color.White)

    -- pos.y = pos.y + 20
    -- text = "q3: " .. tostring(bit.band(self.availableSpells, bit.lshift(1, self.slots.q3)) ~= 0)
    -- DrawHandler:Text(self.font, pos, text, SDK.Utility.Color.White)

    -- pos.y = pos.y + 20
    -- text = "w: " .. tostring(bit.band(self.availableSpells, bit.lshift(1, self.slots.w)) ~= 0)
    -- DrawHandler:Text(self.font, pos, text, SDK.Utility.Color.White)

    -- pos.y = pos.y + 20
    -- text = "e: " .. tostring(bit.band(self.availableSpells, bit.lshift(1, self.slots.e)) ~= 0)
    -- DrawHandler:Text(self.font, pos, text, SDK.Utility.Color.White)

    -- pos.y = pos.y + 20
    -- text = "r1: " .. tostring(bit.band(self.availableSpells, bit.lshift(1, self.slots.r1)) ~= 0)
    -- DrawHandler:Text(self.font, pos, text, SDK.Utility.Color.White)

    -- pos.y = pos.y + 20
    -- text = "r2: " .. tostring(bit.band(self.availableSpells, bit.lshift(1, self.slots.r2)) ~= 0)
    -- DrawHandler:Text(self.font, pos, text, SDK.Utility.Color.White)

    -- pos.y = pos.y + 20
    -- text = "flash: " .. tostring(bit.band(self.availableSpells, bit.lshift(1, self.slots.flash)) ~= 0)
    -- DrawHandler:Text(self.font, pos, text, SDK.Utility.Color.White)

    -- pos.y = pos.y + 50
    -- local buffs = myHero.buffManager.buffs
    -- for i = 1, #buffs do
    -- 	local buff = buffs[i]
    -- 	local text = tostring(buff.name) .. " | " .. tostring(buff.count)
    -- 	DrawHandler:Text(self.font, pos, text, SDK.Utility.Color.White)
    -- 	pos.y = pos.y + 20
    -- end

    pos.y = pos.y + 20
    text = "Best Combo: " .. self:GetBestCombo()
    DrawHandler:Text(self.font, pos, text, SDK.Utility.Color.White)

end

return Riven
