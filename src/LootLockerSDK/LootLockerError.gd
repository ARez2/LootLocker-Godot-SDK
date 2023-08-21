class_name LootLockerError

var error = ""
var error_message = ""

# code & text comes from https://ref.lootlocker.com/game-api/#errors
static var Errors : Dictionary = {
	400 : "Bad Request -- Your request has an error",
	402 : "Payment Required -- Payment failed. Insufficient funds, etc.",
	401 : "Unathorized -- Your session_token is invalid",
	403 : "Forbidden -- You do not have access",
	404 : "Not Found",
	405 : "Method Not Allowed",
	406 : "Not Acceptable -- Purchasing is disabled",
	409 : "Conflict -- Your state is most likely not aligned with the servers.",
	429 : "Too Many Requests -- You're being limited for sending too many requests too quickly.",
	500 : "Internal Server Error -- We had a problem with our server. Try again later.",
	503 : "Service Unavailable -- We're either offline for maintenance, or an error that should be solvable by calling again later was triggered."
}
