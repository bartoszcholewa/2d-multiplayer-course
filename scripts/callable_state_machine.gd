class_name CallableStateMachine

var state_dictionary: Dictionary = {}
var current_state: StringName


func add_states(
	normal_state_callable: Callable,
	enter_state_callable: Callable,
	exit_state_callable: Callable
) -> void:
	state_dictionary[normal_state_callable.get_method()] = {
		"normal": normal_state_callable,
		"enter": enter_state_callable,
		"exit": exit_state_callable
	}


func set_initial_state(state_callable: Callable) -> void:
	var state_name: StringName = state_callable.get_method()
	if state_dictionary.has(state_name):
		_set_state(state_name)
	else:
		push_warning("No state with name " + state_name)


func update() -> void:
	if current_state != null:
		var normal_state: Callable = state_dictionary[current_state].normal
		normal_state.call()


func change_state(state_callable: Callable) -> void:
	var state_name: StringName = state_callable.get_method()
	if state_dictionary.has(state_name):
		_set_state.call_deferred(state_name)
	else:
		push_warning("No state with name " + state_name)


func _set_state(state_name: StringName) -> void:
	if current_state:
		var exit_callable: Callable = state_dictionary[current_state].exit
		if !exit_callable.is_null():
			exit_callable.call()

	current_state = state_name
	var enter_callable: Callable = state_dictionary[current_state].enter
	if !enter_callable.is_null():
		enter_callable.call()
