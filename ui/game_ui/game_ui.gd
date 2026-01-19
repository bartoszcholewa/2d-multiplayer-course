extends CanvasLayer

@export var enemy_manager: EnemyManager
@onready var timer_label: Label = %TimerLabel
@onready var round_label: Label = %RoundLabel


func _ready() -> void:
	enemy_manager.round_changed.connect(_on_round_changed)

func _process(_delta: float) -> void:
	var ceil_time: int = ceili(enemy_manager.get_round_time_remaining())
	timer_label.text = str(ceil_time)


func _on_round_changed(round_count: int) -> void:
	round_label.text = "Round %s" % round_count
