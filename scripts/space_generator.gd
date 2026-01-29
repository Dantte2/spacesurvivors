extends Node2D

@export var asteroid_scene: PackedScene
@export var spawn_radius: float = 1200.0  # distance around player to spawn
@export var min_distance: float = 300.0   # don't spawn too close
@export var max_asteroids: int = 1

@export var player: NodePath  # assign Player node in inspector

var player_node: Node2D
var asteroids: Array = []

func _ready():
    if player:
        player_node = get_node(player)

func _process(_delta):
    if not player_node:
        return

    # Remove far away or freed asteroids safely
    asteroids = asteroids.filter(func(a):
        if not is_instance_valid(a):
            return false  # remove freed asteroids
        if a.global_position.distance_to(player_node.global_position) > spawn_radius * 2:
            a.queue_free()
            return false  # remove far away asteroids
        return true  # keep the asteroid

    )

    # Spawn new asteroids
    while asteroids.size() < max_asteroids:
        var angle = randf() * TAU
        var distance = randf_range(min_distance, spawn_radius)
        var pos = player_node.global_position + Vector2(cos(angle), sin(angle)) * distance

        # Optional: skip spawning inside camera rectangle
        var cam_rect = Rect2(player_node.global_position - Vector2(960, 540), Vector2(1920, 1080))
        if cam_rect.has_point(pos):
            continue

        var asteroid = asteroid_scene.instantiate()
        asteroid.global_position = pos
        get_tree().current_scene.add_child(asteroid)
        asteroids.append(asteroid)
