--!strict
local player = assert(game:GetService("Players"):GetPlayers()[1], "No player")
assert(player:GetAttribute("VibeBloxSmokeCoins") == 1, "Authoritative balance should be exactly one")
return "VIBEBLOX_PASS"
