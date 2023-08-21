extends Node
class_name LootLockerSession

#var lootLockerUtils : LootLockerUtils

var token : String = ""

var httpObject : HTTPRequest

func _init():
	print("LootLockerSession: _init called")
	#lootLockerUtils = LootLockerUtils.new()
	#lootLockerUtils.tree = self

func _ready():
	print("LootLockerSession: _ready called")


func set_token(session_token : String) -> void:
	if session_token != "":
		token = session_token
	else:
		push_error("set_token: Invalid session token provided")


func end_session(session_token : String, is_white_label : bool = false) -> int:
	
	var status : int = OK
	print("[end_session]: begin")
	
	var headers : Array = ["Content-Type: application/json"]
	if session_token != "":
		headers.append("x-session-token: "+session_token)
		if is_white_label == true:
			headers.append("logout: true")
	else:
		print("[end_session]: session token is invalid or not provided")
		status = ERR_INVALID_DATA

	var result = await LootLocker.lootLockerUtils.send_http_request(Constants.END_SESSION_URL, headers, HTTPClient.METHOD_DELETE)
	print("[end_session]: result="+str(result))
	
	
	
		#httpObject = HTTPRequest.new()
		#LootLocker.add_child(httpObject)
		#httpObject.request_completed.connect(_on_end_session_completed)
#
		#httpObject.request(END_SESSION_URL, headers, HTTPClient.METHOD_DELETE)
#
		#if LootLocker.synchronous == true:
			#var result = await httpObject.request_completed
			#print("end_session: RQ result="+str(result))
		#else:
			#pass
	

	print("[end_session]: end")
	
	return status

# could be a generic function which deal with errors etc
func _on_end_session_completed(result, response_code, headers, body) -> int:
	print("_on_end_session_completed:")
	print("result="+str(result))
	print("response_code="+str(response_code))
	print("headers="+str(headers))
	print("body="+str(body))
	
	#check response_code != 200,return error if such case
	
	var json = JSON.parse_string(body.get_string_from_utf8())
	print("_on_end_session_completed-JSON: "+str(json))
	
	#check success = true
	
	if httpObject != null:
		httpObject.queue_free()
	
	return OK
