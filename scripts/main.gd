extends Control

@onready var Http: HTTPRequest = $HTTPRequest
@onready var search_button: Button = $VBoxContainer/search

@onready var scroll_list: VBoxContainer = $ScrollContainer/VBoxContainer
@onready var token_edit: LineEdit = $VBoxContainer/token
@onready var file_name_edit: LineEdit = $"VBoxContainer/file name"
@onready var extension_edit: LineEdit = $VBoxContainer/extension

var repository_template = preload("res://scenes/repository template.tscn")

func search(file_name,extension,token):
	Http.cancel_request()
	
	if scroll_list.get_child_count() > 0:
		for node in scroll_list.get_children():
			node.queue_free()
	
	if token == "":
		return
	
	var url
	
	if file_name != "" or extension != "":
		if file_name != "" and extension != "":
			url = "https://api.github.com/search/code?q=%s+extension:%s" % [file_name,extension]
		elif file_name != "" and extension == "":
			url = "https://api.github.com/search/code?q=filename:%s" % file_name
		else:
			url = "https://api.github.com/search/code?q=extension:%s" % extension

		var headers = [
			"Accept: application/vnd.github+json",
			"Authorization: Bearer " + token,
			"X-GitHub-Api-Version: 2026-03-10"
		]
		
		search_button.disabled = true
		Http.request(url, headers)

func _on_http_request_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS:
		search_button.disabled = false
		return
		
	if response_code != 200:
		search_button.disabled = false
		return

	search_button.disabled = false
	var _body = JSON.parse_string(body.get_string_from_utf8())
	
	for item in _body["items"]:
		create_repository_item(item)

func _on_search_pressed() -> void:
	search(
		file_name_edit.text.strip_edges(),
		extension_edit.text.strip_edges(),
		token_edit.text.strip_edges()
	)

func create_repository_item(item):
	var repo = item["repository"]
	var inst = repository_template.instantiate()
	
	inst.description = repo["description"]
	inst.title = repo["full_name"]
	inst.url = item["html_url"]
	inst._owner = repo["owner"]["login"] + " | " + item["path"]
	
	scroll_list.add_child(inst)
