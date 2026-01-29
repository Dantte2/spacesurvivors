extends Area2D

@export var speed: float = 1800.0  # pixels per second
var direction: Vector2 = Vector2.UP  # default moving up

func _ready() -> void:
    # Optional: rotate bullet sprite to match direction
    rotation = direction.angle()

func _process(delta: float) -> void:
    # Move bullet
    global_position += direction.normalized() * speed * delta

    # Remove if offscreen (simple approach)
    var viewport_rect = Rect2(Vector2.ZERO, get_viewport_rect().size)
    if not viewport_rect.has_point(global_position):
        queue_free()
