xquery version "3.1";
(:
 : author @sardinecan
 : 2021-03-30
 : add missing arrangement field.
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
 : event for maintenance history
:)
declare variable $event :=
  <maintenanceEvent xmlns="xpr">
    <eventType>updated</eventType>
    <eventDateTime standardDateTime="{fn:current-dateTime()}">{fn:current-dateTime()}</eventDateTime>
    <agentType>machine</agentType>
    <agent>updateExpertisesArrangement_files.xqy/BaseX</agent>
    <eventDescription>Ajout du champs Accommodement dans l'éventualité d’une résolution par les parties.</eventDescription>
  </maintenanceEvent>;

(:
 : this function updates the z1j files
 :)
declare
function local:update() {
let $collection := fn:collection($path || 'z1j/')
return
    for $doc at $i in $collection
    where matches(document-uri($doc), '.xml')
    return (
        copy $d := $doc
        modify (
          for $expertise in $d//expertise[not(descendant::conclusions/arrangement)]
            let $maintenance := $expertise//maintenanceHistory
            let $event := local:maintenanceEvent($maintenance)
          return (
            replace node $expertise//maintenanceHistory with $event,
            insert node <arrangement/> before $expertise//conclusions/estimate
          )
        )
        return(
            file:create-dir($path || 'temp'),
            file:create-dir($path || 'temp/output'),
            file:write($path || 'temp/output/' || substring-after(document-uri($doc), 'z1j/'), $d)
        )
    )
};

(: this function adds maintenance events
 : @return modified maintenance history for expertise
 :)
declare

function local:maintenanceEvent($maintenance) {
  copy $d := $maintenance
  modify (
    insert node $event as first into $d
  )
  return $d
};

local:update()