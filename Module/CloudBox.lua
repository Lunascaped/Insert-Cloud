-- Cloud box created and developed by Robuyasu
-- please excuse me for my spaghetti code

local SandbCache = setmetatable({}, {__mode="k"}) -- Caches
local WrapCache = setmetatable({}, {__mode="k"})

local Replicated = game:GetService("ReplicatedStorage") --Services
local Teleport = game:GetService('TeleportService')
local Http = game:GetService("HttpService")
local Starterplayer = game:GetService("StarterPlayer")
local Starterpack = game:GetService("StarterPack")
local Startergui = game:GetService("StarterGui")
local ScriptService = game:GetService("ServerScriptService")
local ServerStorage = game:GetService("ServerStorage")
local Lighting = game:GetService("Lighting")
local MarketPlace = game:GetService("MarketplaceService")
local BadgeService = game:GetService("BadgeService")
local DataService = game:GetService("DataStoreService")
local AssetService = game:GetService("AssetService")
local LocalLoad = require(script.Parent.Loadstring)

local RootParts = { -- The list of root parts, aka parts that cannot be read or edited
	[Starterplayer]=true;
	[Starterpack]=true;
	[Startergui]=true;
	[Replicated]=true;
	[Teleport]=true;
	[ScriptService]=true;
	[MarketPlace]=true;
	[BadgeService]=true;
	[Http]=true;
	[DataService]=true;
	[AssetService]=true;
}
local GameData = {
	[workspace]=true;
	[game]=true;
}
local AllowedFuncs = { -- Functions allowed to use
	['findfirstchild']=true;
	['isa']=true;
	['getchildren']=true;
	['children']=true;
	['getdescendants']=true;
}
local BlockedInstances = { -- Instances you are not allowed to spawn
	['message']=true;
	['hint']=true;
	['script']=true;
	['localscript']=true;
}
local BlockedClasses = { -- Classes you are not allowed to edit
	['Player']=true;
}
local WrappableTypes = { -- List of userdata types to wrap
	["instance"]=true;
	["rbxscriptsignal"]=true;
	["rbxlibrary"]=true;
}
local SandboxedMethods = { --Methods to sandbox
	['connect']=function(realobj, fakeobj, key)
		return function(self, ...)
			return realobj:Connect(unpack(wrap({...})))
		end
	end;
	['clearallchildren']=function(realobj, fakeobj, key)
		if IsARoot(realobj, true) or BlockedClasses[realobj['ClassName']] or IsBasePlate(realobj) or realobj:FindFirstAncestorOfClass("Backpack") then
			return error('CB Error: Object being deleted cannot be a root part!')
		end
		return function()
			for _, Object in ipairs(realobj:GetChildren()) do
				pcall(function()
					if not IsARoot(Object, true) and not BlockedClasses[Object['ClassName']] and not IsBasePlate(Object) and not realobj:FindFirstAncestorOfClass("Backpack") then
						Object:Destroy()
					end
				end)
			end
		end
	end;
	['destroy']=function(realobj, fakeobj, key)
		if IsARoot(realobj, true) or BlockedClasses[realobj['ClassName']] or IsBasePlate(realobj) or realobj:FindFirstAncestorOfClass("Backpack") then
			return error('CB Error: Object being deleted cannot be a root part!')
		end
		return function()
			return realobj:Destroy()
		end
	end;
	['remove']=function(realobj, fakeobj, key)
		if IsARoot(realobj, true) or BlockedClasses[realobj['ClassName']] or IsBasePlate(realobj) or realobj:FindFirstAncestorOfClass("Backpack") then
			return error('CB Error: Object being removed cannot be a root part!')
		end
		return function()
			return realobj:Remove()
		end
	end;
	['clone']=function(realobj, fakeobj, key)
		if IsARoot(realobj, true) or BlockedClasses[realobj['ClassName']] or IsBasePlate(realobj) then
			return error('CB Error: Object being cloned cannot be a root part!')
		end
		return function()
			return wrap(realobj:Clone())
		end
	end;
	['kick']=function(realobj, fakeobj, key)
		return function()
			return error('CB Error: Cannot kick a player!')
		end
	end;
	['getservice']=function(realobj, fakeobj, key)
		return function(self, ...)
			local get = realobj:GetService(rewrap(...))
			if IsARoot(get, true) then
				return error('CB Error: Service is a root instance!')
			end
			return wrap(get)
		end
	end;
	['awardbadge']=function(realobj, fakeobj, key)
		return function()
			return error('CB Error: AwardBadge is not allowed!')
		end
	end;
	['fireserver']=function(realobj, fakeobj, key)
		if IsARoot(realobj, true) then
			return error('CB Error: Realobj or Key is a root instance!')
		end

		return function(self, ...)
			return realobj:FireServer(unprap(...))
		end
	end;
	['fireclient']=function(realobj, fakeobj, key)
		if IsARoot(realobj, true) then
			return error('CB Error: Realobj or Key is a root instance!')
		end

		return function(self, ...)
			return realobj:FireClient(unprap(...))
		end
	end;
	['invokeserver']=function(realobj, fakeobj, key)
		if IsARoot(realobj, true) then
			return error('CB Error: Realobj or Key is a root instance!')
		end

		return function(self, ...)
			return realobj:InvokeServer(unprap(...))
		end
	end;
	['invokeclient']=function(realobj, fakeobj, key)
		if IsARoot(realobj, true) then
			return error('CB Error: Realobj or Key is a root instance!')
		end

		return function(self, ...)
			return realobj:InvokeClient(unprap(...))
		end
	end;
}

