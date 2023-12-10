extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$MarginContainer/VBoxContainer/Start.grab_focus()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_pressed():
	get_tree().change_scene_to_file("res://Scenes/LVL0.tscn")
	pass 

func _on_settings_pressed():
	#var settings = load("SETTINGS").instance() ## MAKE SETTINGS SCENE
	pass



func _on_credits_pressed():
	#var settings = load("SETTINGS").instance() ## MAKE SETTINGS SCENE
	pass


func _on_quit_pressed():
	get_tree().quit()
