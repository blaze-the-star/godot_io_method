tool
extends IOMethod2D
class_name BaseSlot2D, "res://addons/io_method/classes/base_slot_2d/base_slot_2d.png"

signal dragged( dragging_slot )

var custom_wires:Dictionary = {} setget set_custom_wires
var previous_global_position:Vector2 = Vector2(0,0)
var wire_generation:Dictionary = {}

var is_drawing:bool = true setget set_is_drawing

func _draw():
	if Engine.editor_hint:
		draw_slot()
		
		for wire_name in custom_wires:
			draw_wire( wire_name )
		
func _on_dragged( dragging_slot ) -> void:
	pass

func _process( delta:float ) -> void:
	#Only called in editor
	
	if previous_global_position != get_global_position():
		previous_global_position = get_global_position()
		emit_signal( "dragged", self )

func _ready():
	add_to_group( "slot_2d" )
	
	if Engine.editor_hint:
		set_process( true )
		connect( "dragged", self, "_on_dragged" )
	else:
		set_process( false )
	
	#Set owner to editing scene
	var scene_child = get_node("../../../../")
	if scene_child != null:
		set_owner( scene_child.get_owner() )
	
func create_wire_curve( begin:Vector2, end:Vector2 ) -> PoolVector2Array: #Overridable
	begin = Vector2( begin.x-get_global_position().x, begin.y-get_global_position().y )
	end = Vector2( end.x-get_global_position().x, end.y-get_global_position().y )

	var curve:Curve2D = Curve2D.new() 
	var point_diff:Vector2 = Vector2(end.x-begin.x, end.y-begin.y )
	curve.set_bake_interval( 16 )#point_diff.length()/20 )

	#Begin point weight
	var begin_weight:Vector2 = Vector2(0,0)
	if abs(point_diff.x) > abs(point_diff.y):
		begin_weight.x = point_diff.x/4
	else:
		begin_weight.y = point_diff.y/4
	#Add begin point to curve
	curve.add_point( begin, begin_weight, begin_weight )

	#End point weight
	var end_weight:Vector2 = Vector2(0,0)
	if abs(point_diff.x) > abs(point_diff.y):
		end_weight.x = -point_diff.x/4
	else:
		end_weight.y = -point_diff.y/4
	#Add end point to curve
	curve.add_point( end, end_weight, end_weight )

	return curve.get_baked_points()

func draw_slot() -> void: #Overridable
	draw_circle( Vector2(0,0), 8, Color(1,1,1) )
	
func draw_wire( wire_name ) -> void: #Overridable
	if wire_name in custom_wires:
		var wire_info:Dictionary = custom_wires[wire_name]
		if wire_name in wire_generation:
			draw_polyline( wire_generation[wire_name], Color(1,0,0,.5), 2 )
			#Draw dot at end of line
			var dot_pos:Vector2 = wire_info["end"]
			dot_pos.x -= get_global_position().x
			dot_pos.y -= get_global_position().y
			draw_circle( dot_pos, 3, Color(1,0,0) )
	
func generate_wire( wire_name, render_on_completion:bool=true ) -> void:
	if wire_name in custom_wires:
		var wire_info:Dictionary = custom_wires[wire_name]
		wire_generation[wire_name] = create_wire_curve( wire_info["begin"], wire_info["end"] )
		if render_on_completion:
			update()
	
func re_rig_wire( wire_path ) -> bool:
	"""
	Rigs wire points to wire's begin_node and end_nodes (Returns if changed)
	"""
	var wire_info:Dictionary = custom_wires[wire_path]
	var is_changed:bool = false
	if "begin" in wire_info and "begin_node" in wire_info:
		var begin_node:Node = get_node(wire_info["begin_node"])
		if wire_info["begin"] != begin_node.get_global_position():
			wire_info["begin"] = begin_node.get_global_position()
			is_changed = true
	if "end" in wire_info and "end_node" in wire_info:
		var end_node:Node = get_node(wire_info["end_node"])
		if wire_info["end"] != end_node.get_global_position():
			wire_info["end"] = end_node.get_global_position()
			is_changed = true

	set_custom_wires( custom_wires )
	#Generate new wire
	generate_wire( wire_path )
			
	return is_changed
	
func set_custom_wires( value:Dictionary ) -> void:
	custom_wires = value
	
func set_is_drawing( value:bool ) -> void:
	is_drawing = value
	update()
	
func is_a_signals_connected( signal_array:Array, connected_to:Node, method:String ) -> bool:
	for signal_info in signal_array:
		if method == signal_info["method"] and signal_info["target"] == connected_to:
			return true
			
	return false
			