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
declare variable $path := '/Volumes/data/github/xprdata/z1j';

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
            <agentType>human</agentType>
            <agent/>
            <eventDescription/>
        </maintenanceEvent>
    </maintenanceHistory>
</control>;

(:
 : this function add or update the control module for each expertise
 : @return updated xml files
:)
declare function local:updateControl() {
let $collection := fn:collection($path)
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
        return file:write('/Volumes/data/github/xprdata/draft/updatedZ1J/' || substring-after(document-uri($doc), 'z1j/'), $d)
    )
};

local:updateControl()