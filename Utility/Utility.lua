local CosTable = {0.99984769515639, 0.9993908270191, 0.99862953475457, 0.99756405025982, 0.99619469809175,
                  0.99452189536827, 0.99254615164132, 0.99026806874157, 0.98768834059514, 0.98480775301221,
                  0.98162718344766, 0.97814760073381, 0.97437006478524, 0.970295726276, 0.96592582628907,
                  0.96126169593832, 0.95630475596304, 0.95105651629515, 0.94551857559932, 0.93969262078591,
                  0.9335804264972, 0.92718385456679, 0.92050485345244, 0.9135454576426, 0.90630778703665,
                  0.89879404629917, 0.89100652418837, 0.88294759285893, 0.8746197071394, 0.86602540378444,
                  0.85716730070211, 0.84804809615643, 0.83867056794542, 0.82903757255504, 0.81915204428899,
                  0.80901699437495, 0.79863551004729, 0.78801075360672, 0.77714596145697, 0.76604444311898,
                  0.75470958022277, 0.74314482547739, 0.73135370161917, 0.71933980033865, 0.70710678118655,
                  0.694658370459, 0.6819983600625, 0.66913060635886, 0.65605902899051, 0.64278760968654,
                  0.62932039104984, 0.61566147532566, 0.60181502315205, 0.58778525229247, 0.57357643635105,
                  0.55919290347075, 0.54463903501503, 0.5299192642332, 0.51503807491005, 0.5, 0.48480962024634,
                  0.46947156278589, 0.45399049973955, 0.43837114678908, 0.4226182617407, 0.4067366430758,
                  0.39073112848927, 0.37460659341591, 0.3583679495453, 0.34202014332567, 0.32556815445716,
                  0.30901699437495, 0.29237170472274, 0.275637355817, 0.25881904510252, 0.24192189559967,
                  0.22495105434386, 0.20791169081776, 0.19080899537654, 0.17364817766693, 0.15643446504023,
                  0.13917310096007, 0.12186934340515, 0.10452846326765, 0.087155742747658, 0.069756473744125,
                  0.052335956242944, 0.034899496702501, 0.017452406437284, 6.1230317691119e-017, -0.017452406437283,
                  -0.034899496702501, -0.052335956242944, -0.069756473744125, -0.087155742747658, -0.10452846326765,
                  -0.12186934340515, -0.13917310096007, -0.15643446504023, -0.17364817766693, -0.19080899537654,
                  -0.20791169081776, -0.22495105434387, -0.24192189559967, -0.25881904510252, -0.275637355817,
                  -0.29237170472274, -0.30901699437495, -0.32556815445716, -0.34202014332567, -0.3583679495453,
                  -0.37460659341591, -0.39073112848927, -0.4067366430758, -0.4226182617407, -0.43837114678908,
                  -0.45399049973955, -0.46947156278589, -0.48480962024634, -0.5, -0.51503807491005, -0.5299192642332,
                  -0.54463903501503, -0.55919290347075, -0.57357643635105, -0.58778525229247, -0.60181502315205,
                  -0.61566147532566, -0.62932039104984, -0.64278760968654, -0.65605902899051, -0.66913060635886,
                  -0.6819983600625, -0.694658370459, -0.70710678118655, -0.71933980033865, -0.73135370161917,
                  -0.74314482547739, -0.75470958022277, -0.76604444311898, -0.77714596145697, -0.78801075360672,
                  -0.79863551004729, -0.80901699437495, -0.81915204428899, -0.82903757255504, -0.83867056794542,
                  -0.84804809615643, -0.85716730070211, -0.86602540378444, -0.8746197071394, -0.88294759285893,
                  -0.89100652418837, -0.89879404629917, -0.90630778703665, -0.9135454576426, -0.92050485345244,
                  -0.92718385456679, -0.9335804264972, -0.93969262078591, -0.94551857559932, -0.95105651629515,
                  -0.95630475596304, -0.96126169593832, -0.96592582628907, -0.970295726276, -0.97437006478524,
                  -0.97814760073381, -0.98162718344766, -0.98480775301221, -0.98768834059514, -0.99026806874157,
                  -0.99254615164132, -0.99452189536827, -0.99619469809175, -0.99756405025982, -0.99862953475457,
                  -0.9993908270191, -0.99984769515639, -1, -0.99984769515639, -0.9993908270191, -0.99862953475457,
                  -0.99756405025982, -0.99619469809175, -0.99452189536827, -0.99254615164132, -0.99026806874157,
                  -0.98768834059514, -0.98480775301221, -0.98162718344766, -0.97814760073381, -0.97437006478524,
                  -0.970295726276, -0.96592582628907, -0.96126169593832, -0.95630475596304, -0.95105651629515,
                  -0.94551857559932, -0.93969262078591, -0.9335804264972, -0.92718385456679, -0.92050485345244,
                  -0.9135454576426, -0.90630778703665, -0.89879404629917, -0.89100652418837, -0.88294759285893,
                  -0.8746197071394, -0.86602540378444, -0.85716730070211, -0.84804809615643, -0.83867056794542,
                  -0.82903757255504, -0.81915204428899, -0.80901699437495, -0.79863551004729, -0.78801075360672,
                  -0.77714596145697, -0.76604444311898, -0.75470958022277, -0.74314482547739, -0.73135370161917,
                  -0.71933980033865, -0.70710678118655, -0.694658370459, -0.6819983600625, -0.66913060635886,
                  -0.65605902899051, -0.64278760968654, -0.62932039104984, -0.61566147532566, -0.60181502315205,
                  -0.58778525229247, -0.57357643635105, -0.55919290347075, -0.54463903501503, -0.52991926423321,
                  -0.51503807491005, -0.5, -0.48480962024634, -0.46947156278589, -0.45399049973955, -0.43837114678908,
                  -0.4226182617407, -0.4067366430758, -0.39073112848927, -0.37460659341591, -0.3583679495453,
                  -0.34202014332567, -0.32556815445716, -0.30901699437495, -0.29237170472274, -0.275637355817,
                  -0.25881904510252, -0.24192189559967, -0.22495105434387, -0.20791169081776, -0.19080899537654,
                  -0.17364817766693, -0.15643446504023, -0.13917310096007, -0.12186934340515, -0.10452846326765,
                  -0.087155742747658, -0.069756473744126, -0.052335956242944, -0.034899496702501, -0.017452406437283,
                  -1.8369095307336e-016, 0.017452406437283, 0.034899496702501, 0.052335956242944, 0.069756473744125,
                  0.087155742747658, 0.10452846326765, 0.12186934340515, 0.13917310096007, 0.15643446504023,
                  0.17364817766693, 0.19080899537655, 0.20791169081776, 0.22495105434386, 0.24192189559967,
                  0.25881904510252, 0.275637355817, 0.29237170472274, 0.30901699437495, 0.32556815445716,
                  0.34202014332567, 0.3583679495453, 0.37460659341591, 0.39073112848927, 0.4067366430758,
                  0.4226182617407, 0.43837114678908, 0.45399049973955, 0.46947156278589, 0.48480962024634, 0.5,
                  0.51503807491005, 0.5299192642332, 0.54463903501503, 0.55919290347075, 0.57357643635105,
                  0.58778525229247, 0.60181502315205, 0.61566147532566, 0.62932039104984, 0.64278760968654,
                  0.65605902899051, 0.66913060635886, 0.6819983600625, 0.694658370459, 0.70710678118655,
                  0.71933980033865, 0.73135370161917, 0.74314482547739, 0.75470958022277, 0.76604444311898,
                  0.77714596145697, 0.78801075360672, 0.79863551004729, 0.80901699437495, 0.81915204428899,
                  0.82903757255504, 0.83867056794542, 0.84804809615643, 0.85716730070211, 0.86602540378444,
                  0.8746197071394, 0.88294759285893, 0.89100652418837, 0.89879404629917, 0.90630778703665,
                  0.9135454576426, 0.92050485345244, 0.92718385456679, 0.9335804264972, 0.93969262078591,
                  0.94551857559932, 0.95105651629515, 0.95630475596304, 0.96126169593832, 0.96592582628907,
                  0.970295726276, 0.97437006478524, 0.97814760073381, 0.98162718344766, 0.98480775301221,
                  0.98768834059514, 0.99026806874157, 0.99254615164132, 0.99452189536827, 0.99619469809175,
                  0.99756405025982, 0.99862953475457, 0.9993908270191, 0.99984769515639, 1}
