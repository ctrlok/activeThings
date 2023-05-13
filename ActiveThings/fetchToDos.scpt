use framework "Foundation"

tell application "Things3"
    set todoList to {}
    repeat with inboxToDo in to dos of list "Today"
        set todoRecord to {recordID:id of inboxToDo, RecordName:name of inboxToDo}
        copy todoRecord to the end of todoList
    end repeat
    if length of todoList > 0 then
        set firstToDo to item 1 of todoList
        set myObject to firstToDo
        
        set jsonString to current application's NSJSONSerialization's dataWithJSONObject:myObject options:0 |error|:(missing value)
        set jsonString to current application's NSString's alloc()'s initWithData:jsonString encoding:(current application's NSUTF8StringEncoding)
        set jsonString to jsonString as text
        return jsonString
    else
        return "No To-Dos"
    end if
end tell
