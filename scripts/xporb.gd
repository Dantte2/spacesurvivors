extends Area2D

@export var value: int = 33          # how much XP this gives
@export var attract_speed: float = 300.0   # speed when being sucked to player

var player: Node2D = null
var is_collected: bool = false

func _ready():
    # Find the player
    var players = get_tree().get_nodes_in_group("player")
    if players.size() > 0:
        player = players[0]

func _physics_process(delta: float) -> void:
    if is_collected or player == null:
        return

    # Check distance to player for collection
    var dist = global_position.distance_to(player.global_position)
    if dist < 32:  # collect radius
        _collect()
        return

    # Pull XP toward player
    if dist < 150:  # attraction radius
        var dir = (player.global_position - global_position).normalized()
        global_position += dir * attract_speed * delta

func _collect():
    if is_collected:
        return
    is_collected = true
    # TODO: increment player's XP
    player.call("add_xp", value)
    queue_free()
