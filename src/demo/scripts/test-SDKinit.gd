extends Control

# this scene is made to help setup the SDK using your own keys obtained from
# LootLocker web console

# the dummy values here won't work and must be replaced by your own, then you can run the scene

func _ready():
	LootLockerDataVault.API_KEY="myAPIKEY"
	LootLockerDataVault.SERVER_API_KEY="myserverAPIKEY"
	LootLockerDataVault.DOMAIN_KEY="myDomainKey"
	LootLockerDataVault.GAME_VERSION="1.2.3.4"

	var sok = LootLockerDataVault.save_sdk_data()
	print("sok= "+str(sok))
