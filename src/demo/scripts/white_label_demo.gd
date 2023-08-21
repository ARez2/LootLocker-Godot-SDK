extends Control

#var PlayerData : Dictionary = {
	#"player_identifier": ""
#}
var token : String = ""

func _ready():
	LootLocker.setup("API_KEY", "DOMKEY", "0.0.0.1", true, true)
	update_status("ready")


func _on_sign_up_pressed():
	update_status("signing up")
	
	var email = $VBoxContainer/EmailBox/emailAddress.text
	var password = $VBoxContainer/PasswordBox/password.text

	var result = await LootLocker.white_label_signup(email, password)
	if result == OK:
		update_status("email sent")
	else:
		update_status("an error occured")


func _on_sign_in_pressed():
	update_status("signing in")
	
	var email = $VBoxContainer/EmailBox/emailAddress.text
	var password = $VBoxContainer/PasswordBox/password.text
	var remember = $VBoxContainer/ButtonBox/Remember.button_pressed
	
	var result = await LootLocker.white_label_login(email, password, remember)
	if result == OK:
		update_status("logged in")
		update_token(LootLocker.session.token)
	else:
		update_status("an error occured")


func _on_verify_pressed():
	update_status("check token...")
	var token_status = "unchecked"
	var email = $VBoxContainer/EmailBox/emailAddress.text
	token = $VBoxContainer/VBoxContainer/Token.text
	
	var result = await LootLocker.verify_session(token, email)
	
	#not good here, rs=400 => get text ex "error":"Bad Request","message":"no session found"
	#no email provided: "error":"Bad Request","message":"email is missing in input",
	if result == OK:
		token_status = "valid"
	else:
		token_status = "unknow"

	update_status("token checked successfully: "+token_status)


func _on_verify_user_pressed():
	update_status("check user...")
	var user_status = "unchecked"
	var userid = $VBoxContainer/VBoxContainer2/UserId.text
	var email = $VBoxContainer/VBoxContainer2/EmailAddress.text

	var result = await LootLocker.request_user_verification(int(userid), email)
	#result ok (204) not well processed to here !
	if result == OK:
		user_status = "valid"
	else:
		user_status = "unknow"

	update_status("user checked successfully: "+user_status)


func _on_reset_password_pressed():
	update_status("reset password...")
	var email = $VBoxContainer/VBoxContainer3/EmailAddress.text

	var result = await LootLocker.request_password_reset(email)

	if result == OK:
		update_status("password reset successfully")
	else:
		update_status("an error occured")


func _on_delete_wl_session_pressed():
	update_status("deleting session...")
	#may not need to give token as it is loaded for us !
	print("token = "+token)
	if token == "":
		if $VBoxContainer/VBoxContainer/Token.text != "":
			token = $VBoxContainer/VBoxContainer/Token.text
			print("token2 = "+token)
		elif $VBoxContainer/HBoxContainer/SessionToken.text != "":
			token = $VBoxContainer/HBoxContainer/SessionToken.text
			print("token3 = "+token)
	
	if token != "":
		var result = await LootLocker.delete_white_label_session(token)

		if result == OK:
			update_status("session deleted successfully")
			update_token("no active session")
			token = ""
		else:
			update_status("an error occured")
	else:
		update_status("no session token provided")


func update_status(text : String) -> void:
	$VBoxContainer/HBoxContainer/Status.text = text
	
func update_token(token_value : String) -> void:
	$VBoxContainer/HBoxContainer/SessionToken.text = token_value
