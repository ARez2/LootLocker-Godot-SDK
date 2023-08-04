class_name LootLockerLeaderboards

# Used to adress the Leaderboards part of the LootLocker API
# Often returns the LootLockerLeaderboardsResponse wrapper-class which includes the result of
# the API request (rank, score, member) and may include a pagination class (if returned in the response)


# Emitted once the API responds to the request and the returned data has been processed
signal retrieved_leaderboard_result(leaderboards_response : LootLockerLeaderboardsResponse)

# TODO:
# https://ref.lootlocker.io/game-api/#get-all-member-ranks


# Get rank for single member for a leaderboard
func get_member_rank(leaderboard_name : String, member_id : int = LootLocker.current_user.id) -> LootLockerLeaderboardsResponse:
	if member_id != null:
		LootLocker.send_request("leaderboards/%s/member/%s" \
		% [leaderboard_name, str(member_id)], null, on_retrieve_leaderboard_result.bind("members"), HTTPClient.METHOD_GET)
		var response = await retrieved_leaderboard_result
		return response
	return null


# Get ranks for list of members for a leaderboard. This can be helpful when getting a players friends on leaderboard
func get_member_list_ranks(leaderboard_name : String, member_ids : Array[int]) -> LootLockerLeaderboardsResponse:
	var data = {
		"members": member_ids,
	}
	LootLocker.send_request("leaderboards/%s/members" % leaderboard_name, data, on_retrieve_leaderboard_result.bind("members"), HTTPClient.METHOD_GET)
	var response = await retrieved_leaderboard_result
	return response



# Get all leaderboards with member information on the ones the member is on, with rank and score
func get_all_members_ranks(member_id: int = LootLocker.current_user.id) -> LootLockerLeaderboardsResponse:
	print("Not working right now.")
	return null
	LootLocker.send_request("leaderboards/member/%s" % member_id, null, on_retrieve_leaderboard_result, HTTPClient.METHOD_GET)
	var response = await retrieved_leaderboard_result
	return response


# Get list of members in rank range. Result is sorted by rank ascending.
# Maximum allowed members to query for at a time is currently 2000.
func get_score_list(leaderboard_name : String, count: int = 3, after: int = 0) -> LootLockerLeaderboardsResponse:
	# Cap the requested members to the API limit
	count = min(count, 2000)

	LootLocker.send_request("leaderboards/%s/list?count=%s&after=%s" \
	#% [leaderboard_name, count, after], null, on_retrieve_leaderboard_result, HTTPClient.METHOD_GET)
	% [leaderboard_name, count, after], null, on_retrieve_leaderboard_result.bind("items"), HTTPClient.METHOD_GET)
	var response = await retrieved_leaderboard_result
	return response



# Submit scores for member on leaderboard. The member_id in the Game API is automatically
# filled with the currently authenticated players id.
func submit_score(leaderboard_name : String, score : int, member_id : int = LootLocker.current_user.id, metadata = null) -> LootLockerLeaderboardsResponse:
	var data = {
		"member_id": str(member_id),
		"score": score,
		"metadata": metadata,
	}
	LootLocker.send_request("leaderboards/%s/submit" % leaderboard_name, data, on_retrieve_leaderboard_result)
	var response = await retrieved_leaderboard_result
	return response



# Creates and returns a LootLockerLeaderboardResult class which stores the values returned by the API
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

# Used as callback, is called by LootLocker.gd in the '_http_request_completed' method
func on_retrieve_leaderboard_result(response : Dictionary, grouping_name : String = ""):
	# Initializes the required classes so if there are errors, at least return empty objects
	var leaderboards_response := LootLockerLeaderboardsResponse.new()
	var results : Array[LootLockerLeaderboardResult] = []
	var pag : LootLockerLeaderboardPagination = null
	
	# Catches 'Error' Responses by LootLocker
	var error = response.get("error")
	if error != null and error != "":
		var err = LootLockerError.new()
		err.error = error
		err.error_message = response.get("message")
		leaderboards_response.error = err
		return leaderboards_response
	
	# Sometimes the response data is wrapped in an extra JSON header
	if response.get(grouping_name) != null:
		for member in response.get(grouping_name):
			results.append(extract_result(member))
	else:
		results.append(extract_result(response))
	
	# If pagination data is returned by the API, fill the LootLockerPagination class with this data
	if response.get("pagination") != null:
		var pag_dict : Dictionary = response.get("pagination")
		pag = LootLockerLeaderboardPagination.new()
		pag.total = int(pag_dict.get("total"))
		pag.next_cursor = int(pag_dict.get("next_cursor"))
		if pag_dict.get("previous_cursor") != null:
			pag.previous_cursor = int(pag_dict.get("previous_cursor"))
	
	leaderboards_response.result = results
	leaderboards_response.pagination = pag
	
	retrieved_leaderboard_result.emit(leaderboards_response)
