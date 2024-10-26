---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

modutil.mod.Path.Wrap("OnScreenCloseStarted", function(baseFunc, screen, args)

	for envk,env in pairs(global_active_instances) do
		for key, instance in pairs(env[screen.Name]) do
			instance.Destroy()
			global_active_instances[envk][screen.Name][key] = nil
		end
		global_active_instances[envk][screen.Name] = nil
	end

	return baseFunc( screen, args)
end)
modutil.mod.Path.Wrap("OnScreenOpened", function(baseFunc, screen, args)
	for env, _ in pairs(global_active_instances) do
		global_active_instances[env][screen.Name] = {}
	end
	return baseFunc( screen, args)
end)

local guiPath = rom.path.combine(rom.paths.Content, 'Game/Obstacles/GUI.sjson')
local guiAnimPath = rom.path.combine(rom.paths.Content, 'Game/Animations/GUI_Screens_VFX.sjson')

---Radial Menus---
sjson.hook(guiAnimPath, function(data)
	return sjson_RadialMenuIcon(data)
end)

sjson.hook(guiPath, function(data)
	return sjson_RadialMenuObstacle(data)
end)

function sjson_RadialMenuObstacle(data)
    table.insert(data.Obstacles, {
        Name = "RadialSelectorIcon",
        InheritFrom = "1_BaseGUIObstacle",
        DisplayInEditor = false,
        Thing =
        {
            EditorOutlineDrawBounds = false,
            Interact =
            {
                CursorOnly = true,
                UseExtents = true
            },
        }
    })
end

function sjson_RadialMenuIcon(data)
    table.insert(data.Animations, {
        Name = "RadialArrow",
        FilePath = "GUI\\Shell\\OptionSelectorIcon",
        Material = "Unlit",
        OffsetX = 0,
        StartScale = 0.501,
        EndScale = 0.5
    })

	table.insert(data.Animations, {
        Name = "RadialArrowBright",
        FilePath = "GUI\\Shell\\OptionSelectorIcon",
        Material = "Unlit",
        OffsetX = 0,
        StartScale = 0.501,
        EndScale = 0.5,
		AddColor = true,
		Color = {Red = 0.3, Blue = 0.3, Green = 0.3}
    })
end

---Scrolling Lists---
sjson.hook(guiPath, function(data)
    return sjson_ScrollingListObstacles(data)
end)
sjson.hook(guiAnimPath, function(data)
    return sjson_ScrollingListAnimations(data)
end)

function sjson_ScrollingListObstacles(data)
    table.insert(data.Obstacles, {
        Name = "UILibraryButtonScrollingListUp",
        InheritFrom = "BaseInteractableButton",
        DisplayInEditor = true,
        Thing =
        {
          EditorOutlineDrawBounds = false,
          Graphic = "UILibraryButtonScrollingList_Up",
          Interact =
          {
            AutoActivateWithGamepad = true,
            DisabledUseSound = "/Leftovers/SFX/OutOfAmmo",
            HighlightOffAnimation = "UILibraryButtonScrollingList_Up",
            HighlightOnAnimation = "UILibraryButtonScrollingList_Up_Highlight",
          }
        }
      })
  
      table.insert(data.Obstacles, {
        Name = "UILibraryButtonScrollingListLeft",
        InheritFrom = "BaseInteractableButton",
        DisplayInEditor = true,
        Thing =
        {
          EditorOutlineDrawBounds = false,
          Graphic = "UILibraryButtonScrollingList_Left",
          Interact =
          {
            FreeFormSelectable = false,
            DisabledUseSound = "/Leftovers/SFX/OutOfAmmo",
            HighlightOffAnimation = "UILibraryButtonScrollingList_Left",
            HighlightOnAnimation = "UILibraryButtonScrollingList_Left_Highlight",
          }
        }
      })
  
      table.insert(data.Obstacles, {
        Name = "UILibraryButtonScrollingListRight",
        InheritFrom = "BaseInteractableButton",
        DisplayInEditor = true,
        Thing =
        {
          EditorOutlineDrawBounds = false,
          Graphic = "UILibraryButtonScrollingList_Right",
          Interact =
          {
            FreeFormSelectable = false,
            DisabledUseSound = "/Leftovers/SFX/OutOfAmmo",
            HighlightOffAnimation = "UILibraryButtonScrollingList_Right",
            HighlightOnAnimation = "UILibraryButtonScrollingList_Right_Highlight",
          }
        }
      })
  
      table.insert(data.Obstacles, {
        Name = "UILibraryButtonScrollingListDown",
        InheritFrom = "BaseInteractableButton",
        DisplayInEditor = true,
        Thing =
        {
          EditorOutlineDrawBounds = false,
          Graphic = "UILibraryButtonScrollingList_Down",
          Interact =
          {
            AutoActivateWithGamepad = true,
            DisabledUseSound = "/Leftovers/SFX/OutOfAmmo",
            HighlightOffAnimation = "UILibraryButtonScrollingList_Down",
            HighlightOnAnimation = "UILibraryButtonScrollingList_Down_Highlight",
          }
        }
      })
