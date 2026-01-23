extends Sprite2D

@export var health_component: HealthComponent

var shader_tween: Tween

func _ready() -> void:
	if is_multiplayer_authority():
		health_component.damaged.connect(_on_damaged)

@rpc("authority", "call_local", "unreliable")
func _play_highlight() -> void:
	_reset_shader_tween()
	shader_tween.tween_property(material, "shader_parameter/percent", 0, 0.2)\
		.from(1)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_QUINT)


func _on_damaged() -> void:
	_play_highlight.rpc()


func _reset_shader_tween() -> void:
	if shader_tween != null and shader_tween.is_valid():
		shader_tween.kill()
	shader_tween = create_tween()
