---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- this file will be reloaded if it changes during gameplay,

RadioButton = {}

RadioButton.Create = function(env, screen, data)
    local components = screen.Components
    local key = ""
    for a = 1, 10 do
        key = key .. string.char(math.random(65, 65 + 25))
    end
    local guidKey = env._PLUGIN.guid .. key

    components[guidKey] = CreateScreenComponent({
        Name = "BlankObstacle",
        Group=data.Group,
        X = 0,
        Y = 0
    })
    components[guidKey].data = data
    components[guidKey].guidKey = guidKey
    components[guidKey].screen = screen
    components[guidKey].value = ""
    AttachLua({ Id = components[guidKey].Id, Table = components[guidKey] })

    local currentXPos = data.X or 0
    local currentYPos = data.Y or 0

    for k,v in ipairs(data.Buttons) do
        if type(v) ~= "string" then
            print("Incorrect type within RadioButton.Buttons, all values must be a string")
            return
        end

        if data.SpacingFunction then
            local tX, tY = data.SpacingFunction(k)
            currentXPos = tX or currentXPos
            currentYPos = tY or currentYPos
        end

        local currentBaseKey = guidKey .. "RadioButton" .. k
        
        local backingKey = currentBaseKey .. "Backing"
        components[backingKey] = CreateScreenComponent({
            Name = "ButtonDefault",
            Group = data.Group or "",
            Scale = 1,
        })
        SetScaleX({Id = components[backingKey].Id, Fraction=data.ScaleX or 1})
        SetScaleY({Id = components[backingKey].Id, Fraction=data.ScaleY or 1})
        AttachLua({ Id = components[backingKey].Id, Table = components[backingKey] })
        Attach({ Id = components[backingKey].Id, DestinationId = components[guidKey].Id, OffsetX = currentXPos, OffsetY = currentYPos})

        components[backingKey].index = k
        components[backingKey].screen = screen
        components[backingKey].Parent = components[guidKey]
        components[backingKey].guidKey = guidKey
        components[backingKey].value = v
        components[backingKey].selected = false
        components[backingKey].RadioOnSelectedFunction = data.OnSelectedFunction or function() end
        components[backingKey].RadioOnDeselectedFunction = data.OnDeselectedFunction or function() end
        components[backingKey].numRadioButtons = #data.Buttons
        components[backingKey].OnPressedFunctionName = RadioButton.OnPress
        
        local radioIconKey = currentBaseKey .. "Radio"
        components[radioIconKey] = CreateScreenComponent({
            Name="BlankObstacle",
            Group = data.Group or "",
            Scale = 1,
        })
        SetAnimation({ DestinationId = components[radioIconKey].Id, Name = "RadioButton_Unselected" })
        SetScaleX({Id = components[radioIconKey].Id, Fraction=data.ScaleX or 1})
        SetScaleY({Id = components[radioIconKey].Id, Fraction=data.ScaleY or 1})
        AttachLua({ Id = components[radioIconKey].Id, Table = components[radioIconKey] })
        Attach({ Id = components[radioIconKey].Id, DestinationId = components[guidKey].Id, OffsetX = currentXPos - 100 * (data.ScaleX or 1), OffsetY = currentYPos})

        CreateTextBox({
            Id = components[backingKey].Id,
            Text = v,
            FontSize = (data.FontSize or 24),
			OffsetX = 0,
			OffsetY = 0,
			Color = Color.White,
			Font = "P22UndergroundSCMedium",
			Group = data.Group or "",
			ShadowBlur = 0,
			ShadowColor = { 0, 0, 0, 1 },
			ShadowOffset = { 0, 2 },
			Justification = "Left"
        })

        if data.SpacingFunction == nil then
            if data.Alignment == "Horizontal" then
                currentXPos = currentXPos + 284 * (data.ScaleX or 1) + 3 
            else
                currentYPos = currentYPos + 77 * (data.ScaleY or 1) + 3
            end
        end
    end

    return components[guidKey]
end

RadioButton.Destroy = function(env, RadioButtonObject)
    local screen = RadioButtonObject.screen
    local components = screen.Components
    local guidKey = RadioButtonObject.guidKey
    for k,v in ipairs(components[guidKey].data.Buttons) do
        local currentBaseKey = guidKey .. "RadioButton" .. k
        
        local backingKey = currentBaseKey .. "Backing"
        local radioIconKey = currentBaseKey .. "Radio"
        Destroy({Id = components[backingKey].Id})
        Destroy({Id = components[radioIconKey].Id})
    end
    Destroy({Id = components[guidKey].Id})

end

--not public
RadioButton.OnPress = function(screen, button)
    local components = screen.Components

    for k = 1, button.numRadioButtons do
        local radioKey = button.guidKey .. "RadioButton" .. k .. "Radio" 
        local buttonKey = button.guidKey .. "RadioButton" .. k .. "Backing" 
        if k == button.index then 
            if components[buttonKey].selected == false then
                components[buttonKey].selected = true
                button.Parent.value = components[buttonKey].value
                SetAnimation({ DestinationId = components[radioKey].Id, Name = "RadioButton_Selected" })
                button.RadioOnSelectedFunction(button.Parent, components[buttonKey].value)
            end
        elseif components[buttonKey].selected == true then
            components[buttonKey].selected = false
            SetAnimation({ DestinationId = components[radioKey].Id, Name = "RadioButton_Unselected" })
            button.RadioOnDeselectedFunction(button.Parent, components[buttonKey].value)
        end
    end
end