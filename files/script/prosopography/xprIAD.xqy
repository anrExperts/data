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

declare function getIads() {
  let $iad := db:open('xpr', 'xpr/inventories')/*
  return $iad
};

declare function transformIads(){
  for $iad in getIads()

  let $expert := $iad/sourceDesc/expert/@ref => fn:substring-after('#')

  let $date  := $iad/sourceDesc/date/@standardDate

  let $sources := <source id="{"source" || fn:generate-id($iad)}" xmlns="https://archivists.org/ns/eac/v2"><reference href="">{$iad/*:sourceDesc/*:idno[@type='unitid'] => fn:normalize-space()}</reference></source>

  let $sourcesRef := for $source in $sources return "#" || $source/@id

  (:let $place :=
    <place xmlns="https://archivists.org/ns/eac/v2" sourceReference="{$sourcesRef}">
      <date certainty="certain" standardDate="{$date}" sourceReference="" />
      <placeRole>Adresse</placeRole>
      <placeName>{$iad/*:description/*:candidate/*:address/*:street => fn:normalize-space()}</placeName>
      {if($iad/*:description/*:candidate/*:address/*[fn:not(self::*:street)][fn:normalize-space(.)!='']) then
        <address>{
          for $addrLine in $iad/*:description/*:candidate/*:address/*[fn:not(self::*:street)][fn:normalize-space(.)!='']
          return <addressLine>{$addrLine => fn:normalize-space()}</addressLine>
        }</address>
      }
    </place>:)

  let $eventId := "event" || fn:generate-id($iad)
  let $event :=
    <chronItem id="{$eventId}" sourceReference="{$sourcesRef}" localType="death" xmlns="https://archivists.org/ns/eac/v2">
      <date certainty="high" standardDate="{$iad/*:actors/*:deceased/*:deathDate/@standardDate}" />
      <event>Décès</event>
      <place><placeName>{getAddress($iad/*:actors/*:deceased/*:deathPlace)}</placeName></place>
    </chronItem>

  let $notary :=
    let $path := $iad/*:actors/*:notary/*:nameEntry
    let $relationTypeId := fn:generate-id($path)
    return
    <relation xmlns="https://archivists.org/ns/eac/v2" target="{'#' || $eventId}" sourceReference="{$sourcesRef}">
      <targetEntity targetType="person">
        <part localType="full">{fn:string-join($path/*:part, ', ')}</part>
        <part localType="status">Notaire</part>
        <part localType="occupationType"></part>
        <part localType="age"/>
        <part localType="address"/>
        <part localType="origPlace"/>
        <part localType="xprRef"/>
      </targetEntity>
      <relationType id="{$relationTypeId}" valueURI="https://www.ica.org/standards/RiC/ontology#knownBy" vocabularySource="RiC-O" vocabularySourceURI="https://www.ica.org/standards/RiC/ontology" sourceReference="{$sourcesRef}">rico:knownBy</relationType>
      <targetRole target="{'#'||$relationTypeId}">Notaire</targetRole>
    </relation>


  let $executors :=
    for $executor in $iad/*:actors/*:executors/*:executor
    return (
      let $path := $executor
      let $relationTypeId := fn:generate-id($path)
      return
        <relation xmlns="https://archivists.org/ns/eac/v2" target="{'#' || $eventId}" sourceReference="{$sourcesRef}">
          <targetEntity targetType="person">
            <part localType="full">{fn:string-join($path/*:nameEntry/*:part, ', ')}</part>
            <part localType="status">{$path/*:occupation => fn:normalize-space()}</part>
            <part localType="occupationType"></part>
            <part localType="age"></part>
            <part localType="address"></part>
            <part localType="origPlace"/>
            <part localType="xprRef"/>
          </targetEntity>
          <relationType id="{$relationTypeId}" valueURI="https://www.ica.org/standards/RiC/ontology#knownBy" vocabularySource="RiC-O" vocabularySourceURI="https://www.ica.org/standards/RiC/ontology" sourceReference="{$sourcesRef}">rico:knownBy</relationType>
          <targetRole target="{'#'||$relationTypeId}">Exécuteur testamentaire</targetRole>
          {if($path/*:note[fn:normalize-space(.)!='']) then
          <descriptiveNote>
            <p>{$path/*:note => fn:normalize-space()}</p>
          </descriptiveNote>
        }</relation>
    )

  let $spouses :=
    for $spouse in $iad/*:actors/*:weddings/*:wedding
    return (
      let $path := $spouse
      let $relationTypeId := fn:generate-id($path)
      return
        <relation xmlns="https://archivists.org/ns/eac/v2" target="{'#' || $eventId}" sourceReference="{$sourcesRef}">
          <targetEntity targetType="person">
            <part localType="full">{fn:string-join($path/*:spouse/*:nameEntry/*:part, ', ')}</part>
            <part localType="status"></part>
            <part localType="occupationType"></part>
            <part localType="age">{fn:normalize-space($path/*:age)}</part>
            <part localType="address"></part>
            <part localType="origPlace"/>
            <part localType="xprRef"/>
          </targetEntity>
          <relationType id="{$relationTypeId}" valueURI="https://www.ica.org/standards/RiC/ontology#hasOrHadSpouse" vocabularySource="RiC-O" vocabularySourceURI="https://www.ica.org/standards/RiC/ontology" sourceReference="{$sourcesRef}">rico:hasOrHadSpouse</relationType>
          <targetRole target="{'#'||$relationTypeId}">Épouse</targetRole>
          {if (fn:normalize-space($path/*:note)!='' or $path/*:weddingDate[@standardDate!=''] or $path/*:weddingPlace[fn:normalize-space(.)!='']) then
            <descriptiveNote>{
              if($path/*:weddingDate[@standardDate!=''] or $path/*:weddingPlace[fn:normalize-space(.)!='']) then
                <p>{
                  if($path/*:weddingDate[@standardDate!='']) then 'Date du mariage : ' || $path/*:weddingDate/@standardDate,
                  if ($path/*:weddingPlace[fn:normalize-space(.)!='']) then 'Lieu du mariage : ' || $path/*:weddingPlace => fn:normalize-space()
                }</p>,
              if(fn:normalize-space($path/*:note)!='') then
                <p>{$path/*:note => fn:normalize-space()}</p>
            }</descriptiveNote>
        }</relation>
    )

  let $children :=
    for $child in $iad/*:actors/*:children/*:child
    return (
      let $path := $child
      let $relationTypeId := fn:generate-id($path)
      return
        <relation xmlns="https://archivists.org/ns/eac/v2" target="{'#' || $eventId}" sourceReference="{$sourcesRef}">
          <targetEntity targetType="person">
            <part localType="full">{fn:string-join($path/*:nameEntry/*:part, ', ')}</part>
            <part localType="status"></part>
            <part localType="occupationType"></part>
            <part localType="age">{fn:normalize-space($path/*:birthDate/@standardDate)}</part>
            <part localType="address"></part>
            <part localType="origPlace"/>
            <part localType="xprRef"/>
          </targetEntity>
          <relationType id="{$relationTypeId}" valueURI="https://www.ica.org/standards/RiC/ontology#knownBy" vocabularySource="RiC-O" vocabularySourceURI="https://www.ica.org/standards/RiC/ontology" sourceReference="{$sourcesRef}">rico:knownBy</relationType>
                    <targetRole target="{'#'||$relationTypeId}"></targetRole>
          {if (fn:normalize-space($path/*:note)!='') then
            <descriptiveNote>
                <p>{$path/*:note => fn:normalize-space()}</p>
            </descriptiveNote>
        }</relation>
    )

  let $persons :=
    for $person in $iad/*:actors/*:persons/*:person
    return (
      let $path := $person
      let $relationTypeId := fn:generate-id($path)
      return
        <relation xmlns="https://archivists.org/ns/eac/v2" target="{'#' || $eventId}" sourceReference="{$sourcesRef}">
          <targetEntity targetType="person">
            <part localType="full">{fn:string-join($path/*:nameEntry/*:part, ', ')}</part>
            <part localType="status"></part>
            <part localType="occupationType">{fn:normalize-space($path/*:occupation)}</part>
            <part localType="age"></part>
            <part localType="address"></part>
            <part localType="origPlace"/>
            <part localType="xprRef"/>
          </targetEntity>
          <relationType id="{$relationTypeId}" valueURI="https://www.ica.org/standards/RiC/ontology#hasChild" vocabularySource="RiC-O" vocabularySourceURI="https://www.ica.org/standards/RiC/ontology" sourceReference="{$sourcesRef}">rico:hasChild</relationType>
          <targetRole target="{'#'||$relationTypeId}"></targetRole>
          {if (fn:normalize-space($path/*:note)!='' or $path/*:birthDate[@standardDate!=''] or $path/*:birthPlace[fn:normalize-space(.)!=''] or fn:normalize-space($path/*:representative)!='') then
            <descriptiveNote>{
              if($path/*:birthDate[@standardDate!=''] or $path/*:birthPlace[fn:normalize-space(.)!='']) then
                <p>{
                  if($path/*:birthDate[@standardDate!='']) then 'Date de naissance : ' || $path/*:birthDate/@standardDate,
                  if ($path/*:birthPlace[fn:normalize-space(.)!='']) then 'Lieu de naissance : ' || $path/*:birthPlace => fn:normalize-space()
                }</p>,
              if(fn:normalize-space($path/fn:string-join(*:representative))!='') then
                <p>{'Tuteur(s) : ' || fn:string-join($path/*:representative[fn:normalize-space(.)!=''], ' ; ')}</p>,
              if(fn:normalize-space($path/*:note)!='') then
                <p>{$path/*:note => fn:normalize-space()}</p>
            }</descriptiveNote>
        }</relation>
    )

  return (
    $expert, $sources, $event, $executors, $persons
  )
};

declare function getAddress($address) {
let $addr :=
  for $line in $address//*[fn:normalize-space(fn:string-join(text()))!='']
  return (
    switch ($line/fn:local-name())
      case "parish" return "paroisse " || $line => fn:normalize-space()
      default return $line => fn:normalize-space()
  )

return fn:string-join($addr, ', ')

};

transformIads()