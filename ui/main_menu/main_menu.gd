extends Control

const SERVER_IP: String = "127.0.0.1"
const SERVER_PORT: int = 8081


@onready var host_button: Button = $%HostButton
@onready var play_button: Button = $%JoinButton


func _ready() -> void:
	host_button.pressed.connect(_on_host_pressed)
	play_button.pressed.connect(_on_join_pressed)
	multiplayer.peer_connected.connect(_on_peer_connected)


func _on_host_pressed() -> void:
	var server_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	server_peer.create_server(SERVER_PORT)
	multiplayer.multiplayer_peer = server_peer

func _on_join_pressed() -> void:
	var client_peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
	client_peer.create_client(SERVER_IP, SERVER_PORT)
	multiplayer.multiplayer_peer = client_peer

func _on_peer_connected(id: int) -> void:
	print("peer connected: ", id)
