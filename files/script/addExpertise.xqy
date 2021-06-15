xquery version "3.1";
(:
 : author @emchateau & @sardinecan
 : 2020-10
 : this script adds expertises from various xpr ressources into expert db
:)
declare default element namespace "xpr" ;

(:
 : path to xprdata files
 : @rmq to be modified for online/local use
 : @sardinecan : /Volumes/data/github/experts/xprdata/
 : @huma-num server : /sites/expertdb/resource/data/
:)
declare variable $path := '/sites/expertdb/resource/data/';

(:
 : Z1j resources
:)
declare variable $z1j_JH := $path || 'z1j/z1j_JH.xml';
declare variable $gip_JH := $path || 'z1j/gip_JH.xml';
declare variable $z1j_LL := $path || 'z1j/z1j_LL.xml';
declare variable $gip_LL := $path || 'z1j/gip_LL.xml';
declare variable $z1j_YP := $path || 'z1j/z1j_YP.xml';

(:
 : assembling z1j resources
:)
declare variable $expertises :=
<expertises xmlns="xpr">
  {
    fn:doc($z1j_JH)//expertise,
    fn:doc($gip_JH)//expertise,
    fn:doc($z1j_LL)//expertise,
    fn:doc($gip_LL)//expertise,
    fn:doc($z1j_YP)//expertise
  }
</expertises>
;

declare
%updating
function local:addZ1j() {
 let $db := db:open('xpr')
 return(
  copy $d := $db
  modify (
    for $expertise in $expertises//expertise
    order by $expertise/@xml:id
    return insert node $expertise as last into $d//expertises
  )
  return local:updateDb($d)
 )
};

declare
%updating
function local:updateDb($param) {
  replace node db:open('xpr')/xpr with $param
};

local:addZ1j()