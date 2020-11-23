xquery version "3.1";
(:
 : author @emchateau & @sardinecan
 : 2020-10
 : this script create xpr db from various xpr ressources
:)
declare default element namespace "xpr" ;

(:
 : path to xprdata files
 : @rmq to be modified for online/local use
:)
declare variable $path := '/Volumes/data/github/xprdata/';

(:
 : Z1j resources
 : @rmq gip JH needs to be added
:)
declare variable $z1j_JH := $path || 'z1j/z1j_JH.xml';
declare variable $gip_JH := $path || 'z1j/gip_JH.xml';
declare variable $z1j_LL := $path || 'z1j/z1j_LL.xml';
declare variable $gip_LL := $path || 'z1j/gip_LL.xml';

(:
 : prosopo resources
:)
declare variable $experts := $path || 'prosopography/experts.xml';
declare variable $offices := $path || 'prosopography/offices.xml';
declare variable $others := $path || 'prosopography/others.xml';

(:
 : sources resources
:)
declare variable $sources := $path || 'sources/sources.xml';


declare variable $expertises := 
<expertises xmlns="xpr">
  {
    fn:doc($z1j_JH)//expertise,
    fn:doc($gip_JH)//expertise,
    fn:doc($z1j_LL)//expertise,
    fn:doc($gip_LL)//expertise
  }
</expertises>
;



declare variable $db :=
<xpr xmlns="xpr" xmlns:rico="rico" xmlns:xlink="http://www.w3.org/1999/xlink">
  <expertises>
    {
    for $expertise in $expertises/expertise
    order by $expertise/@xml:id
    return $expertise
    }
  </expertises>
  <bio xmlns:xpr="xpr" xmlns:rico="rico">
    {
    fn:doc($experts)//*:eac-cpf,
    fn:doc($others)//*:eac-cpf,
    fn:doc($offices)//*:eac-cpf
    }
  </bio>
  <posthumousInventories/>
  {
    fn:doc($sources)
  }
</xpr>;

declare
%updating
function local:mkdb() {
    db:create(
    'xpr',
    $db,
    'xpr.xml',
    map{
      'ftindex': true(),
      'stemming': true(),
      'casesens': true(),
      'diacritics': true(),
      'language': 'fr',
      'updindex': true(),
      'autooptimize': true(),
      'maxlen': 96,
      'maxcats': 100,
      'splitsize': 0,
      'chop': false(),
      'textindex': true(),
      'attrindex': true(),
      'tokenindex': true(),
      'xinclude': true()
    }
  )
};

local:mkdb()