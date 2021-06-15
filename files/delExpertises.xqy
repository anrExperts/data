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

declare variable $expertises := <expertises xmlns="xpr"/> ;

declare
%updating
function local:cleanExpertises() {
  replace node db:open('xpr')//expertises with $expertises
};


local:cleanExpertises()