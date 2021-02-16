xquery version "3.1";
(:
 : author @sardinecan
 : 2021-02-01
 : this script deletes expertises
 : just run it !
:)
declare default element namespace "xpr" ;

(:
 : this function deletes expertises
:)
declare function local:cleanExpertises() {
  copy $d := db:open('xpr')
  modify (
    for $expertise in $d//expertises/expertise
    return delete node $expertise
  )
  return $d
};

(:
 : database creation
:)
declare
%updating
function local:mkdb() {
let $d := local:cleanExpertises()
return
    db:create(
    'xpr',
    $d,
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