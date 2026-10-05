--!strict
local process = require("@lune/process")
local Project = require("./lib/Project")
local root = Project.root()
local options = Project.options(process.args, {}, { "--fast" })

local steps = {
	{ "Unit tests", "lune", { "run", "tests/run.luau" } },
	{ "Formatting", "stylua", { "--check", "src/", "tests/", "scripts/" } },
}
if not options["--fast"] then
	table.insert(steps, { "Sourcemap", "rojo", { "sourcemap", "default.project.json", "-o", "sourcemap.json" } })
	table.insert(steps, {
		"Type analysis",
		"luau-lsp",
		{
			"analyze",
			"--sourcemap",
			"sourcemap.json",
			"--definitions:typedefs/globalTypes.PluginSecurity.d.luau",
			"src/",
		},
	})
	table.insert(steps, { "Place build", "rojo", { "build", "-o", "game.rbxlx" } })
end

for index, step in steps do
	print(`[{index}/{#steps}] {step[1]}`)
	local ok, result = pcall(process.exec, step[2], step[3], {
		cwd = root,
		stdio = { stdout = "inherit", stderr = "inherit" },
	})
	if not ok then
		warn(`FAIL: {step[1]}: {result}. For missing tools, run rokit install.`)
		process.exit(1)
	end
	if not result.ok then
		warn(`FAIL: {step[1]} (exit {result.code})`)
		process.exit(if result.code ~= 0 then result.code else 1)
	end
end
print(
	if options["--fast"]
		then "Fast checks passed. Run the full gate before submitting."
		else "Full quality gate passed."
)
