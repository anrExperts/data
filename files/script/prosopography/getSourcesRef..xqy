xquery version "3.1";
(:
 : author @sardinecan
 : 2021-02-17
 : this script updates the event label (maintenance history) for z1j files
 : just run it !
:)
declare namespace rest = "http://exquery.org/ns/restxq" ;
declare namespace file = "http://expath.org/ns/file" ;
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization" ;
declare namespace db = "http://basex.org/modules/db" ;
declare namespace web = "http://basex.org/modules/web" ;
declare namespace update = "http://basex.org/modules/update" ;
declare namespace perm = "http://basex.org/modules/perm" ;
declare namespace user = "http://basex.org/modules/user" ;
declare namespace session = 'http://basex.org/modules/session' ;
declare namespace http = "http://expath.org/ns/http-client" ;

declare namespace ev = "http://www.w3.org/2001/xml-events" ;
declare namespace eac = "eac" ;

declare namespace map = "http://www.w3.org/2005/xpath-functions/map" ;
declare namespace xf = "http://www.w3.org/2002/xforms" ;
declare namespace xlink = "http://www.w3.org/1999/xlink" ;

declare namespace xpr = "xpr" ;
declare default element namespace "xpr" ;

declare
%updating
function local:getSourcesRef() {
  let $bio := db:open('xpr')/xpr/bio
  return (
    copy $d := $bio
    modify (
      for $source in $d//*:source[fn:normalize-space(@xlink:href) !='']
      let $href := $source/@xlink:href => fn:normalize-space()
      let $idSource := db:open('xpr')/xpr/sources/source[fn:normalize-space(.) = $href]/@xml:id
      let $ref := '#' || $idSource
      return replace value of node $source/@xlink:href with $ref
    )
    return replace node db:open('xpr')/xpr/bio with $d
  )
};


local:getSourcesRef()