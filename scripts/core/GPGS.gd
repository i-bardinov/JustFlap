extends Node

class_name GPGS

const LEADERBOARD_HIGH_SCORE = "CgkIj5LP34QHEAIQAQ"

var play_games_services

func _ready():
	if Engine.has_singleton("GodotPlayGamesServices"):
		play_games_services = Engine.get_singleton("GodotPlayGamesServices")
		play_games_services.init(true)
	else:
		print("GodotPlayGamesServices Java Singleton not found")

func is_inited():
	return play_games_services != null

# Sign-in/sign-out methods
func sign_in(is_silent: bool) -> void:
	if play_games_services:
		play_games_services.signIn(is_silent)


func sign_out() -> void:
	if play_games_services:
		play_games_services.signOut()


func is_signed_in() -> bool:
	return play_games_services && play_games_services.isSignedIn()

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
