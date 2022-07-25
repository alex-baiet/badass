/*

BADASS : Base Archéologique de Données Attributaires et SpatialeS

Auteurs : Caroline Font, Thomas Guillemard, Florent Mercey, Christelle Seng (cheffe d'orchestre). Inrap, 2022.

Remarques diverses : 
- Les FOREIGN KEY sont commentées afin de ne pas en subir la contrainte, mais de garder le principe du MCD

*/

PRAGMA encoding='UTF-8';

-- LES 6 COUCHES

-- EMPRISE : unité technique ; emprise de l’opération
DROP TABLE IF EXISTS emprise; -- Supprime la table (et ses données) si elle existe déjà. 
CREATE TABLE emprise(
   "id_emprise" INTEGER PRIMARY KEY,
   "numope" TEXT,
   "nomope" TEXT,
   "typope" TEXT,
   "typemp" TEXT,
   "numoa" TEXT,
   "numprescr" TEXT,
   "ro" TEXT,
   "annee" INTEGER,
   "surface" FLOAT
);
SELECT 
AddGeometryColumn ('emprise','geometry',2154,'MULTIPOLYGON','XY',0); -- ajoute la colonne geométrie. Attention, fonction de Spatialite uniquement !!! 

-- OUVERTURE : unité technique : tout creusement réalisé à des fins d’observation (sondage, tranchée, décapage...)
DROP TABLE IF EXISTS ouverture;
CREATE TABLE ouverture(
   "id_ouverture" INTEGER PRIMARY KEY,
   "numouvert" TEXT,
   "typouvert" TEXT,
   "surface" FLOAT
);
SELECT 
AddGeometryColumn ('ouverture','geometry',2154,'MULTIPOLYGON','XY',0);

-- POLY : unité d’observation archéologique représentée sous forme de polygone (us, fait, ens...)
DROP TABLE IF EXISTS poly;
CREATE TABLE poly(
   "id_poly" INTEGER PRIMARY KEY,
   "numpoly" INTEGER,
   "typoly" TEXT,
   "interpret" TEXT,
   "datedebut" INTEGER,
   "datefin" INTEGER
);
SELECT 
AddGeometryColumn ('poly','geometry',2154,'MULTIPOLYGON','XY',0);

-- POINT : unité d’observation archéologique représentée sous forme de point (isolat...)
DROP TABLE IF EXISTS point;
CREATE TABLE point(
   "id_point" INTEGER PRIMARY KEY,
   "numpoint" INTEGER,
   "typoint" TEXT,
   "interpret" TEXT,
   "datedebut" INTEGER,
   "datefin" INTEGER,
   "z_point" FLOAT
);
SELECT 
AddGeometryColumn ('point','geometry',2154,'POINT','XY',0);

-- AXE : unité technique matérialisant l’axe de coupe, sous forme de ligne
DROP TABLE IF EXISTS axe;
CREATE TABLE axe(
   "id_axe" INTEGER PRIMARY KEY,
   "numaxe" TEXT,
   "typaxe" TEXT,
   "z_axe" FLOAT,
   "long_axe" FLOAT
);
SELECT 
AddGeometryColumn ('axe','geometry',2154,'LINESTRING','XY',0);

-- LOG : unité technique ponctuelle localisant l’emplacement des prélèvements, des logs géomorphologiques (lieux d’observation ponctuels)
DROP TABLE IF EXISTS log;
CREATE TABLE log(
   "id_log" INTEGER PRIMARY KEY,
   "numlog" TEXT,
   "typlog" TEXT,
   "alti" FLOAT,
   "typalti" TEXT
);
SELECT 
AddGeometryColumn ('log','geometry',2154,'POINT','XY',0);


-- LES COUPES DANS QGIS : tables nécessaires pour réaliser les coupes des faits dans QGIS (Caro POWAAAAA)

-- La table coupe_axe
DROP TABLE IF EXISTS coupe_axe;
CREATE TABLE coupe_axe(
   "id_axe" INTEGER PRIMARY KEY,
   "numinute" INTEGER,
   "azimuth" FLOAT,
   "alti" FLOAT
   -- FOREIGN KEY("id_axe") REFERENCES "axe"("id_axe")
);
SELECT 
AddGeometryColumn ('coupe_axe','geometry',2154,'LINESTRING','XY',0);

-- La table coupe_line
DROP TABLE IF EXISTS coupe_line;
CREATE TABLE coupe_line(
   "id_cpline" INTEGER PRIMARY KEY,
   "id_axe" INTEGER,
   "numfait" INTEGER,
   "numus" INTEGER,
   "typline" TEXT,
   "numsd" INTEGER
   --FOREIGN KEY("id_axe") REFERENCES "coupe_axe"("id_axe"),
   --FOREIGN KEY("numfait") REFERENCES "t_fait"("numfait"),
   --FOREIGN KEY("numus") REFERENCES "t_us"("numus")
);
SELECT 
AddGeometryColumn ('coupe_line','geometry',2154,'MULTILINESTRING','XY',0); -- mieux vaut prévoir une géométrie multiple dans le cas où une US négative serait interrompue (sondage, perturbation diverse)

-- La table coupe_poly
DROP TABLE IF EXISTS coupe_poly;
CREATE TABLE coupe_poly(
   "id_poly" INTEGER PRIMARY KEY,
   "id_axe" INTEGER,
   "numfait" INTEGER,
   "numus" INTEGER,
   "typoly" TEXT,
   "detail" TEXT,
   "numsd" INTEGER
   --FOREIGN KEY("id_axe") REFERENCES "coupe_axe"("id_axe"),
   --FOREIGN KEY("numfait") REFERENCES "fait"("numfait"),
   --FOREIGN KEY("numus") REFERENCES "us"("numus")
);
SELECT 
AddGeometryColumn ('coupe_poly','geometry',2154,'MULTIPOLYGON','XY',0);


-- LA BASE ARCHEO : les tables des faits, sondage, us, etc. La géométrie peut être associée. 

-- FAIT : la table des faits archéologique qui récupère la géométrie par trigger de la table poly (6 couches) pour "typoly" LIKE 'fait'
DROP TABLE IF EXISTS t_fait;
CREATE TABLE t_fait(
   "id_fait" INTEGER PRIMARY KEY,
   "numfait" INTEGER UNIQUE,
   "interpret_alter" TEXT,
   "interpret" TEXT,
   "douteux" INTEGER,
   "equiv_diag" TEXT,
   "statut" TEXT,
   "rais_annule" TEXT,
   "fouille" TEXT,
   "enr_fini" INTEGER,
   "relev_fini" INTEGER,
   "photo_fini" INTEGER,
   "topo_fini" INTEGER,
   "profil" TEXT,
   "forme" TEXT,
   "orient" TEXT,
   "orient_calc" FLOAT,
   "descrip" TEXT,
   "prof_app" FLOAT,
   "diam" FLOAT,
   "dim_max" FLOAT,
   "dim_min" FLOAT,
   "epais" FLOAT,
   "prof_haut" FLOAT,
   "periode" TEXT,
   "note" TEXT
);
SELECT 
AddGeometryColumn ('t_fait','geometry',2154,'MULTIPOLYGON','XY',0);

-- US : unité stratitgraphique qui récupère la géométrie par trigger de la table poly (6 couches) pour "typoly" LIKE 'us'
DROP TABLE IF EXISTS t_us;
CREATE TABLE t_us(
   "id_us" INTEGER PRIMARY KEY,
   "numus" INTEGER UNIQUE,
   "numfait" INTEGER,
   "type_us" TEXT,
   "nature_us" TEXT,
   "interpret" TEXT, -- liste de valeurs : avec notamment les valeurs OTD 'dépôt inhumation primaire' et  'dépôt inhumation non primaire' et 'contenant inhumation'
   "description" TEXT,
   "datsup_interpret" INTEGER,
   "datinf_interpret" INTEGER,
   "datsup_mobilier" INTEGER,
   "datinf_mobilier" INTEGER,
   "datsup_14c" INTEGER,
   "datinf_14c" INTEGER,
   "note_dat" TEXT,
   "forme" TEXT,
   "diam" FLOAT,
   "dim_max" FLOAT,
   "dim_min" FLOAT,
   "prof_app" FLOAT,
   "zmin" FLOAT,
   "zmax" FLOAT,
   "epais" FLOAT,
   "compo_sediment" TEXT,
   "texture" TEXT,
   "couleur" TEXT,
   "valeur_couleur" TEXT,
   "creator" TEXT,
   "datcreation" DATE,
   "note" TEXT,
   "num_seq" INTEGER,
   "ordre_seq" INTEGER
   -- FOREIGN KEY("numfait") REFERENCES "t_fait"("numfait")
);
SELECT 
AddGeometryColumn ('t_us','geometry',2154,'MULTIPOLYGON','XY',0);

