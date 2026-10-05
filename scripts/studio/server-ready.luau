--!strict
local Players = game:GetService("Players")
local player = Players:GetPlayers()[1]
local deadline = os.clock() + 15
while not player do
	assert(os.clock() < deadline, "No test player joined")
	task.wait(0.1)
	player = Players:GetPlayers()[1]
end
assert(workspace:GetAttribute("VibeBloxServerReady") == true, "Server startup incomplete")
assert(player:GetAttribute("VibeBloxSmokeCoins") == 0, "Expected fresh session balance")
local character = player.Character or player.CharacterAdded:Wait()
local root = character:WaitForChild("HumanoidRootPart", 10)
assert(root and root:IsA("BasePart"), "Player root missing")
root.Anchored = true
root.CFrame = CFrame.new(28, 4, 0)
return "VIBEBLOX_PASS"
