extends Node3D

const LOGNAME = "TiledTerrainSpawner"
const DEFAULT_LENGTH := 6000

@export_dir() var tiles_directory: String
@export var player: Node3D
@export var n_terrains_back := 0
@export var n_terrains_ahead := 2

@onready var _rng := RandomNumberGeneratorManager.get_sub_rng()
var _tiles_files: PackedStringArray
var _first_terrain_z_end := 0.
var _last_terrain_z_end := 0.
var _loading := false
var _next_tile_path := ""


func _ready():
	Logger.add_module(LOGNAME)

	var start_time := Time.get_ticks_msec()

	var tiles_dir := DirAccess.open(tiles_directory)
	if tiles_dir == null:
		Logger.error("Could not open tiles directory", LOGNAME, DirAccess.get_open_error())

	_tiles_files = _filter_scenes(tiles_dir.get_files())

	# Spawn the first tile
	var tile_res := load(_get_random_tile_path())
	var tile = tile_res.instantiate()
	add_child(tile)
	_last_terrain_z_end = tile.get_meta("tile_length", DEFAULT_LENGTH) / 2
	_first_terrain_z_end = _last_terrain_z_end

	var end_time := Time.get_ticks_msec()
	Logger.info("Terrain spawning took %dms" % (end_time - start_time), LOGNAME)


static func _filter_scenes(files: PackedStringArray) -> PackedStringArray:
	var res := PackedStringArray()
	for f in files:
		if f.ends_with(".tscn") or f.ends_with(".scn"):
			res.push_back(f)
	return res


func _on_player_position_changed(player_global_pos: Vector3):
	if player_global_pos.z > _last_terrain_z_end - DEFAULT_LENGTH * n_terrains_ahead:
		_load_next()
	if player_global_pos.z > _first_terrain_z_end + DEFAULT_LENGTH * n_terrains_back:
		_delete_front()


func _load_next():
	if _loading:
		var load_status := ResourceLoader.load_threaded_get_status(_next_tile_path)
		match load_status:
			ResourceLoader.THREAD_LOAD_LOADED:
				_spawn_tile(ResourceLoader.load_threaded_get(_next_tile_path))
				_loading = false
			ResourceLoader.THREAD_LOAD_FAILED:
				Logger.error("Could not load %s" % _next_tile_path, LOGNAME)
				_loading = false
			_:
				pass
		return

	_loading = true
	_next_tile_path = _get_random_tile_path()
	var error := ResourceLoader.load_threaded_request(_next_tile_path, "PackedScene")
	if error != OK:
		Logger.error("Could not load %s" % _next_tile_path, LOGNAME, error)
		_loading = false


func _get_random_tile_path() -> String:
	var path := _tiles_files[_rng.randi_range(0, _tiles_files.size() - 1)]
	return tiles_directory + "/" + path


func _spawn_tile(scene: PackedScene):
	var tile = scene.instantiate()
	var length: float = tile.get_meta("tile_length", DEFAULT_LENGTH)
	tile.position.z = _last_terrain_z_end + length / 2.
	_last_terrain_z_end = _last_terrain_z_end + length
	Logger.info("Spawning tile %s at z=%.0f" % [tile.name, tile.position.z], LOGNAME)
	add_child(tile)


func _delete_front():
	for child in get_children():
		var length: float = child.get_meta("tile_length", DEFAULT_LENGTH)
		if child.position.z + length / 2. <= _first_terrain_z_end:
			Logger.info("Delete tile %s at z=%.0f" % [child.name, child.position.z], LOGNAME)
			child.queue_free()
			return
