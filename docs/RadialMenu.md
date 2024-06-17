# RadialMenu.Create
```lua
RadialMenu(screen, key, args)
```
Creates a RadialMenu object and all its children components within the passed screen, the RadialMenu is not expanded on creation.

Returns the RadialMenu object.

### Parameters
- `screen`: The screen which the Radial Menu is created in
- `args`: The args of the RadialMenu, they are:
    - `StartAngle`: The angle to set the first button at, in degrees and standard position (0 is directly left, 90 is directly up)
    - `EndAngle`: The angle to end at, in degrees and standard position, the last button is located at EndAngle, unless `(EndAngle-StartAngle) % 360 = 0` then the buttons are evenly distributed around a circle
    - `Radius`: The radius of the menu when expanded
    - `X`: The X position of the center of the menu
    - `Y`: The Y position of the center of the menu
    - `Group`: The group which all the components are a part of
    - `ScaleX`: The X scale of each component
    - `ScaleY`: The Y scale of each component
    - `TooltipTextboxId`: If not nil then the Textbox attached to this Id is set to the value of a button when the button is hovered
    - `ExpansionTime`: If 0 expansion / collapse is immediate, if not then expansion / collapse takes `ExpansionTime` seconds to finish
    - `OnSelectFunction`: When a button is selected, this function is called (see below)
    - `Options`: A list of the Options / Buttons created (see below)

### Options
Each option is a table in the form
```lua
    {
        Value = "Earth",
        Image = {
            Path = "Items\\Loot\\EssenceEarth",
            ScaleX = 0.5,
            ScaleY = 0.5,
        }
    }
```
- `Value`: The value passed to `OnSelectFunction` and the text displayed on the textbox at `TooltipTextboxId` when this is selected
- `Image` A table consisting of
    - `Path`: The path to the image, or the name of the animation, i.e `Items\\Loot\\EssenceEarth` can be replaced with `EarthEssenceDrop`
    - `ScaleX`: The X Scale of just the icon
    - `ScaleY`: The Y Scale of just the icon

### OnSelectFunction
This function is called whenever a Radial Menu's button is clicked, it is passed the RadialMenu object that was interacted with and the value of the button clicked:
```lua
function RadialSelected(RadialMenuObject, value)
```
`value` corresponds to the Value of the button as it was defined in the button's corresponding `Option`

# RadialMenu.Expand
```lua
RadialMenu.Expand()
```
Expands the Radial Menu's buttons, does nothing if the Radial Menu is already expanded. Instant if `ExpansionTime` is 0, otherwise takes `ExpansionTime` seconds to complete.

# RadialMenu.Collapse
```lua
RadialMenu.Collapse()
```
Collapses the Radial Menu's buttons, does nothing if the Radial Menu is already collapsed. Instant if `ExpansionTime` is 0, otherwise takes `ExpansionTime` seconds to complete.

# RadialMenu.Destroy
```lua
RadialMenu.Destroy()
```
Destroys the Radial Menu by destroying it and all its children objects.

# Example
```lua
function createMyRadialMenu(screen)
    local components = screen.Components
    local buttonKey = "RadialMenuText"
    components[buttonKey] = CreateScreenComponent({
        Name = "ButtonDefault",
        Group = "Menu_UI_Inventory",
        Scale = 0.8,
        X = 800,
        Y = 400
    })
    CreateTextBox({
        Id = components[buttonKey].Id,
        Text = "",
        FontSize = 20,
        OffsetX = -100,
        OffsetY = 0,
        Color = Color.White,
        Font = "P22UndergroundSCMedium",
        Group = "Menu_UI_Inventory",
        ShadowBlur = 0,
        ShadowColor = { 0, 0, 0, 1 },
        ShadowOffset = { 0, 2 },
        Justification = "Left",
    })

    local myRadialMenu = UILib.RadialMenu(screen, "myRadialMenu", {
        StartAngle = 0,
        EndAngle = 90,
        Radius = 200,
        X = 400,
        Y = 400,
        Group = "Menu_UI_Inventory",
        ScaleX = 1,
        ScaleY = 1,
        TooltipTextboxId = components[buttonKey].Id,
        ExpansionTime = 1,
        OnPressFunction = RadialSelected,
        Options = {
            {
                Value = "Earth",
                Image = {
                    Path = "EarthEssenceDrop",
                    ScaleX = 0.5,
                    ScaleY = 0.5,
                }
            },
            {
                Value = "Air",
                Image = {
                    Path = "Items\\Loot\\EssenceAir",
                    ScaleX = 0.5,
                    ScaleY = 0.5,
                }
            },
            {
                Value = "Fire",
                Image = {
                    Path = "Items\\Loot\\EssenceFire",
                    ScaleX = 0.5,
                    ScaleY = 0.5,
                }
            },
            {
                Value = "Water",
                Image = {
                    Path = "Items\\Loot\\EssenceWater",
                    ScaleX = 0.5,
                    ScaleY = 0.5,
                }
            }
        },
    })

    myRadialMenu.Expand()
end

function RadialSelected(RadialMenuObject, value)
	print("RADIAL: " .. value)
	RadialMenuObject.Collapse()
end
```