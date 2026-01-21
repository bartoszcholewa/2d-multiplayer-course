class_name Enemy
extends CharacterBody2D

@onready var target_acquisition_timer: Timer = $TargetAcquisitionTimer
@onready var health_component: HealthComponent = $HealthComponent
@onready var visuals: Node2D = $Visuals

var target_position: Vector2
var state_machine: CallableStateMachine = CallableStateMachine.new()

func _ready() -> void:
	# Spawning states
	state_machine.add_states(
		normal_state_spawn,
		enter_state_spawn,
		exit_state_spawn,
	)

	# Follow player state
	state_machine.add_states(
		normal_state_follow,
		enter_state_follow,
		exit_state_follow,
	)

	# Setting initial state as spawning
	state_machine.set_initial_state(normal_state_spawn)

	target_acquisition_timer.timeout.connect(_on_target_acqusition_timer_timeout)

	if is_multiplayer_authority():
		health_component.died.connect(_on_died)


func _process(_delta: float) -> void:
	state_machine.update()


#region Enemy States

#region Spawn State
func enter_state_spawn() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(visuals, "scale", Vector2.ONE, 0.4)\
		.from(Vector2.ZERO)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)
	tween.finished.connect(func () -> void:
		state_machine.change_state(normal_state_follow)
	)

func normal_state_spawn() -> void:
	pass

func exit_state_spawn() -> void:
	pass
#endregion

#region Attack State
func enter_state_follow() -> void:
	if is_multiplayer_authority():
		acquire_target()

func normal_state_follow() -> void:
	if is_multiplayer_authority():
		velocity = global_position.direction_to(target_position) * 40
		move_and_slide()
	flip()


func exit_state_follow() -> void:
	pass
#endregion

#endregion





func flip() -> void:
	visuals.scale = Vector2.ONE if target_position.x > global_position.x\
		else Vector2(-1, 1)


func acquire_target() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	var nearest_player: Player = null
	var nearest_squared_distance: float

	for player: Player in players:
		if not nearest_player:
			nearest_player = player
			nearest_squared_distance = nearest_player.global_position\
				.distance_squared_to(global_position)
			continue

		var player_squared_distance: float = player.global_position\
			.distance_squared_to(global_position)
		if player_squared_distance < nearest_squared_distance:
			nearest_squared_distance = player_squared_distance
			nearest_player = player

	if nearest_player != null:
		target_position = nearest_player.global_position

func _on_target_acqusition_timer_timeout() -> void:
	if is_multiplayer_authority():
		acquire_target()

func _on_died() -> void:
	GameEvents.emit_enemy_died()
	queue_free()
