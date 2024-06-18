---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- this file will be reloaded if it changes during gameplay,

definition = {}

--Control "MenuUp" and "MenuDown" is ScrollWheel

local DeregisterUpdateFunction = function(screen, guid)
    screen.UILibrary.UpdateFlag[guid] = nil

    if not screen.UpdateFunctionArgs then
        screen.UpdateFunctionArgs = {}
    end
    screen.UpdateFunctionArgs[guid] = nil

    if IsEmpty(screen.UILibrary.UpdateFlag) then
        screen.UpdateFunctionName = nil
    end
end

local UpdateVisiblity = function(screen, args, baseObject, movingObject, vertical)
    local components = screen.Components

    local distance = GetDistance({Id = baseObject.Id, DestinationId = movingObject})
    local angle = GetAngleBetween({Id = baseObject.Id, DestinationId = movingObject})

    if vertical then
        distance = -distance * math.sin(math.rad(angle))
    else
        distance = distance * math.cos(math.rad(angle))
    end

    local alpha = 1
    if distance < 0 then
        alpha = (50 + distance) / 50
    end
    local viewSize = args.ViewWidth
    if vertical then
        viewSize = args.ViewHeight
    end
    if distance > viewSize then
        alpha = (50 - (distance - viewSize)) / 50
    end

    SetAlpha({Id = movingObject, Fraction = alpha})

    -- local key = nil
    -- for k, component in pairs( components ) do
    --     if component.Id == v then
    --         key = k
    --         break
    --     end
    -- end
    -- if key then
        -- print(key)
        -- if not components[key].UILibScrollingSetUseable then
        --     components[key].UILibScrollingSetUseable = IsUseable({Id = components[key].Id})
        -- end

        -- if components[key].UILibScrollingSetUseable then
            if alpha <= 0 then
                UseableOff({Id = movingObject})
            else
                UseableOn({Id = movingObject})
            end
        -- end
    -- end

    return distance
end

local OnUpdateInternal = function(screen, object, elapsed, direction, vertical)
    local scrollDirection = direction or 0
    local scrollMult = 1
    local scrollTime = 0

    if scrollDirection == 0 then 
        return
    end

    local components = screen.Components

    local instance = component_object_instance[object]
    local data = component_instance_data[instance]
    local args = data.args
    local scrollFraction = data.scrollFraction
    local guidKey = data.guid
    --speed up mouse
    if IsControlDown({Name = "MenuUp"}) or IsControlDown({Name = "MenuDown"}) then
        scrollMult = 2
        scrollTime = elapsed
    end

    local distanceScrolled = (args.ScrollSpeed or 200) * elapsed * scrollDirection * scrollMult
    local currentPosition = scrollFraction * data.ScrollSize
    local endPosition = currentPosition + distanceScrolled

    if endPosition > data.ScrollSize then
        endPosition = data.ScrollSize
    elseif endPosition < 0 then
        endPosition = 0
    end

    distanceScrolled = endPosition - currentPosition

    scrollFraction = scrollFraction + distanceScrolled / data.ScrollSize

    data.scrollFraction = scrollFraction

    if vertical then
        Move({ Id = components[guidKey .. "Slider"].Id, DestinationId = object.Id, OffsetY = args.ViewHeight * scrollFraction, Duration = scrollTime, EaseIn = 0.0, EaseOut = 1.0 })

        for k,v in pairs(args.Items) do
            local angle = GetAngleBetween({Id = object.Id, DestinationId = v})
            local distance = GetDistance({Id = object.Id, DestinationId = v})
            local x = distance * math.cos(math.rad(angle))
            local yDistance = -distance * math.sin(math.rad(angle)) - distanceScrolled
            Move({Id = v, DestinationId = object.Id, OffsetX = x, OffsetY = yDistance, Duration=scrollTime})

            UpdateVisiblity(screen, args, object, v, true)
        end
    else
        Move({ Id = components[guidKey .. "Slider"].Id, DestinationId = object.Id, OffsetX = args.ViewWidth * scrollFraction, Duration = scrollTime, EaseIn = 0.0, EaseOut = 1.0 })

        for k,v in pairs(args.Items) do
            local angle = GetAngleBetween({Id = object.Id, DestinationId = v})
            local distance = GetDistance({Id = object.Id, DestinationId = v})
            local y = -distance * math.sin(math.rad(angle))
            local xDistance = distance * math.cos(math.rad(angle)) - distanceScrolled
            Move({Id = v, DestinationId = object.Id, OffsetX = xDistance, OffsetY = y, Duration=scrollTime})

            UpdateVisiblity(screen, args, object, v, false)
        end
    end
