--!strict
local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")
local Project = require("../scripts/lib/Project")
local Mcp = require("../scripts/lib/Mcp")
local Verify = require("../scripts/lib/Verify")
local passed = 0
local function check(name: string, condition: boolean)
	assert(condition, "FAIL: " .. name)
	passed += 1
	print("ok: " .. name)
end
local root = Project.root()
local fixture = ".vibeblox/workflow-fixture-" .. tostring(math.floor(os.clock() * 1000000))
fs.writeDir(fixture)
local function copy(path: string)
	if fs.isDir(path) then
		fs.writeDir(fixture .. "/" .. path)
		for _, child in fs.readDir(path) do
			copy(path .. "/" .. child)
		end
	else
		fs.writeFile(fixture .. "/" .. path, fs.readFile(path))
	end
end
local ok, err = pcall(function()
	for _, path in
		{
			"scripts",
			"src",
			".githooks",
			"tests/run.luau",
			"AGENTS.md",
			"default.project.json",
			"rokit.toml",
			"stylua.toml",
		}
	do
		if path == "tests/run.luau" then
			fs.writeDir(fixture .. "/tests")
		end
		copy(path)
	end
	Project.exec("git", { "init", "--quiet" }, root .. "/" .. fixture)
	local function init(args: { string })
		local command = { "run", "scripts/initialize.luau" }
		for _, arg in args do
			table.insert(command, arg)
		end
		return process.exec("lune", command, { cwd = root .. "/" .. fixture })
	end
	local args = { "--name", "Test Game", "--namespace", "TestGame", "--concept", "Collect coins" }
	-- The workflow suite is valid in initialized games too; reset only fixture placeholders.
	local gameName = require("../src/ReplicatedStorage/Config").GameName
	if gameName ~= "MYGAME" then
		for _, path in
			{
				"AGENTS.md",
				"default.project.json",
				"src/ReplicatedStorage/Config.luau",
				"src/ServerScriptService/Main.server.luau",
				"src/StarterPlayerScripts/Client.client.luau",
			}
		do
			fs.writeFile(
				fixture .. "/" .. path,
				Project.replace(fs.readFile(fixture .. "/" .. path), gameName, "MYGAME")
			)
		end
	end
	local fixtureConfig = fixture .. "/src/ReplicatedStorage/Config.luau"
	local fixtureAgents = fixture .. "/AGENTS.md"
	fs.writeFile(
		fixtureAgents,
		(fs.readFile(fixtureAgents):gsub("%- Concept: [^\r\n]*", "- Concept: one line - what the player does"))
	)
	fs.writeFile(
		fixtureConfig,
		(fs.readFile(fixtureConfig):gsub('Config.DataStoreName = "[^"]*"', 'Config.DataStoreName = "MYGAME_Save_v1"'))
	)
	local dryArgs = table.clone(args)
	table.insert(dryArgs, "--dry-run")
	local before = fs.readFile(fixture .. "/default.project.json")
	Project.exec("git", { "config", "--local", "core.hooksPath", "custom-hooks" }, root .. "/" .. fixture)
	check("custom hooks are not overwritten", not init(dryArgs).ok)
	check("failed preflight preserves files", fs.readFile(fixture .. "/default.project.json") == before)
	Project.exec("git", { "config", "--local", "--unset", "core.hooksPath" }, root .. "/" .. fixture)
	Project.exec(
		"git",
		{ "remote", "add", "origin", "https://github.com/HuntaPrizle/vibeblox.git" },
		root .. "/" .. fixture
	)
	local dry = init(dryArgs)
	assert(dry.ok, dry.stdout .. dry.stderr)
	check("initialization dry run", dry.ok)
	check("template remote warning", dry.stdout:find("origin still points", 1, true) ~= nil)
	check(
		"remote preserved",
		Project.exec("git", { "remote", "get-url", "origin" }, root .. "/" .. fixture)
			:find("HuntaPrizle/vibeblox.git", 1, true) ~= nil
	)
	check(
		"dry run preserves files",
		fs.readFile(fixture .. "/default.project.json") == before
			and not fs.isFile(fixture .. "/.vibeblox/project.json")
	)
	check("initialization succeeds", init(args).ok)
	local initialized = fs.readFile(fixture .. "/src/ReplicatedStorage/Config.luau")
	check(
		"name and namespace configured",
		initialized:find('Config.GameName = "Test Game"', 1, true) ~= nil
			and initialized:find('Config.DataStoreName = "TestGame_Save_v1"', 1, true) ~= nil
	)
	check("concept configured", fs.readFile(fixture .. "/AGENTS.md"):find("Concept: Collect coins", 1, true) ~= nil)
	check(
		"hook configured",
		Project.exec("git", { "config", "--get", "core.hooksPath" }, root .. "/" .. fixture):match(".githooks") ~= nil
	)
	fs.writeFile(fixture .. "/src/ReplicatedStorage/Config.luau", initialized .. "-- user edit\n")
	check("repeat initialization succeeds", init(args).ok)
	check(
		"repeat preserves edits",
		fs.readFile(fixture .. "/src/ReplicatedStorage/Config.luau") == initialized .. "-- user edit\n"
	)
	local changed = table.clone(args)
	changed[2] = "Different Game"
	check("different initialization refused", not init(changed).ok)
	local malicious = table.clone(args)
	malicious[2] = 'bad"; os.execute("bad")'
	check("unsafe input refused", not init(malicious).ok)
	check("unknown argument refused", not init({ "--unknown" }).ok)
	-- Fail the first gate step and prove later build steps are not reached.
	fs.writeFile(fixture .. "/tests/run.luau", 'error("intentional gate failure")\n')
	local gate = process.exec("lune", { "run", "scripts/check.luau" }, { cwd = root .. "/" .. fixture })
	check(
		"gate fails with named step",
		not gate.ok and (gate.stdout .. gate.stderr):find("FAIL: Unit tests", 1, true) ~= nil
	)
	check(
		"gate stops before build",
		not fs.isFile(fixture .. "/game.rbxlx") and not fs.isFile(fixture .. "/sourcemap.json")
	)
	fs.writeFile(fixture .. "/tests/run.luau", 'print("fixture unit tests")\n')
	fs.writeFile(fixture .. "/tests/workflow.luau", 'print("fixture workflow tests")\n')
	fs.writeFile(fixture .. "/tests/bad-format.luau", "local bad=  1\n")
	local formattingGate = process.exec("lune", { "run", "scripts/check.luau" }, { cwd = root .. "/" .. fixture })
	check(
		"test formatting is enforced",
		not formattingGate.ok
			and (formattingGate.stdout .. formattingGate.stderr):find("FAIL: Formatting", 1, true) ~= nil
	)
	check("format failure stops before build", not fs.isFile(fixture .. "/game.rbxlx"))
end)
local fixtureAbsolute = root:gsub("\\", "/"):gsub("/$", "") .. "/" .. fixture
local expectedPrefix = root:gsub("\\", "/"):gsub("/$", "") .. "/.vibeblox/workflow-fixture-"
assert(
	fixtureAbsolute:sub(1, #expectedPrefix) == expectedPrefix and not fixtureAbsolute:find("/../", 1, true),
	"Fixture cleanup must stay inside this workspace."
)
fs.removeDir(fixtureAbsolute)
assert(ok, err)

local client = Mcp.connect("lune", { "run", "tests/fixtures/mcp.luau" }, 5)
local transportOk, transportErr = pcall(function()
	check("MCP split-response framing", client.tools().fixture ~= nil)
	check("MCP JSON text decoding", #Mcp.content(client.call("fixture", {})).studios == 0)
	check("MCP error propagation", not pcall(client.request, "fail", {}))
	check("MCP timeout", not pcall(client.request, "hang", {}, 0.05))
end)
client.close()
assert(transportOk, transportErr)

local tools = {}
for name, fields in
	{
		get_studio_state = { "studio_id" },
		get_console_output = { "studio_id" },
		start_stop_play = { "studio_id", "is_start" },
		execute_luau = { "studio_id", "code", "datamodel_type" },
	}
do
	local properties = {}
	for _, field in fields do
		properties[field] = {}
	end
	tools[name] = { inputSchema = { properties = properties, required = fields } }
end
local function verifyFixture(mode: string, explicitId: string?, negative: boolean?)
	local playing = false
	local marked = false
	local stopped = false
	local restored = false
	local fake = {}
	function fake.call(name: string, args: any)
		if name == "list_roblox_studios" then
			return {
				structuredContent = {
					studios = if mode == "absent"
						then {}
						elseif mode == "multiple" then { { id = "one" }, { id = "two" } }
						else { { id = "one" } },
				},
			}
		elseif name == "get_studio_state" then
			return {
				structuredContent = {
					datamodels = if playing or mode == "already-playing" then { "Client", "Server" } else { "Edit" },
				},
			}
		elseif name == "start_stop_play" then
			if mode == "cleanup-error" and not args.is_start then
				error("fixture stop failure")
			end
			playing = args.is_start
			if not playing then
				stopped = true
			end
		elseif name == "execute_luau" then
			if args.code:find('SetAttribute("VibeBloxVerify", true)', 1, true) then
				marked = true
			end
			if args.code:find('SetAttribute("VibeBloxVerify", nil)', 1, true) then
				marked = false
				restored = true
			end
			if
				(mode == "broken" and args.datamodel_type == "Client")
				or args.code:find("broken-client-request", 1, true)
			then
				return { isError = true, content = { { type = "text", text = "assertion failed" } } }
			end
			return { content = { { type = "text", text = assert(args.code:match('return "(VIBEBLOX_PASS_%d+)"')) } } }
		elseif name == "get_console_output" then
			return {
				structuredContent = {
					logs = if mode == "runtime-error" and playing
						then { { level = "Error", message = "broken startup" } }
						else {},
				},
			}
		end
		return { content = {} }
	end
	local report = Verify.run(fake, tools, explicitId, negative)
	return report, stopped, restored, marked
end
check("missing Studio is unavailable", verifyFixture("absent").status == "unavailable")
check("multiple Studios require selection", verifyFixture("multiple").status == "unavailable")
check("existing playtest left alone", verifyFixture("already-playing").status == "unavailable")
check("explicit Studio selection", verifyFixture("multiple", "two").status == "passed")
local success, stopped, restored, marked = verifyFixture("success")
check("verification passes and cleans up", success.status == "passed" and stopped and restored and not marked)
local broken, failureStopped, failureRestored = verifyFixture("broken")
check("broken interaction fails and cleans up", broken.status == "failed" and failureStopped and failureRestored)
check("runtime errors fail verification", verifyFixture("runtime-error").status == "failed")
check("negative control fails", verifyFixture("success", nil, true).status == "failed")
local cleanup = verifyFixture("cleanup-error")
check("cleanup failure cannot pass", cleanup.status == "failed" and cleanup.cleanupError ~= nil)
check(
	"source echoed in an error cannot pass",
	not Verify.hasResult(
		{ content = { { type = "text", text = 'Error running: return "VIBEBLOX_PASS_1"' } } },
		"VIBEBLOX_PASS_1"
	)
)
check(
	"structured runtime errors detected",
	Verify.errors({ logs = { { messageType = "MessageError", message = "failure" } } }).failure == 1
)
print(`\n{passed} workflow checks passed`)
