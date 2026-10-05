--!strict
-- Real stdio transport fixture; never connects to Studio or edits a place.
local stdio = require("@lune/stdio")
local serde = require("@lune/serde")
local task = require("@lune/task")
while true do
	local line = stdio.readLine()
	if line == "" then
		break
	end
	local message = serde.decode("json", line)
	if message.id then
		if message.method == "hang" then
			task.wait(10)
		end
		local response = { jsonrpc = "2.0", id = message.id, result = {} }
		if message.method == "initialize" then
			response.result =
				{ protocolVersion = "2024-11-05", capabilities = {}, serverInfo = { name = "fixture", version = "1" } }
		elseif message.method == "tools/list" then
			response.result = { tools = { { name = "fixture", inputSchema = { type = "object", properties = {} } } } }
		elseif message.method == "tools/call" then
			response.result = { content = { { type = "text", text = '{"studios":[]}' } } }
		elseif message.method == "fail" then
			response.result = nil
			response.error = { code = -32601, message = "expected fixture failure" }
		end
		-- Split one JSON response across writes to exercise stream framing.
		local text = serde.encode("json", response) .. "\n"
		stdio.write(text:sub(1, 5))
		task.wait(0.001)
		stdio.write(text:sub(6))
	end
end
