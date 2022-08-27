xquery version "3.1";

declare namespace xpr = "xpr" ;
declare namespace eac = "eac" ;
declare namespace rico = "rico" ;
declare namespace xf = "http://www.w3.org/2002/xforms" ;
declare namespace xlink = "http://www.w3.org/1999/xlink" ;

declare default element namespace "xpr" ;
declare default function namespace "xpr.xpr" ;

import module namespace functx = "http://www.functx.com";

declare default collation "http://basex.org/collation?lang=fr" ;

declare function rawData() {
  let $db := db:open('xpr')
  let $bio := $db//bio/eac:eac-cpf
  return $bio
};

declare function changeNS($input) {
  for $instance in $input
  return functx:change-element-ns-deep($instance, 'urn:isbn:1-931666-33-4','')
};

declare function updateRawData($input) {
  for $instance in $input
  return (
    copy $d := $instance
    modify (
      let $id := $d/@xml:id => fn:normalize-space()
      return (
        insert nodes (
          <recordId xmlns="urn:isbn:1-931666-33-4">{$id}</recordId>,
          <publicationStatus xmlns="urn:isbn:1-931666-33-4">inProcess</publicationStatus>,
          <maintenanceAgency xmlns="urn:isbn:1-931666-33-4"><agencyName>projet Experts</agencyName></maintenanceAgency>
        ) as first into $d//*:control,
        delete node $d//*:control/*:publicationStatus[fn:normalize-space(.)=''],
        delete node $d//*:control/*:localControl[@localType='detailLevel'],
        for $eventType in $d//*:maintenanceEvent[fn:normalize-space(*:eventType)='retroconverted']/*:eventType
        return replace value of node $eventType with 'updated'
      )
    )
    return $d
  )
};

declare function convert($input) {
  (:let $xslt := 'http://localhost:8984/static/eacForms/files/xslt/eac1-to-eac2.xsl':)
  (:@rmq with Basex 10 fetch:xml => fetch:doc :)
  let $xslt := fetch:xml('https://raw.githubusercontent.com/SAA-SDT/eac1-to-eac2-conversion/main/eac1-to-eac2.xsl')
  for $instance in $input
  return xslt:transform($instance, $xslt)
};

