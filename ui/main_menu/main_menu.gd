extends Control

const SERVER_IP: String = "127.0.0.1"
const SERVER_PORT: int = 8081
const MAIN_SCENE: PackedScene = preload("uid://ej1u6umes6d5")


@onready var host_button: Button = $%HostButton
@onready var play_button: Button = $%JoinButton


func _ready() -> void:
	host_button.pressed.connect(_on_host_pressed)
	play_button.pressed.connect(_on_join_pressed)
	multiplayer.connected_to_server.connect(_on_connected_to_server)


func _on_host_pressed() -> void:
	var server_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = server_peer
	get_tree().change_scene_to_packed(MAIN_SCENE)

func _on_join_pressed() -> void:
	var client_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = client_peer


func _on_connected_to_server() -> void:
	get_tree().change_scene_to_packed(MAIN_SCENE)
