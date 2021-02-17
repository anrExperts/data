xquery version "3.1";
(:
 : author @emchateau & @sardinecan
 : 2020-12
 : this script updates the control module for z1j files
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
declare variable $resp := csv:parse(file:read-text($path || 'files/responsability.csv'), map {'header': fn:true()});

(:
 : control module for z1j files
:)
declare variable $control :=
<control>
    <maintenanceStatus/>
    <publicationStatus/>
    <localControl localType="detailLevel">
        <term/>
    </localControl>
    <maintenanceHistory>
        <maintenanceEvent>
            <eventType/>
            <eventDateTime standardDateTime=""/>
            <agentType/>
            <agent/>
            <eventDescription/>
        </maintenanceEvent>
    </maintenanceHistory>
</control>;

(:
 : control module for z1j files
:)
declare variable $event :=
  <maintenanceEvent xmlns="xpr">
    <eventType/>
    <eventDateTime standardDateTime=""/>
    <agentType/>
    <agent/>
    <eventDescription/>
  </maintenanceEvent>;

(:
 : this function add or update the control module for each expertise
 : @return updated xml files
:)
declare function local:updateControl() {
let $collection := fn:collection($path || 'z1j/')
return
    for $doc at $i in $collection
    where matches(document-uri($doc), '.xml')
    return (
        copy $d := $doc
        modify (
            for $expertise in $d//expertise[not(descendant::control)]
            return insert node $control after $expertise/meta,
            for $control in $d//control[not(descendant::eventDescription)]
            return insert node <eventDescription/> after $control/maintenanceHistory/maintenanceEvent/agent
        )
        return(
            file:create-dir($path || 'temp'),
            file:create-dir($path || 'temp/control'),
            file:write($path || 'temp/control/' || substring-after(document-uri($doc), 'z1j/'), $d),
            local:addResp()
        )
    )
};

declare function local:addResp() {
let $collection := fn:collection($path || 'temp/control/')
return(
    file:create-dir($path || 'temp/responsability'),
    for $doc at $i in $collection
    where matches(document-uri($doc), '.xml')
    return (
        copy $d := $doc
        modify (
            for $expertise in $d//expertise
            let $unitid := substring-after($expertise//idno[@type='unitid'], 'Z1J')
            let $responsability := $resp//*:record[descendant::*:unitid[fn:normalize-space(.) = fn:normalize-space($unitid)]]
            return(
              for $who in $responsability//*:who[fn:normalize-space(.) != ''][fn:position() > 1]
              return insert node $event after $expertise//maintenanceEvent[last()]
            )
        )
        return file:write($path || 'temp/responsability/' || fn:substring-after(document-uri($doc), 'control/'), $d)
    ), local:fillResp()
)
};

declare
function local:fillResp() {
let $collection := fn:collection($path || 'temp/responsability/')
return(
    file:create-dir($path || 'temp/output'),
    for $doc in $collection
    where matches(document-uri($doc), '.xml')
    return (
        copy $d := $doc
        modify (
            for $expertise in $d//expertise
            let $unitid := substring-after($expertise//idno[@type='unitid'], 'Z1J')
            let $responsability := $resp//*:record[descendant::*:unitid[normalize-space(.) = normalize-space($unitid)]]
            return(
                for $maintenance at $i in $expertise//maintenanceHistory/maintenanceEvent
                return (
                    replace value of node $maintenance/eventType with $responsability//*:what[$i],
                    replace value of node $maintenance/eventDateTime with $responsability//*:when[$i],
                    replace value of node $maintenance/eventDateTime/@standardDateTime with $responsability//*:when[$i],
                    replace value of node $maintenance/agent with $responsability//*:who[$i],
                    replace value of node $maintenance/eventDescription with $responsability//*:desc[$i],
                    replace value of node $maintenance/agentType with $responsability//*:agentType[$i]
                )
            )
        )
        return file:write($path || 'temp/output/' || substring-after(document-uri($doc), 'responsability/'), $d)
    )
)
};

local:updateControl()