declare function clean($input) {
  for $instance in $input
  return (
    copy $d := $instance
    modify(
      delete nodes $d//*:participant[fn:normalize-space(@href)=''],
      delete nodes $d//*:involve[fn:normalize-space(@href)=''],
      delete nodes $d//*:source[fn:normalize-space(@href)=''],
      delete nodes $d//*:cost,
      delete nodes $d//@notBefore[fn:normalize-space(.)=''],
      delete nodes $d//@notAfter[fn:normalize-space(.)=''],
      delete nodes $d//*:date[fn:string-join(@*) = ''],
      delete nodes $d//*:fromDate[parent::*:dateRange/*:toDate[fn:string-join(@*) = '']][fn:string-join(@*) = ''],
      delete nodes $d//*:toDate[parent::*:dateRange/*:fromDate[fn:string-join(@*) = '']][fn:string-join(@*) = ''],
      delete nodes $d//*:dateRange[fn:string-join(./*/@*) = ''],
      delete nodes $d//*:dateSet,
      delete nodes $d//*:place[fn:normalize-space(.)=''],
      delete nodes $d//*:description/*:places,
      delete nodes $d//*:placeName[fn:normalize-space(.)=''],
      delete nodes $d//*:descriptiveNote[fn:normalize-space(.)=''],
      delete nodes $d//*:functions[fn:normalize-space(.)=''],
      delete nodes $d//*:occupations[fn:normalize-space(.)=''],
      delete nodes $d//*:description//*:reference,
      delete node $d//*:control/*:sources,
      delete node $d//*:bibl,
      delete node $d//*:conventionDeclaration,
      delete nodes $d//@conventionDeclarationReference,
      delete node $d//processing-instruction(),
      if($d//*:comment[fn:normalize-space(.)!='']) then (
        for $comment in $d//*:comment[fn:normalize-space(.)!='']
        return insert node comment {$d//*:comment} as first into $d/*:eac
      ),
      delete nodes $d//*:comment,
      delete nodes $d//*:cpfDescription//comment(),
      for $date in $d//*[fn:local-name() = 'date' or fn:local-name() = 'fromDate' or fn:local-name()='toDate']
      return insert node attribute certainty {} into $date
    )
    return $d
  )
};

declare function sources($input) {
  for $instance in $input[descendant::*:cpfDescription//*:source[fn:normalize-space(@href)!='']]
  return (
    copy $d := $instance
    modify(
      insert node
      <sources xmlns="https://archivists.org/ns/eac/v2">{
        for $source in fn:distinct-values($d//*:cpfDescription//*:source[fn:normalize-space(@href)!='']/@href)
        return <source id="{'source' || fn:generate-id(<node>{$source}</node>)}"><reference id="{'reference' || fn:generate-id(<node>{$source}</node>)}" href="{$source}">{db:open('xpr')/*:xpr/*:sources/*:source[@xml:id=fn:substring-after($source, '#')] => fn:normalize-space()}</reference></source>
      }</sources> after $d//*:control/*:maintenanceHistory
    )
    return $d
  )
};

declare function sourceReference($input) {
  for $instance in $input
  return (
    copy $d := $instance
    modify(
      for $smthg in $d//*:cpfDescription//*[*:source]
        let $ref := for $ref in $smthg/*:source/@href return '#' || $d//*:control/*:sources/*:source/*:reference[@href=$ref]/@id => fn:normalize-space()
        return (
          insert node attribute sourceReference {fn:string-join($ref, ' ')} into $smthg,
          delete nodes $smthg//*:source
        )
    )
    return $d
  )
};

declare function events($input) {
  for $instance in $input
  return (
    copy $d := $instance
    modify(
      for $event in $d//*:chronItem
      return insert node attribute id {'event' || fn:generate-id($event)} into $event
    )
    return $d
  )
};

declare function relations($input) {
  for $instance in $input[descendant::*:participant[fn:normalize-space(@href)!=''] or descendant::*:involve[fn:normalize-space(@href)!='']]
  return (
    copy $d := $instance
    modify(
      insert node
      <relations xmlns="https://archivists.org/ns/eac/v2">{
        for $relation in fn:distinct-values($d//*[fn:local-name() = 'participant' or fn:local-name() = 'involve']/@href)
        let $sourceReference := for $chrontItem in $d//*:chronItem[descendant::*/@href = $relation] return $chrontItem/@sourceReference => fn:normalize-space()
        let $eventReference := for $event in $d//*:chronItem[descendant::*/@href = $relation] return '#' || $event/@id => fn:normalize-space()
        let $entity := db:open('xpr')//*:eac-cpf[@xml:id=fn:substring-after($relation, '#')]
        let $entityName := $entity//*:nameEntry[*:authorizedForm]/*:part => fn:normalize-space()
        let $entityType := $entity//*:entityType => fn:normalize-space()
        return <relation target="{fn:string-join($eventReference, ' ')}" sourceReference="{fn:string-join($sourceReference, ' ')}"><targetEntity target="{$relation}" targetType="{$entityType}"><part localType="">{$entityName}</part></targetEntity></relation>
      }</relations> as last into $d//*:cpfDescription,
      delete nodes $d//*[fn:local-name() = 'participant' or fn:local-name() = 'involve']
    )

    return $d
  )
};

declare function entityType($input) {
  for $instance in $input[descendant::*:identity[@localType]]
  return (
    copy $d := $instance
    modify(
      insert node
      <otherEntityTypes xmlns="https://archivists.org/ns/eac/v2"><otherEntityType><term>{$d//*:identity/@localType => fn:normalize-space()}</term></otherEntityType></otherEntityTypes>
      after $d//*:nameEntry[fn:last()],
      delete node $d//*:identity/@localType
    )
    return $d
  )
};

declare
%updating
function
eac1-to-eac2() {
 let $data := rawData()
 let $changeNS := changeNS($data)
 let $update := updateRawData($changeNS)
 let $convert := convert($update)
 let $clean := clean($convert)
 let $sources := sources($clean)
 let $sourceReference := sourceReference($sources)
 let $events := events($sourceReference)
 let $relations := relations($events)
 let $entityType := entityType($relations)
 return(
  delete nodes db:open('xpr')/*:xpr/*:bio/*,
  for $entity in $entityType
  return insert node $entity as last into db:open('xpr')/*:xpr/*:bio
 )
};
eac1-to-eac2()

