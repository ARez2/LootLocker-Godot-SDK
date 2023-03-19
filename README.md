# LootLocker-Godot-SDK

## Disclaimer
This was just the beginning of an SDK for Godot. The LootLocker Team said that it has plans for an official Godot SDK, but as for now, this is what I came up with.
It also by far does not cover all the LootLocker features as I have just added the most important features that I needed. Those include
- User authentication
- Leaderboards
- (WIP) User Data (XP, Level)


## Quick Start

- Create a leaderboard with the id `live_scores` on LootLocker and enable GameAPI writes
- Add a few 
- Put the files from this repos `src/` into `your/project/folder/addons/LootLockerSDK/`
- Add `res://addons/LootLockerSDK/LootLocker.gd` as Autoload
- Open and run (maybe a couple of times) the `loot_locker_demo.tscn` inside the SDK folder. This scene first authorizes the user using a LootLocker guest login, then fetches scores from the leaderboard, then submits a new score

## Storing the user for later authentication
At the moment, whenever the users restarts your game, a new LootLocker Guest account is created. For a recent game I used the following modifications to enable cross-session login.

TLDR: Save and load the `player_identifier` from a file and provide that to the authentification

### Game State Autoload
I created a GameState.gd script and set it as Autoload. It is responsible for saving and loading the Settings and also the LootLocker identifier.

This basic code should get you started:

```gdscript
# gamestate.gd

extends Node


# Gets set by the save/ load system
var lootlocker_identifier = ""

func _ready() -> void:
	load_save()
	# Load game
	await LootLocker.try_authorize(lootlocker_identifier)


func _exit_tree() -> void:
	save_game()


func save_game():
    var file = FileAccess.open_encrypted_with_pass("user://gamename.save", FileAccess.WRITE, "password")
    var state = {
        "lootlocker_identifier": lootlocker_identifier,
        # Optionally store settings here
    }
    var string = JSON.stringify(state, "    ")
    file.store_string(str(string))

func load_save():
    var file = FileAccess.open_encrypted_with_pass("user://gamename.save", FileAccess.READ, "password")
    if file == null:
        return
    var content = file.get_as_text()
    var json = JSON.parse_string(content)
    lootlocker_identifier = json.get("lootlocker_identifier", "")
    