local SinTable = {0.017452406437284, 0.034899496702501, 0.052335956242944, 0.069756473744125, 0.087155742747658,
                  0.10452846326765, 0.12186934340515, 0.13917310096007, 0.15643446504023, 0.17364817766693,
                  0.19080899537654, 0.20791169081776, 0.22495105434387, 0.24192189559967, 0.25881904510252,
                  0.275637355817, 0.29237170472274, 0.30901699437495, 0.32556815445716, 0.34202014332567,
                  0.3583679495453, 0.37460659341591, 0.39073112848927, 0.4067366430758, 0.4226182617407,
                  0.43837114678908, 0.45399049973955, 0.46947156278589, 0.48480962024634, 0.5, 0.51503807491005,
                  0.5299192642332, 0.54463903501503, 0.55919290347075, 0.57357643635105, 0.58778525229247,
                  0.60181502315205, 0.61566147532566, 0.62932039104984, 0.64278760968654, 0.65605902899051,
                  0.66913060635886, 0.6819983600625, 0.694658370459, 0.70710678118655, 0.71933980033865,
                  0.73135370161917, 0.74314482547739, 0.75470958022277, 0.76604444311898, 0.77714596145697,
                  0.78801075360672, 0.79863551004729, 0.80901699437495, 0.81915204428899, 0.82903757255504,
                  0.83867056794542, 0.84804809615643, 0.85716730070211, 0.86602540378444, 0.8746197071394,
                  0.88294759285893, 0.89100652418837, 0.89879404629917, 0.90630778703665, 0.9135454576426,
                  0.92050485345244, 0.92718385456679, 0.9335804264972, 0.93969262078591, 0.94551857559932,
                  0.95105651629515, 0.95630475596304, 0.96126169593832, 0.96592582628907, 0.970295726276,
                  0.97437006478524, 0.97814760073381, 0.98162718344766, 0.98480775301221, 0.98768834059514,
                  0.99026806874157, 0.99254615164132, 0.99452189536827, 0.99619469809175, 0.99756405025982,
                  0.99862953475457, 0.9993908270191, 0.99984769515639, 1, 0.99984769515639, 0.9993908270191,
                  0.99862953475457, 0.99756405025982, 0.99619469809175, 0.99452189536827, 0.99254615164132,
                  0.99026806874157, 0.98768834059514, 0.98480775301221, 0.98162718344766, 0.97814760073381,
                  0.97437006478524, 0.970295726276, 0.96592582628907, 0.96126169593832, 0.95630475596304,
                  0.95105651629515, 0.94551857559932, 0.93969262078591, 0.9335804264972, 0.92718385456679,
                  0.92050485345244, 0.9135454576426, 0.90630778703665, 0.89879404629917, 0.89100652418837,
                  0.88294759285893, 0.8746197071394, 0.86602540378444, 0.85716730070211, 0.84804809615643,
                  0.83867056794542, 0.82903757255504, 0.81915204428899, 0.80901699437495, 0.79863551004729,
                  0.78801075360672, 0.77714596145697, 0.76604444311898, 0.75470958022277, 0.74314482547739,
                  0.73135370161917, 0.71933980033865, 0.70710678118655, 0.694658370459, 0.6819983600625,
                  0.66913060635886, 0.65605902899051, 0.64278760968654, 0.62932039104984, 0.61566147532566,
                  0.60181502315205, 0.58778525229247, 0.57357643635105, 0.55919290347075, 0.54463903501503,
                  0.5299192642332, 0.51503807491005, 0.5, 0.48480962024634, 0.46947156278589, 0.45399049973955,
                  0.43837114678908, 0.4226182617407, 0.4067366430758, 0.39073112848927, 0.37460659341591,
                  0.3583679495453, 0.34202014332567, 0.32556815445716, 0.30901699437495, 0.29237170472274,
                  0.275637355817, 0.25881904510252, 0.24192189559967, 0.22495105434387, 0.20791169081776,
                  0.19080899537654, 0.17364817766693, 0.15643446504023, 0.13917310096007, 0.12186934340515,
                  0.10452846326765, 0.087155742747658, 0.069756473744126, 0.052335956242944, 0.034899496702501,
                  0.017452406437283, 1.2246063538224e-016, -0.017452406437284, -0.034899496702501, -0.052335956242944,
                  -0.069756473744125, -0.087155742747658, -0.10452846326765, -0.12186934340515, -0.13917310096007,
                  -0.15643446504023, -0.17364817766693, -0.19080899537654, -0.20791169081776, -0.22495105434386,
                  -0.24192189559967, -0.25881904510252, -0.275637355817, -0.29237170472274, -0.30901699437495,
                  -0.32556815445716, -0.34202014332567, -0.3583679495453, -0.37460659341591, -0.39073112848927,
                  -0.4067366430758, -0.4226182617407, -0.43837114678908, -0.45399049973955, -0.46947156278589,
                  -0.48480962024634, -0.5, -0.51503807491005, -0.5299192642332, -0.54463903501503, -0.55919290347075,
                  -0.57357643635105, -0.58778525229247, -0.60181502315205, -0.61566147532566, -0.62932039104984,
                  -0.64278760968654, -0.65605902899051, -0.66913060635886, -0.6819983600625, -0.694658370459,
                  -0.70710678118655, -0.71933980033865, -0.73135370161917, -0.74314482547739, -0.75470958022277,
                  -0.76604444311898, -0.77714596145697, -0.78801075360672, -0.79863551004729, -0.80901699437495,
                  -0.81915204428899, -0.82903757255504, -0.83867056794542, -0.84804809615643, -0.85716730070211,
                  -0.86602540378444, -0.8746197071394, -0.88294759285893, -0.89100652418837, -0.89879404629917,
                  -0.90630778703665, -0.9135454576426, -0.92050485345244, -0.92718385456679, -0.9335804264972,
                  -0.93969262078591, -0.94551857559932, -0.95105651629515, -0.95630475596304, -0.96126169593832,
                  -0.96592582628907, -0.970295726276, -0.97437006478524, -0.97814760073381, -0.98162718344766,
                  -0.98480775301221, -0.98768834059514, -0.99026806874157, -0.99254615164132, -0.99452189536827,
                  -0.99619469809175, -0.99756405025982, -0.99862953475457, -0.9993908270191, -0.99984769515639, -1,
                  -0.99984769515639, -0.9993908270191, -0.99862953475457, -0.99756405025982, -0.99619469809175,
                  -0.99452189536827, -0.99254615164132, -0.99026806874157, -0.98768834059514, -0.98480775301221,
                  -0.98162718344766, -0.97814760073381, -0.97437006478524, -0.970295726276, -0.96592582628907,
                  -0.96126169593832, -0.95630475596304, -0.95105651629515, -0.94551857559932, -0.93969262078591,
                  -0.9335804264972, -0.92718385456679, -0.92050485345244, -0.9135454576426, -0.90630778703665,
                  -0.89879404629917, -0.89100652418837, -0.88294759285893, -0.8746197071394, -0.86602540378444,
                  -0.85716730070211, -0.84804809615643, -0.83867056794542, -0.82903757255504, -0.81915204428899,
                  -0.80901699437495, -0.79863551004729, -0.78801075360672, -0.77714596145697, -0.76604444311898,
                  -0.75470958022277, -0.74314482547739, -0.73135370161917, -0.71933980033865, -0.70710678118655,
                  -0.694658370459, -0.6819983600625, -0.66913060635886, -0.65605902899051, -0.64278760968654,
                  -0.62932039104984, -0.61566147532566, -0.60181502315205, -0.58778525229247, -0.57357643635105,
                  -0.55919290347075, -0.54463903501503, -0.52991926423321, -0.51503807491005, -0.5, -0.48480962024634,
                  -0.46947156278589, -0.45399049973955, -0.43837114678908, -0.4226182617407, -0.4067366430758,
                  -0.39073112848927, -0.37460659341591, -0.3583679495453, -0.34202014332567, -0.32556815445716,
                  -0.30901699437495, -0.29237170472274, -0.275637355817, -0.25881904510252, -0.24192189559967,
                  -0.22495105434387, -0.20791169081776, -0.19080899537654, -0.17364817766693, -0.15643446504023,
                  -0.13917310096007, -0.12186934340515, -0.10452846326765, -0.087155742747658, -0.069756473744126,
                  -0.052335956242944, -0.034899496702501, -0.017452406437284, -2.4492127076448e-016}
