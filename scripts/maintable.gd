
extends Node2D

# TR = to remove; TD = to do

enum View { TABLE, SHOP, DRINKS }

var held_item: String = ""
var current_money: int = 0
var current_view: View = View.TABLE
var dealer_hp: int = 10
var dealer_max_hp: int = 10
var ammo_current: int = 6
var ammo_max: int = 6
var ammo_box_shot_counter: bool = false
var slipups: int = 0
var dealer_paid: int = false

@export var shopkeep_open_texture: Texture2D
@export var shopkeep_idle_texture: Texture2D

@export var ammo_box_normal_texture: Texture2D
@export var ammo_box_shot_texture: Texture2D

@export var zeroD: Texture2D
@export var oneD: Texture2D
@export var twoD: Texture2D
@export var threeD: Texture2D
@export var fourplusD: Texture2D

@onready var dealer_hp_bar = get_parent().get_node("DealerHPBar")

@onready var background_root = get_parent().get_node("Backgrounds")

@onready var ammo_label = $Labels_toRemove/AmmoCounter
@onready var held_label = $Labels_toRemove/HeldItemLabel

@onready var sound_empty = $AudioPlayers/emptyhand
@onready var sound_gun = $AudioPlayers/gun
@onready var sound_money = $AudioPlayers/money

@onready var gun_sprite = $Tools/GunArea/GunSprite
@onready var money_sprite = $Tools/MoneyArea/MoneySprite
@onready var shopkeep_sprite = $Shop/ShopkeepArea/ShopkeepSprite
@onready var ammo_box_sprite = $Dealer/AmmoBoxArea/AmmoBoxSprite

@onready var ware_slots: Array[WareSlot] = [$Shop/BuyableConsumable, $Shop/BuyableArtifact, $Shop/ASes]
@onready var drink_slots: Array[DrinkSlot] = [$Drinks/LDrinkArea, $Drinks/RDrinkArea]

var gun_sprite_base_y: float
var money_sprite_base_y: float

var view_group_nodes := {
	View.TABLE: ["Dealer", "Tools", "../DealerHPBar"],
	View.SHOP: ["Shop"],
	View.DRINKS: ["Drinks"],
}

var view_background_names := {
	View.TABLE: "Table",
	View.SHOP: "Shop",
	View.DRINKS: "Drinks",
}

func _ready() -> void:
	print_tree_pretty()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	$TempMoney.pressed.connect(_money_glitch_TR)
	
	# Зоны — only nodes that actually exist right now
	$Dealer/DealerArea.input_event.connect(_on_dealer_clicked)
	$Dealer/AmmoBoxArea.input_event.connect(_on_ammo_box_clicked)
	$Shop/ShopkeepArea.input_event.connect(_on_shopkeep_clicked)
	$Tools/GunArea.input_event.connect(_on_gun_clicked)
	$Tools/MoneyArea.input_event.connect(_on_money_clicked)
	$Tools/GunArea.mouse_entered.connect(_on_gun_hover_enter)
	$Tools/GunArea.mouse_exited.connect(_on_gun_hover_exit)
	$Tools/MoneyArea.mouse_entered.connect(_on_money_hover_enter)
	$Tools/MoneyArea.mouse_exited.connect(_on_money_hover_exit)

	for slot in ware_slots:
		slot.clicked.connect(_on_ware_slot_clicked)
		slot.restock()
		
	for slot in drink_slots:
		slot.clicked.connect(_on_drink_slot_clicked)
		slot.restock()

	# TD: wire these once the corresponding nodes exist
	# $Dealer/Stash.input_event.connect(...)          -> Obj.STASH
	# $Table/Ammo...                                  -> Obj.AMMO
	# $Table/Ach...                                   -> Obj.ACH
	# $Table/Deck...                                  -> Obj.DECK
	# $Table/Lamp...                                  -> Obj.LAMP
	# $Drinks/Drink1..., Drink2..., Waitress...        -> Obj.DRINK1/2, Obj.WAITRESS
	# $Shop/Artifact..., Cards...                     -> Obj.ARTIFACT, Obj.CARDS

	gun_sprite_base_y = gun_sprite.position.y
	money_sprite_base_y = money_sprite.position.y

	show_view(View.TABLE)
	dealer_hp_bar.max_value = dealer_max_hp
	dealer_hp_bar.value = dealer_hp
	

	update_label()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_page_right"):  # Q
		cycle_view_right()
	if event.is_action_pressed("ui_page_left"):   # E
		cycle_view_left()

