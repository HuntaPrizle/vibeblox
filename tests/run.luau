--!strict
-- Lune tests for this game (run: `lune run tests/run.luau`).
-- Require shared modules by file path and check pure logic.
-- Grow this suite with every tuning change; never shrink it.

local Config = require("../src/ReplicatedStorage/Config")
local SmokeLogic = require("../src/ReplicatedStorage/SmokeLogic")

local passed = 0

local function check(name: string, cond: boolean)
	if not cond then
		error(`FAIL: {name}`, 2)
	end
	passed += 1
	print(`ok: {name}`)
end

check("game name set", Config.GameName ~= "")
check("save versioned", Config.SaveVersion >= 1)
check("commas small", Config.FormatCommas(999) == "999")
check("commas thousands", Config.FormatCommas(1234567) == "1,234,567")
check("commas negative", Config.FormatCommas(-42) == "-42")

local fresh = Config.NewProfile()
check("fresh profile starts at zero", fresh.Coins == 0 and fresh.Wins == 0)

check("smoke example setting is boolean", type(Config.SmokeExampleEnabled) == "boolean")
check("valid claim", SmokeLogic.CanClaim("starter-coin", 5, false))
check("boundary claim", SmokeLogic.CanClaim("starter-coin", 12, false))
check("out of range rejected", not SmokeLogic.CanClaim("starter-coin", 12.1, false))
check("duplicate rejected", not SmokeLogic.CanClaim("starter-coin", 5, true))
check("unknown id rejected", not SmokeLogic.CanClaim("wrong", 5, false))
check("client reward rejected", not SmokeLogic.CanClaim(500, 5, false))
check("invalid distance rejected", not SmokeLogic.CanClaim("starter-coin", -1, false))
check("NaN distance rejected", not SmokeLogic.CanClaim("starter-coin", 0 / 0, false))

print(`\n{passed} checks passed`)
