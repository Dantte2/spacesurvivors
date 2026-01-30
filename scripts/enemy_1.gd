extends CharacterBody2D

# ==============================
# TUNING
# ==============================
@export var max_speed: float = 200.0
@export var acceleration: float = 400.0
@export var damping: float = 0.9
@export var rotate_toward_player: bool = true

# ==============================
# HEALTH
# ==============================
@export var max_health: int = 3
var health: int = 0
var is_dying: bool = false

# ==============================
# SPAWNER SIGNAL
# ==============================
signal enemy_died

# ==============================
# PLAYER REFERENCE
# ==============================
var player: Node2D = null

# ==============================
# Packed Scenes
# ==============================
@export var death_animation_scene: PackedScene
@export var XP_scene: PackedScene

func _ready() -> void:
    health = max_health

    var players = get_tree().get_nodes_in_group("player")
    if players.size() > 0:
        player = players[0]

func _physics_process(delta: float) -> void:
    if is_dying or player == null:
        return

    var dir = (player.global_position - global_position).normalized()
    velocity += dir * acceleration * delta
    velocity = velocity.limit_length(max_speed)
    velocity *= damping

    if rotate_toward_player:
        rotation = dir.angle() - PI / 2

    move_and_slide()

# ==============================
# DAMAGE
# ==============================
func take_damage(amount: int = 1) -> void:
    if is_dying:
        return

    health -= amount
    if health <= 0:
        die()

# ==============================
# DEATH
# ==============================
func die() -> void:
    if is_dying:
        return

    is_dying = true
    velocity = Vector2.ZERO

    emit_signal("enemy_died")

    # Spawn death animation if assigned
    if death_animation_scene:
        var anim = death_animation_scene.instantiate()
        anim.global_position = global_position
        get_tree().get_root().call_deferred("add_child", anim)

    # --- Spawn XP drops ---
    if XP_scene:  # export PackedScene
        for i in range(3):  # drop 3 XP
            var xp = XP_scene.instantiate()
            xp.global_position = global_position + Vector2(randf_range(-16, 16), randf_range(-16, 16))
            get_tree().get_root().call_deferred("add_child", xp)

    queue_free()
