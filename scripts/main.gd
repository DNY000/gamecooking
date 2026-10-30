extends Node2D
## Phở Phố Cổ — bản chơi thử (Godot 4, GDScript).
##
## Màn hình chia hai phần:
##  - Quán (phía trên): thế giới cuộn được, kéo để xem, chụm hai ngón / lăn chuột để phóng to.
##    Khách đi theo lối đi, ngồi xuống bàn, ăn, đứng dậy rồi ra về.
##  - Bếp (phía dưới, cố định): nấu phở bò bằng thao tác kéo thả.
## Lần đầu chơi có hướng dẫn từng bước. Quán chỉ đón khách sau khi người chơi mở cửa.

# ================================================================ cấu hình
const SCREEN := Vector2(1920, 1080)
const KITCHEN_Y := 720.0
const WORLD := Vector2(2400, 1180)
const ZOOM_MIN := 0.78
const ZOOM_MAX := 1.8
const SAVE_PATH := "user://save.cfg"

const DAY_SECONDS := 300.0
const OPEN_HOUR := 5.0
const CLOSE_HOUR := 24.0
const PRICE := 30000
const MAX_TIP := 15000
const STAR_GOALS := [250000, 450000, 650000, 850000, 1050000]

const CUSTOMER_H := 300.0
const SIT_CROP := 0.62
const WALK_SPEED := 230.0
const AISLE_Y := 1110.0
const DOOR := Vector2(-150, 1110)
const QUEUE_PTS := [Vector2(260, 1110), Vector2(180, 1110), Vector2(100, 1110)]
const TABLES := [
	Vector2(780, 760), Vector2(1330, 760), Vector2(1880, 760),
	Vector2(780, 1040), Vector2(1330, 1040), Vector2(1880, 1040),
]

const COOK_TIME := 3.0
const POUR_SPEED := 0.42
const BROTH_LOW := 0.72
const BROTH_HIGH := 0.92

const C_INK := Color("4a2e1c")
const C_CREAM := Color("f6ebd3")
const C_GREEN := Color("5e9e45")
const C_YELLOW := Color("e3b23c")
const C_RED := Color("d64b3c")
const C_GOLD := Color("d9a520")
const C_BROTH := Color("c98b4a")

# vùng chạm trong bếp (toạ độ màn hình)
const R_BOWLS := Rect2(30, 790, 170, 230)
const R_NOODLES := Rect2(210, 800, 180, 220)
const R_BLANCH := Rect2(400, 760, 200, 270)
const R_SLOTS := [Rect2(615, 800, 175, 210), Rect2(795, 800, 175, 210), Rect2(975, 800, 175, 210)]
const R_TAI := Rect2(1165, 785, 150, 115)
const R_CHIN := Rect2(1165, 910, 150, 115)
const R_ONION := Rect2(1325, 785, 140, 115)
const R_PEPPER := Rect2(1325, 910, 140, 115)
const R_BROTH := Rect2(1480, 760, 230, 270)
const R_TRASH := Rect2(1730, 870, 160, 150)

const CUSTOMER_TYPES := [
	{"id": "office_worker", "name": "Công nhân viên", "patience": 26.0, "tip": 0.8, "strict": false, "no_onion": 0.2, "weight": 3.0},
	{"id": "cyclo_driver", "name": "Bác xích lô", "patience": 44.0, "tip": 1.0, "strict": false, "no_onion": 0.1, "weight": 2.0},
	{"id": "schoolboy", "name": "Học sinh", "patience": 32.0, "tip": 0.4, "strict": false, "no_onion": 0.5, "weight": 1.5},
	{"id": "schoolgirl", "name": "Học sinh", "patience": 32.0, "tip": 0.4, "strict": false, "no_onion": 0.6, "weight": 1.5},
	{"id": "old_man", "name": "Cụ ông", "patience": 58.0, "tip": 1.2, "strict": false, "no_onion": 0.2, "weight": 1.2, "broth_lover": true},
	{"id": "market_woman", "name": "Bà đi chợ", "patience": 38.0, "tip": 0.9, "strict": false, "no_onion": 0.2, "weight": 1.5},
	{"id": "soldier", "name": "Anh bộ đội", "patience": 46.0, "tip": 1.0, "strict": false, "no_onion": 0.1, "weight": 1.0},
	{"id": "backpacker", "name": "Khách Tây", "patience": 38.0, "tip": 1.8, "strict": false, "no_onion": 0.6, "weight": 0.8},
	{"id": "food_critic", "name": "Nhà phê bình", "patience": 30.0, "tip": 3.0, "strict": true, "no_onion": 0.3, "weight": 0.35},
]

# Hướng dẫn lần đầu. "wait": điều kiện để sang bước sau, "target": chỗ cần chỉ vào.
const TUTORIAL := [
	{"text": "Na ơi, bà ốm mất rồi. Hôm nay cháu trông quán phở thay bà nhé. Bà sẽ chỉ cháu từng bước.", "button": "Vâng ạ", "wait": "", "target": ""},
	{"text": "Đây là quán của nhà mình. Kéo màn hình để xem quanh quán. Chụm hai ngón (hoặc lăn chuột) để phóng to, thu nhỏ.", "button": "Cháu xem rồi", "wait": "camera", "target": ""},
	{"text": "Bác Ba xích lô, khách quen của bà, tới rồi kìa. Chờ bác vào bàn ngồi nhé.", "button": "", "wait": "seated", "target": "customer", "enter": "spawn"},
	{"text": "Bác gọi \"phở tái, có hành\". Trước tiên chạm vào chồng bát để lấy một bát ra thớt.", "button": "", "wait": "bowl", "target": "bowls"},
	{"text": "Kéo một nắm bánh phở thả vào rổ chần trong nồi nước sôi (chạm vào rổ bánh cũng được).", "button": "", "wait": "noodles_in", "target": "noodles"},
	{"text": "Bánh đang chần. Khi vạch trên nồi chạy vào vùng xanh thì kéo rổ chần đổ bánh vào bát.", "button": "", "wait": "noodles_bowl", "target": "strainer"},
	{"text": "Kéo thịt tái xếp lên mặt bánh. Thịt tái để sống, chan nước dùng nóng vào sẽ chín tới.", "button": "", "wait": "meat", "target": "tai"},
	{"text": "Kéo môi từ nồi nước dùng sang bát rồi giữ tay để chan. Thả tay khi nước tới vạch xanh cạnh bát.", "button": "", "wait": "broth", "target": "broth"},
	{"text": "Rắc hành lá lên trên. Khách dặn \"không hành\" thì bỏ qua. Khách gọi \"thêm tiêu\" thì rắc tiêu.", "button": "", "wait": "onion", "target": "onion"},
	{"text": "Bát phở xong rồi! Kéo bát thả vào bác Ba (hoặc chạm bát rồi chạm vào bác).", "button": "", "wait": "served", "target": "customer"},
	{"text": "Bác đang ăn. Ăn xong khách trả tiền và tip. Nấu khéo, phục vụ nhanh thì được tip nhiều.", "button": "", "wait": "paid", "target": ""},
	{"text": "Bác để lại bát bẩn. Chạm vào bàn để dọn thì khách sau mới ngồi được.", "button": "", "wait": "cleaned", "target": "table"},
	{"text": "Giỏi lắm! Quán mở từ 5 giờ sáng tới 12 giờ đêm. Sáng sớm và buổi tối khách đông. Ai chờ lâu sẽ bỏ về, nhà phê bình khó tính mà sai món là không ăn đâu.", "button": "Mở cửa đón khách", "wait": "", "target": "", "finish": true},
]

# ================================================================ dữ liệu
class Bowl:
	var has_noodle := false
	var noodle_q := 0.0
	var mushy := false
	var tai := false
	var tai_cook := 0.0
	var chin := false
	var onion := false
	var pepper := false
	var broth := 0.0
	var spilled := false

class Customer:
	var type: Dictionary
	var sprite: Sprite2D
	var tex_w := 1.0
	var tex_h := 1.0
	var scale_k := 1.0
	var pos := Vector2.ZERO
	var path: Array = []
	var speed := 0.0
	var state := "walk"          # walk, queue, sit, waiting, eating, stand
	var next_state := ""         # trạng thái khi đi hết đường: sit, queue, gone
	var seat := -1
	var crop := 1.0
	var anim := 0.0
	var patience_max := 30.0
	var patience := 30.0
	var wait := 20.0
	var want_tai := false
	var want_chin := false
	var want_onion := true
	var want_pepper := false
	var eat_timer := 0.0
	var walk_phase := 0.0
	var mood := ""
	var mood_color := Color.WHITE
	var happy := false
	var upset := false
	var pay := 0
	var tip := 0
	var tutorial := false

var tex := {}
var font: Font
var font_bold: Font
var bubble_box := StyleBoxFlat.new()
var tile_box := StyleBoxFlat.new()

var state := "start"           # start, tutorial, playing, summary
var day := 0
var elapsed := 0.0
var hour := OPEN_HOUR
var door_open := false
var day_over := false
var spawn_timer := 2.0
var money := 0
var tips_total := 0
var served := 0
var angry := 0

var customers: Array = []
var queue: Array = []
var seats: Array = []
var slots: Array = [null, null, null]
var selected := -1
var strainer_loaded := false
var strainer_time := 0.0
var pour_target := -1
var floats_world: Array = []
var floats_screen: Array = []
var t_anim := 0.0

# hướng dẫn
var tut_step := -1
var tut_customer: Customer = null
var tut_paid := false
var cam_moved := false
var tutorial_done := false

# con trỏ / cảm ứng
var touches := {}
var pinching := false
var pinch_dist := 0.0
var ptr_down := false
var ptr_start := Vector2.ZERO
var ptr_pos := Vector2.ZERO
var ptr_moved := false
var drag_kind := ""
var drag_slot := -1

# mèo
var cat_pos := Vector2(2150, 1000)
var cat_target := Vector2(2150, 1000)
var cat_rest := 3.0
var cat_phase := 0.0

# node
var cam: Camera2D
var world_bg: Node2D
var actors: Node2D
var world_fx: Node2D
var counter_node: Node2D
var night: CanvasModulate
var na_sprite: Sprite2D
var cat_sprite: Sprite2D
var kui: Control
var overlay: Control
var lbl_clock: Label
var lbl_money: Label
var lbl_hint: Label
var pill_clock: PanelContainer
var pill_money: PanelContainer
var btn_help: Button
var btn_door: Button
var btn_end: Button
var dlg: PanelContainer
var dlg_label: Label
var dlg_button: Button
var start_panel: PanelContainer
var start_label: Label
var summary_panel: PanelContainer
var summary_label: Label


# ================================================================ khởi tạo
func _ready() -> void:
	randomize()
	_load_resources()
	_load_save()
	_build_world()
	_build_kitchen()
	_build_hud()
	cam.position = Vector2(1200, 955)
	cam.zoom = Vector2(0.8, 0.8)
	_clamp_camera()
	reset_day(not tutorial_done)


