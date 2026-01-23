class_name Enemy
extends CharacterBody2D

const ENEMY_IMPACT_PARTICLES_SCENE: PackedScene = preload("uid://cqcbxw57730wx")

@onready var target_acquisition_timer: Timer = $TargetAcquisitionTimer
@onready var health_component: HealthComponent = $HealthComponent
@onready var visuals: Node2D = $Visuals
@onready var attack_cooldown_timer: Timer = $AttackCooldownTimer
@onready var charge_attack_timer: Timer = $ChargeAttackTimer
@onready var hitbox_collision_shape: CollisionShape2D = %HitboxCollisionShape
@onready var alert_sprite: Sprite2D = $AlertSprite
@onready var hurtbox_component: HurtboxComponent = $HurtboxComponent

var target_position: Vector2
var state_machine: CallableStateMachine = CallableStateMachine.new()
var default_collision_layer: int
var default_collision_mask: int
var alert_tween: Tween

var current_state: StringName:
	get:
		return state_machine.current_state
	set(value):
		var state: Callable = Callable.create(self, value)
		state_machine.change_state(state)


func _notification(what: int) -> void:
	if what == NOTIFICATION_SCENE_INSTANTIATED:
		#region Registering enemy states
		# Spawning state
		state_machine.add_states(
			normal_state_spawn,
			enter_state_spawn,
			exit_state_spawn,
		)

		# Follow target state
		state_machine.add_states(
			normal_state_follow,
			enter_state_follow,
			exit_state_follow,
		)

		# Charge Attack state
		state_machine.add_states(
			normal_state_charge_attack,
			enter_state_charge_attack,
			exit_state_charge_attack,
		)

		# Attack State
		state_machine.add_states(
			normal_state_attack,
			enter_state_attack,
			exit_state_attack,
		)

	#endregion


func _ready() -> void:
	# Initial visual setup
	default_collision_layer = collision_layer
	default_collision_mask = collision_mask
	hitbox_collision_shape.disabled = true
	alert_sprite.scale = Vector2.ZERO

	if is_multiplayer_authority():
		health_component.died.connect(_on_died)
		hurtbox_component.hit_by_hitbox.connect(_on_hit_by_hitbox)

		# Setting initial state as spawning
		state_machine.set_initial_state(normal_state_spawn)




func _process(_delta: float) -> void:
	state_machine.update()

	if is_multiplayer_authority():
		move_and_slide()


#region Enemy States

#region Spawn State
func enter_state_spawn() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(visuals, "scale", Vector2.ONE, 0.4)\
		.from(Vector2.ZERO)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)
	tween.finished.connect(func () -> void:
		state_machine.change_state(normal_state_follow)
	)

func normal_state_spawn() -> void:
	pass

func exit_state_spawn() -> void:
	pass
#endregion

#region Attack State
func enter_state_follow() -> void:
	if is_multiplayer_authority():
		acquire_target()
		target_acquisition_timer.start()

func normal_state_follow() -> void:
	if is_multiplayer_authority():
		velocity = global_position.direction_to(target_position) * 40

		if target_acquisition_timer.is_stopped():
			acquire_target()
			target_acquisition_timer.start()

		if attack_cooldown_timer.is_stopped() and global_position.distance_to(target_position) < 150:
			state_machine.change_state(normal_state_charge_attack)

	flip()

func exit_state_follow() -> void:
	pass
#endregion

#region Charge Attack State
func enter_state_charge_attack() -> void:
	if is_multiplayer_authority():
		acquire_target()
		charge_attack_timer.start()

	_reset_aletr_tween()
	alert_tween.tween_property(alert_sprite, "scale", Vector2.ONE, 0.2)\
		.set_ease(Tween.EASE_OUT)\
		.set_trans(Tween.TRANS_BACK)


func normal_state_charge_attack() -> void:
	if is_multiplayer_authority():
		velocity = velocity.lerp(Vector2.ZERO, 1.0 - exp(-15 * get_process_delta_time()))
		if charge_attack_timer.is_stopped():
			state_machine.change_state(normal_state_attack)
	flip()


func exit_state_charge_attack() -> void:
	_reset_aletr_tween()
	alert_tween.tween_property(alert_sprite, "scale", Vector2.ZERO, 0.2)\
		.set_ease(Tween.EASE_IN)\
		.set_trans(Tween.TRANS_BACK)
#endregion

#region Attack State
func enter_state_attack() -> void:
	if is_multiplayer_authority():
		collision_layer = 0
		collision_mask = 1 << 0
		hitbox_collision_shape.disabled = false
		velocity = global_position.direction_to(target_position) * 400

func normal_state_attack() -> void:
	if is_multiplayer_authority():
		velocity = velocity.lerp(Vector2.ZERO, 1.0 - exp(-3 * get_process_delta_time()))
		if velocity.length() < 25:
			state_machine.change_state(normal_state_follow)

func exit_state_attack() -> void:
	if is_multiplayer_authority():
		collision_layer = default_collision_layer
		collision_mask = default_collision_mask
		hitbox_collision_shape.disabled = true
		attack_cooldown_timer.start()

#endregion


func flip() -> void:
	visuals.scale = Vector2.ONE if target_position.x > global_position.x\
		else Vector2(-1, 1)


func acquire_target() -> void:
	var players: Array[Node] = get_tree().get_nodes_in_group("player")
	var nearest_player: Player = null
	var nearest_squared_distance: float

	for player: Player in players:
		if not nearest_player:
			nearest_player = player
			nearest_squared_distance = nearest_player.global_position\
				.distance_squared_to(global_position)
			continue

		var player_squared_distance: float = player.global_position\
			.distance_squared_to(global_position)
		if player_squared_distance < nearest_squared_distance:
			nearest_squared_distance = player_squared_distance
			nearest_player = player

	if nearest_player != null:
		target_position = nearest_player.global_position


@rpc("authority", "call_local", "unreliable")
func spawn_hit_particles() -> void:
	var hit_particles_instance: Node2D = ENEMY_IMPACT_PARTICLES_SCENE.instantiate()
	hit_particles_instance.global_position = hurtbox_component.global_position
	get_parent().add_child(hit_particles_instance)


func _on_died() -> void:
	GameEvents.emit_enemy_died()
	queue_free()

func _reset_aletr_tween() -> void:
	if alert_tween and alert_tween.is_valid():
		alert_tween.kill()
	alert_tween = create_tween()


func _on_hit_by_hitbox() -> void:
	spawn_hit_particles.rpc()
