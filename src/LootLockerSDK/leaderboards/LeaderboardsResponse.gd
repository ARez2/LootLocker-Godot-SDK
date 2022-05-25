class_name LootLockerLeaderboardsResponse
# Just holds the result and pagination classes. Useful for making sure our SDK
# always returns the same stuff

var result : Array[LootLockerLeaderboardResult] = []
var pagination : LootLockerLeaderboardPagination = null
var error : LootLockerError = null