---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- this file will be reloaded if it changes during gameplay,

Dropdown = {}

function Dropdown.Create(env, screen, args)
    local components = screen.Components
    local guid = env._PLUGIN.guid
    local key = ""
    for a = 1, 10 do
        key = key .. string.char(math.random(65, 65 + 25))
    end
    local guidKey = env._PLUGIN.guid .. key

    local currentXPos = args.X or 0
    local currentYPos = args.Y or 0

    components[guidKey] = CreateScreenComponent({
        Name = "ButtonDefault",
        Group = args.Group,
        X = currentXPos,
        Y = currentYPos,
        Scale = 1,
    })
    components[guidKey].env = env
    components[guidKey].guid = guid
    components[guidKey].screen = screen
    components[guidKey].guidKey = guidKey
    components[guidKey].args = args
    components[guidKey].expanded = false
    components[guidKey].OnPressedFunctionName = Dropdown.Toggle

    SetScaleX({Id = components[guidKey].Id, Fraction=args.ScaleX or 1})
    SetScaleY({Id = components[guidKey].Id, Fraction=args.ScaleY or 1})
    AttachLua({ Id = components[guidKey].Id, Table = components[guidKey] })

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
    Attach({ Id = components[dropdownArrowKey].Id, DestinationId = components[guidKey].Id, OffsetX = 100 * (args.ScaleX or 1), OffsetY = 0})

    local startText = args.Placeholder or ""
    if args.DefaultIndex then
        startText = args.Options[args.DefaultIndex]
    end
    components[guidKey].value = startText
    CreateTextBox({
        Id =  components[guidKey].Id,
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

    return components[guidKey]
end

Dropdown.AddOption = function(env, DropdownObject, option)
    local screen = DropdownObject.screen
    local components = screen.Components
    local args = DropdownObject.args

    table.insert(DropdownObject.args.Options, option)

    if DropdownObject.expanded then
        local newIndex = #DropdownObject.args.Options
        local baseYOffset = 68 * (args.ScaleY or 1) * 0.9
        local currentYOffset = newIndex * baseYOffset + 3

        local arrowKey = DropdownObject.guidKey .. "Arrow"
        SetAnimation({DestinationId = components[arrowKey].Id, Name="Arrow_DownHighlight"})

        local key = DropdownObject.guidKey .. "Dropdown" .. option

        components[key] = CreateScreenComponent({
            Name = "ButtonDefault",
            Group = args.Group,
            Scale = 1
        })

        components[key].OnPressFunc = args.OnSelectedFunction or function() end
        components[key].value = option
        components[key].guid = DropdownObject.guid
        components[key].guidKey = DropdownObject.guidKey
        components[key].args = args
        components[key].parent = DropdownObject
        components[key].OnPressedFunctionName = Dropdown.OnPress

        SetScaleX({Id = components[key].Id, Fraction=(args.ScaleX or 1) * 0.9})
        SetScaleY({Id = components[key].Id, Fraction=(args.ScaleY or 1) * 0.9})
        Attach({ Id = components[key].Id, DestinationId = components[DropdownObject.guidKey].Id, OffsetX = 5, OffsetY = currentYOffset})

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

Dropdown.RemoveOption = function(env, DropdownObject, option)
    local screen = DropdownObject.screen
    local components = screen.Components
    local args = DropdownObject.args

    if type(option) == "string" then
        local removed = false
        local baseYOffset = 68 * (args.ScaleY or 1) * 0.9

        local newOptions = {}

        for k,v in ipairs(args.Options) do
            if v == option then
                local key = DropdownObject.guidKey .. "Dropdown" .. v
                Destroy({Id = components[key].Id})

                removed = true
            else
                table.insert(newOptions, v)
                if removed == true then
                    local key = DropdownObject.guidKey .. "Dropdown" .. v
                    local currentYOffset = (k - 1) * baseYOffset + 3
    
                    Attach({ Id = components[key].Id, DestinationId = components[DropdownObject.guidKey].Id, OffsetX = 5, OffsetY = currentYOffset})
                end
            end
        end

        DropdownObject.args.Options = newOptions
    elseif type(option) == "number" then
        local key = DropdownObject.guidKey .. "Dropdown" .. DropdownObject.args.Options[option]
        Destroy({Id = components[key].Id})
        table.remove(DropdownObject.args.Options, option)

        local baseYOffset = 68 * (args.ScaleY or 1) * 0.9
        for k = option, #args.Options do
            local v = args.Options[k]
            local key = DropdownObject.guidKey .. "Dropdown" .. v
            local currentYOffset = k * baseYOffset + 3

            Attach({ Id = components[key].Id, DestinationId = components[DropdownObject.guidKey].Id, OffsetX = 5, OffsetY = currentYOffset})
        end
    end
end

Dropdown.Destroy = function(env, DropdownObject)
    local screen = DropdownObject.screen
    local components = screen.Components
    local args = DropdownObject.args
    local guidKey = DropdownObject.guidKey
    local arrowKey = guidKey .. "Arrow"
    if DropdownObject.expanded then
        for k,v in ipairs(args.Options) do
            local key = guidKey .. "Dropdown" .. v
            Destroy({Id = components[key].Id})
        end
    end
    Destroy({Ids = {components[arrowKey].Id, components[guidKey].Id}})
end

--not public
Dropdown.Toggle = function(screen, button)
    local components = screen.Components
    local args = button.args
    local guidKey = button.guidKey

    if button.expanded == false then
        local baseYOffset = 68 * (args.ScaleY or 1) * 0.9
        local currentYOffset = 1 * baseYOffset + 3

        local arrowKey = guidKey .. "Arrow"
        SetAnimation({DestinationId = components[arrowKey].Id, Name="Arrow_DownHighlight"})

        for k,v in ipairs(args.Options) do
            local key = guidKey .. "Dropdown" .. v

            components[key] = CreateScreenComponent({
                Name = "ButtonDefault",
                Group = args.Group,
                Scale = 1
            })

            components[key].OnPressFunc = args.OnSelectedFunction or function() end
            components[key].value = v
            components[key].guid = button.guid
            components[key].guidKey = guidKey
            components[key].args = args
            components[key].parent = button
            components[key].OnPressedFunctionName = Dropdown.OnPress

            SetScaleX({Id = components[key].Id, Fraction=(args.ScaleX or 1) * 0.9})
            SetScaleY({Id = components[key].Id, Fraction=(args.ScaleY or 1) * 0.9})
            Attach({ Id = components[key].Id, DestinationId = components[guidKey].Id, OffsetX = 5, OffsetY = currentYOffset})

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
        button.expanded = true
    else
        local arrowKey = guidKey .. "Arrow"
        SetAnimation({DestinationId = components[arrowKey].Id, Name="Arrow_LeftHighlight"})

        for k,v in ipairs(args.Options) do
            local key = guidKey .. "Dropdown" .. v
            Destroy({Id = components[key].Id})
        end
        button.expanded = false
    end
end

--not public
Dropdown.OnPress = function(screen, button)
    local components = screen.Components
    local update = button.OnPressFunc(button.parent, button.value)

    if update then
        local guidKey = button.guidKey
        ModifyTextBox({
            Id =  components[guidKey].Id,
            Text = button.value
        })
        components[guidKey].value = button.value
    end
end

