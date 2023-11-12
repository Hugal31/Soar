class_name Leaderboard
extends Resource

@export var scores: Array[int] = []

const MAX_SCORES := 6


## Is this score a new best score? To call before add_score.
func is_new_best_score(score: int) -> bool:
	return scores.is_empty() or score > scores[0]


func add_score(score: int):
	if scores.is_empty() or score > scores.back():
		var insert_index := scores.bsearch_custom(score, func(a, b): return a > b)
		scores.insert(insert_index, score)
		if scores.size() > MAX_SCORES:
			scores.pop_back()
		emit_signal("changed")
