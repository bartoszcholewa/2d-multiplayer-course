class_name Enemy
extends CharacterBody2D

@onready var area_2d: Area2D = $Area2D
@onready var target_acquisition_timer: Timer = $TargetAcquisitionTimer
@onready var health_component: HealthComponent = $HealthComponent

var target_position: Vector2


func _ready() -> void:
	area_2d.area_entered.connect(_on_area_entered)
	target_acquisition_timer.timeout.connect(_on_target_acqusition_timer_timeout)
	if is_multiplayer_authority():
		health_component.died.connect(_on_died)
		acquire_target()


func _process(_delta: float) -> void:
	if is_multiplayer_authority():
		velocity = global_position.direction_to(target_position) * 40
		move_and_slide()

func handle_hit() -> void:
	health_component.damage(1)

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


func _on_area_entered(other_area: Area2D) -> void:
	if not is_multiplayer_authority():
		return

	if other_area.owner is Bullet:
		var bullet: Bullet = other_area.owner
		bullet.register_collision()
		handle_hit()

func _on_target_acqusition_timer_timeout() -> void:
	if is_multiplayer_authority():
		acquire_target()

func _on_died() -> void:
	GameEvents.emit_enemy_died()
	queue_free()
