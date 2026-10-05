--!strict
local player = game:GetService("Players").LocalPlayer
local character = assert(player.Character, "No character")
local root = character:FindFirstChild("HumanoidRootPart")
assert(root and root:IsA("BasePart"), "Root missing")
local world = assert(workspace:FindFirstChild("VibeBloxSmoke"), "World missing")
local coin = world:FindFirstChild("Coin")
assert(coin and coin:IsA("BasePart"), "Coin missing")
local deadline = os.clock() + 10
while (root.Position - coin.Position).Magnitude > 12 do
	assert(os.clock() < deadline, "Server teleport did not replicate")
	task.wait(0.1)
end
local remote = game:GetService("ReplicatedStorage"):FindFirstChild("VibeBloxClaimCoin")
assert(remote and remote:IsA("RemoteEvent"), "Remote missing")
remote:FireServer("starter-coin")
deadline = os.clock() + 10
while player:GetAttribute("VibeBloxSmokeCoins") ~= 1 do
	assert(os.clock() < deadline, "Valid interaction did not award one coin")
	task.wait(0.1)
end
remote:FireServer("starter-coin")
task.wait(0.5)
assert(player:GetAttribute("VibeBloxSmokeCoins") == 1, "Duplicate request awarded twice")
local playerGui = player:WaitForChild("PlayerGui")
local gui = assert(playerGui:FindFirstChild("VibeBloxSmokeGui"), "HUD missing")
local button = gui:FindFirstChild("Claim")
assert(button and button:IsA("TextButton"), "Button missing")
assert(button.Text == "Claim coin (coins: 1)", "HUD did not reflect the server balance")
return "VIBEBLOX_PASS"
