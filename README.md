# data
Données réunies dans le cadre de l’[ANR Experts](https://experts.huma-num.fr) et utilitaires pour l’importation et la refactorisation des données.

Les données consistent principalement en deux corpus : 

- D’une part, l’inventaire et le **dépouillement systématique de dix années de procès-verbaux conservés dans la sous-série Z1J** des Archives nationales de 1690 à 1790. 
- D’autre part la constitution d’une **base de données prosopographique des 234 experts parisiens** pour toute la période étudiée.

Les données sont structurées en XML. Le dépouillement systématique des affaires utilise une grille de dépouillement personnalisée compatible avec le standard archivistique [XML-EAD](https://www.loc.gov/ead/EAD3taglib/), tandis que la prosopographie utilise largement [EAC-CPF](https://eac.staatsbibliothek-berlin.de/) (norme ISAAR-CPF) en s’inspirant des propositions de [RiC-CM](https://www.ica.org/fr/records-in-contexts-modele-conceptuel).

Le schéma ODD et la documentation pour les données de dépouillements z1j, ainsi que le schéma EAC-CPF révisé pour les données prosopographiques sont fournis dans le dossier `schema`. 

*Un script d’exportation vers XML-EAD sera produit prochainement.*

## Bibliographie

- Château-Dutier, Emmanuel, et Josselin Morvan. 2021. « Un outil de dépouillement de sources archivistiques basé sur des technologies XML ». Dans *Colloque Humanistica 2021 - Recueil des résumés*. , 78‑80. Rennes, 10-12 mai 2021 (France). https://doi.org/10.5281/zenodo.4745006.
- Château-Dutier, Emmanuel, Josselin Morvan, et Robert Carvais. 2021. « La répartition des affaires au sein de la communauté d’experts-jurés parisiens du bâtiment au XVIIIe siècle : approche quantitative et analyse de réseau bi-parti pour 1726 ». Dans *6e rencontre ResHIST*. . 21-22 octobre 2021, Aix-en-Provence (France). https://reshist.hypotheses.org/1663.

## L’ANR Experts

**Pratiques des savoirs entre jugement et innovation. Experts, expertises du bâtiment, Paris 1690-1790 – ANR EXPERTS**

Depuis le Moyen Âge et probablement plus tôt, les autorités publiques confient à des personnes qu’elles estiment et qualifient compétentes l’action d’émettre un avis sur le savoir technique et scientifique, que ce soit dans le domaine gracieux comme contentieux. Cette recherche conduite dans le cadre d’un projet d’ANR vise à examiner, à partir d’un secteur économique majeur – celui du bâtiment à l’époque moderne –, le mécanisme de l’expertise : comment la langue technique régulatrice et maîtrisée des experts s’impose à la société, comment leur compétence technique se convertit en autorité, voire parfois en « abus d’autorité » ? L’existence d’un fonds d’archives exceptionnel (A.N. Z1J) qui conserve l’ensemble des procès-verbaux d’expertise du bâtiment parisien de 1643 à 1792 nous a permis de lancer une enquête pluridisciplinaire (juridique, économique et architecturale) de grande envergure sur la question de l’expertise qui connaît, à partir de 1690, un tournant particulier. En effet, les experts se divisent alors en deux branches différentes exerçant deux activités concurrentes, parfois complémentaires : les architectes et les entrepreneurs.

Notre recherche s’intéresse donc à la communauté des experts parisiens du bâtiment de 1690 à 1790. Les experts se répartissent, depuis cette époque, en deux cohortes d’architectes experts bourgeois et d’experts entrepreneurs. Nous étudions la structuration de cette communauté et l’activité des experts. Deux grands chantiers sont menés de front, d’une part l’établissement d’une prosopographie des 266 experts parisiens mais aussi un dépouillement systématique d’un échantillon de dix années de procès-verbaux d’expertise sur toute la période (en particulier, sous-séries V1 Lettres de provisions d’offices, Z1J Chambre et Greffiers des bâtiments, aux Archives nationales de France, Almanachs royaux, œuvres et travaux publiés, BnF).

https://anr.fr/Projet-ANR-17-CE26-0006

## Contenu du repo
```bash
├── xpr
│   └── db // La base de données xpr, constituée de resources xml
│       ├── biographies // données prosopographiques des experts et greffiers du bâtiments
│       ├── expertises // Expertises dépouillées dans le cadre du projet
│       └── inventories // inventaires après-décès des experts dépouillés dans le cadre du projet
├── files // archives des fichiers et scripts utilisés pour réviser la base de données xpr 
├── schema
│   ├── eac-cpf // personnalisation du schema eac-cpf officiel pour le projet xpr (SAA-SDT/eac-cpf-schema)
│   └── z1j // schema ODD et documentation pour le traitement des expertises z1j
├── .gitmodules
├── README.md
└── makedb.xqy // script xquery pour la creation de la base de données xpr
```

## Utilisation avec l'application xpr
- installer l'application xpr ([https://github.com/anrExperts/xpr](https://github.com/anrExperts/xpr))
- cloner le repo `data`
- lancer le script `makedb.xqy` avec [BaseX](https://basex.org/) en prenant soin de changer la variable `$path`