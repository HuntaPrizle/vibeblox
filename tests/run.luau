--!strict
-- Lune tests for MYGAME (run: `lune run tests/run.luau`).
-- Require shared modules by file path and check pure logic.
-- Grow this suite with every tuning change; never shrink it.

local Config = require("../src/ReplicatedStorage/Config")

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

print(`\n{passed} checks passed`)