CosTable[0] = 1
SinTable[0] = 0

local Utility = {
    turrets = {},
    Color = {
        Black = 0xFF000000,
        Gray = 0xFF808080,
        White = 0xFFFFFFFF,
        Azure = 0xFFF0FFFF,
        Brown = 0xFFCD853F,
        Olive = 0xFF8FBC8F,
        Red = 0xFFFF0000,
        Maroon = 0xFF800000,
        Coral = 0xFFFF7F50,
        Orange = 0xFFFF8000,
        Yellow = 0xFFFFFF00,
        Lime = 0xFFADFF2F,
        Green = 0xFF32CD32,
        Cyan = 0xFF00FFFF,
        LightBlue = 0xFF1E90FF,
        SkyBlue = 0xFF87CEFA,
        Blue = 0xFF0000FF,
        Purple = 0xFFFF00FF,
        Pink = 0xFFFFA8CC,
        DeepPink = 0xFFFF1493
    },
    scripterSpells = {
        ["Ashe"] = {
            ["AsheQ"] = true
        },
        ["Kaisa"] = {
            ["KaisaE"] = true
        },
        ["KogMaw"] = {
            ["KogMawBioArcaneBarrage"] = true
        },
        ["Lucian"] = {
            ["LucianE"] = true
        },
        ["MissFortune"] = {
            ["MissFortuneViciousStrikes"] = true
        },
        ["Sivir"] = {
            ["SivirR"] = true
        },
        ["Tristana"] = {
            ["TristanaQ"] = true,
            ["TristanaE"] = true
        },
        ["Twitch"] = {
            ["TwitchFullAutomatic"] = true
        },
        ["Vayne"] = {
            ["VayneInquisition"] = true
        },
        ["Xayah"] = {
            ["XayahW"] = true
        }
    },
    scripterBuffs = {
        ["Ashe"] = {
            ["AsheQAttack"] = true
        },
        ["Kaisa"] = {
            ["kaisaestealth"] = true
        },
        ["KogMaw"] = {
            ["KogMawBioArcaneBarrage"] = true
        },
        ["MissFortune"] = {
            ["MissFortuneViciousStrikes"] = true
        },
        ["Sivir"] = {
            ["SivirR"] = true
        },
        ["Tristana"] = {
            ["TristanaQ"] = true,
            ["TristanaECharge"] = true
        },
        ["Twitch"] = {
            ["twitchhideinshadowsbuff"] = true,
            ["TwitchFullAutomatic"] = true
        },
        ["Vayne"] = {
            ["VayneInquisition"] = true
        },
        ["Xayah"] = {
            ["XayahW"] = true
        }
    }
}

