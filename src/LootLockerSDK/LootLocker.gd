@icon("res://LootLockerSDK/icons/hector.svg")
extends Node
#class_name LootLocker

#const SDK_VERSION : String = "a0.01"
#const SDK_GODOT_COMPATIBILITY : String = "4.2"
#
#const LOOTLOCKER_API_BASE_URL : String= "https://api.lootlocker.io/"
#
#const GUEST_LOGIN_URL : String = LOOTLOCKER_API_BASE_URL + "game/v2/session/guest"
#const END_SESSION_URL : String = LOOTLOCKER_API_BASE_URL + "game/v1/session"
#
#const WHITE_LABEL_URLPART : String = "white-label-login/"
#const WL_SIGNUP_URL : String = LOOTLOCKER_API_BASE_URL + WHITE_LABEL_URLPART + "sign-up"
#const WL_SIGNIN_URL : String = LOOTLOCKER_API_BASE_URL + WHITE_LABEL_URLPART + "login"
#const WL_SIGNOUT_URL : String = LOOTLOCKER_API_BASE_URL + WHITE_LABEL_URLPART + "session"
#const WL_SIGN_VERIF_SESSION_URL : String = LOOTLOCKER_API_BASE_URL + WHITE_LABEL_URLPART + "verify-session"
#const WL_REQ_VERIFICATION_URL : String = LOOTLOCKER_API_BASE_URL + WHITE_LABEL_URLPART + "request-verification"
#const WL_REQ_PASSWORDRESET_URL : String = LOOTLOCKER_API_BASE_URL + WHITE_LABEL_URLPART + "request-reset-password"

enum PLATFORM {Apple, AppleGameCenter, Epic, GooglePlay, NintendoSwitch, Playstation, Steam, Xbox}

var API_KEY : String = ""
var DOMAIN_KEY : String = ""
var GAME_VERSION : String = "1.0.0.0"

var DEV_MODE : bool = false
var synchronous : bool = true

signal logged_in(data : Dictionary)

var lootLockerUtils : LootLockerUtils

var httpObject : HTTPRequest

var session : LootLockerSession = null
var leaderboard : LootLockerLeaderBoards = null
var current_user : LootLockerPlayer = null
var misc : LootLockerMisc = null
#var operation_in_progress : bool = false #to remove maybe

#TODO: put auth func in their own script/class
#purpose of this is ti hold things together only
# AND having a way to store active sessions

#--
var json = JSON.new()	#tmp

# not here
#var leaderboards : LootLockerLeaderboards = LootLockerLeaderboards.new()
#--

func _ready():
	print("LootLocker base class added to tree")
	lootLockerUtils = LootLockerUtils.new()
	lootLockerUtils.tree = self
	lootLockerUtils.synchronous = synchronous
	session = LootLockerSession.new()
	leaderboard = LootLockerLeaderBoards.new()
	current_user = LootLockerPlayer.new()
	misc = LootLockerMisc.new()


func setup(api_key : String, domain_key : String, version : String, dev_mode : bool = true, synchronous_mode : bool = false) -> void:
	API_KEY = api_key
	DOMAIN_KEY = domain_key
	GAME_VERSION = version
	DEV_MODE = dev_mode
	synchronous = synchronous_mode


func setup_from_file() -> void:
	var loadResult = LootLockerDataVault.load_sdk_data()
	#API_KEY = LootLockerDataVault.load_from_userfile("API_KEY")
	#DOMAIN_KEY = LootLockerDataVault.load_from_userfile("DOMAIN_KEY")
	#GAME_VERSION = LootLockerDataVault.load_from_userfile("GAME_VERSION")
	#DEV_MODE = LootLockerDataVault.load_from_userfile("DEV_MODE")
	API_KEY = LootLockerDataVault.API_KEY
	DOMAIN_KEY = LootLockerDataVault.DOMAIN_KEY
	GAME_VERSION = LootLockerDataVault.GAME_VERSION
	#DEV_MODE = LootLockerDataVault.DEV_MODE
	#synchronous = synchronous_mode
	
	if API_KEY == null or DOMAIN_KEY == null:
		print("API_KEY or DOMAIN_KEY not defined !")


