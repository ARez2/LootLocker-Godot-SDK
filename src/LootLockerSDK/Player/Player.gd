extends Node
class_name LootLockerPlayer

# Wrapper class to store the values returned by the API

# either store all players in one file (JSON load/save) or one player per file id by player_id
#	use in filename

const PLAYERID_FILEPATH = "dummy" #tmp


#these are not needed
var player_identifier : String = ""
var player_id : int = -1
var player_name : String = ""
var public_uid : String = ""
var player_created_at : String = ""
var seen_before : bool = false
var check_deactivation_notifications : bool = false
var check_grant_notifications : bool = false
var check_dlcs : bool = false

# dic not very helpful, not here, but later !
var PLAYERSDATA = {
	"check_deactivation_notifications": "",
	"check_dlcs": "",
	"check_grant_notifications": "",
	"player_created_at": "",
	"player_id": "",
	"player_identifier": "",
	"player_name": "",
	"public_uid": "",
	"seen_before": "",
}

	
#orig:
#var id : int = -1
#var public_uid : String = ""
#var username : String = ""
#var level : int = -1
#var xp : int = -1
#var account_balance : int = -1
#var inventory := {}

func set_data(in_data : Dictionary) -> void:
	if in_data != null and in_data.size() > 0:
		for item in PLAYERSDATA:
			if in_data.has(item):
				print("add item:"+item)
				PLAYERSDATA[item] = in_data[item]

	print("Player data="+str(PLAYERSDATA))


func dump_data() -> String:
	if PLAYERSDATA != null and PLAYERSDATA.size() > 0:
		return str(PLAYERSDATA)
	else:
		return "no data"


#TODO later: store just a JSON data, easier to deal 
# or use a cfgfile with proper sections for each player's data (xp, items, assets, files)
func store_player_info(player_data : Dictionary) -> void:
	var file = FileAccess.open("user://LootLocker.data", FileAccess.WRITE)
	print("[store_player_info] Error? "+str(FileAccess.get_open_error()))
	print("[store_player_info] in data="+str(player_data))
	if file != null:
		print("[store_player_info] file open for writing")
		print("[store_player_info] store played data")
		for item in PLAYERSDATA:
			print("[store_player_info] try to store item: "+item)
			file.store_string(item+":")
			if player_data.has(item):
				print("[store_player_info] store item: "+item+"  type: "+str(typeof(player_data[item])))
				match (typeof(player_data[item])):
					TYPE_STRING: file.store_string(player_data[item])
					TYPE_FLOAT: file.store_float(player_data[item])
					#TYPE_BOOL: file.store_b
					TYPE_INT: file.store_int(player_data[item])
					_: file.store_string(str(player_data[item]))
		print("[store_player_info] close file")
		file.close()


func load_player_info()->Dictionary:
	var data : Dictionary = {}
	
	var file = FileAccess.open("user://LootLocker.data", FileAccess.READ)
	if file != null:
		for item in PLAYERSDATA:
			# some data may be missing, need to store item names too
			# or always store data in the same order
			data[item] = file.get_as_text()
			print(item+"="+data[item])
		file.close()
		
	return data


func store_player_identifier(in_player_identifier : String, fileIdx : int = -1, in_filename : String = "") -> bool:
	
	var filename : String = ""
	
	if fileIdx != -1:
		filename = Constants.PLAYERID_FILEPATH_BEGIN+str(fileIdx)+Constants.PLAYERID_FILEPATH_END
	elif in_filename != "":
		filename = in_filename
	
	if filename == "":
		filename = Constants.PLAYERID_FILEPATH_BEGIN+"0"+Constants.PLAYERID_FILEPATH_END

	var file = FileAccess.open(filename, FileAccess.WRITE)
	
	print("[store_player_identifier] Error? "+str(FileAccess.get_open_error()))
	print("[store_player_identifier] player ID="+in_player_identifier)
	
	if file != null:
		file.store_pascal_string(in_player_identifier)
	else:
		push_error("[store_player_identifier] Error: "+str(FileAccess.get_open_error()))
		return false

	return true


