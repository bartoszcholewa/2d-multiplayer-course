extends Control
@onready var host_button: Button = $%HostButton
@onready var play_button: Button = $%PlayButton


func _ready() -> void:
	host_button.pressed.connect(_on_host_pressed)
	play_button.pressed.connect(_on_play_pressed)


func _on_host_pressed() -> void:
	pass

func _on_play_pressed() -> void:
	pass
