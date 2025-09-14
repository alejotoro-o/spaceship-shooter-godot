extends Area2D

signal hit

@export var speed = 400 # How fast the player will move (pixels/sec).
@export var ProjectileScene: PackedScene
@export var shoot_cooldown: float = 0.25

var shoot_timer: float = 0.0
var screen_size # Size of the game window.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_viewport_rect().size
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var velocity = Vector2.ZERO # The player's movement vector.
	if Input.is_action_pressed("move_right"):
		velocity.x += 1
	if Input.is_action_pressed("move_left"):
		velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		velocity.y += 1
	if Input.is_action_pressed("move_up"):
		velocity.y -= 1

	if velocity.length() > 0:
		velocity = velocity.normalized() * speed
		
	position += velocity * delta
	position = position.clamp(Vector2.ZERO, screen_size)
	
	# --- Tilt Animation Control ---
	var max_frame = $Ship.sprite_frames.get_frame_count("default") - 1
	if velocity.x > 0:
		$Ship.flip_h = true
		$Shadow.flip_h = true
		if $Ship.frame < max_frame:
			$Ship.frame += 1  # go forward until last frame
			$Shadow.frame += 1
	elif velocity.x < 0:
		$Ship.flip_h = false
		$Shadow.flip_h = false
		if $Ship.frame < max_frame:
			$Ship.frame += 1
			$Shadow.frame += 1
	else:
		# Return to neutral if tilted
		if $Ship.frame > 0:
			$Ship.frame -= 1
			$Shadow.frame -= 1  
			
	# --- Exhaust Animation Control ---
	var exhaust_max_frame = $Exhaust.sprite_frames.get_frame_count("default") - 1
	if velocity.y < 0:
		$Exhaust.show()
		$Exhaust2.show()
		if $Exhaust.frame < exhaust_max_frame:
			$Exhaust.frame += 1  # go forward until last frame
			$Exhaust2.frame += 1
	else:
		# Return to neutral if tilted
		if $Exhaust.frame > 0:
			$Exhaust.frame -= 1  # go forward until last frame
			$Exhaust2.frame -=1 
		if velocity.y == 0:
			$Exhaust.hide()
			$Exhaust2.hide()
			
	# Shoot
	shoot_timer -= delta
	if Input.is_action_pressed("shoot") and shoot_timer <= 0:
		shoot()
		shoot_timer = shoot_cooldown
	
func start(pos):
	position = pos
	show()
	$Explosion.hide()
	$CollisionPolygon2D.disabled = false
	
	# Show the ship visuals again
	$Ship.show()
	$Shadow.show()
	$Exhaust.show()
	$Exhaust2.show()


func _on_explosion_animation_finished():
	hide()
	hit.emit()
	
func shoot():
	var projectile = ProjectileScene.instantiate()
	projectile.position = position
	get_tree().current_scene.add_child(projectile)  # or a dedicated "Projectiles" node


func _on_area_entered(area: Area2D) -> void:
	# Disable collisions immediately
	$CollisionPolygon2D.set_deferred("disabled", true)
	
	# Hide the ship sprite, but NOT the whole player node
	$Ship.hide()
	$Exhaust.hide()
	$Shadow.hide()
	# Play explosion
	$Explosion.show()
	$Explosion.play()
