tool
extends BaseSlot2D
class_name InputSlot2D, "res://addons/io_method/classes/input_slot_2d/input_slot_2d.png"

export var activation_method:String = "_on_signal_wire_activated"
export var deactivation_method:String = "_on_signal_wire_deactivated"
var connected_outputs:Array = []
var is_active:bool = false
var power:float = 0

func _on_connected_to_output( connected_slot:OutputSlot2D ) -> void:
	connected_outputs.append( connected_slot )
	for output in connected_outputs:
		if output != connected_slot:
			output.disconnect_from_input_slot( self )

func _on_disconnected_from_output( connected_slot:OutputSlot2D ) -> void:
	connected_outputs.erase( connected_slot )

#func _on_dragged( dragging_slot ) -> void:
#	pass

func _ready() -> void:
	add_to_group( "input_slot_2d" )

func draw_slot():
	draw_circle( Vector2(0,0), 8, Color(0,0,1) )
	draw_circle( Vector2(0,0), 6, Color(0,0,0) )

func trigger_signal( signal_active:bool, signal_power:float, force_update:bool=false ) -> void:
#	prints( "inp", get_node("../../../").name, signal_power )
	if get_node("../../../") != null:
		#Upddate only when different
		if signal_power != power or is_active != signal_active or force_update:
			is_active = signal_active
			power = signal_power
			if get_node("../../../").has_method( activation_method ):
				get_node("../../../").call(activation_method, is_active, power)
			else:
				printerr("Method " + activation_method + " does not exist in " + get_node("../../../").get_name() + ".")
		
#		elif is_active and not signal_active:
#			is_active = false
#			if get_node("../../../").has_method( deactivation_method ):
#				get_node("../../../").call( deactivation_method, is_active, power )
#			else:
#				printerr("Method " + deactivation_method + " does not exist in " + get_node("../../../").get_name() + ".")