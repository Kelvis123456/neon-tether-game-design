extends Node

## Encrypted local save file, per architecture.md's SaveSystem spec (AES-256
## wrapping to "protect database integrity"). This deters casual save-file
## editing of crystals/scores; it is not confidentiality against someone who
## has the game's own binary, since the passphrase ships inside it — same
## threat model as the architecture doc's "integrity" framing, not a secrets
## vault.

const SAVE_PATH := "user://neon_tether.save"
const SAVE_PASSPHRASE := "neon-tether-v1-integrity-key"

func save_data(data: Dictionary) -> bool:
	var file := FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.WRITE, SAVE_PASSPHRASE)
	if file == null:
		push_warning("SaveSystem: failed to open save file for writing (%s)" % error_string(FileAccess.get_open_error()))
		return false
	file.store_string(JSON.stringify(data))
	file.close()
	return true

func load_data() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file := FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.READ, SAVE_PASSPHRASE)
	if file == null:
		return {}
	var text := file.get_as_text()
	file.close()
	var parsed = JSON.parse_string(text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return parsed