func _load_resources() -> void:
	var paths := {
		"na": "res://assets/characters/main/na_front.png",
		"ba_tu": "res://assets/characters/main/ba_tu_front.png",
		"cat": "res://assets/characters/customers/cat.png",
		"table": "res://assets/items/decor/bamboo_table.png",
		"stool": "res://assets/items/decor/bamboo_stool.png",
		"lantern": "res://assets/items/decor/red_lantern.png",
		"lamp": "res://assets/items/decor/rattan_lamp.png",
		"painting": "res://assets/items/decor/dong_ho_rooster_painting.png",
		"plant": "res://assets/items/decor/potted_plant.png",
		"cage": "res://assets/items/decor/bird_cage.png",
		"noodles": "res://assets/items/ingredients/rice_noodles.png",
		"beef": "res://assets/items/ingredients/raw_beef.png",
		"onion": "res://assets/items/ingredients/scallions.png",
		"blanch_pot": "res://assets/items/upgrades/pot_lv1.png",
		"broth_pot": "res://assets/items/upgrades/pot_lv2.png",
		"big_pot": "res://assets/items/upgrades/pot_lv3.png",
		"stove": "res://assets/items/upgrades/stove_lv1.png",
		"strainer": "res://assets/props/strainer_basket.png",
		"pho": "res://assets/items/food/pho_bo.png",
	}
	for t in CUSTOMER_TYPES:
		paths[t["id"]] = "res://assets/characters/customers/%s.png" % t["id"]
	for key in paths:
		tex[key] = load(paths[key])

	font = load("res://assets/fonts/BeVietnamPro-SemiBold.ttf")
	font_bold = load("res://assets/fonts/BeVietnamPro-Bold.ttf")
	if font == null:
		font = ThemeDB.fallback_font
	if font_bold == null:
		font_bold = font

	bubble_box.bg_color = Color(1, 1, 1, 0.96)
	bubble_box.border_color = C_INK
	bubble_box.set_border_width_all(3)
	bubble_box.set_corner_radius_all(16)
	tile_box.bg_color = Color(0.3, 0.18, 0.08, 0.14)
	tile_box.set_corner_radius_all(18)


func _load_save() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) == OK:
		tutorial_done = bool(cfg.get_value("progress", "tutorial_done", false))


func _save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("progress", "tutorial_done", tutorial_done)
	cfg.save(SAVE_PATH)


func _world_sprite(key: String, pos: Vector2, height: float, parent: Node, feet := true) -> Sprite2D:
	var s := Sprite2D.new()
	var t: Texture2D = tex[key]
	s.texture = t
	var k := height / float(t.get_height())
	s.scale = Vector2(k, k)
	s.position = pos
	if feet:
		s.offset = Vector2(0, -t.get_height() / 2.0)
	parent.add_child(s)
	return s


func _build_world() -> void:
	world_bg = Node2D.new()
	world_bg.z_index = -20
	add_child(world_bg)
	world_bg.draw.connect(_draw_world_bg)

	var deco := Node2D.new()
	deco.z_index = -10
	add_child(deco)
	_world_sprite("lantern", Vector2(470, 200), 140, deco, false)
	_world_sprite("lantern", Vector2(1500, 200), 140, deco, false)
	_world_sprite("lantern", Vector2(2250, 200), 140, deco, false)
	_world_sprite("lamp", Vector2(1080, 150), 110, deco, false)
	_world_sprite("lamp", Vector2(1930, 150), 110, deco, false)
	_world_sprite("painting", Vector2(770, 280), 150, deco, false)
	_world_sprite("cage", Vector2(2080, 270), 150, deco, false)

	actors = Node2D.new()
	actors.y_sort_enabled = true
	add_child(actors)

	for i in TABLES.size():
		var tp: Vector2 = TABLES[i]
		_world_sprite("stool", tp + Vector2(-150, 8), 80, actors)
		_world_sprite("stool", tp + Vector2(150, 8), 80, actors)
		_world_sprite("table", tp, 170, actors)
	_world_sprite("plant", Vector2(2320, 560), 230, actors)
	_world_sprite("plant", Vector2(560, 560), 190, actors)

	na_sprite = _world_sprite("na", Vector2(250, 650), 300, actors)
	counter_node = Node2D.new()
	counter_node.position = Vector2(250, 720)
	actors.add_child(counter_node)
	counter_node.draw.connect(_draw_counter)

	cat_sprite = _world_sprite("cat", cat_pos, 105, actors)

	world_fx = Node2D.new()
	world_fx.z_index = 50
	add_child(world_fx)
	world_fx.draw.connect(_draw_world_fx)

	night = CanvasModulate.new()
	add_child(night)

	cam = Camera2D.new()
	add_child(cam)
	cam.make_current()


func _build_kitchen() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 5
	add_child(layer)
	kui = Control.new()
	kui.set_anchors_preset(Control.PRESET_FULL_RECT)
	kui.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(kui)
	kui.draw.connect(_draw_kitchen)


func _label(size: int, color: Color, bold := true) -> Label:
	var l := Label.new()
	l.add_theme_font_override("font", font_bold if bold else font)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	return l


func _button(text: String, size := 30) -> Button:
	var b := Button.new()
	b.text = text
	b.add_theme_font_override("font", font_bold)
	b.add_theme_font_size_override("font_size", size)
	b.add_theme_color_override("font_color", C_CREAM)
	b.add_theme_color_override("font_hover_color", Color.WHITE)
	b.add_theme_color_override("font_pressed_color", Color.WHITE)
	b.add_theme_color_override("font_focus_color", C_CREAM)
	var sb := StyleBoxFlat.new()
	sb.bg_color = Color("c8312b")
	sb.border_color = C_INK
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(14)
	sb.content_margin_left = 22
	sb.content_margin_right = 22
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	b.add_theme_stylebox_override("normal", sb)
	var sb_h := sb.duplicate() as StyleBoxFlat
	sb_h.bg_color = Color("a92823")
	b.add_theme_stylebox_override("hover", sb_h)
	b.add_theme_stylebox_override("pressed", sb_h)
	b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	return b


func _pill(radius := 26) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = C_CREAM
	sb.border_color = C_INK
	sb.set_border_width_all(3)
	sb.set_corner_radius_all(radius)
	sb.content_margin_left = 20
	sb.content_margin_right = 20
	sb.content_margin_top = 6
	sb.content_margin_bottom = 6
	return sb


func _build_hud() -> void:
	var hud := CanvasLayer.new()
	hud.layer = 10
	add_child(hud)

	overlay = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(overlay)
	overlay.draw.connect(_draw_overlay)

	pill_clock = PanelContainer.new()
	pill_clock.add_theme_stylebox_override("panel", _pill())
	pill_clock.position = Vector2(24, 18)
	lbl_clock = _label(30, C_INK)
	pill_clock.add_child(lbl_clock)
	hud.add_child(pill_clock)

	pill_money = PanelContainer.new()
	pill_money.add_theme_stylebox_override("panel", _pill())
	pill_money.position = Vector2(350, 18)
	lbl_money = _label(30, C_INK)
	pill_money.add_child(lbl_money)
	hud.add_child(pill_money)

	var right := HBoxContainer.new()
	right.add_theme_constant_override("separation", 12)
	right.alignment = BoxContainer.ALIGNMENT_END
	right.position = Vector2(1180, 16)
	right.size = Vector2(716, 64)
	right.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(right)
	btn_end = _button("Kết thúc ngày")
	btn_end.pressed.connect(_on_end_day)
	right.add_child(btn_end)
	btn_door = _button("Đóng cửa")
	btn_door.pressed.connect(_on_door)
	right.add_child(btn_door)
	btn_help = _button("?")
	btn_help.pressed.connect(_on_help)
	right.add_child(btn_help)

	lbl_hint = _label(26, Color.WHITE)
	lbl_hint.add_theme_color_override("font_outline_color", C_INK)
	lbl_hint.add_theme_constant_override("outline_size", 10)
	lbl_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_hint.position = Vector2(260, 668)
	lbl_hint.size = Vector2(1400, 40)
	lbl_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.add_child(lbl_hint)

	# hộp thoại hướng dẫn
	dlg = PanelContainer.new()
	var dsb := _pill(22)
	dsb.content_margin_left = 18
	dsb.content_margin_right = 26
	dsb.content_margin_top = 14
	dsb.content_margin_bottom = 14
	dlg.add_theme_stylebox_override("panel", dsb)
	dlg.position = Vector2(990, 100)
	dlg.custom_minimum_size = Vector2(910, 0)
	hud.add_child(dlg)
	var dh := HBoxContainer.new()
	dh.add_theme_constant_override("separation", 18)
	dlg.add_child(dh)
	var portrait := TextureRect.new()
	portrait.texture = tex["ba_tu"]
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.custom_minimum_size = Vector2(110, 170)
	dh.add_child(portrait)
	var dv := VBoxContainer.new()
	dv.add_theme_constant_override("separation", 10)
	dv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	dh.add_child(dv)
	var dname := _label(24, Color("8c4222"))
	dname.text = "Bà Tư"
	dv.add_child(dname)
	dlg_label = _label(28, C_INK, false)
	dlg_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dlg_label.custom_minimum_size = Vector2(700, 0)
	dv.add_child(dlg_label)
	dlg_button = _button("Tiếp", 26)
	dlg_button.size_flags_horizontal = Control.SIZE_SHRINK_END
	dlg_button.pressed.connect(_on_dlg_button)
	dv.add_child(dlg_button)
	dlg.visible = false

	# bảng đầu ngày
	start_panel = PanelContainer.new()
	var ssb := _pill(24)
	ssb.content_margin_left = 48
	ssb.content_margin_right = 48
	ssb.content_margin_top = 34
	ssb.content_margin_bottom = 34
	start_panel.add_theme_stylebox_override("panel", ssb)
	start_panel.position = Vector2(560, 150)
	start_panel.custom_minimum_size = Vector2(800, 0)
	hud.add_child(start_panel)
	var sv := VBoxContainer.new()
	sv.add_theme_constant_override("separation", 22)
	start_panel.add_child(sv)
	start_label = _label(30, C_INK, false)
	start_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	start_label.custom_minimum_size = Vector2(700, 0)
	sv.add_child(start_label)
	var open_btn := _button("Mở cửa đón khách")
	open_btn.pressed.connect(_open_shop)
	sv.add_child(open_btn)
	start_panel.visible = false

	# bảng tổng kết
	summary_panel = PanelContainer.new()
	summary_panel.add_theme_stylebox_override("panel", ssb.duplicate() as StyleBoxFlat)
	summary_panel.position = Vector2(560, 120)
	summary_panel.custom_minimum_size = Vector2(800, 0)
	hud.add_child(summary_panel)
	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 20)
	summary_panel.add_child(vb)
	summary_label = _label(32, C_INK, false)
	vb.add_child(summary_label)
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 60)
	vb.add_child(spacer)
	var again := _button("Sang ngày mới")
	again.pressed.connect(func() -> void: reset_day(false))
	vb.add_child(again)
	summary_panel.visible = false


