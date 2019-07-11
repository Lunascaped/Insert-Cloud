--[[
	Insert Cloud Module
	Created and Maintained by Robuyasu

	Github Project: https://github.com/Robuyasu/Insert-Cloud
--]]

--Namespace--
HTTP = game:GetService("HttpService")
Replicated = game:GetService("ReplicatedStorage")
InsertService = game:GetService("InsertService")
Sandbox = require(script:FindFirstChild("CloudBox") or Replicated:FindFirstChild("CloudBox"))
LocalLoad = require(script:FindFirstChild("Loadstring") or Replicated:FindFirstChild("Loadstring"))
Templates = script:FindFirstChild("Templates") or Replicated:FindFirstChild("Templates")
-------------

--Init--
pcall(function()
	script.CloudBox.Parent = Replicated
	script.Loadstring.Parent = Replicated
	script.Templates.Parent = Replicated
end)

ServerCache = Replicated:FindFirstChild("Cache") or Instance.new("Folder", Replicated)
ServerCache.Name = "Cache"

function ColorFunc(Val, Type)
	if Val.r <= 1 and Val.g <= 1 and Val.b <= 1 then
		local Color = Color3.new(Val.r, Val.g, Val.b)
		return Color
	else
		local Color = Color3.new(Val.r/255, Val.g/255, Val.b/255)
		return Color
	end
end;

ValueTypes = {
	['CFrame'] = function(Val, Type)
		local Pos = Val.position
		local Rot = Val.rotation
		local CF = CFrame.new(Pos.x, Pos.y, Pos.z, Rot[1], Rot[2], Rot[3], Rot[4], Rot[5], Rot[6], Rot[7], Rot[8], Rot[9])
		return CF
	end;
	['Vector2'] = function(Val, Type)
		local Vect = Vector2.new(Val.x, Val.y)
		return Vect
	end;
	['Vector3'] = function(Val, Type)
		local Vect = Vector3.new(Val.x, Val.y, Val.z)
		return Vect
	end;
	['BrickColor'] = function(Val, Type)
		local Color = BrickColor.new(Val)
		return Color
	end;

	['Color'] = ColorFunc; --screw rbxm format changes E
	['Color3'] = ColorFunc;
	['Color3uint8'] = ColorFunc;

	['UDim'] = function(Val, Type)
		local UD = UDim.new(Val.scale, Val.offset)
		return UD
	end;
	['UDim2'] = function(Val, Type)
		local UD = UDim2.new(Val.x.scale, Val.x.offset, Val.y.scale, Val.y.offset)
		return UD
	end;

	['ColorSequence'] = function(Val, Type)
		local Sequences = {}
		for _,v in ipairs(Val) do

			local Key = ColorSequenceKeypoint.new(v.time, ColorFunc(v.value, 'Cplor3'), v.envelope)
			table.insert(Sequences, Key)
		end
		local ColSeq = ColorSequence.new(Sequences)
		return ColSeq
	end;
	['NumberSequence'] = function(Val, Type)
		local Sequences = {}
		for _,v in ipairs(Val) do
			local Key = NumberSequenceKeypoint.new(v.time, v.value, v.envelope)
			table.insert(Sequences, Key)
		end
		local NumSeq = NumberSequence.new(Sequences)
		return NumSeq
	end;
	['NumberRange'] = function(Val, Type)
		local Range = NumberRange.new(Val.min, Val.max)
		return Range
	end;
	['Axes'] = function(Val, Type)
		local Ax = Axes.new(
			not Val.x or Enum.Axis.X,
			not Val.y or Enum.Axis.Y,
			not Val.z or Enum.Axis.Z
		)
		return Ax
	end;
	['PhysicalProperties'] = function(Val, Type)
		local number = Val
		local Physical = PhysicalProperties.new(
			number.density or 1,
			number.friction or 1,
			number.elasticity or 1,
			number.friction_weight or 1,
			number.elasticity_weight or 1
		)
		return Physical
	end;
	['Reference'] = function(Val, Type, Refs)
		return Refs[Val]
	end
}

