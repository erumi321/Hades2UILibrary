# ScrollingList.Create
```lua
ScrollingList(screen, key, args)
```
Creates a ScrollingList object and registers all the passed Ids to it.

Returns the ScrollingList object.

### Parameters
- `screen`: The screen which the Radial Menu is created in
- `key`: The key used to reference the object in `UILib.Instances`
- `args`: The args of the RadialMenu, they are:
    - `X`: The X position of the top left of the bounding box (see Bounding Box) and the X Position of the top of the scroll bar
    - `Y`: The Y position of the top left of the bounding box (see Bounding Box) and the Y Position of the top of the scroll bar
    - `Direction`: Requires `Horizontal` or `Vertical`, adjusts which direction the scrollbar scrolls in
    - `ViewWidth` / `ViewHeight`: The size of the bounding box (see Bounding Box)
        - ViewWidth is required if `Direction = "Horizontal"` 
        - ViewHeight is required if `Direction = "Vertical"`
    - `ScrollSpeed`: The speed of scrolling, units are pixels per second of continuous scrolling
    - `Items`: The Ids of the screen components to handle
    - `Arrows`: Args to override the look of the arrows next to the scrollbar (see Arrows Args)
    - `Bar`: Args to override the look of the scrollbar (see Scrollbar Args)

### Arrows Args
These are purely optional args to override the look of the default arrows, any may be nil and the defaults will be used. All Arrow Objects must be in `GUI.sjson` to function as an Obstacle
- `UpArrowObject`: Overrides the Arrow pointing up, only used when `Direction = "Vertical"`
- `DownArrowObject`: Overrides the Arrow pointing down, only used when `Direction = "Vertical"`
- `LeftArrowObject`: Overrides the Arrow pointing left, only used when `Direction = "Horizontal"`
- `RightArrowObject`: Overrides the Arrow pointing right, only used when `Direction = "Horizontal"`
- `Scale`: Scales all Arrows

### Bar Args
These are purely optional args to override the look of the default arrows, any may be nil and the defaults will be used. All Animations must be in `GUIAnimations.sjson` to function as an Animation
- `BarAnimation`: Overrides the Bar animation
- `SliderAnimation`: Overrides the animation for the slider knob on the bar
- `SliderScale`: Scales the slider
- `BarSize`: Necessary if `BarAnimation` is changed, if you want to use a custom image for the bar, then this must be equal to the height of the image of the bar in pixels and the image must be vertical. For reference of this look at the image in `GUI.pkg` at `GUI\Screens\ScrollbarDownUp` which is 476 pixels tall and so would require a `BarSize` of 476.

# ScrollingList.RegisterItemId
```lua
ScrollingList.RegisterItemId(itemId)
```
Registers the passed `itemId` to the scrolling list and updates its alpha and useability. Updates the scrollbar to allow scrolling to the new item if it is now the furthest item. \
The scrolling list registers the item at the position the scrolling list is, so if the scrolling list is scrolled all the way to the end, the item will be registered at the end of the scrolling list, not where it was originally in relation to other objects that are registered.

# ScrollingList.DeregisterItemId
```lua
ScrollingList.DeregisterItemId(itemId)
```
Deregisters the passed `itemId` from the scrolling list so it no longer handles its alpha, usability, or movement.\
**Registering and Deregistering is destructive in state**: When deregistering an object it will not return to its original position, alpha, or usability, which must handled by the modder on a case-by-case basis.

# ScrollingList.Destroy
```lua
ScrollingList.Destroy()
```
Destroys the scrolling list, the scrollbar, and arrows, registered components are not changed when this is performed. \
**Destroying is destructive in state**: When destroying a scrolling list the registered items will not return to their original position, alpha, or usability, which must handled by the modder on a case-by-case basis.

# Bounding Box
The bounding box of a ScrollingList is 2 bounding lines that are infinitely tall or wide.\
When `Direction = "Vertical"` each line is infinitely wide, and any item above the Y position of the scrolling list or below `Y + ViewHeight` is faded out and set to unseable after 50 pixels from the threshold. \
When `Direction = "Horizontal"` each line is infinitely tall, any item to the left of the X position of the scrolling list or the right of `X + ViewWidth` is faded out and set to unusable after 50 pixels from the threshold.

# Example Code
```lua
function createScrollingList(screen)
    local myScrollingList = UILib.ScrollingList(screen, "myScrollingList", {
			X = 250, Y = 100,
			Direction = "Vertical",
			ViewHeight = 375,
			ScrollSpeed = 300,
			Items = {}
		})
    for i = 1, 4 do
        myScrollingList.RegisterItemId(screen.Components["myKey" .. i])
    end
end
```