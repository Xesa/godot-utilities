class_name DialogManager extends Node

@export_dir var dialog_folder : String

var dialogs := {}


func _ready():
	DialogSignal.LoadDialog.connect(_on_load_dialog)
				
				
func _on_load_dialog(dialog_player : DialogPlayer) -> void:
	
	var file_path := dialog_player.scene_file
	
	if file_path:
		var file_name := file_path.get_file().get_basename()
		
		if !self.dialogs.has(file_name):
			self.dialogs[file_name] = read_csv(file_path)
		
		dialog_player.dialog_dict = self.dialogs[file_name]


func read_csv(file_path : String) -> Dictionary:
	var file = FileAccess.open(file_path, FileAccess.READ)
	
	assert(file != null, "No se pudo abrir el archivo " + file_path + ".")
	
	var result = {}
	var headers = []
	
	var is_first_line = true
	
	while not file.eof_reached():
		
		var line = file.get_line().strip_edges()
		if line == "":
			continue
			
		var parts = line.split("|")
		
		if is_first_line:
			headers = parts
			is_first_line = false
		else:
			var dialog_id = int(parts[0])
			var line_id = int(parts[1])
			var row_dict = {}
			
			for i in range(2, parts.size()):
				row_dict[headers[i]] = parts[i]
			
			if !result.has(dialog_id):
				result[dialog_id] = {}
				
			result[dialog_id][line_id] = row_dict
	
	file.close()
	return result
