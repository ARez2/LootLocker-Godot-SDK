extends Node
class_name LootLockerHelpers

static func dump_args(args : Dictionary) -> void:
	var output : String = ""
	for key in args:
		output += str(key) + "=[" + str(args[key]) + "] - "
		
	print(output)


static func check_compatibility(version : String) -> int:
	print("Check version ["+version+"] vs "+"...")
	return OK
