# RadioButton.Create
```lua
RadioButton(screen, key, args)
```
Creates a RadioButton object and all its children components within the passed screen, nothing is selected on creation.

Returns the RadioButton object.

### Parameters
- `screen`: The screen which the Radio Button objects are created in
- `args`: The args of the RadioButton object, they are:
    - `X`: The X position of the first button
    - `Y`: The Y position of the first button
    - `Alignment`: The direction the buttons are moved in, takes `Horiztonal` and `Vertical`
    - `Group`: The group that all the components are created in
    - `ScaleX`: The X scale of the buttons
    - `ScaleY`: The Y scale of the buttons
    - `OnSelectedFunction`: The function that is called when a button is selected / pressed (see below)
    - `OnDeselectedFunction`: The function that is called when a button is selected and an old one was unselected because of it (see below)
    - `Buttons`: A list of strings of the values of each of the buttons, this is the text on the button and the value passed to `OnSelectedFunction` and `OnDeselectedFunction` 
    - `SpacingFunction`: The function that is called to determine the position of each button (see below)

### OnSelectedFunction
```lua
function radioSelected(RadioButtonObject, value)
```
Called when a button is selected by being pressed.
`value` is equal to the text on the button being selected which corresponds to the string in the `Buttons` list

### OnDeselectedFunction
```lua
function radioDeselected(RadioButtonObject, value)
```
Called when a button is deselected because another button is selected.
`value` is equal to the text on the button being deselected which corresponds to the string in the `Buttons` list

### SpacingFunction
```lua
function radioSpacingFunction(index)
    return x,y
end
```
If not nil then called for each button to determine location, `index` is the index of the button (1-based, first button has an index of 1, 2nd button has an index of 2, etc).
Returns two numbers, the first is the x-position of the button, the second is the y-position, if a number is nil then the default positioning is used, which is determined by `X`, `Y`, and `Alignment`

# RadioButton.Destroy
```lua
RadioButton.Destroy()
```
Destroys the RadioButton object and all its children components

# Example
```lua
function createMyRadioButton(screen)
    "myRadioButton" = UILib.RadioButton(screen, "myRadioButton", {
        X = 100,
        Y = 100,
        Group="Menu_UI_Inventory",
        Alignment="Horizontal",
        ScaleX = 1,
        ScaleY = 1,
        OnSelectedFunction = radioPressed,
        OnDeselectedFunction = radioUnselected,
        Buttons = {
            "A", --index = 1
            "B", -- index = 2
            "C", -- index = 3
            "D",
            "E",
            "F",
            "G" ,-- index = 7
            "H" -- index = 8
        },
        SpacingFunction = function(index)
            local mult = index
            if index >= 3 then
                mult = index + 1
            end
            if index >= 7 then
                mult = index + 2
            end
            local x = 100 + mult * 287
            local y = 100
            if index >= 5 then
                y = 200
                x = x - 1435 --wrap back around
            end
            return x, y
        end
    })
end

function radioPressed(RadioButtonObject, value)
	print("Selected: " .. value)
end
function radioUnselected(RadioButtonObject, value)
	print("Unselected: " .. value)
end
```