end

function sjson_ScrollingListAnimations(data)
    table.insert(data.Animations, {
        Name = "UILibraryButtonScrollingList_Down",
        FilePath = "GUI\\Screens\\ScrollArrow_Down",
        HoldLastFrame = false,
        Loop = true,
        Scale = 0.9,
        Material = "Unlit",
        Duration = 1,
        StartScale = 1.03,
        EndScale = 0.97,
        EaseIn = 0.9,
        EaseOut = 1.0,
        AddColor = true,
        StartRed = 0.3,
        StartGreen = 0.2,
        StartBlue = 0.1,
        EndRed = 0 ,
        EndGreen = 0,
        EndBlue = 0,
        StartOffsetY = 0,
        EndOffsetY = 3,
        PingPongShiftOverDuration = true,
      })
      table.insert(data.Animations, {
        Name = "UILibraryButtonScrollingList_Down_Highlight",
        FilePath = "GUI\\Screens\\ScrollArrow_Down",
        HoldLastFrame = true,
        DurationFrames = 6,
        Scale = 0.9,
        StartOffsetY = 3,
        EndOffsetY = 6,
        EaseIn = 0.9,
        EaseOut = 1.0,
        Material = "Unlit",
        Value = 0.2,
        Sound = "/SFX/Menu Sounds/DialoguePanelOut",
      })
      table.insert(data.Animations, {
        Name = "UILibraryButtonScrollingList_Up",
        InheritFrom = "UILibraryButtonScrollingList_Down",
        FilePath = "GUI\\Screens\\ScrollArrow_Up",
        EndOffsetY = -3,
      })

      table.insert(data.Animations, {
        Name = "UILibraryButtonScrollingList_Up_Highlight",
        InheritFrom = "UILibraryButtonScrollingList_Down_Highlight",
        FilePath = "GUI\\Screens\\ScrollArrow_Up",
        StartOffsetY = -3,
        EndOffsetY = -6,
      })
      table.insert(data.Animations, {
        Name = "UILibraryButtonScrollingList_Right",
        InheritFrom = "UILibraryButtonScrollingList_Down",
        Angle = 90,
        EndOffsetY = 0,
        StartOffsetX = 0,
        EndOffsetX = 3
      })
      table.insert(data.Animations, {
        Name = "UILibraryButtonScrollingList_Right_Highlight",
        InheritFrom = "UILibraryButtonScrollingList_Down_Highlight",
        Angle = 90,
        StartOffsetY = 0,
        EndOffsetY = 0,
        StartOffsetX = 3,
        EndOffsetX = 6
      })
      table.insert(data.Animations, {
        Name = "UILibraryButtonScrollingList_Left",
        InheritFrom = "UILibraryButtonScrollingList_Up",
        Angle = 90,
        EndOffsetY = 0,
        StartOffsetX = 0,
        EndOffsetX = -3
      })
      table.insert(data.Animations, {
        Name = "UILibraryButtonScrollingList_Left_Highlight",
        InheritFrom = "UILibraryButtonScrollingList_Up_Highlight",
        Angle = 90,
        StartOffsetY = 0,
        EndOffsetY = 0,
        StartOffsetX = -3,
        EndOffsetX = -6
      })
end