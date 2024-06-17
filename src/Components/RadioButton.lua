---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- this file will be reloaded if it changes during gameplay,

RadioButton = {}

definition = {}

local OnPress = function(screen, button)
    local components = screen.Components
    local instance, data = GetInstanceAndDataByGUID(button.guid)

    local guidKey = data.guid

    data.value = button.value

    for k = 1, button.numRadioButtons do
        local radioKey = guidKey .. "RadioButton" .. k .. "Radio" 
        local buttonKey = guidKey .. "RadioButton" .. k .. "Backing" 
        if k == button.index then 
            if components[buttonKey].selected == false then
                components[buttonKey].selected = true
                SetAnimation({ DestinationId = components[radioKey].Id, Name = "RadioButton_Selected" })
                button.RadioOnSelectedFunction(instance, components[buttonKey].value)
            end
        elseif components[buttonKey].selected == true then
            components[buttonKey].selected = false
            SetAnimation({ DestinationId = components[radioKey].Id, Name = "RadioButton_Unselected" })
            button.RadioOnDeselectedFunction(instance, components[buttonKey].value)
        end
    end
end

definition.Create = function(instance, data, screen)
    local components = screen.Components
    local args = data.args
    local guidKey = data.guid

    local component = CreateScreenComponent({
        Name = "BlankObstacle",
        Group=args.Group,
        X = 0,
        Y = 0
    })
    components[guidKey] = component
    component.fuid = guidKey
    component.screen = screen
    data.value = ""
    AttachLua({ Id = component.Id, Table = component })

    local currentXPos = args.X or 0
    local currentYPos = args.Y or 0

    for k,v in ipairs(args.Buttons) do
        if type(v) ~= "string" then
            print("Incorrect type within RadioButton.Buttons, all values must be a string")
            return
        end

        if args.SpacingFunction then
            local tX, tY = args.SpacingFunction(k)
            currentXPos = tX or currentXPos
            currentYPos = tY or currentYPos
        end

        local currentBaseKey = guidKey .. "RadioButton" .. k
        
        local backingKey = currentBaseKey .. "Backing"
        components[backingKey] = CreateScreenComponent({
            Name = "ButtonDefault",
            Group = args.Group or "",
            Scale = 1,
        })
        SetScaleX({Id = components[backingKey].Id, Fraction=args.ScaleX or 1})
        SetScaleY({Id = components[backingKey].Id, Fraction=args.ScaleY or 1})
        AttachLua({ Id = components[backingKey].Id, Table = components[backingKey] })
        Attach({ Id = components[backingKey].Id, DestinationId = component.Id, OffsetX = currentXPos, OffsetY = currentYPos})

        components[backingKey].index = k
        components[backingKey].guid = guidKey
        components[backingKey].value = v
        components[backingKey].selected = false
        components[backingKey].RadioOnSelectedFunction = args.OnSelectedFunction or function() end
        components[backingKey].RadioOnDeselectedFunction = args.OnDeselectedFunction or function() end
        components[backingKey].numRadioButtons = #args.Buttons
        components[backingKey].OnPressedFunctionName = OnPress
        
        local radioIconKey = currentBaseKey .. "Radio"
        components[radioIconKey] = CreateScreenComponent({
            Name="BlankObstacle",
            Group = args.Group or "",
            Scale = 1,
        })
        SetAnimation({ DestinationId = components[radioIconKey].Id, Name = "RadioButton_Unselected" })
        SetScaleX({Id = components[radioIconKey].Id, Fraction=args.ScaleX or 1})
        SetScaleY({Id = components[radioIconKey].Id, Fraction=args.ScaleY or 1})
        AttachLua({ Id = components[radioIconKey].Id, Table = components[radioIconKey] })
        Attach({ Id = components[radioIconKey].Id, DestinationId = component.Id, OffsetX = currentXPos - 100 * (args.ScaleX or 1), OffsetY = currentYPos})

        CreateTextBox({
            Id = components[backingKey].Id,
            Text = v,
            FontSize = (args.FontSize or 24),
			OffsetX = 0,
			OffsetY = 0,
			Color = Color.White,
			Font = "P22UndergroundSCMedium",
			Group = args.Group or "",
			ShadowBlur = 0,
			ShadowColor = { 0, 0, 0, 1 },
			ShadowOffset = { 0, 2 },
			Justification = "Left"
        })

        if args.SpacingFunction == nil then
            if args.Alignment == "Horizontal" then
                currentXPos = currentXPos + 284 * (args.ScaleX or 1) + 3 
            else
                currentYPos = currentYPos + 77 * (args.ScaleY or 1) + 3
            end
        end
    end

    return component
end

definition.Destroy = function(instance, data)
    local object = data.object
    local guidKey = data.guid
    local args = data.args
    local screen = object.screen
    local components = screen.Components

    for k,v in ipairs(args.Buttons) do
        local currentBaseKey = guidKey .. "RadioButton" .. k
        
        local backingKey = currentBaseKey .. "Backing"
        local radioIconKey = currentBaseKey .. "Radio"
        Destroy({Id = components[backingKey].Id})
        Destroy({Id = components[radioIconKey].Id})
    end
    Destroy({Id = object.Id})
    screen[guidKey] = nil
    data.object = nil
    instance = nil
    data = nil
end

return definition