extends Node

func _ready() -> void:

	# Notify server about client ready
	peer_ready.rpc_id(1)

@rpc("any_peer", "call_local", "reliable")
func peer_ready() -> void:
	print("peer %s ready" % multiplayer.get_remote_sender_id())
