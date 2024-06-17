---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- this file will be reloaded if it changes during gameplay,

definition = {}

--not public

local OnPress = function(screen, button)
    local components = screen.Components
    local instance, data = GetInstanceAndDataByGUID(button.guid)
    local object = data.object

    local update = data.args.OnSelectedFunction(instance, button.value)

    if update then
        ModifyTextBox({
            Id = object.Id,
            Text = button.value
        })
        data.value = button.value
    end
end

local ToggleDropdown = function(screen, button)
    local instance, data = GetInstanceAndDataByGUID(button.guid)
    local guidKey = data.guid
    local args = data.args
    local components = screen.Components

    if data.expanded == false then
        local baseYOffset = 68 * (args.ScaleY or 1) * 0.9
        local currentYOffset = 1 * baseYOffset + 3

        local arrowKey = guidKey .. "Arrow"
        SetAnimation({DestinationId = components[arrowKey].Id, Name="Arrow_DownHighlight"})

        for k,v in ipairs(args.Options) do
            local key = guidKey .. "Dropdown"

            local c = CreateScreenComponent({
                Name = "ButtonDefault",
                Group = args.Group,
                Scale = 1
            })
            key = key .. c.Id
            components[key] = c 

            components[key].value = v
            components[key].guid = guidKey
            components[key].OnPressedFunctionName = OnPress

            SetScaleX({Id = components[key].Id, Fraction=(args.ScaleX or 1) * 0.9})
            SetScaleY({Id = components[key].Id, Fraction=(args.ScaleY or 1) * 0.9})
            Attach({ Id = components[key].Id, DestinationId = button.Id, OffsetX = 5, OffsetY = currentYOffset})

            table.insert(data.ChildButtons, {Value = v, Id=components[key].Id})

            CreateTextBox({
                Id = components[key].Id,
                Text = args.Options[k],
                FontSize = (args.ItemFontSize or 20),
                OffsetX = -100 * (args.ScaleX or 1) * 0.9,
                OffsetY = 0,
                Color = Color.White,
                Font = "P22UndergroundSCMedium",
                Group = args.Group or "",
                ShadowBlur = 0,
                ShadowColor = { 0, 0, 0, 1 },
                ShadowOffset = { 0, 2 },
                Justification = "Left"
            })

            currentYOffset = baseYOffset * (k + 1) + 3
        end
        data.expanded = true
    else
        local arrowKey = guidKey .. "Arrow"
        SetAnimation({DestinationId = components[arrowKey].Id, Name="Arrow_LeftHighlight"})

        for k,v in pairs(data.ChildButtons) do
            Destroy({Id = v.Id})
        end
        data.ChildButtons = {}
        data.expanded = false
    end
end

definition.Create = function(instance, data, screen)
    local components = screen.Components
    local args = data.args
    local guidKey = data.guid

    local currentXPos = args.X or 0
    local currentYPos = args.Y or 0

    local component = CreateScreenComponent({
        Name = "ButtonDefault",
        Group = args.Group,
        X = currentXPos,
        Y = currentYPos,
        Scale = 1,
    })
    screen.Components[guidKey] = component

    data.ChildButtons = {}
    data.expanded = false
    component.guid = guidKey
    component.screen = screen
    component.OnPressedFunctionName = ToggleDropdown

    SetScaleX({Id = component.Id, Fraction=args.ScaleX or 1})
    SetScaleY({Id = component.Id, Fraction=args.ScaleY or 1})
    AttachLua({ Id = component.Id, Table = component })

    local dropdownArrowKey = guidKey .. "Arrow"
    components[dropdownArrowKey] = CreateScreenComponent({
        Name = "BlankObstacle",
        Group = args.Group,
        X = currentXPos,
        Y = currentYPos,
        Scale = 1,
    })

    SetAnimation({DestinationId = components[dropdownArrowKey].Id, Name="Arrow_LeftHighlight"})
    SetScaleX({Id = components[dropdownArrowKey].Id, Fraction=(args.ScaleX or 1) * 0.6})
    SetScaleY({Id = components[dropdownArrowKey].Id, Fraction=(args.ScaleY or 1) * 0.6})
    Attach({ Id = components[dropdownArrowKey].Id, DestinationId = component.Id, OffsetX = 100 * (args.ScaleX or 1), OffsetY = 0})

    local startText = args.Placeholder or ""
    if args.DefaultIndex then
        startText = args.Options[args.DefaultIndex]
    end
    data.value = startText
    CreateTextBox({
        Id =  component.Id,
        Text = startText,
        FontSize = (args.FontSize or 24),
        OffsetX = -100 * (args.ScaleX or 1),
        OffsetY = 0,
        Color = Color.White,
        Font = "P22UndergroundSCMedium",
        Group = args.Group or "",
        ShadowBlur = 0,
        ShadowColor = { 0, 0, 0, 1 },
        ShadowOffset = { 0, 2 },
        Justification = "Left"
    })

    return component
