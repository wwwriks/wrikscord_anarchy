class_name DynamicMusicPlayer extends AudioStreamPlayer


# @export var enemy_kill_cooldown: Timer
# @export var intense_delay: Timer


var current_playback: AudioStreamPlaybackInteractive
var interactive_stream: AudioStreamInteractive 
var is_finished: bool
var prev_ambush_mode: bool
var is_intense: bool


const INTRO_COMBAT := "Intro Combat"
const PEACE := "Peace"
const BUTTON := "Button"
const COMBAT := "Combat Loop"
const INTENSE_COMBAT := "Combat Intense Loop"


signal finished_ambush()
signal started_ambush()
signal fight_changed()


func _ready() -> void:
    var p := get_stream_playback()

    if p is AudioStreamPlaybackInteractive:
        current_playback = p
    if stream is AudioStreamInteractive:
        interactive_stream = stream
    else: return

    fight_changed.connect(_manage_state)

    started_ambush.connect(func():
        if is_finished: return
        if prev_ambush_mode == _is_player_currently_ambushed(): return
        prev_ambush_mode = true
        current_playback.switch_to_clip_by_name(INTRO_COMBAT)
    )

    # enemy_kill_cooldown.timeout.connect(func():
    #     if not prev_ambush_mode: return
    #     intense_delay.start()
    # )

    _manage_state()


func _is_player_currently_ambushed() -> bool:
    return not get_tree().get_nodes_in_group("Enemy").is_empty()


func _manage_state() -> void:
    if current_playback == null: return
    if is_finished: return

    var is_currently_intense := _is_intense()
    var is_currently_ambushed := _is_player_currently_ambushed()
    if is_currently_ambushed != prev_ambush_mode:
        current_playback.switch_to_clip_by_name(INTRO_COMBAT if is_currently_ambushed else PEACE)
    if is_currently_intense and not is_intense and is_currently_ambushed:
        if interactive_stream.get_clip_name(current_playback.get_current_clip_index()) != INTENSE_COMBAT:
            current_playback.switch_to_clip_by_name(INTENSE_COMBAT)
    if not is_currently_intense and is_intense:
        current_playback.switch_to_clip_by_name(COMBAT)

    prev_ambush_mode = is_currently_ambushed
    is_intense = is_currently_intense


func _play_musical_button() -> void:
    if not is_inside_tree(): return
    await get_tree().process_frame
    is_finished = true
    if _is_player_currently_ambushed():
        await finished_ambush
    current_playback.switch_to_clip_by_name(BUTTON)


func _is_intense() -> bool:
    ## Unimplemented
    return false
