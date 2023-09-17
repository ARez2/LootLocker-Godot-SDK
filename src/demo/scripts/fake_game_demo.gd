extends Control

var PlayerData : Dictionary = {
	"player_identifier": ""
}

var leaderboard_entry : PackedScene = preload("res://demo/scenes/leaderboard_entry.tscn")

@export var LeaderboardKey : String = ""
@export var lower_score : int
@export var upper_score : int

func _ready():
	update_status("guest login...")
	var lok = LootLockerDataVault.load_sdk_data()
	print("lok ="+str(lok))
	#LootLocker.setup_from_file()
	#add lb id/key
	#get keys from file
	LootLocker.setup("API_KEY", "DOMKEY", "0.0.0.1", true, true)
	PlayerData["player_identifier"] = LootLocker.current_user.fetch_player_identifier(2)
	
	var result = await LootLocker.guest_login(PlayerData["player_identifier"])
	if result == OK:
		update_status("logged in (as guest)")
		#LootLocker.leaderboard.session_token = LootLocker.session.token
		#LootLocker.leaderboard.player = LootLocker.current_user
		#LootLocker.leaderboard.leaderboard_key = LeaderboardKey
		var pname : String = ""
		if LootLocker.current_user.PLAYERSDATA["player_name"] != "":
		#if PlayerData["player_name"] != "":
			pname = LootLocker.current_user.PLAYERSDATA["player_name"] #PlayerData["player_name"]
		else:
			pname = LootLocker.current_user.PLAYERSDATA["public_uid"] #PlayerData["public_uid"]
		$VBoxContainer/PlayerName.text = "Your name: "+pname
		
		LootLocker.add_leaderboard({"key": LeaderboardKey, "session-token": LootLocker.session.token})
	else:
		update_status("login error !")
	
	
func update_status(newStatus : String) -> void:
	$VBoxContainer/Status.text = "Status: " + newStatus


func _on_play_pressed():
	update_status("playing game...")
	$VBoxContainer/Play.disabled = true
	await get_tree().create_timer(3).timeout
	var score : int = randi_range(lower_score,upper_score)
	update_status("game over, get score: "+str(score))
	$VBoxContainer/Score.text = "Your score: "+str(score)
	await get_tree().create_timer(1.0).timeout
	
	update_status("submitting score...")
	var result = await LootLocker.leaderboard.submit_score(score)
	print("submit_score res="+str(result))
	if result == OK:
		update_status("score submitted successfully")
	else:
		update_status("Error: score not submitted !")

	#submit score return rank ! use it to know which entry to higlight

	$VBoxContainer/Score.visible = true
	$VBoxContainer/Leaderboard.visible = true
	$VBoxContainer/Back.visible = true
	
	result = await LootLocker.leaderboard.get_scores_around_player(2,2)
	print("leaderboard gsap res="+str(result))
	
	if result == OK:
		update_status("leaderboard aquired")
		print("LB="+str(LootLocker.leaderboard.data))
		fill_leaderboard($VBoxContainer/Leaderboard, LootLocker.leaderboard.data["scores"])
	else:
		update_status("Fail to get leaderboard !")


func _on_back_pressed():
	$VBoxContainer/Play.disabled = false
	await get_tree().create_timer(0.5).timeout
	$VBoxContainer/Score.visible = false
	$VBoxContainer/Leaderboard.visible = false
	$VBoxContainer/Back.visible = false


func fill_leaderboard(container : Node, data : Array):
	if container.get_child_count() > 0:
		for child in container.get_children():
			container.remove_child(child)
			child.queue_free()
	if Node != null and data != null and data.size() > 0:
		#data need to be sorted to be sure they're in order UNLESS server garanty they are already !
		var pName : String
		var color : Color
		for item in data:
			var entry = leaderboard_entry.instantiate()
			if item["name"] != "":
				pName = item["name"]
			else:
				pName = item["public_uid"]
			#print("rk="+str(item["rank"])+"/"+str(LootLocker.leaderboard.last_submitted_score_rank))
			if item["rank"] == LootLocker.leaderboard.last_submitted_score_rank:
				color = Color.DARK_TURQUOISE
			else:
				color = Color.WHITE

			entry.setup(item["rank"], pName, item["score"], item["metadata"])
			entry.highlight_entry(color)
			
			container.add_child(entry)