local ClassTypes = {
	['Script'] = function(ClName, ParentObj, Inst, Properties)
		local Object = Templates:FindFirstChild(ClName):Clone()
		Object.Parent = ParentObj
		return Object
	end;
	['LocalScript'] = function(ClName, ParentObj, Inst, Properties)
		local Object = Templates:FindFirstChild(ClName):Clone()
		Object.Parent = ParentObj
		return Object
	end;
	['ModuleScript'] = function(ClName, ParentObj, Inst, Properties)
		local Object = Templates:FindFirstChild(ClName):Clone()
		Object.Parent = ParentObj
		return Object
	end;
	['MeshPart'] = function(ClName, ParentObj, Inst, Properties)
		local Object = Instance.new("Part")
		Object.Parent = ParentObj
		local OrigSize = CompileValue("Size", Inst.properties.size)
		local InitSize = CompileValue("InitializeSize", Inst.properties.InitialSize)
		local MeshID = CompileValue("MeshId", Inst.properties.MeshID)
		local TextID = CompileValue("TextureId", Inst.properties.TextureID)
		local Mesh = Instance.new("SpecialMesh")
		Mesh.Parent = Object
		Mesh.MeshType = Enum.MeshType.FileMesh
		Mesh.MeshId = MeshID or ""
		Mesh.TextureId = TextID or ""
		Mesh.Scale = OrigSize/InitSize
		return Object
	end;
	['Humanoid'] = function(ClName, ParentObj, Inst, Properties)
		local Object = Instance.new('Humanoid')
		Object.Parent = ParentObj
		Object.MaxHealth = Properties['MaxHealth'].value or 100
		Object.Health = pcall(function() return Properties['Health'].value end) or Object.MaxHealth
		return Object
	end;
}
local PropExceptions = {
	Attachment0=true;
	Attachment1=true;
	Part0=true;
	Part1=true;
	Value=true;
	Adornee=true;
	NextSelectionUp=true;
	NextSelectionDown=true;
	NextSelectionLeft=true;
	NextSelectionRight=true;
	SelectionImageObject=true;
	PrimaryPart=true;
	SoundGroup=true;
	CameraSubject=true;
}
--------

function CompileValue (Prop, Value, Refs)
	local Val = Value.value
	local Type = Value.type
	local Func = ValueTypes[Type] or ValueTypes[Prop]
	if Func then
		local New = Func(Val, Type, Refs)
		return New
	else
		if Value ~= nil then
			return Value.value
		else
			return nil
		end
	end
end

function LoadModel(Base, ParentObj, Model, Refs)
	Refs = Refs or {}
	local Objects = {}
	local function Recursive(Base, ParentObj, Model)
		for i,Inst in ipairs(Model) do
			local ClName = Inst.class_name
			pcall(function()
				if ClName ~= "Message" and ClName ~= "Hint" then
					local Object;
					local ClassF = ClassTypes[ClName]
					if ClassF then
						Object = ClassF(ClName, ParentObj, Inst, Inst.properties)
					else
						Object = Instance.new(ClName)
						Object.Parent = ParentObj
					end
					if Object:IsA("BasePart") then
						Object.Anchored = true
						Object.CanCollide = false
					end
					Refs[Inst.reference] = Object
					Objects[Object] = Inst
					Recursive(Base, Object, Inst.children)
				end
			end)
		end
	end
	Recursive(Base, ParentObj, Model)
	LoadProps(Objects, Refs)
end

function LoadProps(Objects, Refs)
	for Object, Inst in pairs(Objects) do
		for x,Property in pairs(Inst.properties) do
			local function iter()
				x = string.upper(string.sub(x, 0, 1))..string.sub(x,2)
				if x == "Color3uint8" then
					x = "Color"
				elseif x == "Source" then
					Object.LOAD.Value = Property.value
				elseif x == "Disabled" and Property.value == false then
					Object.IsDisabled.Value = false
				elseif x == "Locked" then
					Object.Locked = false
				elseif x == "Playing" then
					Object.Playing = false
				end
				if (Object[x] ~= nil or PropExceptions[x]) and x ~= "Disabled" and x ~= 'Locked' and x ~= "Playing" then
					local CompdVal = CompileValue(x, Property, Refs)
					Object[x] = CompdVal
				end
			end
			pcall(iter)
		end
	end
end