# ================================================================ vòng đời một ngày
func reset_day(tutorial: bool) -> void:
	for item in customers:
		var c: Customer = item
		c.sprite.queue_free()
	customers.clear()
	queue.clear()
	seats.clear()
	for i in TABLES.size():
		seats.append({"customer": null, "dirty": false})
	slots = [null, null, null]
	selected = -1
	strainer_loaded = false
	pour_target = -1
	floats_world.clear()
	floats_screen.clear()
	money = 0
	tips_total = 0
	served = 0
	angry = 0
	elapsed = 0.0
	hour = OPEN_HOUR
	door_open = false
	day_over = false
	spawn_timer = 1.0
	tut_customer = null
	tut_paid = false
	_cancel_pointer()
	summary_panel.visible = false
	if tutorial:
		state = "tutorial"
		hour = 7.0
		start_panel.visible = false
		_tut_goto(0)
	else:
		day += 1
		state = "start"
		dlg.visible = false
		start_label.text = "Ngày %d\n\nQuán đang đóng cửa. Chuẩn bị xong thì mở cửa đón khách.\nKhách đông lúc 6–9 giờ sáng và 17–21 giờ tối." % day
		start_panel.visible = true


func _open_shop() -> void:
	start_panel.visible = false
	state = "playing"
	door_open = true
	btn_door.text = "Đóng cửa"
	spawn_timer = 1.0
	_add_float_screen("Mở cửa! Ngày %d" % day, Vector2(960, 420), C_GOLD, 2.0)


func _on_door() -> void:
	if state != "playing" or day_over:
		return
	door_open = not door_open
	btn_door.text = "Đóng cửa" if door_open else "Mở cửa"
	_add_float_screen("Quán mở cửa" if door_open else "Tạm đóng cửa, không đón thêm khách", Vector2(960, 420), C_GOLD)


func _on_end_day() -> void:
	day_over = true
	door_open = false


func _on_help() -> void:
	if state == "tutorial":
		return
	day = maxi(day - 1, 0)
	reset_day(true)


func _show_summary() -> void:
	state = "summary"
	_cancel_pointer()
	var lines := "Tổng kết ngày %d\n\n" % day
	lines += "Khách đã phục vụ: %d\n" % served
	lines += "Khách bỏ về: %d\n" % angry
	lines += "Tiền bán phở: %s\n" % _fmt(money - tips_total)
	lines += "Tiền tip: %s\n" % _fmt(tips_total)
	lines += "Tổng cộng: %s" % _fmt(money)
	summary_label.text = lines
	summary_panel.visible = true


func _process(delta: float) -> void:
	t_anim += delta
	if state == "playing":
		elapsed += delta
		hour = OPEN_HOUR + (CLOSE_HOUR - OPEN_HOUR) * elapsed / DAY_SECONDS
		if hour >= CLOSE_HOUR:
			hour = CLOSE_HOUR
			if not day_over:
				day_over = true
				door_open = false
				_add_float_screen("12 giờ đêm, quán đóng cửa", Vector2(960, 420), C_GOLD, 2.5)
		if door_open:
			spawn_timer -= delta
			if spawn_timer <= 0.0:
				_spawn_customer()
				spawn_timer = _spawn_interval(hour) * randf_range(0.7, 1.3)
	if state == "playing" or state == "tutorial":
		_update_kitchen(delta)
		_update_customers(delta)
	if state == "tutorial":
		_tut_check()
	if state == "playing" and day_over and customers.is_empty():
		_show_summary()

	_update_cat(delta)
	_update_floats(delta)
	na_sprite.position.y = 650.0 + sin(t_anim * (5.0 if _cooking_busy() else 2.0)) * 3.0
	night.color = _sky_tint(hour)
	_update_hud()
	world_bg.queue_redraw()
	counter_node.queue_redraw()
	world_fx.queue_redraw()
	kui.queue_redraw()
	overlay.queue_redraw()


func _spawn_interval(h: float) -> float:
	if h >= 6.0 and h < 9.0:
		return 3.8
	if h >= 11.0 and h < 13.0:
		return 5.5
	if h >= 17.0 and h < 21.0:
		return 4.5
	if h >= 13.0 and h < 17.0:
		return 11.0
	if h >= 22.0:
		return 12.0
	return 7.5


func _sky_tint(h: float) -> Color:
	var dawn := Color(0.82, 0.8, 0.95)
	var sunset := Color(1.0, 0.86, 0.72)
	var dark := Color(0.62, 0.58, 0.78)
	if h < 6.5:
		return dawn.lerp(Color.WHITE, clampf((h - OPEN_HOUR) / 1.5, 0.0, 1.0))
	if h < 17.0:
		return Color.WHITE
	if h < 19.0:
		return Color.WHITE.lerp(sunset, (h - 17.0) / 2.0)
	return sunset.lerp(dark, clampf((h - 19.0) / 2.0, 0.0, 1.0))


# ================================================================ camera
func _screen_to_world(p: Vector2) -> Vector2:
	return cam.position + (p - SCREEN / 2.0) / cam.zoom.x


func _world_to_screen(p: Vector2) -> Vector2:
	return (p - cam.position) * cam.zoom.x + SCREEN / 2.0


func _clamp_camera() -> void:
	var z := cam.zoom.x
	var min_x := -40.0 + 960.0 / z
	var max_x := WORLD.x + 40.0 - 960.0 / z
	var min_y := -60.0 + 540.0 / z
	var max_y := WORLD.y + 20.0 - (KITCHEN_Y - 540.0) / z
	var p := cam.position
	p.x = WORLD.x / 2.0 if min_x > max_x else clampf(p.x, min_x, max_x)
	p.y = (min_y + max_y) / 2.0 if min_y > max_y else clampf(p.y, min_y, max_y)
	cam.position = p


func _zoom_at(screen_pt: Vector2, factor: float) -> void:
	var old_z := cam.zoom.x
	var nz := clampf(old_z * factor, ZOOM_MIN, ZOOM_MAX)
	if is_equal_approx(nz, old_z):
		return
	var before := _screen_to_world(screen_pt)
	cam.zoom = Vector2(nz, nz)
	cam.position = before - (screen_pt - SCREEN / 2.0) / nz
	_clamp_camera()
	cam_moved = true


# ================================================================ khách hàng
func _pick_type() -> Dictionary:
	var total := 0.0
	var weights: Array = []
	for t in CUSTOMER_TYPES:
		var w: float = t["weight"]
		var id: String = t["id"]
		if hour < 9.0 and (id == "office_worker" or id.begins_with("school")):
			w *= 2.0
		if hour >= 19.0 and id.begins_with("school"):
			w *= 0.2
		if id == "food_critic" and hour < 10.0:
			w = 0.0
		weights.append(w)
		total += w
	var r := randf() * total
	for i in CUSTOMER_TYPES.size():
		var w: float = weights[i]
		r -= w
		if r <= 0.0:
			return CUSTOMER_TYPES[i]
	return CUSTOMER_TYPES[0]


func _type_by_id(id: String) -> Dictionary:
	for t in CUSTOMER_TYPES:
		if t["id"] == id:
			return t
	return CUSTOMER_TYPES[0]


func _free_seat() -> int:
	var order := range(seats.size())
	order.shuffle()
	for i in order:
		if seats[i]["customer"] == null and not seats[i]["dirty"]:
			return i
	return -1


func _seat_point(i: int) -> Vector2:
	var t: Vector2 = TABLES[i]
	return t + Vector2(0, -46)


func _aisle_x(i: int) -> float:
	var t: Vector2 = TABLES[i]
	return t.x - 190.0


func _new_customer(type: Dictionary) -> Customer:
	var c := Customer.new()
	c.type = type
	var t: Texture2D = tex[type["id"]]
	c.sprite = Sprite2D.new()
	c.sprite.texture = t
	c.sprite.region_enabled = true
	c.tex_w = t.get_width()
	c.tex_h = t.get_height()
	c.scale_k = CUSTOMER_H / c.tex_h
	c.pos = DOOR
	actors.add_child(c.sprite)
	c.patience_max = type["patience"]
	c.patience = c.patience_max
	c.wait = c.patience_max * 0.8
	_apply_sprite(c)
	customers.append(c)
	return c


func _spawn_customer() -> void:
	var seat := _free_seat()
	if seat == -1 and queue.size() >= QUEUE_PTS.size():
		return
	var c := _new_customer(_pick_type())
	var meat := randi() % 3
	c.want_tai = meat != 1
	c.want_chin = meat != 0
	var no_onion: float = c.type["no_onion"]
	c.want_onion = randf() >= no_onion
	c.want_pepper = randf() < 0.35
	if seat != -1:
		_send_to_seat(c, seat)
	else:
		queue.append(c)
		_send_to_queue(c, queue.size() - 1)


func _spawn_tutorial_customer() -> void:
	var c := _new_customer(_type_by_id("cyclo_driver"))
	c.tutorial = true
	c.want_tai = true
	c.want_chin = false
	c.want_onion = true
	c.want_pepper = false
	tut_customer = c
	_send_to_seat(c, 0)


func _send_to_seat(c: Customer, seat: int) -> void:
	seats[seat]["customer"] = c
	c.seat = seat
	var ax := _aisle_x(seat)
	var sp := _seat_point(seat)
	c.path = [Vector2(ax, AISLE_Y), Vector2(ax, sp.y), sp]
	c.state = "walk"
	c.next_state = "sit"


func _send_to_queue(c: Customer, idx: int) -> void:
	c.path = [QUEUE_PTS[idx]]
	c.state = "walk"
	c.next_state = "queue"


func _seat_from_queue() -> void:
	while not queue.is_empty():
		var seat := _free_seat()
		if seat == -1:
			break
		var c: Customer = queue.pop_front()
		_send_to_seat(c, seat)
	for i in queue.size():
		var q: Customer = queue[i]
		if q.state == "queue" or q.next_state == "queue":
			_send_to_queue(q, i)


func _leave_from_queue(c: Customer) -> void:
	queue.erase(c)
	c.upset = true
	c.path = [DOOR]
	c.state = "walk"
	c.next_state = "gone"
	_seat_from_queue()


func _start_standing(c: Customer) -> void:
	c.state = "stand"
	c.anim = 1.0


func _move_along(c: Customer, delta: float) -> bool:
	if c.path.is_empty():
		return true
	var target: Vector2 = c.path[0]
	var to := target - c.pos
	var dist := to.length()
	var desired := WALK_SPEED
	if c.path.size() == 1:
		desired = minf(WALK_SPEED, maxf(70.0, dist * 3.0))
	c.speed = move_toward(c.speed, desired, 520.0 * delta)
	var step := c.speed * delta
	if absf(to.x) > 2.0:
		c.sprite.flip_h = to.x < 0.0
	c.walk_phase += delta * 10.0 * clampf(c.speed / WALK_SPEED, 0.3, 1.0)
	if step >= dist:
		c.pos = target
		c.path.pop_front()
		return c.path.is_empty()
	c.pos += to / dist * step
	return false


