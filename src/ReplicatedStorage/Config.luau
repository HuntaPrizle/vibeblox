--!strict
-- MYGAME shared tuning + pure helpers.
-- No services touched here, safe to require from server, client, and lune tests.
-- Keep this module plain data only (no Color3/Vector3/etc): lune imports it
-- for tests, and those engine types don't exist there.

export type Profile = {
	Coins: number,
	Wins: number,
}

local Config = {}

Config.GameName = "MYGAME"

-- Optional session-only example; scripts/verify.luau enables it temporarily in Studio.
Config.SmokeExampleEnabled = false

-- Persistence settings only: this starter does not load or save player data.
Config.SaveVersion = 1
Config.DataStoreName = "MYGAME_Save_v1"
Config.AutosaveSeconds = 60
Config.SaveRetries = 3

function Config.FormatCommas(value: number): string
	local n = math.floor(math.abs(value))
	local digits = tostring(n)
	local out = ""
	while #digits > 3 do
		out = "," .. digits:sub(-3) .. out
		digits = digits:sub(1, -4)
	end
	out = digits .. out
	if value < 0 then
		out = "-" .. out
	end
	return out
end

function Config.NewProfile(): Profile
	return {
		Coins = 0,
		Wins = 0,
	}
end

return Config