function IsBasePlate(realobj)
	return realobj:IsDescendantOf(workspace.Baseplate) or realobj == workspace.Baseplate
end

function unprap(...)
	return unpack(unwrap({...}))
end
function rewrap(...)
	return unpack(wrap({...}))
end

function copy(obj, seen) -- Copy table and the metadata
	if type(obj) ~= 'table' then return obj end
	if seen and seen[obj] then return seen[obj] end
	local s = seen or {}
	local res = setmetatable({}, getmetatable(obj))
	s[obj] = res
	for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
	return res
end

function IsARoot(obj, getDesc) -- Check if the object is a root
	if typeof(obj):lower() ~= 'instance' then
		return false
	end
	if not GameData[obj] then
		if RootParts[obj] then
			return true
		end
		if getDesc then
			for key, val in pairs(RootParts) do
				if obj:IsDescendantOf(key) and not GameData[obj] then
					return true
				end
			end
		end
	end
	return false
end

function sandboxObj(realObj) -- Creates a fake userdata value clone of the real object
	local fakeObj = newproxy(true);
   	local meta = getmetatable(fakeObj);
    meta['__index'] = function(self, key)
		local findmeth = SandboxedMethods[key:lower()]
		local indexfind = realObj[key]
		if IsARoot(realObj, true) or IsARoot(indexfind, true) or IsARoot(key, true) then
			return error('CB Error: Cannot access root instances!')
		end
		if type(indexfind) == 'userdata' then
			return wrap(indexfind)
		elseif findmeth then -- oh no the po po is coming!!!!
			return findmeth(realObj, fakeObj, key)
		elseif type(indexfind) == "function" then
			return function(self, ...)
				return unpack(wrap({indexfind(realObj, unpack(unwrap({...})))})) -- my eyes hurt
			end
		else
			return wrap(indexfind)
		end
    end;
	meta['__newindex'] = function(self, index, key)
		if IsARoot(realObj, true) or IsARoot(key, true) or (type(realObj) == 'userdata' and BlockedClasses[realObj.ClassName]) or (type(index) == 'userdata' and BlockedClasses[key.ClassName]) or realObj:IsDescendantOf(workspace.Baseplate) or realObj == workspace.Baseplate or realObj == game:GetService("Players") then
			return error('CB Error: Cannot modify properties of root instances or blocked classes!')
		end
		if index:lower() == "name" and type(key) == 'string' and key:lower() == "rofl" then
			return error('CB Error: Blocked ROFL virus!')
		end
		realObj[tostring(index)] = unwrap(key)
		if index:lower() == "locked" then
			realObj['Locked'] = false;
		end
	end
    meta['__tostring'] = function(self)
        return tostring(realObj);
    end;
	meta['__eq'] = function(self, comp)
		return wrap(unwrap(self) == unwrap(comp))
	end;
	meta['__lt'] = function(self, comp)
		return wrap(unwrap(self) < unwrap(comp))
	end
	meta['__le'] = function(self, comp)
		return wrap(unwrap(self) <= unwrap(comp))
	end
    meta['__metatable'] = "The metatable is a locked"; -- put the a in there for debugging purposes
	return fakeObj
end

function unFunc(obj)
	return function(...)
		return unpack(wrap({obj(unpack(unwrap({...})))})) -- wth is this
	end
end

function unwrap(obj) -- Unwrap object to get the unsandboxed object version
	if type(obj) == "table" then
		local real = {}
		for k,v in next,obj do
			real[k] = unwrap(v)
		end
		setmetatable(real, unwrap(getmetatable(obj)))
		return real
	else
		local real = WrapCache[obj]
		if real == nil then -- If not cached, it is already unsandboxed
			return obj
		end
		return real
	end
end

