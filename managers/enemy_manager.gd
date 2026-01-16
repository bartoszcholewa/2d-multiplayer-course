extends Node

const ENEMY_SCENE: PackedScene = preload("uid://c7u2ej7yguwy6")

@export var enemy_spawn_root: Node
@export var spawn_rect: ReferenceRect

@onready var spawn_interval_timer: Timer = $SpawnIntervalTimer

func _ready() -> void:
	spawn_interval_timer.timeout.connect(_on_spawn_interval_timer_timeout)


func get_random_spawn_position() -> Vector2:
	var x: int = randi_range(0, int(spawn_rect.size.x))
	var y: int = randi_range(0, int(spawn_rect.size.y))

	return spawn_rect.global_position + Vector2(x, y)

func spawn_enemy() -> void:
	var enemy_instance: Enemy = ENEMY_SCENE.instantiate()
	enemy_instance.global_position = get_random_spawn_position()
	enemy_spawn_root.add_child(enemy_instance, true)


func _on_spawn_interval_timer_timeout() -> void:
	if is_multiplayer_authority():
		spawn_enemy()
