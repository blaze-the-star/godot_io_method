tool
extends BaseSlot2D
class_name InputSlot2D, "res://addons/io_method/classes/input_slot_2d/input_slot_2d.png"

export var activation_method:String = "_on_signal_wire_activated"
export var deactivation_method:String = "_on_signal_wire_deactivated"
var is_active:bool = false

func _on_dragged( dragging_slot ) -> void:
	pass

func _ready() -> void:
	add_to_group( "input_slot_2d" )

func draw_slot():
	draw_circle( Vector2(0,0), 8, Color(0,0,1) )
	draw_circle( Vector2(0,0), 6, Color(0,0,0) )

func trigger_signal() -> void:
	if not is_active and get_node("../../../") != null:
		is_active = true
		get_node("../../../").call(activation_method)
			
func kill_signal() -> void:
	if is_active:
		is_active = false
		get_node("../../../").call(deactivation_method)