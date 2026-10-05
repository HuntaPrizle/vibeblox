--!strict
-- MYGAME server entry point. Game systems are added here.
-- Rule: validate everything here, never trust the client.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ConfigModule = ReplicatedStorage:WaitForChild("Config")
local Config = require(ConfigModule)
local ExampleModule = script.Parent:WaitForChild("SmokeExample")
local SmokeExample = require(ExampleModule)
if Config.SmokeExampleEnabled or game:GetService("Workspace"):GetAttribute("VibeBloxVerify") == true then
	SmokeExample.Start()
end
game:GetService("Workspace"):SetAttribute("VibeBloxServerReady", true)
print("[MYGAME] server ready")
