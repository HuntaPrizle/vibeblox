--!strict
local fs = require("@lune/fs")
local process = require("@lune/process")
local Project = require("./lib/Project")
local Mcp = require("./lib/Mcp")
Project.root()
local options = Project.options(process.args, {}, { "--studio", "--tools" })
local failed = false
local pins = {}
for name, version in fs.readFile("rokit.toml"):gmatch('([%w%-]+)%s*=%s*"[^"\n]+@([^"\n]+)"') do
	pins[name] = version
end
for _, tool in { "rokit", "lune", "rojo", "stylua", "luau-lsp", "git" } do
	local ok, result = pcall(process.exec, tool, { "--version" })
	if ok and result.ok then
		print(`OK {tool}: {result.stdout:match("^%s*(.-)%s*$")}`)
		if pins[tool] and result.stdout:match("%d+%.%d+%.%d+") ~= pins[tool] then
			failed = true
			warn(`VERSION MISMATCH {tool}: expected {pins[tool]}. Run rokit install from this root.`)
		end
	else
		failed = true
		warn(`MISSING {tool}: install Rokit/Git, then run rokit install.`)
	end
end
if not fs.isFile(".vibeblox/project.json") then
	print(
		"Template has not been initialized. Use scripts/initialize.luau for a new game; leave it unchanged when developing VibeBlox itself."
	)
end
local hooks = process.exec("git", { "config", "--get", "core.hooksPath" })
if not hooks.ok or hooks.stdout:match("^%s*(.-)%s*$") ~= ".githooks" then
	print("Fast commit hook not enabled. Run git config --local core.hooksPath .githooks.")
end
if options["--studio"] or options["--tools"] then
	local client
	local ok, err = pcall(function()
		client = Mcp.connect()
		local tools = client.tools()
		if options["--tools"] then
			Project.writeJson("studio-tools.json", tools)
			print("Available tool schemas written to studio-tools.json (ignored).")
		end
		assert(
			tools.list_roblox_studios,
			"Studio does not expose list_roblox_studios. Update Studio and inspect available tools."
		)
		local studios = Mcp.content(client.call("list_roblox_studios", {}))
		print("Studio discovery:", studios)
		assert(
			type(studios) == "table" and type(studios.studios) == "table" and #studios.studios > 0,
			"No connected Studio sessions. Open a place and enable Studio MCP."
		)
	end)
	if client then
		client.close()
	end
	if not ok then
		warn(`UNAVAILABLE: {err}`)
		process.exit(1)
	end
else
	print("Studio connection unverified. Run with --studio; use --tools to inspect the current MCP schemas.")
end
process.exit(if failed then 1 else 0)
