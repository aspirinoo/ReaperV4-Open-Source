WeaponsList = {}

-- [EXPLOSION_ID] = WEAPON_HASH
WeaponsList.ExplosiveWeapons = {
    [0] = {
        [GetHashKey("WEAPON_GRENADE")] = true
    },
    [1] = {
        [GetHashKey("WEAPON_GRENADELAUNCHER")] = true
    },
    [2] = {
        [GetHashKey("WEAPON_STICKYBOMB")] = true
    },
    [3] = {
        [GetHashKey("WEAPON_MOLOTOV")] = true
    },
    [4] = {
        [GetHashKey("WEAPON_RPG")] = true
    },
    [19] = {
        [GetHashKey("WEAPON_SMOKEGRENADELAUNCHER")] = true
    },
    [20] = {
        [GetHashKey("WEAPON_SMOKEGRENADE")] = true
    },
    [21] = {
        [GetHashKey("WEAPON_BZGAS")] = true
    },
    [22] = {
        [GetHashKey("WEAPON_FLARE")] = true
    },
    [24] = {
        [GetHashKey("WEAPON_EXTINGUISHER")] = true
    },
    [36] = {
        [GetHashKey("WEAPON_RAILGUN")] = true
    },
    [39] = {
        [GetHashKey("WEAPON_SNOWBALL")] = true
    },
    -- [40] = GetHashKey("WEAPON_PROXMINE"), when holding this returns unarmed
}

WeaponsList.KnownWeaponHashes = {
    [645564] = true
}