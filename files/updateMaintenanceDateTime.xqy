xquery version "3.1";
(:
 : author @emchateau & @sardinecan
 : 2020-12
 : this script adds missing nodes into expertises addresses and adds maintenance event
 : just run it !
:)
declare default element namespace "xpr" ;

(:
 : path to xprdata files
 : @rmq to be modified for online/local use
 : @sardinecan : /Volumes/data/github/xprdata/
 : @huma-num : /sites/expertdb/resource/data/
:)
declare variable $path := '/Volumes/data/github/xprdata/';



(:
 : this function adds missing nodes into expertises addresses
 : @return updated xml files
:)
declare function local:updateExpertisesDateTime() {
let $collection := fn:collection($path || 'z1j/')
return
    for $doc at $i in $collection
    where matches(document-uri($doc), '.xml')
    return (
        copy $d := $doc
        modify (
            for $history in $d//expertises/expertise/control/maintenanceHistory[maintenanceEvent/eventDateTime[not(@standardDateTime castable as xs:dateTime)]]
            let $maintenance := local:maintenanceEvent($history)
            return replace node $history with $maintenance
        )
        return(
            file:create-dir($path || 'temp'),
            file:create-dir($path || 'temp/z1j'),
            file:write($path || 'temp/z1j/' || substring-after(document-uri($doc), 'z1j/'), $d)
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
      if($date castable as xs:gYear) then
      switch  ($date/ancestor::maintenanceEvent/agent)
        case 'JH' return '2017-10-01T12:00:00'
        case 'PC' return '2018-01-01T12:00:00'
        case 'LL' return '2017-04-01T12:00:00'
        case 'RB' return '2016-10-26T12:00:00'
        default return $date || '-01-01T12:00:00'
      else if($date castable as xs:gYearMonth) then $date || '-01T12:00:00'
      else if($date castable as xs:date) then $date || 'T12:00:00'
      else if($date = '2016/2017') then '2016-07-29T12:00:00'
      else if($date = '2018/2019') then '2018-05-29T12:00:00'
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
    <eventDescription>Conversion des dates de révision des fiches au format xsd:dateTime.</eventDescription>
</maintenanceEvent>;

local:updateExpertisesDateTime()