extends Control

@onready var ui_audio_player: UIAudioPlayer = $UIAudioPlayer
@onready var start_button: Button = $VBoxContainer/VBoxContainer/start_button
@onready var stats_button: Button = $VBoxContainer/VBoxContainer/stats_button
@onready var exit_button: Button = $VBoxContainer/VBoxContainer/exit_button
@onready var music_toggle: Button = $VBoxContainer/HBoxContainer/music_toggle
@onready var sfx_toggle: Button = $VBoxContainer/HBoxContainer/sfx_toggle
@onready var stats_popup: PopupPanel = $StatsPopup


var sfx_bus_index:int
var music_bus_index:int

func _ready() -> void:
	music_bus_index = AudioServer.get_bus_index('music')
	sfx_bus_index = AudioServer.get_bus_index('sfx')
	
	start_button.pressed.connect(func(): ui_audio_player.button_pressed(); start())
	stats_button.pressed.connect(func(): stats_popup.visible = true)
	exit_button.pressed.connect(func(): ui_audio_player.button_pressed(); get_tree().quit())
	music_toggle.toggled.connect(toggle_music)
	sfx_toggle.toggled.connect(toggle_sfx)
	
	music_toggle.set_pressed_no_signal(!AudioServer.is_bus_mute(music_bus_index))
	sfx_toggle.set_pressed_no_signal(!AudioServer.is_bus_mute(sfx_bus_index))

func start():
	GameManager.game = GameManager.Game.NEW
	get_tree().change_scene_to_file('res://scenes/main.tscn')

func toggle_music(is_on:bool):
	ui_audio_player.button_pressed()
	AudioServer.set_bus_mute(music_bus_index, !is_on)
	SaveSystem.settings.audio.music = is_on
	SaveSystem.save_settings()

func toggle_sfx(is_on:bool):
	ui_audio_player.button_pressed()
	AudioServer.set_bus_mute(sfx_bus_index, !is_on)
	SaveSystem.settings.audio.sfx = is_on
	SaveSystem.save_settings()
