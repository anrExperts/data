xquery version "3.1";
(:
 : author @emchateau & @sardinecan
 : 2020-12
 : this script updates the control module for z1j files
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
 : this function add or update the control module for each expertise
 : @return updated xml files
:)
declare function local:updateControlExperts() {
(:let $collection := fn:collection($path || 'prosopography/'):)
let $source := fn:doc($path || 'prosopography/experts.xml')
return
    for $doc at $i in $source
(:    where matches(document-uri($doc), '.xml'):)
    return (
        copy $d := $doc
        modify (
            for $bio at $pos in $d//eac-cpf
            let $maintenance := local:addMaintenance($pos)
            return(
              if ($pos <= 11) then insert node <maintenanceStatus>revised</maintenanceStatus> before $bio/control/sources
              else insert node <maintenanceStatus>new</maintenanceStatus> before $bio/control/sources,
              insert node <publicationStatus/> before $bio/control/sources,
              insert node <localControl localType="detailLevel"><term>in progress</term></localControl> before $bio/control/sources,
              insert node $maintenance before $bio/control/sources
            )
        )
        return(
            file:create-dir($path || 'temp'),
            file:create-dir($path || 'temp/prosopography'),
            file:write($path || 'temp/prosopography/' || substring-after(document-uri($doc), 'prosopography/'), $d),
            local:updateControlOffices()
        )
    )
};

declare function local:updateControlOffices() {
(:let $collection := fn:collection($path || 'prosopography/'):)
let $source := fn:doc($path || 'prosopography/offices.xml')
return
    for $doc at $i in $source
(:    where matches(document-uri($doc), '.xml'):)
    return (
        copy $d := $doc
        modify (
            for $bio in $d//eac-cpf
            let $pos := 100
            let $maintenance := local:addMaintenance($pos)
            return(
              insert node <maintenanceStatus>new</maintenanceStatus> before $bio/control/sources,
              insert node <publicationStatus/> before $bio/control/sources,
              insert node <localControl localType="detailLevel"><term>in progress</term></localControl> before $bio/control/sources,
              insert node $maintenance before $bio/control/sources
            )
        )
        return(
            file:create-dir($path || 'temp'),
            file:create-dir($path || 'temp/prosopography'),
            file:write($path || 'temp/prosopography/' || substring-after(document-uri($doc), 'prosopography/'), $d),
            local:updateControlOthers()
        )
    )
};

declare function local:updateControlOthers() {
(:let $collection := fn:collection($path || 'prosopography/'):)
let $source := fn:doc($path || 'prosopography/others.xml')
return
    for $doc at $i in $source
(:    where matches(document-uri($doc), '.xml'):)
    return (
        copy $d := $doc
        modify (
            for $bio at $i in $d//eac-cpf
            return(
              insert node <maintenanceStatus>new</maintenanceStatus> before $bio/control/sources,
              insert node <publicationStatus/> before $bio/control/sources,
              insert node <localControl localType="detailLevel"><term>in progress</term></localControl> before $bio/control/sources,
              if($i > 10) then
              insert node
              <maintenanceHistory>
                <maintenanceEvent>
                  <eventType>created</eventType>
                  <eventDateTime standardDateTime="2020-09">2020-09</eventDateTime>
                  <agentType>human</agentType>
                  <agent>JH</agent>
                  <eventDescription>Création de la fiche.</eventDescription>
                </maintenanceEvent>
              </maintenanceHistory> before $bio/control/sources
              else insert node
              <maintenanceHistory>
                <maintenanceEvent>
                  <eventType>created</eventType>
                  <eventDateTime standardDateTime="2019-11-15">2019-11-15</eventDateTime>
                  <agentType>human</agentType>
                  <agent>JH</agent>
                  <eventDescription>Création de la fiche.</eventDescription>
                </maintenanceEvent>
              </maintenanceHistory> before $bio/control/sources
            )
        )
        return(
            file:create-dir($path || 'temp'),
            file:create-dir($path || 'temp/prosopography'),
            file:write($path || 'temp/prosopography/' || substring-after(document-uri($doc), 'prosopography/'), $d)
        )
    )
};

declare function local:addMaintenance($pos){
let $i := $pos
return (
    if($i <= 11) then
                  <maintenanceHistory>
                    <maintenanceEvent>
                      <eventType>revised</eventType>
                      <eventDateTime standardDateTime="2019-11-15">2019-11-15</eventDateTime>
                      <agentType>human</agentType>
                      <agent>JH</agent>
                      <eventDescription>Révision de la fiches suite à la rétroconversion.</eventDescription>
                    </maintenanceEvent>
                    <maintenanceEvent>
                      <eventType>retroconverted</eventType>
                      <eventDateTime standardDateTime="2019-11-07">2019-11-07</eventDateTime>
                      <agentType>machine</agentType>
                      <agent>xml2eac.xsl/Saxon9</agent>
                      <eventDescription>Notice rétroconvertie en EAC-CPF à partir de données Google Drive.</eventDescription>
                    </maintenanceEvent>
                    <maintenanceEvent>
                      <eventType>created</eventType>
                      <eventDateTime standardDateTime="2018/2019">2018/2019</eventDateTime>
                      <agentType>human</agentType>
                      <agent>JH</agent>
                      <eventDescription>Fiches créée sur Google Drive.</eventDescription>
                    </maintenanceEvent>
                  </maintenanceHistory>
    else if($i > 266) then
       <maintenanceHistory>
         <maintenanceEvent>
           <eventType>created</eventType>
           <eventDateTime standardDateTime="2020-09">2020-09</eventDateTime>
           <agentType>human</agentType>
           <agent>JH</agent>
           <eventDescription>Création de la fiche.</eventDescription>
         </maintenanceEvent>
       </maintenanceHistory>
else
    <maintenanceHistory>
      <maintenanceEvent>
        <eventType>retroconverted</eventType>
        <eventDateTime standardDateTime="2019-11-07">2019-11-07</eventDateTime>
        <agentType>machine</agentType>
        <agent>xml2eac.xsl/Saxon9</agent>
        <eventDescription>Notice rétroconvertie en EAC-CPF à partir de données Google Drive.</eventDescription>
      </maintenanceEvent>
      <maintenanceEvent>
        <eventType>created</eventType>
        <eventDateTime standardDateTime="2018/2019">2018/2019</eventDateTime>
        <agentType>human</agentType>
        <agent>JH</agent>
        <eventDescription>Fiches créée sur Google Drive.</eventDescription>
      </maintenanceEvent>
    </maintenanceHistory>
)
};

local:updateControlExperts()