func _money_glitch_TR() -> void:
	money_gain()

func cycle_view_right() -> void:
	var views := View.values()
	var idx := views.find(current_view)
	show_view(views[(idx - 1 + views.size()) % views.size()])

func cycle_view_left() -> void:
	var views := View.values()
	var idx := views.find(current_view)
	show_view(views[(idx + 1) % views.size()])

func show_view(view: View) -> void:
	var previous_view := current_view 
	current_view = view
	for v in view_group_nodes:
		var is_active: bool = (v == view)
		for path in view_group_nodes[v]:
			get_node(path).visible = is_active
	for bg_view in view_background_names:
		var bg_name: String = view_background_names[bg_view]
		background_root.get_node(bg_name).visible = (bg_view == view)
	if previous_view != view:
		_on_view_exited(previous_view)

@warning_ignore("unused_parameter")
func _on_gun_clicked(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		toggle_item("gun")

@warning_ignore("unused_parameter")
func _on_money_clicked(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		toggle_item("money")

@warning_ignore("unused_parameter")
func _on_dealer_clicked(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		match held_item:
			"gun":
				if ammo_current >= 1:
					ammo_current -= 1
				dealer_hp_damage(1)
				
			"money": 
				if current_money >= 2 and not dealer_paid:
					current_money -= 2
					money_sprite_update()
					dealer_paid = true
					slipups -= 1
			"": print("TD")
		play_sound_by_item()

@warning_ignore("unused_parameter")
func _on_shopkeep_clicked(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		match held_item:
			"gun": print("TD")
			"money":
				if current_money >= 1:
					current_money -= 1
					close_shop()
					for slot in ware_slots:
						slot.restock()
					money_sprite_update()
				open_shop()
			"":
				change_shop_state()
		play_sound_by_item()

@warning_ignore("unused_parameter")
func _on_ammo_box_clicked(viewport, event, shape_idx) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		match held_item:
			"gun":
				if ammo_current >= 1:
					ammo_current -= 1
				ammo_box_shot()
			"money":
				if current_money >= 2:
					ammo_current += 1
					current_money -= 2
					money_sprite_update()
				else:
					print("oтдам за 2 зеленых")
			"":
				print("oтдам за 2 зеленых")
		play_sound_by_item()

func _on_ware_slot_clicked(ware: Ware, slot: WareSlot) -> void:
	match held_item:
		"gun":
			if ammo_current >= 1:
				ammo_current -= 1
			slot.buy() #buy simply nulls the ware/drink, so i dont see reason to create func destroy()
			slot.restock()
		"money":
			if current_money >= ware.price:
				current_money -= ware.price
				print("Bought: ", ware.display_name)
				slot.buy()
				slot.restock()
				money_sprite_update()
			else:
				print("Дыра в кармане?")
		"":
			print(ware.description)
	play_sound_by_item()

func _on_drink_slot_clicked(drink: Drink, slot: DrinkSlot) -> void:
	match held_item:
		"gun":
			if ammo_current >= 1:
				ammo_current -= 1
			slot.buy() #buy simply nulls the ware/drink, so i dont see reason to create func destroy()
			slot.restock()
		"money":
			if current_money >= drink.price:
				current_money -= drink.price
				print("Bought: ", drink.display_name)
				slot.buy()
				slot.restock()
				money_sprite_update()
			else:
				print("Дыра в кармане?")
		"":
			print(drink.description)
	play_sound_by_item()
	
func toggle_item(item: String) -> void:
	if held_item == item:
		await _drop_held()
	else:
		if held_item != "":
			await _drop_held()
		await _pick_up(item)
	update_label()

func _pick_up(item: String) -> void:
	match item:
		"gun": await pickup_gun()
		"money":
			if current_money > 0: 
				await pickup_money()

func _drop_held() -> void:
	match held_item:
		"gun": await drop_gun()
		"money": await drop_money()

func update_label() -> void:
	ammo_label.text = "Ammo: %d/%d" % [ammo_current, ammo_max]
	match held_item:
		"gun": held_label.text = "gun"
		"money": held_label.text = "money"
		_: held_label.text = "nothing"

func play_sound_by_item() -> void:
	match held_item:
		"gun":
			sound_gun.play()
		"money":
			sound_money.play()
		_:
			sound_empty.play()
	update_label()

func _on_gun_hover_enter() -> void:
	gun_sprite.scale = Vector2(0.0715, 0.0715)
	gun_sprite.position.y = gun_sprite_base_y - 20
	gun_sprite.modulate = Color(1.2, 1.2, 1.0, gun_sprite.modulate.a)

func _on_gun_hover_exit() -> void:
	gun_sprite.scale = Vector2(0.065, 0.065)
	gun_sprite.position.y = gun_sprite_base_y
	gun_sprite.modulate = Color(1.0, 1.0, 1.0, gun_sprite.modulate.a)

func _on_money_hover_enter() -> void:
	money_sprite.scale = Vector2(1.05, 1.05)
	money_sprite.position.y = money_sprite_base_y - 20
	money_sprite.modulate = Color(1.2, 1.2, 1.0, money_sprite.modulate.a)

func _on_money_hover_exit() -> void:
	money_sprite.scale = Vector2(1, 1)
	money_sprite.position.y = money_sprite_base_y
	money_sprite.modulate = Color(1.0, 1.0, 1.0, money_sprite.modulate.a)

func close_shop() -> void:
	shopkeep_sprite.texture = shopkeep_idle_texture
	for slot in ware_slots:
		slot.consume()
	
func open_shop() -> void:
	shopkeep_sprite.texture = shopkeep_open_texture
	for slot in ware_slots:
		slot.reveal()

func change_shop_state() -> void:
	if shopkeep_sprite.texture == shopkeep_open_texture:
		shopkeep_sprite.texture = shopkeep_idle_texture
		for slot in ware_slots:
			slot.consume()
	else:
		shopkeep_sprite.texture = shopkeep_open_texture
		for slot in ware_slots:
			slot.reveal()

func dealer_hp_damage(amount: int) -> void:
	dealer_hp = max(0, dealer_hp - amount)
	dealer_hp_bar.value = dealer_hp

func pickup_gun() -> void:
	held_item = "gun"
	#pickup_anim.play("pickup")
	#await pickup_anim.animation_finished
	gun_sprite.self_modulate *= 0.6
	#pickup_anim.visible = false

func drop_gun() -> void:
	#pickup_anim.visible = true
	#pickup_anim.play_backwards("pickup")
	#await pickup_anim.animation_finished
	gun_sprite.self_modulate /= 0.6
	held_item = ""
	
func pickup_money() -> void:
	held_item = "money"
	#money_pickup_anim.play("pickup")
	#await money_pickup_anim.animation_finished
	money_sprite.self_modulate *= 0.6
	#money_pickup_anim.visible = false

func drop_money() -> void:
	#money_pickup_anim.visible = true
	#money_pickup_anim.play_backwards("pickup")
	#await money_pickup_anim.animation_finished
	money_sprite.self_modulate /= 0.6
	held_item = ""

func _on_view_exited(view: View) -> void:
	match view:
		View.SHOP: print("TR") #maybe i will change my mind and not close it down, we'll see
	# add more view-exit cases here as other views need teardown too
	
func money_gain() -> void:
	current_money += 1
	money_sprite_update()

func money_sprite_update() -> void:
	match current_money:
		0: money_sprite.texture = zeroD
		1: money_sprite.texture = oneD
		2: money_sprite.texture = twoD
		3: money_sprite.texture = threeD
		_: money_sprite.texture = fourplusD
		
func ammo_box_shot() -> void:
	if not ammo_box_shot_counter:
		ammo_box_sprite.texture = ammo_box_shot_texture
		ammo_box_shot_counter = true
	else:
		print("well that was useless, eh? TR")
