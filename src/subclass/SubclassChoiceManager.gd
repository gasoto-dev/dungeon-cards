## SubclassChoiceManager — thin seam for the subclass picker UI (no scene yet)
## Wraps SubclassManager for the post-boss subclass selection flow.
class_name SubclassChoiceManager

var _subclass_manager: SubclassManager

func _init() -> void:
	_subclass_manager = SubclassManager.new()

## Returns the 5 available schools for display in the choice UI
func present_choice() -> Array[SubclassData]:
	return _subclass_manager.available_schools()

## Confirm the player's school selection
func confirm_choice(school_id: String) -> void:
	_subclass_manager.select_school(school_id)

## Returns the confirmed active subclass (null if none confirmed yet)
func active_subclass() -> SubclassData:
	return _subclass_manager.active_subclass()
