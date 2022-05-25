extends Node

onready var API_KEY = LootLockerDataVault.load_from_userfile("API_KEY")
onready var DOMAIN_KEY = LootLockerDataVault.load_from_userfile("DOMAIN_KEY")
var GAME_VERSION = "1.0"

var DEV_MODE = false

var session : LootLockerSession = null
var current_user : LootLockerUser = null
var leaderboards : LootLockerLeaderboards = LootLockerLeaderboards.new()

signal api_response (response, args)

func _ready():
	#GAME_VERSION = LootLockerDataVault.load_from_userfile("GAME_VERSION")
	if API_KEY == null or DOMAIN_KEY == null:
		return


func setup(api_key : String, domain_key : String, version : String):
	API_KEY = api_key
	DOMAIN_KEY = domain_key
	GAME_VERSION = version


func is_authorized() -> bool:
	return session != null

func try_authorize():
	var data = {
		"game_key": API_KEY,
		"game_version": str(GAME_VERSION),
		"development_mode": DEV_MODE,
	}
	send_request("v2/session/guest", data)
	var res = yield(LootLocker, "api_response")
	var response = res
	on_auth(response)


func on_auth(response : Dictionary):
	session = LootLockerSession.new()
	session.token = response.get("session_token")
	current_user = LootLockerUser.new()
	current_user.id = response.get("player_id")



# ----------------------- PROBABLY NOT THE RIGHT PLACE TO DO IT -----------------------

signal retrieved_user_data(result)
signal retrieved_player_name(result)

func set_user_data(player_name : String = "player_name", player_xp : int = -1):
	set_name(player_name)
	set_xp(player_xp)

func get_user_data():
	send_request("v1/player/info" , null)
	var res = yield(LootLocker, "api_response")
	var response = res
	on_set_name(response)
	response = yield(self, "retrieved_user_data")
	return response


func on_get_info(response : Dictionary):
	emit_signal("retrieved_user_data", response)


func set_user_name(player_name : String = "player_name"):
	var data = {
		"name" : player_name
	}
	send_request("player/name", data, HTTPClient.METHOD_PATCH)
	var res = yield(LootLocker, "api_response")
	var response = res
	on_set_name(response)


func get_current_user_name():
	send_request("player/name", null)
	var res = yield(LootLocker, "api_response")
	var response = res
	on_get_name(response)
	response = yield(self, "retrieved_player_name")
	return response


func on_set_name(response : Dictionary):
	if current_user == null:
		current_user = LootLockerUser.new()
	current_user.username = response.get("name")

func on_get_name(response : Dictionary):
	emit_signal("retrieved_player_name", response.get("name"))

func set_xp(player_xp : int = -1):
	var data = {
		"points" : player_xp
	}
	send_request("v1/player/xp", data)
	var res = yield(LootLocker, "api_response")
	var response = res
	on_set_xp(response)


func on_set_xp(response : Dictionary):
	if current_user == null:
		current_user = LootLockerUser.new()
	current_user.xp = int(response.get("xp").get("current"))

# -------------------------------------







func build_url(extra_url = "") -> String:
	var base_url = ""
	if is_authorized():
		base_url = "https://%s.api.lootlocker.io" % DOMAIN_KEY
	else:
		base_url = "https://api.lootlocker.io"
	var url = base_url + "/game/%s" % extra_url
	return url


func send_request(url : String, data = null, method := HTTPClient.METHOD_POST):
	var http = HTTPRequest.new()
	add_child(http)
	http.use_threads = true
	http.connect("request_completed", self, "_http_request_completed")
	var header = ["Content-Type: application/json"]
	if is_authorized():
		header.append("x-session-token: %s" % session.token)
	url = build_url(url)
	if data != null:
		var data_string = JSON.print(data)
		printt("URL: ", url, "", "Data: ", data_string)
		http.request(url, header, true, method, str(data_string))
	else:
		printt("URL: ", url)
		http.request(url, header, true, method)
	yield(http, "request_completed")
	http.queue_free()



func _http_request_completed(result, response_code, headers, body):
	var response = JSON.parse(body.get_string_from_utf8())
	if response.error == OK:
		response = response.result
	if response.get("success") == false:
		printt("An error occured: ", response.get("error"), response.get("message"))
		return
	
	emit_signal("api_response", response)
