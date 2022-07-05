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
    local obj = Drawing.new(class)
    
    self.Objects[part] = obj
end

for _, v in ipairs(workspace:GetDescendants()) do
    if v:IsA("Part") then
        ESP:New("Line", v)
    end
end

game.RunService.RenderStepped:Connect(function()
    if ESP.Enabled then
        for i, v in next, ESP.Objects do
            local v3, onscreen = worldToViewport(camera, i.Position)
            
            if onscreen then 
                v.Visible = true
            else
                v.Visible = false
            end
            
            v.To = Vector2.new(v3.X, v3.Y)
        end
    end
end)