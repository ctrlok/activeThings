use framework "Foundation"

tell application "Things3"
    set todoList to {}
    repeat with inboxToDo in to dos of list "Today"
        if status of inboxToDo is not completed then
            set areaName to "No Areas"
            if area of inboxToDo exists then
                set areaName to name of area of inboxToDo
            end if
            set todoRecord to {recordID:id of inboxToDo, RecordName:name of inboxToDo, areaName:areaName}
            copy todoRecord to the end of todoList
        end if
    end repeat
    set myObject to todoList
    
    set jsonString to current application's NSJSONSerialization's dataWithJSONObject:myObject options:0 |error|:(missing value)
    set jsonString to current application's NSString's alloc()'s initWithData:jsonString encoding:(current application's NSUTF8StringEncoding)
    set jsonString to jsonString as text
    return jsonString
end tell
