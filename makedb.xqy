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
 : @sardinecan : /Users/josselinmorvan/files/dh/xpr/data/db
 : @huma-num server : /sites/expertdb/resource/data/db
:)
declare variable $path := '/sites/expertdb/resource/data/db';

(:
 : database creation
:)
declare
%updating
function local:mkdb() {
    db:create(
    'xpr',
    $path,
    '',
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