extends Node2D


func _ready():
	await LootLocker.try_authorize() # Wait to finish
	LootLocker.submit_score()
	LootLocker.retrieve_score()
