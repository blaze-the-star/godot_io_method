tool
extends EditorPlugin

enum EDIT_ACTIONS {
	NONE
	MOVE
	CONNECT_WIRE_FROM_OUTPUT
}

enum EDIT_MODES {
	NONE
	EDIT_SLOTS
	CONNECT_SIGNAL
	REMOVE_SIGNAL
}

enum SLOT_TYPES {
	OUTPUT
	INPUT
}

var edit_action:int = 0
var edit_mode:int = EDIT_MODES.EDIT_SLOTS
var is_editing:bool = true setget set_is_editing
var is_mouse_over_slot:bool = false
var placing_slot_type = SLOT_TYPES.OUTPUT
var io_method:Array = []

var selected_node:Node
var selected_response_wire:Node
var selected_slot:Node

#Tool bar
var editing_mode_button:Node = preload("res://addons/io_method/scenes/edit_mode_button/edit_mode_button.tscn").instance()
var toggle_placing_slot_type:Node = preload("res://addons/io_method/scenes/toggle_placing_slot_type/toggle_placing_slot_type.tscn").instance()

#Nodes
var popup_menu

func _enter_tree():
	add_control_to_container( CONTAINER_CANVAS_EDITOR_MENU, editing_mode_button )
	editing_mode_button.connect( "toggled", self, "set_is_editing" )
	editing_mode_button.hide()
	
	add_control_to_container( CONTAINER_CANVAS_EDITOR_MENU, toggle_placing_slot_type )
	toggle_placing_slot_type.connect( "toggled", self, "_on_toggle_placing_slot_type" )
	toggle_placing_slot_type.hide()

func _exit_tree():
	remove_control_from_container( CONTAINER_CANVAS_EDITOR_MENU, editing_mode_button )
	remove_control_from_container( CONTAINER_CANVAS_EDITOR_MENU, toggle_placing_slot_type )
	pass
	
func _on_toggle_placing_slot_type( toggled_on:bool ) -> void:
	if not toggled_on:
		placing_slot_type = SLOT_TYPES.OUTPUT
	else:
		placing_slot_type = SLOT_TYPES.INPUT
	
func forward_canvas_gui_input( event:InputEvent ) -> bool:
	if selected_response_wire != null:
		#Edit slots
		if is_editing:
			return handle_input_edit_mode( event )
		#Wire manipulation
		return handle_input_wire_mode( event )
			
	return false
	
func handle_input_edit_mode( event:InputEvent ) -> bool:
	"""
	Handle inputs for editing slots
	"""
	if event is InputEventMouseButton:
		var mouse_pos:Vector2 = selected_response_wire.get_global_mouse_position()
		var slot_within_range = selected_response_wire.get_slots_within_range( mouse_pos )
		
		match edit_action:
			EDIT_ACTIONS.NONE:
				#Double click to edit slot
				if event.get_button_index() == BUTTON_LEFT and event.is_doubleclick():
					if slot_within_range is OutputSlot2D:
						open_edit_output_menu( slot_within_range )
					if slot_within_range is InputSlot2D:
						open_edit_input_menu( slot_within_range )
					
				#Single Pressed
				elif event.is_pressed():
					#Left clicked
					if event.get_button_index() == BUTTON_LEFT:
						
						#Add output slot
						if slot_within_range == null:
							if placing_slot_type == SLOT_TYPES.OUTPUT:
								selected_response_wire.add_output( mouse_pos.snapped(Vector2(10,10)) )
							elif placing_slot_type == SLOT_TYPES.INPUT:
								selected_response_wire.add_input( mouse_pos.snapped(Vector2(10,10)) )
						#Begin moving
						else:
							selected_slot = slot_within_range
							edit_action = EDIT_ACTIONS.MOVE
								
						return true
							
					#Right clicked
					if event.get_button_index() == BUTTON_RIGHT and slot_within_range != null:
						#Delete output slot
						selected_response_wire.remove_slot( slot_within_range )
				
						return true
			
			EDIT_ACTIONS.MOVE:
				#Left button
				if event.get_button_index() == BUTTON_LEFT:
					#Left button not clicked
					if not event.is_pressed():
						edit_action = EDIT_ACTIONS.NONE
						return true
				
	#Mouse motion
	elif event is InputEventMouseMotion:
		var mouse_pos:Vector2 = selected_response_wire.get_global_mouse_position()
		var slot_within_range = selected_response_wire.get_slots_within_range( mouse_pos )
		
		match edit_action:
			EDIT_ACTIONS.MOVE:
				#Drag slot
				if is_instance_valid(selected_slot):
					var move_to_pos:Vector2 = Vector2(0,0)
					move_to_pos.x = mouse_pos.x
					move_to_pos.y = mouse_pos.y
					selected_slot.set_global_position( move_to_pos.snapped(Vector2(10,10)) )
					selected_slot.call_deferred( "emit_signal", "dragged", selected_slot )
				else:
					edit_action = EDIT_ACTIONS.NONE
				
				return true
		
	return false
	