end
local OnUpdate = function(screen, args, elapsed)
    local direction = 0
    if IsControlDown({ Name = "Up" }) or IsControlDown({ Name = "MenuUp" }) or IsControlDown({ Name = "Left" }) then
        direction = -1
    elseif IsControlDown({ Name = "Down" }) or IsControlDown({ Name = "MenuDown" }) or IsControlDown({ Name = "Right" }) then
        direction = 1
    end

    for k,guid in pairs(args) do
        local components = screen.Components
        local object = components[guid]
        if object == nil then
            DeregisterUpdateFunction(screen, guid)
            return
        end
        local instance = component_object_instance[object]
        local data = component_instance_data[instance]

        if data.args.Direction == "Vertical" then
            if IsControlDown({ Name = "Select" }) and GetUseTargetId({ }) == components[guid .. "UpArrow"].Id then
                direction = -1
            elseif  IsControlDown({ Name = "Select" }) and GetUseTargetId({ }) == components[guid .. "DownArrow"].Id then
                direction = 1
            end

            if direction ~= 0 then
                OnUpdateInternal(screen, object, elapsed, direction, true)
            end
        elseif data.args.Direction == "Horizontal" then
            if IsControlDown({ Name = "Select" }) and GetUseTargetId({ }) == components[guid .. "LeftArrow"].Id then
                direction = -1
            elseif  IsControlDown({ Name = "Select" }) and GetUseTargetId({ }) == components[guid .. "RightArrow"].Id then
                direction = 1
            end

            if direction ~= 0 then
                OnUpdateInternal(screen, object, elapsed, direction, false)
            end
        end


    end
end

local RegisterUpdateFunction = function(screen, guid)
    if not screen.UILibrary then
        screen.UILibrary = {UpdateFlag = {}}
    end
    screen.UILibrary.UpdateFlag[guid] = true

    if not screen.UpdateFunctionArgs then
        screen.UpdateFunctionArgs = {}
    end
    screen.UpdateFunctionArgs[guid] = guid

    screen.UpdateFunctionName = OnUpdate
end

local CalculateScrollSize = function(instance, data)
    local object = data.object
    local args = data.args

    local largestDistance = 0
    for k,v in pairs(args.Items) do
        local distance = GetDistance({Id = object.Id, DestinationId = v})
        local angle = GetAngleBetween({Id = object.Id, DestinationId = v})
        if args.Direction == "Vertical" then
            distance = -distance * math.sin(math.rad(angle))
        elseif args.Direction == "Horizontal" then
            distance = distance * math.cos(math.rad(angle))
        end
        distance = distance - (data.scrollFraction * data.ScrollSize)
        if distance > largestDistance then
            largestDistance = distance
        end
    end
    data.scrollFraction = 0
    data.ScrollSize = largestDistance

end

