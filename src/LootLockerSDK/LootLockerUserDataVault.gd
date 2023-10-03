extends Node
class_name LootLockerDataVault

# allow to specify also files (later ?)
# need a setting for GAMEKEY
const SDKDATA_FILEPATH : String = "user://LootLockerSDK.cfg"
const PASSWORD_FILEPATH : String = "user://.sdk_data_password"

const DEFAULT_PASSWORD : String = "NOTSETYET"
const DEFAULT_GAME_API_KEY : String = "DEFAULT_GAME_API_KEY"
const DEFAULT_SERVER_API_KEY : String = "DEFAULT_SERVER_API_KEY"
const DEFAULT_DOMAIN_KEY : String = "DEFAULT_DOMAIN_KEY"
const DEFAULT_GAME_VERSION : String = "0.0.0.0"

static var GAME_API_KEY : String = DEFAULT_GAME_API_KEY
static var SERVER_API_KEY : String = DEFAULT_SERVER_API_KEY
static var DOMAIN_KEY : String = DEFAULT_DOMAIN_KEY
static var GAME_VERSION : String = DEFAULT_GAME_VERSION
static var DEV_MODE : bool = true
static var SYNCHRONOUS_MODE : bool = true
static var password : String = DEFAULT_PASSWORD


static func check_password() -> int:
	var status = FAILED

	if FileAccess.file_exists(PASSWORD_FILEPATH):
		var file = FileAccess.open(PASSWORD_FILEPATH, FileAccess.READ)
		if file != null:
			password = file.get_as_text()

			if file.get_error() != OK:
				print("[check_password]: error while reading password data: "+str(file.get_error()))
			else:
				if password == DEFAULT_PASSWORD:
					print("[check_password]: password has not been configured yet !")
					status = ERR_UNCONFIGURED
				else:
					status = OK
					print("[check_password]: *** TEMPDEBUG, pass="+password)

			file.close()
		else:
			print("[check_password]: error trying to open password file:"+str(FileAccess.get_open_error()))
			status = FileAccess.get_open_error()
	else:
		print("[check_password]: password file doesn't exists, you MUST create one first, see install section in documentation.")
		status = ERR_UNCONFIGURED

	return status


# Saves the token into the ConfigFile and encrypts it a configured password stored in a user's file
static func save_sdk_data() -> int:
	var status : int = FAILED

	if check_password() != OK:
		return status
	
	var file = FileAccess.open_encrypted_with_pass(SDKDATA_FILEPATH, FileAccess.WRITE, password)
	if file != null:
		file.store_pascal_string(GAME_API_KEY)
		if file.get_error() != OK:
			print("[check_password]: error while reading password data: "+str(file.get_error()))
		file.store_pascal_string(SERVER_API_KEY)
		file.store_pascal_string(DOMAIN_KEY)
		file.store_pascal_string(GAME_VERSION)
		file.store_var(DEV_MODE)
		file.store_var(SYNCHRONOUS_MODE)
		status = OK
	else:
		push_error("[save_sdk_data] Error: "+str(FileAccess.get_open_error()))

	return status


static func load_sdk_data() -> int:
	var status : int = OK
	var temp

	if check_password() != OK:
		print("[load_sdk_data]: main password is invalid !")
		return FAILED

	print("try to open file "+SDKDATA_FILEPATH)
	var file = FileAccess.open_encrypted_with_pass(SDKDATA_FILEPATH, FileAccess.READ, password)
	print("file="+str(file))
	if file != null:
		GAME_API_KEY = file.get_pascal_string()
		print("GAPIK="+GAME_API_KEY)
		if file.get_error() != OK:
			print("[load_sdk_data]: error while reading API_KEY data: "+str(file.get_error()))
			status = file.get_error()
		if GAME_API_KEY == DEFAULT_GAME_API_KEY:
			print("[load_sdk_data]: GAME_API_KEY has not been configured yet !")
		else:
			print("[load_sdk_data]: GAME_API_KEY="+GAME_API_KEY)

		SERVER_API_KEY = file.get_pascal_string()
		print("SAPIK="+SERVER_API_KEY)
		if file.get_error() != OK:
			print("[load_sdk_data]: error while reading SERVER_API_KEY data: "+str(file.get_error()))
			status = file.get_error()
		DOMAIN_KEY = file.get_pascal_string()
		if file.get_error() != OK:
			print("[load_sdk_data]: error while reading DOMAIN_KEY data: "+str(file.get_error()))
			status = file.get_error()
		GAME_VERSION = file.get_pascal_string()
		if file.get_error() != OK:
			print("[load_sdk_data]: error while reading GAME_VERSION data: "+str(file.get_error()))
			status = file.get_error()
		temp = file.get_var()
		if file.get_error() != OK:
			print("[load_sdk_data]: error while reading DEV_MODE data: "+str(file.get_error()))
			status = file.get_error()
		else:
			if temp != null and typeof(temp) == TYPE_BOOL:
				DEV_MODE = temp
		temp = file.get_var()
		if file.get_error() != OK:
			print("[load_sdk_data]: error while reading SYNCHRONOUS_MODE data: "+str(file.get_error()))
			status = file.get_error()
		else:
			if temp != null and typeof(temp) == TYPE_BOOL:
				SYNCHRONOUS_MODE = temp
	else:
		push_error("[load_sdk_data] Error: "+str(FileAccess.get_open_error()))
		status = FAILED

	return status
