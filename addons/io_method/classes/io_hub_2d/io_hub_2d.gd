tool
extends IOMethod2D
class_name IOHub2D, "res://addons/io_method/classes/io_hub_2d/io_hub_2d.png"

const CONNECTION_SIZE_RADIUS:int =  8

#export var inputs:Array = [] setget set_inputs
#export var outputs:Array = [] setget set_outputs

#Container nodes
var inputs_container:Node2D
var outputs_container:Node2D

func _enter_tree():
	print("enter")
	
func _exit_tree():
	print("exit")

func _ready():
	call_deferred( "initialise_inputs_container" )
	call_deferred( "initialise_outputs_container" )
	
	if Engine.editor_hint:
		add_to_group( "io_hub_2d" )
	
func add_input( slot_position ):
	var new_input = InputSlot2D.new()
	new_input.set_name( "Input" ) 

	new_input.set_owner( get_inputs_container().get_owner() )
	get_inputs_container().add_child(new_input)
	new_input.set_owner( get_inputs_container().get_owner() )

	new_input.set_global_position(slot_position)
	
func add_output( slot_position ):
	initialise_outputs_container()
	var new_output = OutputSlot2D.new()
	new_output.set_name( "Output" ) 
	
	new_output.set_owner( get_outputs_container().get_owner() )
	get_outputs_container().add_child(new_output)
	new_output.set_owner( get_outputs_container().get_owner() )
	
	new_output.set_global_position(slot_position)
	
func get_input_within_range( point:Vector2 ) -> InputSlot2D:
	for slot in get_inputs_container().get_children():
		if slot is InputSlot2D:
			var slot_pos_glb:Vector2 = slot.get_global_position()
			if slot_pos_glb.distance_to( point ) < CONNECTION_SIZE_RADIUS:
				return slot

	return null
	
func get_inputs_container() -> Node2D:
	if inputs_container == null:
		initialise_inputs_container()
		
	return inputs_container
	
func get_output_within_range( point:Vector2 ) -> OutputSlot2D:
	for output in get_outputs_container().get_children():
		if output is OutputSlot2D:
			var output_pos_glb:Vector2 = output.get_global_position()
			if output_pos_glb.distance_to( point ) < CONNECTION_SIZE_RADIUS:
				return output
			
	return null
	
func get_outputs_container() -> Node2D:
	if outputs_container == null:
		initialise_outputs_container()
		
	return outputs_container
	
func get_slot_within_range( point:Vector2 ):
	"""
	Returns the output that is within range of point (For getting of clicked on)
	"""
	var return_slot = null
	return_slot = get_output_within_range( point )
	
	if return_slot == null:
		return_slot = get_input_within_range( point )
			
	return return_slot
	
func initialise_inputs_container():
	if has_node("Inputs"):
		inputs_container = get_node("Inputs")
	elif not is_instance_valid(inputs_container):
		inputs_container = Node2D.new()
		inputs_container.set_name( "Inputs" )
		add_child( inputs_container )
		inputs_container.set_owner( get_owner() )
		
func initialise_outputs_container():
	if has_node("Outputs"):
		outputs_container = get_node("Outputs")
	elif not is_instance_valid(outputs_container):
		outputs_container = Node2D.new()
		outputs_container.set_name( "Outputs" )
		add_child( outputs_container )
		outputs_container.set_owner( get_owner() )
	
func remove_slot( slot ) -> void:
	if slot is InputSlot2D and get_inputs_container().get_children().has(slot):
		slot.queue_free()
	if slot is OutputSlot2D and get_outputs_container().get_children().has(slot):
		slot.queue_free()
		
		
		
		
		