# Instantiation
In the `main.lua` file of your mod, put the following code before the line `local function on_ready()` 
```lua
---@module 'erumi321-UILibrary-auto'
UILib = mods['erumi321-UILibrary'].auto()
```

In the `manifest.json` file of your mod, in `dependencies` add the line
```
"erumi321-UILibrary-0.2.0"
```

In the `thunderstore.toml` file of your mod, underneath `[package.dependencies]` add the line
```
erumi321-UILibrary = "0.2.0"
```

# Creating Components
Because of the class system, you **cannot store the returned object in `screen` or `screen.Components`**.

Each constructor of a component is called by using just their class name in the form: (replacing `[component name]` with the correct component)
```lua
local myComponent = UILib.[component name](screen, key, args)
--i.e local myComponent = UILib.Dropdown(screen, key, args)
```

If another component has the same `key`, that old component is destroyed. 

# Refrencing Created Components
The UI Library handles storing all created obstacles (which are called instances). To get one of these created instances, use `UILib.Instances` in the form:
```lua
UILib.Instances[screen name][instance key]
```
where screen name is the `Name` field of the Screen in which you created the component, and instance key is the `key` passed into the constructor when creating the component.

# Calling Component Methods
Since each component is a class-like structure, each of its methods are called like a class in this form: (replacing `[component name]` and `[method name]` with the correct component and method respectively)
```lua
local myComponent = UILib.[component name](screen, key, args)
myComponent.[method name](arg1, arg2, arg3, ...)
--[[i.e
    local myComponent = UILib.Dropdown(screen, key, args)
    myComponent.AddOption("A")
]]--
```

# Destroying Components
All UILibrary components within a screen are automatically destroyed when the screen closes. Otherwise call
```lua
    myComponent.Destroy()
```

All components and their functions are found here:
- [Radial Menus](RadialMenu.md)
- [Dropdowns](Dropdown.md)
- [Radio Buttons](RadioButton.md)
- [Scrolling Lists](ScrollingList.md)
