extends Control

func _ready():
	await LootLocker.try_authorize()
	LootLocker.submit_score()
	LootLocker.retrieve_score()
