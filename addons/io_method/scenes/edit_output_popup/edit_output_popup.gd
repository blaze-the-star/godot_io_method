tool
extends WindowDialog
#
export(Resource) var editing_output

func _ready():
	#Create signals list
	var signal_list:Array = []
	for signal_dict in editing_output.get_node("../../../").get_signal_list():
		signal_list.append( signal_dict.name )
	signal_list.sort()
		
	#Add items
	var signal_word_category:String = ""
	for signal_name in signal_list:
#		var first_word:String = signal_name.split("_")[0]
#		if signal_word_category != "" and signal_word_category != first_word:
#			$SignalOptions.add_separator()
#		signal_word_category = first_word
			
		$SignalOptions.add_item( signal_name )
		
	#Set initially selected
	for id in range($SignalOptions.get_item_count()):
		if editing_output.activation_signal == $SignalOptions.get_item_text(id):
			$SignalOptions.select(id)
			break

func _on_OkButton_pressed():
	call_deferred("hide")
	call_deferred("queue_free")
	
func _on_OptionButton_item_selected( id:int ):
	editing_output.activation_signal = $SignalOptions.get_item_text(id)