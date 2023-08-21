extends Node
class_name LootLockerUtils

@export var tree : Node
@export var synchronous : bool
@export var delay : float = 30.0
@export var retry : int = 3


var httpObject

func send_http_request(url: String, headers : Array, method: HTTPClient.Method, data: Dictionary = {}, wanted_data: Dictionary = {}) -> Dictionary:

	var output : Dictionary = {}
	var data_as_string : String = ""
	var attempts : int = 0

	print("[send_http_request]: url="+url+" headers="+str(headers)+" method="+str(method)+" data="+str(data)+" wanted:"+str(wanted_data))

	if url == "":
		print("[send_http_request] error: url not defined")
		return {"Error": "url not defined"}

	if method < HTTPClient.METHOD_GET or method > HTTPClient.METHOD_MAX:
		print("[send_http_request] error: invalid method given")
		return {"Error": "invalid method given"}

	if headers == null or headers.size() == 0:
		print("[send_http_request] error: headers empty or not defined")
		return {"Error": "headers empty or not defined"}

	# is that an actual error ? data may not always be needed
	if data == null or data.size() == 0:
		# need to check method GET/POST/...
		print("[send_http_request] info: data empty or not defined")
		#return {"Error": "data empty or not defined"}
	else:
		data_as_string = JSON.stringify(data)
		
	if wanted_data.size() > 0:
		print("[send_http_request] data will be harvested in response")

	httpObject = HTTPRequest.new()
	tree.add_child(httpObject)
	httpObject.request_completed.connect(_on_request_completed)

	print("[send_http_request]: datast="+data_as_string)
	while attempts < retry:
		attempts += 1
		
		var RequestResult = httpObject.request(url, headers, method, data_as_string)
		print("[send_http_request]: RR="+str(RequestResult))
		
		if RequestResult != OK:
			print("[send_http_request]: Error to deal with=")
			
			if RequestResult == ERR_BUSY or RequestResult == ERR_CANT_CONNECT:
				print("[send_http_request]: Busy or can't connect, delay & retry")
				print("using await with a timer, 3 secs...  "+str(Time.get_ticks_msec()))
				await get_tree().create_timer(delay).timeout
				print("after 3 sec   "+str(Time.get_ticks_msec()))
				#TODO: configure retry/delay for loop
			else:
				remove_child(httpObject)
				return {"result" : RequestResult} #?? =>  need consistent output
		else:
			break #continue

	if attempts >= retry:
		print("[send_http_request]: request failed after %d attempts, abort" % attempts)
		remove_child(httpObject)
		return {"result" : "(tmp) too many retries"}
		
	if synchronous == true:
		var result = await httpObject.request_completed
		print("[send_http_request]: RQ result="+str(result))
		#print("type="+str(typeof(result)))
		#print("body="+str(result[3]))
		#check result here + diff cases, handle them ALL !
		if result[3] != null and result[3].size() > 0:
			print("body dec="+result[3].get_string_from_utf8())
			
			# error 504 => body dec = HTML error page !
			var json_data : Dictionary = JSON.parse_string(result[3].get_string_from_utf8())
			print("json_data="+str(json_data))
			
			if wanted_data != null:
				if wanted_data.size() == 1 and wanted_data.has("all"):
					print("get all available data")
					output = json_data.duplicate()
					output.erase("success")
				else:
					for item in wanted_data:
						print("check for item: "+str(item))
						if json_data.has(item):
							print("item("+item+") found="+str(json_data[item]))
							output[item] = json_data[item]
		else:
			print("[send_http_request]: response have no body")
	else:
		pass
		#nothing to do NO => when output is needed (session token for instance)

	return output

# need to add more resp code ok
func _on_request_completed(result, response_code, headers, body) -> Dictionary:
	var out_json : Dictionary
	
	print("[_on_request_completed]: begin")
	print("[_on_request_completed]: result="+str(result)+"  RC="+str(response_code))
	#need to return resp_code !

	if result == OK:
		if response_code == HTTPClient.ResponseCode.RESPONSE_OK:
			out_json = JSON.parse_string(body.get_string_from_utf8())
			print("[_on_request_completed]: JSON="+str(out_json))
	
	# no connection => json object is null
		else:
			print("TODO: RC to process")
	else:
		print("ERROR: "+str(result))

	if httpObject != null:
		httpObject.queue_free()

	print("[_on_request_completed]: end")
	# how to use return data from caller ??
	return out_json
