extends Node

class_name GPGS

const LEADERBOARD_HIGH_SCORE = "CgkIj5LP34QHEAIQAQ"

var play_games_services

func _ready():
	if Engine.has_singleton("GodotPlayGamesServices"):
		play_games_services = Engine.get_singleton("GodotPlayGamesServices")
		play_games_services.connect("_on_sign_in_success", self, "_on_sign_in_success")
		play_games_services.connect("_on_sign_in_failed", self, "_on_sign_in_failed")
		play_games_services.connect("_on_sign_out_success", self, "_on_sign_out_success")
		play_games_services.connect("_on_sign_out_failed", self, "_on_sign_out_failed")
		play_games_services.connect("_on_achievement_unlocked", self, "_on_achievement_unlocked")
		play_games_services.connect("_on_achievement_unlocking_failed", self, "_on_achievement_unlocking_failed")
		play_games_services.connect("_on_achievement_revealed", self, "_on_achievement_revealed")
		play_games_services.connect("_on_achievement_revealing_failed", self, "_on_achievement_revealing_failed")
		play_games_services.connect("_on_achievement_incremented", self, "_on_achievement_incremented")
		play_games_services.connect("_on_achievement_incrementing_failed", self, "_on_achievement_incrementing_failed")
		play_games_services.connect("_on_achievement_steps_set", self, "_on_achievement_steps_set")
		play_games_services.connect("_on_achievement_steps_setting_failed", self, "_on_achievement_steps_setting_failed")
		play_games_services.connect("_on_leaderboard_score_submitted", self, "_on_leaderboard_score_submitted")
		play_games_services.connect("_on_leaderboard_score_submitting_failed", self, "_on_leaderboard_score_submitting_failed")
		play_games_services.connect("_on_game_saved_success", self, "_on_game_saved_success")
		play_games_services.connect("_on_game_saved_fail", self, "_on_game_saved_fail")
		play_games_services.connect("_on_game_load_success", self, "_on_game_load_success")
		play_games_services.connect("_on_game_load_fail", self, "_on_game_load_fail")
		play_games_services.connect("_on_create_new_snapshot", self, "_on_create_new_snapshot")
		play_games_services.connect("_on_player_info_loaded", self, "_on_player_info_loaded")
		play_games_services.connect("_on_player_info_loading_failed", self, "_on_player_info_loading_failed")
		play_games_services.init(true)
	else:
		print("GodotPlayGamesServices Java Singleton not found")

# Sign-in/sign-out methods
func sign_in() -> void:
	if play_games_services:
		play_games_services.signIn()


func sign_out() -> void:
	if play_games_services:
		play_games_services.signOut()


func check_if_signed_in() -> void:
	if play_games_services:
		var is_signed_in: bool = play_games_services.isSignedIn()
		print("Signed in: %s"%is_signed_in)	


# Achievements methods
func unlock_achievement(id) -> void:
	if play_games_services:
		play_games_services.unlockAchievement(id)


func reveal_achievement(id) -> void:
	if play_games_services:
		play_games_services.revealachievement(id) 


func increment_achievement(id, step) -> void:
	if play_games_services:
		play_games_services.incrementAchievement(id, step) 


func show_achievements() -> void:
	if play_games_services:
		play_games_services.showAchievements()


# Leaderboards methods
func show_leaderboard() -> void:
	if play_games_services:
		play_games_services.showLeaderBoard(LEADERBOARD_HIGH_SCORE) 


func show_all_leaderboards() -> void:
	if play_games_services:
		play_games_services.showAllLeaderBoards()


func submit_leaderboard_score(score: int) -> void:
	if play_games_services:
		play_games_services.submitLeaderBoardScore(LEADERBOARD_HIGH_SCORE, score) 

#Save game methods
func save_game() -> void:
	pass


func show_saved_games() -> void:
	if play_games_services:
		play_games_services.showSavedGames("SAVED_GAME", true, true, 5)


func load_player_info() -> void:
	if play_games_services:
		play_games_services.loadPlayerInfo()


# CALLBACKS
# Sign-in / sign-out callbacks
func _on_sign_in_success(account_id: String) -> void:
	print("Sign in success %s"%account_id)

func _on_sign_in_failed(error_code: int, message: String) -> void:
	print("Sign in failed %s, %s" % [error_code, message])

func _on_sign_out_success() -> void:
	print("Sign out success")

func _on_sign_out_failed() -> void:
	print("Sign out failed")

# Achievements callbacks
func _on_achievement_unlocked(achievement: String) -> void:
	print("Achievement %s unlocked"%achievement)

func _on_achievement_unlocking_failed(achievement: String) -> void:
	print("Achievement %s unlocking failed "%achievement)

func _on_achievement_revealed(achievement: String) -> void:
	print("Achievement %s revealed"%achievement)

func _on_achievement_revealing_failed(achievement: String) -> void:
	print("Achievement %s revealing failed"%achievement)

func _on_achievement_incremented(achievement: String) -> void:
	print("Achievement %s incremented"%achievement)

func _on_achievement_incrementing_failed(achievement: String) -> void:
	print("Achievement %s incrementing failed"%achievement)

func _on_achievement_steps_set(achievement: String) -> void:
	print("Achievement %s steps set"%achievement)

func _on_achievement_steps_setting_failed(achievement: String) -> void:
	print("Achievement %s steps setting failed"%achievement)


# Leaderboards callbacks
func _on_leaderboard_score_submitted(leaderboard_id: String) -> void:
	print("LeaderBoard %s, score submitted"%leaderboard_id)

func _on_leaderboard_score_submitting_failed(leaderboard_id: String) -> void:
	print("LeaderBoard %s, score submitting failed"%leaderboard_id)


# Saved game Callbacks:
func _on_game_saved_success():
	print("Game saved success")

func _on_game_saved_fail():
	print("Game saved fail")

func _on_game_load_success(_data):
	pass

func _on_game_load_fail():
	print("Game load fail")

func _on_create_new_snapshot(name:String):
	print("Create new snapshot %s"%name)


# Player Info Callbacks
func _on_player_info_loaded(player_info: String):
	var player_info_dictionary: Dictionary = parse_json(player_info)
	print(player_info_dictionary)

func _on_player_info_loading_failed():
	print("Player info loading failed")

