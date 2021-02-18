xquery version "3.1";
(:
 : author @sardinecan
 : 2021-02-17
 : this script deletes empty namePart into eac-cpf (db)
 : just run it !
:)
declare default element namespace "eac" ;

(:
 : event for maintenance history
:)
declare variable $scriptEvent :=
  <maintenanceEvent xmlns="eac">
    <eventType>updated</eventType>
    <eventDateTime standardDateTime="{fn:current-dateTime()}">{fn:current-dateTime()}</eventDateTime>
    <agentType>machine</agentType>
    <agent>cleanNamePart_db.xqy/BaseX</agent>
    <eventDescription>Suppression des composantes du nom vides.</eventDescription>
  </maintenanceEvent>;

(:
 : @return updated xpr db without empty namePart
:)
declare
%updating
function local:cleanNameParts() {
  let $db := db:open('xpr')/*:xpr/*:bio
  return (
    copy $d := $db
    modify (
      for $person in $d/eac-cpf[descendant::nameEntry[alternativeForm]/part[fn:normalize-space(.)='']]
      let $param := $person
      return local:delNamePart($param)
    )
    return replace node db:open('xpr')/*:xpr/*:bio with $d
  )
};

(:
 : this functions inserts maintenance event & deletes empty nameParts
 :)
declare
%updating
function local:delNamePart($data) {
  insert node $scriptEvent as first into $data/control/maintenanceHistory,
  for $namePart in $data//nameEntry[alternativeForm]/part[fn:normalize-space(.)='']
  return delete node $namePart
};

local:cleanNameParts()