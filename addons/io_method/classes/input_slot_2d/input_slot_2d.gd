tool
extends BaseSlot2D
class_name InputSlot2D, "res://addons/io_method/classes/input_slot_2d/input_slot_2d.png"

export var activation_method:String = "_on_signal_wire_activated"

var connected_outputs:Array = []
var data:Dictionary = { "connected_outputs":[] }
var deffered_signal:Dictionary = {"signal_active":false, "signal_power":1, "force_update":false, "has_triggered":true}
var is_active:bool = false
var is_connected:bool = false
var power:float = 0

func _get_slot_type() -> String:
	return "input"

func _on_connected_to_output( connected_slot:OutputSlot2D ) -> void:
	var slot_path:String = get_data_holder().get_path_to(connected_slot)
	for output in connected_outputs:
		output.disconnect_from_input_slot( self )
	data["connected_outputs"] = []
	data["connected_outputs"].append( slot_path )
	set_data(data)

func _on_disconnected_from_output( connected_slot:OutputSlot2D ) -> void:
	var slot_path:String = get_data_holder().get_path_to(connected_slot)
	if "connected_outputs" in data:
		data["connected_outputs"].erase( slot_path )
	set_data(data)

func _ready() -> void:
	add_to_group( "input_slot_2d" )
#	update_wires_from_meta()
	
	if not Engine.editor_hint:
		yield( get_tree(), "idle_frame" )
		trigger_signal( false, 0, true )

func draw_slot():
	draw_circle( Vector2(0,0), 8, Color(0,0,1) )
	draw_circle( Vector2(0,0), 6, Color(0,0,0) )

func trigger_signal( signal_active:bool, signal_power:float, force_update:bool=false ) -> void:
	#Delay update if has already updated this frame
	if has_updated_in_frame:
		deffered_signal.signal_active = signal_active
		deffered_signal.signal_power = signal_power
		deffered_signal.force_update = force_update
		deffered_signal.has_triggered = false
		return

	is_connected = true
	if get_node("../../../") != null:
		#Upddate only when different
		if signal_power != power or is_active != signal_active or force_update:
			is_active = signal_active
			power = signal_power
			if get_node("../../../").has_method( activation_method ):
				set_has_updated_in_frame( true ) #Must be set before method is called, otherwise will never be set
				get_node("../../../").call(activation_method, is_active, power)
			else:
				printerr("Method " + activation_method + " does not exist in " + get_node("../../../").get_name() + ".")

func set_has_updated_in_frame( value:bool ) -> void:
	has_updated_in_frame = value

	if not has_updated_in_frame and not deffered_signal.has_triggered:
		trigger_signal( deffered_signal.signal_active, deffered_signal.signal_power, deffered_signal.force_update )
		deffered_signal.has_triggered = true
		set_has_updated_in_frame( true )
		
#func update_wires_from_meta() -> void:
#	"""
#	Get wires from data holder's meta
#	"""
#	data = get_data()
#	if not "connected_inputs" in data:
#		data["connected_inputs"] = []
