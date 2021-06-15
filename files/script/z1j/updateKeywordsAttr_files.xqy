xquery version "3.1";
(:
 : author @sardinecan
 : 2021-02-17
 : add missing @value to keywords/term element
 : just run it !
:)
declare default element namespace "xpr" ;


(:
 : path to xprdata files
 : @rmq to be modified for online/local use
 : @sardinecan : /Volumes/data/github/xprdata/
 : @huma-num : /sites/expertdb/resource/data/
:)
declare variable $path := '/Volumes/data/github/experts/xprdata/';

(:
 : event for maintenance history
:)
declare variable $scriptEvent :=
  <maintenanceEvent xmlns="eac">
    <eventType>updated</eventType>
    <eventDateTime standardDateTime="{fn:current-dateTime()}">{fn:current-dateTime()}</eventDateTime>
    <agentType>machine</agentType>
    <agent>updateKeywordsAttr_files.xqy/BaseX</agent>
    <eventDescription>Ajout des @value pour les mots clés (estates).</eventDescription>
  </maintenanceEvent>;

(:
 : missing @value attributes
:)
declare variable $terms :=
<group type="estates" xmlns="xpr">
  <label>Biens expertisés (nature juridique et caractères)</label>
  <term value="a1">Accessoire</term>
  <term value="a2">Acquêts</term>
  <term value="a3">Biens propres</term>
  <term value="a4">Biens vacants</term>
  <term value="a5">Fruits</term>
  <term value="a6">Meubles</term>
  <term value="a7">Usufruit</term>
  <term value="a8">Maison (re)construite à neuf</term>
  <term value="a9">Maison nouvellement acquise</term>
</group>;


(:
 : this function updates the z1j files
 :)
declare function local:update() {
let $collection := fn:collection($path || 'z1j/')
return
    for $doc at $i in $collection
    where matches(document-uri($doc), '.xml')
    return (
        copy $d := $doc
        modify (
          for $expertise in $d//expertise[descendant::keywords[@group='estates'][term[not(@value)]]]
          let $param := $expertise
          return(
            insert node $scriptEvent as first into $expertise/control/maintenanceHistory,
            for $term in $expertise//keywords[@group='estates']/term[not(@value)]
            return replace node $term with $terms//term[fn:normalize-space(.) = fn:normalize-space($term)]
          )
        )
        return(
            file:create-dir($path || 'temp'),
            file:create-dir($path || 'temp/output'),
            file:write($path || 'temp/output/' || substring-after(document-uri($doc), 'z1j/'), $d)
        )
    )
};

(:
 : this functions inserts maintenance event & adds @value attributes.
 :)
declare
%updating
function local:process($data) {
  insert node $scriptEvent as first into $data/control/maintenanceHistory,
  for $term in $data//keywords[@group='estates']/term[not(@value)]
  return replace node $term with $terms//term[fn:normalize-space(.) = fn:normalize-space($term)]
};

local:update()