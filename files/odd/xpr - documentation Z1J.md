# xpr - documentation Z1J

## meta

@todo maintenir ?

## control

@todo Récupération par ead ?

## sourceDesc

Description de la source

### content : 

	- idno (minOccurs : 2 | maxOccurs : 3)
	- facsimile
	- physDesc

## idno

Un identifiant.

### Attributs :

 - @type : précise le type d'identifiant (cote Z1J | numéro du dossier | doublons)
    - values, closed : unitid | item | supplement

### content : not null

- @type="unitid" : xs:string, regex : (z1j\d{1,4})(-)?(\d{1,4})?
- @type="item" : xs:integer, regex : (\d{1,3})
- @type="supplement" : xs:string, value (closed) : bis | ter

## facsimile

Identifiants des vues (numéros des photos, sans type MIME, sans cote unitid).

### Attributs :

 - @from : première image
    - value : xs:integer, regex : (\d{1,4})
- @to : dernière image
  - value : xs:integer, regex : (\d{1,4})

### content : [empty]

## physdesc

Description physique du procès verbal et des pièces annexes

### content :

- extent
- appendices (facultative)

## extent

Nombre de feuillets d'un procès verbal ou d'une annexe, tiré du récollement, et sans comptage des feuillets blancs.

### content : 

	- xs:string (n cahier(s) de n feuillets si pv)
	- ss:integer (si annexe)

### Attributs :

 - @sketch : existance de croquis sur le procès verbal
   	- value (closed) : true | false

## Appendices

Contient la description physique d'une ou plusieurs pièces annexes.

### content : 

	- appendice

## Appendice

Description physique d'une annexe

### content : 

	- type (minOccurs : 1)
	- extent
	- desc
	- note

## type

Type de pièce annexe

### Attributs

 - @type : précise le type de la pièce annexe (en anglais)
   	- value (closed) : drawing | plan | sketch | rough | proxyPA | proxyNA | petition | other

### content 

​	- xs:string

## desc

Description d'une annexe. Permet de décrire le contenu d'un annexe, pour les dessins et croquis, préciser en plus la technique (au trait, lavé, etc.)  

### content

​	- xs:string

## note

Une note, un commentaire sur une annexe, pour préciser l'auteur, le destinataire de l'annexe ou encore le contexte.

### content

	- xs:string

## description

Contient l'analyse d'une expertise.

### content

- sessions
- places
- categories
- procedure
- participants
- conclusions
- keywords
- analysis
- noteworthy

## Dates de l’expertise : *Noter toutes les dates des vacations, la durée est calculée automatiquement*

- Dates des vacations : [xs:date*, regex AAAA-MM-JJ]

- - Pour chaque vacation indiquer le lieu [xs:sequence, Paris et faubourgs, banlieue, campagne]
  - nombre de vacations [xs:integer, paris/faubourg : demi-journée ; banlieue : demi-journée ; campagne : journée]



## Lieux de l’expertise * *[au moment de l’expertise - plusieurs choix possibles pour une même expertise]*

*Pour chaque lieu :* 



- Lieux de l’expertise [xs:sequence, choix unique] : 

[ ] Paris

[ ] Banlieue

[ ] Campagne

[ ] Indéterminé



- Ville et département (si autre que Paris) : [xs:string]

*[Une expertise peut se dérouler dans plusieurs villes] Il n’est pas prévu de rattacher les informations aux différents lieux, hormis pour les estimations.*



- Voie : [xs:string, autocomplétion]

*12/10/2018 : question soulevée du remplissage auto. du champ rue (pour Paris uniquement) • La BHVP entretient un index des rues de Paris à partir du plan de Verniquet. Valérie doit prendre contact avec un conservateur.*

*Alternative, obtenir le fichier XML des AN*



- Précisions géographiques : [xs:string]

*Ex. “près du croisement de la rue…” et “de la rue…” ou “à l’enseigne…”, etc.*



- Paroisse : [xs:string]

*À renseigner le cas échéant, telle qu’elle apparaît dans le document*



- Expertise au bureau : [choix]

- - [ ] non [onSite]
  - [ ] en partie [mixed]
  - [ ] oui [inDesk]



- Propriétaire, le cas échéant [xs:string] : 

## Type d’expertise

*[description envisagée lors de la réunion du 12/10/2018 - à revoir, confirmer, affiner]*



- Catégories d’expertises [xs:sequence, répétable] : 

[ ] ESTIMER LA VALEUR DES BIENS [*Partage et succession, évaluation en vue d’une vente de biens meubles ou immeubles, etc.*]



[ ] RECEVOIR ET ÉVALUER LE TRAVAIL RÉALISÉ [*Réception d’ouvrages, estimation d’honoraires, défaut de paiement etc.*]