end

definition.AddOption = function(instance, data, option)
    local object = data.object
    local guidKey = data.guid
    local args = data.args
    local screen = object.screen
    local components = screen.Components

    table.insert(args.Options, option)

    if data.expanded then
        local newIndex = #args.Options
        local baseYOffset = 68 * (args.ScaleY or 1) * 0.9
        local currentYOffset = newIndex * baseYOffset + 3

        local arrowKey = guidKey .. "Arrow"
        SetAnimation({DestinationId = components[arrowKey].Id, Name="Arrow_DownHighlight"})

        local key = guidKey .. "Dropdown"

        local c = CreateScreenComponent({
            Name = "ButtonDefault",
            Group = args.Group,
            Scale = 1
        })
        key = key .. c.Id
        components[key] = c

        components[key].value = option
        components[key].guid = guidKey
        components[key].OnPressedFunctionName = OnPress

        SetScaleX({Id = components[key].Id, Fraction=(args.ScaleX or 1) * 0.9})
        SetScaleY({Id = components[key].Id, Fraction=(args.ScaleY or 1) * 0.9})
        Attach({ Id = components[key].Id, DestinationId = object.Id, OffsetX = 5, OffsetY = currentYOffset})

        table.insert(data.ChildButtons, {Value = option, Id=components[key].Id})

        CreateTextBox({
            Id = components[key].Id,
            Text = option,
            FontSize = (args.ItemFontSize or 20),
            OffsetX = -100 * (args.ScaleX or 1) * 0.9,
            OffsetY = 0,
            Color = Color.White,
            Font = "P22UndergroundSCMedium",
            Group = args.Group or "",
            ShadowBlur = 0,
            ShadowColor = { 0, 0, 0, 1 },
            ShadowOffset = { 0, 2 },
            Justification = "Left"
        })
    end
end

definition.RemoveOption = function(instance, data, option)
    local object = data.object
    local args = data.args

    if type(option) == "string" then
        local removed = false
        local baseYOffset = 68 * (args.ScaleY or 1) * 0.9

        local newChildButtons = {}
        local newOptions = {}

        for k,v in pairs(data.ChildButtons) do
            if v.Value == option and removed == false then
                Destroy({Id = v.Id})

                removed = true
            else
                table.insert(newChildButtons, v)
                table.insert(newOptions, v.Value)
                if removed == true and object.expanded == true then
                    local currentYOffset = (k - 1) * baseYOffset + 3
    
                    Attach({ Id = v.Id, DestinationId = object.Id, OffsetX = 5, OffsetY = currentYOffset})
                end
            end
        end

        args.Options = newOptions
        data.ChildButtons = newChildButtons
    end
end

definition.Destroy = function(instance, data)
    local object = data.object
    local guidKey = data.guid
    local screen = object.screen
    local components = screen.Components

    local arrowKey = guidKey .. "Arrow"
    if data.expanded then
        for k,v in pairs(data.ChildButtons) do
            Destroy({Id = v.Id})
        end
    end
    Destroy({Ids = {components[arrowKey].Id, object.Id}})
    screen[guidKey] = nil
    data.object = nil
    instance = nil
end

return definition