---@meta _
-- grabbing our dependencies,
-- these funky (---@) comments are just there
--	 to help VS Code find the definitions of things

---@diagnostic disable-next-line: undefined-global
local mods = rom.mods

---@module 'SGG_Modding-ENVY-auto'
envy = mods['SGG_Modding-ENVY']
envy.auto()
-- ^ this gives us `public` and `import`, among others
--	and makes all globals we define private to this plugin.
---@diagnostic disable: lowercase-global

---@diagnostic disable-next-line: undefined-global
rom = rom
---@diagnostic disable-next-line: undefined-global
_PLUGIN = _PLUGIN

-- get definitions for the game's globals
---@module 'game'
game = rom.game
---@module 'game-import'
import_as_fallback(game)

---@module 'SGG_Modding-SJSON'
sjson = mods['SGG_Modding-SJSON']
---@module 'SGG_Modding-ModUtil'
modutil = mods['SGG_Modding-ModUtil']

---@module 'SGG_Modding-ReLoad'
reload = mods['SGG_Modding-ReLoad']

local components_path = rom.path.combine(_PLUGIN.plugins_mod_folder_path,'Components')

component_class_data = setmetatable({},{__mode = 'k'})
component_instance_data = setmetatable({},{__mode = 'k'})
component_object_instance = setmetatable({},{__mode = 'k'})
global_active_instances = setmetatable({},{__mode = 'k'})

local component_class_meta = {
	__call = function(s,...)
		return s.Create(...)
	end,
	__newindex = function(s)
		error('component classes should not be modified',2)
	end
}

public.Components = {}

local per_plugin_key_index = {}

local function generate_guid_key(env)
	local guid = env._PLUGIN.guid
	local keyi = per_plugin_key_index[guid] or 0
	keyi = keyi + 1
	per_plugin_key_index[guid] = keyi

	-- this should be completely unique global ID for a screen object
    local guidKey = _PLUGIN.guid .. '|' .. guid .. '|' ..  tostring(keyi)
	return guidKey
end

local function define_component_class(name, component_definition)
	local constructor = component_definition.Create
	local methods = {}
	for k,v in pairs(component_definition) do
		if k ~= 'Create' then
			methods[k] = v
		end
	end
	
	local component_class = {}
	local data = {}
	component_class_data[component_class] = data
	
	local endowed_constructor = function(env, screen, component_key, args, ...)
		if global_active_instances[env][screen.Name][component_key] then
			global_active_instances[env][screen.Name][component_key].Destroy()
			global_active_instances[env][screen.Name][component_key] = nil
		end

		local key = generate_guid_key(env)
		local component_instance = {}
		local instance_data = { guid = key, class = component_class, args=args }

		component_instance_data[component_instance] = instance_data

		local inner_component = constructor(component_instance, instance_data, screen, ...)
		component_object_instance[inner_component] = component_instance
		instance_data.object = inner_component

		for k,v in pairs(methods) do
			component_instance[k] = function(...)
				return v(component_instance, instance_data, ...)
			end
		end
		screen.Components[key] = inner_component
		global_active_instances[env][screen.Name][component_key] = component_instance

		return component_instance
	end

	data.name = name
	data.create = endowed_constructor
	data.methods = methods

	component_class.Create = endowed_constructor
	for k,v in pairs(methods) do
		component_class[k] = v
	end
	
	setmetatable(component_class,component_class_meta)

	public.Components[name] = component_class
	return component_class
end

local function define_components()
	for _, path in ipairs(rom.path.get_files(components_path)) do 
		local name = rom.path.stem(path)
		local filename = rom.path.filename(path)
		define_component_class(name, import("Components/" .. filename))
	end
end

function GetInstanceAndDataByGUID(guid)
	for instance,data in pairs(component_instance_data) do
		if data.guid == guid then
			return instance, data
		end
	end
end

local function on_ready()
	-- what to do when we are ready, but not re-do on reload.
	
	import 'ready.lua'
end

local function on_reload()
	-- what to do when we are ready, but also again on every reload.
	-- only do things that are safe to run over and over.
	
	import 'reload.lua'
end

define_components()

function public.auto()
	local binds = {}
	local env = envy.getfenv(2)
	for name, class in pairs(public.Components) do
		local bind = {}
		for k,v in pairs(class) do
			bind[k] = v
		end
		bind.Create = function(...)
			return class.Create(env, ...)
		end
		binds[name] = setmetatable(bind,component_class_meta)
	end

    local instances = global_active_instances[env]
    if instances == nil then
      instances = {}
      global_active_instances[env] = instances
    end
    binds.Instances = instances 

	return binds
end

-- this allows us to limit certain functions to not be reloaded.
local loader = reload.auto_single()

-- this runs only when modutil and the game's lua is ready
modutil.once_loaded.game(function()
	loader.load(on_ready, on_reload)
end)