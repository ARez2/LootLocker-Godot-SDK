class_name LootLockerLeaderboardResult
# Wrapper class to store the placement data returned by the API
# If requesting data from a Leaderboard of type 'player' (NOT 'generic') the player
# Variable is filled with a LootLockerUser wrapper-class (includes name, id, currency etc.)

var member_id : int = 0
var rank : int = 0
var score : int = 0
var player : LootLockerUser = null # LootLockerUser
var metadata = null