func _apply_sprite(c: Customer) -> void:
	var s := c.sprite
	var h := c.tex_h * c.crop
	s.region_rect = Rect2(0, 0, c.tex_w, h)
	s.offset = Vector2(0, -h / 2.0)
	var bob := 0.0
	var rot := 0.0
	var sq := 1.0
	match c.state:
		"walk":
			var amt := clampf(c.speed / WALK_SPEED, 0.0, 1.0)
			bob = -absf(sin(c.walk_phase)) * 9.0 * amt
			rot = sin(c.walk_phase) * 0.04 * amt
			sq = 1.0 + sin(c.walk_phase * 2.0) * 0.025 * amt
		"sit", "stand":
			sq = 1.0 - 0.06 * sin(clampf(c.anim, 0.0, 1.0) * PI)
		"eating":
			bob = sin(t_anim * 7.0) * 2.0
			sq = 1.0 + sin(t_anim * 7.0) * 0.012
		"waiting":
			var ratio := c.patience / c.patience_max
			if ratio < 0.25 and not c.tutorial:
				rot = sin(t_anim * 30.0) * 0.03
			else:
				sq = 1.0 + sin(t_anim * 2.0 + c.pos.x) * 0.008
		"queue":
			sq = 1.0 + sin(t_anim * 2.0 + c.pos.x) * 0.01
	s.position = c.pos + Vector2(0, bob)
	s.rotation = rot
	s.scale = Vector2(c.scale_k / sq, c.scale_k * sq)
	var tint := Color.WHITE
	if c.state == "waiting" and not c.tutorial:
		var ratio := c.patience / c.patience_max
		tint = Color.WHITE.lerp(Color(1.0, 0.72, 0.66), clampf(1.0 - ratio * 2.5, 0.0, 1.0))
	s.modulate = tint


func _update_customers(delta: float) -> void:
	for item in customers.duplicate():
		var c: Customer = item
		match c.state:
			"walk":
				if _move_along(c, delta):
					c.speed = 0.0
					c.sprite.flip_h = false
					match c.next_state:
						"sit":
							c.state = "sit"
							c.anim = 0.0
						"queue":
							c.state = "queue"
						_:
							c.sprite.queue_free()
							customers.erase(c)
							continue
			"queue":
				if state == "playing":
					c.wait -= delta
					if c.wait <= 0.0:
						angry += 1
						_add_float_world("Chờ lâu quá!", c.pos + Vector2(0, -CUSTOMER_H - 20), C_RED)
						_leave_from_queue(c)
			"sit":
				c.anim += delta / 0.45
				var e := ease(clampf(c.anim, 0.0, 1.0), -2.0)
				c.crop = lerpf(1.0, SIT_CROP, e)
				if c.anim >= 1.0:
					c.crop = SIT_CROP
					c.state = "waiting"
					c.patience = c.patience_max
			"waiting":
				if state == "playing" and not c.tutorial:
					c.patience -= delta
					if c.patience <= 0.0:
						angry += 1
						c.upset = true
						_add_float_world("Bỏ về!", c.pos + Vector2(0, -CUSTOMER_H * c.crop - 30), C_RED)
						_start_standing(c)
			"eating":
				c.eat_timer -= delta
				if c.eat_timer <= 0.0:
					money += c.pay + c.tip
					tips_total += c.tip
					served += 1
					var txt := "+" + _fmt(c.pay)
					if c.tip > 0:
						txt += "  tip " + _fmt(c.tip)
					_add_float_world(txt, c.pos + Vector2(0, -CUSTOMER_H * c.crop - 30), C_GOLD)
					seats[c.seat]["dirty"] = true
					if c.tutorial:
						tut_paid = true
					_start_standing(c)
			"stand":
				c.anim -= delta / 0.4
				var e := ease(clampf(c.anim, 0.0, 1.0), -2.0)
				c.crop = lerpf(1.0, SIT_CROP, e)
				if c.anim <= 0.0:
					c.crop = 1.0
					var seat := c.seat
					if seat != -1 and seats[seat]["customer"] == c:
						seats[seat]["customer"] = null
					c.seat = -1
					var ax := _aisle_x(seat) if seat != -1 else c.pos.x
					c.path = [Vector2(ax, c.pos.y), Vector2(ax, AISLE_Y), DOOR]
					c.state = "walk"
					c.next_state = "gone"
					_seat_from_queue()
		_apply_sprite(c)


func _customer_at(wp: Vector2) -> Customer:
	for item in customers:
		var c: Customer = item
		if c.state != "waiting":
			continue
		var h := CUSTOMER_H * c.crop
		var r := Rect2(c.pos.x - 90.0, c.pos.y - h - 20.0, 180.0, h + 80.0)
		if r.has_point(wp):
			return c
	return null


func _table_rect(i: int) -> Rect2:
	var t: Vector2 = TABLES[i]
	return Rect2(t.x - 125.0, t.y - 180.0, 250.0, 190.0)


func _order_lines(c: Customer) -> Array:
	var meat := "tái chín"
	if c.want_tai and not c.want_chin:
		meat = "tái"
	elif c.want_chin and not c.want_tai:
		meat = "chín"
	var lines := ["Phở " + meat, "có hành" if c.want_onion else "không hành"]
	if c.want_pepper:
		lines.append("thêm tiêu")
	return lines


# ================================================================ mèo
func _update_cat(delta: float) -> void:
	var to := cat_target - cat_pos
	var bob := 0.0
	if to.length() > 4.0:
		var step := minf(95.0 * delta, to.length())
		cat_pos += to.normalized() * step
		cat_phase += delta * 12.0
		bob = -absf(sin(cat_phase)) * 7.0
		cat_sprite.flip_h = to.x < 0.0
	else:
		cat_rest -= delta
		if cat_rest <= 0.0:
			cat_target = Vector2(randf_range(560.0, 2300.0), randf_range(860.0, 1150.0))
			cat_rest = randf_range(5.0, 10.0)
	cat_sprite.position = cat_pos + Vector2(0, bob)


# ================================================================ bếp
func _cooking_busy() -> bool:
	return strainer_loaded or drag_kind != "" and drag_kind != "pan"


func _update_kitchen(delta: float) -> void:
	if strainer_loaded:
		strainer_time += delta
	pour_target = -1
	if drag_kind == "ladle" and ptr_down:
		var target := _slot_at(ptr_pos)
		if target == -1 and R_BROTH.has_point(ptr_pos):
			target = selected
		if target != -1 and slots[target] != null:
			var b: Bowl = slots[target]
			if b.has_noodle:
				pour_target = target
				b.broth = minf(b.broth + POUR_SPEED * delta, 1.15)
				if b.tai:
					b.tai_cook = minf(1.0, b.tai_cook + delta * 1.1)
				if b.broth > 1.05 and not b.spilled:
					b.spilled = true
					_add_float_screen("Tràn rồi!", _slot_rect(target).get_center() + Vector2(0, -110), C_RED)


func _selected_bowl() -> Bowl:
	if selected < 0:
		return null
	return slots[selected]


func _first_bowl() -> int:
	for i in slots.size():
		if slots[i] != null:
			return i
	return -1


func _slot_rect(i: int) -> Rect2:
	var r: Rect2 = R_SLOTS[i]
	return r


func _slot_at(p: Vector2) -> int:
	for i in R_SLOTS.size():
		var r: Rect2 = R_SLOTS[i]
		if r.has_point(p):
			return i
	return -1


func _noodle_quality(r: float) -> float:
	if r < 0.75:
		return clampf(r / 0.75, 0.0, 1.0) * 0.7
	if r <= 1.15:
		return 1.0
	return maxf(0.2, 1.0 - (r - 1.15) / 0.45 * 0.8)


func _broth_quality(v: float) -> float:
	if v >= BROTH_LOW and v <= BROTH_HIGH:
		return 1.0
	if v < BROTH_LOW:
		return clampf(v / BROTH_LOW, 0.0, 1.0) * 0.8
	return clampf(1.0 - (v - BROTH_HIGH) * 3.0, 0.1, 1.0)


func _add_bowl(slot: int) -> void:
	var target := slot
	if target == -1 or slots[target] != null:
		target = -1
		for i in slots.size():
			if slots[i] == null:
				target = i
				break
	if target == -1:
		_add_float_screen("Thớt hết chỗ đặt bát", R_BOWLS.get_center() + Vector2(0, -130), C_RED)
		return
	slots[target] = Bowl.new()
	selected = target


func _load_strainer() -> void:
	if strainer_loaded:
		_add_float_screen("Rổ chần đang có bánh", R_BLANCH.get_center() + Vector2(0, -150), C_YELLOW)
		return
	strainer_loaded = true
	strainer_time = 0.0


func _drain_to(slot: int) -> void:
	if not strainer_loaded:
		_add_float_screen("Cho bánh vào rổ chần trước", R_BLANCH.get_center() + Vector2(0, -150), C_YELLOW)
		return
	var target := -1
	if slot != -1:
		var b0: Bowl = slots[slot]
		if b0 != null and not b0.has_noodle:
			target = slot
	else:
		var sb := _selected_bowl()
		if sb != null and not sb.has_noodle:
			target = selected
		else:
			for i in slots.size():
				var b1: Bowl = slots[i]
				if b1 != null and not b1.has_noodle:
					target = i
					break
	if target == -1:
		_add_float_screen("Cần một bát trống", R_BLANCH.get_center() + Vector2(0, -150), C_RED)
		return
	var bowl: Bowl = slots[target]
	var r := strainer_time / COOK_TIME
	bowl.has_noodle = true
	bowl.noodle_q = _noodle_quality(r)
	bowl.mushy = r > 1.6
	selected = target
	strainer_loaded = false
	var at := _slot_rect(target).get_center() + Vector2(0, -110)
	if r < 0.75:
		_add_float_screen("Bánh còn sống", at, C_YELLOW)
	elif r <= 1.15:
		_add_float_screen("Vừa chín tới!", at, C_GREEN)
	else:
		_add_float_screen("Bánh bị nát", at, C_RED)


func _add_topping(kind: String, slot: int) -> void:
	var at := ptr_pos + Vector2(0, -90)
	if slot == -1 or slots[slot] == null:
		_add_float_screen("Lấy bát trước", at, C_YELLOW)
		return
	var b: Bowl = slots[slot]
	if not b.has_noodle:
		_add_float_screen("Đổ bánh vào bát trước", at, C_YELLOW)
		return
	selected = slot
	match kind:
		"tai":
			b.tai = true
		"chin":
			b.chin = true
		"onion":
			b.onion = true
		"pepper":
			b.pepper = true


func _trash(slot: int) -> void:
	if slot < 0 or slots[slot] == null:
		return
	slots[slot] = null
	if selected == slot:
		selected = _first_bowl()
	_add_float_screen("Đã bỏ bát", R_TRASH.get_center() + Vector2(0, -110), C_CREAM)


