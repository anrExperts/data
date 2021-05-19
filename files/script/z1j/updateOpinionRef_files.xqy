xquery version "3.1";

(: author @sardinecan
 : 2021-04-01
 : add/update @ref value with '#'
 : just run it !:)

declare default element namespace "xpr" ;


(:
 : path to xprdata files
 : @rmq to be modified for online/local use
 : @sardinecan : /Volumes/data/github/xprdata/
 : @huma-num : /sites/expertdb/resource/data/
:)

declare variable $path := '/Volumes/data/github/xprdata/';


(: : event for maintenance history:)

declare variable $event :=
  <maintenanceEvent xmlns="xpr">
    <eventType>updated</eventType>
    <eventDateTime standardDateTime="{fn:current-dateTime()}">{fn:current-dateTime()}</eventDateTime>
    <agentType>machine</agentType>
    <agent>updateOpinionRef_files.xqy/BaseX</agent>
    <eventDescription>Ajout d'un attribut @ref sur les éléments opinion qui en sont dépourvus.</eventDescription>
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
            for $expertise in $d//expertise[descendant::opinion[fn:not(@ref)]]
                let $maintenance := $expertise//maintenanceHistory
                let $event := local:maintenanceEvent($maintenance)
                return(
                    replace node $expertise//maintenanceHistory with $event,
                    for $opinion in $expertise//opinion[fn:not(@ref)]
                        return (
                        if(fn:count($expertise//experts/expert) = 1) then
                          insert node (attribute ref {fn:normalize-space($expertise//experts/expert/@ref)}) into $opinion
                        else
                          insert node (attribute ref {}) into $opinion
                        )

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