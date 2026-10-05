--!strict
local SmokeExample = {}

function SmokeExample.Start()
	local Players = game:GetService("Players")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local player = Players.LocalPlayer
	local remote = ReplicatedStorage:WaitForChild("VibeBloxClaimCoin", 10)
	assert(remote and remote:IsA("RemoteEvent"), "Smoke example remote missing")
	local gui = Instance.new("ScreenGui")
	gui.Name = "VibeBloxSmokeGui"
	gui.ResetOnSpawn = false
	gui.Parent = player:WaitForChild("PlayerGui")
	local button = Instance.new("TextButton")
	button.Name = "Claim"
	button.Size = UDim2.fromOffset(240, 64)
	button.Position = UDim2.new(0.5, -120, 0.8, 0)
	button.Parent = gui
	local function update()
		button.Text = `Claim coin (coins: {player:GetAttribute("VibeBloxSmokeCoins") or 0})`
	end
	player:GetAttributeChangedSignal("VibeBloxSmokeCoins"):Connect(update)
	button.Activated:Connect(function()
		remote:FireServer("starter-coin")
	end)
	update()
	player:SetAttribute("VibeBloxSmokeClientReady", true)
end

return SmokeExample
