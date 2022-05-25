tool
extends Node
class_name LootLockerDataVault


const USERDATA_FILEPATH = "res://LootLockerSDK/UserData.cfg"

export var API_KEY := "" setget set_api_key
export var SERVER_API_KEY := "" setget set_server_api_key
export var DOMAIN_KEY := "" setget set_domain_key
export var GAME_VERSION := "" setget set_game_version


func set_api_key(v):
	save_to_userfile("API_KEY", v)
	API_KEY = ""
	property_list_changed_notify()
	property_list_changed_notify()


func set_server_api_key(v):
	save_to_userfile("SERVER_API_KEY", v)
	SERVER_API_KEY = ""
	property_list_changed_notify()

func set_domain_key(v):
	save_to_userfile("DOMAIN_KEY", v)
	DOMAIN_KEY = ""
	property_list_changed_notify()


func set_game_version(v):
	GAME_VERSION = v
	save_to_userfile("GAME_VERSION", v)
	property_list_changed_notify()


static func save_to_userfile(keyname : String, value):
	if value == "":
		return
	var section_name = "UserData"
	var password = OS.get_unique_id()
	password = "123"
	var config = ConfigFile.new()
	var error = config.load_encrypted_pass(USERDATA_FILEPATH, password)
	if error == ERR_FILE_NOT_FOUND:
		print("UserData.cfg file not found. Creating new UserData.cfg file...")
	config.set_value(section_name, keyname, value)
	config.save_encrypted_pass(USERDATA_FILEPATH, password)


static func load_from_userfile(keyname):
	var section_name = "UserData"
	var password = OS.get_unique_id()
	password = "123"
	var config = ConfigFile.new()
	var error = config.load_encrypted_pass(USERDATA_FILEPATH, password)
	if error == OK:
		return config.get_value(section_name, keyname)
	else:
		print(error)
