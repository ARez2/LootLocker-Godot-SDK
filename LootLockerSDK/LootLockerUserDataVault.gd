@tool
extends Node

@export var API_KEY := ""
@export var SERVER_API_KEY := ""
@export var DOMAIN_KEY := ""
@export var GAME_VERSION := ""


@export var SAVE_API_KEYS := false:
	set(v):
		LootLocker.GAME_VERSION = GAME_VERSION
		LootLocker.save_to_userfile("SERVER_API_KEY", SERVER_API_KEY)
		SERVER_API_KEY = ""
		LootLocker.save_to_userfile("API_KEY", API_KEY)
		API_KEY = ""
		LootLocker.save_to_userfile("DOMAIN_KEY", DOMAIN_KEY)
		DOMAIN_KEY = ""
