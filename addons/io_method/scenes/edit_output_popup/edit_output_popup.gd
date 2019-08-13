tool
extends WindowDialog
#
export(Resource) var editing_output setget set_editing_output, get_editing_output

func _ready():
	if editing_output is OutputSlot2D:
		$TextEdit.set_text( editing_output.activation_signal )
		$TextEdit2.set_text( editing_output.deactivation_signal )
		
	for signal_name in editing_output.get_node("../../../").get_signal_list():
		pass

func _on_TextEdit_text_changed( new_text:String ) -> void:
	if editing_output is OutputSlot2D:
		editing_output.activation_signal = new_text

func _on_TextEdit2_text_changed( new_text:String ) -> void:
	if editing_output is OutputSlot2D:
		editing_output.deactivation_signal = new_text

func get_editing_output() -> Node2D:
	return editing_output

func set_editing_output( value:Node2D ) -> void:
	editing_output = value

func _on_OkButton_pressed():
	call_deferred("hide")
	call_deferred("queue_free")