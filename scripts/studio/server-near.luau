--!strict
local player = assert(game:GetService("Players"):GetPlayers()[1], "No player")
assert(player:GetAttribute("VibeBloxSmokeCoins") == 0, "Invalid request changed server balance")
local character = assert(player.Character, "No character")
local root = character:FindFirstChild("HumanoidRootPart")
assert(root and root:IsA("BasePart"), "Root missing")
local world = assert(workspace:FindFirstChild("VibeBloxSmoke"), "Example world missing")
local coin = world:FindFirstChild("Coin")
assert(coin and coin:IsA("BasePart"), "Coin missing")
root.CFrame = coin.CFrame + Vector3.new(0, 2, 0)
return "VIBEBLOX_PASS"
