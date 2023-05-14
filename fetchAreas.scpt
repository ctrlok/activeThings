use AppleScript version "2.4"
use scripting additions
use framework "Foundation"

on fetchAreas()
    set areasList to {}
    tell application "Things3"
        repeat with ar in areas
            set areaID to id of ar
            set areaName to name of ar
            set areaDict to {|AreaID|:areaID, |AreaName|:areaName}
            set end of areasList to areaDict
        end repeat
    end tell
    return areasList
end fetchAreas

set areasList to fetchAreas()

if length of areasList > 0 then
    set myObject to areasList
    
    set jsonString to current application's NSJSONSerialization's dataWithJSONObject:myObject options:0 |error|:(missing value)
    set jsonString to current application's NSString's alloc()'s initWithData:jsonString encoding:(current application's NSUTF8StringEncoding)
    set jsonString to jsonString as text
    return jsonString
else
    return "No Areas"
end if
