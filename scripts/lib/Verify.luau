--!strict
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local task = require("@lune/task")
local Mcp = require("./Mcp")
local Project = require("./Project")

local Verify = {}

function Verify.hasResult(result: any, marker: string): boolean
	if result.isError then
		return false
	end
	local value = Mcp.content(result)
	if type(value) == "string" then
		return value:match("^%s*(.-)%s*$") == marker
	end
	return type(value) == "table" and not value.error and value.success ~= false and value.result == marker
end

function Verify.errors(value: any): { [string]: number }
	local errors = {}
	local function visit(node: any)
		if type(node) == "string" then
			for line in node:gmatch("[^\n]+") do
				if
					line:find("MessageError", 1, true)
					or line:match("%[ERROR%]")
					or line:match("%[Error%]")
					or line:match("^%s*Error:")
				then
					errors[line] = (errors[line] or 0) + 1
				end
			end
		elseif type(node) == "table" then
			for _, key in { "type", "messageType", "message_type", "level", "severity" } do
				if type(node[key]) == "string" and node[key]:lower():find("error", 1, true) then
					local signature = tostring(node.message or node.text or node.output or serde.encode("json", node))
					errors[signature] = (errors[signature] or 0) + 1
					return
				end
			end
			for _, child in node do
				visit(child)
			end
		end
	end
	visit(value)
	return errors
end

