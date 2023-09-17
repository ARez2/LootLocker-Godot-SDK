extends Node

# Core constants
static var SDK_VERSION : String = "a0.01"
static var SDK_LOOTLOCKER_COMPATIBILITY : String = "0"
static var SDK_GODOT_COMPATIBILITY : String = "4.2"
static var SDK_COMPATIBILITY : Array = ["a0.01"]

static var USER_AGENT : String = "LootLocker SDK/" + SDK_VERSION + " (" + OS.get_name() + "; " + Engine.get_architecture_name() + " Godot " + Engine.get_version_info()["string"] + ")"

static var LOOTLOCKER_API_BASE_URL : String= "https://api.lootlocker.io/"

# Guest
static var GUEST_LOGIN_URL : String = LOOTLOCKER_API_BASE_URL + "game/v2/session/guest"
static var END_SESSION_URL : String = LOOTLOCKER_API_BASE_URL + "game/v1/session"

# White Label
static var WHITE_LABEL_URLPART : String = "white-label-login/"
static var WL_SIGNUP_URL : String = LOOTLOCKER_API_BASE_URL + WHITE_LABEL_URLPART + "sign-up"
static var WL_SIGNIN_URL : String = LOOTLOCKER_API_BASE_URL + WHITE_LABEL_URLPART + "login"
static var WL_SIGNOUT_URL : String = LOOTLOCKER_API_BASE_URL + WHITE_LABEL_URLPART + "session"
static var WL_SIGN_VERIF_SESSION_URL : String = LOOTLOCKER_API_BASE_URL + WHITE_LABEL_URLPART + "verify-session"
static var WL_REQ_VERIFICATION_URL : String = LOOTLOCKER_API_BASE_URL + WHITE_LABEL_URLPART + "request-verification"
static var WL_REQ_PASSWORDRESET_URL : String = LOOTLOCKER_API_BASE_URL + WHITE_LABEL_URLPART + "request-reset-password"

# Leaderboards
#maybe use placeholder for lid
static var LEADERBOARDS_URL = LOOTLOCKER_API_BASE_URL + "game/leaderboards/"
static var LEADERBOARDS_LIST_EP_URL = "/list"
static var LEADERBOARDS_COUNT_EP_URL = "count"
static var LEADERBOARDS_AFTER_EP_URL = "after"
static var LEADERBOARDS_SUBMITSCORE_EP_URL = "/submit"
static var LEADERBOARDS_MEMBER_EP_URL = "/member"

# Player
static var PLAYERID_FILEPATH_BEGIN = "user://player_" #player_id.data
static var PLAYERID_FILEPATH_END = ".data"

static var PLAYER_URL = LOOTLOCKER_API_BASE_URL + "game/player/"
static var PLAYER_INFO_URL = PLAYER_URL + "info"
static var PLAYER_NAME_URL = PLAYER_URL + "name"
static var PLAYER_LOOKUP_URL = PLAYER_URL + "lookup"
static var PLAYER_DELETE_URL = PLAYER_URL	#without trailling / check if it's work with it or not

# Misc stuff
static var PING_URL = LOOTLOCKER_API_BASE_URL+"game/ping"


