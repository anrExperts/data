xquery version "3.1";
(:
 : author @sardinecan
 : 2021-03-30
 : add/update experts fees
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
    <agent>updateExpertsFees_files.xqy/BaseX</agent>
    <eventDescription>Mise à jour du coûts de l'expertise pour les experts.</eventDescription>
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
          for $expertise in $d//expertise[descendant::fees[@detail='true']/fee[@type='expert'][not(@ref)]]
            let $maintenance := $expertise//maintenanceHistory
            let $event := local:maintenanceEvent($maintenance)
            let $fees := $expertise
            let $updatedFees := local:fees($fees)
          return (
            replace node $expertise//maintenanceHistory with $event,
            replace node $expertise//conclusions/fees[@detail='true'] with $updatedFees
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

(: this function adds @xml:id to places described
 : @return modified description/places nodes
 :)
declare
function local:fees($param) {
  let $data :=
    copy $d := $param
    modify (
      for $expert at $i in $d//description/participants/experts/expert
      where $expert[@ref != '']
        let $ref := fn:normalize-space($expert/@ref)
      return (
        if ($d//fees[@detail='true']/fee[@type='expert'][$i]) then
          insert node attribute ref {$ref} into $d//fees[@detail='true']/fee[@type='expert'][$i]
        else
          insert node <fee ref="{$ref}" type="expert" d="" l="" s=""/> after $d//fees[@detail='true']/fee[@type='expert'][fn:last()]
      )
    )
    return $d
  return $data//fees[@detail='true']
};

local:update()