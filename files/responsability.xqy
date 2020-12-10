xquery version "3.1";
(:
 : author @emchateau & @sardinecan
 : 2020-12
 : this script adds responsability z1j files (creation & revision)
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
 : path to xprdata responsability files
 : @rmq to be modified for online/local use
 : @sardinecan : /Volumes/data/github/xprdata/
 : @huma-num : /sites/expertdb/resource/data/
:)
declare variable $resp := csv:parse(file:read-text($path || 'responsability.csv'), map {'header': fn:true()});


(:
 : control module for z1j files
:)
declare variable $event :=
  <maintenanceEvent xmlns="xpr">
    <eventType/>
    <eventDateTime standardDateTime=""/>
    <agentType>human</agentType>
    <agent/>
    <eventDescription/>
  </maintenanceEvent>;

declare function local:addResp() {
let $collection := fn:collection($path || 'draft/updatedZ1J/')
return
    for $doc at $i in $collection
    where matches(document-uri($doc), '.xml')
    return (
        copy $d := $doc
        modify (
            for $expertise in $d//expertise
            let $unitid := substring-after($expertise//idno[@type='unitid'], 'Z1J')
            let $responsability := fn:doc('/Volumes/data/github/xprdata/responsability.xml')//record[descendant::unitid[normalize-space(.) = normalize-space($unitid)]]
            return(
              for $who in $responsability//who[normalize-space(.) != ''][position() > 1]
              return insert node $event after $expertise//maintenanceEvent[last()]
            )
        )
        return file:write('/Volumes/data/github/xprdata/draft/' || substring-after(document-uri($doc), 'Z1J/'), $d)
    )
};
(:replace value of node $expertise//maintenanceEvent[1]/agent with $creation/who[1]
return file:write('/Volumes/data/github/xprdata/draft/' || substring-after(document-uri($doc), 'Z1J/'), $d)
:)

declare function local:fillResp() {
let $collection := fn:collection($path || 'draft/updatedZ1J/')
return
    for $doc in $collection
    where matches(document-uri($doc), '.xml')
    return (
        copy $d := $doc
        modify (
            for $maintenance at $i in $d//expertise//maintenanceHistory/maintenanceEvent
            let $unitid := substring-after($maintenance/ancestor::expertise//idno[@type='unitid'], 'Z1J')
            let $responsability := fn:doc('/Volumes/data/github/xprdata/responsability.xml')//record[descendant::unitid[normalize-space(.) = normalize-space($unitid)]]
            return (
              replace value of node $maintenance/eventType with $responsability//what[$i],
              replace value of node $maintenance/eventDateTime/@standardDateTime with $responsability//when[$i],
              replace value of node $maintenance/agent with $responsability//who[$i],
              if($i > 1) then replace value of node $maintenance/eventDescription with 'Rétroconversion Gip'
              else replace value of node $maintenance/eventDescription with 'Création de la fiche'
            )
        )
        return file:write('/Volumes/data/github/xprdata/draft/' || substring-after(document-uri($doc), 'Z1J/'), $d)
    )
};
local:fillResp()