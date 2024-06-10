---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- this file will be reloaded if it changes during gameplay,

RadialMenu = {}

RadialMenu.Create = function(env, screen, args)
    local components = screen.Components
    local guid = env._PLUGIN.guid
    local key = ""
    for a = 1, 10 do
        key = key .. string.char(math.random(65, 65 + 25))
    end
    local guidKey = env._PLUGIN.guid .. key

    local xPos = args.X or 0
    local yPos = args.Y or 0

    components[guidKey] = CreateScreenComponent({
        Name = "BaseInteractableButton",
        Group = args.Group,
        Animation="GUI\\Grey_Node",
        X = xPos,
        Y = yPos,
        Scale = 0.03
    })
    SetAlpha({Id = components[guidKey].Id, Fraction=0.01})
    SetInteractProperty({DestinationId = components[guidKey].Id, Property = "FreeFormSelectable", Value = false})

    components[guidKey].env = env
    components[guidKey].guid = guid
    components[guidKey].screen = screen
    components[guidKey].guidKey = guidKey
    components[guidKey].args = args
    components[guidKey].collapsed = true
    components[guidKey].OnPressedFunctionName = RadialMenu.CenterPress

    local currentAngle = args.StartAngle or 0
    local maxAngle = args.EndAngle or 360

    local angleIncrement = 0
    if (maxAngle - currentAngle) % 360 == 0 then
        angleIncrement = (maxAngle - currentAngle) / #args.Options
    else
        angleIncrement = (maxAngle - currentAngle) / (#args.Options - 1)
    end
    
    for k,v in ipairs(args.Options) do
        local artAngle = currentAngle + 180
        local optionKey = guidKey .. "Option" .. k

        local currentXOffset = xPos
        local currentYOffset = yPos

        local buttonKey = optionKey .. "Button"
        components[buttonKey] = CreateScreenComponent({
            Name = "BaseInteractableButton",
            Group =  args.Group or "",
            X = currentXOffset,
            Y = currentYOffset,
            Scale = 1
        })
        SetAnimation({DestinationId = components[buttonKey].Id, Name = "RadialArrow"})
        SetInteractProperty({DestinationId = components[buttonKey].Id, Property = "FreeFormSelectable", Value = false})
        SetScaleX({Id = components[buttonKey].Id, Fraction=(args.ScaleX or 1)})
        SetScaleY({Id = components[buttonKey].Id, Fraction=(args.ScaleY or 1)})
        SetAngle({ Id = components[buttonKey].Id, Angle = artAngle})

        components[buttonKey].args = args
        components[buttonKey].index = k
        components[buttonKey].value = v.Value
        components[buttonKey].screen = screen
        components[buttonKey].guidKey = guidKey
        components[buttonKey].parent = components[guidKey]
        components[buttonKey].OnMouseOverFunctionName = RadialMenu.MouseOverButtonInternal
        components[buttonKey].OnMouseOffFunctionName = RadialMenu.MouseOffButtonInternal
        components[buttonKey].OnPressedFunctionName = RadialMenu.OnPress

        AttachLua({ Id = components[buttonKey].Id, Table = components[buttonKey] })

        if k == 1 then
            components[guidKey].CurrentGamepadTarget = components[buttonKey]
        end

        local sX = args.ScaleX or 1
        local sY = args.ScaleY or 1

        local targetKey = optionKey .. "Target"
        components[targetKey] = CreateScreenComponent({
            Name = "BaseInteractableButton",
            Group =  args.Group or "",
            Animation="GUI\\Grey_Node",
            X = currentXOffset,
            Y = currentYOffset,
            Scale = 0.03
        })

        local teleportX = -math.cos(currentAngle * math.pi / 180) * 40 * sX
        local teleportY = math.sin(currentAngle * math.pi / 180) * 40 * sX

        Attach({ Id = components[targetKey].Id, DestinationId = components[buttonKey].Id, OffsetX = teleportX, OffsetY = teleportY })

        components[targetKey].targetIndex = k
        components[targetKey].args = args
        components[targetKey].screen = screen
        components[targetKey].guidKey = guidKey
        components[targetKey].parent = components[guidKey]
        components[targetKey].OnMouseOverFunctionName = RadialMenu.MoveButton

        AttachLua({ Id = components[targetKey].Id, Table = components[targetKey] })

        SetAlpha({Id = components[targetKey].Id, Fraction=0.01})

        local iconOffsetX = currentXOffset - (7 * sX)
        iconOffsetX = iconOffsetX + math.abs(math.cos((currentAngle / 2) * math.pi / 180) * 12 * sX)
        local iconOffsetY = currentYOffset
        iconOffsetY = iconOffsetY - math.sin((currentAngle) * math.pi / 180) * 5 * sY

        local imageKey = optionKey .. "Image"
        components[imageKey] = CreateScreenComponent({
            Name = "BlankObstacle",
            Animation = v.Image.Path,
            Group =  args.Group or "",
            X = iconOffsetX,
            Y = iconOffsetY,
            Scale = 1
        })
        SetInteractProperty({DestinationId = components[imageKey].Id, Property = "FreeFormSelectable", Value = false})
        SetScaleX({Id = components[imageKey].Id, Fraction=(args.ScaleX or 1) * (v.Image.ScaleX or 1)})
        SetScaleY({Id = components[imageKey].Id, Fraction=(args.ScaleY or 1) * (v.Image.ScaleY or 1)})

        --we want these to be effectivly non-existant until we expand
        SetAlpha({Ids = {components[buttonKey].Id, components[imageKey].Id}, Fraction=0, Duration = 0})
        UseableOff({Ids = {components[buttonKey].Id, components[imageKey].Id, components[targetKey].Id}})

        currentAngle = currentAngle + angleIncrement
    end

    return components[guidKey]
end

RadialMenu.Expand = function(env, RadialMenuObject)
    if RadialMenuObject.expanded then
        return
    end
    RadialMenuObject.expanded = true
    local screen = RadialMenuObject.screen
    local components = screen.Components
    local args = RadialMenuObject.args

    local currentAngle = args.StartAngle or 0
    local maxAngle = args.EndAngle or 360
    local angleIncrement = 0
    if (maxAngle - currentAngle) % 360 == 0 then
        angleIncrement = (maxAngle - currentAngle) / #args.Options
    else
        angleIncrement = (maxAngle - currentAngle) / (#args.Options - 1)
    end
    local radius = args.Radius or 100
    for k,v in ipairs(args.Options) do
        local optionKey = RadialMenuObject.guidKey .. "Option" .. k
        local buttonKey = optionKey .. "Button"
        local imageKey = optionKey .. "Image"
        local targetKey = optionKey .. "Target"

        UseableOn({Ids = {components[buttonKey].Id, components[imageKey].Id, components[targetKey].Id}})
        local sX = args.ScaleX or 1
        if args.ExpansionTime > 0 then
            local startOffset = 20 * sX
            if startOffset >= radius / 1.5 then
                startOffset = 0
            end
            Move({Ids = {components[buttonKey].Id, components[imageKey].Id}, Angle = currentAngle, Distance = startOffset, Duration = 0})
            Move({Ids = {components[buttonKey].Id, components[imageKey].Id}, Angle = currentAngle, Distance = radius, Duration = args.ExpansionTime, EaseOut=0.9})
            SetAlpha({Ids = {components[buttonKey].Id, components[imageKey].Id}, Fraction=1, Duration = args.ExpansionTime / 4})
        else
            Move({Ids = {components[buttonKey].Id, components[imageKey].Id}, Angle = currentAngle, Distance = radius, Duration = 0})
            SetAlpha({Ids = {components[buttonKey].Id, components[imageKey].Id}, Fraction=1, Duration = 0})
        end

        currentAngle = currentAngle + angleIncrement
    end
end

RadialMenu.Collapse = function(env, RadialMenuObject)
    if RadialMenuObject.expanded == false then
        return
    end
    RadialMenuObject.expanded = false
    local screen = RadialMenuObject.screen
    local components = screen.Components
    local args = RadialMenuObject.args

    local currentAngle = args.StartAngle or 0
    local maxAngle = args.EndAngle or 360
    local angleIncrement = 0
    if (maxAngle - currentAngle) % 360 == 0 then
        angleIncrement = (maxAngle - currentAngle) / #args.Options
    else
        angleIncrement = (maxAngle - currentAngle) / (#args.Options - 1)
    end
    local radius = args.Radius or 100

    ModifyTextBox({
        Id = args.TooltipTextboxId,
        Text = " "
    })

    for k,v in ipairs(args.Options) do
        local optionKey = RadialMenuObject.guidKey .. "Option" .. k
        local buttonKey = optionKey .. "Button"
        local imageKey = optionKey .. "Image"
        local targetKey = optionKey .. "Target"

        UseableOff({Ids = {components[buttonKey].Id, components[imageKey].Id, components[targetKey].Id}})

        local sX = args.ScaleX or 1
        if args.ExpansionTime > 0 then
            local startOffset = 20 * sX
            if startOffset >= radius / 1.5 then
                startOffset = 0
            end
            Move({Ids = {components[buttonKey].Id, components[imageKey].Id}, Angle = currentAngle, Distance = -radius, Duration = args.ExpansionTime, EaseOut=0.9})
            thread(function()
                wait( args.ExpansionTime / 2)
                SetAlpha({Ids = {components[buttonKey].Id, components[imageKey].Id}, Fraction=0, Duration = args.ExpansionTime / 4})
            end)
        else
            Move({Ids = {components[buttonKey].Id, components[imageKey].Id}, Angle = currentAngle, Distance = -radius, Duration = 0})
            SetAlpha({Ids = {components[buttonKey].Id, components[imageKey].Id}, Fraction=0, Duration = 0})
        end

        currentAngle = currentAngle + angleIncrement
    end
end

RadialMenu.Destroy = function(env, RadialMenuObject)
    local screen = RadialMenuObject.screen
    local components = screen.Components
    local args = RadialMenuObject.args

    for k,v in ipairs(args.Options) do
        local optionKey = RadialMenuObject.guidKey .. "Option" .. k
        local buttonKey = optionKey .. "Button"
        local imageKey = optionKey .. "Image"
        local targetKey = optionKey .. "Target"

        Destroy({Ids = {components[buttonKey].Id, components[imageKey].Id, components[targetKey].Id}})
    end

    Destroy({Id = RadialMenuObject.Id})
end

RadialMenu.OnPress = function(screen, button)
    if button.args.OnPressFunction then
        button.args.OnPressFunction(button.parent, button.value)
    end
end

RadialMenu.MouseOverButtonInternal = function(button)
    local screen = button.screen
    local components = screen.Components
    local key = button.guidKey .. "Option" .. button.index .. "Button"

    SetAnimation({DestinationId = components[key].Id, Name = "RadialArrowBright"})


    if button.args.TooltipTextboxId then
        ModifyTextBox({
            Id = button.args.TooltipTextboxId,
            Text = button.value
        })
    end
end

RadialMenu.MouseOffButtonInternal = function(button)
    local screen = button.screen
    local components = screen.Components
    for k,v in ipairs(button.args.Options) do
        local currentKey = button.guidKey .. "Option" .. k .. "Button"
        SetAnimation({DestinationId = components[currentKey].Id, Name = "RadialArrow"})
    end
    if button.args.TooltipTextboxId then
        ModifyTextBox({
            Id = button.args.TooltipTextboxId,
            Text = " "
        })
    end
end
RadialMenu.MoveButton = function(button)
    local screen = button.screen
    local components = screen.Components
    local guidKey = button.guidKey
    local args = button.args

    local key = guidKey .. "Option" .. button.targetIndex .. "Button"

    TeleportCursor({DestinationId = button.parent.Id})

    thread(function()
        RadialMenu.MouseOffButtonInternal(components[key])
        RadialMenu.MouseOverButtonInternal(components[key])
    end)

    button.parent.CurrentGamepadTarget = components[key]
end

RadialMenu.CenterPress = function(screen, button)
    RadialMenu.OnPress(screen, button.CurrentGamepadTarget)
end