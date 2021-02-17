xquery version "3.1";
(:
 : author @sardinecan
 : 2021-02-17
 : this script adds maintenance event and convert eventDate to xsd:dateTime
 : just run it !
:)
declare default element namespace "eac" ;

(:
 : path to xprdata files
 : @rmq to be modified for online/local use
 : @sardinecan : /Volumes/data/github/xprdata/
 : @huma-num : /sites/expertdb/resource/data/
:)
declare variable $path := '/Volumes/data/github/xprdata/';



(:
 : @return updated xml files with xsd:dateTime event
:)
declare function local:updateProsopoDateTime() {
let $collection := fn:collection($path || 'prosopography/')
return
    for $doc at $i in $collection
    where matches(document-uri($doc), '.xml')
    return (
        copy $d := $doc
        modify (
            for $history in $d//control/maintenanceHistory[maintenanceEvent/eventDateTime[not(@standardDateTime castable as xs:dateTime)]]
            let $maintenance := local:maintenanceEvent($history)
            return replace node $history with $maintenance
        )
        return(
            file:create-dir($path || 'temp'),
            file:create-dir($path || 'temp/prosopography'),
            file:write($path || 'temp/prosopography/' || substring-after(document-uri($doc), 'prosopography/'), $d)
        )
    )
};

(: this function adds maintenance events
 : @return modified maintenance history for expertise
 :)
declare function local:maintenanceEvent($maintenance) {
copy $d := $maintenance
modify (
    insert node $event as first into $d
)
return local:date2dateTime($d)
};

(:
 :
 :)
declare function local:date2dateTime($maintenance) {
  copy $d := $maintenance
  modify (
    for $eventDate in $d/maintenanceEvent/eventDateTime[not(@standardDateTime castable as xs:dateTime)]
    let $date := $eventDate/@standardDateTime
    let $dateTime :=
      if($date castable as xs:gYear) then $date || '-01-01T12:00:00+01:00'
      else if($date castable as xs:gYearMonth) then $date || '-01T12:00:00+01:00'
      else if($date castable as xs:date) then $date || 'T12:00:00+01:00'
      else if($date = '2018/2019') then '2018-05-29T12:00:00+01:00'
    return (
      replace value of node $eventDate with $dateTime,
      replace value of node $eventDate/@standardDateTime with $dateTime))
  return $d
};


declare variable $event :=
<maintenanceEvent>
    <eventType>updated</eventType>
    <eventDateTime standardDateTime="{fn:current-dateTime()}">{fn:current-dateTime()}</eventDateTime>
    <agentType>machine</agentType>
    <agent>updateMaintenanceDateTime.xqy/BaseX</agent>
    <eventDescription>Conversion des dates de révision des fiches prosopographiques au format xsd:dateTime.</eventDescription>
</maintenanceEvent>;

local:updateProsopoDateTime()