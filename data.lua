
--[[

  Hello!
  
  The data stage of this tutorial mod is going to demonstrate the following things:
    
    > Reading mod startup settings
    
    > Using simple functions to make repetitive code shorter
    
    > Using name prefixes to ensure compatibility with other mods
    
    > Creating an entity 
    
    > Creating an item to place the entity
    
    > Creating a recipe to craft the item
    
    > Conditionally Creating a technology to unlock the recipe
    
    > Bonus: Changing existing prototypes based on what other mods are installed

  Abbreviations used:
    
    > HCG = Hand Crank Generator
    
    > data "stage", settings "stage" = In factorio each "stage" of the startup process
        is divided into three "phases". I.e. the data stage consists of data.lua,
        data-updates.lua and data-final-fixes.lua. This mod does not use updates or 
        final-fixes.
    
  ]]

local function config(name)
    return settings.startup['px:rs-'..name].value
    end
  
  local function sprite(name)
    return '__resourceScanner_0.0.1__/assets/'..name
    end
    
  local function sound(name)
    return '__resourceScanner_0.0.1__/assets/'..name
    end
  
   
  
  -- To add new prototypes to the game I descripe each prototype in a table.
  -- Then each of these tables is put together into one large table, and that large
  -- table is handed to data:extend() which will put it into data.raw where
  -- the game engine can find them.
  
  data:extend({
  
  
    -- This is the hotkey that will later be used.
    {
      type                = 'custom-input'    ,
      name                = 'px:rs-scan',
      
      -- I "link" this hotkey to a vanilla hotkey, so that
      -- the player does not have to remember an extra hotkey.
      -- Linked hotkeys must define an empty key_sequence.
      linked_game_control = 'rotate'          ,
      key_sequence        = ''                ,
      
      -- Here I could block other mods or even vanilla from
      -- using the same hotkey, but as i'm linking to another
      -- hotkey i'm not doing that. Assigning "nil" in lua
      -- deletes the value, so this line has the same effect as
      -- writing nothing at all.
      consuming           =  nil              , 
  
      -- Properties that have a known default value do not have to be
      -- specified. The engine will automatically assign the
      -- default value at the end of the data stage automatically.
  
      -- For reference these are the possible values for "consuming":
  
      -- 'none'       : Default if not defined.
      -- 'game-only'  : The opposite of script-only. Blocks game inputs using the
      --                same key sequence but lets other custom inputs using the
      --                same key sequence fire.
      },
    
    
    -- This is the item that is used to place the entity on the map.
    {
      type = 'item',
      name = 'px:rs-item',
      
      -- In lua any function that is called with exactly one argument
      -- can be written without () brackets if the argument is a string or table.
      
      -- here we call sprite() which will return the full path:
      -- '__eradicators-hand-crank-generator__/sprite/hcg-item.png'
      
      icon      =  sprite 'remote.png',
      icon_size =  32     ,
      subgroup  = 'tool',
      order     = 'z'     ,
      
      -- This is the name of the entity to be placed.
      -- For convenience the item, recipe and entity
      -- often have the same name, but this is not required.
      -- For demonstration purposes I will use explicit
      -- names here.
      place_result = 'px:rs-entity',
      stack_size   =  50            ,
      },
  
    })
    
  
    
  -- The next step is slightly more complicated. According to the "lore" of this
  -- mod the player only gets a single HCG. But because some people might want
  -- more than one there is a "mod setting" that enables a technology and recipe.
  
  -- So I have to read the setting and only create the technology and recipe prototypes
  -- if the setting is enabled.
  data:extend({
    {
      type = "recipe",
      name = "px:rs-recipe",
      energy_required = 1,
      enabled = false,
      ingredients = {
        { type = "item", name = "steel-plate", amount = 1 },
      },
      results = { { type = "item", name = "px:rs-item", amount = 1 } }
    },
     -- This is the technology that will unlock the recipe.
    {
      name = 'er:hcg-technology',
      type = 'technology',
      
      -- Technology icons are quite large, so it is important
      -- to specify the size. As all icons are squares this is only one number.
      icon = sprite 'hcg-technology.png',
      icon_size = 128,
      
      -- Like recipes, technologies can also have normal and expensive difficulty.
      -- In mods where both difficulties should have the same recipe there are two
      -- possible ways to specify this. One is to only specify normal= and leave
      -- out expensive=. The more commonly used way is to put all properties that would
      -- go into the normal= subtable directly into the main prototype. I demonstrate
      -- this approach here by commenting out the normal= sub-table construction [1].
      -- This is also the way that most vanilla recipes and technologies are specified.
      
      -- normal = { -- [1] put parameters directly into prototype
        
        -- Deciding when a recipe becomes available is an important balancing decision.
        prerequisites = {"electric-energy-distribution-1"},
        
        effects = {
          { type   = 'unlock-recipe',
            recipe = 'er:hcg-recipe'
            },
            
          -- The "nothing" effect is used to implement research effects
          -- that the engine does not support directly. It places a marker
          -- with a description in the technology menu so that the player
          -- knows what is going to happen. The actual effect has to be implemented
          -- by the mod in control stage.
          { type = 'nothing',
            effect_description = {'er:hcg.auto-cranking'},
            },
            
          },

        unit = {
          count = 150,
          ingredients = {
            {"automation-science-pack", 1},
            {"logistic-science-pack"  , 1},
            },
          time = 30,
          },
          
        -- }, -- [1] put parameters directly into prototype
      
      order = "c-e-b2",
      },
  })