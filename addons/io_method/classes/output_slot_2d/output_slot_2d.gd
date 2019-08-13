tool
extends BaseSlot2D
class_name OutputSlot2D, "res://addons/io_method/classes/output_slot_2d/output_slot_2d.png"

export var activation_signal:String = "activate_output"
export var deactivation_signal:String = "deactivate_output"

#export var connected_input_slots:Array = []
var is_active:bool = false

func _exit_tree():
	remove_connected_inputs_data()

func _ready():
	._ready()
	set_z_index(1)
	add_to_group( "output_slot_2d" )
	
	if not Engine.editor_hint:
		get_node("../../../").connect( activation_signal, self, "set_is_active", [true] )
		get_node("../../../").connect( deactivation_signal, self, "set_is_active", [false] )
		
	else:
		#Render wires
		var connected_input_slots:Array = get_connected_inputs()
		for slot_path in connected_input_slots:
			var slot_node = get_node(slot_path)
			custom_wires[slot_node] = {"begin":get_global_position(), "end":slot_node.get_global_position()}
			generate_wire( slot_node, false )
		update()
	
func _on_input_slot_moved( wire_key ) -> void:
	if wire_key in custom_wires:
		var input_position_changed:bool = re_rig_wire( wire_key )
		if input_position_changed:
			update()
	
func connect_to_input_slot( slot:InputSlot2D ) -> void:
	var connected_input_slots:Array = get_connected_inputs()
	if not connected_input_slots.has(slot):
		connected_input_slots.append( get_path_to(slot) )
		set_connected_inputs( connected_input_slots )
		custom_wires[slot] = {"begin":get_global_position(), "end":slot.get_global_position(), "begin_node":get_path(), "end_node":slot.get_path()}
		slot.connect( "dragged", self, "_on_input_slot_moved" )
		generate_wire( slot )
	
func draw_slot() -> void:
	draw_circle( Vector2(0,0), 8, Color(1,0,0) )
	draw_circle( Vector2(0,0), 6, Color(0,0,0) )
	draw_circle( Vector2(0,0), 3, Color(1,0,0) )
	
func get_connected_inputs() -> Array:
	var owner_node:Node = get_node("../../../").get_owner()
	if is_instance_valid(owner_node) and owner_node.has_meta( get_meta_key("connected_inputs") ):
		return owner_node.get_meta( get_meta_key("connected_inputs") )
		
	return []
	
func get_meta_key( meta_name:String ) -> String:
	"""
	Get the meta name for the inputed variable
	"""
	var parent_owner = get_node("../../../").get_owner()
	if is_instance_valid( parent_owner ):
		return str( parent_owner.get_path_to(self) ) + "." + meta_name
	return meta_name
	
func remove_connected_inputs_data() -> void:
	"""
	Removes the connected inputs meta data from the ResponseWire's parent's owner
	"""
	var owner_node:Node = get_node("../../../").get_owner()
	if is_instance_valid(owner_node):
		owner_node.set_meta( get_meta_key("connected_inputs"), null )
	
func set_connected_inputs( value:Array ) -> void:
	var owner_node:Node = get_node("../../../").get_owner()
	if is_instance_valid(owner_node):
		owner_node.set_meta( get_meta_key("connected_inputs"), value )
	
func set_is_active( value:bool ) -> void:
	is_active = value
	var connected_input_slots:Array = get_connected_inputs()
	prints("act", value, connected_input_slots)
	
	if is_active:
		for slot in connected_input_slots:
			prints("look", slot)
			if has_node(slot):
				print("send")
				get_node(slot).trigger_signal()
	else:
		for slot in connected_input_slots:
			if has_node(slot):
				get_node(slot).kill_signal()