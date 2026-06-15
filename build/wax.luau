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

local a local aa,ab,ac,ad,ae,af,ag,ah,ai,aj,ak,al,am,an,ao,ap,aq,ar,as,at={function()local b,c,d=a(1)local e return(
function(...)if string.sub(_VERSION,1,4)~='Lune'then print
[[!! Wax doesn't appear to be running on Lune (https://lune-org.github.io/docs), which this script requires, exitting..]]
return end do local f,g,h,i,j,k=0,8,0,string.match(_VERSION,'Lune (%d+).(%d+).(%d+)')i,j,k=tonumber(i),tonumber(j),
tonumber(k)if not i then print(`! Can't parse Lune's version on the assumed format from "{_VERSION}", continuing anyway..\n`
)else _G.LuneVersion=`{i}.{j}.{k}`if i<f or(j<g and i<=f)or(k<h and j<=g and i<=f)then print(`! Lune version "{_G.
LuneVersion}" detected, but Wax currently recommends Lune {f}.{g}.{h} or higher, continuing anyway..\n`)end end end
local f,g,h,i,j,k,l,m,n=d'@lune/fs',d'@lune/serde',d'@lune/stdio',d'@lune/roblox',d'@lune/process',d
'./lib/libraries/LuneUtils',d'./lib/BundleModel',d'./lib/data/Version',d'./lib/data/DefaultDarkluaConfig'local o,p,q,r,s
,t,u=k.Log,k.StringUtils,k.CommandUtils,k.Run,k.ParseArgs,`Wax {m}\n`..
[[A Fast Runtime-Based Lua 5.1x+/Luau Project Bundler, Using Roblox Models and Module-Require Semantics

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
,'Run `lune wax help` for more info'h.write(h.color'reset'..h.style'reset')local function v(w:string):string return if j
.os=='windows'then w else'"'..p.SerializeStringData(w)..'"'end local w=table.clone(j.args)local x=table.remove(w,1)if
not x then print(t)return end x=string.lower(x)if x=='help'then print(t)return elseif x=='version'then print(`Wax v{m}`)
return elseif x=='bundle'then local y=s(w,{input={'string','default.project.json'},output={'string',nil},minify={
'boolean',false},['env-name']={'string',nil},['darklua-config-path']={'string',nil},['temp-dir-base']={'string',nil},[
'extra-offset-lines']={'number',0},['ci-mode']={'boolean',false},verbose={'boolean',true}},t)local z,A,B,C=y.verbose,y[
'ci-mode'],y.minify,y['env-name']local function D(E,...)if z then E(...)end end local function E(F:string,G:string)D(o.
Info,`Writing to "{F}"..`)f.writeFile(F,G)end local function F(G:string)D(o.Info,`Deleting file at "{G}"..`)f.
removeFile(G)end local function G(H:string)D(o.Info,`Creating directory at "{H}"..`)f.writeDir(H)end local function H(I:
string)D(o.Info,`Removing directory at "{I}"..`)f.removeDir(I)end local I=y.input if not f.isFile(I)then o.Error(`Failed to find file path "{
I}" from \`input\` option\n`)print(u)j.exit(1)end local J,K=p.DirectoryOfFilePath(I)or'',string.lower(I)local L=if
string.sub(K,-5)=='.rbxm'then'.rbxm'elseif string.sub(K,-6)=='.rbxmx'then'.rbxmx'elseif string.sub(K,-13)==
'.project.json'then'.project.json'else nil if not L then o.Error(`Invalid file type ".{p.FileType(I)}" for \`input\`, expected [".rbxm", ".rbxmx", ".project.json"]\n`
)print(u)j.exit(1)end local M=y.output if not M then local N if L=='.project.json'then local O,P=pcall(g.decode,'json'::
'json',f.readFile(I))if not O then o.Error(`Failed to parse Rojo project file at "{I}": {P}`)j.exit(1)end if not P.name
or type(P.name)~='string'then o.Warn(`Couldn't find proper "name" entry at the root of Rojo project file at "{I}", using its file name base instead..`
)else N=P.name end end if not N then N=p.FilePathWithoutExtension(I,false)end if not N then o.InternalError(`Failed to get file path without the extension for "{
M}"`)j.exit(1)end N..='.wax.lua'M=J..N else local N,O=p.FileType(M),p.DirectoryOfFilePath(M)if not O then o.Error(`\`output\` file path given, "{
M}" not a valid path\n`)print(u)j.exit(1)elseif not f.isDir(O)then o.Error(`Directory of \`output\` file path given, "{O
}" not found/invalid\n`)print(u)j.exit(1)elseif not N or not table.find({'lua','luau'},N)then local P=if N==''then
'<empty>'else'.'..N o.Error(`File type of \`output\` ({P}) invalid, expected [".lua", ".luau"]\n`)print(u)j.exit(1)end
end local N=p.FileNameFromPath(M)if not N then o.InternalError(`Failed to parse file name from output file path "{M}"`)j
.exit(1)end local O=p.FileNameWithoutExtension(N,false)if not O then o.InternalError(`Failed to parse file name without its extension from "{
N}"`)j.exit(1)end DarkluaConfigPath=y['darklua-config-path']if DarkluaConfigPath and not f.isFile(DarkluaConfigPath)then
o.Error(`File path given for \`darklua-config-path\`, "{DarkluaConfigPath}" not found`)j.exit(1)end local P=y[
'temp-dir-base']if not P then P=p.DirectoryOfFilePath(M)elseif not f.isDir(P)then o.Error(`\`temp-dir-base\` directory given, "{
P}" not found/invalid\n`)print(u)j.exit(1)end if not string.match(P,'[/\\]$')then P..='/'end local Q=P..'.wax-tmp/'if f.
isDir(Q)then D(o.Info,`Old .wax-tmp dir at "{Q}" already exists, removing..`)f.removeDir(Q)end ExtraOffsetLines=y[
'extra-offset-lines']if ExtraOffsetLines<0 then o.Error(`Option \`extra-offset-lines\` ({ExtraOffsetLines}) cannot be less than 0\n`
)print(u)j.exit(1)end if not B and ExtraOffsetLines>0 then D(o.Info,`(Note) Runtime line debugging *will* display with the assumption that \`{
ExtraOffsetLines}\` lines will be added to the output by you manually; make sure this is EXACT, as debugging info could be inaccurate otherwise`
)end local function R(S:string?)if S then o.Error(S)end if f.isDir(Q)then H(Q)end j.exit(1)end if L=='.project.json'and
not q.CommandExists'rojo'then o.Error(`Rojo project file given for input ("{I}"), but the \`rojo\` command wasn't found in your PATH environment variable..\n`
)print(u)j.exit(1)end local S=q.CommandExists'darklua'if B and not S then o.Warn
[[The `minify` option is set as true, but the `darklua` command wasn't found in your PATH environment variable.. (Wax won't be able to completely minify the output)]]
if not A then local T=h.prompt('confirm','Continue anyway?')if not T then R()end end end if L=='.project.json'or(B and S
)then G(Q)end local T if table.find({'.rbxm','.rbxmx'},L)then D(o.Info,`Deserializing Roblox model file at "{I}"..`)
local U,V=pcall(i.deserializeModel,f.readFile(I))if not U then R(`Failed to deserialize Roblox model file at "{I}": {V}`
)end T=V elseif L=='.project.json'then local U=Q..O..'.o.rbxm'D(o.Info,`Building from Rojo project file to "{U}"`)r(
'rojo',{'build','-o',v(U),v(I)},false,R)T=i.deserializeModel(f.readFile(U))F(U)end local U,V,W=pcall(l,T,C,B,
ExtraOffsetLines,z)if not U then R(`Error during BundleModel() process: {V}`)end if B and S then local X=Q..N E(X,V)D(o.
Info,'Starting minification process with Darklua')local Y,Z,_={},Q..'.darklua.json',false if DarkluaConfigPath then
table.insert(Y,`-c={v(DarkluaConfigPath)}`)elseif not f.isFile'.darklua.json'and not f.isFile'.darklua.json5'then D(o.
Info,`No default Darklua config file found in CWD; creating our default config at "{Z}"`)E(Z,n)_=true table.insert(Y,`-c={
v(Z)}`)end r('darklua',{'process',v(X),v(M),unpack(Y)})F(X)if _ then F(Z)end else E(M,V)end if f.isDir(Q)then H(Q)end if
W>0 then print()o.Warn(`WARNING: {W} scripts failed to compile ahead-of-time (CHECK FULL BUILD LOG ABOVE FOR MORE DETAILS); these will throw errors at runtime upon being loaded, detailing said compilation errors.`
)j.exit(1)end else o.Error(`Subcommand "{x}" invalid, see usage for all valid subcommands:\n`)print(t)j.exit(1)end end)(
)end,[17]=function()local b,c,d=a(17)local e return(function(...)local f={}function f.FileType(g:string):string?local h=
string.match(g,'.%.([^%.]+)$')if h then h=string.lower(h)end return h end function f.FileNameFromPath(g:string):string?
return string.match(g,'[^/\\]+$')end function f.FileNameWithoutExtension(g:string,h:boolean?):string?h=if h==nil then
true else h if h then return string.match(g,'^(.+)%.')else return string.match(g,'^%.?[^%.]+')end end function f.
FilePathWithoutExtension(g:string,h:boolean?):string?local i,j=f.DirectoryOfFilePath(g),f.FileNameFromPath(g)if not i or
not j then return end local k=f.FileNameWithoutExtension(j,h)if not k then return end return i..k end function f.
DirectoryOfFilePath(g:string):string?local h=string.match(g,'^.*[/\\]')if not h or h==''then h='./'end return h end
function f.SplitStringByPattern(g:string,h:string)local i={}for j in string.gmatch(g,h)do table.insert(i,j)end return i
end function f.SplitFilePath(g:string)return f.SplitStringByPattern(g,'([^/\\]+)[/\\]?')end function f.LineCount(g:
string):number local h=1 for i in string.gmatch(g,'\n')do h+=1 end return h end function f.Replace(g:string,h:{[string]:
string}):string return string.gsub(g,'${([A-Za-z_][A-Za-z0-9_]*)}',h)end do local g={['"']='\\"',['\\']='\\\\',['\a']=
'\\a',['\b']='\\b',['\t']='\\t',['\n']='\\n',['\v']='\\v',['\f']='\\f',['\r']='\\r'}for h=0,255 do local i=string.char(h
)if not g[i]and(h<32 or h>126)then g[i]='\\'..h end end function f.SerializeStringData(h:string):string local i=string.
gsub(h,'[%z\\"\1-\31\127-\255]',g)return i end end return f end)()end,[9]=function()local b,c,d=a(9)local e return(
function(...)local f,g,h,i,j,k,l,m,n=table,string,next,pcall,game,workspace,tostring,tonumber,getmetatable local o,p,q,r
,s,t,u,v,w=g.format,g.char,g.gsub,g.match,g.rep,g.sub,g.gmatch,f.concat,typeof or type local function x(y)local z={}for
A,B in h,y do z[B]=true end return z end local y,z,A=x{'and','break','do','else','elseif','end','false','for','function'
,'if','in','local','nil','not','or','repeat','return','then','true','until','while','continue'},x{'number','string',
'boolean','Enum','EnumItem','Enums'},'^[A-Za-z_][A-Za-z0-9_]*$'local function B(C,D,...)local E={...}local F,G=x(E),w(C)
if not F[G]then error(o('LuaEncode: Incorrect type for `%s`: `%s` expected, got `%s`',D,v(E,', '),G),0)end return C end
local C do local D={['"']='\\"',['\\']='\\\\',['\a']='\\a',['\b']='\\b',['\t']='\\t',['\n']='\\n',['\v']='\\v',['\f']=
'\\f',['\r']='\\r'}for E=0,255 do local F=p(E)if not D[F]and(E<32 or E>126)then D[F]=o('\\x%02X',E)end end function C(E)
return v{'"',q(E,'[%z\\"\1-\31\127-\255]',D),'"'}end end local function D(E)local F=-1 for G in u(E,'%](=*)%]')do if#G>F
then F=#G end end local G=s('=',F+1)return'--['..G..'['..E..']'..G..']'end local E do local function F(G)local H,I=i(j.
FindService,j,G.ClassName)if H and I then return true end return false end function E(G,H)local I=G if not I then return
end local J=''while I do local K,L,M=I.Name,I.ClassName,I.Parent if M==j and F(I)then J=':GetService('..C(L)..')'..J
elseif H then J=':FindFirstChild('..C(K)..')'..J elseif not y[K]and r(K,A)then J='.'..K..J else J='['..C(K)..']'..J end
if M==j then J='game'..J return J elseif M==k then J='workspace'..J return J end I=M end return end end local function F
(G,H)H=H or{}B(G,'inputTable','table')B(H,'options','table')B(H.Prettify,'options.Prettify','boolean','nil')B(H.
PrettyPrinting,'options.PrettyPrinting','boolean','nil')B(H.IndentCount,'options.IndentCount','number','nil')B(H.
InsertCycles,'options.InsertCycles','boolean','nil')B(H.OutputWarnings,'options.OutputWarnings','boolean','nil')B(H.
FunctionsReturnRaw,'options.FunctionsReturnRaw','boolean','nil')B(H.UseInstancePaths,'options.UseInstancePaths',
'boolean','nil')B(H.UseFindFirstChild,'options.UseFindFirstChild','boolean','nil')B(H.SerializeMathHuge,
'options.SerializeMathHuge','boolean','nil')B(H._StackLevel,'options._StackLevel','number','nil')B(H._VisitedTables,
'options._VisitedTables','table','nil')B(H._SharedTableLarpAsRegTable,'options._SharedTableLarpAsRegTable','boolean',
'nil')local I=(H.Prettify==nil and H.PrettyPrinting==nil and false)or(H.Prettify~=nil and H.Prettify)or(H.PrettyPrinting
and H.PrettyPrinting)local J,K,L,M,N,O,P,Q,R,S=H.IndentCount or(I and 4)or 0,(H.InsertCycles==nil and false)or H.
InsertCycles,(H.OutputWarnings==nil and true)or H.OutputWarnings,(H.FunctionsReturnRaw==nil and false)or H.
FunctionsReturnRaw,(H.UseInstancePaths==nil and true)or H.UseInstancePaths,(H.UseFindFirstChild==nil and true)or H.
UseFindFirstChild,(H.SerializeMathHuge==nil and true)or H.SerializeMathHuge,H._StackLevel or 1,H._VisitedTables or{},H.
_SharedTableLarpAsRegTable or false local T,U,V,W,X,Y,Z,_,aa,ab,ac,ad,ae=(P and'math.huge')or'1/0',(P and'-math.huge')or
'-1/0',(I and'\n')or'',(I and'\n')or' ',(I and', ')or',',(I and' ')or'',(I and' = ')or'=',Q,s(' ',J),1,{}do
local function af(ag,ah,...)local ai=ac[ag](ah,false,...)return ai end local function ag(...)local ah={}for ai,aj in h,{
...}do ah[#ah+1]=af(w(aj),aj)end return v(ah,X)end local function ah(ai,aj)return
[[(function(p, t) for n, v in next, t do p[n] = v end return p end)(]]..v({ai,af('table',aj)},X)..')'end ac.number=
function(ai,aj)if aj and ai==ab then ab=ab+1 return nil,true end if ai==1/0 then return T elseif ai==-1/0 then return U
end return o('%.14g',ai)end ac.string=function(ai,aj)if aj and not y[ai]and r(ai,A)then return ai,true end return C(ai)
end ac.table=function(ai,aj,ak)if R[ai]and L then return'{--[[LuaEncode: Duplicate reference]]}'end local al=
setmetatable({},{__index=H})do al.Prettify=(aj and false)or I al.IndentCount=(aj and((not I and J)or 1))or J al.
_StackLevel=(aj and 1)or _+1 al._VisitedTables=R al._SharedTableLarpAsRegTable=(not aj and ak)end return F(ai,al)end ac.
boolean=function(ai)return ai and'true'or'false'end ac['nil']=function(ai)return'nil'end ac['function']=function(ai)if M
then return ai()end return o('function()%send',(L and
[=[ --[[LuaEncode: `options.FunctionsReturnRaw` false; can't serialize functions]] ]=])or'')end ac.Axes=function(ai)
local aj,ak={},{['Enum.Axis.X']=ai.X,['Enum.Axis.Y']=ai.Y,['Enum.Axis.Z']=ai.Z}for al,am in h,ak do if am then aj[#aj+1]
=al end end return'Axes.new('..v(aj,X)..')'end ac.BrickColor=function(ai)return'BrickColor.new('..((I and af('string',ai
.Name))or ai.Number)..')'end ac.CFrame=function(ai)return'CFrame.new('..ag(ai:components())..')'end ac.
CatalogSearchParams=function(ai)return ah('CatalogSearchParams.new()',{SearchKeyword=ai.SearchKeyword,MinPrice=ai.
MinPrice,MaxPrice=ai.MaxPrice,SortType=ai.SortType,CategoryFilter=ai.CategoryFilter,BundleTypes=ai.BundleTypes,
AssetTypes=ai.AssetTypes})end ac.Color3=function(ai)return'Color3.new('..ag(ai.R,ai.G,ai.B)..')'end ac.ColorSequence=
function(ai)return'ColorSequence.new('..af('table',ai.Keypoints)..')'end ac.ColorSequenceKeypoint=function(ai)return
'ColorSequenceKeypoint.new('..ag(ai.Time,ai.Value)..')'end ac.DateTime=function(ai)return'DateTime.fromUnixTimestamp('..
ai.UnixTimestamp..')'end ac.DockWidgetPluginGuiInfo=function(ai)local aj=l(ai)return'DockWidgetPluginGuiInfo.new('..ag(
Enum.InitialDockState[r(aj,'InitialDockState:(%w+)')],r(aj,'InitialEnabled:(%w+)')=='1',r(aj,
'InitialEnabledShouldOverrideRestore:(%w+)')=='1',m(r(aj,'FloatingXSize:(%w+)')),m(r(aj,'FloatingYSize:(%w+)')),m(r(aj,
'MinWidth:(%w+)')),m(r(aj,'MinHeight:(%w+)')))..')'end ac.Enum=function(ai)local aj=l(ai)if r(aj,A)then return'Enum.'..
aj end return'Enum['..C(aj)..']'end ac.EnumItem=function(ai)local aj,ak=af('Enum',ai.EnumType),ai.Name if r(ak,A)then
return aj..'.'..ai.Name end return aj..'['..C(ak)..']'end ac.Enums=function(ai)return'Enum'end ac.Faces=function(ai)
local aj,ak={},{['Enum.NormalId.Top']=ai.Top,['Enum.NormalId.Bottom']=ai.Bottom,['Enum.NormalId.Left']=ai.Left,[
'Enum.NormalId.Right']=ai.Right,['Enum.NormalId.Back']=ai.Back,['Enum.NormalId.Front']=ai.Front}for al,am in h,ak do if
am then aj[#aj+1]=al end end return'Faces.new('..v(aj,X)..')'end ac.FloatCurveKey=function(ai)return'FloatCurveKey.new('
..ag(ai.Time,ai.Value,ai.Interpolation)..')'end ac.Font=function(ai)return'Font.new('..ag(ai.Family,ai.Weight,ai.Style)
..')'end ac.Instance=function(ai)if N then local aj=E(ai,O)if aj then return aj end end return'nil'..Y..D(
'Instance.new('..af('string',ai.ClassName)..')'..Y..'{'..'Name:'..Y..C(ai.Name)..'}')end ac.NumberRange=function(ai)
return'NumberRange.new('..ag(ai.Min,ai.Max)..')'end ac.NumberSequence=function(ai)return'NumberSequence.new('..af(
'table',ai.Keypoints)..')'end ac.NumberSequenceKeypoint=function(ai)return'NumberSequenceKeypoint.new('..ag(ai.Time,ai.
Value,ai.Envelope)..')'end ac.OverlapParams=function(ai)return ah('OverlapParams.new()',{FilterDescendantsInstances=ai.
FilterDescendantsInstances,FilterType=ai.FilterType,MaxParts=ai.MaxParts,CollisionGroup=ai.CollisionGroup,
RespectCanCollide=ai.RespectCanCollide})end ac.Path2DControlPoint=function(ai)return'Path2DControlPoint.new('..ag(ai.
Position,ai.LeftTangent,ai.RightTangent)..')'end ac.PathWaypoint=function(ai)return'PathWaypoint.new('..ag(ai.Position,
ai.Action,ai.Label)..')'end ac.PhysicalProperties=function(ai)return'PhysicalProperties.new('..ag(ai.Density,ai.Friction
,ai.Elasticity,ai.FrictionWeight,ai.ElasticityWeight)..')'end ac.Random=function()return'Random.new()'end ac.Ray=
function(ai)return'Ray.new('..ag(ai.Origin,ai.Direction)..')'end ac.RaycastParams=function(ai)return ah(
'RaycastParams.new()',{FilterDescendantsInstances=ai.FilterDescendantsInstances,FilterType=ai.FilterType,IgnoreWater=ai.
IgnoreWater,CollisionGroup=ai.CollisionGroup,RespectCanCollide=ai.RespectCanCollide})end ac.Rect=function(ai)return
'Rect.new('..ag(ai.Min,ai.Max)..')'end ac.Region3=function(ai)local aj,ak=ai.CFrame.Position,0.5*ai.Size return
'Region3.new('..ag(aj-ak,aj+ak)..')'end ac.Region3int16=function(ai)return'Region3int16.new('..ag(ai.Min,ai.Max)..')'end
ac.TweenInfo=function(ai)return'TweenInfo.new('..ag(ai.Time,ai.EasingStyle,ai.EasingDirection,ai.RepeatCount,ai.Reverses
,ai.DelayTime)..')'end ac.RotationCurveKey=function(ai)return'RotationCurveKey.new('..ag(ai.Time,ai.Value,ai.
Interpolation)..')'end ac.UDim=function(ai)return'UDim.new('..ag(ai.Scale,ai.Offset)..')'end ac.UDim2=function(ai)return
'UDim2.new('..ag(ai.X.Scale,ai.X.Offset,ai.Y.Scale,ai.Y.Offset)..')'end ac.Vector2=function(ai)return'Vector2.new('..ag(
ai.X,ai.Y)..')'end ac.Vector2int16=function(ai)return'Vector2int16.new('..ag(ai.X,ai.Y)..')'end ac.Vector3=function(ai)
return'Vector3.new('..ag(ai.X,ai.Y,ai.Z)..')'end ac.Vector3int16=function(ai)return'Vector3int16.new('..ag(ai.X,ai.Y,ai.
Z)..')'end ac.buffer=function(ai)return'buffer.fromstring('..C(buffer.tostring(ai))..')'end ac.SharedTable=function(ai,
aj)local ak={}for al,am in SharedTable.clone(ai,not S)do ak[al]=am end local al=ac.table(ak,aj,true)if S then return al
end return v{'SharedTable.new(',al,')'}end ac.userdata=function(ai)if n(ai)~=nil then return'newproxy(true)'else return
'newproxy()'end end end local af,ag,ah,ai,aj={},G,true,{}local ak,al={[ag]=''},{}while ag do _=Q+#ai ad=(I and s(aa,_))
or aa ae=(#ad>0 and t(ad,1,-J-1))or''if ah then af[#af+1]='{'elseif h(ag,aj)==nil then af[#af+1]=V..ae else af[#af+1]=
','end R[ag]=true local am=false for an,ao in h,ag,aj do local ap,aq=w(an),w(ao)local ar,as,at=aq=='table',ac[ap],ac[aq]
af[#af+1]=V..ad if as and at then local au,av,aw,ax=false,i(as,an,true)local ay,az if not ar then ay,az=i(at,ao,false)
end if av and(ar or(ay and az))then if aw then if ax then af[#af+1]=aw else af[#af+1]=v{'[',aw,']'}end af[#af+1]=Z end
if ar then local aA if K and z[ap]and ak[ag]then if ap=='string'and not y[an]and r(an,A)then aA='.'..an else local aB=ac
[ap](an)aA=v{'[',aB,']'}end end if not R[ao]then if aA then ak[ao]=ak[ag]..aA end ai[#ai+1]={ag,an,ab}ag=ao aj=nil ab=1
ah=true am=true break else az=o('{%s}',(L and'--[[LuaEncode: Duplicate reference]]')or'')if aA then al[aA]=ak[ao]end end
end af[#af+1]=az au=true elseif L then local aA=o('LuaEncode: Failed to serialize %s of data type %s: %s',(not av and
'key')or(not ay and'value')or'key/value',aq,(not av and C(aw))or(not ay and C(az))or'(Failed to get error message)')af[#
af+1]=D(aA)end if h(ag,an)==nil then af[#af+1]=V..ae elseif au then af[#af+1]=','end else local au,av=(ap=='userdata'and
'userdata')or l(an),(aq=='userdata'and'userdata')or l(ao)af[#af+1]=D(Y..ap..'('..C(au)..')'..':'..Y..aq..'('..C(av)..')'
..Y)if h(ag,an)==nil then af[#af+1]=V..ae end end end if not am then if not I and J>0 then af[#af+1]=ad end af[#af+1]=
'}'if#ai>0 then local an=ai[#ai]ai[#ai]=nil ag,aj,ab=an[1],an[2],an[3]ah=false else break end end end if K then local am
={}for an,ao in h,al do am[#am+1]=ad..'t'..an..Z..'t'..ao..W end if#am>0 then return v{'(function(t)',V,v(am),V,ad,
'return t',W,'end)(',v(af),')'}end end return v(af)end return F end)()end,[15]=function()local aa,ab,ac=a(15)local ad
return(function(...)local ae=ac'@lune/fs'local function af(ag:string,ah:{string}?):{string}if not string.match(ag,
'[/\\]$')then ag..='/'end local ai=ah or{}for aj,ak in ae.readDir(ag)do if ae.isFile(ak)then table.insert(ai,ag..ak)else
af(ag..ak..'/',ai)end end return ai end return af end)()end,[11]=function()local aa,ab,ac=a(11)local ad return(function(
...)local ae,af=ac'@lune/process',{}function af.CommandExists(ag:string):boolean if ae.os~='windows'then return ae.exec(
'type',{ag},{shell=true}).ok end return true end function af.CheckCommands(ag:{string})for ah,ai in ag do assert(af.
CommandExists(ai),`Required command "{ai}" no found in your PATH environment variable, is it not installed?`)end end
return af end)()end,[18]=function()local aa,ab,ac=a(18)local ad return(function(...)export type WebhookObject={[string]:
any}local ae,af,ag,ah,ai=ac'@lune/net',ac'@lune/task',ac'@lune/serde',false,{}local function aj(ak:number?)ak=ak or 3 if
ah then return end ah=true af.spawn(function()while ah do repeat af.wait()until#ai>=1 local al=ai[1]local am,an:
WebhookObject=al[1],al[2]local ao=ag.encode('json',an)local ap=ae.request{url=am,method='POST',headers={['Content-Type']
='application/json'},body=ao}if not ap.ok then print(`[!] Error in webhook request ({ap.statusCode}): {ap.body}\n[^^ Waiting 5 seconds..]`
)af.wait(5)continue end print(`[*] Discord Response ({ap.statusCode}): {ap.body}`)af.wait(ak)table.remove(ai,1)end end)
end local function ak()ah=false end local function al(am:string,an:WebhookObject)table.insert(ai,{[1]=am,[2]=an})end
local function am()ai={}end local function an()repeat af.wait()until#ai==0 end return{Start=aj,Stop=ak,Add=al,Clear=am,
Await=an}end)()end,[3]=function()local aa,ab,ac=a(3)local ad return(function(...)local ae,af,ag=ac'@lune/luau',ac
'@lune/roblox',ac'./libraries/LuneUtils'local ah,ai,aj,ak,al,am,an=ag.Log,ag.StringUtils,ac'./libraries/LuaEncode',ac
'./data/Version',ac'./data/Template',8,{Folder=1,ModuleScript=2,Script=3,LocalScript=4,StringValue=5}local function ao(
ap:string|{af.Instance},aq:string?,ar:boolean?,as:number?,at:boolean?):(string,number)local au,av,aw,ax=aq or
'WaxRuntime',if ar==nil then true else ar,as or 0,if at==nil then true else at local function ay(az,...)if ax then az(
...)end end local az,aA,aB,b,c,d,e,f,g=av==false,if type(ap)=='string'then af.deserializeModel(ap)else ap,os.clock(),0,{
},{},{},{},{}local function h(i)table.insert(g,i)local j={}for k,l in i:GetChildren()do j[l]=h(l)end return j end local
i=aA for j,k in i do f[k]=h(k)end local function j(k,l,m:string?)m=m or k.Name local n,o=table.find(g,k),k.ClassName
local p=an[o]if not p then ah.Warn(`Skipping instance of ClassName "{o}", as it isn't supported in bundling`)return end
local q=o=='LocalScript'or o=='Script'local r,s=q or o=='ModuleScript',{[1]=n,[2]=p}if r and not(q and k.Disabled)then
local t=k.Source ay(ah.Info,`Compile-checking {k.ClassName} "{m}"..`)local u,v=pcall(ae.compile,t)if u then e[n]=ai.
LineCount(t)+1 d[n]=function()return'function()local wax,script,require=ImportGlobals('..n..
')local ImportGlobals return (function(...)'..t..'\nend)() end'end else local w=string.match(tostring(v),
'%w* ?:%d*: ?([^\n]*)\n')ah.Warn(`WARNING: {k.ClassName} "{m}" failed to compile: {w or
'[Failed to parse compiler error]'}`)b+=1 e[n]=1 d[n]=function()return`function()error("[AOT COMPILER ERROR] {ai.
SerializeStringData(w)}")end`end end end local t={[1]=k.Name}if o=='StringValue'then t.Value=k.Value end if k.Name~=o
then s[3]=t end if next(l)then local u={}for v,w in l do local x=j(v,w,`{m}.{v.Name}`)if x then table.insert(u,x)end end
s[4]=u end return s end for k,l in f do local m=j(k,l)if m then table.insert(c,m)end end local k={}if az then local l=aw
+am for m,n in e do k[m]=l l+=n end end local l=os.clock()ay(ah.Info,`Finished bundling model data in {string.format(
'%.4f',l-aB)} (seconds)`)local m=if av==false then true else false local n,o,p=aj(c,{Prettify=m,StackLimit=math.huge}),
aj(d,{Prettify=m,FunctionsReturnRaw=true}),if not az then'nil'else aj(k,{Prettify=m})local q=ai.Replace(al,{Version=ai.
SerializeStringData(ak),EnvName=ai.SerializeStringData(au),ObjectTree=n,ClosureBindings=o,LineOffsets=p})if#i==1 and i[1
].ClassName=='ModuleScript'then q..=
[[

-- AoT adjustment: Load init module (MainModule behavior)
return LoadScript(RealObjectRoot:GetChildren()[1])]]else
for r,s in next,i do if s.ClassName=='ModuleScript'and s.Name=='MainModule'then q..=
[[

-- AoT adjustment: Load init module (MainModule behavior)
return LoadScript(RealObjectRoot.MainModule)]]break end
end end return q,b end return ao end)()end,[7]=function()local aa,ab,ac=a(7)local ad return(function(...)return'0.4.2'
end)()end,[5]=function()local aa,ab,ac=a(5)local ad return(function(...)local ae,af=ac'@lune/serde',{generator={name=
'dense',column_span=120},rules={'convert_index_to_field','compute_expression','group_local_assignment',
'filter_after_early_return','remove_comments','remove_empty_do','remove_function_call_parens','remove_nil_declaration',
'remove_method_definition','remove_spaces','remove_unused_if_branch','remove_unused_while',{rule='rename_variables',
include_functions=true}}}return ae.encode('json',af,false)end)()end,[13]=function()local aa,ab,ac=a(13)local ad return(
function(...)local ae=ac'@lune/stdio'local af,ag={Reset=ae.color'reset'..ae.style'reset',Red=ae.color'red',Yellow=ae.
color'yellow',Bold=ae.style'bold'},{}function ag.Info(ah:string,ai:string?)ai=ai or'\n'ae.write(`\226\136\153 {ah}{ai}`)
end function ag.Error(ah:string,ai:string?)ai=ai or'\n'ae.ewrite(`{af.Bold..af.Red}\226\136\153 {ah}{af.Reset}{ai}`)end
function ag.Warn(ah:string,ai:string?)ai=ai or'\n'ae.write(`{af.Bold..af.Yellow}\226\136\153 {ah}{af.Reset}{ai}`)end
function ag.InternalError(ah:string,ai:string?)ag.Error('[INTERNAL ERROR] '..ah,ai)end return ag end)()end,[6]=function(
)local aa,ab,ac=a(6)local ad return(function(...)return
[[-- ++++++++ WAX BUNDLED DATA BELOW ++++++++ --

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
end)()end,[12]=function()local aa,ab,ac=a(12)local ad return(function(...)local ae=ac'@lune/fs'local function af(ag:{[
string]:any},ah:string?)for ai,aj in ag do local ak,al=if ah then`{ah}/{ai}`else ai,type(aj)if al=='table'then if not ae
.isDir(ak)then ae.writeDir(ak)end af(aj,ak)elseif al=='string'and not ae.isFile(ak)then ae.writeFile(ak,aj)end end end
return af end)()end,[10]=function()local aa,ab,ac=a(10)local ad return(function(...)return{Log=ac'./LuneUtils/Log',
StringUtils=ac'./LuneUtils/StringUtils',CommandUtils=ac'./LuneUtils/CommandUtils',WebhookQueue=ac
'./LuneUtils/WebhookQueue',Run=ac'./LuneUtils/Run',ParseArgs=ac'./LuneUtils/ParseArgs',EnsureFileTree=ac
'./LuneUtils/EnsureFileTree',RecursiveReadDir=ac'./LuneUtils/RecursiveReadDir'}end)()end,[14]=function()local aa,ab,ac=
a(14)local ad return(function(...)type OptionsInput={[string]:{string|number|boolean|nil}}type OptionsOutput={[string]:
string|number|boolean|nil}local ae,af=ac'@lune/process',ac'./Log'local function ag(ah:{string},ai:OptionsInput,aj:string
?):OptionsOutput local function ak()if aj then print(`\n{aj}`)end ae.exit(1)end local al={}for am,an in ah do local ao,
ap=string.match(an,'([%w%-_]+)=(.+)')if not ao then af.Error(`Command argument given, "{an}" not in the proper \`option=value\` format, aborting..`
)ak()end local aq=ai[ao]if aq==nil then af.Error(`"{ao}" isn't a valid option"`)ak()end local ar=aq[1]if ar=='boolean'
then ap=string.lower(ap)ap=if ap=='true'then true elseif ap=='false'then false else nil if ap==nil then af.Error(`"{ap}" isn't a valid boolean type; expected "true" or "false"`
)ak()end elseif ar=='number'then ap=tonumber(ap)if not ap then af.Error(`Failed to convert given input "{ap}" to a number value`
)ak()end end al[ao]=ap end for am,an in ai do local ao,ap=an[2],an[3]or false if not al[am]then if ap then af.Error(`Option "{
am}" required but not provided`)ak()end al[am]=ao end end return al end return ag end)()end,[16]=function()local aa,ab,
ac=a(16)local ad return(function(...)local ae,af=ac'@lune/process',ac'./Log'local function ag(ah:string,ai:{string}?,aj:
boolean?,ak:((string?)->())?):ae.ExecResult local al,am=ai or{},if aj==nil then false else aj if not am then if#al==0
then af.Info(`> {ah}`)else af.Info(`> {ah} {table.concat(al,' ')}`)end end local an=ae.exec(ah,ai,{shell=if ae.os~=
'windows'then true else nil,stdio=if am then'default'else'inherit'})if not an.ok and ak then ak(`Command above failed with status code {
an.code}`)end return an end return ag end)()end},{{1,2,{'Wax'},{{2,1,{'lib'},{{8,1,{'libraries'},{{9,2,{'LuaEncode'}},{
10,2,{'LuneUtils'},{{16,2,{'Run'}},{14,2,{'ParseArgs'}},{18,2,{'WebhookQueue'}},{17,2,{'StringUtils'}},{15,2,{
'RecursiveReadDir'}},{13,2,{'Log'}},{11,2,{'CommandUtils'}},{12,2,{'EnsureFileTree'}}}}}},{4,1,{'data'},{{6,2,{
'Template'}},{7,2,{'Version'}},{5,2,{'DefaultDarkluaConfig'}}}},{3,2,{'BundleModel'}}}}}}},'0.4.2','WaxRuntime',string,
task,setmetatable,error,next,table,unpack,coroutine,script,type,require,pcall,tostring,tonumber,_VERSION local au,av,aw,
ax,ay,az,aA=aj.insert,aj.remove,aj.freeze or function(au)return au end,al.wrap,ae.sub,ae.match,ae.gmatch if as and ay(as
,1,4)=='Lune'then local aB,b=ap(ao,'@lune/task')if aB and b then af=b end end local aB=af and af.defer local b,c,d,e,f,g
,h,i,j=aB or function(b,...)ax(b)(...)end,{[1]='Folder',[2]='ModuleScript',[3]='Script',[4]='LocalScript',[5]=
'StringValue'},{},{},{},{},{},{},{}local k,l={GetFullName={{},function(k)local l,m=k.Name,k.Parent while m do l=m.Name..
'.'..l m=m.Parent end return l end},GetChildren={{},function(k)local l={}for m in ai,j[k]do au(l,m)end return l end},
GetDescendants={{},function(k)local l={}for m in ai,j[k]do au(l,m)for n,o in ai,m:GetDescendants()do au(l,o)end end
return l end},FindFirstChild={{'string','boolean?'},function(k,l,m)local n=j[k]for o in ai,n do if o.Name==l then return
o end end if m then for o in ai,n do return o:FindFirstChild(l,true)end end end},FindFirstAncestor={{'string'},function(
k,l)local m=k.Parent while m do if m.Name==l then return m end m=m.Parent end end},WaitForChild={{'string','number?'},
function(k,l)return k:FindFirstChild(l)end}},{}for m,n in ai,k do local o,p,q=n[1],n[2],{}for r,s in ai,o do local t,u=
az(s,'^([^%?]+)(%??)')q[r]={t,u}end l[m]=function(r,...)if not j[r]then ah(
"Expected ':' not '.' calling member function "..m,2)end local s={...}for t,u in ai,q do local v=s[t]local w,x,y=an(v),u
[1],u[2]if v==nil and not y then ah('Argument '..v..' missing or nil',3)end if x~='any'and w~=x and not(w=='nil'and y)
then ah('Argument '..t..' expects type "'..x..'", got "'..w..'"',2)end end return p(r,...)end end local function m(n,o,p
)local q,r=(ag({},{__mode='k'}))local function s(t)ah(t..' is not a valid (virtual) member of '..n..' "'..o..'"',3)end
local function t(u)ah('Unable to assign (virtual) property '..u..'. Property is read only',3)end local u,v={},{}v.
__metatable=false v.__index=function(w,x)if x=='ClassName'then return n elseif x=='Name'then return o elseif x=='Parent'
then return p elseif n=='StringValue'and x=='Value'then return r else local y=l[x]if y then return y end end for y in ai
,q do if y.Name==x then return y end end s(x)end v.__newindex=function(w,x,y)if x=='ClassName'then t(x)elseif x=='Name'
then o=y elseif x=='Parent'then if y==u then return end if p~=nil then j[p][u]=nil end p=y if y~=nil then j[y][u]=true
end elseif n=='StringValue'and x=='Value'then r=y else s(x)end end v.__tostring=function()return o end ag(u,v)j[u]=q if
p~=nil then j[p][u]=true end return u end local function n(o,p)local q,r,s,t=o[1],o[2],o[3],o[4]local u=c[r]local v=s
and av(s,1)or u local w=m(u,v,p)d[q]=w if s then for x,y in ai,s do w[x]=y end end if t then for x,y in ai,t do n(y,w)
end end return w end local o=m('Folder','['..ad..']')for p,q in ai,ab do n(q,o)end for p,q in ai,aa do local r=d[p]e[r]=
q f[r]=p local s=r.ClassName if s=='LocalScript'or s=='Script'then au(h,r)end end local function p(q)local r,s=q.
ClassName,g[q]if s and r=='ModuleScript'then return ak(s)end local t=e[q]local function u(v)v=aq(v)local w,x,y=q:
GetFullName(),az(v,'[^:]+:(%d+): (.+)')if not x or not at then return w..':*: '..(y or v)end x=ar(x)local z=f[q]local A=
at[z]local B=x-A+1 if B<0 then B='?'end return w..':'..B..': '..y end if r=='LocalScript'or r=='Script'then local v,w=
ap(t)if not v then ah(u(w),0)end else local v={ap(t)}local w=av(v,1)if not w then local x=av(v,1)ah(u(x),0)end g[q]=v
return ak(v)end end function a(q)local r=d[q]local function s(t,...)local u={ap(t,...)}local v=av(u,1)if not v then ah(u
[1],3)end return ak(u)end local t=aw(ag({},{__index=i,__newindex=function(t,u,v)i[u]=v end,__len=function()return#i end,
__iter=function()return ai,i end}))local u,v=aw{version=ac,envname=ad,shared=t,script=am,require=ao},r local function w(
x,...)local y,z,A=an(x),'Attempted to call require with a non-ModuleScript','Attempted to call require with self'if y==
'table'and j[x]then if x.ClassName~='ModuleScript'then ah(z,2)elseif x==r then ah(A,2)end return p(x)elseif y=='string'
and ay(x,1,1)~='@'then if#x==0 then ah('Attempted to call require with empty string',2)end local B=r if ay(x,1,1)=='/'
then B=o elseif ay(x,1,2)=='./'then x=ay(x,3)end local C for D in aA(x,'([^/]*)/?')do local E=D if D=='.'then E=''elseif
D=='..'then B=B.Parent E=''end if E~=''then local F=B:FindFirstChild(E)if not F then local G=B.Parent if G then F=G:
FindFirstChild(E)end end if F then B=F elseif D~=C and D~='init'and D~='init.server'and D~='init.client'then ah(
'Virtual script path "'..x..'" not found',2)end end C=D end if B.ClassName~='ModuleScript'then ah(z,2)elseif B==r then
ah(A,2)end return p(B)end return s(ao,x,...)end return u,v,w end for q,r in ai,h do b(p,r)end return p(o:GetChildren()[1
])