function Verify.run(client: any, tools: any, studioId: string?, negativeControl: boolean?)
	local report: any = { status = "unavailable", steps = {}, negativeControl = negativeControl == true }
	local started = false
	local marked = false
	local attempted = false
	local marker = "VIBEBLOX_PASS_" .. tostring(math.floor(os.clock() * 1000000))
	local function call(name: string, args: any)
		args.studio_id = report.studioId
		return client.call(name, args)
	end
	local function execute(label: string, code: string, model: string)
		local result =
			call("execute_luau", { code = Project.replace(code, "VIBEBLOX_PASS", marker), datamodel_type = model })
		table.insert(report.steps, { name = label, result = result })
		assert(
			Verify.hasResult(result, marker),
			`{label}: assertion result missing; inspect the tool output in the report.`
		)
		return result
	end
	local function editState()
		local state = Mcp.content(call("get_studio_state", {}))
		local text = serde.encode("json", state)
		assert(
			text:find("Edit", 1, true) and not text:find("Client", 1, true) and not text:find("Server", 1, true),
			"Studio must be idle in Edit mode. Existing playtests are left alone; unknown state formats are unsupported."
		)
		return state
	end
	local ok, err = pcall(function()
		local discovery = Mcp.content(client.call("list_roblox_studios", {}))
		assert(
			type(discovery) == "table" and type(discovery.studios) == "table",
			"Unsupported Studio discovery response."
		)
		local studios = discovery.studios
		report.studios = studios
		assert(#studios > 0, "No connected Studio sessions. Open the built place and enable Studio MCP.")
		if studioId then
			for _, studio in studios do
				if studio.id == studioId then
					report.studioId = studioId
				end
			end
			assert(report.studioId, "Requested Studio ID is not connected.")
		else
			assert(#studios == 1, "Multiple Studio sessions connected. Choose one with --studio <id>.")
			report.studioId = studios[1].id
		end
		assert(type(report.studioId) == "string", "Studio discovery omitted the instance ID.")
		for name, fields in
			{
				get_studio_state = { "studio_id" },
				get_console_output = { "studio_id" },
				start_stop_play = { "studio_id", "is_start" },
				execute_luau = { "studio_id", "code", "datamodel_type" },
			}
		do
			local tool = assert(tools[name], `Required tool missing: {name}. Update Studio.`)
			for _, field in fields do
				assert(tool.inputSchema.properties[field], `Unsupported {name} schema: missing {field}.`)
			end
			for _, field in tool.inputSchema.required or {} do
				assert(table.find(fields, field), `Unsupported required argument: {name}.{field}.`)
			end
		end
		report.initialState = editState()
		local preflight = {
			'assert(workspace:GetAttribute("VibeBloxVerify") == nil, "Existing verification flag; restore the previous interrupted run first")',
		}
		for path, source in
			{
				["game.ReplicatedStorage.Config"] = "src/ReplicatedStorage/Config.luau",
				["game.ReplicatedStorage.SmokeLogic"] = "src/ReplicatedStorage/SmokeLogic.luau",
				["game.ServerScriptService.Main"] = "src/ServerScriptService/Main.server.luau",
				["game.ServerScriptService.SmokeExample"] = "src/ServerScriptService/SmokeExample.luau",
				["game.StarterPlayer.StarterPlayerScripts.Client"] = "src/StarterPlayerScripts/Client.client.luau",
				["game.StarterPlayer.StarterPlayerScripts.SmokeExample"] = "src/StarterPlayerScripts/SmokeExample.luau",
			}
		do
			local expected = fs.readFile(source):gsub("\r\n", "\n")
			table.insert(
				preflight,
				string.format(
					'assert(%s.Source:gsub("\\r\\n", "\\n") == %q, "Studio source differs: %s; rebuild/reconnect Rojo")',
					path,
					expected,
					path
				)
			)
		end
		table.insert(preflight, 'return "VIBEBLOX_PASS"')
		execute("Check source identity", table.concat(preflight, "\n"), "Edit")
		report.baselineLogs = call("get_console_output", {})
		attempted = true
		marked = true -- Set before the call so a partial failure still attempts restoration.
		execute(
			"Enable example temporarily",
			'workspace:SetAttribute("VibeBloxVerify", true); return "VIBEBLOX_PASS"',
			"Edit"
		)
		started = true
		call("start_stop_play", { is_start = true })
		local deadline = os.clock() + 20
		repeat
			local state = serde.encode("json", Mcp.content(call("get_studio_state", {})))
			if state:find("Client", 1, true) and state:find("Server", 1, true) then
				break
			end
			assert(os.clock() < deadline, "Playtest did not expose Client and Server datamodels.")
			task.wait(0.2)
		until false
		for _, step in
			{
				{ "Server startup", "server-ready", "Server" },
				{ "Reject invalid requests", "client-reject", "Client" },
				{ "Move into range", "server-near", "Server" },
				{ "Claim once and update HUD", "client-claim", "Client" },
				{ "Authoritative server balance", "server-result", "Server" },
			}
		do
			local code = fs.readFile(`scripts/studio/{step[2]}.luau`)
			if negativeControl and step[2] == "client-claim" then
				code = Project.replace(
					code,
					'remote:FireServer("starter-coin")',
					'remote:FireServer("broken-client-request")'
				)
			end
			execute(step[1], code, step[3])
		end
	end)
	if attempted then
		local logOk, logs = pcall(call, "get_console_output", {})
		if logOk then
			report.logs = logs
			local baseline = Verify.errors(Mcp.content(report.baselineLogs))
			for signature, count in Verify.errors(Mcp.content(logs)) do
				if count > (baseline[signature] or 0) then
					ok = false
					err = `New runtime error: {signature}`
				end
			end
		else
			ok = false
			err = `Could not collect runtime logs: {logs}`
		end
	end
	local cleanupOk, cleanupErr = pcall(function()
		if started then
			call("start_stop_play", { is_start = false })
			local deadline = os.clock() + 15
			while not pcall(editState) do
				assert(os.clock() < deadline, "Studio did not return to Edit mode during cleanup.")
				task.wait(0.2)
			end
		end
		if marked then
			execute(
				"Restore Edit state",
				'workspace:SetAttribute("VibeBloxVerify", nil); return "VIBEBLOX_PASS"',
				"Edit"
			)
		end
	end)
	if not cleanupOk then
		report.cleanupError = tostring(cleanupErr)
		err = err or `Cleanup failed: {cleanupErr}`
		ok = false
	end
	if not ok then
		report.error = tostring(err)
	end
	report.status = if ok then "passed" elseif attempted or not cleanupOk then "failed" else "unavailable"
	return report
end

return Verify