func _bowl_ready(b: Bowl) -> bool:
	return b != null and b.has_noodle and b.broth >= 0.25


func _serve(c: Customer, slot: int) -> void:
	var b: Bowl = slots[slot] if slot >= 0 else null
	var at := c.pos + Vector2(0, -CUSTOMER_H * c.crop - 30)
	if not _bowl_ready(b):
		_add_float_world("Bát phở chưa xong", at, C_YELLOW)
		return
	slots[slot] = null
	if selected == slot:
		selected = _first_bowl()

	var correct := b.tai == c.want_tai and b.chin == c.want_chin and b.onion == c.want_onion and (b.tai or b.chin)
	var q_time := clampf(c.patience / c.patience_max, 0.0, 1.0)
	var q_broth := _broth_quality(b.broth)
	var score := 0.3 * q_time + 0.25 * b.noodle_q + 0.25 * q_broth + (0.2 if correct else -0.25)
	if b.pepper != c.want_pepper:
		score -= 0.08
	if b.tai and b.tai_cook < 0.4:
		score -= 0.1
	if c.type.get("broth_lover", false):
		score = score * 0.7 + q_broth * 0.3
	var tip_mult: float = c.type["tip"]

	if c.type["strict"] and not correct:
		angry += 1
		c.upset = true
		_add_float_world("Sai món! Không ăn.", at, C_RED)
		_start_standing(c)
		return

	c.pay = PRICE
	var tip_ratio := 0.0
	c.happy = false
	if score >= 0.85:
		c.mood = "Tuyệt vời!"
		c.mood_color = C_GREEN
		c.happy = true
		tip_ratio = 1.0
	elif score >= 0.65:
		c.mood = "Ngon!"
		c.mood_color = C_GREEN
		c.happy = true
		tip_ratio = 0.5
	elif score >= 0.45:
		c.mood = "Tạm được"
		c.mood_color = C_YELLOW
		tip_ratio = 0.15
	else:
		c.mood = "Không ngon..."
		c.mood_color = C_RED
	if not correct:
		c.mood = "Sai món rồi..."
		c.mood_color = C_RED
		c.happy = false
	elif b.tai and b.tai_cook < 0.4:
		c.mood = "Thịt tái còn sống"
		c.mood_color = C_YELLOW
	c.tip = int(round(MAX_TIP * tip_ratio * tip_mult / 1000.0)) * 1000
	c.state = "eating"
	c.eat_timer = 4.0


# ================================================================ nhập liệu
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.position.y < KITCHEN_Y:
			if mb.button_index == MOUSE_BUTTON_WHEEL_UP:
				_zoom_at(mb.position, 1.1)
			elif mb.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				_zoom_at(mb.position, 1.0 / 1.1)
		return
	if event is InputEventMagnifyGesture:
		var mg := event as InputEventMagnifyGesture
		_zoom_at(mg.position, mg.factor)
		return
	if event is InputEventPanGesture:
		var pg := event as InputEventPanGesture
		if pg.position.y < KITCHEN_Y:
			cam.position += pg.delta * 8.0 / cam.zoom.x
			_clamp_camera()
			cam_moved = true
		return
	if event is InputEventScreenTouch:
		var st := event as InputEventScreenTouch
		if st.pressed:
			if touches.is_empty() and _over_ui(st.position):
				return
			touches[st.index] = st.position
			if touches.size() == 1:
				_ptr_press(st.position)
			elif touches.size() == 2:
				pinching = true
				_cancel_pointer()
				pinch_dist = _touch_dist()
		elif touches.has(st.index):
			touches.erase(st.index)
			if pinching:
				if touches.is_empty():
					pinching = false
			elif touches.is_empty():
				_ptr_release(st.position)
		return
	if event is InputEventScreenDrag:
		var sd := event as InputEventScreenDrag
		if not touches.has(sd.index):
			return
		touches[sd.index] = sd.position
		if pinching and touches.size() >= 2:
			var d := _touch_dist()
			if pinch_dist > 0.0:
				_zoom_at(_touch_mid(), d / pinch_dist)
			pinch_dist = d
		elif not pinching:
			_ptr_move(sd.position)


func _touch_dist() -> float:
	var keys := touches.keys()
	if keys.size() < 2:
		return 0.0
	var a: Vector2 = touches[keys[0]]
	var b: Vector2 = touches[keys[1]]
	return a.distance_to(b)


func _touch_mid() -> Vector2:
	var keys := touches.keys()
	var a: Vector2 = touches[keys[0]]
	var b: Vector2 = touches[keys[1]]
	return (a + b) / 2.0


func _over_ui(p: Vector2) -> bool:
	var blockers: Array = [pill_clock, pill_money, btn_help, btn_door, btn_end, dlg, start_panel, summary_panel]
	for item in blockers:
		var ctl: Control = item
		if ctl.is_visible_in_tree() and ctl.get_global_rect().has_point(p):
			return true
	return false


func _cancel_pointer() -> void:
	ptr_down = false
	drag_kind = ""
	drag_slot = -1
	pour_target = -1


func _can_cook() -> bool:
	return state == "playing" or state == "tutorial"


func _ptr_press(p: Vector2) -> void:
	ptr_down = true
	ptr_start = p
	ptr_pos = p
	ptr_moved = false
	drag_kind = ""
	drag_slot = -1
	if p.y >= KITCHEN_Y:
		if _can_cook():
			drag_kind = _kitchen_source(p)
	else:
		drag_kind = "pan"


func _kitchen_source(p: Vector2) -> String:
	if R_BOWLS.has_point(p):
		return "bowl"
	if R_NOODLES.has_point(p):
		return "noodles"
	if R_BLANCH.has_point(p):
		return "strainer" if strainer_loaded else "pot"
	var s := _slot_at(p)
	if s != -1:
		if slots[s] != null:
			selected = s
			drag_slot = s
			return "dish"
		return ""
	if R_TAI.has_point(p):
		return "tai"
	if R_CHIN.has_point(p):
		return "chin"
	if R_ONION.has_point(p):
		return "onion"
	if R_PEPPER.has_point(p):
		return "pepper"
	if R_BROTH.has_point(p):
		return "ladle"
	if R_TRASH.has_point(p):
		return "trash"
	return ""


func _ptr_move(p: Vector2) -> void:
	var d := p - ptr_pos
	ptr_pos = p
	if not ptr_moved and p.distance_to(ptr_start) > 14.0:
		ptr_moved = true
	if drag_kind == "pan" and ptr_moved:
		cam.position -= d / cam.zoom.x
		_clamp_camera()
		cam_moved = true


func _ptr_release(p: Vector2) -> void:
	ptr_pos = p
	var kind := drag_kind
	var slot := drag_slot
	_cancel_pointer()
	if kind == "":
		return
	if kind == "pan":
		if not ptr_moved and _can_cook():
			_world_tap(_screen_to_world(p))
		return
	if kind == "ladle":
		return
	if not ptr_moved:
		_kitchen_tap(kind)
		return
	_kitchen_drop(kind, p, slot)


func _kitchen_tap(kind: String) -> void:
	match kind:
		"bowl":
			_add_bowl(-1)
		"noodles":
			_load_strainer()
		"strainer":
			_drain_to(-1)
		"pot":
			_add_float_screen("Kéo bánh phở vào rổ chần trước", R_BLANCH.get_center() + Vector2(0, -150), C_YELLOW)
		"tai", "chin", "onion", "pepper":
			_add_topping(kind, selected)
		"trash":
			_trash(selected)


func _kitchen_drop(kind: String, p: Vector2, slot: int) -> void:
	var target := _slot_at(p)
	match kind:
		"bowl":
			if target != -1 or p.y >= KITCHEN_Y:
				_add_bowl(target)
		"noodles":
			if R_BLANCH.has_point(p):
				_load_strainer()
		"strainer":
			if target != -1:
				_drain_to(target)
		"tai", "chin", "onion", "pepper":
			if target != -1:
				_add_topping(kind, target)
		"dish":
			if p.y < KITCHEN_Y:
				var c := _customer_at(_screen_to_world(p))
				if c != null:
					_serve(c, slot)
				else:
					_add_float_screen("Thả bát vào người khách", p + Vector2(0, -60), C_YELLOW)
			elif R_TRASH.has_point(p):
				_trash(slot)


func _world_tap(wp: Vector2) -> void:
	var c := _customer_at(wp)
	if c != null:
		var b := _selected_bowl()
		if _bowl_ready(b):
			_serve(c, selected)
		else:
			_add_float_world("Nấu xong bát phở rồi mang ra nhé", c.pos + Vector2(0, -CUSTOMER_H * c.crop - 30), C_YELLOW)
		return
	for i in seats.size():
		if seats[i]["dirty"] and seats[i]["customer"] == null and _table_rect(i).has_point(wp):
			seats[i]["dirty"] = false
			var t: Vector2 = TABLES[i]
			_add_float_world("Sạch rồi!", t + Vector2(0, -200), C_GREEN)
			_seat_from_queue()
			return
	if Rect2(cat_pos.x - 60.0, cat_pos.y - 110.0, 120.0, 115.0).has_point(wp):
		_add_float_world("Meo~", cat_pos + Vector2(0, -130), C_CREAM)


# ================================================================ hướng dẫn
func _tut_goto(i: int) -> void:
	tut_step = i
	if i >= TUTORIAL.size():
		return
	var step: Dictionary = TUTORIAL[i]
	dlg.visible = true
	dlg_label.text = step["text"]
	var btn: String = step["button"]
	dlg_button.visible = btn != ""
	dlg_button.text = btn
	if step.get("enter", "") == "spawn":
		_spawn_tutorial_customer()
	if step["wait"] == "camera":
		cam_moved = false


func _on_dlg_button() -> void:
	if state != "tutorial" or tut_step < 0 or tut_step >= TUTORIAL.size():
		return
	var step: Dictionary = TUTORIAL[tut_step]
	if step.get("finish", false):
		_finish_tutorial()
	else:
		_tut_goto(tut_step + 1)


func _tut_condition(w: String) -> bool:
	match w:
		"camera":
			return cam_moved
		"seated":
			return tut_customer != null and tut_customer.state == "waiting"
		"bowl":
			return _first_bowl() != -1
		"noodles_in":
			return strainer_loaded or _any_bowl("noodle")
		"noodles_bowl":
			return _any_bowl("noodle")
		"meat":
			return _any_bowl("meat")
		"broth":
			return _any_bowl("broth") and drag_kind != "ladle"
		"onion":
			return _any_bowl("onion")
		"served":
			return tut_customer != null and (tut_customer.state == "eating" or tut_paid)
		"paid":
			return tut_paid
		"cleaned":
			for s in seats:
				if s["dirty"]:
					return false
			return tut_paid
	return false


