extends VBoxContainer

var _labels: Array[Label] = []


func _ready():
	LeaderboardManager.leaderboard.changed.connect(_update_list)
	# Use already existing labels
	for child in get_children():
		if child is Label:
			_labels.push_back(child)
	for i in range(_labels.size(), Leaderboard.MAX_SCORES):
		var label := Label.new()
		_labels.push_back(label)
		add_child(label)
	_update_list()


func _update_list():
	for i in range(0, Leaderboard.MAX_SCORES):
		if i < LeaderboardManager.leaderboard.scores.size():
			_labels[i].text = "#%d: %d" % [i + 1, LeaderboardManager.leaderboard.scores[i]]
		else:
			_labels[i].text = "#%d:" % [i + 1]
