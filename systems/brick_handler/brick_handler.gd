extends Node2D

@export var scene:PackedScene
@export var resources:Array[BrickResource]
@export var audio_brick_destroyed:AudioStream
@export var audio_bricks_reset:AudioStream

@onready var audio_player_2d: AudioPlayer2D = $AudioPlayer2D

var bricks_destroyed:Array[Brick] = []
var rows:Array[BrickResource] = []

const ROWS:int = 8
const COLUMNS:int = 14

func _ready() -> void:
	GameManager.bricks_reset.connect(bricks_reset)
	GameManager.bricks_clear.connect(bricks_clear)
	GameManager.game_changed.connect(func(game:int): if game == GameManager.Game.NEW: bricks_reset())
	bricks_reset()

func setup_rows():
	rows = []
	var r_size = resources.size()
	var rows_per_type:float = float(ROWS) / float(r_size)
	var remainder = ROWS % r_size
	
	for r_index in r_size:
		var rows_for_resource:int = floori(rows_per_type) if r_index + 1 <= r_size - remainder else ceili(rows_per_type)
		for row in rows_for_resource:
			rows.append(resources[r_index])

func bricks_clear() -> void:
	for brick in get_children():
		if brick is Brick and !brick.is_destroyed:
			brick.destroy()

func bricks_reset() -> void:
	bricks_clear()
	audio_player_2d.play_audio(audio_bricks_reset)
	setup_rows()
	var offset = Vector2(9, 85)
	for row in rows.size():
		for column in COLUMNS:
			var brick = spawn_brick(rows[row])
			var p:Vector2 = Vector2(
				# each brick is 2 pixels in height, 6 pixels in width
				# add 4 pixels as margin between bricks
				column * ((6 * brick.scale.x) + 4),
				row * ((2 * brick.scale.y) + 4)
			)
			brick.position = p + offset

func spawn_brick(resource:BrickResource) -> Brick:
	var brick:Brick
	if bricks_destroyed.is_empty():
		brick = scene.instantiate()
		add_child(brick)
	else:
		brick = bricks_destroyed.pop_back()
	
	brick.init(resource)
	if !brick.destroyed.is_connected(handle_destroyed_brick):
		brick.destroyed.connect(handle_destroyed_brick.bind(brick))
	
	return brick

func handle_destroyed_brick(brick:Brick):
	if brick not in bricks_destroyed:
		bricks_destroyed.append(brick)
		audio_player_2d.play_audio(audio_brick_destroyed)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Ball and bricks_destroyed.size() == (ROWS * COLUMNS):
		GameManager.bricks_reset.emit()
		if SaveSystem.is_score_saveable:
			SaveSystem.stats.screens_cleared_count += 1
