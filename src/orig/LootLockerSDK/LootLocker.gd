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
	GAME_VERSION = LootLockerDataVault.load_from_userfile("GAME_VERSION")
	if API_KEY == null or DOMAIN_KEY == null:
		return


func setup(api_key : String, domain_key : String, version : String):
	API_KEY = api_key
	DOMAIN_KEY = domain_key
	GAME_VERSION = version


func is_authorized() -> bool:
	return session != null

func try_authorize():
	print("try_authorize")
	var data = {
		"game_key": API_KEY,
		"game_version": str(GAME_VERSION),
		"development_mode": DEV_MODE,
	}
	print("send_request[v2/session/guest]")
	await send_request("v2/session/guest", data, on_auth)

func on_auth(response : Dictionary):
	session = LootLockerSession.new()
	session.token = response.get("session_token")
	current_user = LootLockerUser.new()
	print("on_auth: response= "+str(response))
	current_user.id = response.get("player_id")



# ----------------------- PROBABLY NOT THE RIGHT PLACE TO DO IT -----------------------

signal retrieved_user_data(result)
signal retrieved_player_name(result)

func set_user_data(player_name : String = "player_name", player_xp : int = -1):
	set_name(player_name)
	set_xp(player_xp)

func get_user_data():
	send_request("v1/player/info" , null, on_set_name)
	var result = await retrieved_user_data
	return result

func on_get_info(response : Dictionary):
	retrieved_user_data.emit(response)

func set_user_name(player_name : String = "player_name"):
	var data = {
		"name" : player_name
	}
	send_request("player/name" , data, on_set_name)

func get_current_user_name():
	send_request("player/name" , null, on_get_name)
	var result = await retrieved_player_name
	return result

func on_set_name(response : Dictionary):
	print(response)
	if current_user == null:
		current_user = LootLockerUser.new()
	current_user.username = response.get("name")

func on_get_name(response : Dictionary):
	retrieved_player_name.emit(response.get("name"))

func set_xp(player_xp : int = -1):
	var data = {
		"points" : player_xp
	}
	send_request("v1/player/xp" , data, on_set_xp)

func on_set_xp(response : Dictionary):
	if current_user == null:
		current_user = LootLockerUser.new()
	print(response)
	current_user.xp = int(response.get("xp").get("current"))

# -------------------------------------



# Adds the standard url, which is appended to every API call anyways
func build_url(extra_url = "") -> String:
	var base_url = ""
	# Putting the game domain key into the url isn't necessary but seems like a good habit
	if is_authorized():
		base_url = "https://%s.api.lootlocker.io" % DOMAIN_KEY
	else:
		base_url = "https://api.lootlocker.io"
	var url = base_url + "/game/%s" % extra_url
	return url


# Builds the API request URL
# Therefore creates a new HTTPRequest Node which is added as a child of the Autoload LootLocker
# After finishing, the HTTPRequest Node is deleted
func send_request(url : String, data = null, callback = null, method := HTTPClient.METHOD_POST):
	var http = HTTPRequest.new()
	add_child(http)
	#TODO: add cfg for use_threads
	http.use_threads = true
	if callback:
		http.request_completed.connect(_http_request_completed.bind(callback))
	# Those Headers are required by LootLocker
	var header = ["Content-Type: application/json"]
	if is_authorized():
		header.append("x-session-token: %s" % session.token)
	url = build_url(url)
	print("send_request: url="+url)
	if data != null:
		var data_string = JSON.stringify(data)
		printt("send_request: URL: ", url, "", "Data: [", data_string,"]")
		http.request(url, header, method, str(data_string))
	else:
		printt("send_request: URL: ", url)
		http.request(url, header, method)
	print("send_request: wait request_completed")
	await http.request_completed
	http.queue_free()


# Generalized Function to catch HTTPRequest errors before calling the Callback function (which then utilises the response)
func _http_request_completed(result, response_code, headers, body, callback : Callable):
	var response = json.parse(body.get_string_from_utf8())
	print("_http_request_completed: resp="+str(response))
	if response == OK:
		print("_http_request_completed: resp OK")
		response = json.get_data()
	if response.get("success") == false:
		printt("_http_request_completed: An error occured: Error=", response.get("error"), " Message=", response.get("message"))
		return
	
	if callback != null:
		print("_http_request_completed: use callback")
		callback.call(response)
