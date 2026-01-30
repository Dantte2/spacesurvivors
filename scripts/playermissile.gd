extends CharacterBody2D

# ==============================
# MISSILE SETTINGS
# ==============================
@export var speed := 400.0           # Movement speed
@export var turn_speed := 5.0        # How fast missile rotates toward target
@export var lifetime := 5.0          # Seconds before missile disappears

var target: Node2D = null
var time_alive := 0.0

func _ready() -> void:
    # Pick closest enemy at spawn
    _find_target()

func _physics_process(delta: float) -> void:
    time_alive += delta
    if time_alive >= lifetime:
        queue_free()
        return

    if target == null or not is_instance_valid(target):
        _find_target()
        if target == null:
            # No target left, just go straight
            velocity = Vector2.UP.rotated(rotation) * speed
            move_and_slide()
            return

    # Move toward target
    var dir = (target.global_position - global_position).normalized()
    var angle_diff = dir.angle() - rotation
    rotation += clamp(angle_diff, -turn_speed * delta, turn_speed * delta)

    # Apply velocity in facing direction
    velocity = Vector2.UP.rotated(rotation) * speed
    move_and_slide()

func _find_target() -> void:
    # Pick closest enemy in "enemies" group
    var enemies = get_tree().get_nodes_in_group("enemies")
    var closest_dist = INF
    target = null
    for e in enemies:
        if not is_instance_valid(e):
            continue
        var d = global_position.distance_to(e.global_position)
        if d < closest_dist:
            closest_dist = d
            target = e

# Optional: detect collision with enemy (if using Area2D, use signals)
func _on_body_entered(body: Node) -> void:
    if body.is_in_group("enemies"):
        body.take_damage(1)  # assumes enemy has take_damage()
        queue_free()
