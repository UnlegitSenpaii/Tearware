-- tearware on top

-- universal constants
cfgstr = "savegame.mod.tearware_"
-- 0.01(6)
fixed_update_rate = 1/60
origin_to_eye_distance = 1.7
gameVersion = GetVersion()
registryEntryPoints = { "options", "game", "savegame", "level", "promo", "mods" }
colorSuffix = {"_red", "_green", "_blue", "_alpha", "_rainbow"}

-- {"Name that InputLastPressedKey() Outputs", "Default Value", "Capitalized Value"}
ghettoKeyMap = {
    {"A", "a", "A"},
    {"B", "b", "B"},
    {"C", "c", "C"},
    {"D", "d", "D"},
    {"E", "e", "E"},
    {"F", "f", "F"},
    {"G", "g", "G"},
    {"H", "h", "H"},
    {"I", "i", "I"},
    {"J", "j", "J"},
    {"K", "k", "K"},
    {"L", "l", "L"},
    {"M", "m", "M"},
    {"N", "n", "N"},
    {"O", "o", "O"},
    {"P", "p", "P"},
    {"Q", "q", "Q"},
    {"R", "r", "R"},
    {"S", "s", "S"},
    {"T", "t", "T"},
    {"U", "u", "U"},
    {"V", "v", "V"},
    {"W", "w", "W"},
    {"X", "x", "X"},
    {"Y", "y", "Y"},
    {"Z", "z", "Z"},
    {"1", "1", "!"},
    {"2", "2", "@"},
    {"3", "3", "#"},
    {"4", "4", "$"},
    {"5", "5", "%"},
    {"6", "6", "^"},
    {"7", "7", "&"},
    {"8", "8", "*"},
    {"9", "9", "("},
    {"0", "0", ")"}
}

-- other keyboard layouts? what's that 
-- {"Name that InputPressed Accepts", "Default Value", "Capitalized Value"}
keysNotInLastPressedKey = {
    {",", ",", "<"},
    {".", ".", ">"},
    {"-", "-", "_"},
    {"+", "=", "+"}
    -- figure these out, or if they even exist.
    --{"???", "`", "~"}
    --{"???", ";", ":"}
    --{"???", "/", "?"}
    --{"???", "[", "{"}
    --{"???", "]", "}"}
    --{"???", "\", "|"}
}

-- some keys are too long to be displayed in some places.
-- used by utils_ShortenKeyString
keyShort = {}
keyShort["pgdown"] = "pgd"
keyShort["pgup"] = "pgu"

keyShort["leftarrow"] = "<-"
keyShort["rightarrow"] = "->"
keyShort["uparrow"] = "/\\"
keyShort["downarrow"] = "\\/"

keyShort["home"] = "hom" -- hom.
keyShort["shift"] = "sh"
keyShort["delete"] = "del"
keyShort["backspace"] = "bsp"
keyShort["space"] = "spc"

-- temp values (reset to default on restart/level load/quick load)
openMenu = nil
featurelist = {}
filthyglobal_editingkeybind = " "
skipped_objective = false
valuablesBackup = {}
cached_fog_color = {}
cached_post_process = {}
cachedValuablesPositions = {}
active_sub_menu = nil
active_sub_menu_mode = "default"
overrideConfigValues = false
activeBodyCache = {}
noclipbackuppos = {}

funnyColorCopyCache = {}
funnyColorCopyCache.red = 1
funnyColorCopyCache.green = 1
funnyColorCopyCache.blue = 1
funnyColorCopyCache.alpha = 1
funnyColorCopyCache.rainbow = false

registryCache = {}
registryScrollPos = 0
lastRegistryInput = " "

ss_object = {}
ss_object.obj = nil 
ss_object.dist = nil
ss_last_tool = nil

resetDvd = {} 
resetDvd.width = 175 
resetDvd.height = 25
resetDvd.x = 0
resetDvd.y = 0
resetDvd.speedx = 100
resetDvd.speedy = 100

isScrollingRegistry = false
registryScrollingBaseOffset = 0
registrySelectedKey = {}
registrySelectedKey.key = ""
registrySelectedKey.value = ""

inputStringBackspaceTimer = 0

-- nil = override to string size / end of string
inputStringCursorPos = nil
inputStringCursorTimer = 0
inputStringCursorSwitchTimer = 0
inputStringDrawCursor = true

insaneObjectCache = {}

editingRegistrySearchString = false
registryVisibleCache = {}
registrySearchString = ""
modifiedregistrySearchString = false
lockInputs = false