local DamageType = {
    ALL = 1,
    PHYSICAL = 2,
    MAGICAL = 3
}

function Utility:CanCastSpell(spellSlot)
    return myHero.spellbook:CanUseSpell(spellSlot) == 0 and self:GetSpellLevel(spellSlot) > 0
end

function Utility:GetSpellLevel(spellSlot)
    return myHero.spellbook:Spell(spellSlot).level
end

function Utility:MissingHealth(unit)
    unit = unit or myHero
    return (unit.maxHealth - unit.health)
end

function Utility:MissingHPPercent(unit)
    unit = unit or myHero
    return self:MissingHealth(unit) / unit.maxHealth
end

function Utility:GetBonusAD(unit)
    unit = unit or myHero
    return unit.characterIntermediate.flatPhysicalDamageMod
end

function Utility:GetBonusAP(unit)
    unit = unit or myHero
    return unit.characterIntermediate.flatMagicDamageMod
end

function Utility:GetTotalAD(unit)
    unit = unit or myHero
    return unit.characterIntermediate.flatPhysicalDamageMod + unit.characterIntermediate.baseAttackDamage
end

function Utility:GetTotalAP(unit)
    unit = unit or myHero
    return unit.characterIntermediate.flatMagicDamageMod + unit.characterIntermediate.baseAbilityDamage
