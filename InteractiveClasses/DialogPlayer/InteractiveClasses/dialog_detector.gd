class_name DialogDetector extends Node2D

@export var length := 50

var raycast : RayCast2D

var current_dialog : DialogInteractable

var delay := 300
var delay_marker := 0

enum directions {UP, RIGHT, DOWN, LEFT}


func _ready() -> void:
	self.raycast = RayCast2D.new()
	self.raycast.collision_mask = 16
	self.raycast.hit_from_inside = true
	self.raycast.collide_with_areas = true
	self.raycast.collide_with_bodies = false
	self.raycast.target_position = Vector2(0, length)
	self.raycast.enabled = true
	self.add_child(raycast)
	

func _physics_process(delta: float) -> void:
	
	var direction := Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down")
	
	if direction != Vector2(0,0):
		raycast.target_position = direction * length

	if self.raycast.is_colliding():
		emmit_collision()
	else:
		cease_collision()
		
	if Input.is_action_just_pressed("Action") and Time.get_ticks_msec() - delay_marker  >= delay:
		self.delay_marker = Time.get_ticks_msec()
		self.emmit_action_button_pressed()
			

func emmit_collision() -> void:
	var detected_dialog = self.raycast.get_collider()
	
	if detected_dialog != self.current_dialog:
		if self.current_dialog != null:
			self.current_dialog.player_exited()
			
		self.current_dialog = detected_dialog
		self.current_dialog.player_entered(self)
	
	
func cease_collision():
	if self.current_dialog != null:
		self.current_dialog.player_exited()
		self.current_dialog = null
	
	
func emmit_action_button_pressed() -> void:
	if self.current_dialog:
		self.current_dialog.action_button_pressed()
	
			
		
	
	
