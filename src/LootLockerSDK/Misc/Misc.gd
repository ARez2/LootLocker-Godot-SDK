extends Node
class_name LootLockerMisc

@export var session_token : String = ""
var date : String = ""

func ping() -> int:
	var status : int = OK
	print("[ping]: begin")
	
	var headers : Array

	if session_token != "":
		headers = ["x-session-token: "+session_token]
		
		var result = await LootLocker.lootLockerUtils.send_http_request(Constants.PING_URL, headers, HTTPClient.METHOD_GET, {}, {"date": ""})
		print("[ping]: result="+str(result))
		
		if result != null and typeof(result) == TYPE_DICTIONARY and result.has("date"):
			date = result["date"]
	else:
		print("[ping]: no session token provided")
		status = ERR_INVALID_DATA

	return status
