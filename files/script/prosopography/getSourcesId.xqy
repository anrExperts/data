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

(:
 : this function adds maintenance event to expertise with old eventType label
 : @returned updated expertise with new eventType label
 :)
declare
%updating
function local:getSourcesId() {
  let $sources := db:open('xpr')/xpr/sources
  return (
    copy $d := $sources
    modify (
      for $source in $d/source[not(@xml:id)]
      let $id := "xprSource" || fn:generate-id($source)
      return insert node attribute xml:id {$id} into $source
    )
    return replace node db:open('xpr')/xpr/sources with $d
  )
};

local:getSourcesId()