xquery version "3.1";
(:
 : author @emchateau & @sardinecan
 : 2020-10
 : this script adds expertises from autosave db to the xpr db
:)
declare default element namespace "xpr" ;

(:
 : expertise file to be added
:)
declare
function local:getExpertise() {
    let $db := db:open('xprAutosave')
    let $unitid := 'Z1J1152'
    let $item := '034'
    let $user := 'yplouzennec'
    let $expertise := $db//expertises/expertise[1][descendant::idno[@type='unitid']=$unitid and descendant::idno[@type='item']=$item]
    return
        copy $d := $expertise
        modify(
            let $id := fn:replace(fn:lower-case($d/sourceDesc/idno[@type="unitid"]), '/', '-') || 'd' || fn:format-integer($d/sourceDesc/idno[@type="item"], '000') || $d/sourceDesc/idno[@type="supplement"]
            return (
                insert node attribute xml:id {$id} into $d,
                replace value of node $d/control/maintenanceHistory/maintenanceEvent[1]/agent with $user,
                for $place at $i in $d/description[categories/category[@type="estimation"]]/places/place
                    let $idPlace := fn:generate-id($place)
                    where $place[fn:not(@xml:id)]
                    return (
                        insert node attribute xml:id {$idPlace} into $place,
                        insert node attribute ref {fn:concat('#', $idPlace)} into $d/description/conclusions/estimates/place[$i]
                    )
            )
        )
        return $d
};

declare
%updating
function local:recupExpertise() {
 let $db := db:open('xpr')
 let $expertise := local:getExpertise()
 return insert node $expertise as last into $db//expertises
};


local:recupExpertise()