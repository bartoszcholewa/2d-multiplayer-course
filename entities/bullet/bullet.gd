class_name Bullet
extends Node2D

## Bullet speed in pixels/second
const SPEED: int = 600

@onready var life_timer: Timer = $LifeTimer
@onready var hitbox_component: HitboxComponent = $HitboxComponent

var direction: Vector2

func _ready() -> void:
	hitbox_component.hit_hurtbox.connect(_on_hit_hurtbox)
	life_timer.timeout.connect(_on_life_timer_timeout)

func _process(delta: float) -> void:
	global_position += direction * SPEED * delta


func start(bullet_direction: Vector2) -> void:
	direction = bullet_direction
	rotation = direction.angle()

func register_collision() -> void:
	queue_free()

func _on_life_timer_timeout() -> void:
	# Remove bullet node from server
	if is_multiplayer_authority():
		queue_free()

func _on_hit_hurtbox(_hurtbox_component: HurtboxComponent) -> void:
	register_collision()
