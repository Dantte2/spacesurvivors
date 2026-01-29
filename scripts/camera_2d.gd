extends Camera2D

@export var target: NodePath  # Player node
@export var smooth_speed: float = 8.0
@export var deadzone_radius: float = 50.0  # pixels

func _process(delta):
    if not target:
        return

    var target_node = get_node(target)
    var target_pos = target_node.global_position

    var offset = target_pos - global_position
    if offset.length() > deadzone_radius:
        # Only move camera if player is outside deadzone
        global_position += offset.normalized() * (offset.length() - deadzone_radius) * smooth_speed * delta
