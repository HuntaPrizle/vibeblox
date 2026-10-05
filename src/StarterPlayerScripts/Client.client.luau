--!strict
-- MYGAME client entry point. Build UI and input handling here.
-- Rule: the client displays, the server decides.

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ConfigModule = ReplicatedStorage:WaitForChild("Config")
local Config = require(ConfigModule)
local ExampleModule = script.Parent:WaitForChild("SmokeExample")
local SmokeExample = require(ExampleModule)
if Config.SmokeExampleEnabled or game:GetService("Workspace"):GetAttribute("VibeBloxVerify") == true then
	SmokeExample.Start()
end
print("[MYGAME] client ready")
