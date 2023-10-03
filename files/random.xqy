xquery version "3.0";
declare namespace xpr = "xpr" ;
declare default element namespace "xpr" ;
declare default function namespace "xpr.xpr" ;


declare function getStats() {
let $ids := $data//*:id
return (
    "************GLOBAL************",
    stats($ids)
),
"

",
for $date in fn:sort(getDates())
let $ids := $data[*:date = $date]//*:id
return (
    "************"|| $date ||"************",
    stats($ids)
),
"

",
let $clerks := ('clrk0059', 'clrk0067', 'clrk0034', 'clrk0061', 'xpr0227', 'clrk0029', 'clrk0042', 'clrk0008', 'clrk0062')
for $clerk in $clerks
  let $name := db:open('xpr', 'xpr/biographies')/*:eac[@xml:id=$clerk]//*:identity/*:nameEntry[1] => fn:normalize-space()
  let $expertises := $data[*:clerks[*:clerk = $clerk]]
  let $dates  := fn:distinct-values($expertises//*:unitdate)
return (
  "************"|| $name ||"************",
  stats($expertises/*:id),
  for $year in fn:distinct-values($expertises//*:date)
  order by $year
  let $subCorpus := $expertises[*:date = $year]
  return (
    "************ " || $year || ' : ' || fn:count($subCorpus) || "************",
    stats($subCorpus/*:id)
  ),
  getRandom($expertises, 50)
)
};

declare function getRandom($expertises, $max) {
let $rng := fn:random-number-generator()
let $permutation := $rng('permute')(1 to fn:count($expertises))
let $r := for $i in 1 to 50 return $permutation[$i]
let $random :=
  for $n in $r return $expertises[$n]/*:id => fn:normalize-space()
let $randomCorpus := for $id in $random return $data[*:id = $id]
return (
  $randomCorpus/fn:normalize-space(*:id),
  stats($randomCorpus/*:id),
  for $date in fn:distinct-values($randomCorpus/*:date)
  order by $date
  let $subCorpus := $randomCorpus[*:date = $date]
  return (
    $date || " : " || fn:count($subCorpus) || " | " || fn:round(fn:count($subCorpus) * 100 div $max) || "%",
    stats($subCorpus/*:id)
  )
)
};

declare function stats($ids){
let $corpus := for $id in $ids return $data[*:id = $id]
let $totalExpertises := fn:count($data//*:id)
return(
    "Nombre d'expertises : " || fn:count($corpus) || "/" || $totalExpertises || " | " || fn:round(fn:count($corpus) * 100 div $totalExpertises)  || "%",
    for $category in getCategories()
    let $countCat := fn:count($corpus[*:category[fn:normalize-space(.)=$category]])
    return ($category || " : " || $countCat || " | " || fn:round($countCat * 100 div fn:count($corpus))  || "%"),
    "Tiers-expertises : " || fn:count($corpus[*:thirdParty = "true"]) || " | " || fn:round(fn:count($corpus[*:thirdParty = "true"]) * 100 div fn:count($corpus))  || "%",
    "Expertises avec 1 experts : " || fn:count($corpus[*:nbExperts="1"]) || " | " || fn:round(fn:count($corpus[*:nbExperts="1"]) * 100 div fn:count($corpus))  || "%",
    "Architecte : " || fn:count($corpus[*:nbExperts="1"][*:columns = "architecte"]) || " | " || fn:round(fn:count($corpus[*:nbExperts="1"][descendant::*:columns = "architecte"]) * 100 div fn:count($corpus))  || "%",
    "Entrepreneur : " || fn:count($corpus[*:nbExperts="1"][*:columns = "entrepreneur"]) || " | " || fn:round(fn:count($corpus[*:nbExperts="1"][descendant::*:columns = "entrepreneur"]) * 100 div fn:count($corpus))  || "%",
    "Expertises avec 2 experts : " || fn:count($corpus[*:nbExperts="2"]) || " | " || fn:round(fn:count($corpus[*:nbExperts="2"]) * 100 div fn:count($corpus))  || "%",
    "2 Architectes : " || fn:count($corpus[descendant::*:nbExperts="2"][*:columns = "architecte"]) || " | " || fn:round(fn:count($corpus[descendant::*:nbExperts="2"][*:columns = "architecte"]) * 100 div fn:count($corpus))  || "%",
    "2 Entrepreneurs : " || fn:count($corpus[descendant::*:nbExperts="2"][*:columns = "entrepreneur"]) || " | " || fn:round(fn:count($corpus[descendant::*:nbExperts="2"][*:columns = "entrepreneur"]) * 100 div fn:count($corpus))  || "%",
    "Architecte-Entrepreneur : " || fn:count($corpus[descendant::*:nbExperts="2"][*:columns = "architecte entrepreneur"]) || " | " || fn:round(fn:count($corpus[descendant::*:nbExperts="2"][*:columns = "architecte entrepreneur"]) * 100 div fn:count($corpus))  || "%

    "
    (:for $date in fn:sort(getDates()) return $date || " : " || fn:count($corpus[*:date[fn:normalize-space(.)=fn:string($date)]]):)
)
};

declare function getCorpus() {
   db:open('xpr', 'xpr/expertises')/*:expertise
};

declare function getDates() {
   let $corpus := getCorpus()
   return fn:distinct-values($corpus//*:unitdate)
};

declare function getCategories() {
   let $corpus := getCorpus()
   return fn:distinct-values($corpus//*:categories/*:category/@type)
};

declare variable $data :=
let $expertises := getCorpus()
let $experts := db:open('xpr', 'xpr/biographies')/*:eac
return
    for $expertise in $expertises
    order by $expertise/@xml:id
    let $id := $expertise/@xml:id => fn:normalize-space()
    let $thirdParty := fn:boolean($expertise/descendant::*:experts/*:expert[@context='third-party'])
    let $date := $expertise//*:unitdate[1]

    (:let $origination := fn:translate($expertise/descendant::*:origination, ' ', ' ') => fn:normalize-space()):)
    let $framework := $expertise/descendant::*:framework/@type => fn:normalize-space()
    let $categories := fn:string-join($expertise/descendant::*:categories/*:category/@type, ', ') => fn:normalize-space()
    let $designation := $expertise/descendant::*:categories/*:designation => fn:normalize-space()
    let $expertsId := $expertise//*:experts/*:expert[fn:normalize-space(@ref)!='']/fn:substring-after(@ref, '#')
    let $functions :=
      for $expertId in $expertsId
      return
        switch ($experts[@xml:id=$expertId]//*:functions)
        case ($experts[@xml:id=$expertId]//*:functions[fn:count(*:function) = 1][*:function/*:term = 'Expert bourgeois']) return 'architecte'
        case ($experts[@xml:id=$expertId]//*:functions[fn:count(*:function) = 1][*:function/*:term = 'Expert entrepreneur']) return 'entrepreneur'
        case ($experts[@xml:id=$expertId]//*:functions[fn:count(*:function) = 1][*:function/*:term = 'Arpenteur']) return 'arpenteur'
        case ($experts[@xml:id=$expertId]//*:functions[fn:count(*:function) >= 2][*:function/*:term = 'Expert entrepreneur' and *:function/*:term = 'Expert bourgeois']) return 'transfuge'
        case ($experts[@xml:id=$expertId]//*:functions[fn:count(*:function) >= 2][*:function/*:term = 'Expert entrepreneur'][fn:not(*:function/*:term = 'Expert bourgeois')]) return 'entrepreneur'
        case ($experts[@xml:id=$expertId]//*:functions[fn:count(*:function) >= 2][*:function/*:term = 'Expert bourgeois'][fn:not(*:function/*:term = 'Expert entrepreneur')]) return 'architecte'
        default return 'unknown'
    let $clerks := for $c in $expertise/descendant::*:clerks/*:clerk[@ref !=''] return element clerk {$c/fn:substring-after(@ref, '#')}
    return
    <record>
      <id>{$id}</id>
      <thirdParty>{$thirdParty}</thirdParty>
      <!--<cell>{$origination}</cell>-->
      <date>{$date}</date>
      <framework>{$framework}</framework>
      <category>{$categories}</category>
      <designation>{$designation}</designation>
      <nbExperts>{fn:count($expertsId)}</nbExperts>
      <columns>{for $function in fn:distinct-values($functions) order by $function return $function}</columns>
      <clerks>{$clerks}</clerks>
    </record>;

getStats()
