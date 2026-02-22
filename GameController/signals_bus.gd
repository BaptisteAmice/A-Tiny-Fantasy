extends Node
class_name SignalsBus 

signal POST_COMMAND(command: Command)


##### Game chat

## Add a message to the displayed list
signal ADD_MESSAGE_TO_DISPLAY_LIST(message: String)
## Open the game chat
signal OPEN_GAME_CHAT()
## Close the game chat
signal EXIT_GAME_CHAT()
signal GO_TO_NEXT_GAME_CHAT_MESSAGE_IN_HISTORY()
signal GO_TO_PREVIOUS_GAME_CHAT_MESSAGE_IN_HISTORY()
## Set the value in the chat input
signal SET_GAME_CHAT_INPUT(message: String)
