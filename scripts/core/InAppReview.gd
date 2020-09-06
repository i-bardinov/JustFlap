extends Node

class_name InAppReview

enum InAppReviewStatus {
	None,
	Requested,
	Received,
	Shown
}

var in_app_review

var review_starts_required: int = 3
var review_info = InAppReviewStatus.None

func _ready():
	if Engine.has_singleton("GodotGooglePlayInAppReview"):
		in_app_review = Engine.get_singleton("GodotGooglePlayInAppReview")
		in_app_review.connect("on_request_review_success", self, "_on_request_review_success")
		in_app_review.connect("on_request_review_failed", self, "_on_request_review_failed")
		in_app_review.connect("on_launch_review_flow_success", self, "_on_launch_review_flow_success")
	else:
		print("GodotGooglePlayInAppReview Java Singleton not found")

func request_review_info() -> void:
	if in_app_review and review_info == InAppReviewStatus.None:
		review_info = InAppReviewStatus.Requested
		in_app_review.requestReviewInfo()

func launch_review_flow() -> void:
	if in_app_review and review_info == InAppReviewStatus.Received:
		in_app_review.launchReviewFlow()

func _on_request_review_success() -> void:
	review_info = InAppReviewStatus.Received

func _on_request_review_failed() -> void:
	review_info = InAppReviewStatus.None

func _on_launch_review_flow_success() -> void:
	review_info = InAppReviewStatus.Shown

func _on_Level_reset():
	if review_info == InAppReviewStatus.Shown:
		return
	if Global.matches_count >= 1 && Global.start_count % review_starts_required == 0:
		request_review_info()

func _on_Level_game_over():
	launch_review_flow()
