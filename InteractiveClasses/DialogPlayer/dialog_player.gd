class_name DialogPlayer extends Control


@export_category("Dialog source")
@export_file("*.txt") var scene_file : String
@export var dialog_id : int
@export var line_id : int

@export_category("Dialog properties")
@export_range(0, 10, .25, "or_greater") var text_speed := 1.0
@export var show_name := false
@export var show_portrait := false

var dialog_dict : Dictionary

var current_dialog : int
var current_line : int
var current_line_dict : Dictionary

var current_content: String
var current_content_size : float
var current_content_index : float

var dialog_ready := false
var line_in_progress := false

@onready var dialog_box : Control = $DialogBox
@onready var background : TextureRect = $DialogBox/Background
@onready var name_label : Label = $DialogBox/NameLabel
@onready var text_label : RichTextLabel = $DialogBox/TextLabel
@onready var portrait_box : AnimatedSprite2D = $DialogBox/PortraitContainer/PortraitBox
@onready var next_button: Button = $DialogBox/NextButton
@onready var sfxs : Dictionary

var delay := 150
var delay_marker := 0

const TEXTSFX = "TextSFX"
const NEXTSFX = "NextSFX"

signal finished()
signal pre_started()
signal post_started()
signal pre_finished()
signal post_finished()


func after_ready() -> void:
	self.dialog_box.visible = false
	
	# Sends a signal to load the CSV files
	call_deferred("load_dialogs")
	
	# Checks if all the nodes are present
	DialogHelper.node_dialog_box(self)
	DialogHelper.node_background(self)
	DialogHelper.node_name_label(self)
	DialogHelper.node_text_label(self)
	DialogHelper.node_portrait_box(self)
	DialogHelper.node_next_button(self)

	# Checks if required SFX are present
	self.sfxs = DialogHelper.check_sfx_nodes(self, [TEXTSFX, NEXTSFX])
	
	# Connects the signals
	self.next_button.button_down.connect(_on_button_down)
	self.next_button.button_up.connect(_on_button_up)
	
	
func load_dialogs() -> void:
	DialogSignal.LoadDialog.emit(self)
	
func pre_start() -> Signal:
	# Here you can provide custom behaviour right before the dialog starts
	# Override this function in classes that inherit from this
	return pre_started
	
func post_start() -> Signal:
	# Here you can provide custom behaviour right after the dialog starts
	# Override this function in classes that inherit from this
	return post_started
	
func start() -> void:
	
	DialogHelper.toggle_dialog_player(self, true)
	
	self.current_dialog = self.dialog_id
	self.current_line = self.line_id
	self.current_line_dict = dialog_dict[dialog_id][line_id]
	
	self.show_line()
	
	await self.post_start()
	
	self.dialog_ready = true
	

func show_line() -> void:	
	
	# Checks if there are more lines to show
	if self.current_line_dict.size() == 0:
		self.finish()

	# Sets everything so the _process method can print the line on screen
	else:
		self.current_content = self.current_line_dict["content"]
		self.current_content_size = self.current_content.length()
		self.current_content_index = 0
		self.text_label.visible_characters = 0
		self.text_label.text = self.current_content
		self.line_in_progress = true
	

func get_next_line() -> void:
	var next_line_code : String = current_line_dict["next-line"]
		
	# Searches the next line
	if next_line_code == "next":
		self.current_line = current_line + 1
		self.current_line_dict = dialog_dict[current_dialog][current_line]
		
	# Ends the dialog
	elif next_line_code == "end":
		self.current_line = 0
		self.current_line_dict = {}
		
	else:
		self.current_dialog = int(next_line_code.split("-")[0])
		self.current_line = int(next_line_code.split("-")[1])
		
		self.current_line_dict[current_dialog][current_line]

		
func _on_button_down() -> void:
	
	if dialog_ready:
	
		self.next_button.add_theme_stylebox_override("focus", preload("res://styles/dialog_button_down.tres"))
		
		# If the line is in progress, pressing the button makes it print completely on screen
		if self.line_in_progress:
			self.current_content_index = self.current_content_size
		
		# Otherwise, it jumps to the next line
		elif Time.get_ticks_msec() - delay_marker  >= delay:
			self.sfxs[NEXTSFX].play(0)
			self.get_next_line()
			self.show_line()
		
		
func _on_button_up() -> void:
	self.next_button.add_theme_stylebox_override("focus", preload("res://styles/dialog_button_focus.tres"))


func _process(delta : float) -> void:
	if line_in_progress:
		
		# If speed is 0, it shows the line immediately
		if self.text_speed == 0.0:
			self.text_label.visible_characters = self.current_content_size
			self.line_in_progress = false
			self.delay_marker = Time.get_ticks_msec()
			
		else:
			var rounded_index : float = round(self.current_content_index)
			var clamped_index := clampf(rounded_index, 0 , self.current_content_size)
			
			# Adds characters from the line to the screen at the specified speed
			self.text_label.visible_characters = clamped_index
			self.current_content_index += self.text_speed
			
			if fmod(rounded_index, 5) == 0:
				var sfx : AudioStreamPlayer = sfxs[TEXTSFX]
				sfx.pitch_scale = randf_range(0.75, 1.0)
				sfx.play(0)
			
			# If it reached the end of line it doesn't update anymore
			if rounded_index > self.current_content_size:
				self.line_in_progress = false
				self.delay_marker = Time.get_ticks_msec()
	
func pre_finish() -> void:
	# Here you can provide custom behaviour right before the dialog finishes
	# Override this function in classes that inherit from this
	pass
	
func post_finish() -> void:
	# Here you can provide custom behaviour right after the dialog finishes
	# Override this function in classes that inherit from this
	pass

func finish():
	
	await self.pre_finish()
	
	self.current_dialog = 0
	self.current_line = 0
	self.current_line_dict = {}
	DialogHelper.toggle_dialog_player(self, false)
	self.dialog_ready = false
	
	await self.post_finish()
	self.finished.emit()
