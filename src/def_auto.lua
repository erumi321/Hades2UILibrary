---@meta erumi321-UILibrary-auto
local public = {}
-- document whatever you made publicly available to other plugins here
-- use luaCATS annotations and give descriptions where appropriate
--  e.g. 
--	---@param a integer helpful description
--	---@param b string helpful description
--	---@return table c helpful description
--	function public.do_stuff(a, b) end

-------------Radio Buttons-------------

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
---@param key string The key to assign to the parent element of the radio buttons
---@param args RadioButtonCreateArgs Args of the button: takes X (int), Y (int), ScaleX (float), ScaleY (float), FontSize (int), Group (string), SpacingFunction (function), OnSelectedFunction (function), OnDeselectedFunction (function), Buttons (table). Buttons consists of a list of strings which is the label of each button
---@return table RadioButtonObject  Returns the object which is used to be passed to other RadioButton functions
function public.RadioButton.Create(screen, args) end

---@param RadioButtonObject table Any radio button returned by Create
---@return nil
function public.RadioButton.Destroy(RadioButtonObject) end

-------------Dropdown-------------

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
---@param args DropdownCreateArgs Args of the button: takes Placeholder (string), X (int), Y (int), ScaleX (float), ScaleY (float), DefaultIndex (number), FontSize (int), ItemFontSize (int), Group (string), OnSelectedFunction (function), Options (table). Options consists of a list of strings which is the label of each dropdown button
---@return table DropdownObject Returns the object which is used to be passed to other Dropdown functions
function public.Dropdown.Create(screen, args) end

---@param DropdownObject table The dropdown object to add the option to
---@param option string The value of the option to add
---@return nil
function public.Dropdown.AddOption(DropdownObject, option) end

---@param DropdownObject table The dropdown object to remove the option from
---@param option string|number The option to remove, if a string remove that value, if a number then remove the option at that index
---@return nil
function public.Dropdown.RemoveOption(DropdownObject, option) end

---@param DropdownObject table The Dropdown to destroy
---@return nil
function public.Dropdown.Destroy(DropdownObject) end

-------------Radial Menu-------------

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
---@param args RadialMenuCreateArgs Args of the menu, takes StartAngle (number), EndAngle (number) Radius (number), Radius (number), X (number), Y (number), Group (string), ScaleX (number), ScaleY (number), TooltipTextboxId (Id), ExpansionTime (number), OnSelectFunction (function), Options (option) 
---@return table RadialMenuObject Returns the object which is used to be passed to other RadialMenu functions
function public.RadialMenu.Create(screen, args) end


---@param RadialMenuObject table The RadialMenu to expand
---@return nil
function public.RadialMenu.Expand(RadialMenuObject) end

---@param RadialMenuObject table The RadialMenu to collapse
---@return nil
function public.RadialMenu.Collapse(RadialMenuObject) end

---@param RadialMenuObject table The RadialMenu to destroy
---@return nil
function public.RadialMenu.Destroy(RadialMenuObject) end

return public