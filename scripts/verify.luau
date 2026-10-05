--!strict
local fs = require("@lune/fs")
local process = require("@lune/process")
local Project = require("./lib/Project")
local Mcp = require("./lib/Mcp")
local Verify = require("./lib/Verify")
Project.root()
local options = Project.options(process.args, { "--studio" }, { "--negative-control" })
local client
local report
local ok, err = pcall(function()
	client = Mcp.connect(nil, nil, 45)
	local tools = client.tools()
	assert(tools.list_roblox_studios, "Studio discovery tool is unavailable. Update Roblox Studio.")
	report = Verify.run(client, tools, options["--studio"], options["--negative-control"])
end)
if client then
	client.close()
end
if not ok then
	report = { status = "unavailable", error = tostring(err) }
end
fs.writeDir(".vibeblox")
Project.writeJson(".vibeblox/verify.json", report)
print(`Studio verification: {report.status}. Evidence: .vibeblox/verify.json`)
if report.error then
	warn(report.error)
end
if report.cleanupError then
	warn(
		"Cleanup failed: "
			.. report.cleanupError
			.. ". Stop Play and remove Workspace's VibeBloxVerify attribute manually."
	)
end
-- Lune 0.10.5 maps nonzero script exit statuses to CLI exit 1;
-- use report.status to distinguish unavailable from failed.
process.exit(if report.status == "passed" then 0 else 1)
