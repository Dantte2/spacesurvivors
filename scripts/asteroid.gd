extends CharacterBody2D

@export var rotation_speed_range: Vector2 = Vector2(-1.0, 1.0)  # radians/sec
var rotation_speed: float = 0.0

@export var drift_speed_range: Vector2 = Vector2(20.0, 60.0)  # pixels/sec
var drift_velocity: Vector2 = Vector2.ZERO

@export var max_health: int = 10
var health: int = 0

var is_exploding: bool = false  # Prevent multiple explosions

func _ready() -> void:
    health = max_health

    # Random rotation
    rotation_speed = randf_range(rotation_speed_range.x, rotation_speed_range.y)
    
    # Random drift direction
    var angle = randf() * TAU
    var speed = randf_range(drift_speed_range.x, drift_speed_range.y)
    drift_velocity = Vector2(cos(angle), sin(angle)) * speed

func _physics_process(delta: float) -> void:
    if is_exploding:
        return  # Stop movement during explosion
    # Rotate
    rotation += rotation_speed * delta

    # Drift in space
    velocity = drift_velocity
    move_and_slide()

# --- Damage handling ---
func take_damage(amount: int = 1) -> void:
    if is_exploding:
        return  # Ignore damage while exploding
    health -= amount
    if health <= 0:
        explode()

# --- Explosion ---
func explode() -> void:
    if is_exploding:
        return  # Already exploding
    is_exploding = true

    # Stop movement
    velocity = Vector2.ZERO
    set_physics_process(false)

    # Play explosion animation
    if has_node("AnimatedSprite2D"):
        var sprite = $AnimatedSprite2D
        sprite.animation = "explode"  # Make sure your animation is named "explode"
        sprite.play()

        # Connect safely to animation_finished
        if not sprite.animation_finished.is_connected(Callable(self, "_on_explosion_finished")):
            sprite.animation_finished.connect(Callable(self, "_on_explosion_finished"))
    else:
        queue_free()  # Fallback if no sprite

func _on_explosion_finished():
    queue_free()
