extends Area2D

@export var speed: float = 1800.0
var direction: Vector2 = Vector2.UP

func _ready() -> void:
    rotation = direction.angle()

    # Offscreen deletion
    if not has_node("VisibleOnScreenNotifier2D"):
        var notifier = VisibleOnScreenNotifier2D.new()
        add_child(notifier)
        notifier.rect = Rect2(Vector2(-8, -8), Vector2(16, 16))
        notifier.screen_exited.connect(Callable(self, "_on_screen_exited"))

    # Collision detection
    body_entered.connect(Callable(self, "_on_body_entered"))

func _process(delta: float) -> void:
    global_position += direction.normalized() * speed * delta

func _on_screen_exited():
    queue_free()

func _on_body_entered(body):
    if body.has_method("take_damage"):
        body.take_damage(1)
    queue_free()
