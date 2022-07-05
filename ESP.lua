local camera = workspace.CurrentCamera
local viewportSize = camera.ViewportSize
local worldToViewport = camera.WorldToViewportPoint

local ESP = {
    Enabled = true,
    Objects = {}
}

function ESP:DrawAddon(class, properties)
    local obj = Drawing.new(class)

    for i, v in next, properties do
        obj[i] = v
    end

    return obj
end

function ESP:New(part, properties)
    local obj = properties or {
        Name = part.Name,
        Color = part.Color
    }
    
    setmetatable(obj, {__index = getprops(part)}) -- now, dont have to put every property into the table
    
    obj.addons = {}
    local addons = obj.addons

    addons.Text = self:DrawAddon("Text", {
        Text = obj.Name,
        Size = 20,
        Center = true,
        Outline = true,
        Color = obj.Color,
        Visible = true
    })

    addons.Line = self:DrawAddon("Line", {
        From = viewportSize / 2,
        Thickness = 2.5,
        Visible = true,
        Color = obj.Color
    })

    setmetatable(obj, {
        __newindex = function(self, i, v)
            for i2, v2 in next, addons do
                if i2 == "Line" then
                    v2.To = v
                    continue
                end

                v2.Position = v 
            end
        end
    })

    self.Objects[part] = obj
    
    ESP:InitCheckParent(part)
end

function ESP:RemoveObj(part)
    if not self.Objects[part] then return end -- manual remove object call

    for _, obj in next, self.Objects[part].addons do
        obj:Remove()
    end

    self.Objects[part] = nil
end

function ESP:InitCheckParent(part)
    local parent_check; parent_check = part:GetPropertyChangedSignal("Parent"):Connect(function()
        if part.Parent then return end
        if not self.Objects[part] then
            parent_check:Disconnect()
            return
        end
        
        parent_check:Disconnect()
        self:RemoveObj(part)
    end)
end

function ESP:SetVisible(obj, onscreen)
    for _, v in next, obj.addons do
        if not self.Enabled then
            v.Visible = false    
            continue
        end
        
        v.Visible = onscreen
    end
end

function ESP:GetPosition(part, obj)
    local v3, onscreen = worldToViewport(camera, part.Position)
    
    self:SetVisible(obj, onscreen)

    local v2 = Vector2.new(v3.X, v3.Y)

    return v2
end

function ESP:Update(part, obj)
    local position = self:GetPosition(part, obj)
    
    obj.Position = position
end

game.RunService.RenderStepped:Connect(function()
    for part, v in next, ESP.Objects do
        ESP:Update(part, v)
    end
end)

return ESP
