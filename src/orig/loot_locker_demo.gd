extends Control

func _ready():
	await LootLocker.try_authorize()
	var res : LootLockerLeaderboardsResponse = await LootLocker.leaderboards.get_score_list("live_scores", 3, 3)
	if typeof(res) == TYPE_DICTIONARY:
		for r in res.result:
			printt(r.rank, r.player.id, r.score)
	var sub : LootLockerLeaderboardsResponse = await LootLocker.leaderboards.submit_score("live_scores", 333)
