class_name PowerData extends RefCounted

const GRID_SIZE: int = 1024
const GRID_HALF: int = GRID_SIZE / 2
const SOURCE_TEX_SIZE: int = 256
const MAX_SOURCES: int = SOURCE_TEX_SIZE * SOURCE_TEX_SIZE
const POOL_WIDTH: int = 1024
const POOL_ENTRIES: int = POOL_WIDTH * POOL_WIDTH / 2


class Buffer:
	var data: PackedByteArray = PackedByteArray()
	var image: Image
	var texture: ImageTexture
	var dirty: bool = false

	func _init(width: int, height: int, format: Image.Format, bytesPerTexel: int) -> void:
		data.resize(width * height * bytesPerTexel)
		data.fill(0)
		image = Image.create_empty(width, height, false, format)
		texture = ImageTexture.create_from_image(image)

	func clear() -> void:
		data.fill(0)
		dirty = true

	func flush() -> void:
		if not dirty: return
		dirty = false
		image.set_data(image.get_width(), image.get_height(), false, image.get_format(), data)
		texture.update(image)


var cells := Buffer.new(GRID_SIZE, GRID_SIZE, Image.FORMAT_RGBA8, 4)
var sources := Buffer.new(SOURCE_TEX_SIZE, SOURCE_TEX_SIZE, Image.FORMAT_R8, 1)
var heads := Buffer.new(GRID_SIZE, GRID_SIZE, Image.FORMAT_RGBA8, 4)
var pool := Buffer.new(POOL_WIDTH, POOL_WIDTH, Image.FORMAT_RGBA8, 4)

var sourceObjects: Array = []
var freeSourceIds: Array[int] = []
var nextEntry: int = 1
var freeEntries: Array[int] = []


static func isInBounds(pos: Vector2i) -> bool:
	return pos.x >= -GRID_HALF and pos.x < GRID_HALF and pos.y >= -GRID_HALF and pos.y < GRID_HALF


static func cellIndex(pos: Vector2i) -> int:
	return (pos.y + GRID_HALF) * GRID_SIZE + pos.x + GRID_HALF


func bindCellTexture(material: ShaderMaterial) -> void:
	material.set_shader_parameter("powerTex", cells.texture)


func bindWireTextures(material: ShaderMaterial) -> void:
	material.set_shader_parameter("wireHead", heads.texture)
	material.set_shader_parameter("wirePool", pool.texture)
	material.set_shader_parameter("sourceTex", sources.texture)


func reset() -> void:
	for buffer in [cells, sources, heads, pool]:
		buffer.clear()
	sourceObjects.clear()
	freeSourceIds.clear()
	nextEntry = 1
	freeEntries.clear()


func flush() -> void:
	cells.flush()
	sources.flush()
	heads.flush()
	pool.flush()


# --- CELLS ---


func setCellPower(channel: int, pos: Vector2i, power: int) -> void:
	if not isInBounds(pos): return
	var idx := cellIndex(pos) * 4 + channel
	var value := power * 17
	if cells.data[idx] == value: return
	cells.data[idx] = value
	cells.dirty = true


# --- SOURCES ---


func allocSource(source: Generator) -> int:
	var id: int
	if not freeSourceIds.is_empty():
		id = freeSourceIds.pop_back()
		sourceObjects[id] = source
	elif sourceObjects.size() < MAX_SOURCES:
		id = sourceObjects.size()
		sourceObjects.append(source)
	else:
		push_warning("Too many sources, wires will not show the power of this one")
		return -1
	return id


func freeSource(id: int) -> void:
	sourceObjects[id] = null
	setSourcePower(id, 0)
	freeSourceIds.append(id)


func setSourcePower(id: int, power: int) -> void:
	var value := power * 17
	if sources.data[id] == value: return
	sources.data[id] = value
	sources.dirty = true


# --- WIRE LISTS ---


func getHead(cell: int) -> int:
	var idx := cell * 4
	return heads.data[idx] | (heads.data[idx + 1] << 8) | (heads.data[idx + 2] << 16)


func setHead(cell: int, entry: int) -> void:
	var idx := cell * 4
	heads.data[idx] = entry & 255
	heads.data[idx + 1] = (entry >> 8) & 255
	heads.data[idx + 2] = entry >> 16
	heads.dirty = true


func getEntryId(entry: int) -> int:
	var idx := entry * 8
	return pool.data[idx] | (pool.data[idx + 1] << 8)


func getEntryNext(entry: int) -> int:
	var idx := entry * 8
	return pool.data[idx + 3] | (pool.data[idx + 4] << 8) | (pool.data[idx + 5] << 16)


func setEntryNext(entry: int, next: int) -> void:
	var idx := entry * 8
	pool.data[idx + 3] = next & 255
	pool.data[idx + 4] = (next >> 8) & 255
	pool.data[idx + 5] = next >> 16
	pool.dirty = true


func allocEntry(id: int, dist: int, next: int) -> int:
	var entry: int
	if not freeEntries.is_empty():
		entry = freeEntries.pop_back()
	elif nextEntry < POOL_ENTRIES:
		entry = nextEntry
		nextEntry += 1
	else:
		push_warning("Wire entry pool is full, some wires will not show their power")
		return 0
	var idx := entry * 8
	pool.data[idx] = id & 255
	pool.data[idx + 1] = id >> 8
	pool.data[idx + 2] = dist
	setEntryNext(entry, next)
	return entry


func addWireSource(pos: Vector2i, id: int, dist: int) -> bool:
	var cell := cellIndex(pos)
	var head := getHead(cell)
	var entry := head
	while entry != 0:
		if getEntryId(entry) == id: return false
		entry = getEntryNext(entry)
	var added := allocEntry(id, dist, head)
	if added == 0: return false
	setHead(cell, added)
	return true


func removeWireSource(cell: int, id: int) -> void:
	var prev := 0
	var entry := getHead(cell)
	while entry != 0:
		var next := getEntryNext(entry)
		if getEntryId(entry) == id:
			if prev == 0: setHead(cell, next)
			else: setEntryNext(prev, next)
			freeEntries.append(entry)
			return
		prev = entry
		entry = next


func clearWireCell(pos: Vector2i) -> void:
	var cell := cellIndex(pos)
	var entry := getHead(cell)
	while entry != 0:
		freeEntries.append(entry)
		entry = getEntryNext(entry)
	setHead(cell, 0)


func getWireSourceIds(pos: Vector2i) -> Array[int]:
	var ids: Array[int] = []
	var entry := getHead(cellIndex(pos))
	while entry != 0:
		ids.append(getEntryId(entry))
		entry = getEntryNext(entry)
	return ids
