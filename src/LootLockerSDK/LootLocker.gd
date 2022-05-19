extends Node
var API_KEY = ""
var DOMAIN_KEY = ""
var GAME_VERSION = "1.0"

var DEV_MODE = false

var json = JSON.new()
var session : LootLockerSession = null
var current_user : LootLockerUser = null

var leaderboards : LootLockerLeaderboards = LootLockerLeaderboards.new()


func _ready():
	API_KEY = LootLockerDataVault.load_from_userfile("API_KEY")
	DOMAIN_KEY = LootLockerDataVault.load_from_userfile("DOMAIN_KEY")
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
	await send_request("v2/session/guest", data, on_auth)

func on_auth(response : Dictionary):
	session = LootLockerSession.new()
	session.token = response.get("session_token")
	current_user = LootLockerUser.new()
	current_user.id = response.get("player_id")






func build_url(extra_url = "") -> String:
	var base_url = ""
	if is_authorized():
		base_url = "https://%s.api.lootlocker.io" % DOMAIN_KEY
	else:
		base_url = "https://api.lootlocker.io"
	var url = base_url + "/game/%s" % extra_url
	return url


func send_request(url : String, data = null, callback = null, method := HTTPClient.METHOD_POST):
	var http = HTTPRequest.new()
	add_child(http)
	http.use_threads = true
	if callback:
		http.request_completed.connect(_http_request_completed.bind(callback))
	var header = ["Content-Type: application/json"]
	if is_authorized():
		header.append("x-session-token: %s" % session.token)
	url = build_url(url)
	if data != null:
		var data_string = json.stringify(data)
		printt("URL: ", url, "", "Data: ", data_string)
		http.request(url, header, true, method, str(data_string))
	else:
		printt("URL: ", url)
		http.request(url, header, true, method)
	await http.request_completed
	http.queue_free()



func _http_request_completed(result, response_code, headers, body, callback : Callable):
	var response = json.parse(body.get_string_from_utf8())
	if response == OK:
		response = json.get_data()
	if response.get("success") == false:
		printt("An error occured: ", response.get("error"), response.get("message"))
		return
	
	callback.call(response)
