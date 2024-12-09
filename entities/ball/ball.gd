class_name Ball
extends CharacterBody2D

var speed:int = GameManager.BallSpeed.INIT :
	set(s):
		if s > GameManager.BallSpeed.INIT and s <= speed:
			return
		speed = s
var rng = RandomNumberGenerator.new()
var direction:Vector2 = Vector2.ZERO

signal reset_ball

func _ready() -> void:
	GameManager.game_new.connect(reset)
	GameManager.ball_speed_changed.connect(func(s:int): speed = s)

func reset() -> void:
	velocity = Vector2.ZERO
	reset_ball.emit()

func serve():
	direction = Vector2(rng.randf_range(-1, 1), -1)
	velocity = direction.normalized()
 
func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * speed * delta)
	if collision:
		var collider:Object = collision.get_collider()
		if !handle_velocity_after_collision(collider):
			# if the velocity was not handled after collision, just bounce
			velocity = velocity.bounce(collision.get_normal())
		
		if collider.has_method('take_damage'):
			collider.take_damage(1)
		
		if collider.has_method('trigger_mode_change'):
			collider.trigger_mode_change()

func handle_velocity_after_collision(object:Object) -> bool:	
	# then check if the velocity should be handled
	if object.has_method('ball_velocity_after_bounce'):
		velocity = object.ball_velocity_after_bounce(velocity, position)
		return true
	
	# returning false means that the velocity was not handled
	return false

func _on_screen_exited() -> void:
	GameManager.lives -= 1
	GameManager.brick_streak = 0
	GameManager.mode = GameManager.Mode.NORMAL
	if GameManager.lives > 0:
		await get_tree().create_timer(1.0).timeout
		reset()