func guest_login(player_identifier : String = "") -> int:
	
	var status = OK

	print("[guest_login]: begin")
	var data = { "game_key": API_KEY, "game_version": GAME_VERSION, "development_mode": DEV_MODE }
	
	if player_identifier != "":
		data["player_identifier"] = player_identifier
	
	var headers : Array = ["Content-Type: application/json"]
	var wanted : Dictionary = {
		"session_token": "", "player_identifier": "", "player_id":"", "player_name":"",
		"player_created_at":"", "public_uid":"","seen_before":"",
		"check_grant_notifications":"","check_deactivation_notifications":"","check_dlcs":""
	}
	var result = await lootLockerUtils.send_http_request(Constants.GUEST_LOGIN_URL, headers, HTTPClient.METHOD_POST, data, wanted)
	print("[guest_login]: result="+str(result))
	
	#TODO: need to get player data !
	
	if result != null and result.size() > 0:
		if result.has("session_token"):
			session.token = result["session_token"]
		else:
			print("[guest_login]: error, session token not found in response !")
			status = FAILED
			
		#fill player data
		print("Fill player data")
		current_user.set_data(result)
	else:
		pass

	print("[guest_login]: end")
	
	#TODO: deal with error
	return status


# toremove
func _on_guest_login_completed_unused(result, response_code, headers, body) -> Dictionary:
	var out_json : Dictionary

	print("_on_guest_login_completed: begin")
	print("result="+str(result)+"  RC="+str(response_code))
	#result == OK and response_code == 200 => proceed
	#else error
	if result == OK:
		if response_code == 200: #tmp use enum value
			out_json = JSON.parse_string(body.get_string_from_utf8())
			print("_on_guest_login_completed-JSON: "+str(out_json))

	# no connection => json object is null
			if out_json.has("session_token"):
				session.token = out_json["session_token"]
				print("session="+str(session))
				logged_in.emit(out_json)
		else:
			print("TODO: RC to process")
	else:
		print("ERROR: "+str(result))

	if httpObject != null:
		httpObject.queue_free()

	#if operation_in_progress == true:
	#	operation_in_progress = false

	print("_on_guest_login_completed: end")
	# how to use return data from caller ??
	return out_json


func white_label_signup(email : String, password : String) -> int:
	var status = OK

	print("[white_label_signup]: begin")
	
	if email == "": #+ check email valid xxx@domain
		print("[white_label_signup]: no email address provided")
		status = ERR_INVALID_DATA
	if password == "":
		print("[white_label_signup]: no password provided")
		status = ERR_INVALID_DATA
	if password.length() < 8:
		print("[white_label_signup]: password should be at least eight characters long")
		status = ERR_INVALID_DATA

	var headers = ["Content-Type: application/json", "domain-key: "+DOMAIN_KEY, "is-development: "+str(DEV_MODE)]
	var data = { "email": email, "password": password }
	
	var result = await lootLockerUtils.send_http_request(Constants.WL_SIGNUP_URL, headers, HTTPClient.METHOD_POST, data, {})
	print("[white_label_signup]: result="+str(result))
	
	#if result != null and result.size() > 0 and result.has("session_token"):
		#session.token = result["session_token"]
	#else:
		#print("[white_label_signup]: error, session token not found in response !")
		#status = FAILED

	print("[white_label_signup]: end")
	return status


# put all WL stuff in their own script file
func white_label_login(email : String, password : String, remember_me : bool = false) -> int:
	var status = OK

	print("[white_label_login]: begin")
	
	if email == "": #+ check email valid xxx@domain
		print("[white_label_login]: no email address provided")
		status = ERR_INVALID_DATA
	if password == "":
		print("[white_label_login]: no password provided")
		status = ERR_INVALID_DATA
	if password.length() < 8:
		print("[white_label_login]: password should be at least eight characters long")
		status = ERR_INVALID_DATA

	var headers = ["Content-Type: application/json", "domain-key: "+DOMAIN_KEY, "is-development: "+str(DEV_MODE)]
	var data = { "email": email, "password": password, "remember_me": remember_me }
	var wanted = { "session_token": "", "id": "", "game_id": "", "verified_at": ""}

	var result = await lootLockerUtils.send_http_request(Constants.WL_SIGNIN_URL, headers, HTTPClient.METHOD_POST, data, wanted)
	print("[white_label_login]: result="+str(result))
	#maybe store result/wanted stuff in a temp storage inside object
	# so we can get back anyting we want for further use

	if result != null and result.size() > 0:
		if result.has("session_token"):
			session.token = result["session_token"]
		else:
			print("[white_label_login]: error, session token not found in response !")
			status = FAILED
			
		#fill player data
		#print("Fill player data")
		#current_user.set_data(result)
	else:
		pass	#deal with no result situation

	print("[white_label_login]: end")
	return status


