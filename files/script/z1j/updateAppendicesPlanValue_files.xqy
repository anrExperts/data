xquery version "3.1";

(: author @sardinecan
 : 2021-04-01
 : add/update @ref value with '#'
 : just run it !:)

declare default element namespace "xpr" ;


(:
 : path to xprdata files
 : @rmq to be modified for online/local use
 : @sardinecan : /Volumes/data/github/experts/xprdata/
 : @huma-num : /sites/expertdb/resource/data/
:)

declare variable $path := '/Volumes/data/github/experts/xprdata/';


(: : event for maintenance history:)

declare variable $event :=
  <maintenanceEvent xmlns="xpr">
    <eventType>updated</eventType>
    <eventDateTime standardDateTime="{fn:current-dateTime()}">{fn:current-dateTime()}</eventDateTime>
    <agentType>machine</agentType>
    <agent>updateAppendicesPlanValue_files.xqy/BaseX</agent>
    <eventDescription>Mise à jour de la valeur "plan" pour les champs "type" des annexes "Plan, coupe, élévation".</eventDescription>
  </maintenanceEvent>;


(: : this function updates the z1j files:)

declare
function local:update() {
let $collection := fn:collection($path || 'z1j/')
return
    for $doc at $i in $collection
    where matches(document-uri($doc), '.xml')
    return (
        copy $d := $doc
        modify (
            for $expertise in $d//expertise[descendant::appendice/type/@type='plan']
                let $maintenance := $expertise//maintenanceHistory
                let $event := local:maintenanceEvent($maintenance)
                return(
                    replace node $expertise//maintenanceHistory with $event,
                    for $type in $expertise//appendice/type[@type='plan']
                        let $value := 'Plan, coupe, élévation'
                        return replace value of node $type with $value
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
 : @return modified maintenance history for expertise:)

declare

function local:maintenanceEvent($maintenance) {
  copy $d := $maintenance
  modify (
    insert node $event as first into $d
  )
  return $d
};

local:update()