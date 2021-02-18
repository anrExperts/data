xquery version "3.1";
(:
 : author @sardinecan
 : 2021-02-17
 : this script deletes empty namePart into eac-cpf instances
 : just run it !
:)
declare default element namespace "eac" ;

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
declare variable $scriptEvent :=
  <maintenanceEvent xmlns="eac">
    <eventType>updated</eventType>
    <eventDateTime standardDateTime="{fn:current-dateTime()}">{fn:current-dateTime()}</eventDateTime>
    <agentType>machine</agentType>
    <agent>cleanNamePart_files.xqy/BaseX</agent>
    <eventDescription>Suppression des composantes du nom vides.</eventDescription>
  </maintenanceEvent>;


(:
 : @return updated xml files without empty namePart
:)
declare function local:cleanNameParts() {
let $collection := fn:collection($path || 'prosopography/')
return
    for $doc at $i in $collection
    where matches(document-uri($doc), '.xml')
    return (
        copy $d := $doc
        modify (
          for $person in $d//eac-cpf[descendant::nameEntry[alternativeForm]/part[fn:normalize-space(.)='']]
          let $param := $person
          return local:delNamePart($param)
        )
        return(
            file:create-dir($path || 'temp'),
            file:create-dir($path || 'temp/prosopography'),
            file:write($path || 'temp/prosopography/' || substring-after(document-uri($doc), 'prosopography/'), $d)
        )
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