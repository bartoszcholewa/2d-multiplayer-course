class_name Player
extends CharacterBody2D

@onready var player_input_synchronizer_component: PlayerInputSynchronizerComponent = $PlayerInputSynchronizerComponent
@onready var weapon_root: Node2D = $WeaponRoot

var input_multiplayer_authority: int

func _ready() -> void:
	# Set player authority as soon as node is ready
	player_input_synchronizer_component.set_multiplayer_authority(input_multiplayer_authority)


func _process(_delta: float) -> void:
	# Rotate and point weapon at mouse position (aim_vector)
	var aim_position: Vector2 = weapon_root.global_position + player_input_synchronizer_component.aim_vector
	weapon_root.look_at(aim_position)

	# Move players only from the server
	if is_multiplayer_authority():
		velocity = player_input_synchronizer_component.movement_vector * 100
		move_and_slide()
