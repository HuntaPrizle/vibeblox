--!strict
local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")

local Project = {}

function Project.root()
	assert(fs.isFile("default.project.json") and fs.isFile("rokit.toml"), "Run this command from the project root.")
	return process.cwd
end

function Project.options(args: { string }, values: { string }, flags: { string })
	local result: { [string]: any } = {}
	local index = 1
	while index <= #args do
		local name = args[index]
		assert(result[name] == nil, `Duplicate argument: {name}`)
		if table.find(flags, name) then
			result[name] = true
		elseif table.find(values, name) then
			index += 1
			assert(args[index] and not args[index]:match("^%-%-"), `Missing value for {name}`)
			result[name] = args[index]
		else
			error(`Unknown argument: {name}`)
		end
		index += 1
	end
	return result
end

function Project.json(path: string)
	return serde.decode("json", fs.readFile(path))
end

function Project.writeJson(path: string, value: any)
	fs.writeFile(path, serde.encode("json", value, true) .. "\n")
end

function Project.exec(program: string, args: { string }, cwd: string?)
	local result = process.exec(program, args, { cwd = cwd or process.cwd })
	assert(result.ok, `{program} failed ({result.code}): {result.stderr}{result.stdout}`)
	return result.stdout
end

function Project.replace(text: string, old: string, new: string): string
	return (text:gsub(old:gsub("(%W)", "%%%1"), function()
		return new
	end))
end

return Project
