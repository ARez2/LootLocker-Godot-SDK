@tool
extends Node

const USERDATA_FILEPATH = "res://addons/LootLockerSDK/UserData.cfg"
var API_KEY = ""
var DOMAIN_KEY = ""
var GAME_VERSION = ""

var json = JSON.new()
var session : LootLockerSession = null
var current_user : LootLockerUser = null


func _ready():
	API_KEY = load_from_userfile("API_KEY")
	DOMAIN_KEY = load_from_userfile("DOMAIN_KEY")


func save_to_userfile(keyname : String, value):
	if value == "":
		return
	var section_name = "UserData"
	var password = OS.get_unique_id()
	var config = ConfigFile.new()
	var error = config.load_encrypted_pass(LootLocker.USERDATA_FILEPATH, password)
	if error == ERR_FILE_NOT_FOUND:
		print("Creating new UserData.cfg file...")
	config.set_value(section_name, keyname, value)
	config.save_encrypted_pass(LootLocker.USERDATA_FILEPATH, password)


func load_from_userfile(keyname):
	var section_name = "UserData"
	var password = OS.get_unique_id()
	var config = ConfigFile.new()
	var error = config.load_encrypted_pass(LootLocker.USERDATA_FILEPATH, password)
	if error == OK:
		return config.get_value(section_name, keyname)



func setup(api_key : String, domain_key : String, version : String):
	API_KEY = api_key
	DOMAIN_KEY = domain_key
	GAME_VERSION = version


func is_authorized() -> bool:
	return session != null

func try_authorize():
	var data = {
		"game_key": API_KEY,
		"game_version": GAME_VERSION,
		"development_mode": false,
	}
	await send_request("v2/session/guest", data, on_auth)

func on_auth(response : Dictionary):
	print(response)
	session = LootLockerSession.new()
	session.token = response.get("session_token")
	current_user = LootLockerUser.new()
	current_user.id = response.get("player_id")
	print(current_user.id)




# ----------------------- PROBABLY NOT THE RIGHT PLACE TO DO IT -----------------------

func submit_score(leaderboard_name : String = "2522"):
	var data = {
		"member_id": str(current_user.id),
		"score": randi_range(0, 1000),
	}
	send_request("leaderboards/%s/submit" % leaderboard_name, data, on_submit_score)

func retrieve_score(leaderboard_name : String = "2522", num_scores := 10):
	send_request("leaderboards/%s/list?count=%d&after=%d" % [leaderboard_name, num_scores, 0], null, on_retrieve_score, HTTPClient.METHOD_GET)

func on_submit_score(response : Dictionary) -> LootLockerLeaderboardResult:
	print(response)
	var result = LootLockerLeaderboardResult.new()
	result.rank = response.get("rank")
	result.member_id = response.get("member_id").to_int()
	result.score = response.get("score")
	result.metadata = response.get("metadata")
	return result

func on_retrieve_score(response : Dictionary):
	print(response)

# -------------------------------------------------------------------------------------




func build_url(extra_url = "") -> String:
	var base_url = ""
	if is_authorized():
		base_url = "https://%s.api.lootlocker.io" % DOMAIN_KEY
	else:
		base_url = "https://api.lootlocker.io"
	var url = base_url + "/game/%s" % extra_url
	return url


func send_request(url : String, data = null, callback = null, method := HTTPClient.METHOD_POST):
	print("IDK")
	var http = HTTPRequest.new()
	add_child(http)
	http.use_threads = true
	if callback:
		http.request_completed.connect(_http_request_completed.bind(callback))
		http.request_completed.connect(http.queue_free)
	var header = ["Content-Type: application/json"]
	if is_authorized():
		header.append("x-session-token: %s" % session.token)
	url = build_url(url)
	if data != null:
		printt("URL: ", url)
		var data_string = json.stringify(data)
		http.request(url, header, true, method, str(data_string))
	else:
		printt("URL: ", url)
		http.request(url, header, true, method)
	await http.request_completed



func _http_request_completed(result, response_code, headers, body, callback : Callable):
	var response = json.parse(body.get_string_from_utf8())
	if response == OK:
		response = json.get_data()
	if response.get("success") == false:
		printt("An error occured: ", response.get("error"), response.get("message"))
		return
	callback.call(response)
