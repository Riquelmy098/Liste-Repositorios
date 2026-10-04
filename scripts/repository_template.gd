extends PanelContainer

@onready var description_node = $VBoxContainer/description
@onready var title_node = $VBoxContainer/title
@onready var owner_node = $VBoxContainer/VBoxContainer/owner

var description = ""
var title = ""
var _owner = ""
var url = ""

func _ready() -> void:
	if description == null and title == null:
		queue_free()
		return
	
	if description:
		description_node.text = description
	if title:
		title_node.text = title
	owner_node.text = _owner

func _on_open_pressed() -> void:
	if url != "":
		OS.shell_open(url)
