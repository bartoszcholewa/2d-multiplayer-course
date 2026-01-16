class_name Bullet
extends Node2D

## Bullet speed in pixels/second
const SPEED: int = 600

var direction: Vector2

func _process(delta: float) -> void:
	global_position += direction * SPEED * delta



func start(bullet_direction: Vector2) -> void:
	direction = bullet_direction
	rotation = direction.angle()