func verify_session(token : String, email: String) -> int:
	var status = OK

	print("[verify_session]: begin")
	
	if email == "": #+ check email valid xxx@domain
		print("[verify_session]: no email address provided")
		status = ERR_INVALID_DATA
	if email.length() < 8:
		print("[verify_session]: email should be at least eight characters long")
		status = ERR_INVALID_DATA
	if token == "":
		print("[verify_session]: no token provided")
		status = ERR_INVALID_DATA

	var headers = ["Content-Type: application/json", "domain-key: "+DOMAIN_KEY, "is-development: "+str(DEV_MODE)]
	var data = { "email": email, "token": token }
	
	var result = await lootLockerUtils.send_http_request(Constants.WL_SIGN_VERIF_SESSION_URL, headers, HTTPClient.METHOD_POST, data, {})
	print("[verify_session]: result="+str(result))
	
	#if result != null and result.size() > 0 and result.has("session_token"):
		#session.token = result["session_token"]
	#else:
		#print("[white_label_signup]: error, session token not found in response !")
		#status = FAILED

	print("[verify_session]: end")
	return status


func request_user_verification(userid : int, email: String) -> int:
	var status = OK

	print("[request_user_verification]: begin")
	var data = {}
	
	if email == "": #+ check email valid xxx@domain
		print("[request_user_verification]: no email address provided")
		status = ERR_INVALID_DATA
	elif email.length() < 8:
		print("[request_user_verification]: email should be at least eight characters long")
		status = ERR_INVALID_DATA
	else:
		data["email"] = email
	if userid == null:
		print("[request_user_verification]: no userid provided")
		status = ERR_INVALID_DATA
	else:
		data["user_id"] = userid
	
	var headers = ["Content-Type: application/json", "domain-key: "+DOMAIN_KEY, "is-development: "+str(DEV_MODE)]

	var result = await lootLockerUtils.send_http_request(Constants.WL_REQ_VERIFICATION_URL, headers, HTTPClient.METHOD_POST, data, {})
	print("[request_user_verification]: result="+str(result))
	
	#if result != null and result.size() > 0 and result.has("session_token"):
		#session.token = result["session_token"]
	#else:
		#print("[white_label_signup]: error, session token not found in response !")
		#status = FAILED

	print("[request_user_verification]: end")
	return status


func request_password_reset(email: String) -> int:
	var status = OK

	print("[request_password_reset]: begin")
	var data = {}
	
	if email == "": #+ check email valid xxx@domain
		print("[request_password_reset]: no email address provided")
		status = ERR_INVALID_DATA
	elif email.length() < 8:
		print("[request_password_reset]: email should be at least eight characters long")
		status = ERR_INVALID_DATA
	else:
		data["email"] = email
	
	var headers = ["Content-Type: application/json", "domain-key: "+DOMAIN_KEY, "is-development: "+str(DEV_MODE)]

	var result = await lootLockerUtils.send_http_request(Constants.WL_REQ_PASSWORDRESET_URL, headers, HTTPClient.METHOD_POST, data, {})
	print("[request_password_reset]: result="+str(result))
	
	#if result != null and result.size() > 0 and result.has("session_token"):
		#session.token = result["session_token"]
	#else:
		#print("[white_label_signup]: error, session token not found in response !")
		#status = FAILED

	print("[request_password_reset]: end")
	return status


func delete_white_label_session(token : String) -> int:
	var status = OK

	print("[delete_white_label_session]: begin")
	var data = {}
	
	if token == "":
		print("[delete_white_label_session]: no session token provided")
		status = ERR_INVALID_DATA
	else:
		data["token"] = token
	
	var headers = ["Content-Type: application/json", "domain-key: "+DOMAIN_KEY, "is-development: "+str(DEV_MODE)]

	var result = await lootLockerUtils.send_http_request(Constants.WL_SIGNOUT_URL, headers, HTTPClient.METHOD_DELETE, data, {})
	print("[delete_white_label_session]: result="+str(result))
	
	#if result != null and result.size() > 0 and result.has("session_token"):
		#session.token = result["session_token"]
	#else:
		#print("[white_label_signup]: error, session token not found in response !")
		#status = FAILED

	print("[delete_white_label_session]: end")
	return status


func platform_login(platform : String):
	pass
	

#================================ orig code ======================
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
	current_user = LootLockerPlayer.new()
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
		current_user = LootLockerPlayer.new()
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
		current_user = LootLockerPlayer.new()
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
