extends Area3D

# Declare signals
signal body_entered_signal(body)
signal body_exited_signal(body)

# Called when the node enters the scene tree for the first time.
func _ready():
	# Connect the signals using the connect method
	#connect("body_entered", self, "_on_body_entered")
	#connect("body_exited", self, "_on_body_exited")
	print("testing")

func _on_body_entered(body):
	if body is CharacterBody3D:
		# Character entered the trigger box
		# You can add your custom logic here
		print("Character entered the trigger box")
		emit_signal("body_entered_signal", body)
		body.game_over()

func _on_body_exited(body):
	if body is CharacterBody3D:
		# Character exited the trigger box
		# You can add your custom logic here
		print("Character exited the trigger box")
		emit_signal("body_exited_signal", body)
