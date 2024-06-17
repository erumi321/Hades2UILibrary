---@meta erumi321-UILibrary-auto
local public = {}
-- document whatever you made publicly available to other plugins here
-- use luaCATS annotations and give descriptions where appropriate
--  e.g. 
--	---@param a integer helpful description
--	---@param b string helpful description
--	---@return table c helpful description
--	function public.do_stuff(a, b) end

-- https://discord.com/channels/667753182608359424/1237738649484005469/1250904769162117140

-------------Radio Buttons-------------

---@class (exact) RadioButtonObject
---@field public Destroy fun(): nil Destroys the RadioButton

---@class RadioButtonCreateArgs
---@field X number
---@field Y number
---@field ScaleX? number
---@field ScaleY? number
---@field FontSize? number
---@field Group string
---@field OnSelectedFunction? function
---@field OnDeselectedFunction? function
---@field Buttons table<number, string>
---@field SpacingFunction? function

---@param screen table The screen to assign all created objects too
---@param key string The key used to refrence the component in UILib.Instances
---@param args RadioButtonCreateArgs Args of the button: takes X (int), Y (int), ScaleX (float), ScaleY (float), FontSize (int), Group (string), SpacingFunction (function), OnSelectedFunction (function), OnDeselectedFunction (function), Buttons (table). Buttons consists of a list of strings which is the label of each button
---@return table RadioButtonObject  Returns the object which is used to call other RadioButton functions. **DO NOT ASSIGN THIS TO `screen` OR `screen.Components`**
function public.RadioButton(screen, key, args) end

-------------Dropdown-------------

---@class (exact) DropdownObject
---@field public AddOption fun(option: string): nil Adds `option` to Dropdown's options <br>   -`option`: The option value to add
---@field public RemoveOption fun(option: string): nil Removes `option` from Dropdown's options <br> -`option`: Removes the option that has the value of `option`
---@field public Destroy fun(): nil Destroys the DropdownObject

---@class DropdownCreateArgs
---@field Placeholder string
---@field X number
---@field Y number
---@field ScaleX? number
---@field ScaleY? number
---@field FontSize? number
---@field ItemFontSize? number
---@field Group string
---@field OnSelectedFunction? function
---@field DefaultIndex? number
---@field Options table<number, string>

---@param screen table The screen to assign all created objects too
---@param key string The key used to refrence the component in UILib.Instances
---@param args DropdownCreateArgs Args of the button: takes Placeholder (string), X (int), Y (int), ScaleX (float), ScaleY (float), DefaultIndex (number), FontSize (int), ItemFontSize (int), Group (string), OnSelectedFunction (function), Options (table). Options consists of a list of strings which is the label of each dropdown button
---@return DropdownObject DropdownObject Returns the object which is used call other Dropdown functions. **DO NOT ASSIGN THIS TO `screen` OR `screen.Components`**
function public.Dropdown(screen, key, args) end

-------------Radial Menu-------------

---@class (exact) RadialMenuObject
---@field public Expand fun(): nil Expands the RadialMenu
---@field public Collapse fun(): nil Collapses the RadialMenu
---@field public Destroy fun(): nil Destroys the RadialMenu

---@class RadialMenuOptionImage
---@field Path string
---@field ScaleX? number
---@field ScaleY? number

---@class RadialMenuOption
---@field Value string
---@field Image RadialMenuOptionImage

---@class RadialMenuCreateArgs
---@field StartAngle number
---@field EndAngle number
---@field Radius number
---@field X number
---@field Y number
---@field Group string
---@field ScaleX? number
---@field ScaleY? number
---@field TooltipTextboxId? number
---@field ExpansionTime? number
---@field OnSelectFunction? function
---@field Options table<number, RadialMenuOption>

---@param screen table The screen to assign all created objects too
---@param key string The key used to refrence the component in UILib.Instances
---@param args RadialMenuCreateArgs Args of the menu, takes StartAngle (number), EndAngle (number) Radius (number), Radius (number), X (number), Y (number), Group (string), ScaleX (number), ScaleY (number), TooltipTextboxId (Id), ExpansionTime (number), OnSelectFunction (function), Options (option) 
---@return RadialMenuObject RadialMenuObject Returns the object which is used to call other RadialMenu functions. **DO NOT ASSIGN THIS TO `screen` OR `screen.Components`**
function public.RadialMenu(screen, key, args) end


-------------Scrolling Lists-------------
---@class (exact) ScrollingListObject
---@field public RegisterItemId fun(itemId): nil Registers `itemId` to the ScrollingList so it handles movement and alpha <br> -`itemId`: The id of the screen component to register
---@field public DeregisterItemId fun(itemId): nil Deregisters `itemId` from the ScrollingList so it stops handling movement and alpha <br> -`itemId`: The id of the screen component to deregister
---@field public Destroy fun(): nil Destroys the ScrollingList


---@alias ScrollingListDirection "Vertical" | "Horizontal"

---@class ScrollingListBarArgs
---@field BarSize? number
---@field BarAnimation? string
---@field SliderAnimation? string
---@field SliderScale? number

---@class ScrollingListArrowArgs
---@field UpArrowObject? string
---@field LeftArrowObject? string
---@field RightArrowObject? string
---@field DownArrowObject? string
---@field Scale? number

---@class ScrollingListCreateArgs
---@field X number
---@field Y number
---@field Direction ScrollingListDirection
---@field ViewWidth? number
---@field ViewHeight? number
---@field ScrollSpeed number
---@field Bar? ScrollingListBarArgs
---@field Arrows? ScrollingListArrowArgs
---@field Items table<number, number>

---@param screen table The screen to assign all created objects too
---@param key string The key used to refrence the component in UILib.Instances
---@param args ScrollingListCreateArgs Args of the list container, takes X (number), Y (number), Direction (Direction), ViewWidth/ViewHeight (number), ScrollSpeed (number), Bar (Bar Arg), Arrows (Arrows Args), Items (table)
---@return ScrollingListObject ScrollingListObject Returns the object which is used to call other ScrollingList functions. **DO NOT ASSIGN THIS TO `screen` OR `screen.Components`**
function public.ScrollingList(screen, key, args) end

return public