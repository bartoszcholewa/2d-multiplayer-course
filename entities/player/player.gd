class_name Player
extends CharacterBody2D

@onready var player_input_synchronizer_component: PlayerInputSynchronizerComponent = $PlayerInputSynchronizerComponent

var input_multiplayer_authority: int

func _ready() -> void:
	# Set player authority as soon as node is ready
	player_input_synchronizer_component.set_multiplayer_authority(input_multiplayer_authority)

	# Only process this node from server, but not client
	set_process(is_multiplayer_authority())


func _process(_delta: float) -> void:
	velocity = player_input_synchronizer_component.movement_vector * 100
	move_and_slide()