func fetch_player_identifier(fileIdx : int = -1, in_filename : String = "") -> String:
	var out_player_identifier : String = ""
	var filename : String = ""
	
	if fileIdx != -1:
		filename = Constants.PLAYERID_FILEPATH_BEGIN+str(fileIdx)+Constants.PLAYERID_FILEPATH_END
	elif in_filename != "":
		filename = in_filename
	
	if filename == "":
		filename = Constants.PLAYERID_FILEPATH_BEGIN+"0"+Constants.PLAYERID_FILEPATH_END
		
	var file = FileAccess.open(filename, FileAccess.READ)
 
	if file != null:
		out_player_identifier = file.get_pascal_string()
	else:
		push_error("[store_player_identifier] Error: "+str(FileAccess.get_open_error()))

	return out_player_identifier


func dump_player_data() -> void:
	for item in PLAYERSDATA:
		print(item+"="+str(PLAYERSDATA[item]))


func get_player_info() -> int:
	var status : int = OK
	
	print("[get_player_info]: begin")
	
	var headers : Array = ["x-session-token: "+LootLocker.session.token]

	var result = await LootLocker.lootLockerUtils.send_http_request(Constants.PLAYER_INFO_URL, headers, HTTPClient.METHOD_GET, {}, {"all": true})
	print("[get_player_info]: result="+str(result))
	
	if result != null and typeof(result) == TYPE_DICTIONARY and result.size() > 0:
		for item in result:
			PLAYERSDATA[item] = result[item]

	print("[get_player_info]: end")
	
	return status
	

func get_player_name() -> int:
	var status : int = OK
	print("[get_player_name]: begin")
	
	var headers : Array = ["Content-Type: application/json", "x-session-token: "+LootLocker.session.token]

	var result = await LootLocker.lootLockerUtils.send_http_request(Constants.PLAYER_NAME_URL, headers, HTTPClient.METHOD_GET, {}, {"name": ""})
	print("[get_player_name]: result="+str(result))
	
	PLAYERSDATA["name"] = result["name"]
	
	print("[get_player_name]: end")
	
	return status


func lookup_players(player_ids: Array, player_puids: Array) -> int:
	
	var status : int = OK
	print("[lookup_players]: begin")
	
	var headers : Array = ["Content-Type: application/json", "x-session-token: "+LootLocker.session.token]
	var data : Array = []
		#Dictionary = {"player_id": "", "player_public_uid": ""}
	
	if player_ids != null and typeof(player_ids) == TYPE_ARRAY and player_ids.size() > 0:
		#data["player_id"] = player_ids
		data.append_array(player_ids)
		
	if player_puids != null and typeof(player_puids) == TYPE_ARRAY and player_puids.size() > 0:
		#data["player_public_uid"] = player_puids
		data.append_array(player_puids)
	
	#lookup is the ONLY (for now) call using this scheme of array for input data
	#data is an array with one cell per item -d id, -d id2, ...
	#tmp, won't work !
	var result = await LootLocker.lootLockerUtils.send_http_request(Constants.PLAYER_LOOKUP_URL, headers, HTTPClient.METHOD_GET, {"data":data}, {"all": true})
	print("[lookup_players]: result="+str(result))
	
	print("[lookup_players]: end")
	
	return status


func set_player_name(Name : String) -> int:
	var status : int = OK
	print("[set_player_name]: begin")
	
	var headers : Array = ["Content-Type: application/json", "x-session-token: "+LootLocker.session.token]

	if Name != "":
		print("[set_player_name]: name="+Name)
	else:
		print("[set_player_name]: no name provided")
		status = ERR_INVALID_DATA
		#return

	var result = await LootLocker.lootLockerUtils.send_http_request(Constants.PLAYER_NAME_URL, headers, HTTPClient.METHOD_PATCH, {"name": Name}, {"name": ""})
	print("[set_player_name]: result="+str(result))
	
	print("[set_player_name]: end")
	
	return status


func delete_player() -> int:
	var status : int = OK
	print("[delete_player]: begin")
	
	var headers : Array = ["Content-Type: application/json", "x-session-token: "+LootLocker.session.token]

	var result = await LootLocker.lootLockerUtils.send_http_request(Constants.PLAYER_DELETE_URL, headers, HTTPClient.METHOD_DELETE, {}, {})
	print("[delete_player]: result="+str(result))
	#RC 204 = ok
	print("[delete_player]: end")
	
	return status
