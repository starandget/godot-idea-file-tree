@tool
extends EditorPlugin

const FileTreeView := preload("res://addons/idea_file_tree/idea_file_tree.gd")

var _dock: EditorDock
var _view: Control


func _enter_tree() -> void:
	_view = FileTreeView.new()
	_view.open_path_requested.connect(_open_path)

	_dock = EditorDock.new()
	_dock.title = "Project"
	_dock.icon_name = &"Filesystem"
	_dock.default_slot = EditorDock.DOCK_SLOT_LEFT_BR
	_dock.available_layouts = EditorDock.DOCK_LAYOUT_VERTICAL | EditorDock.DOCK_LAYOUT_FLOATING
	_dock.add_child(_view)
	add_dock(_dock)

	var editor_filesystem := get_editor_interface().get_resource_filesystem()
	editor_filesystem.filesystem_changed.connect(_view.refresh)


func _exit_tree() -> void:
	var editor_filesystem := get_editor_interface().get_resource_filesystem()
	if editor_filesystem.filesystem_changed.is_connected(_view.refresh):
		editor_filesystem.filesystem_changed.disconnect(_view.refresh)

	remove_dock(_dock)
	_dock.queue_free()
	_dock = null
	_view = null


func _open_path(path: String) -> void:
	if path.get_extension().to_lower() in ["tscn", "scn"]:
		get_editor_interface().open_scene_from_path(path)
		return

	var resource := ResourceLoader.load(path)
	if resource != null:
		get_editor_interface().edit_resource(resource)
	else:
		get_editor_interface().get_file_system_dock().navigate_to_path(path)


