extends Node

const PLAYER_SCENE: PackedScene = preload("uid://cse7rqp64wxuc")
const ENEMY_SCENE: PackedScene = preload("uid://c7u2ej7yguwy6")

@onready var player_spawn_position: Marker2D = $PlayerSpawnPosition
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner

func _ready() -> void:
	multiplayer_spawner.spawn_function = _spawn_player
	# Notify server about client ready
	peer_ready.rpc_id(1)

	if is_multiplayer_authority():
		var enemy_instance: Enemy = ENEMY_SCENE.instantiate()
		enemy_instance.global_position = Vector2.ONE * 200
		add_child(enemy_instance)


func _spawn_player(data: Dictionary) -> Player:
	var player_instance: Player = PLAYER_SCENE.instantiate()
	var peer_id: int = data["peer_id"]
	player_instance.name = str(peer_id)
	player_instance.input_multiplayer_authority = peer_id
	player_instance.global_position = player_spawn_position.global_position
	return player_instance

@rpc("any_peer", "call_local", "reliable")
func peer_ready() -> void:
	var sender_id: int = multiplayer.get_remote_sender_id()
	multiplayer_spawner.spawn({"peer_id": sender_id})