func _any_bowl(what: String) -> bool:
	for item in slots:
		if item == null:
			continue
		var b: Bowl = item
		match what:
			"noodle":
				if b.has_noodle:
					return true
			"meat":
				if b.tai or b.chin:
					return true
			"broth":
				if b.broth >= 0.4:
					return true
			"onion":
				if b.onion:
					return true
	return false


func _tut_check() -> void:
	if tut_step < 0 or tut_step >= TUTORIAL.size():
		return
	var step: Dictionary = TUTORIAL[tut_step]
	var w: String = step["wait"]
	if w != "" and _tut_condition(w):
		_tut_goto(tut_step + 1)


func _finish_tutorial() -> void:
	tutorial_done = true
	_save()
	dlg.visible = false
	day += 1
	state = "playing"
	door_open = true
	btn_door.text = "Đóng cửa"
	elapsed = 0.0
	hour = OPEN_HOUR
	spawn_timer = 2.0
	_add_float_screen("Mở cửa! Ngày %d" % day, Vector2(960, 420), C_GOLD, 2.0)


func _tut_target_rect() -> Rect2:
	if state != "tutorial" or tut_step < 0 or tut_step >= TUTORIAL.size():
		return Rect2()
	var step: Dictionary = TUTORIAL[tut_step]
	var t: String = step["target"]
	match t:
		"bowls":
			return R_BOWLS
		"noodles":
			return R_NOODLES
		"strainer":
			return R_BLANCH
		"tai":
			return R_TAI
		"broth":
			return R_BROTH
		"onion":
			return R_ONION
		"customer":
			if tut_customer != null and is_instance_valid(tut_customer.sprite):
				var h := CUSTOMER_H * tut_customer.crop
				var a := _world_to_screen(tut_customer.pos + Vector2(-90, -h - 10))
				var b := _world_to_screen(tut_customer.pos + Vector2(90, 20))
				return Rect2(a, b - a)
		"table":
			for i in seats.size():
				if seats[i]["dirty"]:
					var r := _table_rect(i)
					var a := _world_to_screen(r.position)
					var b := _world_to_screen(r.end)
					return Rect2(a, b - a)
	return Rect2()


# ================================================================ HUD
func _update_hud() -> void:
	var h := int(hour) % 24
	var m := int((hour - floorf(hour)) * 60.0)
	if state == "tutorial":
		lbl_clock.text = "Hướng dẫn"
	else:
		lbl_clock.text = "Ngày %d · %02d:%02d" % [day, h, m]
	lbl_money.text = _fmt(money)
	pill_money.position.x = pill_clock.position.x + pill_clock.size.x + 14.0
	btn_door.visible = state == "playing" and not day_over
	btn_end.visible = state == "playing" and not day_over and not door_open and customers.is_empty()
	btn_help.visible = state != "tutorial"
	lbl_hint.text = _hint() if state == "playing" else ""


func _hint() -> String:
	if not door_open and not day_over:
		return "Quán đang tạm đóng cửa. Nhấn \"Mở cửa\" để đón khách."
	for s in seats:
		if s["dirty"] and s["customer"] == null and not queue.is_empty():
			return "Có khách đang chờ ở cửa: chạm vào bàn có bát bẩn để dọn"
	if strainer_loaded:
		var r := strainer_time / COOK_TIME
		if r >= 0.75 and r <= 1.15:
			return "Bánh vừa chín: kéo rổ chần đổ vào bát!"
		if r > 1.15:
			return "Bánh sắp nát, đổ vào bát ngay!"
	var b := _selected_bowl()
	if b == null:
		return "Chạm chồng bát để lấy bát, kéo bánh phở vào rổ chần"
	if not b.has_noodle:
		return "Kéo bánh phở vào rổ chần, chín rồi đổ vào bát"
	if not b.tai and not b.chin:
		return "Kéo thịt Tái hoặc Chín vào bát theo order của khách"
	if b.broth < 0.25:
		return "Kéo môi từ nồi nước dùng sang bát, giữ tay để chan"
	return "Rắc hành, tiêu nếu khách gọi rồi kéo bát ra cho khách"


func _add_float_world(text: String, pos: Vector2, color: Color, life := 1.6) -> void:
	floats_world.append({"text": text, "pos": pos, "color": color, "t": 0.0, "life": life})


func _add_float_screen(text: String, pos: Vector2, color: Color, life := 1.4) -> void:
	floats_screen.append({"text": text, "pos": pos, "color": color, "t": 0.0, "life": life})


func _update_floats(delta: float) -> void:
	for list in [floats_world, floats_screen]:
		var arr: Array = list
		for f in arr.duplicate():
			f["t"] += delta
			f["pos"] += Vector2(0, -40.0 * delta)
			if f["t"] >= f["life"]:
				arr.erase(f)


func _fmt(v: int) -> String:
	var s := str(absi(v))
	var out := ""
	var count := 0
	for i in range(s.length() - 1, -1, -1):
		out = s[i] + out
		count += 1
		if count % 3 == 0 and i > 0:
			out = "." + out
	return ("-" if v < 0 else "") + out + " đ"


func _stars() -> int:
	var n := 0
	for g in STAR_GOALS:
		var goal: int = g
		if money >= goal:
			n += 1
	return n


# ================================================================ vẽ: tiện ích
func _tex(ci: CanvasItem, key: String, center: Vector2, height: float, mod := Color.WHITE) -> void:
	var t: Texture2D = tex[key]
	var k := height / float(t.get_height())
	var sz := Vector2(t.get_width() * k, height)
	ci.draw_texture_rect(t, Rect2(center - sz / 2.0, sz), false, mod)


func _text(ci: CanvasItem, pos: Vector2, text: String, size: int, color: Color, width := 400.0, outline := true) -> void:
	var p := pos - Vector2(width * 0.5, 0)
	if outline:
		ci.draw_string_outline(font_bold, p, text, HORIZONTAL_ALIGNMENT_CENTER, width, size, 8, Color(C_INK, color.a))
	ci.draw_string(font_bold, p, text, HORIZONTAL_ALIGNMENT_CENTER, width, size, color)


func _ellipse(center: Vector2, r: Vector2, n := 28) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in n:
		var a := TAU * float(i) / float(n)
		pts.append(center + Vector2(cos(a) * r.x, sin(a) * r.y))
	return pts


func _steam(ci: CanvasItem, base: Vector2, count: int, height: float, alpha := 0.55) -> void:
	for i in count:
		var x := base.x + (float(i) - (count - 1) / 2.0) * 26.0
		var pts := PackedVector2Array()
		for k in 7:
			var y := base.y - k * height / 6.0
			pts.append(Vector2(x + sin(t_anim * 3.0 + k * 0.8 + i * 1.7) * 7.0, y))
		ci.draw_polyline(pts, Color(1, 1, 1, alpha), 4.0)


func _draw_bowl(ci: CanvasItem, c: Vector2, b: Bowl, s: float) -> void:
	var w := 150.0 * s
	var depth := 72.0 * s
	ci.draw_colored_polygon(_ellipse(c + Vector2(0, depth + 4.0 * s), Vector2(w * 0.38, 8.0 * s)), Color(0, 0, 0, 0.18))
	var body := PackedVector2Array()
	for i in 17:
		var a := PI * float(i) / 16.0
		body.append(c + Vector2(cos(a) * w * 0.5, sin(a) * depth))
	ci.draw_colored_polygon(body, Color("f7f3ea"))
	var band := PackedVector2Array()
	for i in 17:
		var a := PI * float(i) / 16.0
		band.append(c + Vector2(cos(a) * w * 0.46, 12.0 * s + sin(a) * depth * 0.55))
	ci.draw_polyline(band, Color("2f5d8a"), 6.0 * s)
	for i in 5:
		var a := PI * (0.2 + 0.15 * i)
		ci.draw_circle(c + Vector2(cos(a) * w * 0.33, 30.0 * s + sin(a) * depth * 0.35), 4.5 * s, Color("2f5d8a"))
	body.append(body[0])
	ci.draw_polyline(body, C_INK, 3.0)

	var rim := _ellipse(c, Vector2(w * 0.5, 16.0 * s))
	var inside := Color("e2d8c6")
	if b != null and b.broth > 0.0:
		inside = Color("efd9a6").lerp(C_BROTH, clampf(b.broth, 0.0, 1.0))
	ci.draw_colored_polygon(rim, inside)
	if b != null:
		if b.has_noodle:
			var nc := Color("fff8e6") if not b.mushy else Color("efe4c6")
			for i in 5:
				var y := c.y - 6.0 * s + i * 3.0 * s
				var pts := PackedVector2Array()
				for k in 9:
					var x := c.x - w * 0.38 + k * w * 0.095
					pts.append(Vector2(x, y + sin(k * 1.3 + i) * 2.0 * s))
				ci.draw_polyline(pts, nc, 3.0 * s)
		if b.tai:
			var raw := Color("e88a8a")
			var done := Color("b98068")
			var col := raw.lerp(done, b.tai_cook)
			ci.draw_colored_polygon(_ellipse(c + Vector2(-w * 0.2, -3.0 * s), Vector2(18, 7) * s), col)
			ci.draw_colored_polygon(_ellipse(c + Vector2(-w * 0.04, 2.0 * s), Vector2(16, 6) * s), col)
		if b.chin:
			ci.draw_colored_polygon(_ellipse(c + Vector2(w * 0.17, -3.0 * s), Vector2(17, 7) * s), Color("9c5b33"))
			ci.draw_colored_polygon(_ellipse(c + Vector2(w * 0.31, 2.0 * s), Vector2(12, 5) * s), Color("9c5b33"))
		if b.onion:
			for i in 9:
				var pp := c + Vector2(-w * 0.36 + i * w * 0.09, -7.0 * s + (i % 3) * 5.0 * s)
				ci.draw_rect(Rect2(pp, Vector2(6, 4) * s), C_GREEN)
		if b.pepper:
			for i in 12:
				var pp := c + Vector2(-w * 0.3 + (i * 37 % 60) / 60.0 * w * 0.6, -6.0 * s + (i * 13 % 11) * s)
				ci.draw_circle(pp, 1.6 * s, Color("2b1a12"))
	rim.append(rim[0])
	ci.draw_polyline(rim, C_INK, 3.0)
	if b != null and b.broth > 0.3:
		_steam(ci, c + Vector2(0, -16.0 * s), 3, 60.0 * s, 0.45)


func _bar(ci: CanvasItem, r: Rect2, value: float, good: Vector2, maxv: float, vertical := false) -> void:
	ci.draw_rect(r, C_CREAM)
	if vertical:
		var gy0 := r.end.y - r.size.y * good.y / maxv
		var gy1 := r.end.y - r.size.y * good.x / maxv
		ci.draw_rect(Rect2(r.position.x, gy0, r.size.x, gy1 - gy0), Color(C_GREEN, 0.5))
		var fill := clampf(value / maxv, 0.0, 1.0) * r.size.y
		ci.draw_rect(Rect2(r.position.x, r.end.y - fill, r.size.x, fill), C_BROTH)
	else:
		var gx0 := r.position.x + r.size.x * good.x / maxv
		var gx1 := r.position.x + r.size.x * good.y / maxv
		ci.draw_rect(Rect2(gx0, r.position.y, gx1 - gx0, r.size.y), Color(C_GREEN, 0.6))
		var px := r.position.x + clampf(value / maxv, 0.0, 1.0) * r.size.x
		ci.draw_line(Vector2(px, r.position.y - 5), Vector2(px, r.end.y + 5), C_INK, 5.0)
	ci.draw_rect(r, C_INK, false, 3.0)


