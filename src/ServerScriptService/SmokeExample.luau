--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local LogicModule = ReplicatedStorage:WaitForChild("SmokeLogic")
local SmokeLogic = require(LogicModule)

local SmokeExample = {}

function SmokeExample.Start()
	local Players = game:GetService("Players")
	local Workspace = game:GetService("Workspace")
	local world = Instance.new("Folder")
	world.Name = "VibeBloxSmoke"
	world.Parent = Workspace

	local floor = Instance.new("Part")
	floor.Name = "Floor"
	floor.Anchored = true
	floor.Size = Vector3.new(64, 1, 64)
	floor.Position = Vector3.new(0, -1, 0)
	floor.Parent = world

	local spawn = Instance.new("SpawnLocation")
	spawn.Name = "Spawn"
	spawn.Anchored = true
	spawn.Size = Vector3.new(6, 1, 6)
	spawn.Position = Vector3.new(0, 0, 0)
	spawn.Parent = world

	local coin = Instance.new("Part")
	coin.Name = "Coin"
	coin.Anchored = true
	coin.CanCollide = false
	coin.Shape = Enum.PartType.Ball
	coin.Color = Color3.fromRGB(255, 205, 50)
	coin.Size = Vector3.new(2, 2, 2)
	coin.Position = Vector3.new(6, 3, 0)
	coin.Parent = world

	local remote = Instance.new("RemoteEvent")
	remote.Name = "VibeBloxClaimCoin"
	remote.Parent = ReplicatedStorage
	local claimed: { [Player]: boolean } = {}
	local function initialize(player: Player)
		player:SetAttribute("VibeBloxSmokeCoins", 0)
	end
	Players.PlayerAdded:Connect(initialize)
	for _, player in Players:GetPlayers() do
		initialize(player)
	end
	Players.PlayerRemoving:Connect(function(player)
		claimed[player] = nil
	end)
	remote.OnServerEvent:Connect(function(player: Player, request: unknown)
		local character = player.Character
		local root = if character then character:FindFirstChild("HumanoidRootPart") else nil
		local humanoid = if character then character:FindFirstChildOfClass("Humanoid") else nil
		if not root or not root:IsA("BasePart") or not humanoid or humanoid.Health <= 0 then
			return
		end
		if not SmokeLogic.CanClaim(request, (root.Position - coin.Position).Magnitude, claimed[player] == true) then
			return
		end
		claimed[player] = true
		player:SetAttribute("VibeBloxSmokeCoins", 1)
	end)
end

return SmokeExample