end

function Utility:GetPerkDamage(target, time)
    return self:GetCoupDeGraceMulti(myHero, target, time) * self:GetCutDownMulti(myHero, target)
end

function Utility:GetCoupDeGraceMulti(source, target, time)
    time = time or 0
    if target.type ~= GameObjectType.AIHeroClient then
        return 1
    end
    if not source.avatar:HasPerk(8014) then
        return 1
    end

    local hpRegOverTime = time * target.characterIntermediate.hpRegenRate
    local procentualReg = hpRegOverTime * 100 / target.maxHealth

    if target.type == GameObjectType.AIHeroClient and target.healthPercent + hpRegOverTime <= 40 then
        return 1.08
    end

    return 1
end

function Utility:GetCutDownMulti(source, target)
    if target.type ~= GameObjectType.AIHeroClient then
        return 1
    end
    if not source.avatar:HasPerk(8017) then
        return 1
    end

    local delta = target.maxHealth * 100 / source.maxHealth - 100
    if delta < 10 then
        return 1
    end
    local multi = 1 + (0.05 + (delta - 10) * 0.001111111111111)

    return multi >= 1.15 and 1.15 or multi
end

function Utility:GetRange(includeBoundingRadius)
    includeBoundingRadius = includeBoundingRadius or true
    return myHero.characterIntermediate.attackRange + (includeBoundingRadius and (myHero.boundingRadius * 1.5) or 0)
end

---@param target GameObject
---@return number
function Utility:GetRealAutoAttackRange(target)
    local result = myHero.characterIntermediate.attackRange + myHero.boundingRadius
    if self:IsValidTarget(target, 2000) then
        local aiBase = target
        if aiBase then
            if myHero.charName == "Caitlyn" and aiBase.buffManager:HasBuff(0x1e8b8ca0) then
                return 1250
            end

            if myHero.charName == "Aphelios" and aiBase.buffManager:HasBuff(0x9f57b629) then
                return 1800
            end

            result = result - math.min((NetClient.ping - 40) / 3, 10)
            result = result - 11
        end

        return result + target.boundingRadius
    end

    return result
end