func _star(ci: CanvasItem, c: Vector2, r: float, on: bool) -> void:
	var pts := PackedVector2Array()
	for i in 10:
		var a := -PI / 2.0 + PI * float(i) / 5.0
		var rr := r if i % 2 == 0 else r * 0.45
		pts.append(c + Vector2(cos(a) * rr, sin(a) * rr))
	ci.draw_colored_polygon(pts, C_GOLD if on else Color("e9dcc3"))
	pts.append(pts[0])
	ci.draw_polyline(pts, C_INK, 3.0)


func _pepper_shaker(ci: CanvasItem, c: Vector2, s: float) -> void:
	var body := Rect2(c + Vector2(-20, -30) * s, Vector2(40, 64) * s)
	ci.draw_rect(body, Color("f3eadb"))
	ci.draw_rect(Rect2(c + Vector2(-20, -42) * s, Vector2(40, 14) * s), Color("8a8580"))
	for i in 5:
		ci.draw_circle(c + Vector2(-12 + i * 6, -36) * s, 1.6 * s, Color("2b1a12"))
	ci.draw_rect(Rect2(c + Vector2(-20, -8) * s, Vector2(40, 12) * s), Color("2f5d8a"))
	ci.draw_rect(body, C_INK, false, 3.0)


func _ladle(ci: CanvasItem, tip: Vector2, full: bool) -> void:
	ci.draw_line(tip + Vector2(20, -10), tip + Vector2(110, -90), Color("7a4720"), 8.0)
	ci.draw_colored_polygon(_ellipse(tip, Vector2(28, 16)), Color("b8b4ac"))
	if full:
		ci.draw_colored_polygon(_ellipse(tip + Vector2(0, -3), Vector2(22, 9)), C_BROTH)
	var rim := _ellipse(tip, Vector2(28, 16))
	rim.append(rim[0])
	ci.draw_polyline(rim, C_INK, 3.0)


# ================================================================ vẽ: quán
func _draw_world_bg() -> void:
	var ci := world_bg
	var c_post := Color("a0682b")
	var c_post_dark := Color("6e4317")
	ci.draw_rect(Rect2(-400, -200, WORLD.x + 800, WORLD.y + 600), Color("3b2418"))
	# mái rơm và xà tre
	ci.draw_rect(Rect2(-60, -80, WORLD.x + 120, 170), Color("c99545"))
	for x in range(-60, int(WORLD.x) + 60, 12):
		ci.draw_line(Vector2(x, -80), Vector2(x + 8, 90), Color("a9772f"), 2.0)
	ci.draw_rect(Rect2(-60, 90, WORLD.x + 120, 22), Color("8e5a26"))
	# vách tre đan
	ci.draw_rect(Rect2(-60, 112, WORLD.x + 120, 320), Color("dda84e"))
	for k in range(-400, int(WORLD.x) + 400, 46):
		ci.draw_line(Vector2(k, 112), Vector2(k + 320, 432), Color("b98235"), 3.0)
		ci.draw_line(Vector2(k + 320, 112), Vector2(k, 432), Color("b98235"), 3.0)
	# cửa sổ nhìn ra vườn tre
	for wx in [960.0, 1600.0]:
		var win := Rect2(wx, 160, 250, 180)
		ci.draw_rect(win, Color("a7c98a"))
		for i in 8:
			ci.draw_line(win.position + Vector2(18 + i * 30, 180), win.position + Vector2(10 + i * 30 + sin(t_anim + i) * 3.0, 0), Color("6f9a4e"), 6.0)
		ci.draw_rect(win, c_post_dark, false, 8.0)
		ci.draw_line(win.position + Vector2(125, 0), win.position + Vector2(125, 180), c_post_dark, 6.0)
	# biển hiệu
	var board := Rect2(90, 150, 330, 86)
	ci.draw_rect(board, Color("7a4720"))
	ci.draw_rect(board, C_INK, false, 4.0)
	_text(ci, Vector2(board.get_center().x, board.position.y + 60), "Phở Bà Tư", 44, Color("ffd27a"), 330, false)
	# cột tre
	for x in [20.0, 640.0, 1240.0, 1840.0, 2380.0]:
		ci.draw_rect(Rect2(x - 18, 90, 36, 360), c_post)
		for y in range(150, 450, 90):
			ci.draw_line(Vector2(x - 18, y), Vector2(x + 18, y), c_post_dark, 3.0)
	# nền đất nện
	ci.draw_rect(Rect2(-60, 432, WORLD.x + 120, WORLD.y - 432 + 60), Color("a56a35"))
	for i in 40:
		var p := Vector2(float(i * 397 % int(WORLD.x)), 470.0 + float(i * 173 % 700))
		ci.draw_circle(p, 3.0 + float(i % 3), Color("94602f"))
	# chiếu tre dưới mỗi dãy bàn
	for row_y in [640.0, 920.0]:
		var mat := Rect2(520, row_y, 1630, 200)
		ci.draw_rect(mat, Color("c79a55"))
		for y in range(int(row_y) + 10, int(row_y) + 200, 18):
			ci.draw_line(Vector2(mat.position.x, y), Vector2(mat.end.x, y), Color("a8793c"), 2.0)
		ci.draw_rect(mat, Color("8e5e25"), false, 3.0)
	# lối đi và cửa ra vào
	ci.draw_rect(Rect2(-60, 1080, WORLD.x + 120, 70), Color("b88250"))
	ci.draw_rect(Rect2(-60, 960, 70, 220), Color("2b1a12"))
	ci.draw_rect(Rect2(10, 950, 14, 230), c_post)
	for i in 6:
		ci.draw_line(Vector2(-40 + i * 10, 960), Vector2(-40 + i * 10 + sin(t_anim + i) * 2.0, 1060), Color("c8312b"), 4.0)


func _draw_counter() -> void:
	var ci := counter_node
	# quầy nấu của Na: mặt quầy tre, nồi nước dùng lớn và bếp than
	_tex(ci, "big_pot", Vector2(-120, -170), 150)
	_steam(ci, Vector2(-120, -250), 3, 110.0, 0.5)
	ci.draw_rect(Rect2(-230, -150, 460, 26), Color("e3b867"))
	ci.draw_rect(Rect2(-220, -124, 440, 124), Color("b9853a"))
	for x in range(-220, 220, 30):
		ci.draw_line(Vector2(x, -124), Vector2(x, 0), Color("8e5e25"), 3.0)
	ci.draw_rect(Rect2(-230, -150, 460, 26), C_INK, false, 3.0)
	ci.draw_rect(Rect2(-220, -124, 440, 124), C_INK, false, 3.0)
	for i in 3:
		var bc := Vector2(70 + i * 40, -162)
		ci.draw_colored_polygon(_ellipse(bc, Vector2(22, 8)), Color("f7f3ea"))
		var e := _ellipse(bc, Vector2(22, 8))
		e.append(e[0])
		ci.draw_polyline(e, C_INK, 2.0)


func _draw_world_fx() -> void:
	var ci := world_fx
	# bàn bẩn và bát phở đang ăn trên bàn
	for i in seats.size():
		var t: Vector2 = TABLES[i]
		var top := t + Vector2(0, -132)
		var s: Dictionary = seats[i]
		var occupant: Customer = s["customer"]
		if occupant != null and occupant.state == "eating":
			_tex(ci, "pho", top, 70)
			_steam(ci, top + Vector2(0, -24), 2, 50.0, 0.5)
		elif s["dirty"]:
			_draw_bowl(ci, top, Bowl.new(), 0.45)
			ci.draw_line(top + Vector2(-16, -2), top + Vector2(14, 4), Color("8e5a26"), 3.0)
			ci.draw_line(top + Vector2(30, -10), top + Vector2(60, -40), Color("c98b4a"), 3.0)
			_text(ci, top + Vector2(0, -40), "Chạm để dọn", 24, Color.WHITE, 240)

	# bóng thoại và biểu cảm của khách
	for item in customers:
		var c: Customer = item
		var head := c.pos + Vector2(0, -CUSTOMER_H * c.crop - 12)
		if c.state == "waiting":
			var ratio := clampf(c.patience / c.patience_max, 0.0, 1.0)
			if c.tutorial:
				ratio = 1.0
			var col := C_GREEN
			if ratio < 0.25:
				col = C_RED
			elif ratio < 0.55:
				col = C_YELLOW
			var lines := _order_lines(c)
			var bh := 28.0 + lines.size() * 32.0 + 22.0
			var box := Rect2(head.x - 125, head.y - bh - 10, 250, bh)
			bubble_box.border_color = col
			bubble_box.set_border_width_all(4 if ratio >= 0.25 else 6)
			ci.draw_style_box(bubble_box, box)
			var tail := PackedVector2Array([Vector2(head.x - 14, box.end.y - 2), Vector2(head.x + 14, box.end.y - 2), Vector2(head.x, box.end.y + 16)])
			ci.draw_colored_polygon(tail, Color.WHITE)
			for li in lines.size():
				var line: String = lines[li]
				var lc := C_INK
				if line == "không hành":
					lc = C_RED
				elif line == "thêm tiêu":
					lc = Color("2f5d8a")
				ci.draw_string(font_bold if li == 0 else font, box.position + Vector2(0, 40 + li * 32), line, HORIZONTAL_ALIGNMENT_CENTER, box.size.x, 28 if li == 0 else 24, lc)
			var pb := Rect2(box.position.x + 20, box.end.y - 22, box.size.x - 40, 11)
			ci.draw_rect(pb, Color("e6d6b4"))
			ci.draw_rect(Rect2(pb.position, Vector2(pb.size.x * ratio, pb.size.y)), col)
			if c.type["strict"]:
				_text(ci, Vector2(head.x, box.position.y - 10), "Khách khó tính", 22, C_RED, 260)
			if ratio < 0.55:
				var drop := head + Vector2(70, -6)
				ci.draw_colored_polygon(PackedVector2Array([drop + Vector2(0, -16), drop + Vector2(8, 2), drop + Vector2(-8, 2)]), Color("7fb8e6"))
				ci.draw_circle(drop + Vector2(0, 3), 8, Color("7fb8e6"))
			if ratio < 0.25:
				var m := head + Vector2(-72, -4)
				ci.draw_line(m + Vector2(-10, -10), m + Vector2(-3, -3), C_RED, 4.0)
				ci.draw_line(m + Vector2(10, -10), m + Vector2(3, -3), C_RED, 4.0)
				ci.draw_line(m + Vector2(-10, 10), m + Vector2(-3, 3), C_RED, 4.0)
				ci.draw_line(m + Vector2(10, 10), m + Vector2(3, 3), C_RED, 4.0)
		elif c.state == "queue":
			var ratio := clampf(c.wait / (c.patience_max * 0.8), 0.0, 1.0)
			var pb := Rect2(head.x - 55, head.y - 24, 110, 12)
			ci.draw_rect(pb, Color("e6d6b4"))
			ci.draw_rect(Rect2(pb.position, Vector2(pb.size.x * ratio, pb.size.y)), C_YELLOW if ratio > 0.3 else C_RED)
			ci.draw_rect(pb, C_INK, false, 2.0)
		elif c.state == "eating":
			_text(ci, head + Vector2(0, -26), c.mood, 30, c.mood_color, 340)
			if c.happy:
				var hp := head + Vector2(80, -40 - fmod(t_anim * 30.0, 30.0))
				ci.draw_circle(hp + Vector2(-6, 0), 8, C_RED)
				ci.draw_circle(hp + Vector2(6, 0), 8, C_RED)
				ci.draw_colored_polygon(PackedVector2Array([hp + Vector2(-14, 3), hp + Vector2(14, 3), hp + Vector2(0, 18)]), C_RED)

	for f in floats_world:
		var a := 1.0 - clampf((f["t"] - f["life"] * 0.6) / (f["life"] * 0.4), 0.0, 1.0)
		var col: Color = f["color"]
		col.a = a
		_text(ci, f["pos"], f["text"], 34, col, 640)


