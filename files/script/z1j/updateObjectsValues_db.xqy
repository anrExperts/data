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
    <agent>updateObjectsValues_db.xqy/BaseX</agent>
    <eventDescription>Modification des valeurs admises pour le champ "objets de l’expertise" (passage au pluriel).</eventDescription>
  </maintenanceEvent>;

(:
 : missing @value attributes
:)
declare variable $objects :=
<objects xmlns="xpr">
  <object type="house">Maison(s)</object>
  <object type="plot">Terrain(s)</object>
  <object type="buildings">Ensemble de bâtiments (biens immeubles)</object>
  <object type="territory">Domaine, terres, fief</object>
  <object type="wall">Mur(s)</object>
  <object type="cesspool">Fosse(s) d'aisance</object>
  <object type="well">Puits</object>
  <object type="repairs">Réparations</object>
  <object type="masonry">Maçonnerie (ouvrage(s))</object>
  <object type="carpentry">Charpenterie (ouvrage(s))</object>
  <object type="roofing">Couverture (ouvrage(s))</object>
  <object type="joinery">Menuiserie (ouvrage(s))</object>
  <object type="sculpture">Sculpture (ouvrage(s))</object>
  <object type="painting">Peinture (ouvrage(s))</object>
  <object type="gilding">Dorure (ouvrage(s))</object>
  <object type="marblework">Marbre (ouvrage(s))</object>
  <object type="locks">Serrurerie (ouvrage(s))</object>
  <object type="glasswork">Vitrerie (ouvrage(s))</object>
  <object type="leadWork">Plomb (ouvrage(s))</object>
  <object type="fees">Honoraires</object>
  <object type="salary">Salaires</object>
  <object type="other"/>
</objects>;


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
      for $expertise in $d/expertise[descendant::object[@type='house' or @type='plot' or @type='buildings' or @type='wall' or @type='cesspool']]
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
  for $object in $data//object[@type='house' or @type='plot' or @type='buildings' or @type='wall' or @type='cesspool']
  let $value := $objects//object[@type=$object/@type] => fn:normalize-space()
  return replace value of node $object with $value
};

local:update()