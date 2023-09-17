extends Control

var PlayerData : Dictionary = {
	"player_identifier": ""
}

@export var playerSlot : int = 2
var leaderboard_entry : PackedScene = preload("res://demo/scenes/leaderboard_entry.tscn")

func _ready():
	update_status("setting up...")
	#load from file
	LootLocker.setup("API_KEY", "DOMKEY", "0.0.0.1", true, true)
	
	# it use player created in guest_login_demo
	PlayerData["player_identifier"] = LootLocker.current_user.fetch_player_identifier(2)
	$MarginContainer/VBoxContainer/HBoxContainer/Button.disabled = true
	$MarginContainer/VBoxContainer/HBoxContainer2/NameButton.disabled = true

func _process(_delta):
	pass


func _on_login_pressed():
	update_status("logging in...")
	#coroutine or not should be hidden, caller shouldn't have to deal with this
	var result = await LootLocker.guest_login(PlayerData["player_identifier"])
	if result == OK:
		update_status("logged in")
		$MarginContainer/VBoxContainer/HBoxContainer/Button.disabled = false
		$MarginContainer/VBoxContainer/HBoxContainer2/NameButton.disabled = false
		LootLocker.add_leaderboard({"key": "LBKEY", "session-token": LootLocker.session.token})
	else:
		update_status("Fail to login !")


func _on_logout_pressed():
	update_status("logging out...")
	var result = await LootLocker.session.end_session(LootLocker.session.token)
	if result == OK:
		update_status("not logged")
		$MarginContainer/VBoxContainer/HBoxContainer/Button.disabled = true
		$MarginContainer/VBoxContainer/HBoxContainer2/NameButton.disabled = true
	else:
		update_status("Fail to logout !")


func _on_leaderboard_pressed():
	var result = await LootLocker.leaderboard.get_leaderboard({})
	print("leaderboard get res="+str(result))
	if result == OK:
		update_status("leaderboard aquired")
		print("LB="+str(LootLocker.leaderboard.data))
		fill_leaderboard($"MarginContainer/VBoxContainer/Leaderboard-data", LootLocker.leaderboard.data["scores"])
	else:
		update_status("Fail to get leaderboard !")

func update_status(text : String) -> void:
	$MarginContainer/VBoxContainer/Status.text = text
	
func fill_leaderboard(container : Node, data : Array):
	if container.get_child_count() > 0:
		for child in container.get_children():
			container.remove_child(child)
			child.queue_free()
	if Node != null and data != null and data.size() > 0:
		#data need to be sorted to be sure they're in order UNLESS server garanty they are already !
		var rank : int = 1
		var pName : String
		for item in data:
			var entry = leaderboard_entry.instantiate()
			if item["name"] != "":
				pName = item["name"]
			else:
				pName = item["public_uid"]
			entry.setup(rank, pName, item["score"], item["metadata"])
			container.add_child(entry)
			rank += 1


func _on_button_pressed():
	var score : String = $MarginContainer/VBoxContainer/HBoxContainer/TextEdit.text
	if score != "" and score.is_valid_int():
		var scoreToSubmit = int(score)
		
		var result = await LootLocker.leaderboard.submit_score(scoreToSubmit)
		print("submit_score res="+str(result))
		if result == OK:
			update_status("score submitted successfully")
		else:
			update_status("score not submitted !")
	else:
		update_status("Invalid score submitted !")


func _on_name_button_pressed():
	var playerName : String = $MarginContainer/VBoxContainer/HBoxContainer2/TextEdit.text
	var result = await LootLocker.current_user.set_player_name(playerName)
	print("set_player_name res="+str(result))
	if result == OK:
		update_status("player's name set successfully")
	else:
		update_status("player's name not modified !")
