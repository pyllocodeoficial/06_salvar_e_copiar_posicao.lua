-- 06: Painel para salvar a posicao do personagem, copiar como
-- CFrame.new(x, y, z) e teleportar de volta. Mostra coordenadas ao vivo.
-- Usado para descobrir: arremesso = (0, 5.3, -45); treino = (-15.10, 11.05, -6.97) no plot 1.

local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

local saved = nil

local function root()
	local c = player.Character
	return c and c:FindFirstChild("HumanoidRootPart")
end

local function fmtPos(v)
	return string.format("%.1f, %.1f, %.1f", v.X, v.Y, v.Z)
end

local old = player:WaitForChild("PlayerGui"):FindFirstChild("PosSaverGui")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "PosSaverGui"
gui.ResetOnSpawn = false
gui.Parent = player.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 150, 0, 130)
frame.Position = UDim2.new(0, 160, 0, 120)
frame.BackgroundColor3 = Color3.new(0, 0, 0)
frame.BackgroundTransparency = 0.4
frame.BorderSizePixel = 0
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

local lay = Instance.new("UIListLayout", frame)
lay.Padding = UDim.new(0, 2)
lay.SortOrder = Enum.SortOrder.LayoutOrder
lay.HorizontalAlignment = Enum.HorizontalAlignment.Center
Instance.new("UIPadding", frame).PaddingTop = UDim.new(0, 3)

local ord = 0
local function nxt() ord += 1 return ord end

local handle = Instance.new("TextLabel")
handle.Size = UDim2.new(1, -8, 0, 12)
handle.BackgroundColor3 = Color3.new(1, 1, 1)
handle.BackgroundTransparency = 0.8
handle.Text = "= Posicao ="
handle.TextColor3 = Color3.new(1, 1, 1)
handle.Font = Enum.Font.GothamBold
handle.TextSize = 9
handle.LayoutOrder = nxt()
handle.Parent = frame

local drag, ds, sp = false, nil, nil
handle.InputBegan:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
		drag, ds, sp = true, i.Position, frame.Position
	end
end)
UIS.InputChanged:Connect(function(i)
	if drag and (i.UserInputType == Enum.UserInputType.MouseMovement
		or i.UserInputType == Enum.UserInputType.Touch) then
		local d = i.Position - ds
		frame.Position = UDim2.new(0, sp.X.Offset + d.X, 0, sp.Y.Offset + d.Y)
	end
end)
UIS.InputEnded:Connect(function(i)
	if i.UserInputType == Enum.UserInputType.MouseButton1
		or i.UserInputType == Enum.UserInputType.Touch then
		drag = false
	end
end)

local function label(color)
	local l = Instance.new("TextLabel")
	l.Size = UDim2.new(1, -8, 0, 18)
	l.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	l.BackgroundTransparency = 0.3
	l.TextColor3 = color
	l.Font = Enum.Font.Code
	l.TextSize = 9
	l.TextWrapped = true
	l.LayoutOrder = nxt()
	l.Parent = frame
	Instance.new("UICorner", l).CornerRadius = UDim.new(0, 4)
	return l
end

local function button(text, color)
	local b = Instance.new("TextButton")
	b.Size = UDim2.new(1, -8, 0, 16)
	b.BackgroundColor3 = color
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 9
	b.Text = text
	b.LayoutOrder = nxt()
	b.Parent = frame
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
	return b
end

local liveLabel = label(Color3.fromRGB(120, 220, 255))
local savedLabel = label(Color3.fromRGB(150, 255, 150))
savedLabel.Text = "salva: -"

local saveBtn = button("Salvar posicao", Color3.fromRGB(60, 60, 130))
local copyBtn = button("Copiar salva", Color3.fromRGB(50, 130, 130))
local goBtn = button("Ir ate a salva", Color3.fromRGB(50, 130, 70))

local function flash(btn, text, original)
	btn.Text = text
	task.delay(1.2, function() btn.Text = original end)
end

saveBtn.Activated:Connect(function()
	local h = root()
	if not h then return end
	saved = h.CFrame
	savedLabel.Text = "salva: " .. fmtPos(saved.Position)
	flash(saveBtn, "Salva!", "Salvar posicao")
end)

copyBtn.Activated:Connect(function()
	if not saved then
		flash(copyBtn, "nada salvo", "Copiar salva")
		return
	end
	local p = saved.Position
	local text = string.format("CFrame.new(%.2f, %.2f, %.2f)", p.X, p.Y, p.Z)
	print("[POS SALVA] " .. text)
	if setclipboard then
		setclipboard(text)
		flash(copyBtn, "Copiado!", "Copiar salva")
	else
		flash(copyBtn, "veja o console", "Copiar salva")
	end
end)

goBtn.Activated:Connect(function()
	local h = root()
	if h and saved then
		h.AssemblyLinearVelocity = Vector3.zero
		h.CFrame = saved
	end
end)

task.spawn(function()
	while gui.Parent do
		local h = root()
		liveLabel.Text = h and ("agora: " .. fmtPos(h.Position)) or "sem personagem"
		task.wait(0.2)
	end

end)
