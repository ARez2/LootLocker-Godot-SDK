@tool
extends Node

@export var API_KEY := "":
	set(v):
		LootLocker.save_to_userfile("API_KEY", v)
		API_KEY = ""
@export var SERVER_API_KEY := "":
	set(v):
		LootLocker.save_to_userfile("SERVER_API_KEY", v)
		SERVER_API_KEY = ""
@export var DOMAIN_KEY := "":
	set(v):
		LootLocker.save_to_userfile("DOMAIN_KEY", v)
		DOMAIN_KEY = ""



@export var GAME_VERSION := "":
	set(v):
		LootLocker.GAME_VERSION = v
		GAME_VERSION = v
