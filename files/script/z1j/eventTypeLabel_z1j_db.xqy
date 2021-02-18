xquery version "3.1";
(:
 : author @sardinecan
 : 2021-02-17
 : this script updates the event label (maintenance history) for z1j files
 : just run it !
:)
declare default element namespace "xpr" ;

(:
 : event for maintenance history
:)
declare variable $scriptEvent :=
  <maintenanceEvent xmlns="xpr">
    <eventType>updated</eventType>
    <eventDateTime standardDateTime="{fn:current-dateTime()}">{fn:current-dateTime()}</eventDateTime>
    <agentType>machine</agentType>
    <agent>eventTypeLabel_z1j_db.xqy/BaseX</agent>
    <eventDescription>Correction des eventType (changement de nom).</eventDescription>
  </maintenanceEvent>;

(:
 : this function adds maintenance event to expertise with old eventType label
 : @returned updated expertise with new eventType label
 :)
declare
%updating
function local:eventTypeLabel() {
  let $db := db:open('xpr')/xpr/expertises
  return (
    copy $d := $db
    modify (
      for $history in $d//maintenanceHistory[maintenanceEvent/eventType='creation' or maintenanceEvent/eventType='revision']
      let $param := $history
      return local:modifyLabel($param)
    )
    return replace node db:open('xpr')/xpr/expertises with $d
  )
};


(:
 : this function updates eventType label
 :)
declare
%updating
function local:modifyLabel($data) {
  insert node $scriptEvent as first into $data,
  for $eventType in $data//eventType[.='creation' or .='revision']
  let $label :=
    switch ($eventType)
      case 'creation' return 'created'
      case 'revision' return 'revised'
      default return fn:normalize-space(.)
  return replace value of node $eventType with $label
};

local:eventTypeLabel()