function wrap(obj) -- Sandboxes the object by wrapping it\
    if WrappableTypes[typeof(obj):lower()] then
       	local realObj = obj;
		if SandbCache[realObj] then
			return SandbCache[realObj]
		end

       	local fakeObj = sandboxObj(realObj)
		SandbCache[realObj] = fakeObj
		WrapCache[fakeObj] = realObj
        return fakeObj;
	elseif type(obj) == 'function' then
		return function(...)
			return unpack(wrap({obj(unpack(wrap({...})))})) -- wth is this
		end
	elseif type(obj) == 'table' then
		for i,v in pairs(obj) do
			if i ~= nil or v ~= nil then
				obj[wrap(i)] = wrap(v)
			end
		end

		if getmetatable(obj) then --for rbx libraries
			local oldcall = getmetatable(obj).__call
			getmetatable(obj).__call = function(self, ...)
				return unFunc(unpack({oldcall(obj, unpack(unwrap({...})))}))
			end
		end
		return obj
    else
        return obj;
    end;
end;

function generateSandbox(Code, _ENV, LoadLocal, Scr, Player) -- Creates a new sandbox for the script
	local sandBox = {
		--Wrapping userdatas
		workspace=wrap(workspace);
		Workspace=wrap(workspace);
		game=wrap(game);
		Game=wrap(game);

		--Lua Functions
		Spawn=spawn;
		getmetatable=function(tab)
			return getmetatable(tab)
		end;
		setmetatable=function(tab, meta)
			return setmetatable(tab, meta)
		end;
		Instance = {
	        new = function(a, b)
				if BlockedInstances[a:lower()] then
					return nil
				end
				if not IsARoot(b, true) then
					return wrap(Instance.new(a, unwrap(b)))
				else
					return error('CB Error: Cannot create new instance inside a root instance!')
				end
	        end;
		};
		LoadLibrary=wrap(LoadLibrary);

		--Void SB Support
		owner=wrap(Player);
		NLS=function(Code, Parent, Disabled)
			if game:GetService("RunService"):IsClient() then
				return error('CB Error: Cannot create a local script within a local script.')
			end
			local NewLocal = game:GetService("ReplicatedStorage").Templates.SandboxLocalScript:Clone()
			NewLocal.IsDisabled.Value = Disabled or false
			NewLocal.LOAD.Value = tostring(Code)
			NewLocal.Parent = unwrap(Parent) or Player.Character
			NewLocal.Disabled = Disabled or false
			return NewLocal
		end;
		NS=function(Code, Parent, Disabled)
			if not game:GetService("RunService"):IsClient() then
				return error('CB Error: Cannot create a script within a script.')
			end
			return script.NS:InvokeServer(Code, unwrap(Parent), Disabled)
		end;

		--Possibly dangerous keywords
		require=function(Module)
			if type(Module) == "number" or type(Module) == "string" then
				return error('CB Error: Cannot require online modules!')
			elseif type(Module) == "userdata" and not IsARoot(Module, true) then
				return require(unwrap(Module))
			else
				return error('CB Error: Requiring a non userdata!')
			end
		end;
		loadstring=function(LoadCode)
			return SandboxFunc(LoadCode, {}, LoadLocal, Scr)
		end;
		getfenv=function(...)
			return error('CB Error: Cannot use getfenv in script!')
		end;
		setfenv=function(...)
			return error('CB Error: Cannot use setfenv in script!')
		end;
	}
	return setmetatable(sandBox, { -- Returning values not included in the sandbox
		__index=function(self, index)
			if rawget(self, index) then
				return rawget(self, index)
			else
				local ind = getfenv()[index]
				return wrap(ind)
			end
		end
	})
end

SandboxFunc = function(Code, _ENV, LoadLocal, Scr, Player) -- Where the magic happens
	if _ENV == nil then
		warn('ENV variable is nil!')
		return nil
	end
	if Code == nil then
		warn('Code variable is nil!')
		return nil
	end

	local sandbox = generateSandbox(Code, _ENV, LoadLocal, Scr, Player)

	local custsandbox = copy(sandbox)
	local newScr = wrap(Scr)
	custsandbox['script'] = newScr
	custsandbox['Script'] = newScr

	if type(Code) == 'string' then
		if not LoadLocal then
			if pcall(function() return loadstring(Code) end) then
				Code = loadstring(Code)
			else
				Code = LocalLoad(Code, custsandbox)
			end
		else
			Code = LocalLoad(Code, custsandbox)
		end
	end

	if Code == nil then
		warn('Code could not be loaded!')
		return nil
	end

	setfenv(Code, setmetatable(custsandbox, {__index = _ENV}));

	return Code
end

return SandboxFunc
