class_name DialogInteractable extends Area2D

var dialog_player : DialogPlayer

@onready var collider : CollisionShape2D = $Collider
@onready var sprite : AnimatedSprite2D = $Sprite

var detector : DialogDetector
	

func _ready() -> void:
	assert(self.collider != null, "The DialogInteractable node must include a CollisionShape2D node named 'Collider'.")
	assert(self.sprite != null, "The DialogInteractable node must include an AnimatedSprite2D node named 'Sprite'.")
	
	self.dialog_player = get_parent()
	assert(self.dialog_player != null, "The DialogInteractable node must be placed inside a DialogPlayer node.")
	
	self.sprite.visible = false
	
	self.dialog_player.finished.connect(on_dialog_finished)
	
	
func action_button_pressed() -> void:
	self.sprite.visible = false
	self.sprite.stop()
	dialog_player.start()
	
	
func player_entered(detector : DialogDetector) -> void:
	self.detector = detector
	self.sprite.visible = true
	self.sprite.play("idle")
	
	
func player_exited() -> void:
	self.detector = null
	self.sprite.visible = false
	self.sprite.stop()
	
	
func on_dialog_finished() -> void:
	if self.detector != null:
		self.sprite.visible = true
		self.sprite.play("idle")
		self.detector.delay_marker = Time.get_ticks_msec()
	