function InitModel (Model, Parent, Pos, Settings)
	Model.Parent = workspace
	Model:MakeJoints()
	if Pos then
		Model:MoveTo(Pos)
	end
	if Settings.AnchorParts then
		for i,v in ipairs(Model:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Anchored = true
			end
		end
	end
	if Settings.RemoveDecals then
		for i,v in ipairs(Model:GetDescendants()) do
			if v:IsA("Decal") or v:IsA("Texture") then
				v:Destroy()
			end
		end
	end
	if Settings.RemoveScripts then
		for i,v in ipairs(Model:GetDescendants()) do
			if v:IsA("BaseScript") or v:IsA("ModuleScript") then
				v:Destroy()
			end
		end
	end
	Model.Parent = Parent or workspace
end

local InsertCloud = {

	_VERSION='2.1.0';
	_DEVELOPERS={
		'Robuyasu'; --Main developer
		'Anaminus'; --Rbxfile gostruct api creator
		'einsteinK'; --Loadstring ppl
		'AMD_Chan';
		'Stravant';
		'Sceleratis';
		'mathcamp'; --TargetPoint fix model
	};
	LoadAsset = function (self, URL, Key, ID, Parent, Pos, Settings)
		ID = tostring(ID)

		local Model = Instance.new("Model")
		Model.Parent = Replicated
		Model.Name = ID

		local New;
		local Get;
		local FindCache = ServerCache:FindFirstChild(ID)
		if not FindCache then
			New = URL..Key.."/"..ID
			Get = HTTP:GetAsync(New)
		else
			if Settings.LoadCache == true then
				Model:Destroy()
				local Clone = FindCache:Clone()
				InitModel(Clone, Parent, Pos, Settings)

				return Clone
			else
				New = URL..Key.."/"..ID
				Get = HTTP:GetAsync(New)
			end
		end

		local Response;
		local Instances;

		local Status, Error = pcall(function() --Pcall incase of error
			Response = HTTP:JSONDecode(Get)
			Instances = Response.instances
			LoadModel(Model, Model, Instances)
			local XSum, XTot, ZSum, ZTot, YLow = 0, 0, 0, 0, math.huge
			local function GetCent(Par)
				for i,v in ipairs(Par:GetChildren())do
					if v:IsA("BasePart") then
						XTot = XTot + 1
						ZTot = ZTot + 1
						XSum = XSum + v.Position.X
						ZSum = ZSum + v.Position.Z
						if v.Position.Y - v.Size.Y/2 < YLow then
							YLow = v.Position.Y - v.Size.Y/2
						end
					end
					GetCent(v)
				end
			end
			GetCent(Model)
			local Center = Instance.new("Part")
			Center.Parent = Model
			Center.Anchored = true
			Center.Locked = true
			Center.CanCollide = false
			Center.Transparency = 1
			Center.Size = Vector3.new(0.05,0.05,0.05)
			Center.Name = "CenterOfModel"
			Center.CFrame = CFrame.new(XSum/XTot, YLow, ZSum/ZTot)
			Model.PrimaryPart = Center
			local NewCache = Model:Clone()
			NewCache.Parent = ServerCache
			InitModel(Model, Parent, Pos, Settings)
		end)

		if Status ~= true then
			Model:Destroy()
			return nil
		else
			return Model
		end
	end;
	LoadCode=function(self, Code, Type, Parent, Player)
		local Script = Templates:FindFirstChild(Type)
		Script = Script:Clone()
		if Script:FindFirstChild("Player") then
			Script.Player.Value = Player
		end
		Script.Parent = Parent or workspace
		Script.LOAD.Value = Code
		Script.Disabled = false
	end;
	Credits=function(self)
		print("_DEVELOPERS:")
		for i,v in ipairs(self._DEVELOPERS) do
			print(v)
		end
	end;
	RestartApp=function(self, URL, Key)
		URL = URL:sub(0,#URL-8)
		HTTP:GetAsync(URL.."/restart/"..Key)
	end;
}

print("Insert Cloud Module loaded. Developed and maintained by Robuyasu.")
print("_VERSION: "..InsertCloud._VERSION)

return setmetatable(InsertCloud, {
	__index=function(self, index)
		return rawget(self, index) or InsertService[index]
	end
})
