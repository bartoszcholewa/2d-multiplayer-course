extends Node

const PLAYER_SCENE: PackedScene = preload("uid://cse7rqp64wxuc")

@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner

func _ready() -> void:
	multiplayer_spawner.spawn_function = _spawn_player
	# Notify server about client ready
	peer_ready.rpc_id(1)


func _spawn_player(data: Dictionary) -> CharacterBody2D:
	var player_instance: CharacterBody2D = PLAYER_SCENE.instantiate()
	player_instance.name = str(data.peer_id)
	return player_instance

@rpc("any_peer", "call_local", "reliable")
func peer_ready() -> void:
	var sender_id: int = multiplayer.get_remote_sender_id()
	multiplayer_spawner.spawn({"peer_id": sender_id})