func handle_input_wire_mode( event:InputEvent ) -> bool:
	if event is InputEventMouseButton:
		var mouse_pos:Vector2 = selected_response_wire.get_global_mouse_position()
		var slot_within_range = selected_response_wire.get_slots_within_range( mouse_pos )
		
		match edit_action:
			EDIT_ACTIONS.NONE:
				#Single Pressed
				if event.is_pressed():
					#Left click
					if event.get_button_index() == BUTTON_LEFT:
						#Start connecting
						if slot_within_range is OutputSlot2D:
							selected_slot = slot_within_range
							edit_action = EDIT_ACTIONS.CONNECT_WIRE_FROM_OUTPUT
							return true
					
			EDIT_ACTIONS.CONNECT_WIRE_FROM_OUTPUT:
				#Single Pressed
				if event.is_pressed():
					#Left click
					if event.get_button_index() == BUTTON_LEFT:
						#Find clicked input slot in any IOHub2D
						var input_slot_owner = null
						var clicked_input = null
						for response_wire_2d in get_editor_interface().get_edited_scene_root().get_tree().get_nodes_in_group("response_wire_2d"):
							clicked_input = response_wire_2d.get_input_within_range( mouse_pos )
							if clicked_input != null:
								input_slot_owner = response_wire_2d
								break
								
						#Connect output wire to clicked InputSlot2D
						selected_slot.connect_to_input_slot( clicked_input )
						if "plugin_dragging" in selected_slot.custom_wires:
							selected_slot.custom_wires.erase("plugin_dragging")
								
						return true
							
					#Right click
					if event.get_button_index() == BUTTON_RIGHT:
						edit_action = EDIT_ACTIONS.NONE
						if "plugin_dragging" in selected_slot.custom_wires:
								selected_slot.custom_wires.erase("plugin_dragging")
								selected_slot.update()
								
						return true
					
	#Mouse motion
	elif event is InputEventMouseMotion:
		var mouse_pos:Vector2 = selected_response_wire.get_global_mouse_position()
		
		match edit_action:
			EDIT_ACTIONS.CONNECT_WIRE_FROM_OUTPUT:
				if selected_slot is OutputSlot2D:
					selected_slot.custom_wires["plugin_dragging"] = {"begin":selected_slot.get_global_position(), "end":mouse_pos}
					selected_slot.generate_wire( "plugin_dragging" )
					
					
	return false
	
func handles( object ) -> bool:
	if object.has_method("get_children"):
		for child in object.get_children():
			if child is IOHub2D:
				on_focus_entered_response_wire_parent( object, child )
				return true
				
		on_focus_left_response_wire_parent( object )
	
	return false
	
func on_focus_entered_response_wire_parent( parent:Node, response_wire:IOHub2D ) -> void:
	selected_node = parent
	selected_response_wire = response_wire
	for slot in selected_node.get_tree().get_nodes_in_group("slot_2d"):
		slot.is_drawing = true
		
	editing_mode_button.show()
	toggle_placing_slot_type.show()
	
func on_focus_left_response_wire_parent( selected_node:Node ) -> void:
#	if selected_response_wire == null:
	for output in selected_node.get_tree().get_nodes_in_group("slot_2d"):
		output.is_drawing = false
		
	editing_mode_button.hide()
	toggle_placing_slot_type.hide()
	
	selected_response_wire = null
	
func open_edit_input_menu( editing_input_slot ) -> void:
	var editor_control:Control = get_editor_interface().get_base_control()
	var edior_size = editor_control.get_size()
	
	popup_menu = load("res://addons/io_method/scenes/edit_input_popup/edit_input_popup.tscn").instance()
	var popup_pos:Vector2 = Vector2(0,0)
	popup_pos.x = (edior_size.x/2)-(popup_menu.get_size().x/2)
	popup_pos.y = (edior_size.y/2)-(popup_menu.get_size().y/2)
	popup_menu.set_position( popup_pos )
	popup_menu.editing_input = editing_input_slot
	
	editor_control.add_child( popup_menu )
	popup_menu.popup()
	
func open_edit_output_menu( editing_output_slot ) -> void:
	var editor_control:Control = get_editor_interface().get_base_control()
	var edior_size = editor_control.get_size()
	
	popup_menu = load("res://addons/io_method/scenes/edit_output_popup/edit_output_popup.tscn").instance()
	var popup_pos:Vector2 = Vector2(0,0)
	popup_pos.x = (edior_size.x/2)-(popup_menu.get_size().x/2)
	popup_pos.y = (edior_size.y/2)-(popup_menu.get_size().y/2)
	popup_menu.set_position( popup_pos )
	popup_menu.editing_output = editing_output_slot
	
	editor_control.add_child( popup_menu )
	popup_menu.popup()
	
func set_is_editing( value:bool ) -> void:
	is_editing = value
	edit_mode = 0
