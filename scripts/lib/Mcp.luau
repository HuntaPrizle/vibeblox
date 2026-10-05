--!strict
local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")
local task = require("@lune/task")

local Mcp = {}

function Mcp.launcher()
	if process.os == "windows" then
		local path = assert(process.env.LOCALAPPDATA, "LOCALAPPDATA is missing") .. "\\Roblox\\mcp.bat"
		assert(fs.isFile(path), "Studio MCP launcher missing. Install/update Roblox Studio and enable its MCP server.")
		return "cmd.exe", { "/d", "/c", path }
	end
	assert(process.os == "macos", "Studio MCP requires Windows or macOS.")
	local path = "/Applications/RobloxStudio.app/Contents/MacOS/StudioMCP"
	assert(fs.isFile(path), "Studio MCP launcher missing. Install/update Roblox Studio.")
	return path, {}
end

function Mcp.connect(command: string?, args: { string }?, timeout: number?)
	if not command then
		command, args = Mcp.launcher()
	end
	local child = process.create(command, args or {})
	local responses: { [number]: any } = {}
	local stderr = ""
	local closed = false
	local failure: string? = nil
	local sequence = 0
	local client = {}

	task.spawn(function()
		local ok, err = pcall(function()
			local buffer = ""
			while not closed do
				local chunk = child.stdout:read(65536)
				if chunk == nil then
					failure = "MCP process closed its output. " .. stderr
					break
				end
				buffer ..= chunk
				while buffer:find("\n", 1, true) do
					local finish = assert(buffer:find("\n", 1, true))
					local line = buffer:sub(1, finish - 1)
					buffer = buffer:sub(finish + 1)
					if line:match("%S") then
						local message = serde.decode("json", line)
						if message.id ~= nil and (message.result ~= nil or message.error ~= nil) then
							responses[message.id] = message
						elseif message.id ~= nil then
							child.stdin:write(serde.encode("json", {
								jsonrpc = "2.0",
								id = message.id,
								error = { code = -32601, message = "Client requests not supported" },
							}) .. "\n")
						end
					end
				end
			end
		end)
		if not ok then
			failure = tostring(err)
		end
	end)
	task.spawn(function()
		pcall(function()
			while not closed do
				local chunk = child.stderr:read()
				if not chunk then
					break
				end
				stderr = (stderr .. chunk):sub(-8000)
			end
		end)
	end)

	function client.close()
		if closed then
			return
		end
		closed = true
		pcall(function()
			child.stdin:close()
		end)
		pcall(function()
			child:kill()
		end)
	end

	function client.request(method: string, params: any?, requestTimeout: number?)
		sequence += 1
		local id = sequence
		child.stdin:write(serde.encode("json", { jsonrpc = "2.0", id = id, method = method, params = params }) .. "\n")
		local deadline = os.clock() + (requestTimeout or timeout or 30)
		while responses[id] == nil do
			assert(not failure, failure)
			assert(os.clock() < deadline, `MCP request timed out: {method}. {stderr}`)
			task.wait(0.01)
		end
		local message = responses[id]
		responses[id] = nil
		assert(not message.error, serde.encode("json", message.error))
		return message.result
	end

	local ok, err = pcall(function()
		client.request(
			"initialize",
			{ protocolVersion = "2024-11-05", capabilities = {}, clientInfo = { name = "vibeblox", version = "1.0.0" } }
		)
		child.stdin:write(serde.encode("json", { jsonrpc = "2.0", method = "notifications/initialized" }) .. "\n")
	end)
	if not ok then
		client.close()
		error(err)
	end

	function client.tools()
		local tools = {}
		local cursor = nil
		repeat
			local page = client.request("tools/list", if cursor then { cursor = cursor } else {})
			for _, tool in page.tools do
				tools[tool.name] = tool
			end
			cursor = page.nextCursor
		until cursor == nil
		return tools
	end

	function client.call(name: string, arguments: any)
		local result = client.request("tools/call", { name = name, arguments = arguments })
		assert(not result.isError, serde.encode("json", result))
		return result
	end

	return client
end

function Mcp.content(result: any)
	if result.structuredContent then
		return result.structuredContent
	end
	local parts = {}
	for _, item in result.content or {} do
		if item.type == "text" then
			table.insert(parts, item.text)
		end
	end
	local text = table.concat(parts, "\n")
	local ok, value = pcall(serde.decode, "json", text)
	return if ok then value else text
end

return Mcp
