@tool
extends VBoxContainer

signal open_path_requested(path: String)

const ROOT_PATH := "res://"
const ROW_HEIGHT := 22

var _tree: Tree
var _expanded_paths: Dictionary = {}


func _init() -> void:
	name = "IDEAFileTree"
	custom_minimum_size = Vector2(230, 180)
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL

	_tree = Tree.new()
	_tree.name = "ProjectTree"
	_tree.hide_root = false
	_tree.columns = 1
	_tree.column_titles_visible = false
	_tree.select_mode = Tree.SELECT_SINGLE
	_tree.allow_rmb_select = true
	_tree.enable_recursive_folding = true
	_tree.custom_minimum_size = Vector2(0, 120)
	_tree.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_tree.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_tree.add_theme_constant_override("v_separation", 0)
	_tree.add_theme_constant_override("h_separation", 4)
	_tree.add_theme_constant_override("item_margin", 16)
	_tree.add_theme_constant_override("inner_item_margin_left", 2)
	_tree.add_theme_constant_override("button_margin", 2)
	_tree.add_theme_constant_override("draw_guides", 0)
	_tree.add_theme_constant_override("draw_relationship_lines", 1)
	_tree.add_theme_constant_override("relationship_line_width", 1)
	_tree.add_theme_constant_override("parent_hl_line_width", 1)
	_tree.add_theme_constant_override("children_hl_line_width", 1)
	_tree.add_theme_color_override("relationship_line_color", Color(0.48, 0.51, 0.56, 0.55))
	_tree.add_theme_color_override("font_color", Color(0.78, 0.80, 0.83))
	_tree.add_theme_color_override("font_hovered_color", Color(0.92, 0.93, 0.95))
	_tree.item_activated.connect(_on_item_activated)
	_tree.item_collapsed.connect(_on_item_collapsed)
	add_child(_tree)

	call_deferred("refresh")


func refresh() -> void:
	if not is_instance_valid(_tree):
		return
	_remember_expanded_items()
	_tree.clear()
	var root := _tree.create_item()
	_setup_item(root, ROOT_PATH, true)
	root.set_text(0, "res://")
	root.set_collapsed(false)
	_add_directory(root, ROOT_PATH)


func _add_directory(parent: TreeItem, directory_path: String) -> void:
	var directory := DirAccess.open(directory_path)
	if directory == null:
		return
	var directories: PackedStringArray = []
	var files: PackedStringArray = []
	directory.list_dir_begin()
	var entry := directory.get_next()
	while not entry.is_empty():
		if not entry.begins_with("."):
			if directory.current_is_dir():
				directories.append(entry)
			else:
				files.append(entry)
		entry = directory.get_next()
	directory.list_dir_end()
	directories.sort()
	files.sort()
	for directory_name in directories:
		var child_path := directory_path.path_join(directory_name)
		var child := _tree.create_item(parent)
		_setup_item(child, child_path, true)
		child.set_text(0, directory_name)
		child.set_collapsed(not _expanded_paths.has(child_path))
		_add_directory(child, child_path)
	for file_name in files:
		var file_path := directory_path.path_join(file_name)
		var child := _tree.create_item(parent)
		_setup_item(child, file_path, false)
		child.set_text(0, file_name)


func _setup_item(item: TreeItem, path: String, is_directory: bool) -> void:
	item.set_metadata(0, path)
	item.set_custom_minimum_height(ROW_HEIGHT)
	item.set_icon_max_width(0, 16)
	item.set_tooltip_text(0, path)
	var icon_name := &"Folder" if is_directory else _icon_name_for_file(path)
	if has_theme_icon(icon_name, &"EditorIcons"):
		item.set_icon(0, get_theme_icon(icon_name, &"EditorIcons"))
	elif has_theme_icon(&"File", &"EditorIcons"):
		item.set_icon(0, get_theme_icon(&"File", &"EditorIcons"))


func _icon_name_for_file(path: String) -> StringName:
	match path.get_extension().to_lower():
		"gd": return &"GDScript"
		"tscn", "scn": return &"PackedScene"
		"tres", "res": return &"ResourcePreloader"
		"png", "jpg", "jpeg", "webp", "svg": return &"ImageTexture"
		"wav", "ogg", "mp3": return &"AudioStreamPlayer"
		"md", "txt", "json", "cfg": return &"TextFile"
		_: return &"File"


func _on_item_activated() -> void:
	var item := _tree.get_selected()
	if item == null:
		return
	if item.get_child_count() > 0:
		item.set_collapsed(not item.is_collapsed())
		return
	var path: String = item.get_metadata(0)
	if not DirAccess.dir_exists_absolute(ProjectSettings.globalize_path(path)):
		open_path_requested.emit(path)


func _on_item_collapsed(item: TreeItem) -> void:
	var path: String = item.get_metadata(0)
	if item.is_collapsed():
		_expanded_paths.erase(path)
		_collapse_descendants(item)
	else:
		_expanded_paths[path] = true


func _collapse_descendants(item: TreeItem) -> void:
	var child := item.get_first_child()
	while child != null:
		if child.get_child_count() > 0:
			child.set_collapsed(true)
			_expanded_paths.erase(child.get_metadata(0))
			_collapse_descendants(child)
		child = child.get_next()


func _remember_expanded_items() -> void:
	if _tree.get_root() == null:
		return
	_expanded_paths.clear()
	_collect_expanded(_tree.get_root())


func _collect_expanded(item: TreeItem) -> void:
	if item.get_child_count() > 0 and not item.is_collapsed():
		_expanded_paths[item.get_metadata(0)] = true
	var child := item.get_first_child()
	while child != null:
		_collect_expanded(child)
		child = child.get_next()
