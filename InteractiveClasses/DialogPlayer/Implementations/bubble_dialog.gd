class_name BubbleDialog extends DialogPlayer


func _ready() -> void:
	self.after_ready()
	
func post_start() -> Signal:
	var scale = self.dialog_box.scale.x
	
	self.dialog_box.scale.x = 0.0
	self.dialog_box.scale.y = 0.0
	
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_BACK)
		
	tween.tween_property(self.dialog_box, "scale", Vector2(0, 0), 0.2)
	tween.tween_property(self.dialog_box, "scale", Vector2(scale * 1.05, scale * 1.05), 0.2)
	tween.tween_property(self.dialog_box, "scale", Vector2(scale * 0.95, scale * 0.95), 0.1)
	tween.tween_property(self.dialog_box, "scale", Vector2(scale * 1.025, scale * 1.025), 0.1)
	tween.tween_property(self.dialog_box, "scale", Vector2(scale * 1.0, scale * 1.0), 0.1)
	
	return tween.finished
