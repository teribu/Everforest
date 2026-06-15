--!nolint
--!nocheck
--!native
--!optimize 2

--[[
    Wax - A Fast Runtime-Based Lua 5.1x+/Luau Project Bundler, Using Roblox Models and Module-Require Semantics
    MIT License | Copyright (c) 2023-2025 Latte Softworks <https://latte.to>

    Wax Version: 0.4.2
]]

------------------------------------------------------------------------------------------------------

-- ++++++++ WAX BUNDLED DATA BELOW ++++++++ --

-- Will be used later for getting flattened globals
local ImportGlobals

-- Holds direct closure data (defining this before the DOM tree for line debugging etc)
local ClosureBindings = {
    function()local wax,script,require=ImportGlobals(1)local ImportGlobals return (function(...)-- MIT License | Copyright (c) 2023-2025 Latte Softworks <https://latte.to>

if string.sub(_VERSION, 1, 4) ~= "Lune" then
	print(
		"!! Wax doesn't appear to be running on Lune (https://lune-org.github.io/docs), which this script requires, exitting.."
	)
	return
end

do
	-- Minimum "recommended" ver
	local MajorRec, MinorRec, PatchRec = 0, 8, 0

	local Major, Minor, Patch = string.match(_VERSION, "Lune (%d+).(%d+).(%d+)")

	Major, Minor, Patch = tonumber(Major), tonumber(Minor), tonumber(Patch)

	if not Major then
		print(`! Can't parse Lune's version on the assumed format from "{_VERSION}", continuing anyway..\n`)
	else
		_G.LuneVersion = `{Major}.{Minor}.{Patch}`
		if
			Major < MajorRec
			or (Minor < MinorRec and Major <= MajorRec)
			or (Patch < PatchRec and Minor <= MinorRec and Major <= MajorRec)
		then
			print(
				`! Lune version "{_G.LuneVersion}" detected, but Wax currently recommends Lune {MajorRec}.{MinorRec}.{PatchRec} or higher, continuing anyway..\n`
			)
		end
	end
end

local fs = require("@lune/fs")
local serde = require("@lune/serde")
local stdio = require("@lune/stdio")
local roblox = require("@lune/roblox")
local process = require("@lune/process")

local LuneUtils = require("./lib/libraries/LuneUtils")
local BundleModel = require("./lib/BundleModel")

local Version = require("./lib/data/Version")
local DefaultDarkluaConfig = require("./lib/data/DefaultDarkluaConfig")

local Log = LuneUtils.Log
local StringUtils = LuneUtils.StringUtils
local CommandUtils = LuneUtils.CommandUtils
local Run = LuneUtils.Run
local ParseArgs = LuneUtils.ParseArgs

local UsageMessage = `Wax {Version}\n`
	.. [[
A Fast Runtime-Based Lua 5.1x+/Luau Project Bundler, Using Roblox Models and Module-Require Semantics

USAGE:
    lune run wax [subcommand] [options]

* When no subcommand is provided, this usage message is displayed
* Provide all options in the following format (no "--" flag prefix): option=value

SUBCOMMANDS:
    help      Displays this usage message

    version   Displays Wax's version

    bundle    Builds a bundled script file from a given Roblox model (*.rbxm/*.rbxmx)
              or Rojo project file (*.project.json, requires the `rojo` command
              available in your PATH environment variable), to an output path

      OPTIONS for `bundle`:
      * input[="default.project.json"]
            The input Roblox model (*.rbxm/*.rbxmx) or Rojo project (*.project.json) file
            path for Wax to bundle from

      * output[="{input-filename}.lua"]
            The final output file path (must end in .lua or .luau) for the bundled script

      * minify[=false]
            If codegen output should be "minified", which also omits any runtime line
            debugging info (offsets). For 'full' codegen minification (outside of just
            LuaEncode's table output), you must have the `darklua` command available in
            your PATH environment variable.
            Additionally, with Darklua, if a ".darklua.json/json5" file isn't found in the
            CWD (your dir "position" in your terminal), it'll use the default configuration
            we provide (see `lune/lib/data/DefaultDarkluaConfig.luau`)

      * env-name[="WaxRuntime"]
            The name of the "environment" of the bundled script. This is the "name" of
            the root object (like the `game` DataModel in Roblox) and displays in virtual
            runtime errors (e.g. "[WaxRuntime].Script:1: Some error message")

      * darklua-config-path[=(".darklua.json", ".darklua.json5")]
            When `minify` is set as true, this path can be used to directly pass your own
            Darklua config file's path, instead of only checking for the default paths
            it looks for

      * temp-dir-base[="{output-dir}"]
            If you're providing a Rojo project file as input or minifying with Darklua,
            a temporary directory is created inside of this directory path, and is removed
            by the time Wax has completed processing

      * extra-offset-lines[=0]
            (Only applicable to when `minify` is set to false) Internally acknowledges
            any extra lines offset from the top of the script (like if you're adding a
            header of sorts to the codegen) for line debugging info. Ths MUST be exactly
            accurate to its name (*extra* lines, so you may want to do something like
            `#ExtraHeader - 1` if you're using this option)

      * ci-mode[=false]
            (*Primarily* for automated CI pipelines or deployment systems) Never gives
            any user input prompts, and will *always* exit with a `1` status code upon an
            'error' or warning during the build process

      * verbose[=true]
            "Verbose" (detailed) output logging from CLI/bundler
]]

local DirectionToHelp = "Run `lune wax help` for more info"

-- Flush out any other previous ANSI nonsense
stdio.write(stdio.color("reset") .. stdio.style("reset"))

local function EncodeShellData(shellData: string): string
	return if process.os == "windows"
		then shellData -- I swear, Windows makes everything worse
		else '"' .. StringUtils.SerializeStringData(shellData) .. '"'
end

local CommandArgs = table.clone(process.args)
local Subcommand = table.remove(CommandArgs, 1)

if not Subcommand then
	print(UsageMessage)
	return
end

Subcommand = string.lower(Subcommand)

if Subcommand == "help" then
	print(UsageMessage)
	return
elseif Subcommand == "version" then
	print(`Wax v{Version}`)
	return
elseif Subcommand == "bundle" then
	-- Below is our user-proofing hell!
	-- “An idiot admires complexity, a genius admires simplicity" - Terry A Davis

	-- Parse and init default CLI options
	local Options = ParseArgs(CommandArgs, {
		-- Option = {Type, DefaultValue, IsRequired?}
		["input"] = { "string", "default.project.json" },
		["output"] = { "string", nil },
		["minify"] = { "boolean", false },
		["env-name"] = { "string", nil }, -- BundleModel() internally defaults to "WaxRuntime"
		["darklua-config-path"] = { "string", nil },
		["temp-dir-base"] = { "string", nil },
		["extra-offset-lines"] = { "number", 0 },
		["ci-mode"] = { "boolean", false },
		["verbose"] = { "boolean", true },
	}, UsageMessage)

	local Verbose = Options["verbose"]
	local CIMode = Options["ci-mode"]

	local Minify = Options["minify"]
	local EnvName = Options["env-name"]

	local function RunIfVerbose(f, ...)
		if Verbose then
			f(...)
		end
	end

	-- These is being defined here since we're utilizing RunIfVerbose()
	local function WriteFile(path: string, contents: string)
		RunIfVerbose(Log.Info, `Writing to "{path}"..`)
		fs.writeFile(path, contents)
	end

	local function RemoveFile(path: string)
		RunIfVerbose(Log.Info, `Deleting file at "{path}"..`)
		fs.removeFile(path)
	end

	local function WriteDir(path: string)
		RunIfVerbose(Log.Info, `Creating directory at "{path}"..`)
		fs.writeDir(path)
	end

	local function RemoveDir(path: string)
		RunIfVerbose(Log.Info, `Removing directory at "{path}"..`)
		fs.removeDir(path)
	end

	-- `input` option handling:

	local Input = Options["input"]

	if not fs.isFile(Input) then
		Log.Error(`Failed to find file path "{Input}" from \`input\` option\n`)
		print(DirectionToHelp)
		process.exit(1)
	end

	local InputDirectory = StringUtils.DirectoryOfFilePath(Input) or ""

	local InputLower = string.lower(Input)
	local InputType = if string.sub(InputLower, -5) == ".rbxm"
		then ".rbxm" -- Roblox model (binary)
		elseif string.sub(InputLower, -6) == ".rbxmx" then ".rbxmx" -- Roblox model (XML)
		elseif string.sub(InputLower, -13) == ".project.json" then ".project.json" -- Rojo project file
		else nil

	if not InputType then
		Log.Error(
			`Invalid file type ".{StringUtils.FileType(Input)}" for \`input\`, expected [".rbxm", ".rbxmx", ".project.json"]\n`
		)
		print(DirectionToHelp)
		process.exit(1)
	end

	-- `output` option handling:

	local Output = Options["output"]

	if not Output then
		local NewOutputBase

		if InputType == ".project.json" then
			local ParseSuccess, ErrorOrParsed = pcall(serde.decode, "json" :: "json", fs.readFile(Input))

			if not ParseSuccess then
				Log.Error(`Failed to parse Rojo project file at "{Input}": {ErrorOrParsed}`)
				process.exit(1)
			end

			if not ErrorOrParsed.name or type(ErrorOrParsed.name) ~= "string" then
				Log.Warn(
					`Couldn't find proper "name" entry at the root of Rojo project file at "{Input}", using its file name base instead..`
				)
			else
				NewOutputBase = ErrorOrParsed.name
			end
		end

		-- If it's not a Rojo project file or `NewOutputBase` still hasn't been set..
		if not NewOutputBase then
			NewOutputBase = StringUtils.FilePathWithoutExtension(Input, false)
		end

		if not NewOutputBase then
			Log.InternalError(`Failed to get file path without the extension for "{Output}"`)
			process.exit(1)
		end

		NewOutputBase ..= ".wax.lua"
		Output = InputDirectory .. NewOutputBase
	else
		local OutputFileType = StringUtils.FileType(Output)
		local DirectoryOfOutput = StringUtils.DirectoryOfFilePath(Output)

		if not DirectoryOfOutput then
			Log.Error(`\`output\` file path given, "{Output}" not a valid path\n`)
			print(DirectionToHelp)
			process.exit(1)
		elseif not fs.isDir(DirectoryOfOutput) then
			Log.Error(`Directory of \`output\` file path given, "{DirectoryOfOutput}" not found/invalid\n`)
			print(DirectionToHelp)
			process.exit(1)
		elseif not OutputFileType or not table.find({ "lua", "luau" }, OutputFileType) then
			local FileTypeDisplay = if OutputFileType == "" then "<empty>" else "." .. OutputFileType

			Log.Error(`File type of \`output\` ({FileTypeDisplay}) invalid, expected [".lua", ".luau"]\n`)
			print(DirectionToHelp)
			process.exit(1)
		end
	end

	local OutputFileName = StringUtils.FileNameFromPath(Output)
	if not OutputFileName then
		Log.InternalError(`Failed to parse file name from output file path "{Output}"`)
		process.exit(1)
	end

	local OutputFileNameWithoutExtension = StringUtils.FileNameWithoutExtension(OutputFileName, false)
	if not OutputFileNameWithoutExtension then
		Log.InternalError(`Failed to parse file name without its extension from "{OutputFileName}"`)
		process.exit(1)
	end

	-- `darklua-config-path` option handling:

	DarkluaConfigPath = Options["darklua-config-path"]

	if DarkluaConfigPath and not fs.isFile(DarkluaConfigPath) then
		Log.Error(`File path given for \`darklua-config-path\`, "{DarkluaConfigPath}" not found`)
		process.exit(1)
	end

	-- `temp-dir-base` option handling:

	local TempDirBase = Options["temp-dir-base"]

	if not TempDirBase then
		TempDirBase = StringUtils.DirectoryOfFilePath(Output)
	elseif not fs.isDir(TempDirBase) then
		Log.Error(`\`temp-dir-base\` directory given, "{TempDirBase}" not found/invalid\n`)
		print(DirectionToHelp)
		process.exit(1)
	end

	if not string.match(TempDirBase, "[/\\]$") then
		TempDirBase ..= "/"
	end

	-- The actual temp dir path we'll be using
	local TempDir = TempDirBase .. ".wax-tmp/"

	-- If it already exists for some reason..?
	if fs.isDir(TempDir) then
		RunIfVerbose(Log.Info, `Old .wax-tmp dir at "{TempDir}" already exists, removing..`)
		fs.removeDir(TempDir)
	end

	ExtraOffsetLines = Options["extra-offset-lines"]
	if ExtraOffsetLines < 0 then
		Log.Error(`Option \`extra-offset-lines\` ({ExtraOffsetLines}) cannot be less than 0\n`)
		print(DirectionToHelp)
		process.exit(1)
	end
	if not Minify and ExtraOffsetLines > 0 then
		RunIfVerbose(
			Log.Info,
			`(Note) Runtime line debugging *will* display with the assumption that \`{ExtraOffsetLines}\` lines will be added to the output by you manually; make sure this is EXACT, as debugging info could be inaccurate otherwise`
		)
	end

	-- Now we'll start non-option processing

	-- Now, we may need to eventually worry about exitting upon random unhandled errors
	-- since we may be creating a temp dir in the user's directory
	local function BadExit(message: string?)
		if message then
			Log.Error(message)
		end

		if fs.isDir(TempDir) then
			RemoveDir(TempDir)
		end

		process.exit(1)
	end

	-- Check for necessary commands
	if InputType == ".project.json" and not CommandUtils.CommandExists("rojo") then
		Log.Error(
			`Rojo project file given for input ("{Input}"), but the \`rojo\` command wasn't found in your PATH environment variable..\n`
		)
		print(DirectionToHelp)
		process.exit(1)
	end

	local DarkluaBinaryExists = CommandUtils.CommandExists("darklua")
	if Minify and not DarkluaBinaryExists then
		Log.Warn(
			"The `minify` option is set as true, but the `darklua` command wasn't found in your PATH environment variable.. (Wax won't be able to completely minify the output)"
		)
		if not CIMode then
			local ShouldContinue = stdio.prompt("confirm", "Continue anyway?")
			if not ShouldContinue then
				BadExit()
			end
		end
	end

	-- Create tmp dir if applicable
	if InputType == ".project.json" or (Minify and DarkluaBinaryExists) then
		WriteDir(TempDir)
	end

	local ModelRoot

	if table.find({ ".rbxm", ".rbxmx" }, InputType) then -- Roblox model file (direct)
		RunIfVerbose(Log.Info, `Deserializing Roblox model file at "{Input}"..`)
		local Success, ModelRootOrError = pcall(roblox.deserializeModel, fs.readFile(Input))

		if not Success then -- ModelRootOrError is an err msg
			BadExit(`Failed to deserialize Roblox model file at "{Input}": {ModelRootOrError}`)
		end

		-- Here, it's just the ModelRoot return ofc
		ModelRoot = ModelRootOrError
	elseif InputType == ".project.json" then -- Rojo project file
		local ModelOutputFileName = TempDir .. OutputFileNameWithoutExtension .. ".o.rbxm"
		RunIfVerbose(Log.Info, `Building from Rojo project file to "{ModelOutputFileName}"`)

		Run(
			"rojo",
			{
				"build",
				"-o",
				EncodeShellData(ModelOutputFileName),
				EncodeShellData(Input),
			},
			false,
			BadExit -- Run() has an option to provide an err handler ourselves
		)

		ModelRoot = roblox.deserializeModel(fs.readFile(ModelOutputFileName))
		RemoveFile(ModelOutputFileName) -- Remove temporary rbxm
	end

	local BundleSuccess, CodegenOutputOrError, FailedCompilations =
		pcall(BundleModel, ModelRoot, EnvName, Minify, ExtraOffsetLines, Verbose)

	if not BundleSuccess then
		BadExit(`Error during BundleModel() process: {CodegenOutputOrError}`)
	end

	if Minify and DarkluaBinaryExists then
		local TempOutputFilePath = TempDir .. OutputFileName
		WriteFile(TempOutputFilePath, CodegenOutputOrError)

		RunIfVerbose(Log.Info, "Starting minification process with Darklua")

		local ExtraDarkluaProcessArgs = {}

		-- Check for possible default Darklua cfg files under CWD
		local TempDarkluaConfigPath = TempDir .. ".darklua.json"
		local TempDarkluaConfigWasAdded = false

		if DarkluaConfigPath then
			table.insert(ExtraDarkluaProcessArgs, `-c={EncodeShellData(DarkluaConfigPath)}`)
		elseif not fs.isFile(".darklua.json") and not fs.isFile(".darklua.json5") then
			RunIfVerbose(
				Log.Info,
				`No default Darklua config file found in CWD; creating our default config at "{TempDarkluaConfigPath}"`
			)
			WriteFile(TempDarkluaConfigPath, DefaultDarkluaConfig)
			TempDarkluaConfigWasAdded = true

			table.insert(ExtraDarkluaProcessArgs, `-c={EncodeShellData(TempDarkluaConfigPath)}`)
		end

		Run("darklua", {
			"process",
			EncodeShellData(TempOutputFilePath),
			EncodeShellData(Output),
			unpack(ExtraDarkluaProcessArgs),
		})

		RemoveFile(TempOutputFilePath)
		if TempDarkluaConfigWasAdded then
			RemoveFile(TempDarkluaConfigPath)
		end
	else
		-- Just write directly
		WriteFile(Output, CodegenOutputOrError)
	end

	-- We're now completely finished!
	if fs.isDir(TempDir) then
		RemoveDir(TempDir)
	end

	-- Let the user *clearly* know if there were any user-fault compiler errors
	if FailedCompilations > 0 then
		print()
		Log.Warn(
			`WARNING: {FailedCompilations} scripts failed to compile ahead-of-time (CHECK FULL BUILD LOG ABOVE FOR MORE DETAILS); these will throw errors at runtime upon being loaded, detailing said compilation errors.`
		)

		process.exit(1)
	end
else
	Log.Error(`Subcommand "{Subcommand}" invalid, see usage for all valid subcommands:\n`)
	print(UsageMessage)
	process.exit(1)
end

end)() end,
    [3] = function()local wax,script,require=ImportGlobals(3)local ImportGlobals return (function(...)-- MIT License | Copyright (c) 2023-2025 Latte Softworks <https://latte.to>

local luau = require("@lune/luau")
local roblox = require("@lune/roblox")

local LuneUtils = require("./libraries/LuneUtils")

local Log = LuneUtils.Log
local StringUtils = LuneUtils.StringUtils

local LuaEncode = require("./libraries/LuaEncode")

local Version = require("./data/Version")

-- Init script template for codegen (in this, we'll maintain 5.1 *syntax* compat
-- for optional compilation to vanilla Lua 5.1x bytecode format)
local InitScriptTemplate = require("./data/Template")

-- The line where the 1st closure's function will start in bundled codegen
local InitialLineOffset = 8

local ClassNameIdKeys = {
	Folder = 1,
	ModuleScript = 2,
	Script = 3,
	LocalScript = 4,
	StringValue = 5,
}

-- Building codegen directly from model data (from .rbxm/.rbxmx) or a deserialized
-- object using Lune's `roblox` library
local function BundleModel(
	modelData: string | { roblox.Instance },
	envName: string?,
	minifyCodegen: boolean?,
	extraLinesToOffset: number?,
	verbose: boolean?
): (string, number)
	local EnvName = envName or "WaxRuntime"
	local MinifyCodegen = if minifyCodegen == nil then true else minifyCodegen
	local ExtraLinesToOffset = extraLinesToOffset or 0
	local Verbose = if verbose == nil then true else verbose

	-- Same as in Wax CLI
	local function RunIfVerbose(f, ...)
		if Verbose then
			f(...)
		end
	end

	local LineDebugging = MinifyCodegen == false

	local ModelRoot = if type(modelData) == "string" then roblox.deserializeModel(modelData) else modelData

	-- We'll track how long it takes for us to read the entire object tree, with all
	-- other various processes included
	local ReadStartTime = os.clock()

	local FailedCompilations = 0

	-- We'll initialize the output object tree, then walk through what we need to
	local ObjectTree = {}
	local ClosureBindings = {} -- [RefId] = Closure
	local ClosureSourceLineCounts = {} -- [RefId] = LineCount

	local ScrapedInstanceTree = {} -- [RealRef] = {Child, ...}
	local RefIds = {} -- [RefId] = RealRef

	-- Recursive function to actually walk through the real instance tree, and assign refs
	local function ScrapeInstanceChildren(instance)
		-- Add a reference id for this instance
		table.insert(RefIds, instance)

		local ScrapedChildren = {}
		for _, Child in instance:GetChildren() do
			ScrapedChildren[Child] = ScrapeInstanceChildren(Child)
		end

		return ScrapedChildren
	end

	-- Initialize the scraped instance tree and assign all refs from root
	local ModelRootChildren = ModelRoot -- Using later aswell
	for _, RealInstance in ModelRootChildren do
		ScrapedInstanceTree[RealInstance] = ScrapeInstanceChildren(RealInstance)
	end

	-- Now, we'll recursively create the fake object tree
	local function CreateObjectTree(instance, children, currentPathString: string?)
		currentPathString = currentPathString or instance.Name

		local RefId = table.find(RefIds, instance)
		local ClassName = instance.ClassName

		local ClassNameId = ClassNameIdKeys[ClassName]
		if not ClassNameId then
			Log.Warn(`Skipping instance of ClassName "{ClassName}", as it isn't supported in bundling`)
			return
		end

		local InstanceIsABaseScript = ClassName == "LocalScript" or ClassName == "Script"
		local InstanceIsAScript = InstanceIsABaseScript or ClassName == "ModuleScript"

		--[[
            {
                [1] = RefId,
                [2] = ClassName,
                [3] = Properties,
                [4] = Children?
            }
        ]]

		local InstanceObject = {
			[1] = RefId,
			[2] = ClassNameId,
		}

		-- If it's statically disabled, we just won't include the closure to run
		if InstanceIsAScript and not (InstanceIsABaseScript and instance.Disabled) then
			local ScriptSource = instance.Source

			RunIfVerbose(Log.Info, `Compile-checking {instance.ClassName} "{currentPathString}"..`)
			local CompileSuccess, CompileError = pcall(luau.compile, ScriptSource)

			if CompileSuccess then
				-- The added line here is the "\nend" below every arbitrary closure
				ClosureSourceLineCounts[RefId] = StringUtils.LineCount(ScriptSource) + 1

				-- We're using `FunctionsReturnRaw` on LuaEncode later, this will set the return
				-- to the rew value, which is the script closure
				ClosureBindings[RefId] = function()
					return "function()local wax,script,require=ImportGlobals("
						.. RefId
						.. ")local ImportGlobals return (function(...)"
						.. ScriptSource
						.. "\nend)() end"
				end
			else
				local FirstLineOfError = string.match(tostring(CompileError), "%w* ?:%d*: ?([^\n]*)\n")
				Log.Warn(
					`WARNING: {instance.ClassName} "{currentPathString}" failed to compile: {FirstLineOfError or "[Failed to parse compiler error]"}`
				)
				FailedCompilations += 1

				ClosureSourceLineCounts[RefId] = 1 -- Guaranteed 1 line; see below lol

				ClosureBindings[RefId] = function()
					return `function()error("[AOT COMPILER ERROR] {StringUtils.SerializeStringData(FirstLineOfError)}")end`
				end
			end
		end

		-- Add any properties
		local Properties = { [1] = instance.Name } -- For byte preservation (lol) the name is just set as the property index 1, and not "Name"

		if ClassName == "StringValue" then
			Properties.Value = instance.Value
		end

		-- The init script will assume the `Name` is the same as the `ClassName` if not included
		if instance.Name ~= ClassName then
			InstanceObject[3] = Properties
		end

		-- Recursively add children
		if next(children) then
			local ObjectChildren = {}

			for Child, ChildrenOfChild in children do
				local ChildObjectTree = CreateObjectTree(Child, ChildrenOfChild, `{currentPathString}.{Child.Name}`)
				if ChildObjectTree then
					table.insert(ObjectChildren, ChildObjectTree)
				end
			end

			InstanceObject[4] = ObjectChildren
		end

		return InstanceObject
	end

	for RealInstance, Children in ScrapedInstanceTree do
		local ChildObjectTree = CreateObjectTree(RealInstance, Children)

		if ChildObjectTree then
			table.insert(ObjectTree, ChildObjectTree)
		end
	end

	local LineOffsets = {}
	if LineDebugging then
		-- Where the first closure func start should be
		local CurrentLineOffset = ExtraLinesToOffset + InitialLineOffset

		for RefId, LineCount in ClosureSourceLineCounts do
			LineOffsets[RefId] = CurrentLineOffset
			CurrentLineOffset += LineCount
		end
	end

	-- Now we're done reading everything!
	local ReadEndTime = os.clock()
	RunIfVerbose(
		Log.Info,
		`Finished bundling model data in {string.format("%.4f", ReadEndTime - ReadStartTime)} (seconds)`
	)

	local Prettify = if MinifyCodegen == false then true else false

	local SerializedObjectTree = LuaEncode(ObjectTree, {
		Prettify = Prettify,
		StackLimit = math.huge,
	})

	local SerializedClosureBindings = LuaEncode(ClosureBindings, {
		Prettify = Prettify,
		FunctionsReturnRaw = true, -- For Script.Source function closures
	})

	local SerializedLineOffsets = if not LineDebugging
		then "nil"
		else LuaEncode(LineOffsets, {
			Prettify = Prettify,
		})

	local CodegenOutput = StringUtils.Replace(InitScriptTemplate, {
		Version = StringUtils.SerializeStringData(Version),
		EnvName = StringUtils.SerializeStringData(EnvName),
		ObjectTree = SerializedObjectTree,
		ClosureBindings = SerializedClosureBindings,
		LineOffsets = SerializedLineOffsets,
	})

	-- If there's a top-level init modulescript, we'll return it from the output's closure directly
	-- It's better to impl this all AoT!
	if #ModelRootChildren == 1 and ModelRootChildren[1].ClassName == "ModuleScript" then
		CodegenOutput ..= "\n-- AoT adjustment: Load init module (MainModule behavior)\nreturn LoadScript(RealObjectRoot:GetChildren()[1])"
	else
		for _, Ref in next, ModelRootChildren do
			if Ref.ClassName == "ModuleScript" and Ref.Name == "MainModule" then
				CodegenOutput ..= "\n-- AoT adjustment: Load init module (MainModule behavior)\nreturn LoadScript(RealObjectRoot.MainModule)"
				break
			end
		end
	end

	return CodegenOutput, FailedCompilations
end

return BundleModel

end)() end,
    [5] = function()local wax,script,require=ImportGlobals(5)local ImportGlobals return (function(...)local serde = require("@lune/serde")

local Config = {
    generator = {
        name = "dense",
        column_span = 120,
    },

    rules = {
        "convert_index_to_field",
        "compute_expression",
        "group_local_assignment",
        "filter_after_early_return",
        "remove_comments",
        "remove_empty_do",
        "remove_function_call_parens",
        "remove_nil_declaration",
        "remove_method_definition",
        "remove_spaces",
        "remove_unused_if_branch",
        "remove_unused_while",

        {
            rule = "rename_variables",
            include_functions = true,
        },
    },
}

return serde.encode("json", Config, false)

end)() end,
    [6] = function()local wax,script,require=ImportGlobals(6)local ImportGlobals return (function(...)-- This codegen template *must* be 100% compatible with Lua 5.1x+, NOT just Luau
-- With that being said, this explains the weird cflow in some parts

return [[
-- ++++++++ WAX BUNDLED DATA BELOW ++++++++ --

-- Will be used later for getting flattened globals
local ImportGlobals

-- Holds direct closure data (defining this before the DOM tree for line debugging etc)
local ClosureBindings = ${ClosureBindings} -- [RefId] = Closure

-- Holds the actual DOM data
local ObjectTree = ${ObjectTree}

-- Line offsets for debugging (only included when minifyTables is false)
local LineOffsets = ${LineOffsets}

-- Misc AOT variable imports
local WaxVersion = "${Version}"
local EnvName = "${EnvName}"

-- ++++++++ RUNTIME IMPL BELOW ++++++++ --

-- Localizing certain libraries and built-ins for runtime efficiency
local string, task, setmetatable, error, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION =
      string, task, setmetatable, error, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION

local table_insert = table.insert
local table_remove = table.remove
local table_freeze = table.freeze or function(t) return t end -- lol

local coroutine_wrap = coroutine.wrap

local string_sub = string.sub
local string_match = string.match
local string_gmatch = string.gmatch

-- The Lune runtime has its own `task` impl, but it must be imported by its builtin
-- module path, "@lune/task"
if _VERSION and string_sub(_VERSION, 1, 4) == "Lune" then
    local RequireSuccess, LuneTaskLib = pcall(require, "@lune/task")
    if RequireSuccess and LuneTaskLib then
        task = LuneTaskLib
    end
end

local task_defer = task and task.defer

-- If we're not running on the Roblox engine, we won't have a `task` global
local Defer = task_defer or function(f, ...)
    coroutine_wrap(f)(...)
end

-- ClassName "IDs"
local ClassNameIdBindings = {
    [1] = "Folder",
    [2] = "ModuleScript",
    [3] = "Script",
    [4] = "LocalScript",
    [5] = "StringValue",
}

local RefBindings = {} -- [RefId] = RealObject

local ScriptClosures = {}
local ScriptClosureRefIds = {} -- [ScriptClosure] = RefId
local StoredModuleValues = {}
local ScriptsToRun = {}

-- wax.shared __index/__newindex
local SharedEnvironment = {}

-- We're creating 'fake' instance refs soley for traversal of the DOM for require() compatibility
-- It's meant to be as lazy as possible
local RefChildren = {} -- [Ref] = {ChildrenRef, ...}

-- Implemented instance methods
local InstanceMethods = {
    GetFullName = { {}, function(self)
        local Path = self.Name
        local ObjectPointer = self.Parent

        while ObjectPointer do
            Path = ObjectPointer.Name .. "." .. Path

            -- Move up the DOM (parent will be nil at the end, and this while loop will stop)
            ObjectPointer = ObjectPointer.Parent
        end

        return Path
    end},

    GetChildren = { {}, function(self)
        local ReturnArray = {}

        for Child in next, RefChildren[self] do
            table_insert(ReturnArray, Child)
        end

        return ReturnArray
    end},

    GetDescendants = { {}, function(self)
        local ReturnArray = {}

        for Child in next, RefChildren[self] do
            table_insert(ReturnArray, Child)

            for _, Descendant in next, Child:GetDescendants() do
                table_insert(ReturnArray, Descendant)
            end
        end

        return ReturnArray
    end},

    FindFirstChild = { {"string", "boolean?"}, function(self, name, recursive)
        local Children = RefChildren[self]

        for Child in next, Children do
            if Child.Name == name then
                return Child
            end
        end

        if recursive then
            for Child in next, Children do
                -- Yeah, Roblox follows this behavior- instead of searching the entire base of a
                -- ref first, the engine uses a direct recursive call
                return Child:FindFirstChild(name, true)
            end
        end
    end},

    FindFirstAncestor = { {"string"}, function(self, name)
        local RefPointer = self.Parent
        while RefPointer do
            if RefPointer.Name == name then
                return RefPointer
            end

            RefPointer = RefPointer.Parent
        end
    end},

    -- Just to implement for traversal usage
    WaitForChild = { {"string", "number?"}, function(self, name)
        return self:FindFirstChild(name)
    end},
}

-- "Proxies" to instance methods, with err checks etc
local InstanceMethodProxies = {}
for MethodName, MethodObject in next, InstanceMethods do
    local Types = MethodObject[1]
    local Method = MethodObject[2]

    local EvaluatedTypeInfo = {}
    for ArgIndex, TypeInfo in next, Types do
        local ExpectedType, IsOptional = string_match(TypeInfo, "^([^%?]+)(%??)")
        EvaluatedTypeInfo[ArgIndex] = {ExpectedType, IsOptional}
    end

    InstanceMethodProxies[MethodName] = function(self, ...)
        if not RefChildren[self] then
            error("Expected ':' not '.' calling member function " .. MethodName, 2)
        end

        local Args = {...}
        for ArgIndex, TypeInfo in next, EvaluatedTypeInfo do
            local RealArg = Args[ArgIndex]
            local RealArgType = type(RealArg)
            local ExpectedType, IsOptional = TypeInfo[1], TypeInfo[2]

            if RealArg == nil and not IsOptional then
                error("Argument " .. RealArg .. " missing or nil", 3)
            end

            if ExpectedType ~= "any" and RealArgType ~= ExpectedType and not (RealArgType == "nil" and IsOptional) then
                error("Argument " .. ArgIndex .. " expects type \"" .. ExpectedType .. "\", got \"" .. RealArgType .. "\"", 2)
            end
        end

        return Method(self, ...)
    end
end

local function CreateRef(className, name, parent)
    -- `name` and `parent` can also be set later by the init script if they're absent

    -- Extras
    local StringValue_Value

    -- Will be set to RefChildren later aswell
    local Children = setmetatable({}, {__mode = "k"})

    -- Err funcs
    local function InvalidMember(member)
        error(member .. " is not a valid (virtual) member of " .. className .. " \"" .. name .. "\"", 3)
    end
    local function ReadOnlyProperty(property)
        error("Unable to assign (virtual) property " .. property .. ". Property is read only", 3)
    end

    local Ref = {}
    local RefMetatable = {}

    RefMetatable.__metatable = false

    RefMetatable.__index = function(_, index)
        if index == "ClassName" then -- First check "properties"
            return className
        elseif index == "Name" then
            return name
        elseif index == "Parent" then
            return parent
        elseif className == "StringValue" and index == "Value" then
            -- Supporting StringValue.Value for Rojo .txt file conv
            return StringValue_Value
        else -- Lastly, check "methods"
            local InstanceMethod = InstanceMethodProxies[index]

            if InstanceMethod then
                return InstanceMethod
            end
        end

        -- Next we'll look thru child refs
        for Child in next, Children do
            if Child.Name == index then
                return Child
            end
        end

        -- At this point, no member was found; this is the same err format as Roblox
        InvalidMember(index)
    end

    RefMetatable.__newindex = function(_, index, value)
        -- __newindex is only for props fyi
        if index == "ClassName" then
            ReadOnlyProperty(index)
        elseif index == "Name" then
            name = value
        elseif index == "Parent" then
            -- We'll just ignore the process if it's trying to set itself
            if value == Ref then
                return
            end

            if parent ~= nil then
                -- Remove this ref from the CURRENT parent
                RefChildren[parent][Ref] = nil
            end

            parent = value

            if value ~= nil then
                -- And NOW we're setting the new parent
                RefChildren[value][Ref] = true
            end
        elseif className == "StringValue" and index == "Value" then
            -- Supporting StringValue.Value for Rojo .txt file conv
            StringValue_Value = value
        else
            -- Same err as __index when no member is found
            InvalidMember(index)
        end
    end

    RefMetatable.__tostring = function()
        return name
    end

    setmetatable(Ref, RefMetatable)

    RefChildren[Ref] = Children

    if parent ~= nil then
        RefChildren[parent][Ref] = true
    end

    return Ref
end

-- Create real ref DOM from object tree
local function CreateRefFromObject(object, parent)
    local RefId = object[1]
    local ClassNameId = object[2]
    local Properties = object[3] -- Optional
    local Children = object[4] -- Optional

    local ClassName = ClassNameIdBindings[ClassNameId]

    local Name = Properties and table_remove(Properties, 1) or ClassName

    local Ref = CreateRef(ClassName, Name, parent) -- 3rd arg may be nil if this is from root
    RefBindings[RefId] = Ref

    if Properties then
        for PropertyName, PropertyValue in next, Properties do
            Ref[PropertyName] = PropertyValue
        end
    end

    if Children then
        for _, ChildObject in next, Children do
            CreateRefFromObject(ChildObject, Ref)
        end
    end

    return Ref
end

local RealObjectRoot = CreateRef("Folder", "[" .. EnvName .. "]")
for _, Object in next, ObjectTree do
    CreateRefFromObject(Object, RealObjectRoot)
end

-- Now we'll set script closure refs and check if they should be ran as a BaseScript
for RefId, Closure in next, ClosureBindings do
    local Ref = RefBindings[RefId]

    ScriptClosures[Ref] = Closure
    ScriptClosureRefIds[Ref] = RefId

    local ClassName = Ref.ClassName
    if ClassName == "LocalScript" or ClassName == "Script" then
        table_insert(ScriptsToRun, Ref)
    end
end

local function LoadScript(scriptRef)
    local ScriptClassName = scriptRef.ClassName

    -- First we'll check for a cached module value (packed into a tbl)
    local StoredModuleValue = StoredModuleValues[scriptRef]
    if StoredModuleValue and ScriptClassName == "ModuleScript" then
        return unpack(StoredModuleValue)
    end

    local Closure = ScriptClosures[scriptRef]

    local function FormatError(originalErrorMessage)
        originalErrorMessage = tostring(originalErrorMessage)

        local VirtualFullName = scriptRef:GetFullName()

        -- Check for vanilla/Roblox format
        local OriginalErrorLine, BaseErrorMessage = string_match(originalErrorMessage, "[^:]+:(%d+): (.+)")

        if not OriginalErrorLine or not LineOffsets then
            return VirtualFullName .. ":*: " .. (BaseErrorMessage or originalErrorMessage)
        end

        OriginalErrorLine = tonumber(OriginalErrorLine)

        local RefId = ScriptClosureRefIds[scriptRef]
        local LineOffset = LineOffsets[RefId]

        local RealErrorLine = OriginalErrorLine - LineOffset + 1
        if RealErrorLine < 0 then
            RealErrorLine = "?"
        end

        return VirtualFullName .. ":" .. RealErrorLine .. ": " .. BaseErrorMessage
    end

    -- If it's a BaseScript, we'll just run it directly!
    if ScriptClassName == "LocalScript" or ScriptClassName == "Script" then
        local RunSuccess, ErrorMessage = pcall(Closure)
        if not RunSuccess then
            error(FormatError(ErrorMessage), 0)
        end
    else
        local PCallReturn = {pcall(Closure)}

        local RunSuccess = table_remove(PCallReturn, 1)
        if not RunSuccess then
            local ErrorMessage = table_remove(PCallReturn, 1)
            error(FormatError(ErrorMessage), 0)
        end

        StoredModuleValues[scriptRef] = PCallReturn
        return unpack(PCallReturn)
    end
end

-- We'll assign the actual func from the top of this output for flattening user globals at runtime
-- Returns (in a tuple order): wax, script, require
function ImportGlobals(refId)
    local ScriptRef = RefBindings[refId]

    local function RealCall(f, ...)
        local PCallReturn = {pcall(f, ...)}

        local CallSuccess = table_remove(PCallReturn, 1)
        if not CallSuccess then
            error(PCallReturn[1], 3)
        end

        return unpack(PCallReturn)
    end

    -- `wax.shared` index
    local WaxShared = table_freeze(setmetatable({}, {
        __index = SharedEnvironment,
        __newindex = function(_, index, value)
            SharedEnvironment[index] = value
        end,
        __len = function()
            return #SharedEnvironment
        end,
        __iter = function()
            return next, SharedEnvironment
        end,
    }))

    local Global_wax = table_freeze({
        -- From AOT variable imports
        version = WaxVersion,
        envname = EnvName,

        shared = WaxShared,

        -- "Real" globals instead of the env set ones
        script = script,
        require = require,
    })

    local Global_script = ScriptRef

    local function Global_require(module, ...)
        local ModuleArgType = type(module)

        local ErrorNonModuleScript = "Attempted to call require with a non-ModuleScript"
        local ErrorSelfRequire = "Attempted to call require with self"

        if ModuleArgType == "table" and RefChildren[module]  then
            if module.ClassName ~= "ModuleScript" then
                error(ErrorNonModuleScript, 2)
            elseif module == ScriptRef then
                error(ErrorSelfRequire, 2)
            end

            return LoadScript(module)
        elseif ModuleArgType == "string" and string_sub(module, 1, 1) ~= "@" then
            -- The control flow on this SUCKS

            if #module == 0 then
                error("Attempted to call require with empty string", 2)
            end

            local CurrentRefPointer = ScriptRef

            if string_sub(module, 1, 1) == "/" then
                CurrentRefPointer = RealObjectRoot
            elseif string_sub(module, 1, 2) == "./" then
                module = string_sub(module, 3)
            end

            local PreviousPathMatch
            for PathMatch in string_gmatch(module, "([^/]*)/?") do
                local RealIndex = PathMatch
                if PathMatch == "." then
                    RealIndex = ""
                elseif PathMatch == ".." then
                    CurrentRefPointer = CurrentRefPointer.Parent
                    RealIndex = ""
                end

                -- Don't advance dir if it's just another "/" either
                if RealIndex ~= "" then
                    local ResultRef = CurrentRefPointer:FindFirstChild(RealIndex)
                    if not ResultRef then
                        local CurrentRefParent = CurrentRefPointer.Parent
                        if CurrentRefParent then
                            ResultRef = CurrentRefParent:FindFirstChild(RealIndex)
                        end
                    end

                    if ResultRef then
                        CurrentRefPointer = ResultRef
                    elseif PathMatch ~= PreviousPathMatch and PathMatch ~= "init" and PathMatch ~= "init.server" and PathMatch ~= "init.client" then
                        error("Virtual script path \"" .. module .. "\" not found", 2)
                    end
                end

                -- For possible checks next cycle
                PreviousPathMatch = PathMatch
            end

            if CurrentRefPointer.ClassName ~= "ModuleScript" then
                error(ErrorNonModuleScript, 2)
            elseif CurrentRefPointer == ScriptRef then
                error(ErrorSelfRequire, 2)
            end

            return LoadScript(CurrentRefPointer)
        end

        return RealCall(require, module, ...)
    end

    -- Now, return flattened globals ready for direct runtime exec
    return Global_wax, Global_script, Global_require
end

for _, ScriptRef in next, ScriptsToRun do
    Defer(LoadScript, ScriptRef)
end
]]

end)() end,
    [7] = function()local wax,script,require=ImportGlobals(7)local ImportGlobals return (function(...)return "0.4.2"

end)() end,
    [9] = function()local wax,script,require=ImportGlobals(9)local ImportGlobals return (function(...)-- LuaEncode - Fast table serialization library for pure Luau/Lua 5.1+
-- MIT License | Copyright (c) 2022-2025 Chad Hyatt <chad@hyatt.page>
-- https://github.com/chadhyatt/LuaEncode

--!optimize 2
--!native

local table, string, next, pcall, game, workspace, tostring, tonumber, getmetatable =
	table, string, next, pcall, game, workspace, tostring, tonumber, getmetatable

local string_format = string.format
local string_char = string.char
local string_gsub = string.gsub
local string_match = string.match
local string_rep = string.rep
local string_sub = string.sub
local string_gmatch = string.gmatch

local table_concat = table.concat

local Type = typeof or type

local function LookupTable(array)
	local Out = {}
	for _, Value in next, array do
		Out[Value] = true
	end

	return Out
end

-- Used for checking direct getfield syntax; Lua keywords can't be used as keys without being a str
-- FYI; `continue` is Luau only (in Lua it's actually a global function)
local LuaKeywords = LookupTable({
	"and",
	"break",
	"do",
	"else",
	"elseif",
	"end",
	"false",
	"for",
	"function",
	"if",
	"in",
	"local",
	"nil",
	"not",
	"or",
	"repeat",
	"return",
	"then",
	"true",
	"until",
	"while",
	"continue",
})

-- Type names that can be used as manual key indexes (i.e. non-reference types)
local KeyIndexTypes = LookupTable({
	"number",
	"string",
	"boolean",
	"Enum",
	"EnumItem",
	"Enums",
})

local DirectIndexPat = "^[A-Za-z_][A-Za-z0-9_]*$"

local function CheckType(inputData, dataName, ...)
	local ValidTypes = { ... }
	local ValidTypesLookup = LookupTable(ValidTypes)
	local InputType = Type(inputData)

	if not ValidTypesLookup[InputType] then
		error(
			string_format(
				"LuaEncode: Incorrect type for `%s`: `%s` expected, got `%s`",
				dataName,
				table_concat(ValidTypes, ", "), -- For if multiple types are accepted
				InputType
			),
			0
		)
	end

	return inputData
end

-- This re-serializes a string back into Lua, for the interpreter AND humans to read. This fixes
-- `string_format("%q")` only outputting in system encoding, instead of explicit Lua byte escapes
local SerializeString
do
	-- These are control characters to be encoded in a certain way in Lua rather than just a byte escape
	local SpecialCharacters = {
		['"'] = '\\"',
		["\\"] = "\\\\",
		["\a"] = "\\a",
		["\b"] = "\\b",
		["\t"] = "\\t",
		["\n"] = "\\n",
		["\v"] = "\\v",
		["\f"] = "\\f",
		["\r"] = "\\r",
	}

	for Index = 0, 255 do
		local Character = string_char(Index)

		if not SpecialCharacters[Character] and (Index < 32 or Index > 126) then
			SpecialCharacters[Character] = string_format("\\x%02X", Index)
		end
	end

	function SerializeString(inputString)
		-- FYI; We can't do "\0-\31" in Lua 5.1 (Only Luau/Lua 5.2+) due to an embedded zeros in pattern
		-- issue. See: https://stackoverflow.com/a/22962409
		return table_concat({ '"', string_gsub(inputString, '[%z\\"\1-\31\127-\255]', SpecialCharacters), '"' })
	end
end

-- Escape warning messages and such for comment block inserts
local function CommentBlock(inputString)
	local Longest = -1
	for Match in string_gmatch(inputString, "%](=*)%]") do
		if #Match > Longest then
			Longest = #Match
		end
	end

	local Padding = string_rep("=", Longest + 1)
	return "--[" .. Padding .. "[" .. inputString .. "]" .. Padding .. "]"
end

local EvaluateInstancePath
do
	local function IsService(object)
		-- Logically, if an object is actually under a service, that service *has* to already exist, as we've
		-- presumably evaluated to said path
		local FindServiceSuccess, ServiceObject = pcall(game.FindService, game, object.ClassName)
		if FindServiceSuccess and ServiceObject then
			return true
		end

		return false
	end

	-- Evaluates an instances' accessable "path" with just it's ref, and if the root parent is nil/isn't
	-- under `game` or `workspace`, returns nil.
	function EvaluateInstancePath(object, useFindFirstChild)
		local ObjectPointer = object
		if not ObjectPointer then
			return
		end

		local Path = ""

		while ObjectPointer do
			local ObjectName = ObjectPointer.Name
			local ObjectClassName = ObjectPointer.ClassName
			local ObjectParent = ObjectPointer.Parent

			if ObjectParent == game and IsService(ObjectPointer) then
				-- ^^ Then we'll use GetService directly, since it's actually a service under the DataModel

				Path = ":GetService(" .. SerializeString(ObjectClassName) .. ")" .. Path
			elseif useFindFirstChild then
				Path = ":FindFirstChild(" .. SerializeString(ObjectName) .. ")" .. Path
			elseif not LuaKeywords[ObjectName] and string_match(ObjectName, DirectIndexPat) then
				-- ^^ Like the string data type, this means means we can index the name directly in Lua
				-- without an explicit string
				Path = "." .. ObjectName .. Path
			else
				Path = "[" .. SerializeString(ObjectName) .. "]" .. Path
			end

			if ObjectParent == game then
				Path = "game" .. Path
				return Path
			elseif ObjectParent == workspace then
				Path = "workspace" .. Path
				return Path
			end

			-- Advance ObjectPointer, whether it exists or not
			ObjectPointer = ObjectParent
		end

		return
	end
end

--[[
LuaEncode(inputTable: {[any]: any}, options: {[string]: any}): string

    ---------- OPTIONS: ----------

    Prettify <boolean:false> | Whether or not the output should be pretty printed

    IndentCount <number:0> | The amount of characters that should be used for indents
    (**Note**: If `Prettify` is set to true and this is unspecified, it will default to `4`)

    InsertCycles <boolean:false> | If there are cyclic references in your table, the output
    will be wrapped in an anonymous function that manually sets paths to those references.
    (**NOTE:** If a key in the index path to the cycle is a reference type (e.g. `table`,
    `function`), the codegen can't externally set that path, and the value will have to be ignored)

    OutputWarnings <boolean:true> | If "warnings" should be placed into the output as
    comment blocks

    FunctionsReturnRaw <boolean:false> | If `function` values should be treated as callbacks
    that return a string to be inserted directly into the serialized output as the key/value

    UseInstancePaths <boolean:true> | If Roblox `Instance` values should return their
    Lua-accessable path for serialization. If the instance is parented under `nil` or
    isn't under `game`/`workspace`, it'll always fall back to `Instance.new(ClassName)`

    UseFindFirstChild  <boolean:true> | When `options.UseInstancePaths` is true, whether or
    not instance paths should use `FindFirstChild` instead of direct indexes

    SerializeMathHuge <boolean:true> | If "infinite" (or negative-infinite) numbers should
    be serialized as `math.huge`. (uses the `math` global, as opposed to just a direct data
    type) If false, "`1/0`" or "`-1/0`" will be serialized, which is supported on all
    target Lua environments

]]

local function LuaEncode(inputTable, options)
	options = options or {}

	CheckType(inputTable, "inputTable", "table")
	CheckType(options, "options", "table")

	CheckType(options.Prettify, "options.Prettify", "boolean", "nil")
	CheckType(options.PrettyPrinting, "options.PrettyPrinting", "boolean", "nil") -- Alias for `Options.Prettify`
	CheckType(options.IndentCount, "options.IndentCount", "number", "nil")
	CheckType(options.InsertCycles, "options.InsertCycles", "boolean", "nil")
	CheckType(options.OutputWarnings, "options.OutputWarnings", "boolean", "nil")
	CheckType(options.FunctionsReturnRaw, "options.FunctionsReturnRaw", "boolean", "nil")
	CheckType(options.UseInstancePaths, "options.UseInstancePaths", "boolean", "nil")
	CheckType(options.UseFindFirstChild, "options.UseFindFirstChild", "boolean", "nil")
	CheckType(options.SerializeMathHuge, "options.SerializeMathHuge", "boolean", "nil")

	CheckType(options._StackLevel, "options._StackLevel", "number", "nil")
	CheckType(options._VisitedTables, "options._VisitedTables", "table", "nil")
	CheckType(options._SharedTableLarpAsRegTable, "options._SharedTableLarpAsRegTable", "boolean", "nil")

	local Prettify = (options.Prettify == nil and options.PrettyPrinting == nil and false)
		or (options.Prettify ~= nil and options.Prettify)
		or (options.PrettyPrinting and options.PrettyPrinting)
	local IndentCount = options.IndentCount or (Prettify and 4) or 0
	local InsertCycles = (options.InsertCycles == nil and false) or options.InsertCycles
	local OutputWarnings = (options.OutputWarnings == nil and true) or options.OutputWarnings
	local FunctionsReturnRaw = (options.FunctionsReturnRaw == nil and false) or options.FunctionsReturnRaw
	local UseInstancePaths = (options.UseInstancePaths == nil and true) or options.UseInstancePaths
	local UseFindFirstChild = (options.UseFindFirstChild == nil and true) or options.UseFindFirstChild
	local SerializeMathHuge = (options.SerializeMathHuge == nil and true) or options.SerializeMathHuge

	local StackLevelOpt = options._StackLevel or 1
	local VisitedTables = options._VisitedTables or {} -- [Ref: table] = true
	local SharedTableLarpAsRegTable = options._SharedTableLarpAsRegTable or false

	-- Lazy serialization reference values
	local PositiveInf = (SerializeMathHuge and "math.huge") or "1/0"
	local NegativeInf = (SerializeMathHuge and "-math.huge") or "-1/0"
	local NewEntryString = (Prettify and "\n") or ""
	local CodegenNewline = (Prettify and "\n") or " "
	local ValueSeperator = (Prettify and ", ") or ","
	local BlankSeperator = (Prettify and " ") or ""
	local EqualsSeperator = (Prettify and " = ") or "="

	local StackLevel = StackLevelOpt

	-- For pretty printing we need to keep track of the current stack level, then repeat IndentString by that count
	local IndentStringBase = string_rep(" ", IndentCount)

	-- Calculated in the walk loop, based on the current StackLevel
	local IndentString = nil
	local EndingIndentString = nil

	--IndentString = (Prettify and string_rep(IndentString, StackLevel)) or IndentString
	--local EndingIndentString = (#IndentString > 0 and string_sub(IndentString, 1, -IndentCount - 1)) or ""

	-- For number key values, we want to explicitly serialize the index num ONLY when it needs to be
	local KeyNumIndex = 1

	-- Cases for encoding values, then end setup. Functions are all expected to return a (EncodedKey: string, EncloseInBrackets: boolean)
	local TypeCases = {}
	do
		local function TypeCase(typeName, value, ...)
			local EncodedValue = TypeCases[typeName](value, false, ...) -- False to label as NOT `isKey`
			return EncodedValue
		end

		local function Args(...)
			local EncodedValues = {}

			for _, Arg in next, { ... } do
				EncodedValues[#EncodedValues + 1] = TypeCase(Type(Arg), Arg)
			end

			return table_concat(EncodedValues, ValueSeperator)
		end

		-- For Roblox's different `Params` data types
		local function Params(newData, params)
			return "(function(p, t) for n, v in next, t do p[n] = v end return p end)("
				.. table_concat({ newData, TypeCase("table", params) }, ValueSeperator)
				.. ")"
		end

		TypeCases["number"] = function(value, isKey)
			-- If the number isn't the current real index of the table, we DO want to
			-- explicitly define it in the serialization no matter what for accuracy
			if isKey and value == KeyNumIndex then
				-- What's EXPECTED unless otherwise explicitly defined, if so, return no encoded num
				KeyNumIndex = KeyNumIndex + 1
				return nil, true
			end

			-- Special cases
			if value == 1 / 0 then
				return PositiveInf
			elseif value == -1 / 0 then
				return NegativeInf
			end

			-- Return fixed-formatted precision num
			return string_format("%.14g", value)
		end

		TypeCases["string"] = function(value, isKey)
			if isKey and not LuaKeywords[value] and string_match(value, DirectIndexPat) then
				-- Doesn't need full string def
				return value, true
			end

			return SerializeString(value)
		end

		-- This is NOT used for recursive table serialization, only table-as-key values and Roblox data types that use tables as
		-- arguments for constructor functions
		TypeCases["table"] = function(value, isKey, stLarpAsRegTable)
			-- Primarily for tables-as-keys
			if VisitedTables[value] and OutputWarnings then
				return "{--[[LuaEncode: Duplicate reference]]}"
			end

			local NewOptions = setmetatable({}, { __index = options })
			do
				NewOptions.Prettify = (isKey and false) or Prettify
				NewOptions.IndentCount = (isKey and ((not Prettify and IndentCount) or 1)) or IndentCount
				NewOptions._StackLevel = (isKey and 1) or StackLevel + 1
				NewOptions._VisitedTables = VisitedTables
				NewOptions._SharedTableLarpAsRegTable = (not isKey and stLarpAsRegTable)
			end

			return LuaEncode(value, NewOptions)
		end

		TypeCases["boolean"] = function(value)
			return value and "true" or "false"
		end

		TypeCases["nil"] = function(value)
			return "nil"
		end

		TypeCases["function"] = function(value)
			-- If `options.FunctionsReturnRaw` is enabled, we'll call the function here itself, expecting
			-- a raw value to insert as the serialized key/value
			if FunctionsReturnRaw then
				return value()
			end

			return string_format(
				"function()%send",
				(OutputWarnings and " --[[LuaEncode: `options.FunctionsReturnRaw` false; can't serialize functions]] ")
					or ""
			)
		end

		---------- ROBLOX CUSTOM DATA TYPES BELOW ----------

		TypeCases["Axes"] = function(value)
			local EncodedArgs = {}
			local EnumValues = {
				["Enum.Axis.X"] = value.X,
				["Enum.Axis.Y"] = value.Y,
				["Enum.Axis.Z"] = value.Z,
			}

			for EnumValue, IsEnabled in next, EnumValues do
				if IsEnabled then
					EncodedArgs[#EncodedArgs + 1] = EnumValue
				end
			end

			return "Axes.new(" .. table_concat(EncodedArgs, ValueSeperator) .. ")"
		end

		TypeCases["BrickColor"] = function(value)
			-- BrickColor.Number (Its enum ID) will be slightly more efficient in all cases in deser,
			-- so we'll use it if Options.Prettify is false
			return "BrickColor.new(" .. ((Prettify and TypeCase("string", value.Name)) or value.Number) .. ")"
		end

		TypeCases["CFrame"] = function(value)
			return "CFrame.new(" .. Args(value:components()) .. ")"
		end

		TypeCases["CatalogSearchParams"] = function(value)
			return Params("CatalogSearchParams.new()", {
				SearchKeyword = value.SearchKeyword,
				MinPrice = value.MinPrice,
				MaxPrice = value.MaxPrice,
				SortType = value.SortType, -- EnumItem
				CategoryFilter = value.CategoryFilter, -- EnumItem
				BundleTypes = value.BundleTypes, -- table
				AssetTypes = value.AssetTypes, -- table
			})
		end

		TypeCases["Color3"] = function(value)
			return "Color3.new(" .. Args(value.R, value.G, value.B) .. ")"
		end

		TypeCases["ColorSequence"] = function(value)
			return "ColorSequence.new(" .. TypeCase("table", value.Keypoints) .. ")"
		end

		TypeCases["ColorSequenceKeypoint"] = function(value)
			return "ColorSequenceKeypoint.new(" .. Args(value.Time, value.Value) .. ")"
		end

		TypeCases["DateTime"] = function(value)
			return "DateTime.fromUnixTimestamp(" .. value.UnixTimestamp .. ")"
		end

		-- Properties seem to throw an error on index if the scope isn't a Studio plugin, so we're
		-- directly getting values! (so fun!!!!)
		TypeCases["DockWidgetPluginGuiInfo"] = function(value)
			-- e.g.: "InitialDockState:Right InitialEnabled:0 InitialEnabledShouldOverrideRestore:0 FloatingXSize:0 FloatingYSize:0 MinWidth:0 MinHeight:0"
			local ValueString = tostring(value)

			return "DockWidgetPluginGuiInfo.new("
				.. Args(
					-- InitialDockState (Enum.InitialDockState)
					Enum.InitialDockState[string_match(ValueString, "InitialDockState:(%w+)")], -- Enum.InitialDockState.Right
					-- InitialEnabled and InitialEnabledShouldOverrideRestore (boolean as number; `0` or `1`)
					string_match(ValueString, "InitialEnabled:(%w+)") == "1", -- false
					string_match(ValueString, "InitialEnabledShouldOverrideRestore:(%w+)") == "1", -- false
					-- FloatingXSize/FloatingYSize (numbers)
					tonumber(string_match(ValueString, "FloatingXSize:(%w+)")), -- 0
					tonumber(string_match(ValueString, "FloatingYSize:(%w+)")), -- 0
					-- MinWidth/MinHeight (numbers)
					tonumber(string_match(ValueString, "MinWidth:(%w+)")), -- 0
					tonumber(string_match(ValueString, "MinHeight:(%w+)")) -- 0
				)
				.. ")"
		end

		-- e.g. `Enum.UserInputType`
		TypeCases["Enum"] = function(value)
			local ValueString = tostring(value)

			if string_match(ValueString, DirectIndexPat) then
				return "Enum." .. ValueString
			end
			return "Enum[" .. SerializeString(ValueString) .. "]"
		end

		-- e.g. `Enum.UserInputType.Gyro`
		TypeCases["EnumItem"] = function(value)
			local EnumTypeStr = TypeCase("Enum", value.EnumType)
			local EnumName = value.Name

			if string_match(EnumName, DirectIndexPat) then
				return EnumTypeStr .. "." .. value.Name
			end
			return EnumTypeStr .. "[" .. SerializeString(EnumName) .. "]"
		end

		-- i.e. the `Enum` global return
		TypeCases["Enums"] = function(value)
			return "Enum"
		end

		TypeCases["Faces"] = function(value)
			local EncodedArgs = {}
			local EnumValues = {
				["Enum.NormalId.Top"] = value.Top, -- These return bools
				["Enum.NormalId.Bottom"] = value.Bottom,
				["Enum.NormalId.Left"] = value.Left,
				["Enum.NormalId.Right"] = value.Right,
				["Enum.NormalId.Back"] = value.Back,
				["Enum.NormalId.Front"] = value.Front,
			}

			for EnumValue, IsEnabled in next, EnumValues do
				if IsEnabled then
					EncodedArgs[#EncodedArgs + 1] = EnumValue
				end
			end

			return "Faces.new(" .. table_concat(EncodedArgs, ValueSeperator) .. ")"
		end

		TypeCases["FloatCurveKey"] = function(value)
			return "FloatCurveKey.new(" .. Args(value.Time, value.Value, value.Interpolation) .. ")"
		end

		TypeCases["Font"] = function(value)
			return "Font.new(" .. Args(value.Family, value.Weight, value.Style) .. ")"
		end

		-- Instance refs can be evaluated to their paths (optional), but if parented to
		-- nil or some DataModel not under `game`, it'll just return nil
		TypeCases["Instance"] = function(value)
			if UseInstancePaths then
				local InstancePath = EvaluateInstancePath(value, UseFindFirstChild)
				if InstancePath then
					return InstancePath
				end
			end

			return "nil"
				.. BlankSeperator
				.. CommentBlock(
					"Instance.new("
						.. TypeCase("string", value.ClassName)
						.. ")"
						.. BlankSeperator
						.. "{"
						.. "Name:"
						.. BlankSeperator
						.. SerializeString(value.Name)
						.. "}"
				)
		end

		TypeCases["NumberRange"] = function(value)
			return "NumberRange.new(" .. Args(value.Min, value.Max) .. ")"
		end

		TypeCases["NumberSequence"] = function(value)
			return "NumberSequence.new(" .. TypeCase("table", value.Keypoints) .. ")"
		end

		TypeCases["NumberSequenceKeypoint"] = function(value)
			return "NumberSequenceKeypoint.new(" .. Args(value.Time, value.Value, value.Envelope) .. ")"
		end

		TypeCases["OverlapParams"] = function(value)
			return Params("OverlapParams.new()", {
				FilterDescendantsInstances = value.FilterDescendantsInstances,
				FilterType = value.FilterType,
				MaxParts = value.MaxParts,
				CollisionGroup = value.CollisionGroup,
				RespectCanCollide = value.RespectCanCollide,
			})
		end

		TypeCases["Path2DControlPoint"] = function(value)
			return "Path2DControlPoint.new(" .. Args(value.Position, value.LeftTangent, value.RightTangent) .. ")"
		end

		TypeCases["PathWaypoint"] = function(value)
			return "PathWaypoint.new(" .. Args(value.Position, value.Action, value.Label) .. ")"
		end

		TypeCases["PhysicalProperties"] = function(value)
			return "PhysicalProperties.new("
				.. Args(value.Density, value.Friction, value.Elasticity, value.FrictionWeight, value.ElasticityWeight)
				.. ")"
		end

		TypeCases["Random"] = function()
			return "Random.new()"
		end

		TypeCases["Ray"] = function(value)
			return "Ray.new(" .. Args(value.Origin, value.Direction) .. ")"
		end

		TypeCases["RaycastParams"] = function(value)
			return Params("RaycastParams.new()", {
				FilterDescendantsInstances = value.FilterDescendantsInstances,
				FilterType = value.FilterType,
				IgnoreWater = value.IgnoreWater,
				CollisionGroup = value.CollisionGroup,
				RespectCanCollide = value.RespectCanCollide,
			})
		end

		TypeCases["Rect"] = function(value)
			return "Rect.new(" .. Args(value.Min, value.Max) .. ")"
		end

		-- Roblox doesn't provide direct read properties for min/max on `Region3`, but they do on Region3int16..
		TypeCases["Region3"] = function(value)
			local ValuePos = value.CFrame.Position
			local ValueSize = 0.5 * value.Size

			return "Region3.new("
				.. Args(
					ValuePos - ValueSize, -- Minimum
					ValuePos + ValueSize -- Maximum
				)
				.. ")"
		end

		TypeCases["Region3int16"] = function(value)
			return "Region3int16.new(" .. Args(value.Min, value.Max) .. ")"
		end

		TypeCases["TweenInfo"] = function(value)
			return "TweenInfo.new("
				.. Args(
					value.Time,
					value.EasingStyle,
					value.EasingDirection,
					value.RepeatCount,
					value.Reverses,
					value.DelayTime
				)
				.. ")"
		end

		TypeCases["RotationCurveKey"] = function(value)
			return "RotationCurveKey.new(" .. Args(value.Time, value.Value, value.Interpolation) .. ")"
		end

		TypeCases["UDim"] = function(value)
			return "UDim.new(" .. Args(value.Scale, value.Offset) .. ")"
		end

		TypeCases["UDim2"] = function(value)
			return "UDim2.new(" .. Args(value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset) .. ")"
		end

		TypeCases["Vector2"] = function(value)
			return "Vector2.new(" .. Args(value.X, value.Y) .. ")"
		end

		TypeCases["Vector2int16"] = function(value)
			return "Vector2int16.new(" .. Args(value.X, value.Y) .. ")"
		end

		TypeCases["Vector3"] = function(value)
			return "Vector3.new(" .. Args(value.X, value.Y, value.Z) .. ")"
		end

		TypeCases["Vector3int16"] = function(value)
			return "Vector3int16.new(" .. Args(value.X, value.Y, value.Z) .. ")"
		end

		TypeCases["buffer"] = function(value)
			return "buffer.fromstring(" .. SerializeString(buffer.tostring(value)) .. ")"
		end

		TypeCases["SharedTable"] = function(value, isKey)
			local StClone = {}
			-- Will still compile in vanilla Lua if we do it this way. We should probably create a deep clone
			-- of the current state of the table regardless
			for Key, Value in SharedTable.clone(value, not SharedTableLarpAsRegTable) do
				StClone[Key] = Value
			end

			local StCloneStr = TypeCases["table"](StClone, isKey, true) -- 3rd arg is stLarpAsRegTable
			if SharedTableLarpAsRegTable then
				return StCloneStr
			end
			return table_concat({ "SharedTable.new(", StCloneStr, ")" })
		end

		TypeCases["userdata"] = function(value)
			if getmetatable(value) ~= nil then -- Has mt
				return "newproxy(true)"
			else
				return "newproxy()" -- newproxy() defaults to false (no mt)
			end
		end
	end

	-- Setup for final output, which will be concat together
	local Output = {}

	local TablePointer = inputTable
	local NextKey = nil -- Used with TableStack so the TablePointer loop knows where to continue from upon stack pop
	local IsNewTable = true -- Used with table stack push/pop to identify when an opening curly brace should be added

	-- Stack array for table depth
	local TableStack = {} -- [Depth: number] = {TablePointer: table, NextKey: any, KeyNumIndex: number}
	local RefMaps = { [TablePointer] = "" } -- [Ref: table] = ".example["ref path"]'
	local CycleMaps = {} -- ['.example["ref path"]'] = '.another["ref path"]'

	while TablePointer do
		-- Update StackLevel for formatting
		StackLevel = StackLevelOpt + #TableStack
		IndentString = (Prettify and string_rep(IndentStringBase, StackLevel)) or IndentStringBase
		EndingIndentString = (#IndentString > 0 and string_sub(IndentString, 1, -IndentCount - 1)) or ""

		-- Only append an opening brace to the table if this isn't just a continution up the stack
		if IsNewTable then
			Output[#Output + 1] = "{"
		elseif next(TablePointer, NextKey) == nil then -- Formatting for the next entry still needs to be added like any other value
			Output[#Output + 1] = NewEntryString .. EndingIndentString
		else
			Output[#Output + 1] = ","
		end

		VisitedTables[TablePointer] = true

		-- Just because of control flow restrictions with Lua compatibility
		local SkipStackPop = false

		for Key, Value in next, TablePointer, NextKey do
			local KeyType, ValueType = Type(Key), Type(Value)
			local ValueIsTable = ValueType == "table"
			local KeyTypeCase, ValueTypeCase = TypeCases[KeyType], TypeCases[ValueType]

			Output[#Output + 1] = NewEntryString .. IndentString

			if KeyTypeCase and ValueTypeCase then
				local ValueWasEncoded = false -- Keeping track of this for adding a "," to the output if needed

				-- Evaluate output for key
				local KeyEncodedSuccess, EncodedKeyOrError, DontEncloseKeyInBrackets = pcall(KeyTypeCase, Key, true) -- The `true` represents if it's a key or not, here it is

				-- Evaluate output for value, ignoring 2nd arg (`DontEncloseInBrackets`) because this isn't the key
				local ValueEncodedSuccess, EncodedValueOrError
				if not ValueIsTable then
					ValueEncodedSuccess, EncodedValueOrError = pcall(ValueTypeCase, Value, false)
				end

				-- Ignoring `if EncodedKeyOrError` because the key doesn't actually need to ALWAYS
				-- be explicitly encoded, like if it's a number of the current key index!
				if KeyEncodedSuccess and (ValueIsTable or (ValueEncodedSuccess and EncodedValueOrError)) then
					-- Append explicit key if necessary
					if EncodedKeyOrError then
						if DontEncloseKeyInBrackets then
							Output[#Output + 1] = EncodedKeyOrError
						else
							Output[#Output + 1] = table_concat({ "[", EncodedKeyOrError, "]" })
						end

						Output[#Output + 1] = EqualsSeperator
					end

					-- Of course, recursive tables are handled differently and use the stack system
					if ValueIsTable then
						local IndexPath
						if InsertCycles and KeyIndexTypes[KeyType] and RefMaps[TablePointer] then
							if KeyType == "string" and not LuaKeywords[Key] and string_match(Key, DirectIndexPat) then
								IndexPath = "." .. Key
							else
								local EncodedKeyAsValue = TypeCases[KeyType](Key)
								IndexPath = table_concat({ "[", EncodedKeyAsValue, "]" })
							end
						end

						if not VisitedTables[Value] then
							if IndexPath then
								RefMaps[Value] = RefMaps[TablePointer] .. IndexPath
							end

							TableStack[#TableStack + 1] = { TablePointer, Key, KeyNumIndex }

							TablePointer = Value
							NextKey = nil
							KeyNumIndex = 1

							IsNewTable = true
							SkipStackPop = true
							break
						else
							EncodedValueOrError =
								string_format("{%s}", (OutputWarnings and "--[[LuaEncode: Duplicate reference]]") or "")

							if IndexPath then
								CycleMaps[IndexPath] = RefMaps[Value]
							end
						end
					end

					-- Append value like normal
					Output[#Output + 1] = EncodedValueOrError

					ValueWasEncoded = true
				elseif OutputWarnings then -- Then `Encoded(Key/Value)OrError` is the error msg
					-- ^^ Then either the key or value wasn't properly checked or encoded, and there
					-- was an error we need to log!
					local ErrorMessage = string_format(
						"LuaEncode: Failed to serialize %s of data type %s: %s",
						(not KeyEncodedSuccess and "key") or (not ValueEncodedSuccess and "value") or "key/value",
						ValueType,
						(not KeyEncodedSuccess and SerializeString(EncodedKeyOrError))
							or (not ValueEncodedSuccess and SerializeString(EncodedValueOrError))
							or "(Failed to get error message)"
					)

					Output[#Output + 1] = CommentBlock(ErrorMessage)
				end

				if next(TablePointer, Key) == nil then
					-- If there isn't another value after the current index, add ending formatting
					Output[#Output + 1] = NewEntryString .. EndingIndentString
				elseif ValueWasEncoded then
					Output[#Output + 1] = ","
				end
			else
				-- Data type is unimplemented

				-- Dtc
				local KeyTostring = (KeyType == "userdata" and "userdata") or tostring(Key)
				local ValueTostring = (ValueType == "userdata" and "userdata") or tostring(Value)

				Output[#Output + 1] = CommentBlock(
					BlankSeperator
						.. KeyType
						.. "("
						.. SerializeString(KeyTostring)
						.. ")"
						.. ":"
						.. BlankSeperator
						.. ValueType
						.. "("
						.. SerializeString(ValueTostring)
						.. ")"
						.. BlankSeperator
				)

				if next(TablePointer, Key) == nil then
					Output[#Output + 1] = NewEntryString .. EndingIndentString
				end
			end
		end

		-- Vanilla Lua control flow is fun
		if not SkipStackPop then
			if not Prettify and IndentCount > 0 then
				Output[#Output + 1] = IndentString
			end
			Output[#Output + 1] = "}"

			if #TableStack > 0 then
				local TableUp = TableStack[#TableStack]
				TableStack[#TableStack] = nil -- Pop off the table stack

				TablePointer, NextKey, KeyNumIndex = TableUp[1], TableUp[2], TableUp[3]
				IsNewTable = false
			else
				break
			end
		end
	end

	if InsertCycles then
		local CycleMapsOut = {}
		for CycleIndex, CycleMap in next, CycleMaps do
			CycleMapsOut[#CycleMapsOut + 1] = IndentString
				.. "t"
				.. CycleIndex
				.. EqualsSeperator
				.. "t"
				.. CycleMap
				.. CodegenNewline
		end

		if #CycleMapsOut > 0 then
			return table_concat({
				"(function(t)",
				NewEntryString,
				table_concat(CycleMapsOut),
				NewEntryString,
				IndentString,
				"return t",
				CodegenNewline,
				"end)(",
				table_concat(Output),
				")",
			})
		end
	end

	return table_concat(Output)
end

return LuaEncode

end)() end,
    [10] = function()local wax,script,require=ImportGlobals(10)local ImportGlobals return (function(...)-- MIT License | Copyright (c) 2023-2025 Latte Softworks <https://latte.to>

return {
	Log = require("./LuneUtils/Log"),
	StringUtils = require("./LuneUtils/StringUtils"),
	CommandUtils = require("./LuneUtils/CommandUtils"),
	WebhookQueue = require("./LuneUtils/WebhookQueue"),

	Run = require("./LuneUtils/Run"),
	ParseArgs = require("./LuneUtils/ParseArgs"),
	EnsureFileTree = require("./LuneUtils/EnsureFileTree"),
	RecursiveReadDir = require("./LuneUtils/RecursiveReadDir"),
}

end)() end,
    [11] = function()local wax,script,require=ImportGlobals(11)local ImportGlobals return (function(...)-- MIT License | Copyright (c) 2023-2025 Latte Softworks <https://latte.to>

local process = require("@lune/process")

local CommandUtils = {}

function CommandUtils.CommandExists(binary: string): boolean
	if process.os ~= "windows" then
		-- Unix-compliance is simple!
		return process.exec("type", { binary }, { shell = true }).ok -- Return from status code directly
	end

	-- I hate Windows
	return true
end

function CommandUtils.CheckCommands(requiredCommands: { string })
	-- Check required commands to continue script exec
	for _, Command in requiredCommands do
		assert(
			CommandUtils.CommandExists(Command),
			`Required command "{Command}" no found in your PATH environment variable, is it not installed?`
		)
	end
end

return CommandUtils

end)() end,
    [12] = function()local wax,script,require=ImportGlobals(12)local ImportGlobals return (function(...)-- MIT License | Copyright (c) 2023-2025 Latte Softworks <https://latte.to>

local fs = require("@lune/fs")

--[[
    This kinda looks like a strange function, because of the format a "FileTree" accepts:

    ```lua
    EnsureFileTree({
        ["test"] = {
            ["test.txt"] = "hi",
            ["test.json"] = "[\"hi again\"]",
            ["another-sub-dir"] = {
                ["bye.txt"] = "bye"
            },
        },
        ["another-test"] = {
            ["another-example.txt"] = "real",
        },
    })
    ```
]]
local function EnsureFileTree(fileTree: { [string]: any }, _currentPath: string?)
	for FileName, Entry in fileTree do
		local RealPath = if _currentPath then `{_currentPath}/{FileName}` else FileName
		local EntryType = type(Entry)

		if EntryType == "table" then -- This is to be a directory
			if not fs.isDir(RealPath) then
				fs.writeDir(RealPath)
			end

			-- Recursively continue creating the file tree..
			EnsureFileTree(Entry, RealPath)
		elseif EntryType == "string" and not fs.isFile(RealPath) then -- This is to be a file
			fs.writeFile(RealPath, Entry)
		end
	end
end

return EnsureFileTree

end)() end,
    [13] = function()local wax,script,require=ImportGlobals(13)local ImportGlobals return (function(...)-- MIT License | Copyright (c) 2023-2025 Latte Softworks <https://latte.to>

local stdio = require("@lune/stdio")

local ANSI = {
	Reset = stdio.color("reset") .. stdio.style("reset"),

	Red = stdio.color("red"),
	Yellow = stdio.color("yellow"),

	Bold = stdio.style("bold"),
}

local Log = {}

function Log.Info(message: string, ending: string?)
	ending = ending or "\n"
	stdio.write(`∙ {message}{ending}`)
end

function Log.Error(message: string, ending: string?)
	ending = ending or "\n"
	stdio.ewrite(`{ANSI.Bold .. ANSI.Red}∙ {message}{ANSI.Reset}{ending}`)
end

function Log.Warn(message: string, ending: string?)
	ending = ending or "\n"
	stdio.write(`{ANSI.Bold .. ANSI.Yellow}∙ {message}{ANSI.Reset}{ending}`)
end

function Log.InternalError(message: string, ending: string?)
	Log.Error("[INTERNAL ERROR] " .. message, ending)
end

return Log

end)() end,
    [14] = function()local wax,script,require=ImportGlobals(14)local ImportGlobals return (function(...)-- MIT License | Copyright (c) 2023-2025 Latte Softworks <https://latte.to>

type OptionsInput = { [string]: { string | number | boolean | nil } }
type OptionsOutput = { [string]: string | number | boolean | nil }

local process = require("@lune/process")

local Log = require("./Log")

local function ParseArgs(args: { string }, optionsTable: OptionsInput, usageMessage: string?): OptionsOutput
	local function ErrorExit()
		if usageMessage then
			print(`\n{usageMessage}`)
		end
		process.exit(1)
	end

	local OptionsOutput = {}

	for _, Arg in args do
		local Option, Value = string.match(Arg, "([%w%-_]+)=(.+)")

		if not Option then
			Log.Error(`Command argument given, "{Arg}" not in the proper \`option=value\` format, aborting..`)
			ErrorExit()
		end

		local OptionDetails = optionsTable[Option]

		if OptionDetails == nil then -- Then it isn't a defined arg
			Log.Error(`"{Option}" isn't a valid option"`)
			ErrorExit()
		end

		local OptionType = OptionDetails[1]

		if OptionType == "boolean" then
			Value = string.lower(Value)
			Value = if Value == "true" then true elseif Value == "false" then false else nil

			if Value == nil then
				Log.Error(`"{Value}" isn't a valid boolean type; expected "true" or "false"`)
				ErrorExit()
			end
		elseif OptionType == "number" then
			Value = tonumber(Value)
			if not Value then
				Log.Error(`Failed to convert given input "{Value}" to a number value`)
				ErrorExit()
			end
		end

		OptionsOutput[Option] = Value
	end

	for Option, Details in optionsTable do
		local DefaultValue = Details[2]
		local IsRequired = Details[3] or false

		if not OptionsOutput[Option] then
			if IsRequired then
				Log.Error(`Option "{Option}" required but not provided`)
				ErrorExit()
			end

			OptionsOutput[Option] = DefaultValue
		end
	end

	return OptionsOutput
end

return ParseArgs

end)() end,
    [15] = function()local wax,script,require=ImportGlobals(15)local ImportGlobals return (function(...)-- MIT License | Copyright (c) 2023-2025 Latte Softworks <https://latte.to>

local fs = require("@lune/fs")

local function RecursiveReadDir(directory: string, _existingFileList: { string }?): { string }
	if not string.match(directory, "[/\\]$") then
		directory ..= "/"
	end

	local FileList = _existingFileList or {}
	for _, EntryName in fs.readDir(directory) do
		if fs.isFile(EntryName) then
			table.insert(FileList, directory .. EntryName)
		else -- Is dir
			RecursiveReadDir(directory .. EntryName .. "/", FileList)
		end
	end

	return FileList
end

return RecursiveReadDir

end)() end,
    [16] = function()local wax,script,require=ImportGlobals(16)local ImportGlobals return (function(...)-- MIT License | Copyright (c) 2023-2025 Latte Softworks <https://latte.to>

local process = require("@lune/process")

local Log = require("./Log")

local function Run(
	command: string,
	args: { string }?,
	directRun: boolean?,
	errorHandler: (string?) -> ()?
): process.ExecResult
	local Args = args or {}
	local DirectRun = if directRun == nil then false else directRun

	if not DirectRun then
		if #Args == 0 then
			Log.Info(`> {command}`)
		else
			Log.Info(`> {command} {table.concat(Args, " ")}`)
		end
	end

	local Result = process.exec(command, args, {
		shell = if process.os ~= "windows" then true else nil,
		stdio = if DirectRun then "default" else "inherit",
	})

	if not Result.ok and errorHandler then
		errorHandler(`Command above failed with status code {Result.code}`)
	end

	return Result
end

return Run

end)() end,
    [17] = function()local wax,script,require=ImportGlobals(17)local ImportGlobals return (function(...)-- MIT License | Copyright (c) 2023-2025 Latte Softworks <https://latte.to>

local StringUtils = {}

function StringUtils.FileType(filePath: string): string?
	local Match = string.match(filePath, ".%.([^%.]+)$")
	if Match then
		Match = string.lower(Match)
	end

	return Match
end

function StringUtils.FileNameFromPath(filePath: string): string?
	return string.match(filePath, "[^/\\]+$")
end

function StringUtils.FileNameWithoutExtension(fileName: string, onlyTheLastDot: boolean?): string?
	onlyTheLastDot = if onlyTheLastDot == nil then true else onlyTheLastDot

	if onlyTheLastDot then
		return string.match(fileName, "^(.+)%.")
	else
		return string.match(fileName, "^%.?[^%.]+")
	end
end

function StringUtils.FilePathWithoutExtension(filePath: string, onlyTheLastDot: boolean?): string?
	local FilePathDirectory = StringUtils.DirectoryOfFilePath(filePath)
	local FileName = StringUtils.FileNameFromPath(filePath)

	if not FilePathDirectory or not FileName then
		return
	end

	local FileNameStripped = StringUtils.FileNameWithoutExtension(FileName, onlyTheLastDot)
	if not FileNameStripped then
		return
	end

	return FilePathDirectory .. FileNameStripped
end

function StringUtils.DirectoryOfFilePath(filePath: string): string?
	local Directory = string.match(filePath, "^.*[/\\]")
	if not Directory or Directory == "" then
		Directory = "./"
	end

	return Directory
end

function StringUtils.SplitStringByPattern(originalString: string, pattern: string)
	local SplitArray = {}
	for Match in string.gmatch(originalString, pattern) do
		table.insert(SplitArray, Match)
	end

	return SplitArray
end

function StringUtils.SplitFilePath(filePath: string)
	return StringUtils.SplitStringByPattern(filePath, "([^/\\]+)[/\\]?")
end

function StringUtils.LineCount(input: string): number
	local Lines = 1
	for _ in string.gmatch(input, "\n") do
		Lines += 1
	end

	return Lines
end

function StringUtils.Replace(inputString: string, replacements: { [string]: string }): string
	return string.gsub(inputString, "${([A-Za-z_][A-Za-z0-9_]*)}", replacements)
end

-- Based from https://github.com/regginator/LuaEncode/blob/995daa18266dab2e2b94f43189d6eadb46f82c79/src/LuaEncode.lua#L76-L108
do
	-- These are control characters to be encoded in a certain way in Lua rather than just a byte
	-- escape (e.g. "\n" -> "\10")
	local SpecialCharacters = {
		['"'] = '\\"', -- Double-Quote
		["\\"] = "\\\\", -- (Literal) Backslash
		-- Special ASCII control char codes
		["\a"] = "\\a", -- Bell; ASCII #7
		["\b"] = "\\b", -- Backspace; ASCII #8
		["\t"] = "\\t", -- Horizontal-Tab; ASCII #9
		["\n"] = "\\n", -- Newline; ASCII #10
		["\v"] = "\\v", -- Vertical-Tab; ASCII #11
		["\f"] = "\\f", -- Form-Feed; ASCII #12
		["\r"] = "\\r", -- Carriage-Return; ASCII #13
	}

	-- We need to assign all extra normal byte escapes for runtime optimization
	for Index = 0, 255 do
		local Character = string.char(Index)

		if not SpecialCharacters[Character] and (Index < 32 or Index > 126) then
			SpecialCharacters[Character] = "\\" .. Index
		end
	end

	function StringUtils.SerializeStringData(inputString: string): string
		-- FYI; We can't do "\0-\31" in Lua 5.1 (Only Luau/Lua 5.2+) due to an embedded zeros in pattern
		-- issue. See: https://stackoverflow.com/a/22962409
		local Serialized = string.gsub(inputString, '[%z\\"\1-\31\127-\255]', SpecialCharacters)
		return Serialized
	end
end

return StringUtils

end)() end,
    [18] = function()local wax,script,require=ImportGlobals(18)local ImportGlobals return (function(...)-- MIT License | Copyright (c) 2023-2025 Latte Softworks <https://latte.to>

export type WebhookObject = { [string]: any }

local net = require("@lune/net")
local task = require("@lune/task")
local serde = require("@lune/serde")

-- Setup everything used in the main thread
local QueueIsRunning = false -- Used for `WebhookQueue.Stop()`
local QueueTable = {}

-- Start the running thread to listen to the queue
local function Start(waitInterval: number?)
	waitInterval = waitInterval or 3

	if QueueIsRunning then -- Already running, must've been a mistake
		return
	end

	QueueIsRunning = true

	task.spawn(function()
		while QueueIsRunning do
			repeat
				task.wait()
			until #QueueTable >= 1
			local WebhookEntry = QueueTable[1]

			local WebhookUrl = WebhookEntry[1]
			local WebhookObject: WebhookObject = WebhookEntry[2]

			local Encoded = serde.encode("json", WebhookObject)

			local DiscordResponse = net.request({
				url = WebhookUrl,
				method = "POST",
				headers = {
					["Content-Type"] = "application/json",
				},
				body = Encoded,
			})

			if not DiscordResponse.ok then
				print(
					`[!] Error in webhook request ({DiscordResponse.statusCode}): {DiscordResponse.body}\n[^^ Waiting 5 seconds..]`
				)
				task.wait(5)
				continue
			end

			print(`[*] Discord Response ({DiscordResponse.statusCode}): {DiscordResponse.body}`)

			-- Wait the interval now..
			task.wait(waitInterval)

			-- Finnaly, remove the current webhook object from the queue, which also triggers `Await()`
			table.remove(QueueTable, 1)
		end
	end)
end

-- Stop the running thread
local function Stop()
	QueueIsRunning = false
end

-- Add to the Webhook post queue
local function Add(webhookUrl: string, webhookObject: WebhookObject)
	table.insert(QueueTable, {
		[1] = webhookUrl,
		[2] = webhookObject,
	})
end

-- "Clear" all entries from the queue
local function Clear()
	QueueTable = {}
end

-- Await in the current running thread for the queue to finish all tasks
local function Await()
	repeat
		task.wait()
	until #QueueTable == 0
end

return {
	Start = Start,
	Stop = Stop,
	Add = Add,
	Clear = Clear,
	Await = Await,
}

end)() end
} -- [RefId] = Closure

-- Holds the actual DOM data
local ObjectTree = {
    {
        1,
        2,
        {
            "Wax"
        },
        {
            {
                2,
                1,
                {
                    "lib"
                },
                {
                    {
                        3,
                        2,
                        {
                            "BundleModel"
                        }
                    },
                    {
                        4,
                        1,
                        {
                            "data"
                        },
                        {
                            {
                                7,
                                2,
                                {
                                    "Version"
                                }
                            },
                            {
                                5,
                                2,
                                {
                                    "DefaultDarkluaConfig"
                                }
                            },
                            {
                                6,
                                2,
                                {
                                    "Template"
                                }
                            }
                        }
                    },
                    {
                        8,
                        1,
                        {
                            "libraries"
                        },
                        {
                            {
                                10,
                                2,
                                {
                                    "LuneUtils"
                                },
                                {
                                    {
                                        18,
                                        2,
                                        {
                                            "WebhookQueue"
                                        }
                                    },
                                    {
                                        13,
                                        2,
                                        {
                                            "Log"
                                        }
                                    },
                                    {
                                        16,
                                        2,
                                        {
                                            "Run"
                                        }
                                    },
                                    {
                                        12,
                                        2,
                                        {
                                            "EnsureFileTree"
                                        }
                                    },
                                    {
                                        17,
                                        2,
                                        {
                                            "StringUtils"
                                        }
                                    },
                                    {
                                        15,
                                        2,
                                        {
                                            "RecursiveReadDir"
                                        }
                                    },
                                    {
                                        14,
                                        2,
                                        {
                                            "ParseArgs"
                                        }
                                    },
                                    {
                                        11,
                                        2,
                                        {
                                            "CommandUtils"
                                        }
                                    }
                                }
                            },
                            {
                                9,
                                2,
                                {
                                    "LuaEncode"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

-- Line offsets for debugging (only included when minifyTables is false)
local LineOffsets = {
    22,
    [3] = 505,
    [5] = 757,
    [6] = 789,
    [7] = 1304,
    [9] = 1307,
    [10] = 2200,
    [11] = 2215,
    [12] = 2244,
    [13] = 2287,
    [14] = 2324,
    [15] = 2399,
    [16] = 2423,
    [17] = 2461,
    [18] = 2576
}

-- Misc AOT variable imports
local WaxVersion = "0.4.2"
local EnvName = "WaxRuntime"

-- ++++++++ RUNTIME IMPL BELOW ++++++++ --

-- Localizing certain libraries and built-ins for runtime efficiency
local string, task, setmetatable, error, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION =
      string, task, setmetatable, error, next, table, unpack, coroutine, script, type, require, pcall, tostring, tonumber, _VERSION

local table_insert = table.insert
local table_remove = table.remove
local table_freeze = table.freeze or function(t) return t end -- lol

local coroutine_wrap = coroutine.wrap

local string_sub = string.sub
local string_match = string.match
local string_gmatch = string.gmatch

-- The Lune runtime has its own `task` impl, but it must be imported by its builtin
-- module path, "@lune/task"
if _VERSION and string_sub(_VERSION, 1, 4) == "Lune" then
    local RequireSuccess, LuneTaskLib = pcall(require, "@lune/task")
    if RequireSuccess and LuneTaskLib then
        task = LuneTaskLib
    end
end

local task_defer = task and task.defer

-- If we're not running on the Roblox engine, we won't have a `task` global
local Defer = task_defer or function(f, ...)
    coroutine_wrap(f)(...)
end

-- ClassName "IDs"
local ClassNameIdBindings = {
    [1] = "Folder",
    [2] = "ModuleScript",
    [3] = "Script",
    [4] = "LocalScript",
    [5] = "StringValue",
}

local RefBindings = {} -- [RefId] = RealObject

local ScriptClosures = {}
local ScriptClosureRefIds = {} -- [ScriptClosure] = RefId
local StoredModuleValues = {}
local ScriptsToRun = {}

-- wax.shared __index/__newindex
local SharedEnvironment = {}

-- We're creating 'fake' instance refs soley for traversal of the DOM for require() compatibility
-- It's meant to be as lazy as possible
local RefChildren = {} -- [Ref] = {ChildrenRef, ...}

-- Implemented instance methods
local InstanceMethods = {
    GetFullName = { {}, function(self)
        local Path = self.Name
        local ObjectPointer = self.Parent

        while ObjectPointer do
            Path = ObjectPointer.Name .. "." .. Path

            -- Move up the DOM (parent will be nil at the end, and this while loop will stop)
            ObjectPointer = ObjectPointer.Parent
        end

        return Path
    end},

    GetChildren = { {}, function(self)
        local ReturnArray = {}

        for Child in next, RefChildren[self] do
            table_insert(ReturnArray, Child)
        end

        return ReturnArray
    end},

    GetDescendants = { {}, function(self)
        local ReturnArray = {}

        for Child in next, RefChildren[self] do
            table_insert(ReturnArray, Child)

            for _, Descendant in next, Child:GetDescendants() do
                table_insert(ReturnArray, Descendant)
            end
        end

        return ReturnArray
    end},

    FindFirstChild = { {"string", "boolean?"}, function(self, name, recursive)
        local Children = RefChildren[self]

        for Child in next, Children do
            if Child.Name == name then
                return Child
            end
        end

        if recursive then
            for Child in next, Children do
                -- Yeah, Roblox follows this behavior- instead of searching the entire base of a
                -- ref first, the engine uses a direct recursive call
                return Child:FindFirstChild(name, true)
            end
        end
    end},

    FindFirstAncestor = { {"string"}, function(self, name)
        local RefPointer = self.Parent
        while RefPointer do
            if RefPointer.Name == name then
                return RefPointer
            end

            RefPointer = RefPointer.Parent
        end
    end},

    -- Just to implement for traversal usage
    WaitForChild = { {"string", "number?"}, function(self, name)
        return self:FindFirstChild(name)
    end},
}

-- "Proxies" to instance methods, with err checks etc
local InstanceMethodProxies = {}
for MethodName, MethodObject in next, InstanceMethods do
    local Types = MethodObject[1]
    local Method = MethodObject[2]

    local EvaluatedTypeInfo = {}
    for ArgIndex, TypeInfo in next, Types do
        local ExpectedType, IsOptional = string_match(TypeInfo, "^([^%?]+)(%??)")
        EvaluatedTypeInfo[ArgIndex] = {ExpectedType, IsOptional}
    end

    InstanceMethodProxies[MethodName] = function(self, ...)
        if not RefChildren[self] then
            error("Expected ':' not '.' calling member function " .. MethodName, 2)
        end

        local Args = {...}
        for ArgIndex, TypeInfo in next, EvaluatedTypeInfo do
            local RealArg = Args[ArgIndex]
            local RealArgType = type(RealArg)
            local ExpectedType, IsOptional = TypeInfo[1], TypeInfo[2]

            if RealArg == nil and not IsOptional then
                error("Argument " .. RealArg .. " missing or nil", 3)
            end

            if ExpectedType ~= "any" and RealArgType ~= ExpectedType and not (RealArgType == "nil" and IsOptional) then
                error("Argument " .. ArgIndex .. " expects type \"" .. ExpectedType .. "\", got \"" .. RealArgType .. "\"", 2)
            end
        end

        return Method(self, ...)
    end
end

local function CreateRef(className, name, parent)
    -- `name` and `parent` can also be set later by the init script if they're absent

    -- Extras
    local StringValue_Value

    -- Will be set to RefChildren later aswell
    local Children = setmetatable({}, {__mode = "k"})

    -- Err funcs
    local function InvalidMember(member)
        error(member .. " is not a valid (virtual) member of " .. className .. " \"" .. name .. "\"", 3)
    end
    local function ReadOnlyProperty(property)
        error("Unable to assign (virtual) property " .. property .. ". Property is read only", 3)
    end

    local Ref = {}
    local RefMetatable = {}

    RefMetatable.__metatable = false

    RefMetatable.__index = function(_, index)
        if index == "ClassName" then -- First check "properties"
            return className
        elseif index == "Name" then
            return name
        elseif index == "Parent" then
            return parent
        elseif className == "StringValue" and index == "Value" then
            -- Supporting StringValue.Value for Rojo .txt file conv
            return StringValue_Value
        else -- Lastly, check "methods"
            local InstanceMethod = InstanceMethodProxies[index]

            if InstanceMethod then
                return InstanceMethod
            end
        end

        -- Next we'll look thru child refs
        for Child in next, Children do
            if Child.Name == index then
                return Child
            end
        end

        -- At this point, no member was found; this is the same err format as Roblox
        InvalidMember(index)
    end

    RefMetatable.__newindex = function(_, index, value)
        -- __newindex is only for props fyi
        if index == "ClassName" then
            ReadOnlyProperty(index)
        elseif index == "Name" then
            name = value
        elseif index == "Parent" then
            -- We'll just ignore the process if it's trying to set itself
            if value == Ref then
                return
            end

            if parent ~= nil then
                -- Remove this ref from the CURRENT parent
                RefChildren[parent][Ref] = nil
            end

            parent = value

            if value ~= nil then
                -- And NOW we're setting the new parent
                RefChildren[value][Ref] = true
            end
        elseif className == "StringValue" and index == "Value" then
            -- Supporting StringValue.Value for Rojo .txt file conv
            StringValue_Value = value
        else
            -- Same err as __index when no member is found
            InvalidMember(index)
        end
    end

    RefMetatable.__tostring = function()
        return name
    end

    setmetatable(Ref, RefMetatable)

    RefChildren[Ref] = Children

    if parent ~= nil then
        RefChildren[parent][Ref] = true
    end

    return Ref
end

-- Create real ref DOM from object tree
local function CreateRefFromObject(object, parent)
    local RefId = object[1]
    local ClassNameId = object[2]
    local Properties = object[3] -- Optional
    local Children = object[4] -- Optional

    local ClassName = ClassNameIdBindings[ClassNameId]

    local Name = Properties and table_remove(Properties, 1) or ClassName

    local Ref = CreateRef(ClassName, Name, parent) -- 3rd arg may be nil if this is from root
    RefBindings[RefId] = Ref

    if Properties then
        for PropertyName, PropertyValue in next, Properties do
            Ref[PropertyName] = PropertyValue
        end
    end

    if Children then
        for _, ChildObject in next, Children do
            CreateRefFromObject(ChildObject, Ref)
        end
    end

    return Ref
end

local RealObjectRoot = CreateRef("Folder", "[" .. EnvName .. "]")
for _, Object in next, ObjectTree do
    CreateRefFromObject(Object, RealObjectRoot)
end

-- Now we'll set script closure refs and check if they should be ran as a BaseScript
for RefId, Closure in next, ClosureBindings do
    local Ref = RefBindings[RefId]

    ScriptClosures[Ref] = Closure
    ScriptClosureRefIds[Ref] = RefId

    local ClassName = Ref.ClassName
    if ClassName == "LocalScript" or ClassName == "Script" then
        table_insert(ScriptsToRun, Ref)
    end
end

local function LoadScript(scriptRef)
    local ScriptClassName = scriptRef.ClassName

    -- First we'll check for a cached module value (packed into a tbl)
    local StoredModuleValue = StoredModuleValues[scriptRef]
    if StoredModuleValue and ScriptClassName == "ModuleScript" then
        return unpack(StoredModuleValue)
    end

    local Closure = ScriptClosures[scriptRef]

    local function FormatError(originalErrorMessage)
        originalErrorMessage = tostring(originalErrorMessage)

        local VirtualFullName = scriptRef:GetFullName()

        -- Check for vanilla/Roblox format
        local OriginalErrorLine, BaseErrorMessage = string_match(originalErrorMessage, "[^:]+:(%d+): (.+)")

        if not OriginalErrorLine or not LineOffsets then
            return VirtualFullName .. ":*: " .. (BaseErrorMessage or originalErrorMessage)
        end

        OriginalErrorLine = tonumber(OriginalErrorLine)

        local RefId = ScriptClosureRefIds[scriptRef]
        local LineOffset = LineOffsets[RefId]

        local RealErrorLine = OriginalErrorLine - LineOffset + 1
        if RealErrorLine < 0 then
            RealErrorLine = "?"
        end

        return VirtualFullName .. ":" .. RealErrorLine .. ": " .. BaseErrorMessage
    end

    -- If it's a BaseScript, we'll just run it directly!
    if ScriptClassName == "LocalScript" or ScriptClassName == "Script" then
        local RunSuccess, ErrorMessage = pcall(Closure)
        if not RunSuccess then
            error(FormatError(ErrorMessage), 0)
        end
    else
        local PCallReturn = {pcall(Closure)}

        local RunSuccess = table_remove(PCallReturn, 1)
        if not RunSuccess then
            local ErrorMessage = table_remove(PCallReturn, 1)
            error(FormatError(ErrorMessage), 0)
        end

        StoredModuleValues[scriptRef] = PCallReturn
        return unpack(PCallReturn)
    end
end

-- We'll assign the actual func from the top of this output for flattening user globals at runtime
-- Returns (in a tuple order): wax, script, require
function ImportGlobals(refId)
    local ScriptRef = RefBindings[refId]

    local function RealCall(f, ...)
        local PCallReturn = {pcall(f, ...)}

        local CallSuccess = table_remove(PCallReturn, 1)
        if not CallSuccess then
            error(PCallReturn[1], 3)
        end

        return unpack(PCallReturn)
    end

    -- `wax.shared` index
    local WaxShared = table_freeze(setmetatable({}, {
        __index = SharedEnvironment,
        __newindex = function(_, index, value)
            SharedEnvironment[index] = value
        end,
        __len = function()
            return #SharedEnvironment
        end,
        __iter = function()
            return next, SharedEnvironment
        end,
    }))

    local Global_wax = table_freeze({
        -- From AOT variable imports
        version = WaxVersion,
        envname = EnvName,

        shared = WaxShared,

        -- "Real" globals instead of the env set ones
        script = script,
        require = require,
    })

    local Global_script = ScriptRef

    local function Global_require(module, ...)
        local ModuleArgType = type(module)

        local ErrorNonModuleScript = "Attempted to call require with a non-ModuleScript"
        local ErrorSelfRequire = "Attempted to call require with self"

        if ModuleArgType == "table" and RefChildren[module]  then
            if module.ClassName ~= "ModuleScript" then
                error(ErrorNonModuleScript, 2)
            elseif module == ScriptRef then
                error(ErrorSelfRequire, 2)
            end

            return LoadScript(module)
        elseif ModuleArgType == "string" and string_sub(module, 1, 1) ~= "@" then
            -- The control flow on this SUCKS

            if #module == 0 then
                error("Attempted to call require with empty string", 2)
            end

            local CurrentRefPointer = ScriptRef

            if string_sub(module, 1, 1) == "/" then
                CurrentRefPointer = RealObjectRoot
            elseif string_sub(module, 1, 2) == "./" then
                module = string_sub(module, 3)
            end

            local PreviousPathMatch
            for PathMatch in string_gmatch(module, "([^/]*)/?") do
                local RealIndex = PathMatch
                if PathMatch == "." then
                    RealIndex = ""
                elseif PathMatch == ".." then
                    CurrentRefPointer = CurrentRefPointer.Parent
                    RealIndex = ""
                end

                -- Don't advance dir if it's just another "/" either
                if RealIndex ~= "" then
                    local ResultRef = CurrentRefPointer:FindFirstChild(RealIndex)
                    if not ResultRef then
                        local CurrentRefParent = CurrentRefPointer.Parent
                        if CurrentRefParent then
                            ResultRef = CurrentRefParent:FindFirstChild(RealIndex)
                        end
                    end

                    if ResultRef then
                        CurrentRefPointer = ResultRef
                    elseif PathMatch ~= PreviousPathMatch and PathMatch ~= "init" and PathMatch ~= "init.server" and PathMatch ~= "init.client" then
                        error("Virtual script path \"" .. module .. "\" not found", 2)
                    end
                end

                -- For possible checks next cycle
                PreviousPathMatch = PathMatch
            end

            if CurrentRefPointer.ClassName ~= "ModuleScript" then
                error(ErrorNonModuleScript, 2)
            elseif CurrentRefPointer == ScriptRef then
                error(ErrorSelfRequire, 2)
            end

            return LoadScript(CurrentRefPointer)
        end

        return RealCall(require, module, ...)
    end

    -- Now, return flattened globals ready for direct runtime exec
    return Global_wax, Global_script, Global_require
end

for _, ScriptRef in next, ScriptsToRun do
    Defer(LoadScript, ScriptRef)
end

-- AoT adjustment: Load init module (MainModule behavior)
return LoadScript(RealObjectRoot:GetChildren()[1])