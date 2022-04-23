class_name LootLockerLeaderboards

signal retrieved_leaderboard_result(result)


func get_member_rank(leaderboard_name : String, member_id : int = LootLocker.current_user.id) -> LootLockerLeaderboardResult:
	if member_id != null:
		LootLocker.send_request("leaderboards/%s/member/%s" \
		% [leaderboard_name, str(member_id)], null, on_retrieve_leaderboard_result, HTTPClient.METHOD_GET)
		var result : Array[LootLockerLeaderboardResult] = await retrieved_leaderboard_result
		if result.size() > 0:
			return result.front()
	return null


func get_member_list_ranks(leaderboard_name : String, member_ids : Array[int]) -> Array[LootLockerLeaderboardResult]:
	var data = {
		"members": member_ids,
	}
	LootLocker.send_request("leaderboards/%s/members" % leaderboard_name, data, on_retrieve_leaderboard_result)
	var result : Array[LootLockerLeaderboardResult] = await retrieved_leaderboard_result
	return result


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
func on_retrieve_leaderboard_result(response : Dictionary):
	var results : Array[LootLockerLeaderboardResult] = []
	
	if response.get("members") != null:
		for member in response.get("members"):
			results.append(extract_result(member))
	else:
		results.append(extract_result(response))
	retrieved_leaderboard_result.emit(results)
