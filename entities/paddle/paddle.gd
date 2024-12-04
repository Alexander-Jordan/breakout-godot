extends CharacterBody2D

@export var ball:Ball

var input_pos:Vector2 = self.position
var speed:int = 2000
var lock_ball:bool = true

signal spawn_ball()

func _ready() -> void:
	if ball:
		ball.reset_ball.connect(func(): lock_ball = true)

func _physics_process(delta: float) -> void:
	input_pos = get_viewport().get_mouse_position()
	velocity = Vector2(input_pos.x - position.x, 0) * speed * delta
	move_and_slide()
	
	if lock_ball:
		lock_ball_to_paddle()
		if Input.is_action_just_pressed('serve'):
			serve_ball()

func lock_ball_to_paddle() -> void:
	if ball:
		ball.position = Vector2(position.x, position.y - 20)

func serve_ball() -> void:
	if ball and lock_ball:
		lock_ball = false
		ball.serve()

func ball_velocity_after_bounce(ball_velocity:Vector2, ball_position:Vector2) -> Vector2:
	# new y should be:
	# - negative if the ball on impact is from the top of the paddle
	# - positive if the ball on impact is from the bottom of the paddle
	var new_y:float = -abs(ball_velocity.y) if ball_position.y <= position.y else abs(ball_velocity.y)
	# how far from the center in x-axis was the hit?
	var from_center:float = ball_position.x - position.x
	# new x is calculated by normalizing from_center (ex. 20 to -20 range -> 1 to -1 range)
	# that's done by dividing from_center with max value (in this case: width / 2)
	var new_x:float = from_center / ((6 * scale.x) / 2)
	# clamp new_x so it doesn't shoot straight left or right
	new_x = clampf(new_x, -0.9, 0.9)
	return Vector2(new_x, new_y).normalized()