xquery version "3.1";
(:
 : author @sardinecan
 : 2021-07-07
 : add missing @value to keywords/term element
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
    <agent>updateThirdPartyAgreement_db.xqy/BaseX</agent>
    <eventDescription>Modification des valeurs admises pour le champ "dispositif de l'expertise" dans le cadre de tiers expertises.</eventDescription>
  </maintenanceEvent>;

(:
 : this function updates the xpr:db
 :)
declare
%updating
function local:update() {
  let $db := db:open('xpr')/xpr/expertises
  return (
    copy $d := $db
    modify (
      for $expertise in $d/expertise[descendant::expert[@context='third-party']][descendant::agreement[@type='disagreement' or @type='agreement']]
      let $param := $expertise
      return local:process($param)
    )
    return replace node db:open('xpr')/xpr/expertises with $d
  )
};

(:
 : this functions inserts maintenance event & adds @value attributes.
 :)
declare
%updating
function local:process($data) {
  insert node $scriptEvent as first into $data/control/maintenanceHistory,
  replace node $data//conclusions/agreement with <agreement type="conclusion">Conclusion</agreement>

};

local:update()