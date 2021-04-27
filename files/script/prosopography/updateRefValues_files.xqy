xquery version "3.1";

(: author @sardinecan
 : 2021-04-01
 : add/update @ref value with '#'
 : just run it !:)

declare default element namespace "eac" ;
declare namespace xlink = "http://www.w3.org/1999/xlink" ;


(:
 : path to xprdata files
 : @rmq to be modified for online/local use
 : @sardinecan : /Volumes/data/github/xprdata/
 : @huma-num : /sites/expertdb/resource/data/
:)

declare variable $path := '/Volumes/data/github/xprdata/';


(: : event for maintenance history:)

declare variable $event :=
  <maintenanceEvent xmlns="eac">
    <eventType>updated</eventType>
    <eventDateTime standardDateTime="{fn:current-dateTime()}">{fn:current-dateTime()}</eventDateTime>
    <agentType>machine</agentType>
    <agent>updateRefValues_files.xqy/BaseX</agent>
    <eventDescription>Mise à jour de la valeur des champs @xlink:ref (ajout d'un '#' pour les participants et les relations).</eventDescription>
  </maintenanceEvent>;


(: : this function updates the z1j files:)

declare
function local:update() {
let $collection := fn:collection($path || 'prosopography/')
return
    for $doc at $i in $collection
    where matches(document-uri($doc), '.xml')
    return (
        copy $d := $doc
        modify (
            for $prosopo in $d//eac-cpf[descendant::*[@xlink:href !='' and not(fn:matches(@xlink:href, '#'))][fn:local-name() = 'participant' or fn:local-name() = 'involve' or fn:local-name() = 'cpfRelation']]
                let $maintenance := $prosopo//maintenanceHistory
                let $event := local:maintenanceEvent($maintenance)
                return(
                    replace node $prosopo//maintenanceHistory with $event,
                    for $ref in $prosopo//*[@xlink:href !='' and not(fn:matches(@xlink:href, '#'))][fn:local-name() = 'participant' or fn:local-name() = 'involve' or fn:local-name() = 'cpfRelation']/@xlink:href
                        let $refValue := $ref => fn:normalize-space()
                        let $updatedRefValue := fn:concat('#', $refValue)
                        return replace value of node $ref with $updatedRefValue
                )
        )
        return(
            file:create-dir($path || 'temp'),
            file:create-dir($path || 'temp/output'),
            file:write($path || 'temp/output/' || substring-after(document-uri($doc), 'prosopography/'), $d)
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