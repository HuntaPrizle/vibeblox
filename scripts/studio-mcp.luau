--!strict
-- Portable stdio relay for MCP clients. Keep stdout exclusively JSON-RPC.
local process = require("@lune/process")
local stdio = require("@lune/stdio")
local task = require("@lune/task")
local Mcp = require("./lib/Mcp")
local Project = require("./lib/Project")
Project.root()
local command, args = Mcp.launcher()
local child = process.create(command, args)
local drained = 0
for _, stream in { "stdout", "stderr" } do
	task.spawn(function()
		while true do
			local chunk = child[stream]:read(65536)
			if chunk == nil then
				break
			end
			if stream == "stdout" then
				stdio.write(chunk)
			else
				stdio.ewrite(chunk)
			end
		end
		drained += 1
	end)
end
task.spawn(function()
	while true do
		local line = stdio.readLine()
		if line == "" then
			break
		end
		child.stdin:write(line .. "\n")
	end
	child.stdin:close()
end)
local status = child:status()
while drained < 2 do
	task.wait(0.01)
end
process.exit(status.code)
