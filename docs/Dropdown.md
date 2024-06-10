# Dropdown.Create
```lua
Dropdown.Create(screen, args)
```
Creates a Dropdown object and all its children components within the passed screen, the Dropdown is not expanded on creation.

Returns the Dropdown object to be used in other functions.

### Parameters
- `screen`: The screen which the Dropdown objects are created in
- `args`: The args of the Dropdown object which are:
    - `Placeholder`: The default text in the dropdown when nothing is selected (not used if `DefaultIndex` is not nil)
    - `X`: The X position of the dropdown
    - `Y`: The Y position of the dropdown
    - `Group`: The group each of the components is created in
    - `ScaleX`: The X Scale of the dropdown and its buttons
    - `ScaleY`: The Y Scale of the dropdown and its buttons
    - `FontSize`: The fontsize of the text on the dropdown
    - `ItemFontSize`: The fontsize of the text on each of the dropdown's buttons
    - `DefaultIndex`: If not nil then replaces `Placeholder` with the value of the option at this index (1-based)
    - `Options`: A list of strings of the text in each dropdown option and the value to pass to `OnSelectedFunction`  
    - `OnSelectedFunction`: The function that is called when an option is selected (see below)

### OnSelectedFunction
```lua
function dropdownPressed(DropdownObject, value)
	return true/false
end
```
`value` is the same as the text on the button pressed.
If this returns a truthy value then the Dropdown's text is updated to be equal to `value` when this is called.

# Dropdown.AddOption
```lua
Dropdown.AddOption(DropdownObject, option)
```
Adds `option` to the list of `Options` within the passed `DropdownObject`, if the Dropdown is expanded then the button is automatically added visually.

# Dropdown.RemoveOption
```lua
Dropdown.RemoveOption(DropdownObject, option)
```
If `option` is a string then that option is searched for and removed from `DropdownObject`'s `Options`.
If `option` is a number then the option at that index is removed from `DropdownObject`'s `Options`.

# Dropdown.Destroy
```lua
Dropdown.Destroy(DropdownObject)
```
Destroys the `DropdownObject` and all its children objects

# Example
```lua
function createMyDropdown(screen)
    local components = screen.Components
    components["DropdownTest"] = UILib.Dropdown.Create(screen, {
        Placeholder = "Dropdown",
        X = 400,
        Y = 100,
        Group="Menu_UI_Inventory",
        ScaleX = 1,
        ScaleY = 1,
        FontSize = 24,
        ItemFontSize = 20,
        DefaultIndex = 1,
        Options = {
            "A",
            "B",
            "C", 
            "D",
            "E",
            "F",
            "G"
        },
        OnSelectedFunction = dropdownPressed,
    })
end
function dropdownPressed(DropdownObject, value)
    print(value)
	return true
end
```