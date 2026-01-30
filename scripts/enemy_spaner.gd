extends Node2D

# ==============================
# SPAWNER CONFIG
# ==============================
@export var enemy_scene: PackedScene           # Enemy scene to spawn
@export var initial_spawn_interval := 2.0     # Initial spawn interval
@export var min_spawn_interval := 0.3         # Minimum spawn interval
@export var spawn_acceleration := 0.005       # How fast interval decreases per second

@export var initial_max_enemies := 5          # Initial max enemies
@export var max_enemies_cap := 50             # Absolute max enemies
@export var max_enemies_increment := 0.02     # Max enemies increase per second

# Optional enemy scaling over time
@export var enemy_health_scale := 0.01
@export var enemy_speed_scale := 0.005

# ==============================
# INTERNAL
# ==============================
var spawn_timer := 0.0
var spawn_interval := initial_spawn_interval
var max_enemies := initial_max_enemies
var time_passed := 0.0

func _process(delta: float) -> void:
    time_passed += delta

    # Decrease spawn interval over time
    spawn_interval = max(min_spawn_interval, spawn_interval - spawn_acceleration * delta)

    # Increase max enemies gradually
    max_enemies = min(max_enemies_cap, max_enemies + max_enemies_increment * delta)

    # Spawn timer
    spawn_timer -= delta
    if spawn_timer <= 0:
        _try_spawn_enemy()
        spawn_timer = spawn_interval

# ==============================
# SPAWN ENEMY OFFSCREEN
# ==============================
func _try_spawn_enemy() -> void:
    var current_enemies := get_tree().get_nodes_in_group("enemies").size()
    if current_enemies >= max_enemies:
        return

    # Get camera viewport rectangle in world coordinates
    var camera := get_viewport().get_camera_2d()
    if camera == null:
        return

    var screen_rect = Rect2(
        camera.global_position - camera.zoom * camera.get_viewport_rect().size / 2,
        camera.get_viewport_rect().size * camera.zoom
    )

    # Pick random edge: 0=top,1=bottom,2=left,3=right
    var side := randi() % 4
    var pos := Vector2.ZERO
    var buffer := 50  # spawn offscreen by 50px

    match side:
        0:  # top
            pos.x = randf_range(screen_rect.position.x, screen_rect.position.x + screen_rect.size.x)
            pos.y = screen_rect.position.y - buffer
        1:  # bottom
            pos.x = randf_range(screen_rect.position.x, screen_rect.position.x + screen_rect.size.x)
            pos.y = screen_rect.position.y + screen_rect.size.y + buffer
        2:  # left
            pos.x = screen_rect.position.x - buffer
            pos.y = randf_range(screen_rect.position.y, screen_rect.position.y + screen_rect.size.y)
        3:  # right
            pos.x = screen_rect.position.x + screen_rect.size.x + buffer
            pos.y = randf_range(screen_rect.position.y, screen_rect.position.y + screen_rect.size.y)

    # Instantiate enemy
    var enemy = enemy_scene.instantiate()
    enemy.global_position = pos

    # Scale enemy stats over time
    if enemy.has_method("scale_stats"):
        enemy.scale_stats(
            1.0 + enemy_health_scale * time_passed,
            1.0 + enemy_speed_scale * time_passed
        )

    # Add to scene
    get_tree().current_scene.add_child(enemy)
    enemy.add_to_group("enemies")
