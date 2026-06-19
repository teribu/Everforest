# a folder containing init.lua is treated as a ModuleScript.
# otherwise, it is treated as a normal Folder.

"""
Project: Scan source files -> Build a virtual ModuleScript tree
↓
Store module sources as:
Sources[instance] = function(script, require)
    ...
end
↓
Rewrite relative requires:
require("./creator")
→ require(script.Parent.creator)
↓
Generate a single Lua file
↓
Recreate the ModuleScript tree at runtime
↓
Override require():
require(instance)
→ Sources[instance]
→ Execute module
↓
Cache result
↓
Return module exports
"""

import sys
from pathlib import Path

from require import rewrite_requires

args = {}

for arg in sys.argv[1:]:
    if "=" in arg:
        key, value = arg.split("=", 1)
        args[key] = value

NAME = args.get("name", "Project")
INPUT = args.get("input", "src")
OUTPUT = args.get("output", f"{NAME}.lua")
SOURCE_EXTENSIONS = {
    ".lua",
    ".luau",
}

tree = {}
var_id = 0
content = f"""--[[
{NAME} folder tree:
"""


def next_var():
    global var_id
    var_id += 1
    return f"v{var_id}"


def build_tree(folder):
    tree = {}
    global content

    for item in sorted(Path(folder).iterdir()):
        if item.is_dir():
            content += f"Folder: {item.name}\n"
            tree[next_var()] = ["Folder", item.name, build_tree(item)]
        elif item.suffix in SOURCE_EXTENSIONS:
            content += f"{folder}\\{item.stem}\n"
            tree[next_var()] = [
                "ModuleScript",
                item.stem,
                item.read_text(encoding="utf-8"),
            ]
    return tree


tree = build_tree(INPUT)
content += f"""
]]

local Sources = {{}}
local {NAME} = Instance.new("ModuleScript")
{NAME}.Name = "{NAME}"
"""


def generate_source(source):
    source = rewrite_requires(source)
    source = "function(script, require)\n" + source + "\nend"
    return source


def generate_map(tree, parent):
    global content
    for file, source in tree.items():
        if source[0] == "Folder":
            kind = (
                "ModuleScript"
                if any(child[1] == "init" for child in source[2].values())
                else "Folder"
            )

            content += f'local {file} = Instance.new("{kind}", {parent})\n'
            content += f'{file}.Name = "{source[1]}"\n'
            generate_map(source[2], file)
        else:
            if source[1] == "init":
                content += f"Sources[{parent}] = {generate_source(source[2])}\n"
            else:
                content += f"local {file} = Instance.new('ModuleScript', {parent})\n"
                content += f'{file}.Name = "{source[1]}"\n'
                content += f"Sources[{file}] = {generate_source(source[2])}\n"


generate_map(tree, NAME)

content += f"""
local Cache = {{}}
local Loading = {{}}
local OldRequire = require

function Require(target)
    if Sources[target] ~= nil then
        if Cache[target] == Loading then
            error("Circular require detected: " .. target:GetFullName())
        end
        if Cache[target] ~= nil then
            return Cache[target]
        end
        Cache[target] = Loading
        local factory = Sources[target]
        local result = factory(target, Require)

        if result == nil then
            result = true
        end
        Cache[target] = result
        return result
    end

    return OldRequire(target)
end

return Require({NAME})
"""
Path(OUTPUT).write_text(content, encoding="utf-8")
