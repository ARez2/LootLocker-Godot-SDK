extends Control

var PlayersaveIdx : int = 0
var PlayerData : Dictionary = {
	"player_identifier": ""
}

func _ready():
	update_status("setting up...")
	LootLocker.setup("API_KEY", "DOMKEY", "0.0.0.1", $"VBoxContainer/DevMode CB".button_pressed)
	
	$"VBoxContainer/HBoxContainer1/gameAPI Input".placeholder_text = LootLocker.API_KEY
	if LootLocker.API_KEY.begins_with("dev_") == true:
		$"VBoxContainer/DevMode CB".button_pressed = true 
		
	#signal no longer emitted
	#LootLocker.logged_in.connect(_ll_connected)

func _on_login_pressed():
	print("logging in...")
	update_status("login...")
	
	var result = await LootLocker.guest_login(PlayerData["player_identifier"])
	#print("opinprogress="+str(LootLocker.operation_in_progress))
	if result == OK:
		print("logged in")
		update_status("logged in")
		#print("opinprogress2="+str(LootLocker.operation_in_progress))
		print("LLobj="+str(LootLocker))
		print("LLsessobj="+str(LootLocker.session))
		print("LLplayer="+LootLocker.current_user.dump_data())
		
		$VBoxContainer/HBoxContainer4/session_token_value.text = LootLocker.session.token
		$VBoxContainer/HBoxContainer3/Player_id_value.text = LootLocker.current_user.PLAYERSDATA["player_identifier"]
		
		PlayerData["player_identifier"] = LootLocker.current_user.PLAYERSDATA["player_identifier"]
		PlayerData["player_name"] = LootLocker.current_user.PLAYERSDATA["player_name"]
		PlayerData["player_id"] = LootLocker.current_user.PLAYERSDATA["player_id"]
		PlayerData["public_uid"] = LootLocker.current_user.PLAYERSDATA["public_uid"]
		#$VBoxContainer/HBoxContainer4/session_token_value.text = LootLocker.session.token
		
		if PlayerData["player_name"] == "":
			PlayerData["player_name"] = "new name"

	else:
		update_status("ERROR")


func _on_logout_pressed():
	print("logging out...")
	if LootLocker.session != null:
		update_status("logout...")
		LootLocker.session.end_session(LootLocker.session.token)
		$VBoxContainer/HBoxContainer4/session_token_value.text = "not logged in"
	else:
		update_status("not logged !")


func _on_game_api_input_text_changed():
	$"VBoxContainer/DevMode CB".button_pressed = false
	if $"VBoxContainer/HBoxContainer1/gameAPI Input".text.begins_with("dev_") == true:
		$"VBoxContainer/DevMode CB".button_pressed = true 


func update_status(new_status : String = "unknow") -> void:
	$"VBoxContainer/Status".text = new_status


func _on_load_player_pressed():
	print("load player data from disk")
	PlayerData["player_identifier"] = LootLocker.current_user.fetch_player_identifier(PlayersaveIdx)
	$VBoxContainer/HBoxContainer3/Player_id_value.text = PlayerData["player_identifier"]


func _on_save_player_pressed():
	print("save player data to disk")
	LootLocker.current_user.store_player_identifier(PlayerData["player_identifier"], PlayersaveIdx)


func _on_h_slider_value_changed(value : float):
	$VBoxContainer/HBoxContainer6/PlayerIdx.text = str(int(value))
	PlayersaveIdx = int(value)


func _on_delete_pressed():
	var result = await LootLocker.current_user.delete_player()
	print("del: res="+str(result))