[ ] ENREGISTRER [*Projet de construction (arrêt du Parlement du 18 août 1766), alignement non conflictuel et non estimatif*]



[ ] DÉPARTAGER [*Conflit de voisinage et conflit entre locataire et propriétaire, répartition des frais d’entretien ou de construction d’un mur mitoyen, conflits de fosses d’aisance, prise en charge des réparations locatives etc.*]



[ ] EVALUER LES COÛTS À VENIR [*Réparations à faire*]





- Intitulé de l’expertise : [xs:string ou séquence, citation du type d’expertise (parfois en haut à gauche des pv, parfois intitulé forgé)]

- - préciser si titre forgé ou non [xs:boolean]

## Procédure et cadre de l’expertise

- Procédure [xs:sequence, choix unique] : 

[ ] A/ Commun accord des parties

[ ] B/ Saisie du lieutenant civil (LC) (ou autres, à préciser)

[ ] B1/ Requête auprès du LC pour qu’il demande une expertise

[ ] B2/ Le LC est saisi dans le cadre d’une procédure

[ ] B2a/ LC saisi dans le cadre d’une procédure (Les parties nomment chacune leur expert ou un expert commun)

[ ] B2b/ LC saisi dans le cadre d’une procédure (Le LC nomme un ou deux experts) 

[ ] C/ Cas problématique

### Origine de l’expertise

- Déclenchement de l’expertise [xs:sequence, choix unique] : 

[ ] Les parties

[ ] Une institution



### Intervention d’une institution [répétable pour chaque institution]

*[Attention, le Châtelet intervient automatiquement dans le cadre gracieux de la mise en place de la procédure de l’arrêt du Parlement du 18 août 1766,seulement pour nommer d’office le ou les experts. Ne faut-il pas ajouter alors les successions non litigieuses ? Je pense qu’il faut relever la “nomination d’office”.]*

- Description de l’institution : [xs:sequence + cas ouvert]
- Date de la/des sentence(s) le cas échéant : [xs:date*, regex AAAA-MM-JJ, répétable pour chaque sentence de l’institution]



### Cause de l’expertise : [xs:string, autocomplétion, *entretien, fin de location, nouvelle construction, partage, privilège, réception de travaux, reconstruction de mur mitoyen, etc.*]



### Objet de l’expertise : [xs:sequence,choix multiples]

[ ] Maison

[ ] Terrain

[ ] Ensemble de bâtiments

[ ] Domaine, terres, fief

[ ] Mur

[ ] Fosse d’aisance

[ ] Puits

[ ] Autre (à préciser) :



### Matière de l’expertise ?





## Acteurs de l’expertise*

### Expert*



*Pour chaque expert :* 

- Patronyme [xs:string, nom, prénom, autocomplétion] : 
- Dénomination de l’expert dans l’acte [xs:string, “*architecte” voire “architecte-entrepreneur”*] : 
- Expert nommé en [xs:sequence, choix unique] : 

[ ] premier lieu (primary)

[ ] tiers expert (third-party)

[ ] indéterminé (unknown)

- Expert nommé [xs:sequence, choix unique] :

[ ] d’office (par le lieutenant civil) (court-appointed)

[ ] par les parties (appointed)

[ ] indéterminé (unknown)

### Greffier

- Patronyme : [xs:string, nom, prenom, liste, autocomplétion]

### Parties

*Pour chaque partie*

- Description du ou des individus ou personne(s) morale(s) [xs:string, nom, prénom, qualité, profession, *une même partie peut regrouper plusieurs personnes*]



- Partie [xs:sequence, choix unique] :

[ ] Requérante

[ ] Opposante



- Qualification individuelle [xs:sequence, choix unique]

[ ] Entrepreneur

[ ] Propriétaire

[ ] Co-propriétaire

[ ] Commanditaire

[ ] Héritier

[ ] Voisin

[ ] Locataire

[ ] Principale locataire

[ ] Créancier

[ ] Débiteur

[ ] Fermier judiciaire



- Expert agissant pour cette partie [xs:string, nom, prenom]
- Représentant(s) ou procureur(s) [xs:string, nom(s), qualité(s), répétable] : 
- Partie présente [xs:boolean]
- Partie intervenante [xs:boolean]



### Entrepreneur, architecte ou maître d’œuvre *[N’intervenant pas comme parties, mais présents à l’expertise ou mentionnés]* [xs:boolean]

  Le cas échéant : 

- patronyme : [xs:string, nom, prenom]
- profession : [xs:sequence ?, liste ?]



## Conclusion ou dispositif de l’expertise

- Conclusion [accord ou désaccord des experts (1 avis commun ou plusieurs avis d’experts ?)] [xs:sequence]

