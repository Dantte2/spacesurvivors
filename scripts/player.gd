extends CharacterBody2D

# ==============================
# MOVEMENT TUNING
# ==============================
@export var acceleration: float = 1800.0
@export var max_speed: float = 900.0
@export var rotation_speed: float = 10.0
@export var damping: float = 0.985  # drift

# ==============================
# SHOOTING
# ==============================
@export var bullet_scene: PackedScene
@export var fire_rate: float = 0.2  # seconds per shot
@onready var bullet_spawn_1: Node2D = $BulletSpawn1
@onready var bullet_spawn_2: Node2D = $BulletSpawn2
var fire_timer: float = 0.0

# ==============================
# NODES
# ==============================
@onready var ship: AnimatedSprite2D = $Ship
@onready var exhaust: AnimatedSprite2D = $Exhaust

func _ready() -> void:
	ship.play("normal")
	exhaust.play("default")  # always on

func _physics_process(delta: float) -> void:
	_handle_rotation(delta)
	_handle_movement(delta)
	_handle_shooting(delta)
	ship.play("normal")

# -----------------------------
# ROTATION
# -----------------------------
func _handle_rotation(delta: float) -> void:
	var mouse_pos = get_global_mouse_position()
	var dir_to_mouse = (mouse_pos - global_position).normalized()
	var target_rot = dir_to_mouse.angle() - PI / 2
	rotation = lerp_angle(rotation, target_rot, rotation_speed * delta)

# -----------------------------
# MOVEMENT
# -----------------------------
func _handle_movement(delta: float) -> void:
	if Input.is_action_pressed("ui_up"): # W
		var forward_dir = -Vector2.UP.rotated(rotation)
		velocity += forward_dir * acceleration * delta

	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	velocity *= damping
	move_and_slide()

# -----------------------------
# AUTO-SHOOT
# -----------------------------
func _handle_shooting(delta: float) -> void:
	if bullet_scene == null:
		return

	fire_timer -= delta
	if fire_timer <= 0.0:
		_shoot_bullet(bullet_spawn_1)
		_shoot_bullet(bullet_spawn_2)
		fire_timer = fire_rate

func _shoot_bullet(spawn: Node2D) -> void:
	var bullet = bullet_scene.instantiate()
	# Move bullet slightly in front of spawn so it's not inside the player
	var forward_dir = -Vector2.UP.rotated(rotation)
	bullet.global_position = spawn.global_position + forward_dir * 32
	bullet.direction = forward_dir
	get_tree().current_scene.add_child(bullet)
