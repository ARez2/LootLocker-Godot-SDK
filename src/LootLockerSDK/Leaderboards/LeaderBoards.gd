extends Node
class_name LootLockerLeaderBoards

#const LEADERBOARDS_URL = LootLocker.LOOTLOCKER_API_BASE_URL + "game/leaderboards/"
	#+leaderboard_key+"/list?count=10"

@export var session_token : String = ""
@export var player : LootLockerPlayer
@export var leaderboard_key : String = ""
@export var leaderboard_id : String = ""

var leaderboards : Dictionary = {}
var last_submitted_score_rank : int = -1
var top_scores = {}
var scores_around_player = {}


func _ready():
	print("LootLockerLeaderBoards: _ready called")

#func token(token : String):
	#session_token = token

#or leaderboard_id int param
#session token + lb key => as property, remove from arg list
#session_token : String, leaderboard_key : String = "", 
#HERE: get rid of lkey/lid, not good here or as last opt args
func get_leaderboard(pagination_cursor : int = 1, count : int = 10, after : int = -1, key : String = leaderboard_key, id : String = leaderboard_id) -> int:
	
	var status : int = OK
	print("[get_leaderboard]: begin")
	LootLockerHelpers.dump_args({"key": key, "id": id, "pagination_cursor": pagination_cursor, "count": count, "after": after})
	
	var headers : Array = ["Content-Type: application/json"]

	if session_token != "":
		headers.append("x-session-token: "+session_token)
	else:
		print("[get_leaderboard]: no session token provided")
		status = ERR_INVALID_DATA
		#return
	#if leaderboard_key != "":
		#print("[get_leaderboard]: leaderboard key="+leaderboard_key)
	#else:
		#print("[get_leaderboard]: no leaderboard_key provided")
		#status = ERR_INVALID_DATA
		#return

	#maybe generic build URL from list of items, take care of convert all to string + check all ok
	var url = Constants.LEADERBOARDS_URL+leaderboard_key+"/list?count=" + str(count)
	if after != -1:
		print("after is in use")
		url += "&" + Constants.LEADERBOARDS_AFTER_EP_URL + "=" + str(after)
		print("URL="+url)
	var result = await LootLocker.lootLockerUtils.send_http_request(url, headers, HTTPClient.METHOD_GET, {}, {"pagination": "", "items": ""})
	print("[get_leaderboard]: result="+str(result))
	
	#need to return LB data as well or fill in some object here (current LB)
	if result.size() > 0 and result.has("items"):
		print("fill local dta with items regardless of pagination")
		leaderboards[leaderboard_key] = Array()
		var arrayIdx = 0
		
		#"highlight" current player rank in results
		# rank is the index of the returned array, 1st item idx 0 = rk 1...
		# ONLY for first page, after that rank = idx + delta !
		leaderboards[leaderboard_key].resize(result["items"].size())
		for item in result["items"]:
			print("process item"+str(item))
			if item.has("rank"):
				leaderboards[leaderboard_key][arrayIdx] = Dictionary()
			if item.has("score"):
				leaderboards[leaderboard_key][arrayIdx]["score"] = int(item["score"])
			if item.has("player") and typeof(item["player"]) == TYPE_DICTIONARY and item["player"].size() > 0:
				leaderboards[leaderboard_key][arrayIdx]["rank"] = item["rank"]
				#if item["player"].has("name") and item["player"]["name"] != "":
				leaderboards[leaderboard_key][arrayIdx]["name"] = item["player"]["name"]
				#if item["player"].has("public_uid") and item["player"]["public_uid"] != "":
				leaderboards[leaderboard_key][arrayIdx]["public_uid"] = item["player"]["public_uid"]
				#print("id type="+str(typeof(item["player"]["id"])))
				#if item["player"].has("id") and item["player"]["id"] != null:
				leaderboards[leaderboard_key][arrayIdx]["id"] = item["player"]["id"]
				print("id type="+str(typeof(item["metadata"])))
				#if item.has("metadata") and item["metadata"] != "":
				leaderboards[leaderboard_key][arrayIdx]["metadata"] = item["metadata"]
			arrayIdx += 1

	print("[get_leaderboard]: LB="+str(leaderboards))

	print("[get_leaderboard]: end")
	
	return status


func submit_score(score : int, metadata : String = "") -> int:
	var data = { "score": str(score), "metadata": metadata }
	var headers : Array = ["Content-Type: application/json", "x-session-token:"+session_token]
	var result = await LootLocker.lootLockerUtils.send_http_request(Constants.LEADERBOARDS_URL+leaderboard_key+"/submit", headers, HTTPClient.METHOD_POST, data, {"rank": true})
	print("[submit_score]: result="+str(result))

	if result != null and typeof(result) == TYPE_DICTIONARY and result.size() > 0:
		if result.has("rank"):
			last_submitted_score_rank = result["rank"]

	return OK


func get_top_scores(count : int = 3) -> int:
	var status : int = OK
	print("[get_top_scores]: begin")
	
	status = await get_leaderboard(1,count)
	
	print("[get_top_scores]: end")
	
	return status


func get_scores_around_player(countBefore : int = 2, countAfter : int = countBefore) -> int:
	var status : int = OK
	print("[get_scores_around_player]: begin")
	LootLockerHelpers.dump_args({"countBefore": countBefore, "countAfter": countAfter})

	var headers : Array = ["Content-Type: application/json"]
	
	if session_token != "":
		headers.append("x-session-token: "+session_token)
	else:
		print("[get_scores_around_player]: no session token provided")
		status = ERR_INVALID_DATA
		#return

	#curl -X GET "https://api.lootlocker.io/game/leaderboards/1/member/1" lastp = player_id
	var player_id = player.PLAYERSDATA["player_id"]
	var url = Constants.LEADERBOARDS_URL + leaderboard_key + Constants.LEADERBOARDS_MEMBER_EP_URL + "/" + str(player_id)
	var result = await LootLocker.lootLockerUtils.send_http_request(url, headers, HTTPClient.METHOD_GET, {}, {"all": true})
	print("[get_scores_around_player]: result="+str(result))
	#{ "rank": 8, "member_id": "4812874", "score": 962757, "player": { "name": "newname11", "id": 4812874, "public_uid": "GXTLLY6C" }, "metadata": "" }
	
	if result != null and typeof(result) == TYPE_DICTIONARY and result.size() > 0:
		if result.has("rank"):
			print("rank is: "+str(result["rank"]))
		else:
			print("rank not found in result !")
			return ERR_INVALID_DATA
	else:
		print("invalid data received from previous call")
		return ERR_INVALID_DATA

	#suggested by Johannes from LL team
	#curl -X GET "https://api.lootlocker.io/game/leaderboards/1/list?count=10&after=49"
	var count = countBefore + countAfter + 1
	var after : int = result["rank"] - ceili(count / 2.0)
	#rk=8 c=6 aft=7 ??
	#	should be 5  rk-3 rk+3
	#	but here cb/ca = 2 => cb+ca=4 => rk-2,rk+2
	print("rk="+str(result["rank"])+"  c="+str(count)+" cb/2="+str(ceili(countBefore / 2.0))+ "  aft="+str(after))
	print("=============get scores around player rank==============")
	result = await get_leaderboard(1, count, after)
	print("[get_scores_around_player]: end")
	
	return status