---@param target GameObject
---@return boolean
function Utility:InAutoAttackRange(target)
    if not self:IsValidTarget(target, 2000) then
        return false
    end

    local myRange = self:GetRealAutoAttackRange(target)
    return SDK.Vector(target.position):distSqr(SDK.Vector(myHero.position)) <= myRange * myRange
end

function Utility:MousePos()
    return SDK.Vector(pwHud.hudManager.virtualCursorPos)
end

function Utility:HeroVPos()
    return SDK.Vector(myHero.position)
end

function Utility:DynamicRange(pred, target, spell)
    local distToPosition = self:HeroVPos():dist(SDK.Vector(target.position)) -- GetDistance(target)
    local distToCast = self:HeroVPos():dist(SDK.Vector(pred.castPosition)) -- GetDistance(pred.castPosition)
    if distToPosition <= distToCast then
        return true
    end
    if distToPosition + (distToPosition - distToCast) *
        (pred.interceptionTime - spell.delay - NetClient.ping / 2000 - 0.07) / pred.interceptionTime < spell.range then
        return true
    end

    return false
end

function Utility:IsMouseInsideRange(range)
    return self:HeroVPos():dist(self:MousePos()) < range
end

function Utility:IsUnderTurret(pos)
    local vPos = pos or self:HeroVPos()

    local turrets = ObjectManager:GetEnemyTurrets()
    for i = 1, #turrets do
        local turret = turrets[i]
        if turret then
            if turret.isValid and turret.health > 0 and vPos:dist(SDK.Vector(turret.position)) <= 800 then
                return true
            end
        end
    end

    return false
end

---@param unit GameObject
function Utility:HasLT(unit)
    unit = unit or myHero
    return unit.buffManager:HasBuff(0xC098BA92)
end

function Utility:HasExhaust(unit)
    unit = unit or myHero
    return unit.buffManager:HasBuff(0x26a7b745)
end

function Utility:AutoAttackTarget(unit)
    local spellCasterClient = unit.spellbook.spellCasterClient

    if (spellCasterClient ~= nil and spellCasterClient.isAutoAttacking) then
        return spellCasterClient.spellCastInfo.target
    end
end

function Utility:AutoAttackTargetType(unit)
    local spellCasterClient = unit.spellbook.spellCasterClient

    if (spellCasterClient ~= nil and spellCasterClient.isAutoAttacking and spellCasterClient.spellCastInfo.target) then
        return spellCasterClient.spellCastInfo.target.type
    end
end

function Utility:HasPTADebuff(unit)
    return unit.buffManager:HasBuff(0xde9c9649)
end

function Utility:GetPTADamage(unit)
    if self:HasPTADebuff(unit) then
        return 1.07765 + (0.00235 * myHero.experience.level)
    end
    return 1
end

function Utility:HasHobBuff(unit)
    return unit.buffManager:HasBuff(0x08c2c951)
end

function Utility:GetBuffStacks(unit, buffName)
    local buff = unit.buffManager:HasBuff(buffName)
    if (buff) then
        return buff.count
    end
    return 0
end

function Utility:GetBuffTime(unit, buffName)
    local buff = unit.buffManager:HasBuff(buffName)
    if (buff) then
        return buff.remainingTime
    end
    return 0
end

---@param damage number
---@param damageType DamageType
---@return boolean
function GameObject:IsKillable(damage, damageType)
    damageType = damageType or DamageType.ALL
    if damage >= self:GetRealHealth(damageType) then
        return true
    end
    local percent = damage / self:GetRealHealth(damageType) -- < 1.0
    if myHero.inventory:HasItem(6676) then
        return percent >= 0.949
    end
    return percent >= 0.99
end

---@param damageType DamageType
function GameObject:GetRealHealth(damageType)
    local rawHealth = self.health
    local shields = 0
    if damageType == DamageType.ALL then
        shields = self.allShield + self.magicShield + self.attackShield
    elseif damageType == DamageType.MAGICAL then
        shields = self.allShield + self.magicShield
    elseif damageType == DamageType.PHYSICAL then
        shields = self.allShield + self.attackShield
    end

    return rawHealth + shields
end

function Utility:HasHookBuffs(unit)
    local threshBuff = unit.buffManager:HasBuff(0x2147af12) or unit.buffManager:HasBuff(0xebdc68e0) or
                           unit.buffManager:HasBuff(0xde92c6c6)
    local blitzBuff = unit.buffManager:HasBuff(0xdbde3ca7)
    local pykeBuff = unit.buffManager:HasBuff(0xff79f121)
    return threshBuff or blitzBuff or pykeBuff
end

