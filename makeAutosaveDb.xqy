xquery version "3.1";
(:
 : author @emchateau & @sardinecan
 : 2020-10
 : this script create xpr db from various xpr ressources
:)
declare default element namespace "xpr" ;

(:
 : autosave db
:)
declare variable $db :=
<xpr xmlns="xpr" xmlns:rico="rico" xmlns:xlink="http://www.w3.org/1999/xlink">
  <expertises/>
  <bio xmlns:xpr="xpr" xmlns:rico="rico"/>
  <posthumousInventories/>
  <sources/>
</xpr>;

(:
 : database creation
:)
declare
%updating
function local:mkasdb() {
    db:create(
    'xprAutosave',
    $db,
    'xprAutosave.xml',
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

local:mkasdb()