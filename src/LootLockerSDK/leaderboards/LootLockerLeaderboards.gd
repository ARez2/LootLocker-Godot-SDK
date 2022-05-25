class_name LootLockerLeaderboards

signal retrieved_leaderboard_result(leaderboards_response)

# TODO:
# https://ref.lootlocker.io/game-api/#get-all-member-ranks
# https://ref.lootlocker.io/game-api/#get-score-list
# https://ref.lootlocker.io/game-api/#submit-score




func extract_result(from_dict) -> LootLockerLeaderboardResult:
	var res = LootLockerLeaderboardResult.new()
	if !from_dict.has("member_id"):
		return null
	res.member_id = from_dict.get("member_id").to_int()
	res.rank = from_dict.get("rank")
	res.score = from_dict.get("score")
	if from_dict.get("player") != null:
		var p : Dictionary = from_dict.get("player")
		var player = LootLockerUser.new()
		player.id = int(p.get("id"))
		player.public_uid = p.get("public_uid")
		player.name = p.get("name")
		res.player = player
	res.metadata = from_dict.get("metadata")
	return res

func on_retrieve_leaderboard_result(response : Dictionary, grouping_name := ""):
	var leaderboards_response := LootLockerLeaderboardsResponse.new()
	var results = []
	var pag : LootLockerLeaderboardPagination = null
	
	var error = response.get("error")
	if error != null and error != "":
		var err = LootLockerError.new()
		err.error_string = error + ": " + response.get("message")
		leaderboards_response.error = err
		return leaderboards_response
		
	if response.get(grouping_name) != null:
		for member in response.get(grouping_name):
			var r = extract_result(member)
			if r == null:
				var err = LootLockerError.new()
				err.error_string = "Recieved wrong API response. Make sure every previous API Call is completed using yield/ await"
				leaderboards_response.error = err
			else:
				results.append(r)
	else:
		var r = extract_result(response)
		if r == null:
			var err = LootLockerError.new()
			err.error_string = "Recieved wrong API response. Make sure every previous API Call is completed using yield/ await"
			leaderboards_response.error = err
		else:
			results.append(r)
		
	if response.get("pagination") != null:
		var pag_dict : Dictionary = response.get("pagination")
		pag = LootLockerLeaderboardPagination.new()
		pag.total = int(pag_dict.get("total"))
		pag.next_cursor = int(pag_dict.get("next_cursor"))
		if pag_dict.get("previous_cursor") != null:
			pag.previous_cursor = int(pag_dict.get("previous_cursor"))
	
	leaderboards_response.result = results
	leaderboards_response.pagination = pag
	
	emit_signal("retrieved_leaderboard_result", leaderboards_response)
	return leaderboards_response



func get_member_rank(leaderboard_name : String, member_id : int = LootLocker.current_user.id) -> LootLockerLeaderboardsResponse:
	if member_id != null:
		LootLocker.send_request("leaderboards/%s/member/%s" \
		% [leaderboard_name, str(member_id)], null, HTTPClient.METHOD_GET)
		var res = yield(LootLocker, "api_response")
		res = on_retrieve_leaderboard_result(res)
		return res
	return null


func get_member_list_ranks(leaderboard_name : String, member_ids) -> LootLockerLeaderboardsResponse:
	var data = {
		"members": member_ids,
	}
	LootLocker.send_request("leaderboards/%s/members" % leaderboard_name, data, HTTPClient.METHOD_GET)
	var res = yield(LootLocker, "api_response")
	res = on_retrieve_leaderboard_result(res, "members")
	return res



func get_all_members_ranks(member_id: int = LootLocker.current_user.id) -> LootLockerLeaderboardsResponse:
	print("Not working right now.")
	return null
	LootLocker.send_request("leaderboards/member/%s" % member_id, null, HTTPClient.METHOD_GET)
	var res = yield(LootLocker, "api_response")
	res = on_retrieve_leaderboard_result(res, "members")
	return res


func get_score_list(leaderboard_name : String, count: int = 3, after: int = 0) -> LootLockerLeaderboardsResponse:
	LootLocker.send_request("leaderboards/%s/list?count=%s&after=%s" \
	#% [leaderboard_name, count, after], null, on_retrieve_leaderboard_result, HTTPClient.METHOD_GET)
	% [leaderboard_name, count, after], null, HTTPClient.METHOD_GET)
	var res = yield(LootLocker, "api_response")
	res = on_retrieve_leaderboard_result(res, "items")
	return res



func submit_score(leaderboard_name : String, score : int, member_id : int = LootLocker.current_user.id, metadata = null) -> LootLockerLeaderboardsResponse:
	var data = {
		"member_id": str(member_id),
		"score": score,
		"metadata": metadata,
	}
	LootLocker.send_request("leaderboards/%s/submit" % leaderboard_name, data)
	var res = yield(LootLocker, "api_response")
	res = on_retrieve_leaderboard_result(res)
	return res


