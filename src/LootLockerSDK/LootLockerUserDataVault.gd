@tool
extends Node
class_name LootLockerDataVault


const USERDATA_FILEPATH = "res://LootLockerSDK/UserData.cfg"

@export var API_KEY := "":
	set(v):
		save_to_userfile("API_KEY", v)
		API_KEY = ""
@export var SERVER_API_KEY := "":
	set(v):
		save_to_userfile("SERVER_API_KEY", v)
		SERVER_API_KEY = ""
@export var DOMAIN_KEY := "":
	set(v):
		save_to_userfile("DOMAIN_KEY", v)
		DOMAIN_KEY = ""



@export var GAME_VERSION := "":
	set(v):
		GAME_VERSION = v
		save_to_userfile("GAME_VERSION", v)



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
