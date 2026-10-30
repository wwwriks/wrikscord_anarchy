extends BTAction


func _tick(_delta: float) -> Status:
    var nav := blackboard.get_var("navigation") as NavigationAgent3D


    nav.target_position = agent.get_tree().get_first_node_in_group("Player").global_position


    return SUCCESS
