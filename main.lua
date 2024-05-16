local UIS = game:GetService("UserInputService")
local ScreenGui = Instance.new("ScreenGui",game.CoreGui)
local TextBox = Instance.new("TextBox",ScreenGui)
local ScrollingFrame = Instance.new("ScrollingFrame",TextBox)
local UIListLayout = Instance.new("UIListLayout",ScrollingFrame)
local Example = Instance.new("TextLabel")

TextBox.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
TextBox.BorderColor3 = Color3.fromRGB(0, 0, 0)
TextBox.Position = UDim2.new(1, -200, 1, -20)
TextBox.Size = UDim2.new(0, 200, 0, 20)
TextBox.Font = Enum.Font.Ubuntu
TextBox.Text = ""
TextBox.TextColor3 = Color3.fromRGB(255, 255, 255)
TextBox.TextSize = 15
TextBox.TextStrokeColor3 = Color3.fromRGB(255, 255, 255)
TextBox.TextXAlignment = Enum.TextXAlignment.Left
TextBox.PlaceholderText = "Press ; to start typing.."

ScrollingFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ScrollingFrame.BackgroundTransparency = 0.1
ScrollingFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
ScrollingFrame.ClipsDescendants = true
ScrollingFrame.Visible = false
ScrollingFrame.ScrollBarThickness = 6
ScrollingFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y

Example.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Example.BackgroundTransparency = 0.6
Example.BorderColor3 = Color3.fromRGB(0, 0, 0)
Example.Size = UDim2.new(1, 0, 0, 18)
Example.Visible = false
Example.Font = Enum.Font.Ubuntu
Example.TextColor3 = Color3.fromRGB(255, 255, 255)
Example.TextSize = 15
Example.TextXAlignment = Enum.TextXAlignment.Left

local keys = {
	["W"] = false,
	["S"] = false,
	["A"] = false,
	["D"] = false
}

UIS.InputBegan:Connect(function(k,t)
	if t then return end
	if k.KeyCode == Enum.KeyCode.Semicolon then 
		task.wait()
		TextBox:CaptureFocus()
	end
	if keys[k.KeyCode.Name] ~= nil then
		keys[k.KeyCode.Name] = true
	end
end)

local cmds = {}

function addCommand(alias,txt,callback)
	local btn = Example:Clone()
	cmds[alias] = {["txt"] = txt,["callback"] = callback,["btn"] = btn}
	btn.Parent = ScrollingFrame
	btn.Visible = true
	btn.Text = txt
end

function AddReference(alias,newalias)
	cmds[newalias] = cmds[alias]
end

