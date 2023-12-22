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

declare function transformInductions(){
  for $induction in getInductions()

  let $expert := $induction/description/candidate/persName/@ref => fn:substring-after('#')

  let $date  := $induction/description/masterpiece/date[@type='induction']/@when

  let $sources :=
    for $s in $induction/sourceDesc/source
    let $sourceId := "source" || fn:generate-id($s)
    return <source id="{$sourceId}" xmlns="https://archivists.org/ns/eac/v2"><reference href="">{$s/*:unitid => fn:normalize-space()}</reference></source>

  let $sourcesRef := for $source in $sources return "#" || $source/@id

  let $place :=
    <place xmlns="https://archivists.org/ns/eac/v2" sourceReference="{$sourcesRef}">
      <date certainty="certain" standardDate="{$date}" sourceReference="" />
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
        if($induction/*:description/*:petition/*:date[fn:normalize-space(@when)!='']) then <date certainty="certain" standardDate="{$induction/*:description/*:petition/*:date/@when}" sourceReference="" >Supplique</date>,
        if($induction/*:description/*:petition/*:syndicCommunication/*:date[fn:normalize-space(@when)!='']) then <date certainty="certain" standardDate="{$induction/*:description/*:petition/*:syndicCommunication/*:date/@when}" sourceReference="" >Communication au syndic</date>,
        if($induction/*:description/*:petition/*:syndicCommunication/*:response[fn:normalize-space(@when)!='']) then <date certainty="certain" standardDate="{$induction/*:description/*:petition/*:syndicCommunication/*:response/@when}" sourceReference="" >Réponse du syndic</date>,
        if($induction/*:description/*:manners/*:date[@type='ruling'][fn:normalize-space(@when)!='']) then <date certainty="certain" standardDate="{$induction/*:description/*:manners/*:date[@type='ruling']/@when}" sourceReference="" >Ordonnance de soit fait</date>,
        if($induction/*:description/*:manners/*:date[@type='manners'][fn:normalize-space(@when)!='']) then <date certainty="certain" standardDate="{$induction/*:description/*:manners/*:date[@type='manners']/@when}" sourceReference="" >Information de vie et de mœurs</date>,
        if($induction/*:description/*:masterpiece/*:date[@type='ruling'][fn:normalize-space(@when)!='']) then <date certainty="certain" standardDate="{$induction/*:description/*:masterpiece/*:date[@type='ruling']/@when}" sourceReference="" >Ordonnance</date>,
        if($induction/*:description/*:masterpiece/*:date[@type='certificate'][fn:normalize-space(@when)!='']) then <date certainty="certain" standardDate="{$induction/*:description/*:masterpiece/*:date[@type='certificate']/@when}" sourceReference="" >Certificat</date>,
        if($induction/*:description/*:masterpiece/*:drawing/*:date[fn:normalize-space(@when)!='']) then <date certainty="certain" standardDate="{$induction/*:description/*:masterpiece/*:drawing/*:date/@when}" sourceReference="" >Tracer et dessiner sur des cartons le trait géométrique</date>,
        if($induction/*:description/*:masterpiece/*:stoneModel/*:date[fn:normalize-space(@when)!='']) then <date certainty="certain" standardDate="{$induction/*:description/*:masterpiece/*:stoneModel/*:date/@when}" sourceReference="" >Réalisation du modèle en pierre</date>,
        if($induction/*:description/*:masterpiece/*:date[@type='induction'][fn:normalize-space(@when)!='']) then <date certainty="certain" standardDate="{$induction/*:description/*:masterpiece/*:date[@type='induction']/@when}" sourceReference="" >Réception</date>
      }</dateSet>
      <event>Maîtrise de maçon</event>
    </chronItem>

  let $petitionMagistrate :=
    let $path := $induction/*:description/*:petition/*:magistrate
    let $relationTypeId := fn:generate-id($path)
    return
    <relation xmlns="https://archivists.org/ns/eac/v2" target="{'#' || $eventId}" sourceReference="{$sourcesRef}">
      <targetEntity targetType="person">
        <part localType="full">{$path/*:surname || ', ' || $path/*:forename}</part>
        <part localType="status">{$path/*:note => fn:normalize-space()}</part>
        <part localType="occupationType"></part>
        <part localType="age"/>
        <part localType="address"/>
        <part localType="origPlace"/>
        <part localType="xprRef"/>
      </targetEntity>
      <relationType id="{$relationTypeId}" valueURI="" vocabularySource="RiC-O" vocabularySourceURI="https://www.ica.org/standards/RiC/ontology" sourceReference="{$sourcesRef}"></relationType>
      <targetRole target="{'#'||$relationTypeId}"></targetRole>
    </relation>

  let $petitionSyndic :=
    let $path := $induction/*:description/*:petition/*:syndicCommunication/*:syndic
    let $relationTypeId := fn:generate-id($path)
    return
    <relation xmlns="https://archivists.org/ns/eac/v2" target="{'#' || $eventId}" sourceReference="{$sourcesRef}">
      <targetEntity targetType="person">
        <part localType="full">{$path/*:surname || ', ' || $path/*:forename}</part>
        <part localType="status"/>
        <part localType="occupationType"></part>
        <part localType="age"/>
        <part localType="address"/>
        <part localType="origPlace"/>
        <part localType="xprRef"/>
      </targetEntity>
      <relationType id="{$relationTypeId}" valueURI="" vocabularySource="RiC-O" vocabularySourceURI="https://www.ica.org/standards/RiC/ontology" sourceReference="{$sourcesRef}"></relationType>
      <targetRole target="{'#'||$relationTypeId}"></targetRole>
      <descriptiveNote>
        <p>{$path/*:note => fn:normalize-space()}</p>
      </descriptiveNote>
    </relation>

  let $mannersMagistrate :=
    let $path := $induction/*:description/*:manners/*:magistrate
    let $relationTypeId := fn:generate-id($path)
    return
    <relation xmlns="https://archivists.org/ns/eac/v2" target="{'#' || $eventId}" sourceReference="{$sourcesRef}">
      <targetEntity targetType="person">
        <part localType="full">{$path/*:surname || ', ' || $path/*:forename}</part>
        <part localType="status"/>
        <part localType="occupationType"></part>
        <part localType="age"/>
        <part localType="address">{if(fn:normalize-space($path/*:address)!='')then getAddress($path/*:address)}</part>
        <part localType="origPlace"/>
        <part localType="xprRef"/>
      </targetEntity>
      <relationType id="{$relationTypeId}" valueURI="" vocabularySource="RiC-O" vocabularySourceURI="https://www.ica.org/standards/RiC/ontology" sourceReference="{$sourcesRef}"></relationType>
      <targetRole target="{'#'||$relationTypeId}"></targetRole>
      <descriptiveNote>
        <p>{$path/*:note => fn:normalize-space()}</p>
      </descriptiveNote>
    </relation>

  let $witnesses :=
    for $witness in $induction/*:description/*:manners/*:witnesses/*:witness
    return (
      let $path := $witness
      let $relationTypeId := fn:generate-id($path)
      return
        <relation xmlns="https://archivists.org/ns/eac/v2" target="{'#' || $eventId}" sourceReference="{$sourcesRef}">
          <targetEntity targetType="person">
            <part localType="full">{$path/*:persName/*:surname || ', ' || $path/*:persName/*:forename}</part>
            <part localType="status">{$path/*:occupation => fn:normalize-space()}</part>
            <part localType="occupationType"></part>
            <part localType="age">{fn:normalize-space($path/*:age)}</part>
            <part localType="address">{if(fn:normalize-space($path/*:address)!='')then getAddress($path/*:address)}</part>
            <part localType="origPlace"/>
            <part localType="xprRef"/>
          </targetEntity>
          <relationType id="{$relationTypeId}" valueURI="https://www.ica.org/standards/RiC/ontology#knownBy" vocabularySource="RiC-O" vocabularySourceURI="https://www.ica.org/standards/RiC/ontology" sourceReference="{$sourcesRef}">rico:knownBy</relationType>
          <targetRole target="{'#'||$relationTypeId}">témoin</targetRole>
          <descriptiveNote>
            <p>{$path/*:persName/*:note => fn:normalize-space()}</p>
          </descriptiveNote>
        </relation>
    )

  let $patrons :=
    for $patron in $induction/*:description/*:masterpiece/*:patrons/*:patron
    return (
      let $path := $patron
      let $relationTypeId := fn:generate-id($path)
      return
        <relation xmlns="https://archivists.org/ns/eac/v2" target="{'#' || $eventId}" sourceReference="{$sourcesRef}">
          <targetEntity targetType="person">
            <part localType="full">{$path/*:persName/*:surname || ', ' || $path/*:persName/*:forename}</part>
            <part localType="status">{$path/*:occupation => fn:normalize-space()}</part>
            <part localType="occupationType"></part>
            <part localType="age">{fn:normalize-space($path/*:age)}</part>
            <part localType="address">{if(fn:normalize-space($path/*:address)!='')then getAddress($path/*:address)}</part>
            <part localType="origPlace"/>
            <part localType="xprRef"/>
          </targetEntity>
          <relationType id="{$relationTypeId}" valueURI="https://www.ica.org/standards/RiC/ontology#hasOrHadTeacher" vocabularySource="RiC-O" vocabularySourceURI="https://www.ica.org/standards/RiC/ontology" sourceReference="{$sourcesRef}">rico:hasOrHadTeacher</relationType>
          <targetRole target="{'#'||$relationTypeId}">examinateur</targetRole>
          <descriptiveNote>
            <p>{$path/*:persName/*:note => fn:normalize-space()}</p>
          </descriptiveNote>
        </relation>
    )

  return (
    $expert, $sources, $event, $place, $patrons
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

transformInductions()