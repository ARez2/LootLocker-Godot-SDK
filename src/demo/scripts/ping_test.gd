extends Control

var PlayerData : Dictionary = {
	"player_identifier": ""
}


func _ready():
	LootLocker.setup("API_KEY", "DOMKEY", "0.0.0.1", true, true)
	PlayerData["player_identifier"] = LootLocker.current_user.fetch_player_identifier()
	
	var result = await LootLocker.guest_login(PlayerData["player_identifier"])
	if result == OK:
		print("logged in")
		LootLocker.misc.session_token = LootLocker.session.token
	else:
		print("Fail to login !")


func _on_ping_pressed():
	var result = await LootLocker.misc.ping()
	if result == OK:
		print("ping ok")
		$VBoxContainer/ServerTimeValue.text = LootLocker.misc.date
	else:
		print("ping failed !")
