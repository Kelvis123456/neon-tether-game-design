extends Node

## Procedural audio, ported from prototype/app.js's CyberSynth (Web Audio
## oscillators/noise) to Godot's AudioStreamGenerator. No baked SFX assets —
## every sound is synthesized at play time, same as the browser prototype.

const MIX_RATE := 44100.0
const BGM_PATTERN := [220.00, 261.63, 329.63, 392.00, 329.63, 261.63]
const BGM_STEP_SEC := 0.26

var enabled: bool = true

var _bgm_player: AudioStreamPlayer
var _bgm_playback: AudioStreamGeneratorPlayback
var _bgm_timer: Timer
var _bgm_step: int = 0

func _ready() -> void:
	_bgm_player = AudioStreamPlayer.new()
	var gen := AudioStreamGenerator.new()
	gen.mix_rate = MIX_RATE
	gen.buffer_length = 0.3
	_bgm_player.stream = gen
	_bgm_player.volume_db = linear_to_db(0.05)
	add_child(_bgm_player)

	_bgm_timer = Timer.new()
	_bgm_timer.wait_time = BGM_STEP_SEC
	_bgm_timer.one_shot = false
	_bgm_timer.timeout.connect(_bgm_step_tick)
	add_child(_bgm_timer)

func start_bgm() -> void:
	if not enabled or _bgm_player.playing:
		return
	_bgm_player.play()
	_bgm_playback = _bgm_player.get_stream_playback()
	_bgm_step = 0
	_bgm_step_tick()
	_bgm_timer.start()

func stop_bgm() -> void:
	_bgm_timer.stop()
	_bgm_player.stop()
	_bgm_playback = null

func _bgm_step_tick() -> void:
	if not enabled or _bgm_playback == null:
		return
	var freq: float = BGM_PATTERN[_bgm_step % BGM_PATTERN.size()]
	_bgm_step += 1
	_fill_tone(_bgm_playback, freq, BGM_STEP_SEC * 0.9, 0.5, "triangle")

func play_split() -> void:
	_play_one_shot(150.0, 600.0, 0.15, "sawtooth", 0.15)

func play_merge() -> void:
	_play_one_shot(261.63, 261.63, 0.25, "triangle", 0.2)

func play_graze() -> void:
	_play_one_shot(1200.0, 1500.0, 0.2, "sine", 0.1)

func play_crash() -> void:
	_play_noise_burst(0.4, 0.2)

func _play_one_shot(freq_start: float, freq_end: float, duration: float, wave: String, volume: float) -> void:
	if not enabled:
		return
	var player := AudioStreamPlayer.new()
	var gen := AudioStreamGenerator.new()
	gen.mix_rate = MIX_RATE
	gen.buffer_length = duration + 0.1
	player.stream = gen
	player.volume_db = linear_to_db(volume)
	add_child(player)
	player.play()
	var playback: AudioStreamGeneratorPlayback = player.get_stream_playback()
	_fill_sweep(playback, freq_start, freq_end, duration, wave)
	var timer := get_tree().create_timer(duration + 0.1)
	timer.timeout.connect(player.queue_free)

func _play_noise_burst(duration: float, volume: float) -> void:
	if not enabled:
		return
	var player := AudioStreamPlayer.new()
	var gen := AudioStreamGenerator.new()
	gen.mix_rate = MIX_RATE
	gen.buffer_length = duration + 0.1
	player.stream = gen
	player.volume_db = linear_to_db(volume)
	add_child(player)
	player.play()
	var playback: AudioStreamGeneratorPlayback = player.get_stream_playback()
	var frame_count := int(MIX_RATE * duration)
	for i in frame_count:
		var t := float(i) / frame_count
		var env := 1.0 - t
		var sample := (randf() * 2.0 - 1.0) * env
		playback.push_frame(Vector2(sample, sample))
	var timer := get_tree().create_timer(duration + 0.1)
	timer.timeout.connect(player.queue_free)

func _fill_tone(playback: AudioStreamGeneratorPlayback, freq: float, duration: float, volume: float, wave: String) -> void:
	_fill_sweep(playback, freq, freq, duration, wave, volume)

func _fill_sweep(playback: AudioStreamGeneratorPlayback, freq_start: float, freq_end: float, duration: float, wave: String, volume: float = 1.0) -> void:
	var frame_count := int(MIX_RATE * duration)
	var phase := 0.0
	for i in frame_count:
		var t := float(i) / frame_count
		var freq := lerpf(freq_start, freq_end, t)
		var env := 1.0 - t
		var sample := _wave_sample(wave, phase) * env * volume
		phase += freq / MIX_RATE
		if phase > 1.0:
			phase -= 1.0
		playback.push_frame(Vector2(sample, sample))

func _wave_sample(wave: String, phase: float) -> float:
	match wave:
		"sine":
			return sin(phase * TAU)
		"triangle":
			return 1.0 - 4.0 * absf(round(phase - 0.25) - (phase - 0.25))
		"sawtooth":
			return 2.0 * (phase - floor(phase + 0.5))
		_:
			return sin(phase * TAU)
