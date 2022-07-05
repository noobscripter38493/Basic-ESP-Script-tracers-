local camera = workspace.CurrentCamera
local viewportSize = camera.ViewportSize
local worldToViewport = camera.WorldToViewportPoint

local Defaults = {
    Visible = true,
    ZIndex = 9e9,
    Transparency = 1,
    From = viewportSize / 2
}
-- made in 20 mins
local ESP = {
    Enabled = true,
    Objects = setmetatable({}, {
        __newindex = function(self, i, v)
            local v3 = worldToViewport(camera, i.Position)

            for i2, v2 in next, Defaults do
                v[i2] = v2    
            end
            
            v.To = Vector2.new(v3.X, v3.Y)
            
            rawset(self, i, v)
        end
    })
}

function ESP:New(class, part)
    if not ESP:InitCheckParent(part) then return end

    local obj = Drawing.new(class)
    
    self.Objects[part] = obj
end

function ESP:InitCheckParent(part)
    return part.Parent and part:GetPropertyChangedSignal("Parent"):Connect(function()
        if part.Parent then return end
        
        self.Objects[part]:Remove()
        self.Objects[part] = nil
    end)
end

function ESP:Update(part, obj)
    local v3, onscreen = worldToViewport(camera, part.Position)
    
    if onscreen then 
        obj.Visible = true
    else
        obj.Visible = false
    end
    
    obj.To = Vector2.new(v3.X, v3.Y)
end

game.RunService.RenderStepped:Connect(function()
    if ESP.Enabled then
        for part, v in next, ESP.Objects do
            ESP:Update(part, v)
        end
    end
end)

return ESP
