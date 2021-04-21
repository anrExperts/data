xquery version "3.1";
(:
 : author @sardinecan
 : 2021-03-30
 : add missing estimates and @xml:id for places when we have an expertise with estimation.
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
    <agent>updateExpertisesPlacesEstimates_files.xqy/BaseX</agent>
    <eventDescription>Ajout des champs pour l'estimation des lieux.</eventDescription>
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
          for $expertise in $d//expertise[descendant::category[@type='estimation']][not(descendant::conclusions/estimates)]
            let $maintenance := $expertise//maintenanceHistory
            let $event := local:maintenanceEvent($maintenance)
            let $places := $expertise//description/places
            let $updatedPlaces := local:placesId($places)
            let $estimates :=
            <estimates>{
              for $place at $i in $updatedPlaces//place
              return <place ref="{fn:concat('#', $place/@xml:id)}"><appraisal l="" s="" d=""><desc/></appraisal></place>
            }</estimates>
          return (
            replace node $expertise//maintenanceHistory with $event,
            replace node $expertise//description/places with $updatedPlaces,
            insert node $estimates after $expertise//conclusions/estimate
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
function local:placesId($param) {
  let $data :=
    copy $d := $param
    modify (
      for $place at $i in $d//place
      where $place[fn:not(@xml:id)]
        let $idPlace := fn:generate-id($place)
      return insert node attribute xml:id {$idPlace} into $place
    )
    return $d
  return $data
};

local:update()