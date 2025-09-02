extends RefCounted
class_name OzqnLoader

static func load(resource_path: String, tree: SceneTree) -> Resource:
	var progress: Array[int] = [0]
	var resource: Resource
	
	ResourceLoader.load_threaded_request(resource_path)
	
	while true:
		var status := ResourceLoader.load_threaded_get_status(resource_path, progress)
		if tree == null:
			break
		await tree.process_frame
		match status:
			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
				assert(false, "Given Resource Path is invalid!")
				break
			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
				assert(false, "Failed to load resource on thread.")
				break
			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
				resource = ResourceLoader.load_threaded_get(resource_path)
				break
			ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS:
				continue
	return resource
