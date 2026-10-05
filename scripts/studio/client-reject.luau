--!strict
local player = game:GetService("Players").LocalPlayer
local remote = game:GetService("ReplicatedStorage"):WaitForChild("VibeBloxClaimCoin", 10)
assert(remote and remote:IsA("RemoteEvent"), "Remote missing")
local deadline = os.clock() + 10
while player:GetAttribute("VibeBloxSmokeClientReady") ~= true do
	assert(os.clock() < deadline, "Client startup incomplete")
	task.wait(0.1)
end
remote:FireServer("starter-coin") -- Valid ID from too far away must be rejected.
remote:FireServer(500) -- Client must not be able to choose its reward.
remote:FireServer("unknown-coin")
task.wait(0.5)
assert(player:GetAttribute("VibeBloxSmokeCoins") == 0, "Invalid request awarded coins")
return "VIBEBLOX_PASS"