-- ENSEMBLE : les ensembles regroupant des faits et/ou des us (bâtiment...)
DROP TABLE IF EXISTS t_ens;
CREATE TABLE t_ens(
   "id_ens" INTEGER PRIMARY KEY,
   "numens" INTEGER,
   "typens" TEXT, -- liste de valeurs Thesaurus (archéo, technique...)
   "interpret" TEXT, -- liste de valeurs
   "description" TEXT,
   "note" TEXT,
   "ens_englob" INTEGER -- renvoie vers le num d'un super ensemble qui englobe l'entité (et d'autres...)
   );
SELECT 
AddGeometryColumn ('t_ens','geometry',2154,'MULTIPOLYGON','XY',0);

-- SONDAGE : pour les ouvertures (unité technique) de type sondage qui récupère la géométrie par trigger de la table ouverture (6 couches) pour "typouvert" LIKE 'sondage'
DROP TABLE IF EXISTS t_sondage;
CREATE TABLE t_sondage(
   "id_sd" INTEGER PRIMARY KEY,
   "numsd" INTEGER UNIQUE,
   "numtr" INTEGER,
   "type" TEXT,
   "prof" FLOAT,
   "note" TEXT
   -- FOREIGN KEY("numtr") REFERENCES t_tranchee("numtr")
);
SELECT 
AddGeometryColumn ('t_sondage','geometry',2154,'MULTIPOLYGON','XY',0);

--TRANCHEE : pour les ouvertures (unité technique) de type tranchée qui récupère la géométrie par trigger de la table ouverture (6 couches) pour "typouvert" LIKE 'tranchée'
DROP TABLE IF EXISTS t_tranchee;
CREATE TABLE t_tranchee(
   "id_tr" INTEGER PRIMARY KEY,
   "numtr" INTEGER UNIQUE,
   "long" FLOAT,
   "larg" FLOAT,
   "surface" FLOAT,
   "prof_max" FLOAT,
   "prof_min" FLOAT,
   "note" TEXT
   );
SELECT 
AddGeometryColumn('t_tranchee','geometry',2154,'MULTIPOLYGON','XY',0);

-- PHOTO : les photographies numériques (pas de géométrie)
DROP TABLE IF EXISTS t_photo;
CREATE TABLE t_photo(
   "id_photo" INTEGER PRIMARY KEY,
   "numphoto" TEXT UNIQUE, -- numéro de 1 à n enregistré par l'archéo
   "nomfichier" TEXT, -- le nom du fichier photo avec son extension (attention à la casse)
   "chemin_url" TEXT, -- chemin d'accès du fichier
   "legend" TEXT, -- peut correspondre au titre de la figure dans le rapport
   "vue_vers" TEXT, -- liste de valeurs
   "creator" TEXT, -- liste de valeurs
   "datephoto" TEXT, -- date du cliché
   "type" TEXT, -- coupe, plan, mobilier, ambiance....
   "support" TEXT, -- numérique, argentique...
   "destination" TEXT -- rapport, valorisation, publi...
);

-- MINUTE : les relevés de terrain sur minute de chantier (pas de géométrie)
DROP TABLE IF EXISTS t_minute;
CREATE TABLE t_minute(
   "id_minut" INTEGER PRIMARY KEY,
   "numinute" INTEGER UNIQUE,
   "descr" TEXT,
   "echelle" TEXT,
   "contenu" TEXT,
   "creator" TEXT,
   "format" TEXT,
   "support" TEXT,
   "chemin_url" TEXT,
   "scan" INTEGER, -- booléen
   "min_dao" INTEGER, -- booléen
   "numodel" TEXT -- renvoie au nom du modèle 3D
   -- FOREIGN KEY("numodel") REFERENCES t_photogram("numodel")
);

-- MOBILIER : CETTE TABLE EST A REVOIR COMPLETEMENT
DROP TABLE IF EXISTS t_mobilier;
CREATE TABLE t_mobilier( 
   "id_mob" INTEGER PRIMARY KEY,
   "numiso" INTEGER UNIQUE,
   "numpoint" INTEGER,
   "numus" INTEGER,
   "numfait" INTEGER,
   "iso_lot" TEXT, -- soit iso, soit lot
   "iso_ident" TEXT,
   "iso_ssident" TEXT, -- à repenser !!!!!!!!!!!!!!!!!!!!
   "matiere" TEXT, -- hérité de OTD à repenser !!!!!!!!!!!!!!!!!!!! CADoc : 3 champs "matiere", "identification" et "categorie" (cf Instrumentum 2013)
   "catego" TEXT, -- à repenser !!!!!!!!!!!!!!!!!!!!
   "sscatego" TEXT, -- à repenser !!!!!!!!!!!!!!!!!!!
   "alt" FLOAT,
   "dim_min" FLOAT,
   "dim_max" FLOAT,
   "diam" FLOAT,
   "epaiss" FLOAT,
   "masse" FLOAT,
   "nr" INTEGER, -- nombre de restes
   "pr" INTEGER, -- poids des restes
   "etatcons" TEXT,
   "note" TEXT,
   "datesup" INTEGER,
   "dateinf" INTEGER,
   "dat_note" TEXT
   -- FOREIGN KEY("numfait") REFERENCES "t_fait"("numfait")
   -- FOREIGN KEY("numus") REFERENCES "t_us"("numus")
 );
SELECT 
AddGeometryColumn ('t_mobilier','geometry',2154,'POINT','XY',0);

-- SEQUENCE : regroupement des US en séquences stratigraphiques (pas de géométrie)
DROP TABLE IF EXISTS t_seq;
CREATE TABLE t_seq(
   "numseq" INTEGER PRIMARY KEY,
   "titre" TEXT,
   "datation" TEXT,
   "crit_dat" TEXT, -- éléments sur lesquels se base la datation
   "note" TEXT
);

-- PHASE : regroupement des séquences en phases chrono-stratigraphiques (pas de géométrie)
DROP TABLE IF EXISTS t_phase;
CREATE TABLE t_phase(
   "id_phase" INTEGER PRIMARY KEY,
   "numphase" INTEGER UNIQUE,
   "titre" TEXT,
   "datation" TEXT,
   "tpq" INTEGER,
   "taq" INTEGER,
   "note" TEXT -- précision sur la nature de la phase, sur la datation...
);

-- PERIODE : regroupement des phases en périodes chronologiques (pas de géométrie)
DROP TABLE IF EXISTS t_periode;
CREATE TABLE t_periode(
   "id_period" INTEGER PRIMARY KEY,
   "numperiod" INTEGER UNIQUE,
   "titre" TEXT,
   "datation" TEXT,
   "date_inf" INTEGER,
   "date_sup" INTEGER,
   "note" TEXT
);

-- LOG : les logs enregistrés/décrits sur le terrain qui récupère la géométrie par trigger de la table plog (6 couches)
DROP TABLE IF EXISTS t_log; 
CREATE TABLE t_log(
   "id_log" INTEGER PRIMARY KEY,
   "numlog" INTEGER UNIQUE,
   "numtr" INTEGER,
   "numsd" INTEGER,
   "alti" FLOAT,
   "prof_log" FLOAT,
   "zmin_log" FLOAT,
   "objectif_log" TEXT,
   "note_log" TEXT,
   "numaxe" INTEGER -- dans le cas par exemple d'un transect
   -- FOREIGN KEY("numtr") REFERENCES t_tranchee("numtr")
   -- FOREIGN KEY("numsd") REFERENCES t_sondage("numsd")
   -- FOREIGN KEY("numaxe") REFERENCES t_axe("numaxe")
);
SELECT 
AddGeometryColumn ('t_log','geometry',2154,'POINT','XY',0);

-- PRELEVEMENTS : pour enregistrer les prélèvements
DROP TABLE IF EXISTS t_prelevement;
CREATE TABLE t_prelevement( 
   "id_prel" INTEGER PRIMARY KEY,
   "numprel" INTEGER UNIQUE,
   "numus" INTEGER,
   "numfait" INTEGER,
   "type" TEXT,
   "objectif" TEXT,
   "volume" FLOAT,
   "contenant" TEXT,
   "creator" TEXT,
   "note" TEXT
   -- FOREIGN KEY("numus") REFERENCES "t_us"("numus")
 );
SELECT 
AddGeometryColumn ('t_prelevement','geometry',2154,'POINT','XY',0);


-- AXE : les axes de relevé de plan et/ou coupe effectués sur le terrain qu'il peut être nécessaire d'enregistrer (en relation de n à n avec fait, us, sd, tr)
DROP TABLE IF EXISTS t_axe;
CREATE TABLE t_axe(
   "id_axe" INTEGER PRIMARY KEY,
   "numaxe" INTEGER UNIQUE,
   "note" TEXT,
   "long" FLOAT,
   "alti" FLOAT
);
SELECT 
AddGeometryColumn ('t_axe','geometry',2154,'LINESTRING','XY',0);

-- TABLE DE RELATION / JOINCTION / JOINTURE (de 1 à n, permettant la relation de n à n entre deux tables utiles comme t_fait et t_photo)

-- gestion de la relation entre les axes et les sujets du relevé (faits, us, sd, tr)
DROP TABLE IF EXISTS j_rel_axe;
CREATE TABLE j_rel_axe(
   "id_rel_axe" INTEGER PRIMARY KEY,
   "numaxe" INTEGER,
   "numfait" INTEGER,
   "numus" INTEGER,
   "numsd" INTEGER,
   "numtr" INTEGER
   -- FOREIGN KEY("numaxe") REFERENCES t_axe("numaxe")
   -- FOREIGN KEY("numtr") REFERENCES t_tranchee("numtr")
   -- FOREIGN KEY("numsd") REFERENCES t_sondage("numsd")
   -- FOREIGN KEY("numus") REFERENCES "t_us"("numus"),
   -- FOREIGN KEY("numfait") REFERENCES "t_fait"("numfait")
);

-- gestion de la relation entre les US et les LOG, cette table permet de générer les box par US des logs automatiquement dans QGIS
DROP TABLE IF EXISTS j_us_log;
CREATE TABLE j_us_log(
   "id_us_log" INTEGER PRIMARY KEY,
   "numus" INTEGER,
   "numlog" INTEGER,
   "prof_toit" FLOAT,
   "prof_base" FLOAT,
   "epais_uslog" FLOAT,
   "zmax_uslog" FLOAT,
   "zmin_uslog" FLOAT
   --FOREIGN KEY("numlog") REFERENCES "t_log"("numlog"),
   --FOREIGN KEY("numus") REFERENCES "t_us"("numus")
);

-- gestion de la relation, les US (relation stratigraphique inter-US)
DROP TABLE IF EXISTS j_rel_us;
CREATE TABLE j_rel_us(
   "id_rel_us" INTEGER PRIMARY KEY,
   "numus1" INTEGER,
   "numus2" INTEGER,
   "typrel" TEXT,
   "incert" INTEGER -- 0 = sûre ; 1 = incertain
   -- FOREIGN KEY("numus1") REFERENCES t_us("numus"),
   -- FOREIGN KEY("numus2") REFERENCES t_us("numus")
);

-- gestion de la relation, les faits (relation stratigraphique inter-faits)
DROP TABLE IF EXISTS j_rel_fait;
CREATE TABLE j_rel_fait(
   "id_rel_fait" INTEGER PRIMARY KEY,
   "numfait1" INTEGER,
   "numfait2" INTEGER,
   "typrel" TEXT,
   "incert" INTEGER
   -- FOREIGN KEY("numfait1") REFERENCES t_fait("numfait"),
   -- FOREIGN KEY("numfait2") REFERENCES t_fait("numfait")
);

-- gestion de la relation entre les sondages et les US, faits et logs
DROP TABLE IF EXISTS j_rel_sondage;
CREATE TABLE j_rel_sondage(
   "id_rel_sd" INTEGER PRIMARY KEY,
   "numsd" INTEGER,
   "numus" INTEGER,
   "numlog" INTEGER,
   "numfait" INTEGER
   -- FOREIGN KEY("numsd") REFERENCES "t_sondage"("numsd"),
   -- FOREIGN KEY("numus") REFERENCES "t_us"("numus"),
   -- FOREIGN KEY("numfait") REFERENCES "t_fait"("numfait")
   -- FOREIGN KEY("numlog") REFERENCES "t_log"("numlog")
);

-- gestion de la relation entre les tranchées et les US, faits et les logs
DROP TABLE IF EXISTS j_rel_tranchee;
CREATE TABLE j_rel_tranchee(
   "id_rel_tr" INTEGER PRIMARY KEY,
   "numtr" INTEGER,
   "numus" INTEGER,
   "numfait" INTEGER,
   "numlog" INTEGER
   -- FOREIGN KEY("numtr") REFERENCES "t_tranchee"("numtr"),
   -- FOREIGN KEY("numus") REFERENCES "t_us"("numus"),
   -- FOREIGN KEY("numfait") REFERENCES "t_fait"("numfait")
   -- FOREIGN KEY("numlog") REFERENCES "t_log"("numlog")
);

--gestion de la relation entre les ensembles et les US et faits
DROP TABLE IF EXISTS j_rel_ens;
CREATE TABLE j_rel_ens(
   "id_rel_ens" INTEGER PRIMARY KEY,
   "numens" INTEGER,
   "numus" INTEGER,
   "numfait" INTEGER,
   "typrel" TEXT,
   "incert" INTEGER
   -- FOREIGN KEY("numens") REFERENCES "t_ens"("numens"),
   -- FOREIGN KEY("numfait") REFERENCES "t_fait"("numfait"),
   -- FOREIGN KEY("numus") REFERENCES "us"("numus")
);

-- gestion de la relation entre les séquences et les phases
DROP TABLE IF EXISTS j_seq_phase;
CREATE TABLE j_seq_phase(
   "id_rel_phase" INTEGER PRIMARY KEY,
   "numseq" INTEGER NOT NULL,
   "numphase" INTEGER,
   "ordre" INTEGER -- ordre de la séquence dans la phase
   --FOREIGN KEY("numseq") REFERENCES "t_seq"("numseq"),
   --FOREIGN KEY("numphase") REFERENCES "t_phase"("numphase")
);

-- gestion de la relation les phases et les périodes
DROP TABLE IF EXISTS j_phase_per;
CREATE TABLE j_phase_per(
   "id_rel_periode" INTEGER PRIMARY KEY,
   "numphase" INTEGER,
   "numperiod" INTEGER,
   "ordre" INTEGER -- ordre éventuel de la phase dans la période
   --FOREIGN KEY("numperiod") REFERENCES "t_periode"("numperiod"),
   --FOREIGN KEY("numphase") REFERENCES "t_phase"("numphase")
);

-- gestion de la relation entre les minutes de terrain et les US, faits, ensembles, les axes, isolats, les sondages et tranchées
DROP TABLE IF EXISTS j_rel_minute;
CREATE TABLE j_rel_minute(
   "id_rel_minute" INTEGER PRIMARY KEY,
   "numinute" INTEGER,
   "numsd" INTEGER,
   "numtr" INTEGER,
   "numens" INTEGER,
   "numfait" INTEGER,
   "numus" INTEGER,
   "numiso" INTEGER,
   "numlog" INTEGER,
   "numaxe" INTEGER
   --FOREIGN KEY("numinute") REFERENCES "t_minute"("numinute"),
   --FOREIGN KEY("numsd") REFERENCES "t_sondage"("numsd"),
   --FOREIGN KEY("numtr") REFERENCES "t_tranchee"("numtr"),
   --FOREIGN KEY("numens") REFERENCES "t_ens"("numens"),
   --FOREIGN KEY("numfait") REFERENCES "t_fait"("numfait"),
   --FOREIGN KEY("numus") REFERENCES "t_us"("numus"),
   --FOREIGN KEY("numiso") REFERENCES "t_mobilier"("numiso"),
   --FOREIGN KEY("numaxe") REFERENCES "t_axe"("numaxe")
);

--gestion de la relation entre les photos et les US, faits, les ensembles et isolats et les sondages et tranchées
DROP TABLE IF EXISTS j_rel_photo;
CREATE TABLE j_rel_photo(
   "id_rel_photo" INTEGER PRIMARY KEY,
   "numphoto" INTEGER,
   "numsd" INTEGER,
   "numtr" INTEGER,
   "numens" INTEGER,
   "numfait" INTEGER,
   "numus" INTEGER, -- clé étrangère à spécifier lorsque la photo représente un lot de mobilier
   "numiso" INTEGER,
   "numlog" INTEGER,
   "numodel" TEXT 
   --FOREIGN KEY("numphoto") REFERENCES "t_photo"("numphoto"),
   --FOREIGN KEY("numsd") REFERENCES "t_sondage"("numsd"),
   --FOREIGN KEY("numtr") REFERENCES "t_tranchee"("numtr"),
   --FOREIGN KEY("numens") REFERENCES "t_ens"("numens"),
   --FOREIGN KEY("numfait") REFERENCES "t_fait"("numfait"),
   --FOREIGN KEY("numus") REFERENCES "t_us"("numus"),
   --FOREIGN KEY("numiso") REFERENCES "t_mobilier"("numiso"),
   --FOREIGN KEY("numodel") REFERENCES "t_photogram"("numodel")
);

-- PHOTOGRAMMETRIE : permet l'enregistrement des modèles et le suivi des traitements
DROP TABLE IF EXISTS t_photogram;
CREATE TABLE t_photogram(
"id_photogram" INTEGER PRIMARY KEY, -- clé primaire
"numodel" TEXT, -- nom du modèle
"datemodel" DATE, -- date du traitement du modele
"legend" TEXT, -- description du ou des sujet(s) de la scène
"obj_model" TEXT,-- multivarié, objectif(s) du modèle (orthoimage, coupes, profils...)
"job" TEXT, -- nom de job contenant le modèle (car un job peut contenir un ou plusieurs modèles)
"urljob" TEXT, -- url du job
"creator" TEXT,-- auteur du traitement d'après liste de valeurs
"comment" TEXT,
/*paramètres prises de vue*/
"boitier" TEXT, -- nom de l'APN
"iso" INTEGER, -- valeur ISO
"nettete" TEXT, -- 
"objectif" TEXT, -- 
"diaphragme" TEXT, --
"temps_pose" TEXT, --
/*suivi traitement*/
"xmlcalib" TEXT, -- fichier .xml contenant les paramètres de calibration
"convers" INTEGER, -- conversion des RAW en TIFF, 0 ou 1
"suivi" TEXT -- liste de valeurs : aérotriangulation, génération du nuage dense, 
--génération du MNS, génération d'une orthoimage
);
SELECT 
AddGeometryColumn('t_photogram','geometry',2154,'MULTIPOLYGON','XYZ',0); -- correspond à l'emprise du modèle

-- table de relation (n à n) entre la table de modèle 3d (t_photogram) et une table de points topo qui n'existe pas encore
DROP TABLE IF EXISTS j_rel_photogram;
CREATE TABLE j_rel_photogram(
"id_rel_photogram" INTEGER PRIMARY KEY, -- clé primaire
"numodel" TEXT, -- nom du modèle
"pt_appui" TEXT 
);




----------------------------------------------------------------------------------------------------------------------
-- THESAURUS : rassemble les termes des listes de valeurs
DROP TABLE IF EXISTS thesaurus_badass;
CREATE TABLE thesaurus_badass(
   "id_thes" INTEGER PRIMARY KEY,
   "tabl_thes" TEXT, -- table où on trouve le champs qui propose la valeurs
   "field_thes" TEXT, -- champ qui propose le terme en liste de valeurs
   "val_thes" TEXT, -- il s'agit de la valeur / terme / modalité
   "def_thes" TEXT, -- si possible, définition du terme 
   "cat_thes" TEXT, -- catégorie de regroupement des termes    
   "comment" TEXT -- observations diverses
);

-- les valeurs du thésaurus
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (1,NULL,'couleur','blanc',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (2,NULL,'couleur','noir',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (3,NULL,'couleur','bleu',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (4,NULL,'couleur','rouge',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (5,NULL,'couleur','jaune',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (6,NULL,'couleur','vert',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (7,NULL,'couleur','beige',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (8,NULL,'couleur','gris',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (9,NULL,'couleur','brun',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (10,NULL,'couleur','orange',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (11,NULL,'forme','circulaire',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (12,NULL,'forme','ovale',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (13,NULL,'forme','quadrangulaire',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (14,NULL,'forme','carré',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (15,NULL,'forme','indéterminée',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (16,NULL,'forme','irrégulière',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (17,NULL,'forme','oblongue',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (18,NULL,'forme','rectiligne',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (19,NULL,'forme','incomplète',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (20,NULL,'forme','trapézoiïdale',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (21,NULL,'forme','anthropomorphe',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (22,NULL,'forme','banquette',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (23,NULL,'forme','non visible',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (24,'t_fait','fouille','50 %',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (25,'t_fait','fouille','100 %',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (26,'t_fait','fouille','sondage',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (27,'t_us','interpret','terre végétale',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (28,'t_us','interpret','dépôt primaire inhumation',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (29,'t_us','interpret','dépôt non primaire inhumation',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (30,'t_us','interpret','contenant',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (31,'t_us','interpret','dépôt mobilier',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (32,'t_fait','interpret','silo',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (33,'t_fait','interpret','trou de poteau',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (34,'t_fait','interpret','fosse',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (35,'t_fait','interpret','fossé',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (36,'t_fait','interpret','four',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (37,'t_fait','interpret','maçonnerie',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (38,'t_fait','interpret','cave',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (39,'t_fait','interpret','réseau',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (40,'t_fait','interpret','puits',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (41,'t_fait','interpret','citerne',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (42,'t_fait','interpret','tranchée',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (43,'t_fait','interpret','sépulture',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (44,'t_fait','interpret','voie',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (45,'t_fait','interpret','fond de cabane',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (46,'t_fait','interpret','plate-forme',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (47,'t_fait','interpret','sablière',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (48,'t_fait','interpret','chablis',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (49,'t_fait','interpret','mare',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (50,'t_fait','interpret','anomalie géologique',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (51,'t_fait','interpret','incinération',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (52,'t_fait','interpret','cellier',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (53,'t_fait','interpret','radier',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (54,'t_fait','interpret','séchoir',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (55,'t_fait','interpret','trou de plantation',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (56,'t_fait','interpret','drain',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (57,'t_fait','interpret','indéterminée',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (58,'t_fait','interpret','sol',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (59,'t_mobilier','matiere','albâtre',NULL,'lapidaire',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (60,'t_mobilier','matiere','ardoise',NULL,'lapidaire',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (61,'t_mobilier','matiere','calcaire',NULL,'lapidaire',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (62,'t_mobilier','matiere','dolérite',NULL,'lapidaire',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (63,'t_mobilier','matiere','granit',NULL,'lapidaire',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (64,'t_mobilier','matiere','grès',NULL,'lapidaire',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (65,'t_mobilier','matiere','gypse',NULL,'lapidaire',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (66,'t_mobilier','matiere','marbre',NULL,'lapidaire',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (67,'t_mobilier','matiere','obsidienne',NULL,'lapidaire',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (68,'t_mobilier','matiere','pierre',NULL,'lapidaire',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (69,'t_mobilier','matiere','porphyre',NULL,'lapidaire',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (70,'t_mobilier','matiere','quartz',NULL,'lapidaire',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (71,'t_mobilier','matiere','quartzite',NULL,'lapidaire',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (72,'t_mobilier','matiere','schiste',NULL,'lapidaire',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (73,'t_mobilier','matiere','silex',NULL,'lapidaire',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (74,'t_mobilier','matiere','tuf',NULL,'lapidaire',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (75,'t_mobilier','matiere','fossile',NULL,'fossiles et résines fossiles',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (76,'t_mobilier','matiere','ambre',NULL,'fossiles et résines fossiles',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (77,'t_mobilier','matiere','poix',NULL,'fossiles et résines fossiles',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (78,'t_mobilier','matiere','corail',NULL,'fossiles et résines fossiles',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (79,'t_mobilier','matiere','houille',NULL,'lignite et apparentés',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (80,'t_mobilier','matiere','jais',NULL,'lignite et apparentés',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (81,'t_mobilier','matiere','lignite',NULL,'lignite et apparentés',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (82,'t_mobilier','matiere','roche charbonneuse',NULL,'lignite et apparentés',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (83,'t_mobilier','matiere','schiste bitumeux',NULL,'lignite et apparentés',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (84,'t_mobilier','matiere','terre indéterminée',NULL,'terre indéterminée',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (85,'t_mobilier','matiere','céramique',NULL,'céramique',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (86,'t_mobilier','matiere','céramique commune',NULL,'céramique',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (87,'t_mobilier','matiere','céramique fine',NULL,'céramique',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (88,'t_mobilier','matiere','céramique glaçurée',NULL,'céramique',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (89,'t_mobilier','matiere','céramique peinte',NULL,'céramique',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (90,'t_mobilier','matiere','céramique sigillée',NULL,'céramique',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (91,'t_mobilier','matiere','faïence',NULL,'céramique',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (92,'t_mobilier','matiere','grès',NULL,'céramique',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (93,'t_mobilier','matiere','protogrès',NULL,'céramique',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (94,'t_mobilier','matiere','porcelaine',NULL,'céramique',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (95,'t_mobilier','matiere','ardoise',NULL,'lithique',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (96,'t_mobilier','matiere','calcaire',NULL,'lithique',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (97,'t_mobilier','matiere','tuf',NULL,'lithique',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (98,'t_mobilier','matiere','dolérite',NULL,'lithique',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (99,'t_mobilier','matiere','granit',NULL,'lithique',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (100,'t_mobilier','matiere','grès',NULL,'lithique',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (101,'t_mobilier','matiere','grès schisteux',NULL,'lithique',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (102,'t_mobilier','matiere','gypse',NULL,'lithique',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (103,'t_mobilier','matiere','marbre',NULL,'lithique',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (104,'t_mobilier','matiere','obsidienne',NULL,'lithique',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (105,'t_mobilier','matiere','poudingue',NULL,'lithique',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (106,'t_mobilier','matiere','porphyre',NULL,'lithique',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (107,'t_mobilier','matiere','quartz',NULL,'lithique',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (108,'t_mobilier','matiere','quartzite',NULL,'lithique',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (109,'t_mobilier','matiere','schiste',NULL,'lithique',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (110,'t_mobilier','matiere','silex',NULL,'lithique',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (111,'t_mobilier','matiere','os indéterminé',NULL,'matériau osseux indéterminé',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (112,'t_mobilier','matiere','os humain',NULL,'os humain',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (113,'t_us','nature_us','construction',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (114,'t_us','nature_us','occupation',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (115,'t_us','nature_us','destruction',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (116,'t_us','nature_us','abandon',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (117,'t_us','nature_us','remblai',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (118,'t_us','nature_us','colluvions naturels',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (119,'t_us','nature_us','alluvions naturels',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (120,'t_us','nature_us','naturel',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (121,NULL,'nature_us','technique/mécanique',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (122,NULL,'nature_us','autre',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (123,'t_fait','profil','en cuvette',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (124,'t_fait','profil','piriforme',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (125,'t_fait','profil','en "V"',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (126,'t_fait','profil','en "U"',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (127,'t_fait','profil','en auge',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (128,'t_fait','profil','irrégulier',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (129,'t_fait','profil','à fond plat',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (130,'t_fait','profil','indéterminé',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (131,'t_fait','profil','évasé',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (132,'t_fait','profil','concave',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (133,'t_fait','profil','cylindrique',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (134,'t_fait','profil','incomplet',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (135,'t_fait','statut','en cours',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (136,'t_fait','statut','fouillé',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (137,'t_fait','statut','non fouillé',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (138,'t_fait','statut','annulé',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (139,'t_us','type_us','couche',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (140,'t_us','type_us','négatif',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (141,'t_us','type_us','altération',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (142,'t_us','valeur','clair',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (143,'t_us','valeur','moyen',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (144,'t_us','valeur','foncé',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (145,'j_rel_us','jru_typrel','sous',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (146,'j_rel_us','jru_typrel','sur',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (147,'j_rel_us','jru_typrel','égale',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (148,'j_rel_us','jru_typrel','équivalente',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (149,'j_rel_us','jru_typrel','synchrone',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (150,'t_fait','f_periode','Paléolithique','-3300000 à -10000',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (151,'t_fait','f_periode','Paléolithique inférieur','-3300000 à -300000',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (152,'t_fait','f_periode','Paléolithique moyen','-300000 à -40000',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (153,'t_fait','f_periode','Paléolithique supérieur','-40000 à -10000',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (154,'t_fait','f_periode','Mésolithique et Épipaléolithique','-10000 à -5500',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (155,'t_fait','f_periode','Néolithique','-5500 à -2200',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (156,'t_fait','f_periode','Néolithique ancien','-5500 à -2200',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (157,'t_fait','f_periode','Néolithique moyen','-5500 à -4600',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (158,'t_fait','f_periode','Néolithique récent','-4600 à -3400',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (159,'t_fait','f_periode','Chalcolithique','-3400 à -2900',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (160,'t_fait','f_periode','Protohistoire','-2900 à -50',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (161,'t_fait','f_periode','Âge du Bronze','-2200 à -800',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (162,'t_fait','f_periode','Âge du Bronze ancien','-2200 à -1600',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (163,'t_fait','f_periode','Âge du Bronze moyen','-1600 à -1400',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (164,'t_fait','f_periode','Âge du Bronze récent','-1400 à -800',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (165,'t_fait','f_periode','Âge du Fer','-800 à -50',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (166,'t_fait','f_periode','Hallstatt','-800 à -450',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (167,'t_fait','f_periode','La Tène','-450 à -50',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (168,'t_fait','f_periode','Antiquité romaine','-50 à 476',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (169,'t_fait','f_periode','République romaine','-50 à 10',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (170,'t_fait','f_periode','Empire romain','-37 à 476',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (171,'t_fait','f_periode','Haut-Empire','-37 à 235',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (172,'t_fait','f_periode','Bas-Empire','235 à 476',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (173,'t_fait','f_periode','Époque médiévale','476 à 1492',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (174,'t_fait','f_periode','haut Moyen Âge','476 à 999',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (175,'t_fait','f_periode','Moyen Âge','1000 à 1299',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (176,'t_fait','f_periode','bas Moyen Âge','1299 à 1492',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (177,'t_fait','f_periode','Temps modernes','1492 à 1789',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (178,'t_fait','f_periode','Époque contemporaine','1789 à aujourd''hui',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (179,'t_fait','f_periode','Ère industrielle','1800 à 1914',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (180,'t_us','u_compo_sediment','limon',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (181,'t_us','u_compo_sediment','argile',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (182,'t_us','u_compo_sediment','sable',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (183,'t_us','u_texture','très compact',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (184,'t_us','u_texture','compact',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (185,'t_us','u_texture','meuble',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (186,'t_us','u_texture','très meuble',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (187,'t_us','interpret','aménagement inhumation',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (188,'t_us','interpret','contenant inhumation',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (189,'t_fait','orientation','nord/sud',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (190,'t_fait','orientation','sud/nord',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (191,'t_fait','orientation','est/ouest',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (192,'t_fait','orientation','ouest/est',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (193,'t_fait','orientation','nord-ouest/sud-est',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (194,'t_fait','orientation','sud-est/nord-ouest',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (195,'t_fait','orientation','nord-est/sud-ouest',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (196,'t_fait','orientation','sud-ouest/nord-est',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (197,'t_us','nature_us','technique',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (198,'t_us','interpret','décapage',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (199,'t_us','interpret','nettoyage',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (200,'t_us','interpret','remblai',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (201,'t_us','interpret','creusement',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (202,'t_us','interpret','comblement',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (203,'t_us','interpret','radier',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (204,'t_mobilier','mob_iso_ident','amphore',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (205,'t_mobilier','mob_iso_ident','anneau',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (206,'t_mobilier','mob_iso_ident','arme',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (207,'t_mobilier','mob_iso_ident','bobine',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (208,'t_mobilier','mob_iso_ident','bracelet',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (209,'t_mobilier','mob_iso_ident','charnière',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (210,'t_mobilier','mob_iso_ident','clef',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (211,'t_mobilier','mob_iso_ident','clou',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (212,'t_mobilier','mob_iso_ident','culot de four',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (213,'t_mobilier','mob_iso_ident','élément lithique',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (214,'t_mobilier','mob_iso_ident','enduit peint',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (215,'t_mobilier','mob_iso_ident','épingle',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (216,'t_mobilier','mob_iso_ident','fibule',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (217,'t_mobilier','mob_iso_ident','hache',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (218,'t_mobilier','mob_iso_ident','indéterminé',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (219,'t_mobilier','mob_iso_ident','jeton',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (220,'t_mobilier','mob_iso_ident','lame',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (221,'t_mobilier','mob_iso_ident','meule',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (222,'t_mobilier','mob_iso_ident','meule rotative',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (223,'t_mobilier','mob_iso_ident','molette',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (224,'t_mobilier','mob_iso_ident','monnaie',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (225,'t_mobilier','mob_iso_ident','mortier',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (226,'t_mobilier','mob_iso_ident','outil lithique',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (227,'t_mobilier','mob_iso_ident','perle',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (228,'t_mobilier','mob_iso_ident','peson',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (229,'t_mobilier','mob_iso_ident','poids',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (230,'t_mobilier','mob_iso_ident','scorie de forge',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (231,'t_mobilier','mob_iso_ident','scorie de réduction',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (232,'t_mobilier','mob_iso_ident','statuette',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (233,'t_mobilier','mob_iso_ident','TCA indéterminée',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (234,'t_mobilier','mob_iso_ident','tuile',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (235,'t_mobilier','mob_iso_ident','brique',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (236,'t_mobilier','mob_iso_ident','pilette',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (237,'t_mobilier','mob_iso_ident','torchis',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (238,'t_mobilier','mob_iso_ident','verre de construction',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (239,'t_mobilier','mob_iso_ident','vaisselle',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (240,'t_mobilier','mob_catego','roche ou minéral indéterminé et minerais',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (241,'t_mobilier','mob_catego','lapidaire','éléments d''architecture, sculpture, statuaire...',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (242,'t_mobilier','mob_catego','lithique','industrie sur roche et minéraux, hors lignite',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (243,'t_mobilier','mob_catego','fossiles et résines fossiles',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (244,'t_mobilier','mob_catego','lignite et apparentés','roche charbonneuse',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (245,'t_mobilier','mob_catego','terre indéterminée',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (246,'t_mobilier','mob_catego','céramique','vaisselle, récipients, vases...',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (247,'t_mobilier','mob_catego','terre cuite architecturale utilitaire, décorative ou votive','peson, statuette, lampe à huile...',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (248,'t_mobilier','mob_catego','terre cuite architecturale','tuile, brique...',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (249,'t_mobilier','mob_etatcons','très mauvais',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (250,'t_mobilier','mob_etatcons','mauvais',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (251,'t_mobilier','mob_etatcons','moyen',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (252,'t_mobilier','mob_etatcons','bon',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (253,'t_mobilier','mob_etatcons','très bon',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (254,'t_mobilier','mob_etatcons','complet',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (255,'t_mobilier','mob_catego','argile crue ou cuite accidentellement','torchis...',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (256,'t_mobilier','mob_catego','matériau osseux indéterminé',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (257,'t_mobilier','mob_catego','os humain','non travaillé',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (258,'t_mobilier','mob_catego','faune','non travaillé',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (259,'t_mobilier','mob_catego','ichtyologie','non travaillé',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (260,'t_mobilier','mob_catego','malacologie','non travaillé',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (261,'t_mobilier','mob_catego','os travaillé',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (262,'t_mobilier','mob_catego','coquillage, coquille, corail travaillé',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (263,'t_mobilier','mob_catego','matériau organique indéterminé',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (264,'t_mobilier','mob_catego','bois et vannerie',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (265,'t_mobilier','mob_catego','textile','fibres animales et végétales',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (266,'t_mobilier','mob_catego','cuir et peau',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (267,'t_mobilier','mob_catego','métal et alliage indéterminé ou métaux composites',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (268,'t_mobilier','mob_catego','or',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (269,'t_mobilier','mob_catego','argent',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (270,'t_mobilier','mob_catego','cuivre et alliages cuivreux','bronze, laiton',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (271,'t_mobilier','mob_catego','fer et alliages ferreux',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (272,'t_mobilier','mob_catego','plomb et alliages plombifères',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (273,'t_mobilier','mob_catego','étain',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (274,'t_mobilier','mob_catego','zinc',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (275,'t_mobilier','mob_catego','monnaies',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (276,'t_mobilier','mob_catego','verre',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (277,'t_mobilier','mob_catego','matériau composite connu ou indéterminé ou matériaux divers',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (278,'t_mobilier','mob_catego','émaux sur métaux',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (279,'t_mobilier','mob_catego','mosaïque',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (280,'t_mobilier','mob_catego','enduit peint',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (281,'t_mobilier','mob_catego','matériaux pierreux','mortier, plâtre, stuc...',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (282,'t_mobilier','mob_catego','industrie du métal ou du verre','scorie, creuset...',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (283,'t_prelevement','pvt_type','prélèvement brut non trié',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (284,'t_prelevement','pvt_type','anthracologie','charbons de bois',NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (285,'t_prelevement','pvt_type','carpologie',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (286,'t_prelevement','pvt_type','palynologie',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (287,'t_prelevement','pvt_type','granulométrie',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (288,'t_prelevement','pvt_type','micromorphologie',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (289,'t_prelevement','pvt_type','dendochronologie',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (290,'t_prelevement','pvt_type','thermoluminescence',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (291,'t_prelevement','pvt_type','datation carbone 14',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (292,'t_prelevement','pvt_type','phosphates',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (293,'t_prelevement','pvt_type','parasitologie',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (294,'t_mobilier','matiere','roche indéterminée',NULL,'roche ou minéral indéterminé et minerais',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (295,'t_mobilier','matiere','minéral indéterminé',NULL,'roche ou minéral indéterminé et minerais',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (296,'t_mobilier','matiere','minerai indéterminé',NULL,'roche ou minéral indéterminé et minerais',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (297,'t_mobilier','matiere','terre cuite utilitaire',NULL,'terre cuite architecturale utilitaire, décorative ou votive',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (298,'t_mobilier','matiere','terre cuite décorative',NULL,'terre cuite architecturale utilitaire, décorative ou votive',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (299,'t_mobilier','matiere','fusaïole',NULL,'terre cuite architecturale utilitaire, décorative ou votive',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (300,'t_mobilier','matiere','peson',NULL,'terre cuite architecturale utilitaire, décorative ou votive',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (301,'t_mobilier','matiere','creuset',NULL,'terre cuite architecturale utilitaire, décorative ou votive',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (302,'t_mobilier','matiere','parure',NULL,'terre cuite architecturale utilitaire, décorative ou votive',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (303,'t_mobilier','matiere','bracelet',NULL,'terre cuite architecturale utilitaire, décorative ou votive',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (304,'t_mobilier','matiere','perle',NULL,'terre cuite architecturale utilitaire, décorative ou votive',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (305,'t_mobilier','matiere','terre cuite votive',NULL,'terre cuite architecturale utilitaire, décorative ou votive',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (306,'t_mobilier','matiere','ex-voto',NULL,'terre cuite architecturale utilitaire, décorative ou votive',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (307,'t_mobilier','matiere','statuette',NULL,'terre cuite architecturale utilitaire, décorative ou votive',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (308,'t_mobilier','matiere','brique',NULL,'terre cuite architecturale',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (309,'t_mobilier','matiere','tuile',NULL,'terre cuite architecturale',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (310,'t_mobilier','matiere','tuile vernissée',NULL,'terre cuite architecturale',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (311,'t_mobilier','matiere','grès',NULL,'terre cuite architecturale',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (312,'t_mobilier','matiere','porcelaine',NULL,'terre cuite architecturale',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (313,'t_mobilier','matiere','faïence',NULL,'terre cuite architecturale',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (314,'t_mobilier','matiere','terre crue',NULL,'argile crue ou cuite accidentellement',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (315,'t_mobilier','matiere','terre rubéfiée',NULL,'argile crue ou cuite accidentellement',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (316,'t_mobilier','matiere','adobe',NULL,'argile crue ou cuite accidentellement',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (317,'t_mobilier','matiere','argile',NULL,'argile crue ou cuite accidentellement',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (318,'t_mobilier','matiere','bauge',NULL,'argile crue ou cuite accidentellement',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (319,'t_mobilier','matiere','ocre',NULL,'argile crue ou cuite accidentellement',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (320,'t_mobilier','matiere','pisé',NULL,'argile crue ou cuite accidentellement',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (321,'t_mobilier','matiere','torchis',NULL,'argile crue ou cuite accidentellement',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (322,'t_mobilier','matiere','os animal',NULL,'faune',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (323,'t_mobilier','matiere','corne',NULL,'faune',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (324,'t_mobilier','matiere','bovidé',NULL,'faune',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (325,'t_mobilier','matiere','canidé',NULL,'faune',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (326,'t_mobilier','matiere','caprin',NULL,'faune',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (327,'t_mobilier','matiere','équidé',NULL,'faune',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (328,'t_mobilier','matiere','félin',NULL,'faune',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (329,'t_mobilier','matiere','mammifère marin',NULL,'faune',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (330,'t_mobilier','matiere','ovidé',NULL,'faune',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (331,'t_mobilier','matiere','porcin',NULL,'faune',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (332,'t_mobilier','matiere','rongeur',NULL,'faune',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (333,'t_mobilier','matiere','volatile',NULL,'faune',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (334,'t_mobilier','matiere','poisson',NULL,'ichtyologie',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (335,'t_mobilier','matiere','écaille',NULL,'ichtyologie',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (336,'t_mobilier','matiere','arête',NULL,'ichtyologie',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (337,'t_mobilier','matiere','coquillage',NULL,'malacologie',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (338,'t_mobilier','matiere','coquille',NULL,'malacologie',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (339,'t_mobilier','matiere','corail',NULL,'malacologie',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (340,'t_mobilier','matiere','nacre',NULL,'malacologie',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (341,'t_mobilier','matiere','coque',NULL,'malacologie',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (342,'t_mobilier','matiere','bernique',NULL,'malacologie',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (343,'t_mobilier','matiere','huître',NULL,'malacologie',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (344,'t_mobilier','matiere','moule',NULL,'malacologie',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (345,'t_mobilier','matiere','os animal travaillé',NULL,'os travaillé',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (346,'t_mobilier','matiere','os humain travaillé',NULL,'os travaillé',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (347,'t_mobilier','matiere','os indéterminé travaillé',NULL,'os travaillé',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (348,'t_mobilier','matiere','corne',NULL,'os travaillé',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (349,'t_mobilier','matiere','ivoire',NULL,'os travaillé',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (350,'t_mobilier','matiere','coquillage travaillé',NULL,'coquillage, coquille, corail travaillé',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (351,'t_mobilier','matiere','coquille travaillée',NULL,'coquillage, coquille, corail travaillé',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (352,'t_mobilier','matiere','nacre',NULL,'coquillage, coquille, corail travaillé',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (353,'t_mobilier','matiere','corail',NULL,'coquillage, coquille, corail travaillé',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (354,'t_mobilier','matiere','matériau organique indéterminé',NULL,'matériau organique indéterminé',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (355,'t_mobilier','matiere','bois',NULL,'bois et vannerie',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (356,'t_mobilier','matiere','vannerie',NULL,'bois et vannerie',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (357,'t_mobilier','matiere','textile',NULL,'textile',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (358,'t_mobilier','matiere','fibre animale',NULL,'textile',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (359,'t_mobilier','matiere','fibre végétale',NULL,'textile',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (360,'t_mobilier','matiere','chanvre',NULL,'textile',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (361,'t_mobilier','matiere','coton',NULL,'textile',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (362,'t_mobilier','matiere','lin',NULL,'textile',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (363,'t_mobilier','matiere','cuir',NULL,'cuir et peau',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (364,'t_mobilier','matiere','peau',NULL,'cuir et peau',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (365,'t_mobilier','matiere','métal indéterminé',NULL,'métal et alliage indéterminé ou métaux composites',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (366,'t_mobilier','matiere','alliage indéterminé',NULL,'métal et alliage indéterminé ou métaux composites',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (367,'t_mobilier','matiere','métal composite',NULL,'métal et alliage indéterminé ou métaux composites',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (368,'t_mobilier','matiere','alliage composite',NULL,'métal et alliage indéterminé ou métaux composites',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (369,'t_mobilier','matiere','or',NULL,'or',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (370,'t_mobilier','matiere','argent',NULL,'argent',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (371,'t_mobilier','matiere','cuivre',NULL,'cuivre et alliages cuivreux',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (372,'t_mobilier','matiere','alliage cuivreux',NULL,'cuivre et alliages cuivreux',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (373,'t_mobilier','matiere','bronze',NULL,'cuivre et alliages cuivreux',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (374,'t_mobilier','matiere','laiton',NULL,'cuivre et alliages cuivreux',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (375,'t_mobilier','matiere','fer',NULL,'fer et alliages ferreux',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (376,'t_mobilier','matiere','alliage ferreux',NULL,'fer et alliages ferreux',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (377,'t_mobilier','matiere','acier',NULL,'fer et alliages ferreux',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (378,'t_mobilier','matiere','fonte',NULL,'fer et alliages ferreux',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (379,'t_mobilier','matiere','hématite',NULL,'fer et alliages ferreux',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (380,'t_mobilier','matiere','manganèse',NULL,'fer et alliages ferreux',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (381,'t_mobilier','matiere','plomb',NULL,'plomb et alliages plombifères',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (382,'t_mobilier','matiere','alliage plombifère',NULL,'plomb et alliages plombifères',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (383,'t_mobilier','matiere','antimoine',NULL,'plomb et alliages plombifères',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (384,'t_mobilier','matiere','étain',NULL,'étain',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (385,'t_mobilier','matiere','zinc',NULL,'zinc',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (386,'t_mobilier','matiere','monnaie',NULL,'monnaies',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (387,'t_mobilier','matiere','verre',NULL,'verre',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (388,'t_mobilier','matiere','verre mécanique',NULL,'verre',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (389,'t_mobilier','matiere','verre soufflé',NULL,'verre',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (390,'t_mobilier','matiere','verre indéterminé',NULL,'verre',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (391,'t_mobilier','matiere','pâte de verre',NULL,'verre',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (392,'t_mobilier','matiere','matériau composite',NULL,'matériau composite connu ou indéterminé ou matériaux divers',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (393,'t_mobilier','matiere','matériau composite indéterminé',NULL,'matériau composite connu ou indéterminé ou matériaux divers',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (394,'t_mobilier','matiere','divers',NULL,'matériau composite connu ou indéterminé ou matériaux divers',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (395,'t_mobilier','matiere','émail',NULL,'émaux sur métaux',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (396,'t_mobilier','matiere','mosaïque',NULL,'mosaïque',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (397,'t_mobilier','matiere','enduit peint',NULL,'enduit peint',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (398,'t_mobilier','matiere','matériel pierreux',NULL,'matériaux pierreux',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (399,'t_mobilier','matiere','mortier',NULL,'matériaux pierreux',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (400,'t_mobilier','matiere','plâtre',NULL,'matériaux pierreux',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (401,'t_mobilier','matiere','stuc',NULL,'matériaux pierreux',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (402,'t_mobilier','matiere','scorie',NULL,'industrie du métal ou du verre',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (403,'t_mobilier','matiere','creuset',NULL,'industrie du métal ou du verre',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (404,'t_mobilier','matiere','culot',NULL,'industrie du métal ou du verre',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (405,'t_mobilier','matiere','battiture',NULL,'industrie du métal ou du verre',NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (406,'t_minute','échelle','1/10e',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (407,'t_minute','échelle','1/20e',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (408,'t_minute','échelle','1/40e',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (409,'t_minute','échelle','1/50e',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (410,'t_minute','échelle','1/100e',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (411,'t_minute','support','calque',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (412,'t_minute','support','numérique',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (413,'t_minute','format','A4',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (414,'t_minute','format','A3',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (415,NULL,'auteur','M.X',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (416,NULL,'auteur','Mme Y.',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (417,'t_minute','format','autre',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (418,'t_sondage','sd_type','manuel',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (419,'t_sondage','sd_type','mécanique',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (420,'t_sondage','sd_type','profond',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (421, 't_ens', 'typens', 'archéologique', NULL, NULL, NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (422, 't_ens', 'typens', 'technique', NULL, NULL, NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (423, 't_ens', 'typens', 'entité architecturale', NULL, NULL, NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (424, 't_ens', 'interpret', 'bâtiment', NULL, 'archéologique', NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (425, 't_ens', 'interpret', 'enclos', NULL, 'archéologique', NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (426, 't_ens', 'interpret', 'palissade', NULL, 'archéologique', NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (427, 't_ens', 'interpret', 'cave', NULL, 'archéologique', NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (428, 't_ens', 'interpret', 'nécropole', NULL, 'archéologique', NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (429, 't_ens', 'interpret', 'zone', NULL, 'technique', NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (430, 't_ens', 'interpret', 'secteur', NULL, 'technique', NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (431, 't_ens', 'interpret', 'groupe', NULL, 'technique', NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (432, 't_photo', 'support', 'numérique', NULL, NULL, NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (433, 't_photo', 'support', 'argentique', NULL, NULL, NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (434, 't_photo', 'vue_vers', 'nord', NULL, NULL, NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (435, 't_photo', 'vue_vers', 'sud', NULL, NULL, NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (436, 't_photo', 'vue_vers', 'est', NULL, NULL, NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (437, 't_photo', 'vue_vers', 'ouest', NULL, NULL, NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (438, 't_photo', 'vue_vers', 'nord-est', NULL, NULL, NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (439, 't_photo', 'vue_vers', 'nord-ouest', NULL, NULL, NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (440, 't_photo', 'vue_vers', 'sud-est', NULL, NULL, NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (441, 't_photo', 'vue_vers', 'sud-ouest', NULL, NULL, NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (442, 't_photogram', 'obj_model', 'orthoimage', NULL, NULL, NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (443, 't_photogram', 'obj_model', 'coupe', NULL, NULL, NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (444, 't_photogram', 'obj_model', 'profil', NULL, NULL, NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (445, 't_photogram', 'obj_model', 'modèle 3D', NULL, NULL, NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (446, 't_photogram', 'suivi', 'aérotriangulation', NULL, NULL, NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (447, 't_photogram', 'suivi', 'génération du nuage dense', NULL, NULL, NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (448, 't_photogram', 'suivi', 'génération du MNS', NULL, NULL, NULL);
INSERT INTO "thesaurus_badass" ("id_thes", "tabl_thes", "field_thes", "val_thes", "def_thes", "cat_thes", "comment") VALUES (449, 't_photogram', 'suivi', 'génération d''une orthoimage', NULL, NULL, NULL);



----------------------------------------------------------------------------------------------------------------------
-- LES TRIGGERS --
 
-- pour les préfixes :
-- trg pour TRIGGER
-- a pour AFTER
-- b pour BEFORE
-- i pour INSERT
-- u pour UPDATE
-- d pour DELETE


-- les triggers à mettre en place pour la table poly (qui doivent mettre à jour les tables t_fait et t_us)

-- AFTER INSERT
-- qui met à jour la table t_fait après CREATION d'une entité dans poly
CREATE TRIGGER trgai_poly_maj_t_fait /*déclaration de création d'un nouveau trigger qui a pour nom...*/
    AFTER INSERT /*qui sera exécuté après l'ajout d'une nouvelle entité*/
    ON poly /*sur/dans la table*/
FOR EACH ROW /*commande obligatoire : pour tous les enregistrement*/
WHEN (NEW.typoly = 'fait') /*cette condition permet de restreindre les enregistrements concernés aux seuls 'fait' ; NEW correspond à une copie temporaire des nouveaux éléments de la table t_poly effectuée lors de l'exécution du trigger*/
BEGIN /* debut de l'action déclenchée*/
UPDATE t_fait /*avec une modification de la table t_fait*/
SET geometry = NEW.geometry /*qui redéfini la valeur du champ "geom" de la table t_fait par la valeur du champ "geom" de la copie temporaire NEW de la table t_poly*/
WHERE NEW.numpoly = numfait ; /*à chaque fois que la valeur du champ "num_fait" de la table t_fait est égale à la valeur du champ "numpoly" de la copie temporaire NEW de la table t_poly*/
END ; /*fin de l'action et fin du trigger*/

-- qui met à jour la table t_us après CREATION d'une entité dans poly
CREATE TRIGGER trgai_poly_maj_t_us 
    AFTER INSERT 
    ON poly 
FOR EACH ROW 
WHEN (NEW.typoly IN('US','us'))
   BEGIN
   UPDATE t_us
   SET geometry = NEW.geometry 
   WHERE NEW.numpoly = numus ;
END ; 

-- AFTER UPDATE
-- qui met à jour la table t_fait après MODIFICATION d'une entité dans poly
CREATE TRIGGER trgau_poly_maj_t_fait
   AFTER UPDATE /*qui sera exécuté après la modification de la géométrie d'une entité*/
   ON poly
FOR EACH ROW
WHEN (NEW.typoly = 'fait')
BEGIN
UPDATE t_fait
SET geometry = NEW.geometry
WHERE NEW.numpoly = numfait ;
END ;

-- qui met à jour la table t_us après MODIFICATION d'une entité dans poly
CREATE TRIGGER trgau_poly_maj_t_us
   AFTER UPDATE 
   ON poly
FOR EACH ROW
WHEN (NEW.typoly IN('US','us') )
   BEGIN
UPDATE t_us
SET geometry = NEW.geometry
WHERE NEW.numpoly = numus ;
END ;


-- AFTER DELETE
-- pas utile, parce que dans le cas d'une annulation, on préfère indiquer que l'objet est annulé plutôt que de supprimer l'enregitrement et dans le cas de mise à jour des entités dans la couche poly après un lever topo, il ne doit pas y avoir de conséquence sur l'enregistrement dans t_fait ou t_us


-- les triggers à mettre en place pour la table t_fait (qui doivent mettre à jour la table poly)

-- AFTER INSERT
-- on n'en fait pas de celui là car une création d'entité 
-- dans t_fait ne doit pas forcément induire une création équivalente dans t_poly

-- AFTER UPDATE
CREATE TRIGGER trgau_t_fait_maj_poly /*déclaration de création d'un nouveau trigger qui a pour nom...*/
   AFTER UPDATE /*qui sera exécuté après la modification de la géométrie d'une entité*/
   ON t_fait /*sur la table*/
FOR EACH ROW /*commande obligatoire : pour tous les enregistrement*/
BEGIN /* debut de l'action déclenchée*/
UPDATE poly /*avec une modification de la table t_poly*/
SET geometry = NEW.geometry /*qui redéfini la valeur du champ "geom" de la table t_poly par la valeur du champ "geom" de la copie temporaire des nouveaux éléments NEW de la table t_fait*/
WHERE NEW.numfait = numpoly AND typoly = 'fait' ; /*pour les entités dont la valeur du champ "numpoly" de la table t_poly est égale à la valeur du champ "num_fait" de la copie temporaire NEW de la table t_fait et pour lesquels la valeur 'fait' est renseignée dans le champ "typoly"*/
END ; /*fin de l'action et fin du trigger*/

-- AFTER DELETE
-- inutile, voir supra

-- les triggers à mettre en place pour la table t_us (qui doivent mettre à jour la table poly)
-- AFTER UPDATE
CREATE TRIGGER trgau_t_us_maj_poly 
   AFTER UPDATE 
   ON t_us 
FOR EACH ROW 
BEGIN 
UPDATE poly 
SET geometry = NEW.geometry 
WHERE NEW.numus = numpoly AND typoly = 'us' ; 
END ; 

-- AFTER DELETE
-- inutile, voir supra


-- les triggers à mettre en place pour la table ouverture (qui doivent mettre à jour les tables t_sondage et t_tranchee)

-- AFTER INSERT
-- qui met à jour la table t_sondage après CREATION d'une entité dans ouverture
CREATE TRIGGER trgai_ouverture_maj_t_sondage 
    AFTER INSERT 
    ON ouverture 
FOR EACH ROW 
WHEN (NEW.typouvert = 'sondage') 
BEGIN 
UPDATE t_sondage 
SET geometry = NEW.geometry 
WHERE NEW.numouvert = numsd ; 
END ; 

-- qui met à jour la table t_tranchee après CREATION d'une entité dans ouverture
CREATE TRIGGER trgai_ouverture_maj_t_tranchee 
    AFTER INSERT 
    ON ouverture 
FOR EACH ROW 
WHEN (NEW.typouvert = 'tranchée') 
   BEGIN
   UPDATE t_tranchee
   SET geometry = NEW.geometry 
   WHERE NEW.numouvert = numtr ;
END ; 

-- AFTER UPDATE
-- qui met à jour la table t_sondage après MODIFICATION d'une entité dans ouverture
CREATE TRIGGER trgau_ouverture_maj_t_sondage
   AFTER UPDATE 
   ON ouverture
FOR EACH ROW
WHEN (NEW.typouvert = 'sondage')
BEGIN
UPDATE t_sondage
SET geometry = NEW.geometry
WHERE NEW.numouvert = numsd ;
END ;

-- qui met à jour la table t_tranchee après MODIFICATION d'une entité dans ouverture
CREATE TRIGGER trgau_ouverture_maj_t_tranchee
   AFTER UPDATE 
   ON ouverture
FOR EACH ROW
WHEN (NEW.typouvert = 'tranchée')
BEGIN
UPDATE t_tranchee
SET geometry = NEW.geometry
WHERE NEW.numouvert = numtr ;
END ;

-- AFTER DELETE
-- inutile, voir supra 


-- les triggers à mettre en place pour la table t_sondage (qui doivent mettre à jour la table ouverture)
-- AFTER UPDATE
CREATE TRIGGER trgau_t_sondage_maj_ouverture 
   AFTER UPDATE 
   ON t_sondage 
FOR EACH ROW 
BEGIN 
UPDATE ouverture 
SET geometry = NEW.geometry 
WHERE NEW.numsd = numouvert AND typouvert = 'sondage' ; 
END ; 

-- AFTER DELETE
-- inutile, voir supra


-- les triggers à mettre en place pour la table t_tranchee (qui doivent mettre à jour la table ouverture)
-- AFTER UPDATE
CREATE TRIGGER trgau_t_tranchee_maj_ouverture 
   AFTER UPDATE 
   ON t_tranchee 
FOR EACH ROW 
BEGIN 
UPDATE ouverture 
SET geometry = NEW.geometry 
WHERE NEW.numtr = numouvert AND typouvert = 'tranchée' ; 
END ; 

-- AFTER DELETE
-- inutile, voir supra


-- les triggers à mettre en place pour la table axe (qui doivent mettre à jour la tables t_axe)

-- AFTER INSERT
-- qui met à jour la table t_axe après CREATION d'une entité dans axe
CREATE TRIGGER trgai_axe_maj_t_axe 
    AFTER INSERT 
    ON axe 
FOR EACH ROW 
BEGIN 
UPDATE t_axe 
SET geometry = NEW.geometry 
WHERE NEW.numaxe = numaxe ; 
END ; 

-- AFTER UPDATE
-- qui met à jour la table t_axe après MODIFICATION d'une entité dans axe
CREATE TRIGGER trgau_axe_maj_t_axe
   AFTER UPDATE 
   ON axe
FOR EACH ROW
BEGIN
UPDATE t_axe
SET geometry = NEW.geometry
WHERE NEW.numaxe = numaxe ;
END ;

-- AFTER DELETE
-- inutile, voir supra

-- les triggers à mettre en place pour la table t_axe (qui doivent mettre à jour la table axe)
-- AFTER UPDATE
CREATE TRIGGER trgau_t_axe_maj_axe 
   AFTER UPDATE 
   ON t_axe 
FOR EACH ROW 
BEGIN 
UPDATE axe 
SET geometry = NEW.geometry 
WHERE NEW.numaxe = numaxe ; 
END ; 

-- AFTER DELETE
-- inutile, voir supra 


-- les triggers à mettre en place pour la table point (qui doivent mettre à jour la tables t_mobilier)

-- AFTER INSERT
-- qui met à jour la table t_mobilier après CREATION d'une entité dans point
CREATE TRIGGER trgai_point_maj_t_mobilier 
    AFTER INSERT 
    ON point
FOR EACH ROW 
BEGIN 
UPDATE t_mobilier 
SET geometry = NEW.geometry 
WHERE NEW.numpoint = numpoint ; 
END ; 

-- AFTER UPDATE
-- qui met à jour la table t_mobilier après MODIFICATION d'une entité dans point
CREATE TRIGGER trgau_point_maj_t_mobilier
   AFTER UPDATE 
   ON point
FOR EACH ROW
BEGIN
UPDATE t_mobilier
SET geometry = NEW.geometry
WHERE NEW.numpoint = numpoint ;
END ;

-- AFTER DELETE
-- inutile, voir supra

-- les triggers à mettre en place pour la table t_point (qui doivent mettre à jour la table point)
-- AFTER UPDATE
CREATE TRIGGER trgau_t_mobilier_maj_point 
   AFTER UPDATE 
   ON t_mobilier 
FOR EACH ROW 
BEGIN 
UPDATE point 
SET geometry = NEW.geometry 
WHERE NEW.numpoint = numpoint ; 
END ; 

-- AFTER DELETE
-- inutile, voir supra

-- les triggers à mettre en place pour la table log (qui doivent mettre à jour la tables t_log)

-- AFTER INSERT
-- qui met à jour la table t_log après CREATION d'une entité dans log
CREATE TRIGGER trgai_log_maj_t_log 
    AFTER INSERT 
    ON log
FOR EACH ROW 
BEGIN 
UPDATE t_log 
SET geometry = NEW.geometry 
WHERE NEW.numlog = numlog ; 
END ; 

-- AFTER UPDATE
-- qui met à jour la table t_log après MODIFICATION d'une entité dans log
CREATE TRIGGER trgau_log_maj_t_log
   AFTER UPDATE 
   ON log
FOR EACH ROW
BEGIN
UPDATE t_log
SET geometry = NEW.geometry
WHERE NEW.numlog = numlog ;
END ;

-- AFTER DELETE
-- inutile, voir supra

-- les triggers à mettre en place pour la table t_log (qui doivent mettre à jour la table plog)
-- AFTER UPDATE
CREATE TRIGGER trgau_t_log_maj_log 
   AFTER UPDATE 
   ON t_log 
FOR EACH ROW 
BEGIN 
UPDATE log 
SET geometry = NEW.geometry 
WHERE NEW.numlog = numlog ; 
END ; 

-- AFTER DELETE
-- inutile, voir supra

-- les triggers qui vont doubler les relations horizontales entre les US
-- après la création d'une relation entre US
CREATE TRIGGER trgai_j_rel_us
   AFTER INSERT
   ON j_rel_us
FOR EACH ROW
WHEN (NEW."typrel" like 'égale' OR NEW."typrel" like 'équivalente' OR NEW."typrel" like 'synchrone')
BEGIN
   INSERT INTO j_rel_us ("numus1","numus2","typrel","incert") VALUES (NEW."numus2", NEW."numus1", NEW."typrel", NEW."incert");
END;

-- après la mise à jour d'une relation entre US. ATTENTION : ce trigger est passé en commentaire car au final il semble redondant avec le INSERT (à voir...)
/*CREATE TRIGGER trgau_j_rel_us
   AFTER UPDATE
   ON j_rel_us
FOR EACH ROW
WHEN (NEW."jru_typrel" like 'égale' OR NEW."jru_typrel" like 'équivalente' OR NEW."jru_typrel" like 'synchrone')
BEGIN
   INSERT INTO j_rel_us ("jru_us1","jru_us2","jru_typrel","jru_incert") VALUES (NEW."jru_us2", NEW."jru_us1", NEW."jru_typrel", NEW."jru_incert");
end;*/

-- après la suppression d'une relation entre US
CREATE TRIGGER trgad_j_rel_us 
   AFTER DELETE 
   ON j_rel_us 
FOR EACH ROW 
WHEN (OLD."typrel" like 'égale' OR OLD."typrel" like 'équivalente' OR OLD."typrel" like 'synchrone') 
BEGIN 
DELETE FROM j_rel_us 
WHERE ("numus1" = OLD."numus2" and "numus2" = OLD."numus1" and "typrel" = OLD."typrel" and "incert" = OLD."incert"); 
END ; 






--Les vues
--Vue de récapitulation des faits enregistrés par tranchée
CREATE VIEW vue_recap_fait_tranchee AS
SELECT "numtr",
GROUP_CONCAT("numfait",', ') AS recap_fait
FROM (select * from j_rel_tranchee order by "numfait")
GROUP BY "numtr"
ORDER BY "numfait";

--Vue de récapitulation des US enregistrées par fait
CREATE VIEW vue_recap_us_fait AS
SELECT "numfait" as numfait,
GROUP_CONCAT("numus",', ') as recap_us
FROM (select * from t_us order by "numus")
GROUP BY "numfait"
ORDER BY "numus";

--Vue de récapitulation des relations stratigraphiques par US
CREATE VIEW vue_recap_relationus AS
SELECT "numus1" as numus,
GROUP_CONCAT(CASE WHEN "typrel" LIKE 'sous' THEN "numus2" ELSE null END, ', ') AS us_posterieur,
GROUP_CONCAT(CASE WHEN "typrel" LIKE 'sur' THEN "numus2" ELSE null END, ', ') AS us_anterieur,
GROUP_CONCAT(CASE WHEN "typrel" IN('égale','équivalente','synchrone') THEN "numus2" ELSE null END, ', ') AS rel_horizontal
FROM (select * from j_rel_us order by "numus2")
GROUP BY numus1
ORDER BY numus1;

--Vue d'inversion des relations stratigraphiques à partir de la table j_rel_us
CREATE VIEW vue_j_rel_us_inverse AS
SELECT "id_rel_us", "numus2" as numus1,
CASE WHEN "typrel" LIKE 'sur' THEN 'sous'
WHEN "typrel" LIKE 'sous' THEN 'sur' end as typrel,
"numus1" as numus2, incert
FROM j_rel_us
WHERE "typrel" IN ('sur','sous');

--Vue de récapitulation des relations stratigraphiques par US
CREATE VIEW vue_recap_relationus_deduite AS
SELECT "numus1" as numus,
GROUP_CONCAT(CASE WHEN "typrel" LIKE 'sous' THEN "numus2" ELSE null END, ', ') AS us_posterieur,
GROUP_CONCAT(CASE WHEN "typrel" LIKE 'sur' THEN "numus2" ELSE null END, ', ') AS us_anterieur,
GROUP_CONCAT(CASE WHEN "typrel" IN('égale','équivalente','synchrone') THEN "numus2" ELSE null END, ', ') AS rel_horizontal
FROM (select * from vue_j_rel_us_inverse order by "numus2")
GROUP BY numus1
ORDER BY numus1;

--Vue de récapitulation des tranchées, sondages, faits, us, log et iso par minute
CREATE VIEW vue_recap_minute AS
select m.*, m1."numinute", 
group_concat(m1."numtr", ', ') as recap_tr, 
group_concat(m1."numsd", ', ') as recap_sd, 
group_concat(m1."numlog", ', ') as recap_log,
group_concat(m1."numfait", ', ') as recap_fait, 
group_concat(m1."numus", ', ') as recap_us, 
group_concat(m1."numiso", ', ') as recap_iso
from j_rel_minute as m1
join t_minute as m on m1."numinute" = m."numinute"
group by m1."numinute"
order by m1."numinute";

--Vue de récapitulation des tranchées, sondages, faits, us et iso par photo
CREATE VIEW vue_recap_photo AS
select p.*, m1."numphoto", 
group_concat(m1."numtr", ', ') as recap_tr, 
group_concat(m1."numsd", ', ') as recap_sd,
group_concat(m1."numlog", ', ') as recap_log,
group_concat(m1."numfait", ', ') as recap_fait, 
group_concat(m1."numus", ', ') as recap_us, 
group_concat(m1."numiso", ', ') as recap_iso
from j_rel_photo as m1
join t_photo as p on m1."numphoto" = p."id_photo"
group by m1."numphoto"
order by p."id_photo";

-- Vue d'exportation de la table t_us pour le stratifiant. Manque quelques champs : FPAestime (date estimée au plus ancien de fin de formation de l'US) ; FPRestime (date estimée au plus récent de fin de formation de l'US) ; REF_PhaseDebut (n° d'ordre de la phase au plus ancien attribué à l'US) ; REF_PhaseFin (n° d'ordre de la phase au plus récent attribué à l'US). Pour ces requêtes, j'ai besoin d'aide...
CREATE VIEW ExportUS AS
SELECT "numus" AS ID_US, REPLACE(REPLACE( "type_us",'couche physique','couche'),'négative','négatif') AS Type_US, "datinf_interpret" AS FPA, "datsup_interpret" AS FPR
FROM t_us; 

-- Vue d'exportation de la table de relations stratigraphiques pour les relations d'antériorité/postériorié. Manque le champ RelationIncertaine rempli par NULL ou '?'
CREATE VIEW ExportRelations AS
SELECT DISTINCT CASE WHEN "typrel" LIKE 'sur' THEN "numus2" WHEN "typrel" LIKE 'sous' THEN "numus1" END AS REF_USanterieure, CASE WHEN "typrel" LIKE 'sur' THEN "numus1" WHEN "typrel" LIKE 'sous' THEN "numus2" END AS REF_USposterieure
FROM j_rel_us
WHERE "typrel" IN ('sur', 'sous');

-- Vue d'exportation de la table de relations stratigraphiques pour les relations horizontales. Manque le champ RelationIncertaine rempli par NULL ou '?'
CREATE VIEW ExportSynchros AS
SELECT DISTINCT CASE WHEN "typrel" IN ('égale','équivalente','synchrone') THEN "numus1" END AS REF_USsynchro1, CASE WHEN "typrel" IN ('égal','équivalent','synchrone') THEN "numus2" END AS REF_USsynchro2
FROM j_rel_us
WHERE "typrel" IN ('égal','équivalent','synchrone');

-- Vue de détection des erreurs d'écritures de relations stratigraphiques : sur une même US ou relations contradictoires 
CREATE VIEW erreur_saisie_strati AS
SELECT *, CASE WHEN r."REF_USanterieure" = r."REF_USposterieure"  THEN 'relation verticale sur la même US' WHEN s."REF_USsynchro1" = s."REF_USsynchro2" THEN 'relation horizontale sur la même US' WHEN r."REF_USanterieure"||r."REF_USposterieure" = r."REF_USposterieure"||r."REF_USanterieure" THEN 'relations stratigraphiques contradictoires' END AS nature_erreur
FROM ExportRelations AS r, ExportSynchros AS s
WHERE r."REF_USanterieure" = r."REF_USposterieure"
OR r."REF_USanterieure"||r."REF_USposterieure" = r."REF_USposterieure"||r."REF_USanterieure"
OR s."REF_USsynchro1" = s."REF_USsynchro2";

