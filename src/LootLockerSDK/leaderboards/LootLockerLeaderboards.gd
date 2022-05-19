class_name LootLockerLeaderboards

signal retrieved_leaderboard_result(leaderboards_response : LootLockerLeaderboardsResponse)


func get_member_rank(leaderboard_name : String, member_id : int = LootLocker.current_user.id) -> LootLockerLeaderboardsResponse:
	if member_id != null:
		LootLocker.send_request("leaderboards/%s/member/%s" \
		% [leaderboard_name, str(member_id)], null, on_retrieve_leaderboard_result.bind("members"), HTTPClient.METHOD_GET)
		var response = await retrieved_leaderboard_result
		return response
	return null


func get_member_list_ranks(leaderboard_name : String, member_ids : Array[int]) -> LootLockerLeaderboardsResponse:
	var data = {
		"members": member_ids,
	}
	LootLocker.send_request("leaderboards/%s/members" % leaderboard_name, data, on_retrieve_leaderboard_result.bind("members"), HTTPClient.METHOD_GET)
	var response = await retrieved_leaderboard_result
	return response



func get_all_members_ranks(member_id: int = LootLocker.current_user.id) -> LootLockerLeaderboardsResponse:
	print("Not working right now.")
	return null
	LootLocker.send_request("leaderboards/member/%s" % member_id, null, on_retrieve_leaderboard_result, HTTPClient.METHOD_GET)
	var response = await retrieved_leaderboard_result
	return response


func get_score_list(leaderboard_name : String, count: int = 3, after: int = 0) -> LootLockerLeaderboardsResponse:
	LootLocker.send_request("leaderboards/%s/list?count=%s&after=%s" \
	#% [leaderboard_name, count, after], null, on_retrieve_leaderboard_result, HTTPClient.METHOD_GET)
	% [leaderboard_name, count, after], null, on_retrieve_leaderboard_result.bind("items"), HTTPClient.METHOD_GET)
	var response = await retrieved_leaderboard_result
	return response





func extract_result(from_dict) -> LootLockerLeaderboardResult:
	var res = LootLockerLeaderboardResult.new()
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

func on_retrieve_leaderboard_result(response : Dictionary, grouping_name : String = ""):
	var leaderboards_response := LootLockerLeaderboardsResponse.new()
	var results : Array[LootLockerLeaderboardResult] = []
	var pag : LootLockerLeaderboardPagination = null
	
	var error = response.get("error")
	if error != null and error != "":
		print("Error when fetching response: ", error)
		print("Error message: ", response.get("message"))
		return leaderboards_response
	
	if response.get(grouping_name) != null:
		for member in response.get(grouping_name):
			results.append(extract_result(member))
	else:
		results.append(extract_result(response))
		
	if response.get("pagination") != null:
		var pag_dict : Dictionary = response.get("pagination")
		pag = LootLockerLeaderboardPagination.new()
		pag.total = int(pag_dict.get("total"))
		pag.next_cursor = int(pag_dict.get("next_cursor"))
		if pag_dict.get("previous_cursor") != null and pag_dict.get("previous_cursor") != "null":
			pag.previous_cursor = int(pag_dict.get("previous_cursor"))
	
	leaderboards_response.result = results
	leaderboards_response.pagination = pag
	
	retrieved_leaderboard_result.emit(leaderboards_response)
