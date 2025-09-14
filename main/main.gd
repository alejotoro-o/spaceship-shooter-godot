extends Node

@export var asteroid_scene: PackedScene
var score

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#new_game()
	$HUD.show_message("Destroy the Asteroids!")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func game_over() -> void:
	$AsteroidTimer.stop()
	$HUD.show_game_over()
	
func new_game():
	score = 0
	$Player.start($StartPosition.position)
	$StartTimer.start()
	get_tree().call_group("asteroids", "queue_free")


func _on_asteroid_timer_timeout() -> void:
	# Create a new instance of the asteroid scene.
	var asteroid = asteroid_scene.instantiate()
	asteroid.connect('hit', update_score)

	# Choose a random location on Path2D.
	var asteroid_spawn_location = $AsteroidPath/AsteroidSpawnLocation
	asteroid_spawn_location.progress_ratio = randf()

	# Set the asteroid's position to the random location.
	asteroid.position = asteroid_spawn_location.position

	# Set the asteroid's direction down.
	asteroid.rotation = PI

	# Choose the velocity for the asteroid.
	asteroid.velocity = Vector2(0.0, randf_range(150.0, 250.0))

	# Spawn the asteroid by adding it to the Main scene.
	add_child(asteroid)


func _on_start_timer_timeout() -> void:
	$AsteroidTimer.start()
	
func update_score():
	score += 1
	$HUD.update_score(score)
