xquery version "3.1";
(:
 : author @sardinecan
 : 2022-12
 : this script puts inductions from builder app into xpr prosopo files
:)
declare namespace xpr = "xpr" ;
declare namespace eac = "https://archivists.org/ns/eac/v2" ;

declare default element namespace "xpr" ;
declare default function namespace "xpr.funct" ;

declare function getInductions() {
  let $inductions := db:open('builders')/builders/inductions/induction
  return $inductions
};

declare %updating function transformInductions(){
  for $induction in getInductions()

  let $expert := $induction/description/candidate/persName/@ref => fn:substring-after('#')

  let $date  := $induction/description/masterpiece/date[@type='induction']/@when

  let $sources :=
    for $s in $induction/sourceDesc/source
    let $sourceId := "source" || fn:generate-id($s)
    return 
      <source id="{$sourceId}" xmlns="https://archivists.org/ns/eac/v2">
        <reference href="">{$s/*:unitid => fn:normalize-space()}</reference>
        {if($s/*:item[fn:normalize-space(.)!='']) then <citedRange unit="page">{$s/*:item/fn:normalize-space()}</citedRange>}
        {if($s/*:facsimile[fn:normalize-space((@from))!='' or fn:normalize-space((@to))!='']) then 
        <descriptiveNote>
          <p>facsimile : {fn:string-join($s/*:facsimile/@*[fn:normalize-space(.)!=''], ' - ')}</p>
        </descriptiveNote>}
      </source>

  let $sourcesRef := for $source in $sources return fn:normalize-space($source/@id)

  let $place :=
    if($induction/*:description/*:candidate/*:address[fn:normalize-space(.)!='']) then
    <place xmlns="https://archivists.org/ns/eac/v2" sourceReference="{$sourcesRef}">
      <date certainty="certain" standardDate="{$date}" />
      <placeRole>Adresse</placeRole>
      <placeName>{$induction/*:description/*:candidate/*:address/*:street => fn:normalize-space()}</placeName>
      {if($induction/*:description/*:candidate/*:address/*[fn:not(self::*:street)][fn:normalize-space(.)!='']) then
        <address>{
          for $addrLine in $induction/*:description/*:candidate/*:address/*[fn:not(self::*:street)][fn:normalize-space(.)!='']
          return <addressLine>{$addrLine => fn:normalize-space()}</addressLine>
        }</address>
      }
    </place>

  let $eventId := "event" || fn:generate-id($induction)
  let $event :=
    <chronItem id="{$eventId}" sourceReference="{$sourcesRef}" localType="master" xmlns="https://archivists.org/ns/eac/v2">
      <dateSet>{
        if($induction/*:description/*:petition/*:date[fn:normalize-space(@when)!='']) then <date certainty="certain" standardDate="{$induction/*:description/*:petition/*:date/@when}">Supplique</date>,
        if($induction/*:description/*:petition/*:syndicCommunication/*:date[fn:normalize-space(@when)!='']) then <date certainty="certain" standardDate="{$induction/*:description/*:petition/*:syndicCommunication/*:date/@when}">Communication au syndic</date>,
        if($induction/*:description/*:petition/*:syndicCommunication/*:response[fn:normalize-space(@when)!='']) then <date certainty="certain" standardDate="{$induction/*:description/*:petition/*:syndicCommunication/*:response/@when}">Réponse du syndic</date>,
        if($induction/*:description/*:manners/*:date[@type='ruling'][fn:normalize-space(@when)!='']) then <date certainty="certain" standardDate="{$induction/*:description/*:manners/*:date[@type='ruling']/@when}">Ordonnance de soit fait</date>,
        if($induction/*:description/*:manners/*:date[@type='manners'][fn:normalize-space(@when)!='']) then <date certainty="certain" standardDate="{$induction/*:description/*:manners/*:date[@type='manners']/@when}">Information de vie et de mœurs</date>,
        if($induction/*:description/*:masterpiece/*:date[@type='ruling'][fn:normalize-space(@when)!='']) then <date certainty="certain" standardDate="{$induction/*:description/*:masterpiece/*:date[@type='ruling']/@when}">Ordonnance</date>,
        if($induction/*:description/*:masterpiece/*:date[@type='certificate'][fn:normalize-space(@when)!='']) then <date certainty="certain" standardDate="{$induction/*:description/*:masterpiece/*:date[@type='certificate']/@when}">Certificat</date>,
        if($induction/*:description/*:masterpiece/*:drawing/*:date[fn:normalize-space(@when)!='']) then <date certainty="certain" standardDate="{$induction/*:description/*:masterpiece/*:drawing/*:date/@when}">Tracer et dessiner sur des cartons le trait géométrique</date>,
        if($induction/*:description/*:masterpiece/*:stoneModel/*:date[fn:normalize-space(@when)!='']) then <date certainty="certain" standardDate="{$induction/*:description/*:masterpiece/*:stoneModel/*:date/@when}">Réalisation du modèle en pierre</date>,
        if($induction/*:description/*:masterpiece/*:date[@type='induction'][fn:normalize-space(@when)!='']) then <date certainty="certain" standardDate="{$induction/*:description/*:masterpiece/*:date[@type='induction']/@when}">Réception</date>
      }</dateSet>
      <event>Maîtrise de maçon</event>
      {if($induction/*:description/*:masterpiece/*:drawing[fn:normalize-space(*:placeName)!='']
          or $induction/*:description/*:masterpiece/*:stoneModel[fn:normalize-space(*:placeName)!='']) then
          <places>{
            if($induction/*:description/*:masterpiece/*:drawing[fn:normalize-space(*:placeName)!='']) then 
            <place>
              <placeRole>Tracer et dessiner sur des cartons le trait géométrique</placeRole>
              <placeName>{$induction/*:description/*:masterpiece/*:drawing/fn:normalize-space(*:placeName)}</placeName>
            </place>,
            if($induction/*:description/*:masterpiece/*:stoneModel[fn:normalize-space(*:placeName)!='']) then 
            <place>
              <placeRole>Modèle en pierre</placeRole>
              <placeName>{$induction/*:description/*:masterpiece/*:stoneModel/fn:normalize-space(*:placeName)}</placeName>
            </place>
          }</places>}
      {if($induction/*:description/*:petition/*:syndicCommunication/*:response[fn:normalize-space(.)!=''] 
          or $induction/*:description/*:masterpiece[fn:normalize-space(*:objectName)!=''] 
          or $induction/*:description/*:masterpiece[fn:normalize-space(*:induction)!='']) then
      <descriptiveNote>{
        if($induction/*:description/*:petition/*:syndicCommunication/*:response[fn:normalize-space(.)!='']) then <p>Réponse du syndic : {$induction/*:description/*:petition/*:syndicCommunication/*:response/fn:normalize-space()}</p>,
        if($induction/*:description/*:masterpiece[fn:normalize-space(*:objectName)!='']) then <p>Chef-dœuvre : {$induction/*:description/*:masterpiece/fn:normalize-space(*:objectName)}</p>,
        if($induction/*:description/*:masterpiece[fn:normalize-space(*:induction)!='']) then <p>Réception : {$induction/*:description/*:masterpiece/fn:normalize-space(*:induction)}</p>
    }</descriptiveNote>}
    </chronItem>

  let $petitionMagistrate :=
    let $path := $induction/*:description/*:petition/*:magistrate
    let $relationTypeId := fn:generate-id($path)
    return
    <relation xmlns="https://archivists.org/ns/eac/v2" target="{$eventId}" sourceReference="{$sourcesRef}">
      <targetEntity targetType="person">
        <part localType="full">{$path/*:surname || ', ' || $path/*:forename}</part>
        <part localType="status">{$path/*:note => fn:normalize-space()}</part>
        <part localType="occupationType"></part>
        <part localType="age"/>
        <part localType="address"/>
        <part localType="origPlace"/>
        <part localType="xprRef">{$path/@ref => fn:normalize-space()}</part>
      </targetEntity>
      <relationType id="{$relationTypeId}" valueURI="https://www.ica.org/standards/RiC/ontology#hasOrHadController" vocabularySource="RiC-O" vocabularySourceURI="https://www.ica.org/standards/RiC/ontology" sourceReference="{$sourcesRef}">rico:hasOrHadController</relationType>
      <targetRole target="{$relationTypeId}">magistrat</targetRole>
    </relation>

  let $petitionSyndic :=
    let $path := $induction/*:description/*:petition/*:syndicCommunication/*:syndic
    let $relationTypeId := fn:generate-id($path)
    return
    <relation xmlns="https://archivists.org/ns/eac/v2" target="{$eventId}" sourceReference="{$sourcesRef}">
      <targetEntity targetType="person">
        <part localType="full">{$path/*:surname || ', ' || $path/*:forename}</part>
        <part localType="status"/>
        <part localType="occupationType"></part>
        <part localType="age"/>
        <part localType="address"/>
        <part localType="origPlace"/>
        <part localType="xprRef">{$path/@ref => fn:normalize-space()}</part>
      </targetEntity>
      <relationType id="{$relationTypeId}" valueURI="https://www.ica.org/standards/RiC/ontology#hasOrHadController" vocabularySource="RiC-O" vocabularySourceURI="https://www.ica.org/standards/RiC/ontology" sourceReference="{$sourcesRef}">rico:hasOrHadController</relationType>
      <targetRole target="{$relationTypeId}">syndic</targetRole>
      if($path/*:persName/*:note[fn:normalize-space(.)!='']) then(
        <descriptiveNote>
          <p>{$path/*:persName/*:note => fn:normalize-space()}</p>
        </descriptiveNote>)
    </relation>

  let $mannersMagistrate :=
    let $path := $induction/*:description/*:manners/*:magistrate
    let $relationTypeId := fn:generate-id($path)
    return
    <relation xmlns="https://archivists.org/ns/eac/v2" target="{$eventId}" sourceReference="{$sourcesRef}">
      <targetEntity targetType="person">
        <part localType="full">{$path/*:surname || ', ' || $path/*:forename}</part>
        <part localType="status"/>
        <part localType="occupationType"></part>
        <part localType="age"/>
        <part localType="address">{if(fn:normalize-space($path/*:address)!='')then getAddress($path/*:address)}</part>
        <part localType="origPlace"/>
        <part localType="xprRef">{$path/@ref => fn:normalize-space()}</part>
      </targetEntity>
      <relationType id="{$relationTypeId}" valueURI="https://www.ica.org/standards/RiC/ontology#hasOrHadController" vocabularySource="RiC-O" vocabularySourceURI="https://www.ica.org/standards/RiC/ontology" sourceReference="{$sourcesRef}">rico:hasOrHadController</relationType>
      <targetRole target="{$relationTypeId}">magistrat</targetRole>
      if($path/*:persName/*:note[fn:normalize-space(.)!='']) then(
        <descriptiveNote>
          <p>{$path/*:persName/*:note => fn:normalize-space()}</p>
        </descriptiveNote>)
    </relation>

  let $witnesses :=
    for $witness in $induction/*:description/*:manners/*:witnesses/*:witness
    return (
      let $path := $witness
      let $relationTypeId := fn:generate-id($path)
      return
        <relation xmlns="https://archivists.org/ns/eac/v2" target="{$eventId}" sourceReference="{$sourcesRef}">
          <targetEntity targetType="person">
            <part localType="full">{$path/*:persName/*:surname || ', ' || $path/*:persName/*:forename}</part>
            <part localType="status">{$path/*:occupation => fn:normalize-space()}</part>
            <part localType="occupationType"></part>
            <part localType="age">{fn:normalize-space($path/*:age)}</part>
            <part localType="address">{if(fn:normalize-space($path/*:address)!='')then getAddress($path/*:address)}</part>
            <part localType="origPlace"/>
            <part localType="xprRef">{$path/*:persName/@ref => fn:normalize-space()}</part>
          </targetEntity>
          <relationType id="{$relationTypeId}" valueURI="https://www.ica.org/standards/RiC/ontology#knownBy" vocabularySource="RiC-O" vocabularySourceURI="https://www.ica.org/standards/RiC/ontology" sourceReference="{$sourcesRef}">rico:knownBy</relationType>
          <targetRole target="{$relationTypeId}">témoin</targetRole>
          {if($path/*:persName/*:note[fn:normalize-space(.)!=''] 
          or $path/*:signature[fn:normalize-space(.)='true']) then(
          <descriptiveNote>{
            if($path/*:persName/*:note[fn:normalize-space(.)!='']) then <p>{$path/*:persName/*:note => fn:normalize-space()}</p>,
            if($path/*:signature[fn:normalize-space(.)='true']) then <p>Signature de l’information de vie et mœurs (maîtrise en l’art de maçonnerie) : {getBoolean($path/*:signature => fn:normalize-space())}</p>
          }</descriptiveNote>)}
        </relation>
    )

  let $patrons :=
    for $patron in $induction/*:description/*:masterpiece/*:patrons/*:patron
    return (
      let $path := $patron
      let $relationTypeId := fn:generate-id($path)
      return
        <relation xmlns="https://archivists.org/ns/eac/v2" target="{$eventId}" sourceReference="{$sourcesRef}">
          <targetEntity targetType="person">
            <part localType="full">{$path/*:persName/*:surname || ', ' || $path/*:persName/*:forename}</part>
            <part localType="status">{$path/*:occupation => fn:normalize-space()}</part>
            <part localType="occupationType"></part>
            <part localType="age">{fn:normalize-space($path/*:age)}</part>
            <part localType="address">{if(fn:normalize-space($path/*:address)!='')then getAddress($path/*:address)}</part>
            <part localType="origPlace"/>
            <part localType="xprRef">{$path/*:persName/@ref => fn:normalize-space()}</part>
          </targetEntity>
          <relationType id="{$relationTypeId}" valueURI="https://www.ica.org/standards/RiC/ontology#hasOrHadController" vocabularySource="RiC-O" vocabularySourceURI="https://www.ica.org/standards/RiC/ontology" sourceReference="{$sourcesRef}">rico:hasOrHadController</relationType>
          <targetRole target="{$relationTypeId}">examinateur</targetRole>
          {if($path/*:persName/*:note[fn:normalize-space(.)!=''] 
            or $path[@citedInRuling='true']
            or $path[@oldest='true']) then(
          <descriptiveNote>{
            if($path/*:persName/*:note[fn:normalize-space(.)!='']) then <p>{$path/*:persName/*:note => fn:normalize-space()}</p>,
            if($path[@citedInRuling='true']) then <p>Mentionné dans l’ordonnance (maîtrise en l’art de maçonnerie).</p>,
            if($path[@oldest='true']) then <p>Doyen (maîtrise en l’art de maçonnerie).</p>
          }</descriptiveNote>)}
        </relation>
    )

  return (
    updateExpert($expert, $sources, $event, $place, $petitionMagistrate, $petitionSyndic, $mannersMagistrate, $witnesses, $patrons)
  )
};

declare %updating function updateExpert($expert, $sources, $event, $place, $petitionMagistrate, $petitionSyndic, $mannersMagistrate, $witnesses, $patrons) {
  if($expert!='' and $expert!='xpr0127' and $expert!='xpr0109' and $expert!='xpr0005') then
  let $eac := db:open('xpr', 'xpr/biographies/'||$expert||'.xml')
  return(
    copy $d := $eac
    modify (
      if($d/*:eac/*:control/*:sources) then insert nodes $sources as last into $d/*:eac/*:control/*:sources
      else insert node <sources xmlns="https://archivists.org/ns/eac/v2">{$sources}</sources> after $d/*:eac/*:control/*:maintenanceHistory,
      
      insert node $event as last into $d/*:eac/*:cpfDescription/*:description/*:biogHist/*:chronList,
      
      if(fn:normalize-space($place)!='') then (
        if($d/*:eac/*:cpfDescription/*:description/*:places) then insert node $place as last into $d/*:eac/*:cpfDescription/*:description/*:places
        else insert node <places xmlns="https://archivists.org/ns/eac/v2">{$place}</places> before $d/*:eac/*:cpfDescription/*:description/*:existDates  
      ),
      insert nodes ($petitionMagistrate, $petitionSyndic, $mannersMagistrate, $witnesses, $patrons) as last into $d/*:eac/*:cpfDescription/*:relations
    )
    return db:replace('xpr', 'xpr/biographies/'||$expert||'.xml', $d)
  ) 
};

declare function getAddress($address) {
let $addr :=
  for $line in $address/*[fn:normalize-space(.)!='']
  return (
    switch ($line/fn:local-name())
      case "street" return "rue " || $line => fn:normalize-space()
      case "parish" return "paroisse " || $line => fn:normalize-space()
      default return $line => fn:normalize-space()
  )
return fn:string-join($addr, ', ')

};

declare function getBoolean($value) {

  switch ($value)
      case "true" return "oui"
      case "false" return "non"
      default return ''
};

transformInductions()