# ================================================================ vẽ: bếp
func _draw_kitchen() -> void:
	var ci := kui
	ci.draw_rect(Rect2(0, KITCHEN_Y, 1920, 1080 - KITCHEN_Y), Color("b9853a"))
	for x in range(0, 1920, 40):
		ci.draw_line(Vector2(x, KITCHEN_Y + 44), Vector2(x, 1080), Color("9a6a2c"), 3.0)
	ci.draw_rect(Rect2(0, KITCHEN_Y, 1920, 44), Color("e3b867"))
	ci.draw_line(Vector2(0, KITCHEN_Y), Vector2(1920, KITCHEN_Y), C_INK, 4.0)
	ci.draw_line(Vector2(0, KITCHEN_Y + 44), Vector2(1920, KITCHEN_Y + 44), C_INK, 3.0)

	for r in [R_BOWLS, R_NOODLES, R_BLANCH, R_TAI, R_CHIN, R_ONION, R_PEPPER, R_BROTH, R_TRASH]:
		ci.draw_style_box(tile_box, r)
	# thớt gỗ đặt bát
	var board := Rect2(605, 790, 555, 230)
	ci.draw_rect(board, Color("dcb47c"))
	ci.draw_rect(board, C_INK, false, 3.0)

	# chồng bát
	for i in 4:
		_draw_bowl(ci, R_BOWLS.get_center() + Vector2(0, 50 - i * 28), null, 0.78)
	# rổ bánh phở
	_tex(ci, "noodles", R_NOODLES.get_center() + Vector2(0, -8), 125)
	# nồi chần nước sôi
	var pot_c := R_BLANCH.get_center() + Vector2(0, -6)
	_tex(ci, "stove", pot_c + Vector2(0, 95), 95)
	_tex(ci, "blanch_pot", pot_c + Vector2(0, 5), 135)
	var water := pot_c + Vector2(0, -40)
	ci.draw_colored_polygon(_ellipse(water, Vector2(58, 13)), Color("d9e3df"))
	for i in 6:
		var bp := water + Vector2(sin(t_anim * 3.0 + i * 2.1) * 40.0, cos(t_anim * 2.0 + i) * 6.0)
		ci.draw_arc(bp, 4.0 + fmod(t_anim * 6.0 + i, 3.0), 0, TAU, 12, Color(1, 1, 1, 0.8), 2.0)
	_steam(ci, water + Vector2(0, -10), 2, 60.0, 0.4)
	if strainer_loaded and drag_kind != "strainer":
		_tex(ci, "strainer", water + Vector2(0, -22 + sin(t_anim * 6.0) * 3.0), 110)
		ci.draw_colored_polygon(_ellipse(water + Vector2(0, -2), Vector2(26, 8)), Color("fff8e6"))
		var r := strainer_time / COOK_TIME
		_bar(ci, Rect2(R_BLANCH.position.x + 15, R_BLANCH.position.y + 4, R_BLANCH.size.x - 30, 22), r, Vector2(0.75, 1.15), 1.8)
	elif not strainer_loaded:
		_tex(ci, "strainer", pot_c + Vector2(72, 30), 85, Color(1, 1, 1, 0.95))

	# bát trên thớt
	for i in slots.size():
		var r: Rect2 = R_SLOTS[i]
		var b: Bowl = slots[i]
		if i == selected and b != null:
			ci.draw_rect(r.grow(-6), Color(1.0, 0.85, 0.3, 0.3))
			ci.draw_rect(r.grow(-6), C_GOLD, false, 5.0)
		if b != null and not (drag_kind == "dish" and drag_slot == i and ptr_moved):
			_draw_bowl(ci, r.get_center() + Vector2(-14, -12), b, 0.95)
			if b.has_noodle:
				_bar(ci, Rect2(r.end.x - 30, r.position.y + 30, 18, 140), b.broth, Vector2(BROTH_LOW, BROTH_HIGH), 1.15, true)
		elif b == null:
			ci.draw_arc(r.get_center() + Vector2(0, -6), 40, 0, TAU, 32, Color(0.3, 0.18, 0.08, 0.25), 3.0)

	# thịt, hành, tiêu
	_tex(ci, "beef", R_TAI.get_center() + Vector2(0, -6), 72)
	_tex(ci, "beef", R_CHIN.get_center() + Vector2(0, -6), 72, Color(0.62, 0.42, 0.3))
	_tex(ci, "onion", R_ONION.get_center() + Vector2(0, -8), 90)
	_pepper_shaker(ci, R_PEPPER.get_center() + Vector2(0, -4), 1.0)

	# nồi nước dùng và môi
	var bc := R_BROTH.get_center()
	_tex(ci, "broth_pot", bc + Vector2(0, 5), 200)
	_steam(ci, bc + Vector2(0, -95), 3, 90.0, 0.55)
	if drag_kind != "ladle":
		_ladle(ci, bc + Vector2(60, -70), false)

	# giỏ bỏ bát
	var tr_c := R_TRASH.get_center() + Vector2(0, -10)
	var basket := PackedVector2Array([tr_c + Vector2(-55, -35), tr_c + Vector2(55, -35), tr_c + Vector2(42, 45), tr_c + Vector2(-42, 45)])
	ci.draw_colored_polygon(basket, Color("8e5e25"))
	for i in 5:
		ci.draw_line(tr_c + Vector2(-50, -25 + i * 15), tr_c + Vector2(50, -25 + i * 15), Color("6e4317"), 2.0)
	basket.append(basket[0])
	ci.draw_polyline(basket, C_INK, 3.0)

	# nhãn
	var labels := [
		[R_BOWLS, "Lấy bát"], [R_NOODLES, "Bánh phở"], [R_BLANCH, "Nồi chần"], [R_TAI, "Tái"], [R_CHIN, "Chín"],
		[R_ONION, "Hành"], [R_PEPPER, "Tiêu"], [R_BROTH, "Nước dùng"], [R_TRASH, "Bỏ bát"],
	]
	for item in labels:
		var r: Rect2 = item[0]
		var text: String = item[1]
		_text(ci, Vector2(r.get_center().x, r.end.y - 6), text, 24, Color.WHITE, r.size.x + 40)


# ================================================================ vẽ: lớp trên cùng
func _draw_overlay() -> void:
	var ci := overlay
	# sao và mục tiêu
	var n := _stars()
	if state == "summary":
		var base := summary_panel.position + Vector2(summary_panel.size.x * 0.5 - 2 * 60, summary_panel.size.y - 128)
		for i in 5:
			_star(ci, base + Vector2(i * 60, 0), 26, i < n)
	elif state == "playing":
		var base := Vector2(960 - 2 * 46, 46)
		for i in 5:
			_star(ci, base + Vector2(i * 46, 0), 20, i < n)
		if n < STAR_GOALS.size():
			var goal: int = STAR_GOALS[n]
			_text(ci, Vector2(960, 92), "Mục tiêu sao %d: %s" % [n + 1, _fmt(goal)], 20, Color.WHITE, 500)

	# chỉ dẫn trong phần hướng dẫn
	var target_r := _tut_target_rect()
	if target_r.size != Vector2.ZERO:
		var pulse := 0.5 + 0.5 * sin(t_anim * 5.0)
		var g := target_r.grow(8.0 + pulse * 6.0)
		ci.draw_rect(g, Color(1.0, 0.85, 0.3, 0.9), false, 6.0)
		var tip := Vector2(g.get_center().x, g.position.y - 10.0 - pulse * 14.0)
		ci.draw_colored_polygon(PackedVector2Array([tip, tip + Vector2(-26, -36), tip + Vector2(26, -36)]), C_GOLD)
		ci.draw_rect(Rect2(tip + Vector2(-10, -78), Vector2(20, 44)), C_GOLD)

	# vật đang kéo
	if drag_kind != "" and drag_kind != "pan" and ptr_moved:
		var p := ptr_pos
		match drag_kind:
			"bowl":
				_draw_bowl(ci, p, null, 0.8)
			"noodles":
				_tex(ci, "noodles", p, 70)
			"strainer":
				_tex(ci, "strainer", p, 110)
				ci.draw_colored_polygon(_ellipse(p + Vector2(0, 18), Vector2(26, 8)), Color("fff8e6"))
			"tai":
				_tex(ci, "beef", p, 60)
			"chin":
				_tex(ci, "beef", p, 60, Color(0.62, 0.42, 0.3))
			"onion":
				_tex(ci, "onion", p, 70)
			"pepper":
				_pepper_shaker(ci, p, 0.9)
			"dish":
				if drag_slot >= 0 and slots[drag_slot] != null:
					var b: Bowl = slots[drag_slot]
					_draw_bowl(ci, p, b, 0.9 / (1.0 if p.y >= KITCHEN_Y else 1.2))
	if drag_kind == "ladle" and ptr_down:
		var lp := ptr_pos
		if pour_target != -1:
			var bc := _slot_rect(pour_target).get_center() + Vector2(-14, -12)
			lp = bc + Vector2(30, -80)
			ci.draw_line(lp + Vector2(-10, 10), bc + Vector2(0, -6), C_BROTH, 9.0)
		_ladle(ci, lp, true)

	for f in floats_screen:
		var a := 1.0 - clampf((f["t"] - f["life"] * 0.6) / (f["life"] * 0.4), 0.0, 1.0)
		var col: Color = f["color"]
		col.a = a
		_text(ci, f["pos"], f["text"], 32, col, 700)
