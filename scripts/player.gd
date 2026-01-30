extends CharacterBody2D

# ==============================
# MOVEMENT TUNING
# ==============================
@export var acceleration := 1800.0
@export var max_speed := 900.0
@export var rotation_speed := 10.0
@export var damping := 0.985 #space drifting

# ==============================
# SHOOTING
# ==============================
@export var bullet_scene: PackedScene
@export var fire_rate := 0.2
@onready var bullet_spawn_1 := $BulletSpawn1
@onready var bullet_spawn_2 := $BulletSpawn2
var fire_timer := 0.0

# ==============================
# XP / LEVEL
# ==============================
var xp := 0
var level := 1
var xp_to_next_level := 100
var xp_bar: TextureProgressBar

var target_xp := 0.0          
var xp_lerp_speed := 3.0      

# ==============================
# NODES
# ==============================
@onready var ship: AnimatedSprite2D = $Ship
@onready var exhaust: AnimatedSprite2D = $Exhaust

func _ready() -> void:
    ship.play("normal")
    exhaust.play("default")

    var main := get_tree().current_scene
    xp_bar = main.get_node("UI/XPbar")
    xp_bar.max_value = xp_to_next_level
    xp_bar.value = xp
    target_xp = xp

func _process(delta: float) -> void:
    # lerp xp bar
    xp_bar.value = lerp(xp_bar.value, target_xp, xp_lerp_speed * delta)
    
    # 🔹 Print the current XP bar value for debugging
    #print("XP Bar Value:", xp_bar.value, " | Target XP:", target_xp)

func _physics_process(delta: float) -> void:
    _handle_rotation(delta)
    _handle_movement(delta)
    _handle_shooting(delta)

# -----------------------------
# ROTATION
# -----------------------------
func _handle_rotation(delta: float) -> void:
    var dir = (get_global_mouse_position() - global_position).normalized()
    var target_rot = dir.angle() - PI / 2
    rotation = lerp_angle(rotation, target_rot, rotation_speed * delta)

# -----------------------------
# MOVEMENT
# -----------------------------
func _handle_movement(delta: float) -> void:
    if Input.is_action_pressed("ui_up"):
        var forward = -Vector2.UP.rotated(rotation)
        velocity += forward * acceleration * delta

    if velocity.length() > max_speed:
        velocity = velocity.normalized() * max_speed

    velocity *= damping
    move_and_slide()

# -----------------------------
# SHOOTING
# -----------------------------
func _handle_shooting(delta: float) -> void:
    if bullet_scene == null:
        return

    fire_timer -= delta
    if fire_timer <= 0.0:
        _shoot(bullet_spawn_1)
        _shoot(bullet_spawn_2)
        fire_timer = fire_rate

func _shoot(spawn: Node2D) -> void:
    var bullet = bullet_scene.instantiate()
    var dir = -Vector2.UP.rotated(rotation)
    bullet.global_position = spawn.global_position + dir * 32
    bullet.direction = dir
    get_tree().current_scene.add_child(bullet)

# ==============================
# XP
# ==============================
func add_xp(amount: int) -> void:
    xp += amount
    
    # Handle multiple level-ups 
    while xp >= xp_to_next_level:
        xp -= xp_to_next_level
        level += 1
        print("LEVEL UP:", level)
        xp_to_next_level = int(xp_to_next_level * 1.25)
        # Reset XP bar smoothly for new level
        target_xp = 0
        xp_bar.max_value = xp_to_next_level

    # Set target XP for smooth fill
    target_xp = xp
    xp_bar.max_value = xp_to_next_level
