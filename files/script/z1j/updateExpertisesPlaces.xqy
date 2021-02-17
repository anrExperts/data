xquery version "3.1";
(:
 : author @emchateau & @sardinecan
 : 2020-12
 : this script adds missing nodes into expertises addresses and adds maintenance event
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
 : this function adds missing nodes into expertises addresses
 : @return updated xml files
:)
declare function local:updateExpertisesPlaces() {
let $collection := fn:collection($path || 'z1j/')
return
    for $doc at $i in $collection
    where matches(document-uri($doc), '.xml')
    return (
        copy $d := $doc
        modify (
            for $expertise in $d//expertises/expertise[descendant::places/place[(@type='paris' and (not(*:address/*:street) or not(*:address/*:buildingNumber) or not(*:parish))) or (@type='province'and (not(*:district) or not(*:city))) or (@type='suburbs'and (not(*:district) or not(*:city)))]]
            let $maintenance := $expertise//maintenanceHistory
            let $places := $expertise//description/places
            let $event := local:maintenanceEvent($maintenance)
            let $lieu := local:updatedPlaces($places)
            return(
                replace node $expertise//maintenanceHistory with $event,
                replace node $expertise//description/places with $lieu
                )
        )
        return(
            file:create-dir($path || 'temp'),
            file:create-dir($path || 'temp/z1j'),
            file:write($path || 'temp/z1j/' || substring-after(document-uri($doc), 'z1j/'), $d)
        )
    )
};

(: this function adds maintenance events
 : @return modified maintenance history for expertise
 :)
declare function local:maintenanceEvent($maintenance) {
copy $d := $maintenance
modify (
    insert node $event as first into $d
)
return $d
};

(: this function adds missing nodes into places (addresses)
 : @return updated places for expertise
 :)
declare function local:updatedPlaces($places) {
copy $d := $places
modify (
    for $place in $d/place[(@type='paris' and (not(*:address/*:street) or not(*:address/*:buildingNumber) or not(*:parish))) or (@type='province'and (not(*:district) or not(*:city))) or (@type='suburbs'and (not(*:district) or not(*:city)))]
    return (
        switch ($place/@type)
        case 'paris' return(
            replace node $place/address with <address xmlns="xpr"><street/><buildingNumber/></address>,
            insert node <parish xmlns="xpr"/> after $place/complement
        )
        case 'suburbs' return(
            insert node <city xmlns="xpr"/> after $place/complement,
            insert node <district xmlns="xpr"/> before $place/owner[1]
        )
        case 'province' return(
            insert node <city xmlns="xpr"/> after $place/complement,
            insert node <district xmlns="xpr"/> before $place/owner[1]
        )
        default return $place
    )
)
return $d
};

declare variable $event :=
<maintenanceEvent>
    <eventType>updated</eventType>
    <eventDateTime standardDateTime="{fn:current-dateTime()}">{fn:current-dateTime()}</eventDateTime>
    <agentType>machine</agentType>
    <agent>updateExpertisesPlaces.xqy/BaseX</agent>
    <eventDescription>Ajout des nœuds xml manquant dans les adresses.</eventDescription>
</maintenanceEvent>;

local:updateExpertisesPlaces()