- - [ ] Accord
  - [ ] Désaccord
  - [ ] Sans conclusion



- Transcription de toutes les conclusions ou dispositifs des experts [xs:string]

- - montant global (pour les estimations)



- Pour une estimation : 

- - montant global
  - justification de l’estimation [xs:string]



## Coût de l’expertise

- Détail [si mentionné]

Expert(s) : 

Greffier :

Roles :

Papier et contrôle : 

(Plans) :

(Procureurs) :

(Aides) :

Total : 



- Mention(s) de la Bourse commune (des experts ou des greffiers) et détail :

- - [ ] A/ Bourse commune des greffiers :

  - - Montant [xs:string] :

  - [ ] B/ Bourse commune des experts : 

  - - Montant [xs:string] :

  - [ ] C/ Pas de mention de bourse commune



## Mots-clés

### Rubrique spécifique aux expertises techniques

- mots-clés [xs:string, répétable, autocomplétion] 

### Outils et actions de l’expertise [optionnel]

- [xs:string, champ libre, peuvent être mentionnés : les sens, les outils, mais aussi les actions (creusement par un expert, etc.)]

### Rubrique spécifique aux estimations

- mots-clés [xs:string, répétable, autocomplétion]

### Rubrique spécifique au droit

- mots-clés [xs:string, répétable, autocomplétion/checkbox?]





## Commentaires et première analyse

- Passages intéressants [xs:string] : 

## Éléments remarquables [xs:string, champ libre, optionnel]

- : 





------



# Implémentation de l’outil de saisie

- Multi-utilisateurs : OUI
- Gestion concurrente des données : NON
- Stand-alone/web ou les deux : il n’y a pas toujours de connexion aux archives (connexion filaire ?), prévoir de pouvoir travailler en local ? isoler les traitements par série (pour éviter la concurrence si en local) ?
- Modèles de données : pas de contraintes de standardisation, mais export nécessaire en XML-EAD
- Articulation avec l’outil prosopographique : nécessaire pour les entrées d’experts (mais mise à jour distincte)
- Ergonomie : raccourcis clavier, personnalisation de l’environnement, aides et description des champs, auto-complétion, listes, enregistrement automatique, etc.



## Solutions possibles



### CMS Libres et Open source (Omeka-S)

https://omeka.org/s/

Architecture MAMP (MySQL PostgreSQL)





Avantages

- bien documenté, stable, facile à mettre en œuvre
- gestion des rôles d’utilisateurs
- technologies bien maîtrisées par les prestataires potentiels (nuancer pour Omeka)
- gestion native de vocabulaires structurés
- cohérent avec le travail possible sur la prosopographie (



Inconvénients

- données relationnelles sans contrôle du modèle d’implémentation (à moins d’utiliser un CMS en mode API pas le cas d’Omeka).



Omeka-S : séparation back-end et front-end. Difficultés de personnalisation du backend (pb ergonomie).



## Heurist

http://heuristnetwork.org

Architecture LAMP

Personnalisation du SGBDR par interface graphique



Avantages

Facile à déployer

Modèle biographique

Personnalisation des champs possibles

Fonctionnalités d’export (vérifier la qualité de la sortie)

Libre et Open Source

API JSON



Inconvénients

Interface un peu datée

Personnalisation des formulaires sans doute difficile

Pas de publication de sources

### Autres CMS

- Drupal usine à gaz
- Wordpress pas de gestion fine des champs
- ModX https://modx.com (framework PHP)
- Django https://www.djangoproject.com (python)
- Scalar https://scalar.me/anvc/ centré publication
- CMS Symphony https://www.getsymphony.com



## Headless CMS

https://headlesscms.org

https://en.wikipedia.org/wiki/Headless_content_management_system



Avantages

Indépendance pour la création des formulaires

Possibilité de réutiliser des framework (BootStrap, VueEtc.) pour le backend

API



Inconvénients

Solidité de la solution CMS

Difficultés de mise en œuvre





## FileMaker

Avantages

Facile à déployer

Personnalisation possible des formulaires



Inconvénients

Propriétaire

Exports problématiques

Pas full web

Solution de publication insuffisantes (API, édition)

## From Scratch with BaseX



Avantages

Indépendance pour la création des formulaires

Possibilité de réutiliser des framework (BootStrap, VueEtc.) pour le backend

Facilités d’exportation et de manipulation des données

Possibilité de créer une application de publication (y compris pour l’édition TEI de pièces)

Création d’une API Rest pour la mise à disposition des contenus



Inconvénients

Environnement Java

Difficultés de mise en œuvre



http://www.agencexml.com/xsltforms

https://www.orbeon.com

https://www.w3.org/TR/xforms/



## Benchmarking Critères

- Facilité de mise en œuvre
- Ergonomie et contrôle