extends Node

var test: String = "test"

func _ready() -> void:
	var a: int = my_func(5)
	if a == 5:
		print(test)



func my_func(my_test: int) -> int:
	return 0 + my_test
