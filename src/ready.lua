---@meta _
-- globals we define are private to our plugin!
---@diagnostic disable: lowercase-global

-- here is where your mod sets up all the things it will do.
-- this file will not be reloaded if it changes during gameplay
-- 	so you will most likely want to have it reference
--	values and functions later defined in `reload.lua`.

rom.game.ErumiUILib = {
	RadioButton = {}
}

local guiPath = rom.path.combine(rom.paths.Content, 'Game/Obstacles/GUI.sjson')
local guiAnimPath = rom.path.combine(rom.paths.Content, 'Game/Animations/GUIAnimations.sjson')

sjson.hook(guiAnimPath, function(data)
	return sjson_RadialIcon(data)
end)

sjson.hook(guiPath, function(data)
	return sjson_RadialObstacle(data)
end)

function sjson_RadialObstacle(data)
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


function sjson_RadialIcon(data)
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