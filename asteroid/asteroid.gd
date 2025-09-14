extends Area2D

@export var asteroid_sprites: Array[Texture2D]
var velocity = Vector2.ZERO

signal hit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize_sprite()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += velocity * delta

func randomize_sprite():
	if asteroid_sprites.is_empty():
		return
	var tex = asteroid_sprites.pick_random()
	
	$Sprite2D.texture = tex
	$Explosion.hide()
	
	var shape = CircleShape2D.new()
	shape.radius = tex.get_width() * 0.5 * $Sprite2D.scale.x
	$CollisionShape2D.shape = shape


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()

func _on_explosion_animation_finished() -> void:
	hide()
	hit.emit()

func _on_area_entered(area: Area2D) -> void:
	# Disable collisions immediately
	$CollisionShape2D.set_deferred("disabled", true)
	
	# Play explosion
	$Sprite2D.hide()
	$Explosion.show()
	$Explosion.play()
