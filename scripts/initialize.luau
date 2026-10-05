--!strict
local fs = require("@lune/fs")
local process = require("@lune/process")
local serde = require("@lune/serde")
local Project = require("./lib/Project")
Project.root()
local options = Project.options(process.args, { "--name", "--namespace", "--concept" }, { "--dry-run" })
local name = options["--name"]
local namespace = options["--namespace"]
local concept = options["--concept"]
assert(
	type(name) == "string" and name:match("^[%w][%w _%-]*$") and #name <= 64,
	"--name: 1-64 ASCII letters, digits, spaces, _ or -; start with a letter/digit."
)
assert(name ~= "MYGAME", "Choose your own game name.")
assert(
	type(namespace) == "string" and namespace:match("^[%w_%-]+$") and #namespace <= 40 and namespace ~= "MYGAME",
	"--namespace: 1-40 ASCII letters, digits, _ or -; choose a unique namespace."
)
assert(
	type(concept) == "string" and concept:match("%S") and not concept:match("[%c]"),
	"--concept must be one nonempty line."
)

local statePath = ".vibeblox/project.json"
if fs.isFile(statePath) then
	local state = Project.json(statePath)
	assert(
		state.name == name and state.namespace == namespace and state.concept == concept,
		"Already initialized with different values. Edit project files intentionally; init will not rename an existing game."
	)
	print("Already initialized; game files left unchanged.")
	process.exit(0)
end

local version, gitRoot = pcall(Project.exec, "git", { "rev-parse", "--show-toplevel" })
assert(version, "Initialize a Git repository before running init.")
local function normalize(path: string)
	path = path:gsub("\\", "/"):gsub("/%s*$", ""):gsub("%s+$", "")
	return if process.os == "windows" then path:lower() else path
end
assert(normalize(gitRoot) == normalize(process.cwd), "The project must be the Git repository root.")
assert(fs.isFile(".githooks/pre-commit"), "Template commit hook is missing.")
local hooks = process.exec("git", { "config", "--get", "core.hooksPath" })
assert(hooks.code == 1 or hooks.ok, "Cannot inspect Git hook configuration.")
assert(
	not hooks.ok or hooks.stdout:match("^%s*(.-)%s*$") == ".githooks",
	"A custom hooksPath is configured; integrate the VibeBlox hook manually before initialization."
)

local updates: { [string]: string } = {}
for _, path in
	{
		"default.project.json",
		"AGENTS.md",
		"src/ReplicatedStorage/Config.luau",
		"src/ServerScriptService/Main.server.luau",
		"src/StarterPlayerScripts/Client.client.luau",
	}
do
	local text = fs.readFile(path)
	assert(text:find("MYGAME", 1, true), `Expected template placeholder missing in {path}; no files changed.`)
	if path == "src/ReplicatedStorage/Config.luau" then
		text = Project.replace(text, "MYGAME_Save_v1", namespace .. "_Save_v1")
	end
	text = Project.replace(text, "MYGAME", name)
	if path == "AGENTS.md" then
		text = Project.replace(text, "Concept: one line - what the player does", "Concept: " .. concept)
	end
	assert(not text:find("MYGAME", 1, true), `Unresolved placeholder in {path}`)
	updates[path] = text
end
local project = serde.decode("json", updates["default.project.json"])
assert(project.name == name, "Project name validation failed.")

local remote = process.exec("git", { "remote", "get-url", "origin" })
if remote.ok and remote.stdout:lower():match("huntaprizle/vibeblox") then
	print(
		"origin still points to the VibeBlox template. Create your game repository and run git remote set-url origin <your-repository-url> before pushing. The remote is left unchanged."
	)
end
local paths = {}
for path in updates do
	table.insert(paths, path)
end
table.sort(paths)
for _, path in paths do
	print(`Configure {path}`)
end
if options["--dry-run"] then
	print("Dry run: no files or Git settings changed.")
	process.exit(0)
end
Project.exec("git", { "config", "--local", "core.hooksPath", ".githooks" })
for _, path in paths do
	fs.writeFile(path, updates[path])
end
fs.writeDir(".vibeblox")
Project.writeJson(statePath, { name = name, namespace = namespace, concept = concept })
print(
	"Initialized. Fill in the remaining game brief in AGENTS.md, then run lune run scripts/doctor.luau and lune run scripts/check.luau."
)