function findCommand(txt)
	local cmd = string.split(txt," ")[1]
	for i,v in pairs(cmds) do 
		v["btn"].Visible = false
	end
	for i,v in pairs(cmds) do 
		if string.sub(i,1,#cmd) == cmd then 
			v["btn"].Visible = true
		end
	end
end

function getPlayer(name)
	if #name == 0 then return end
	for i,v in pairs(game.Players:GetPlayers()) do
		if string.lower(string.sub(v.Name,1,#name)) == string.lower(name) or string.lower(string.sub(v.DisplayName,1,#name)) == string.lower(name) then
			print(v)
			return v
		end
	end
end

function selectCommand(txt)
	local data = string.split(txt," ")
	local valid = {}
	if #data[1] < 2 then return false end
	for i,v in pairs(cmds) do 
		if string.sub(i,1,#data[1]) == data[1] then
			valid[i] = v
			--return v["callback"](data)
		end
	end
	local selected,dist = nil,9e9
	for i,v in valid do 
		if math.abs(#i-#data[1]) < dist then 
			selected = i
			dist = math.abs(#i-#data[1])
		end 
	end
	
	return cmds[selected] and cmds[selected]["callback"](data)
end

TextBox.Focused:Connect(function()
	for i,v in pairs(cmds) do 
		v["btn"].Visible = true
	end
	ScrollingFrame.Visible = true
	for i = 0,1,0.1 do task.wait()
		ScrollingFrame.Size = UDim2.new(1,0,0,0):Lerp(UDim2.new(1,0,0,200),i)
		ScrollingFrame.Position = UDim2.new(0,0,0,0):Lerp(UDim2.new(0,0,0,-200),i)
	end
end)

TextBox.FocusLost:Connect(function()
	selectCommand(string.lower(TextBox.Text))
	TextBox.Text = ""
	for i = 0,1,0.1 do task.wait()
		ScrollingFrame.Size = UDim2.new(1,0,0,200):Lerp(UDim2.new(1,0,0,0),i)
		ScrollingFrame.Position = UDim2.new(0,0,0,-200):Lerp(UDim2.new(0,0,0,0),i)
	end 
	ScrollingFrame.Visible = false
end)

TextBox.Changed:Connect(function(prop)
	if prop ~= "Text" then return end
	findCommand(string.lower(TextBox.Text)) 
end)
local plr = game.Players.LocalPlayer

-- walkspeed --
addCommand("walkspeed","WalkSpeed [amount]", function(data)
	plr.Character.Humanoid.WalkSpeed = tonumber(data[2]) or 16
end)
AddReference("walkspeed", "ws")
AddReference("walkspeed", "speed")

-- unwalkspeed --
addCommand("unwalkspeed","remove WalkSpeed", function(data)
	plr.Character.Humanoid.WalkSpeed = 16
end)
AddReference("unwalkspeed", "unws")
AddReference("unwalkspeed", "unspeed")

-- jumppower --
addCommand("jumppower","JumpPower [amount]", function(data)
	plr.Character.Humanoid.JumpPower = tonumber(data[2]) or 50
end)
AddReference("jumppower", "jp")

-- unjumppower -- 
addCommand("unjumppower","UnJumpPower", function(data)
	plr.Character.Humanoid.JumpPower = 50
end)
AddReference("unjumppower", "unjp")

-- forcejump -- 
addCommand("forcejump","ForceJump", function(data)
	plr.Character.Humanoid.Jump = true
end)

-- sit --
addCommand("sit", "Sit down", function(data)
	plr.Character.Humanoid.Sit = true
end)

-- infjump --
local infjump = false
UIS.JumpRequest:connect(function()
	if not infjump then return end
	plr.Character:FindFirstChildWhichIsA('Humanoid'):ChangeState("Jumping") 
end)
addCommand("infinitejump", "Infinite Jump", function(data)
	infjump = not infjump
end)
AddReference("infinitejump","infjump")
AddReference("infinitejump","jetpack")

-- goto plr --
addCommand("goto","Goto [plr]", function(data)
	local target = getPlayer(data[2])
	if not target then return end
	plr.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame + Vector3.new(0,1,0)
end)
AddReference("goto", "tp")

-- view plr --
addCommand("spectate", "Spectate [plr]", function(data)
	local target = getPlayer(data[2])
	if not target or not target.Character then workspace.CurrentCamera.CameraSubject = plr.Character.Humanoid return end
	workspace.CurrentCamera.CameraSubject = target.Character.Humanoid
end)
AddReference("spectate", "view")

-- unview plr --
addCommand("unspectate", "Unspectate", function(data)
	workspace.CurrentCamera.CameraSubject = plr.Character.Humanoid
end)
AddReference("unspectate","unview")

-- anchor self --
addCommand("selfanchor", "SelfAnchor", function(data)
	plr.Character.HumanoidRootPart.Anchored = not plr.Character.HumanoidRootPart.Anchored
end)
AddReference("selfanchor", "anchorself")

-- reach --
addCommand("reach", "Reach [number]", function(data)
	local tool = plr.Character:FindFirstChildWhichIsA("Tool")
	if not tool then return end 
	local a = Instance.new("SelectionBox",tool.Handle)
	a.Adornee = tool.Handle
	tool.Handle.Size = tool.Handle.Size * (tonumber(data[2]) or 10)
	tool.Handle.Massless = true
	plr.Character.Humanoid:UnequipTools()
end)

-- btools --
addCommand("btools", "BuilderTools", function(data)
	Instance.new("HopperBin",plr.Backpack).BinType = "Clone"
	Instance.new("HopperBin",plr.Backpack).BinType = "Hammer"
	Instance.new("HopperBin",plr.Backpack).BinType = "Grab"
end)
AddReference("btools", "buildertools")

-- gravity --
addCommand("gravity", "Gravity [number]", function(data)
	workspace.Gravity = tonumber(data[2]) or 196.2
end)

-- tp tool --
addCommand("tptool", "Tp tool", function(data)
	local a = Instance.new("Tool",plr.Backpack)
	a.Name = "Click to tp"
	a.RequiresHandle = false
	a.Activated:Connect(function()
		plr.Character.HumanoidRootPart.CFrame = CFrame.new(plr:GetMouse().hit.p + Vector3.new(0,2,0))
	end)
end)
AddReference("tptool","clicktotp")

-- fly --
UIS.InputEnded:Connect(function(k,t)
	if t then return end
	if keys[k.KeyCode.Name] ~= nil then 
		keys[k.KeyCode.Name] = false
	end
end)

local flying = false
local flyspeed = 1
addCommand("fly", "Fly", function(data)
	flying = not flying
	local hum = plr.Character.Humanoid
	local hrt = plr.Character.HumanoidRootPart

	hrt.Anchored = true
	task.spawn(function()
		repeat task.wait()
			if keys["W"] then
				hrt.CFrame = hrt.CFrame + workspace.CurrentCamera.CFrame.LookVector * flyspeed
			end
			if keys["S"] then
				hrt.CFrame = hrt.CFrame + workspace.CurrentCamera.CFrame.LookVector * -flyspeed
			end
			if keys["D"] then 
				hrt.CFrame = hrt.CFrame + workspace.CurrentCamera.CFrame.RightVector * flyspeed
			end
			if keys["A"] then 
				hrt.CFrame = hrt.CFrame + workspace.CurrentCamera.CFrame.RightVector * -flyspeed
			end
		until hum.Health < 1 or not flying
		hrt.Anchored = false
	end)
end)

-- flyspeed --
addCommand("flyspeed", "FlySpeed [number]", function(data)
	flyspeed = tonumber(data[2]) or 1
end)
AddReference("flyspeed", "fspeed")

-- unfly --
addCommand("unfly", "unFly", function()
	flying = false
end)

-- animation stealer --
addCommand("stealanimations", "Stealanimations [plr]", function(data)
	local target = getPlayer(data[2])
	if not target or not target.Character or not plr.Character:FindFirstChild("LowerTorso") then workspace.CurrentCamera.CameraSubject = plr.Character.Humanoid return end
	for i,v in pairs(plr.Character.Animate:GetChildren()) do 
		if v:IsA("StringValue") then v:Destroy() end
	end
	for i,v in pairs(target.Character.Animate:GetChildren()) do 
		v:Clone().Parent = plr.Character.Animate
	end
end)
AddReference("stealanimations", "stealanims")
AddReference("stealanimations", "copyanims")

-- exit --
addCommand("exit", "Exit", function(data)
	ScreenGui:Destroy()
end)
AddReference("exit","quit")

-- debug --
addCommand("print", "Print stuff ig", function(data)
	print(getPlayer(data[2]).Name)
end)
