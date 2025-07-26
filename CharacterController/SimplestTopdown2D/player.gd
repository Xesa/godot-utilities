class_name Player extends CharacterBody2D


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _process(delta : float) -> void:
	
	var direction := Input.get_vector("Move Left", "Move Right", "Move Up", "Move Down")
	
	if direction != Vector2(0,0):
		sprite.play("running")
		self.velocity = direction * 10000 * delta
		
		if direction.x < 0:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
			
	else:
		self.velocity = Vector2(0,0)
		sprite.play("idle")
		
	move_and_slide()
