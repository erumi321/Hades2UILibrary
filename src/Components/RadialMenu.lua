---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

definition = {}

local OnPress = function(screen, button)
    local instance, data = GetInstanceAndDataByGUID(button.guid)
    if data.args.OnPressFunction then
        data.args.OnPressFunction(instance, button.value)
    end
end

local MouseOverButtonInternal = function(button)
    local instance, data = GetInstanceAndDataByGUID(button.guid)
    local screen = button.screen
    local components = screen.Components
    local guidKey = data.guid
    local args = data.args

    local key = guidKey .. "Option" .. button.index .. "Button"

    SetAnimation({DestinationId = components[key].Id, Name = "RadialArrowBright"})

    if args.TooltipTextboxId then
        ModifyTextBox({
            Id = args.TooltipTextboxId,
            Text = button.value
        })
    end
end

local MouseOffButtonInternal = function(button)
    local instance, data = GetInstanceAndDataByGUID(button.guid)
    local screen = button.screen
    local components = screen.Components
    local guidKey = data.guid
    local args = data.args
    for k,v in ipairs(args.Options) do
        local currentKey = guidKey .. "Option" .. k .. "Button"
        SetAnimation({DestinationId = components[currentKey].Id, Name = "RadialArrow"})
    end
    if args.TooltipTextboxId then
        ModifyTextBox({
            Id = args.TooltipTextboxId,
            Text = " "
        })
    end
end
local MoveButton = function(button)
    local instance, data = GetInstanceAndDataByGUID(button.guid)
    local screen = button.screen
    local components = screen.Components
    local object = data.object

    local guidKey = data.guid
    local args = data.args

    local key = guidKey .. "Option" .. button.targetIndex .. "Button"

    TeleportCursor({DestinationId = object.Id})

    thread(function()
        MouseOffButtonInternal(components[key])
        MouseOverButtonInternal(components[key])
    end)

    data.CurrentGamepadTarget = components[key]
end

local CenterPress = function(screen, button)
    local instance, data = GetInstanceAndDataByGUID(button.guid)
    OnPress(screen, data.CurrentGamepadTarget)
end

definition.Create = function(instance, data, screen)
    local components = screen.Components
    local args = data.args
    local guidKey = data.guid

    local xPos = args.X or 0
    local yPos = args.Y or 0

    local component = CreateScreenComponent({
        Name = "BaseInteractableButton",
        Group = args.Group,
        Animation="GUI\\Grey_Node",
        X = xPos,
        Y = yPos,
        Scale = 0.03
    })
    screen.Components[guidKey] = component
    SetAlpha({Id = component.Id, Fraction=0.01})
    SetInteractProperty({DestinationId = component.Id, Property = "FreeFormSelectable", Value = false})

    component.screen = screen
    component.guid = guidKey
    data.collapsed = true
    component.OnPressedFunctionName = CenterPress

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

        components[buttonKey].index = k
        components[buttonKey].value = v.Value
        components[buttonKey].screen = screen
        components[buttonKey].guid = guidKey
        components[buttonKey].OnMouseOverFunctionName = MouseOverButtonInternal
        components[buttonKey].OnMouseOffFunctionName = MouseOffButtonInternal
        components[buttonKey].OnPressedFunctionName = OnPress

        AttachLua({ Id = components[buttonKey].Id, Table = components[buttonKey] })

        if k == 1 then
            data.CurrentGamepadTarget = components[buttonKey]
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
        components[targetKey].screen = screen
        components[targetKey].guid = guidKey
        components[targetKey].OnMouseOverFunctionName = MoveButton

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

    return component
end

definition.Expand = function(instance, data)
    local object = data.object
    if data.expanded then
        return
    end
    data.expanded = true
    local screen = object.screen
    local components = screen.Components
    local args = data.args

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
        local optionKey = data.guid .. "Option" .. k
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

definition.Collapse = function(instance, data)
    local object = data.object
    if data.expanded == false then
        return
    end
    data.expanded = false
    local screen = object.screen
    local components = screen.Components
    local args = data.args

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
        local optionKey = data.guid .. "Option" .. k
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

definition.Destroy = function(instance, data)
    local object = data.object
    local screen = object.screen
    local components = screen.Components
    local args = data.args
    local guidKey = data.guid

    for k,v in ipairs(args.Options) do
        local optionKey = guidKey .. "Option" .. k
        local buttonKey = optionKey .. "Button"
        local imageKey = optionKey .. "Image"
        local targetKey = optionKey .. "Target"

        Destroy({Ids = {components[buttonKey].Id, components[imageKey].Id, components[targetKey].Id}})
    end

    Destroy({Id = object.Id})
    screen[guidKey] = nil
    instance = nil
    data.object = nil
    data = nil
end

return definition