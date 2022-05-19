extends Control

func _ready():
	await LootLocker.try_authorize()
	var res : LootLockerLeaderboardsResponse = await LootLocker.leaderboards.get_score_list("live_scores")
	for r in res.result:
		printt(r.player.id, r.score)
