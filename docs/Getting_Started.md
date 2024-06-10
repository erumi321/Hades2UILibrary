# Instantiation
In the `main.lua` file of your mod, put the following code before the function `on_ready` 
```lua
---@module 'erumi321-UILibrary-auto'
UILib = mods['erumi321-UILibrary'].auto()
```

# Using Components
In your main code files (e.g. `reload.lua`) prepend all UILibrary function calls with `UILib`, meaning all calls follow the pattern:
```
UILib.[component name].[function name](...)
```

All components and their functions are found here:
- [Radial Menus](RadialMenu.md)
- [Dropdowns](Dropdown.md)
- [Radio Buttons](RadioButton.md)
