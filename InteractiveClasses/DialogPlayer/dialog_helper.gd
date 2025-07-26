class_name DialogHelper extends Node

static func node_dialog_box(node : DialogPlayer) -> void:
	assert(node.dialog_box != null, "The DialogPlayer node must include a Control node named 'DialogBox'.")
	
static func node_background(node : DialogPlayer) -> void:
	assert(node.background != null, "The DialogBox node must include a TextureRect node named 'Background'.")


static func node_text_label(node : DialogPlayer) -> void:
	assert(node.text_label != null, "The DialogBox node must include a RichTextLabel node named 'TextLabel'.")
	
	
static func node_name_label(node : DialogPlayer) -> void:
	if node.show_name:
		assert(node.name_label != null, "The DialogBox node must include a Label node named 'NameLabel'.")
	
	
static func node_portrait_box(node : DialogPlayer) -> void:
	if node.show_portrait:
		assert(node.portrait_box != null, "The DialogBox node must include an AnimatedSprite2D node named 'PortraitBox' inside a Control node name 'PortraitContainer'.")
	
	
static func node_next_button(node : DialogPlayer) -> void:
	assert(node.next_button != null, "The DialogBox node must include a Button node named 'NextButton'.")

	
static func populate_sfx_array(node : DialogPlayer) -> Dictionary:
	var sfx_node = node.get_node("SFX")
	assert(sfx_node != null, "The DialogPlayer node must include a basic node named 'SFX', even if it's empty.")
	
	var sfxs := {}
	
	for child : Node in sfx_node.get_children(true):
		if child is AudioStreamPlayer:
			var sfx := child as AudioStreamPlayer
			sfxs[sfx.name] = sfx
			
	if len(sfxs) == 0: push_warning("SFX Array in '"+node.name+"' has no elements.")
	return sfxs
	

static func check_sfx_nodes(node : DialogPlayer, sfx_names : Array) -> Dictionary:
	var sfxs = DialogHelper.populate_sfx_array(node)
	
	var all_sfx_names := ""
	var check := true
	var i := 0
	
	for name : String in sfx_names:
		if i < sfx_names.size():
			all_sfx_names += name + ", "
		else:
			all_sfx_names += "and" + name if sfx_names.size() > 1 else name
			
		check = sfxs.has(name)
		
	assert(check, "A DialogPlayer node must have the "+all_sfx_names+" node(s).")
	return sfxs


static func toggle_dialog_player(node : DialogPlayer, toggle : bool) -> void:
		node.get_tree().paused = toggle
		node.dialog_box.visible = toggle
		node.next_button.grab_focus() if toggle else node.next_button.release_focus()
