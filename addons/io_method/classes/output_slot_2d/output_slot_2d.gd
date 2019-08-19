tool
extends BaseSlot2D
class_name OutputSlot2D, "res://addons/io_method/classes/output_slot_2d/output_slot_2d.png"

export var activation_signal:String = "activate_output"
export var deactivation_signal:String = "deactivate_output"

#export var connected_input_slots:Array = []
var is_active:bool = true
var sent_initial_signal:bool = false

func _on_dragged( dragged_slot ) -> void:
	var path_to_dragged:NodePath = get_path_to(dragged_slot)
	#Self dragged
	if dragged_slot == self:
		for wire_name in custom_wires:
			var wire_info:Dictionary = custom_wires[wire_name]
			if "begin" in wire_info and "end" in wire_info:
				var wire_position_changed:bool = re_rig_wire( wire_name )
		update()
		
	
func _on_input_slot_dragged( dragged_slot ) -> void:
	var path_to_dragged:NodePath = get_path_to(dragged_slot)
	if get_connected_inputs().has( path_to_dragged ):
		re_rig_wire( path_to_dragged )

func _ready():
	._ready()
	set_z_index(1)
	add_to_group( "output_slot_2d" )
	
	if not Engine.editor_hint:
#		call_deferred("set_is_active", 0 , true)
		get_node("../../../").connect( activation_signal, self, "set_is_active" )
		
	else:
		update_wires_from_meta()
		connect( "script_changed", self, "_on_script_changed" )
		
	if not Engine.editor_hint:
		if not sent_initial_signal:
			call_deferred("set_is_active", 0 , true)
	
func _on_input_slot_moved( wire_key ) -> void:
	if wire_key in custom_wires:
		var input_position_changed:bool = re_rig_wire( wire_key )
		if input_position_changed:
			update()
	
func _on_script_changed() -> void:
	update_wires_from_meta()
	print("cha")
	
func connect_to_input_slot( slot ) -> void:
	var slot_path:NodePath = get_path_to(slot)
	var connected_input_slots:Array = get_connected_inputs()
	if not connected_input_slots.has(slot_path):
		connected_input_slots.append( slot_path )
		set_connected_inputs( connected_input_slots )
		#Draw wire
		custom_wires[ get_path_to(slot) ] = {"begin":get_global_position(), "end":slot.get_global_position(), "begin_node":get_path(), "end_node":slot_path}
		slot.connect( "dragged", self, "_on_input_slot_dragged" )
		generate_wire( slot_path )
		
		slot._on_connected_to_output( self )
	
func disconnect_all_input_slots() -> void:
	custom_wires = {}
	set_connected_inputs( [] )
	update()
	
func disconnect_from_input_slot( slot ) -> void:
	var connected_input_slots:Array = get_connected_inputs()
	if  connected_input_slots.has( get_path_to(slot) ):
		connected_input_slots.erase( get_path_to(slot) )
		set_connected_inputs( connected_input_slots )
		#Draw wire
		custom_wires.erase( get_path_to(slot) )
		slot.disconnect( "dragged", self, "_on_input_slot_dragged" )
		update()
		
		slot._on_connected_to_output( self )
	
func draw_slot() -> void:
	draw_circle( Vector2(0,0), 8, Color(1,0,0) )
	draw_circle( Vector2(0,0), 6, Color(0,0,0) )
	draw_circle( Vector2(0,0), 3, Color(1,0,0) )
	
func get_connected_inputs() -> Array:
	var owner_node:Node = get_node("../../../../")
	if is_instance_valid(owner_node) and owner_node.has_meta( get_meta_key("connected_inputs") ):
		return owner_node.get_meta( get_meta_key("connected_inputs") )
		
	return []
	
func get_meta_key( meta_name:String ) -> String:
	"""
	Get the meta name for the inputed variable
	"""
	var parent_owner = get_node("../../../../")
	if is_instance_valid( parent_owner ):
		return str( parent_owner.get_path_to(self) ) + "." + meta_name
	return meta_name
	
func remove_connected_inputs_data() -> void:
	"""
	Removes the connected inputs meta data from the ResponseWire's parent's owner
	"""
	var owner_node:Node = get_node("../../../../")
	if is_instance_valid(owner_node):
		owner_node.set_meta( get_meta_key("connected_inputs"), null )
	
func set_connected_inputs( value:Array ) -> void:
	var owner_node:Node = get_node("../../../../")
	if is_instance_valid(owner_node):
		owner_node.set_meta( get_meta_key("connected_inputs"), value )
	
func set_is_active( value:float, force_update:bool=false ) -> void:
	if force_update and sent_initial_signal:
		sent_initial_signal = true
		return
	else:
		sent_initial_signal = true
		
	if abs(value) >= .5:
		is_active = true
	else:
		is_active = false
		
	var connected_input_slots:Array = get_connected_inputs()
	for slot in connected_input_slots:
		if has_node(slot):
			get_node(slot).trigger_signal( is_active, value, force_update )
			
func update_wires_from_meta() -> void:
	"""
	Redraw wires using data from IOHub2D's parent
	"""
	var connected_input_slots:Array = get_connected_inputs()
	for slot_path in connected_input_slots:
		custom_wires[slot_path] = {"begin":get_global_position(), "end":get_node(slot_path).get_global_position()}
		generate_wire( slot_path, false )
	update()