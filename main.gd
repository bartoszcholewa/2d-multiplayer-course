extends Node

const PLAYER_SCENE: PackedScene = preload("uid://cse7rqp64wxuc")

@onready var player_spawn_position: Marker2D = $PlayerSpawnPosition
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var enemy_manager: EnemyManager = $EnemyManager

var dead_peers: Array[int] = []


func _ready() -> void:
	multiplayer_spawner.spawn_function = _spawn_player
	# Notify server about client ready
	peer_ready.rpc_id(1)
	enemy_manager.round_completed.connect(_on_round_completed)


func _spawn_player(data: Dictionary) -> Player:
	var player_instance: Player = PLAYER_SCENE.instantiate()
	var peer_id: int = data["peer_id"]
	player_instance.name = str(peer_id)
	player_instance.input_multiplayer_authority = peer_id
	player_instance.global_position = player_spawn_position.global_position

	if is_multiplayer_authority():
		player_instance.died.connect(_on_player_died.bind(peer_id))

	return player_instance


@rpc("any_peer", "call_local", "reliable")
func peer_ready() -> void:
	var sender_id: int = multiplayer.get_remote_sender_id()
	multiplayer_spawner.spawn({"peer_id": sender_id})
	enemy_manager.synchronize(sender_id)


func respawn_dead_peers() -> void:
	for peer_id: int in dead_peers:
		multiplayer_spawner.spawn({"peer_id": peer_id})
	dead_peers.clear()


func _on_player_died(peer_id: int) -> void:
	dead_peers.append(peer_id)

func _on_round_completed() -> void:
	respawn_dead_peers()