definition.Create = function(instance, data, screen)
    local components = screen.Components
    local args = data.args
    local guidKey = data.guid

    local component = CreateScreenComponent({
        Name = "BlankObstacle",
        Group=args.Group,
        X = args.X,
        Y = args.Y
    })
    components[guidKey] = component
    component.screen = screen
    data.scrollFraction = 0
    AttachLua({ Id = component.Id, Table = component })
    
    local scrollbarKey = guidKey .. "Scrollbar"
    local sliderKey = guidKey .. "Slider"

    if not args.Bar then
        args.Bar = {}
    end
    if not args.Arrows then
        args.Arrows = {}
    end

    
    if args.Direction == "Vertical" then
        local barY = args.Y + args.ViewHeight / 2
        local barScale = (args.ViewHeight / 2) / ((args.Bar.BarSize or 476) / 2)
    
        components[scrollbarKey] = CreateScreenComponent({
            Name = "BlankObstacle",
            Animation = args.Bar.BarAnimation or "PageScrollbar",
            X = args.X,
            Y = barY,
        })
        SetScaleY({Id = components[scrollbarKey].Id, Fraction=barScale})

        local upArrowKey = guidKey .. "UpArrow"
        components[upArrowKey] = CreateScreenComponent({
            Name = args.Arrows.UpArrowObject or "UILibraryButtonScrollingListUp",
            X = args.X,
            Y = args.Y - (args.Arrows.Offset or 40),
            Scale = args.Arrows.Scale or 1
        })
        SetScaleY({Id = components[upArrowKey].Id, Fraction=1})
        SetAlpha({Id = components[upArrowKey].Id, Fraction=1})

        local downArrowKey = guidKey .. "DownArrow"
        components[downArrowKey] = CreateScreenComponent({
            Name = args.Arrows.DownArrowObject or "UILibraryButtonScrollingListDown",
            X = args.X,
            Y = args.Y + args.ViewHeight + (args.Arrows.Offset or 40),
        })
        SetScaleY({Id = components[downArrowKey].Id, Fraction=1})
        SetAlpha({Id = components[upArrowKey].Id, Fraction=1})


        local largestDistance = 0
        for k,v in pairs(args.Items) do
            local dist = UpdateVisiblity(screen, args, component, v, true)
            if dist > largestDistance then
                largestDistance = dist
            end
        end

        data.ScrollSize = largestDistance
    elseif args.Direction == "Horizontal" then
        local barX = args.X + args.ViewWidth / 2
        local barScale = (args.ViewWidth / 2) / ((args.Bar.BarSize or 476) / 2)
    
        components[scrollbarKey] = CreateScreenComponent({
            Name = "BlankObstacle",
            Animation =args.Bar.BarAnimation or "PageScrollbar",
            Angle = 90,
            X = barX,
            Y = args.Y,
        })
        SetScaleY({Id = components[scrollbarKey].Id, Fraction=barScale})
        -- SetAnimation({Id = components[scrollbarKey].Id, Fraction=barScale})

        local leftArrowKey = guidKey .. "LeftArrow"
        components[leftArrowKey] = CreateScreenComponent({
            Name = args.Arrows.LeftArrowObject or "UILibraryButtonScrollingListLeft",
            X = args.X - (args.Arrows.Offset or 40),
            Y = args.Y,
        })
        SetScaleY({Id = components[leftArrowKey].Id, Fraction=1})
        SetAlpha({Id = components[leftArrowKey].Id, Fraction=1})

        local rightArrowKey = guidKey .. "RightArrow"
        components[rightArrowKey] = CreateScreenComponent({
            Name =  args.Arrows.RightArrowObject or "UILibraryButtonScrollingListRight",
            X = args.X + args.ViewWidth + (args.Arrows.Offset or 40),
            Y = args.Y,
        })
        SetScaleY({Id = components[rightArrowKey].Id, Fraction=1})
        SetAlpha({Id = components[rightArrowKey].Id,  Fraction=1})

        local largestDistance = 0
        for k,v in pairs(args.Items) do
            local dist = UpdateVisiblity(screen, args, component, v, false)
            if dist > largestDistance then
                largestDistance = dist
            end
        end

        data.ScrollSize = largestDistance
    end

    components[sliderKey] = CreateScreenComponent({
        Name = "BlankObstacle",
        Animation = args.Bar.SliderAnimation or "PageScrollbarSlider",
        X = args.X,
        Y = args.Y,
    })
    SetScale({Id = components[sliderKey].Id, Fraction=args.Bar.SliderScale or 1})

    RegisterUpdateFunction(screen, guidKey)

    return component
end

definition.RegisterItemId = function(instance, data, itemId)
    table.insert(data.args.Items, itemId)
    local object = data.object
    local args = data.args
    local screen = object.screen
    UpdateVisiblity(screen, args, object, itemId, args.Direction == "Vertical")

    CalculateScrollSize(instance, data)
end

definition.DeregisterItemId = function(instance, data, itemId)
    local t = {}
    local args = data.args
    for k,v in pairs(args.Items) do
        if v ~= itemId then
            t[k] = v
        end
    end

    args.Items = t
end

definition.Destroy = function(instance, data)
    local object = data.object
    local guidKey = data.guid
    local args = data.args
    local screen = object.screen
    local components = screen.Components

    local scrollbarKey = guidKey .. "Scrollbar"
    local sliderKey = guidKey .. "Slider"
    Destroy({Ids = {components[scrollbarKey].Id, components[sliderKey].Id}})

    if args.Direction == "Vertical" then
        local upArrowKey = guidKey .. "UpArrow"
        local downArrowKey = guidKey .. "DownArrow"
        Destroy({Ids = {components[upArrowKey].Id, components[downArrowKey].Id}})
    elseif args.Direction == "Horizontal" then
        local leftArrowKey = guidKey .. "LeftArrow"
        local rightArrowKey = guidKey .. "RightArrow"
        Destroy({Ids = {components[leftArrowKey].Id, components[rightArrowKey].Id}})
    end
    DeregisterUpdateFunction(screen, guidKey)
    Destroy({Id = object.Id})
    screen[guidKey] = nil
    component_instance_data[instance].object = nil
end

return definition