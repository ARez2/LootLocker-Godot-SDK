extends Control

# This load scene is mostly use as debug purpose to be sure the SDK init was done properly
# through sdk_init-save scene
# If you've done things right, you should get back the data you've set up previously.

func _ready():
	#LootLockerDataVault.API_KEY="aaa"
	#LootLockerDataVault.SERVER_API_KEY="bbb"
	#LootLockerDataVault.DOMAIN_KEY="ddd"
	#LootLockerDataVault.GAME_VERSION="0.0.1.1"

	#var pok = LootLockerDataVault.check_password()
	#print("pok ="+str(pok))
	
	#var sok = LootLockerDataVault.save_sdk_data()
	#print("sok ="+str(sok))
	
	var lok = LootLockerDataVault.load_sdk_data()
	print("lok= "+str(lok))
	
	print("API_KEY="+LootLockerDataVault.API_KEY)
	print("DOMAIN_KEY="+LootLockerDataVault.DOMAIN_KEY)
	print("GAME_VERSION="+LootLockerDataVault.GAME_VERSION)
