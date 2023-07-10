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
for $date in fn:sort(getDates())
let $ids := $data[*:date = fn:string($date)]//*:id
return (
    "************"|| $date ||"************",
    stats($ids)
),
"************RANDOM************",
let $max := 500
let $random := for $i in 1 to $max let $randomPos := random:integer(fn:count($data//*:id)) return $data[$randomPos]/*:id
return (
    stats($random),
    for $date in fn:sort(getDates())
    let $corpus := for $id in $random return $data[*:id = $id]
    return $date || " : " || fn:count($corpus[*:date = fn:string($date)]) || " | " || fn:round(fn:count($corpus[*:date = fn:string($date)]) * 100 div $max) || "%",
    $random
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
    "Architecte-Entrepreneur : " || fn:count($corpus[descendant::*:nbExperts="2"][*:columns = "architecte entrepreneur"]) || " | " || fn:round(fn:count($corpus[descendant::*:nbExperts="2"][*:columns = "architecte entrepreneur"]) * 100 div fn:count($corpus))  || "%"
    (:for $date in fn:sort(getDates()) return $date || " : " || fn:count($corpus[*:date[fn:normalize-space(.)=fn:string($date)]]):)
)
};

declare function getCorpus() {
   db:open('xpr')/xpr/expertises/expertise
};

declare function getDates() {
   let $corpus := getCorpus()
   return fn:distinct-values($corpus//sessions/date[1][@when castable as xs:date][fn:ends-with(fn:string(fn:year-from-date(@when)), '6')]/fn:year-from-date(@when))
};

declare function getCategories() {
   let $corpus := getCorpus()
   return fn:distinct-values($corpus//categories/category/@type)
};

declare variable $data :=
let $expertises := db:open('xpr')/xpr/expertises/expertise
let $experts := db:open('xpr')/xpr/bio/*:eac
return
    for $expertise in $expertises
    order by $expertise/@xml:id
    let $id := $expertise/@xml:id => fn:normalize-space()
    let $thirdParty := fn:boolean($expertise/descendant::*:experts/*:expert[@context='third-party'])
    let $date := $expertise//sessions/date[1][@when castable as xs:date][fn:ends-with(fn:string(fn:year-from-date(@when)), '6')]/fn:year-from-date(@when)
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
    </record>;

getStats()