function Utility:IsImortal(hero)

    if hero.type ~= myHero.type then
        return false
    end

    local name = hero.name

    if name == "Fiora" and hero.buffManager:HasBuff(0x7ef0ec09) then
        return true
    end

    if name == "Sion" and hero.buffManager:HasBuff(0xb600518b) then
        return true
    end
    if name == "Vladimir" and hero.buffManager:HasBuff(0xeb8deb15) then
        return true
    end
    if name == "Karthus" and hero.buffManager:HasBuff(0x627a6d7f) then
        return true
    end
    if name == "Kayn" and hero.buffManager:HasBuff(0x86b8ab70) then
        return true
    end

    if name == "Lissandra" and hero.buffManager:HasBuff(0x2214093c) then
        return true
    end
    if name == "XinZhao" and hero.buffManager:HasBuff(0xdbf88945) and
        not self:HeroVPos():dist(SDK.Vector(hero.position)) < 450 then
        return true
    end
    if name == "Tryndamere" and hero.buffManager:HasBuff(0x66af2836) and hero.health <= 70 then
        return true
    end

    return false
end

---@param unit GameObject
---@param range number
---@return boolean
function Utility:IsValidTarget(unit, range)
    if not unit then
        return false
    end

    local valid = unit.isValid
    local visible = unit.isVisible
    local alive = not unit.isDead
    local player = not unit.isZombie
    local mortal = not self:IsImortal(unit)
    local invulnerable = unit.isInvulnerable or unit.buffManager:HasBuffOfType(BuffType.Invulnerability) or
                             unit.buffManager:HasBuffOfType(BuffType.PhysicalImmunity) or
                             unit.buffManager:HasBuffOfType(BuffType.SpellImmunity) or
                             unit.buffManager:HasBuffOfType(BuffType.SpellShield) or self:IsImortal(unit)

    local targetable = true
    if SDK.MenuManager.Menu.humanizer:get() then
        targetable = SDK.MenuManager.TS:CanReactToTarget(unit)
    end
    return valid and visible and alive and player and not invulnerable and targetable and mortal and
               (not range or self:HeroVPos():dist(SDK.Vector(unit.position)) <= range)
end

function Utility:ValidUlt(target)
    return not (target.buffManager:HasBuffOfType(BuffType.PhysicalImmunity) or
               target.buffManager:HasBuffOfType(BuffType.SpellImmunity) or target.isZombie or target.isInvulnerable or
               target.buffManager:HasBuffOfType(BuffType.Invulnerability) or target.buffManager:HasBuff(0xe9edcf9e) or
               target.buffManager:HasBuffOfType(BuffType.SpellShield))
end

function Utility:CanMove(target)
    return not (target.buffManager:HasBuffOfType(BuffType.Stun) or target.buffManager:HasBuffOfType(BuffType.Fear) or
               target.buffManager:HasBuffOfType(BuffType.Snare) or target.buffManager:HasBuffOfType(BuffType.Knockup) or
               target.buffManager:HasBuffOfType(BuffType.Knockback) or target.buffManager:HasBuffOfType(BuffType.Charm) or
               target.buffManager:HasBuffOfType(BuffType.Taunt) or
               target.buffManager:HasBuffOfType(BuffType.Suppression))
    -- or target.buffManager:HasBuffOfType(BuffType.SleepBuffType)
end

function Utility:DrawCircle(pos, radius, thickness, color)
    for i = 1, thickness / 2 do
        DrawHandler:Circle3D(pos, radius - i, color)
    end
    for i = 1, thickness / 2 do
        DrawHandler:Circle3D(pos, radius + i, color)
    end
end

function SDK.Vector:RotatedAngle(angle)
    local c, s = CosTable[angle], SinTable[angle]
    return SDK.Vector(self.x * c + self.z * s, self.y, self.z * c - self.x * s)
end

