xquery version "3.1";
(:~
 : This xquery module is an application for xpr
 :
 : @author sardinecan & emchateau (ANR Experts)
 : @since 2022-12
 : @licence GNU http://www.gnu.org/licenses
 : @version 0.2
 :
 : xpr is free software: you can redistribute it and/or modify
 : it under the terms of the GNU General Public License as published by
 : the Free Software Foundation, either version 3 of the License, or
 : (at your option) any later version.
 :
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
declare namespace json = "http://basex.org/modules/json" ;
declare namespace eac = "https://archivists.org/ns/eac/v2";

declare namespace xpr = "xpr" ;
declare default function namespace "xpr" ;

declare default collation "http://basex.org/collation?lang=fr" ;

declare function getdb() {
  db:open('xpr', 'xpr/biographies')
};

declare %updating function hashtag() {
  for $b in getdb()//@*[fn:local-name() = ('sourceReference', 'target')]
  return replace value of node $b with fn:replace($b, '#', '')
};

declare %updating function maintenanceStatus() {
  for $ms in getdb()//@maintenanceStatus[fn:normalize-space(.)='updated']
  return replace value of node $ms with 'revised'
};

declare %updating function dateSR() {
  for $sr in getdb()//*[fn:local-name() = ('date', 'fromDate', 'toDate')][fn:not(ancestor::eac:existDates)][fn:normalize-space(@sourceReference)='']
  return delete node $sr/@sourceReference
};

declare %updating function relationNote() {
  for $rel in getdb()//eac:relation[*[1][self::eac:descriptiveNote]]
  let $dn := $rel/eac:descriptiveNote
  return (
    delete node $rel/eac:descriptiveNote,
    insert node $dn as last into $rel

  )
};

declare %updating function relationDate() {
  for $rel in getdb()//eac:relation[*[fn:local-name() = ('date', 'dateRange', 'dateSet')]]
  let $d := $rel/*[fn:local-name() = ('date', 'dateRange', 'dateSet')]
  return (
    delete node $rel/*[fn:local-name() = ('date', 'dateRange', 'dateSet')],
    insert node $d after $rel/eac:targetEntity

  )
};

declare %updating function places() {
  for $d in getdb()//eac:description[eac:places/following-sibling::eac:occupations]
  let $p := $d/eac:places
  return (
    delete node $d/eac:places,
    insert node $p after $d/eac:occupations
  )
};

declare %updating function placesLD() {
  for $d in getdb()//eac:description[eac:places/following-sibling::eac:localDescriptions][fn:not(eac:occupations)]
  let $p := $d/eac:places
  return (
    delete node $d/eac:places,
    insert node $p after $d/eac:localDescriptions
  )
};

hashtag(), maintenanceStatus(), dateSR(), relationNote(), relationDate(), places(), placesLD()