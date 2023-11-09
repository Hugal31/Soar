extends Node

@export var leaderboard: Leaderboard

const LOGNAME := "LeaderboardManager"
const SAVE_PATH := "user://leaderboard.tres"


func _ready():
	Logger.add_module(LOGNAME)
	leaderboard = load(SAVE_PATH)
	if leaderboard == null:
		Logger.info("Not leaderboard found, create leaderboard", LOGNAME)
		leaderboard = Leaderboard.new()
		save_leaderboard()
	leaderboard.changed.connect(save_leaderboard)


func save_leaderboard():
	var error := ResourceSaver.save(leaderboard, SAVE_PATH)
	if error != OK:
		Logger.error("Could not save leaderboard", LOGNAME, error)