---@param pos3d D3DXVECTOR3
---@param radius number
---@param color number
function Utility:DrawMinimapCircle(pos3d, radius, color)
    pos3d = SDK.Vector(pos3d)
    color = color or self.Color.White
    local pts = {}
    local dir = pos3d:normalized()

    for angle = 0, 360, 15 do
        local r = (pos3d + dir:RotatedAngle(angle) * radius):toDX3()
        local pos = TacticalMap:WorldToMinimap(r)
        if pos.x ~= 0 then
            pts[#pts + 1] = pos
        end
    end

    for i = 1, #pts - 1 do
        DrawHandler:Line(pts[i], pts[i + 1], color)
    end
end

function Utility:DrawDamage(target, damage)
    if damage > target.health then
        damage = target.health
    end

    if target.infoComponent == nil then
        return
    end

    local color = {}

    local damagePercentage = (damage / target.health) * 100

    if (damagePercentage >= 100) then
        color = 0x66FFFFFF -- Color.White
    elseif (damagePercentage >= 75) then
        color = 0x66FF0000 -- Color.Red
    elseif (damagePercentage >= 50) then
        color = 0x66FF8D03 -- Color.Orange
    elseif (damagePercentage >= 25) then
        color = 0x66FFFF00 -- Color.Yellow
    else
        color = 0x6600FF00 -- Color.Green
    end

    local healthBarPosition = target.infoComponent.hpBarScreenPosition
    local barLength = (damage / target.maxHealth) * 106
    local startLocation = healthBarPosition.x - 46 + (target.health / target.maxHealth) * 106 - barLength

    DrawHandler:FilledRect(D3DXVECTOR4(startLocation, healthBarPosition.y - 24, barLength, 10), color)
end

function Utility:rgba2hex(a, r, g, b)
    return tonumber(string.format("0x%02x%02x%02x%02x", a, r, g, b))
end

function Utility:GetPosExtendedAngle(pos, dir, angle, dist)
    local phi = math.rad(angle)
    local c, s = math.cos(phi), math.sin(phi)

    local rotated_dir = SDK.Vector(dir.x * c + dir.z * s, 0, dir.z * c - dir.x * s)

    return pos + rotated_dir * dist
end

function Utility:DrawCone(point, direction, angle, range, color)
    local points = {}
    point = SDK.Vector(point)
    direction = SDK.Vector(direction)

    for angle = math.floor(angle / 2), 0, -5 do
        points[#points + 1] = Renderer:WorldToScreen((self:GetPosExtendedAngle(point, direction, angle, range)):toDX3())
    end
    for angle = 355, math.floor(360 - (angle / 2)), -5 do
        points[#points + 1] = Renderer:WorldToScreen((self:GetPosExtendedAngle(point, direction, angle, range)):toDX3())
    end

    local hero_2d = Renderer:WorldToScreen(myHero.position)

    DrawHandler:Line(hero_2d, points[1], color)
    DrawHandler:Line(hero_2d, points[#points], color)
    for i = 1, #points - 1 do
        DrawHandler:Line(points[i], points[i + 1], color)
    end
end

function Utility:DrawMinionDamage(minion, damage)
    if minion and not minion.isDead then
        if minion.infoComponent then
            local minionHPBar = minion.infoComponent.hpBarScreenPosition
            local hpBarSize = string.find(minion.charName, "Super") and 100 or 70
            local hpBarStartPos = string.find(minion.charName, "Super") and 50 or 35
            local pHP = hpBarSize * minion.health / minion.maxHealth
            local pDMG = hpBarSize * damage / minion.maxHealth
            pDMG = pHP > pDMG and pDMG or pHP
            if minion.health < damage then
                DrawHandler:OutlinedRect(D3DXVECTOR4(minionHPBar.x - hpBarStartPos, minionHPBar.y - 7, hpBarSize, 8), 2,
                    self:rgba2hex(255, 255, 0, 0), self:rgba2hex(50, 255, 0, 0))
            else
                DrawHandler:OutlinedRect(D3DXVECTOR4(minionHPBar.x - hpBarStartPos + pHP - pDMG, minionHPBar.y - 7,
                    pDMG, 6), 2, self:rgba2hex(100, 0, 255, 0), self:rgba2hex(0, 0, 0, 0))
            end
        end
    end
end

local delayedActions, delayedActionsExecuter = {}, nil
function Utility:DelayAction(func, delay, args) -- delay in seconds
    if not delayedActionsExecuter then
        function delayedActionsExecuter()
            for t, funcs in pairs(delayedActions) do
                if t <= os.clock() then
                    for i = 1, #funcs do
                        local f = funcs[i]
                        if f and f.func then
                            f.func(unpack(f.args or {}))
                        end
                    end
                    delayedActions[t] = nil
                end
            end
        end
        AddEvent(Events.OnTick, delayedActionsExecuter)
    end
    local t = os.clock() + (delay or 0)
    if delayedActions[t] then
        delayedActions[t][#delayedActions[t] + 1] = {
            func = func,
            args = args
        }
    else
        delayedActions[t] = {{
            func = func,
            args = args
        }}
    end
end

function Utility:DebugChat(text, color)
    PrintChat('<font color="' .. color .. '">[nulledSeries] - [' .. myHero.charName .. "] " .. text .. "</font>")
end

function SDK.Vector:RotatedRad(r)
    local c, s = math.cos(r), math.sin(r)
    return SDK.Vector(self.x * c + self.z * s, self.y, self.z * c - self.x * s)
end

return function()
    return Utility, DamageType
end
