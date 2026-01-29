extends CharacterBody2D

@export var rotation_speed_range: Vector2 = Vector2(-1.0, 1.0)  # radians/sec
var rotation_speed: float = 0.0

@export var drift_speed_range: Vector2 = Vector2(20.0, 60.0)  # pixels/sec
var drift_velocity: Vector2 = Vector2.ZERO

func _ready() -> void:
    # Random rotation
    rotation_speed = randf_range(rotation_speed_range.x, rotation_speed_range.y)
    
    # Random drift direction
    var angle = randf() * TAU
    var speed = randf_range(drift_speed_range.x, drift_speed_range.y)
    drift_velocity = Vector2(cos(angle), sin(angle)) * speed

func _physics_process(delta: float) -> void:
    # Rotate
    rotation += rotation_speed * delta

    # Drift in space
    velocity = drift_velocity
    move_and_slide()
