extends Node

const PLAYER_SCENE: PackedScene = preload("uid://cse7rqp64wxuc")
const MAIN_MENU_SCENE_PATH: String = "res://ui/main_menu/main_menu.tscn"

@onready var player_spawn_position: Marker2D = $PlayerSpawnPosition
@onready var multiplayer_spawner: MultiplayerSpawner = $MultiplayerSpawner
@onready var enemy_manager: EnemyManager = $EnemyManager

var dead_peers: Array[int] = []


func _ready() -> void:
	multiplayer_spawner.spawn_function = _spawn_player
	# Notify server about client ready
	peer_ready.rpc_id(1)
	enemy_manager.round_completed.connect(_on_round_completed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


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


func end_game() -> void:
	# Terminate the peer connections and close the server
	multiplayer.multiplayer_peer = null

	# Change Main scene to Main Menu scene
	get_tree().change_scene_to_file(MAIN_MENU_SCENE_PATH)


func check_game_over() -> void:
	var is_game_over: bool = true

	# Get all peers ids including the server (1)
	var all_peers: PackedInt32Array = multiplayer.get_peers()
	all_peers.push_back(multiplayer.get_unique_id())

	for peer_id: int in all_peers:
		if not dead_peers.has(peer_id):
			is_game_over = false
			break

	if is_game_over:
		# Terminate the server and peers and load main menu
		end_game()


func _on_player_died(peer_id: int) -> void:
	dead_peers.append(peer_id)
	check_game_over()

func _on_round_completed() -> void:
	respawn_dead_peers()

func _on_server_disconnected() -> void:
	end_game()
