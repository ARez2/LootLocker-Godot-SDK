extends Control

var namesData : Dictionary
var maxToGenerate : int

func _ready():
	LootLocker.setup("API_KEY", "DOMKEY", "0.0.0.1", true, true)
	randomize()
	
	namesData = load_names_data()


func _on_button_pressed():
	var number : int = randi_range(1,maxToGenerate) #(10,1000)
	$VBoxContainer/HBoxContainer/Label.text = "will generate %d players" % number
	
	var created : int = 0
	var playerName = ""
	var randomIdx : int
	var result
	
	for count in range(0, number):
		result = await LootLocker.guest_login()
		if result == OK:
			created += 1
			
			LootLocker.leaderboard.session_token = LootLocker.session.token
			LootLocker.leaderboard.leaderboard_key = "LBKEY"	#tochange
			
			randomIdx = randi_range(0, 99)
			playerName = namesData["first names"][randomIdx] + " "
			randomIdx = randi_range(0, 99)
			playerName += namesData["last names"][randomIdx]
			print("PN="+playerName)
			
			result = await LootLocker.current_user.set_player_name(playerName)
			if result == OK:
				print("player's name set successfully")
			else:
				pass
				
			#get player pub_uid
			if $VBoxContainer/HBoxContainer/CheckBox.button_pressed == true:
				#meta: OS.get_unix_time_from_system()
				result = await LootLocker.leaderboard.submit_score(randi_range(1000,1000000))
				if result == OK:
					print("player's score submitted successfully")
				else:
					pass
		else:
			$VBoxContainer/HBoxContainer/Label.text = "guest login error !"
		$Label2.text = "generating players... %d/%d" % [created, number]

	$VBoxContainer/HBoxContainer/Label.text = "generated %d players on expected %d" % [created, number]


func load_names_data() -> Dictionary:
	var status = OK
	
	var firstnames : Array  = []
	firstnames.resize(100)
	var lastnames : Array = []
	lastnames.resize(100)
	
	var idx : int = 0

	var file = FileAccess.open("res://data/btn_givennames-100.txt", FileAccess.READ)
	if file != null:
		var fname = file.get_line().get_slice("\t", 0)
		#print("fn="+fname+"  eof="+str(file.eof_reached()))
		while !file.eof_reached():
			if fname != "" and !fname.begins_with("#"):
				firstnames[idx] = fname
				idx += 1
			fname = file.get_line().get_slice("\t", 0)
			#print("fn="+fname+"  eof="+str(file.eof_reached()))
		if fname != "" and !fname.begins_with("#"):
			firstnames[idx] = fname
		file.close()
	else:
		pass

	idx = 0
	file = FileAccess.open("res://data/btn_surnames-100.txt", FileAccess.READ)
	if file != null:
		var sname = file.get_line()
		#print("sn="+sname+"  eof="+str(file.eof_reached()))
		while !file.eof_reached():
			if sname != "" and !sname.begins_with("#"):
				lastnames[idx] = sname
				idx += 1
			sname = file.get_line()
			#print("sn="+sname+"  eof="+str(file.eof_reached()))
		if sname != "" and !sname.begins_with("#"):
			lastnames[idx] = sname

		file.close()
	else:
		pass

	print("FN="+str(firstnames))
	print("LN="+str(lastnames))
	return {"status": status, "first names": firstnames, "last names": lastnames}


func _on_h_slider_value_changed(value : float) -> void:
	$VBoxContainer/HBoxContainer/Count.text = str(value)
	maxToGenerate = int(value)
