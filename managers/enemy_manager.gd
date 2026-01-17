extends Node

const ENEMY_SCENE: PackedScene = preload("uid://c7u2ej7yguwy6")
const ROUND_BASE_TIME: int = 10
const ROUND_GROWTH: int = 5
const BASE_ENEMY_SPAWN_TIME: float = 2.0
const ENEMY_SPAWN_TIME_GROWTH: float = -0.15

@export var enemy_spawn_root: Node
@export var spawn_rect: ReferenceRect

@onready var spawn_interval_timer: Timer = $SpawnIntervalTimer
@onready var round_timer: Timer = $RoundTimer

var round_count: int = 0

func _ready() -> void:
	spawn_interval_timer.timeout.connect(_on_spawn_interval_timer_timeout)
	round_timer.timeout.connect(_on_round_timer_timeout)
	begin_round()


func begin_round() -> void:
	round_count += 1
	round_timer.wait_time = ROUND_BASE_TIME + ((round_count - 1) * ROUND_GROWTH)
	round_timer.start()

	spawn_interval_timer.wait_time = BASE_ENEMY_SPAWN_TIME +\
		((round_count - 1) * ENEMY_SPAWN_TIME_GROWTH)
	spawn_interval_timer.start()


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
		spawn_interval_timer.start()

func _on_round_timer_timeout() -> void:
	if is_multiplayer_authority():
		spawn_interval_timer.stop()
		print("round over")
