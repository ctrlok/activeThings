#!/bin/sh

#  fetchToDos.scpt
#  ActiveThings
#
#  Created by Seva Poliakov on 13.05.2023.
#  


tell application "Things3"
    set todoList to {}
    repeat with inboxToDo in to dos of list "Today"
        copy name of inboxToDo to the end of todoList
    end repeat
    if length of todoList > 0 then
        return item 1 of todoList
    else
        return "No To-Dos"
    end if
end tell
