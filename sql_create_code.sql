/*

BADASS : Base Archéologique de Données Attributaires et SpatialeS

Auteur : Caroline Font, Thomas Guillemard, Florent Mercey. Inrap, Saint-Cyr-en-Val, 2020.

Remarques diverses :
- Les FOREIGN KEY sont commentées afin de ne pas en subir la contrainte, mais de garder le principe du MCD

*/



-- LES 6 COUCHES

-- EMPRISE : unité technique ; emprises de l’opération
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
   "surface" REAL
);
SELECT
AddGeometryColumn ('emprise','geometry',2154,'MULTIPOLYGON','XY',0); -- ajoute la colonne geométrie. Attention, fonction de Spatialite uniquement !!!

-- OUVERTURE : unité technique : tout creusement réalisé à des fins d’observation (sondage, tranchée, décapage...)
DROP TABLE IF EXISTS ouverture;
CREATE TABLE ouverture(
   "id_ouverture" INTEGER PRIMARY KEY,
   "numouvert" TEXT,
   "typouvert" TEXT,
   "surface" REAL
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
   "z_point" REAL
);
SELECT
AddGeometryColumn ('point','geometry',2154,'POINT','XY',0);

-- AXE : unité technique matérialisant l’axe de coupe, sous forme de ligne
DROP TABLE IF EXISTS axe;
CREATE TABLE axe(
   "id_axe" INTEGER PRIMARY KEY,
   "numaxe" TEXT,
   "typaxe" TEXT,
   "z_axe" REAL,
   "longu_axe" REAL
);
SELECT
AddGeometryColumn ('axe','geometry',2154,'LINESTRING','XY',0);

-- LOG : unité technique ponctuelle localisant l’emplacement des prélèvements, des logs géomorphologiques (lieux d’observation ponctuels)
DROP TABLE IF EXISTS plog;
CREATE TABLE plog(
   "id_plog" INTEGER PRIMARY KEY,
   "numplog" TEXT,
   "typlog" TEXT,
   "alti" REAL,
   "typalti" TEXT
);
SELECT
AddGeometryColumn ('plog','geometry',2154,'POINT','XY',0);


-- LES COUPES DANS QGIS : tables nécessaires pour réaliser les coupes des faits dans QGIS (Caro POWAAAAA)

-- La table coupe_axe
DROP TABLE IF EXISTS coupe_axe;
CREATE TABLE coupe_axe(
   "id_axe" INTEGER PRIMARY KEY,
   "numinute" INTEGER
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
   "typline" TEXT
   --FOREIGN KEY("id_axe") REFERENCES "coupe_axe"("id_axe"),
   --FOREIGN KEY("numfait") REFERENCES "t_fait"("f_numfait"),
   --FOREIGN KEY("numus") REFERENCES "t_us"("u_numus")
);
SELECT
AddGeometryColumn ('coupe_line','geometry',2154,'MULTILINESTRING','XY',0); -- mieux vaut prévoir une géométrie multiple dans le cas où une US négative serait interrompue (sondage, perturbation diverse)

-- La table coupe_poly
DROP TABLE IF EXISTS coupe_poly;
CREATE TABLE coupe_poly(
   "id_cpoly" INTEGER PRIMARY KEY,
   "id_axe" INTEGER,
   "numfait" INTEGER,
  "numus" INTEGER,
   "typolyc" TEXT,
   "detail" TEXT
   --FOREIGN KEY("id_axe") REFERENCES "coupe_axe"("id_axe"),
   --FOREIGN KEY("numfait") REFERENCES "fait"("f_numfait"),
   --FOREIGN KEY("numus") REFERENCES "us"("u_numus")
);
SELECT
AddGeometryColumn ('coupe_poly','geometry',2154,'MULTIPOLYGON','XY',0);


-- LA BASE ARCHEO : les tables des faits, sondage, us, etc. La géométrie peut être associée.

-- FAIT : la table des faits archéologique qui récupère la géométrie par trigger de la table poly (6 couches) pour "typoly" LIKE 'fait'
DROP TABLE IF EXISTS t_fait;
CREATE TABLE t_fait(
   "f_id" INTEGER PRIMARY KEY,
   "f_numfait" INTEGER UNIQUE,
   "f_interpret_alter" TEXT,
   "f_interpret" TEXT,
   "f_douteux" INTEGER,
   "f_equiv_diag" TEXT,
   "f_statut" TEXT,
   "f_rais_annule" TEXT,
   "f_fouille" INTEGER,
   "f_enr_fini" INTEGER,
   "f_relev_fini" INTEGER,
   "f_photo_fini" INTEGER,
   "f_topo_fini" INTEGER,
   "f_profil" TEXT,
   "f_forme" TEXT,
   "f_orient" TEXT,
   "f_orient_calc" REAL,
   "f_descrip" REAL,
   "f_prof_app" REAL,
   "f_diam" REAL,
   "f_dim_max" REAL,
   "f_dim_min" REAL,
   "f_epais" REAL,
   "f_prof_haut" REAL,
   "f_periode" REAL,
   "f_note" TEXT
);
SELECT
AddGeometryColumn ('t_fait','geometry',2154,'MULTIPOLYGON','XY',0);

-- US : unité stratitgraphique qui récupère la géométrie par trigger de la table poly (6 couches) pour "typoly" LIKE 'us'
DROP TABLE IF EXISTS t_us;
CREATE TABLE t_us(
   "u_id" INTEGER PRIMARY KEY,
   "u_numus" INTEGER UNIQUE,
   "u_numfait" INTEGER,
   "u_type_us" TEXT,
   "u_nature_us" TEXT,
   "u_interpret" TEXT,
   "u_datsup_interpret" INTEGER,
   "u_datfin_interpret" INTEGER,
   "u_datsup_mobilier" INTEGER,
   "u_datinf_mobilier" INTEGER,
   "u_datsup_14c" INTEGER,
   "u_datinf_14c" INTEGER,
   "u_note_dat" TEXT,
   "u_forme" TEXT,
   "u_diam" REAL,
   "u_dim_max" REAL,
   "u_dim_min" REAL,
   "u_prof_app" REAL,
   "u_zmin" REAL,
   "u_zmax" REAL,
   "u_epais" REAL,
   "u_compo_sediment" TEXT,
   "u_texture" TEXT,
   "u_couleur" TEXT,
   "u_valeur_couleur" TEXT,
   "u_creator" TEXT,
   "u_datcreation" DATE,
   "u_note" TEXT,
   "u_num_seq" INTEGER,
   "u_ordre_seq" INTEGER
   -- FOREIGN KEY("u_numfait") REFERENCES "t_fait"("f_numfait")
);
SELECT
AddGeometryColumn ('t_us','geometry',2154,'MULTIPOLYGON','XY',0);

-- ENSEMBLE : les ensembles regroupant des faits et/ou des us (bâtiment...)
DROP TABLE IF EXISTS t_ens;
CREATE TABLE t_ens(
   "ens_id" INTEGER PRIMARY KEY,
   "ens_num" INTEGER,
   "ens_description" TEXT,
   "ens_note" TEXT
);
SELECT
AddGeometryColumn ('t_ens','geometry',2154,'MULTIPOLYGON','XY',0);

-- SONDAGE : pour les ouvertures (unité technique) de type sondage qui récupère la géométrie par trigger de la table ouverture (6 couches) pour "typouvert" LIKE 'sondage'
DROP TABLE IF EXISTS t_sondage;
CREATE TABLE t_sondage(
   "sd_id" INTEGER PRIMARY KEY,
   "sd_num" INTEGER UNIQUE,
   "sd_numtr" INTEGER,
   "sd_type" TEXT,
   "sd_prof" REAL,
   "sd_note" TEXT
   -- FOREIGN KEY("sd_numtr") REFERENCES t_tranchee("tr_num")
);
SELECT
AddGeometryColumn ('t_sondage','geometry',2154,'MULTIPOLYGON','XY',0);

--TRANCHEE : pour les ouvertures (unité technique) de type tranchée qui récupère la géométrie par trigger de la table ouverture (6 couches) pour "typouvert" LIKE 'tranchée'
DROP TABLE IF EXISTS t_tranchee;
CREATE TABLE t_tranchee(
   "tr_id" INTEGER PRIMARY KEY,
   "tr_num" INTEGER UNIQUE,
   "tr_long" REAL,
   "tr_larg" REAL,
   "tr_surface" REAL,
   "tr_prof_max" REAL,
   "tr_prof_min" REAL,
   "tr_note" TEXT
   );
SELECT
AddGeometryColumn('t_tranchee','geometry',2154,'MULTIPOLYGON','XY',0);

-- PHOTO : les photographies numériques (pas de géométrie)
DROP TABLE IF EXISTS t_photo;
CREATE TABLE t_photo(
   "ph_id" INTEGER PRIMARY KEY,
   "ph_nom" TEXT,
   "ph_url" TEXT,
   "ph_descr" TEXT,
   "ph_vue_vers" TEXT,
   "ph_creator" TEXT,
   "ph_date" DATE,
   "ph_sujet" TEXT
);

-- MINUTE : les relevés de terrain sur minute de chantier (pas de géométrie)
DROP TABLE IF EXISTS t_minute;
CREATE TABLE t_minute(
   "min_id" INTEGER PRIMARY KEY,
   "min_num" INTEGER,
   "min_descr" TEXT,
   "min_echelle" TEXT,
   "min_contenu" TEXT,
   "min_creator" TEXT,
   "min_format" TEXT,
   "min_support" TEXT,
   "min_scan" INTEGER,
   "min_dao" INTEGER
);

-- MOBILIER : CETTE TABLE EST A REVOIR COMPLETEMENT
DROP TABLE IF EXISTS t_mobilier;
CREATE TABLE t_mobilier(
   "mob_id" INTEGER PRIMARY KEY,
   "mob_numiso" INTEGER,
   "mob_numpoint" INTEGER,
   "mob_us" INTEGER,
   "mob_fait" INTEGER,
   "mob_iso_lot" INTEGER,
   "mob_iso_ident" TEXT,
   "mob_catego" TEXT,
   "mob_sscatego" TEXT,
   "mob_alt" REAL,
   "mob_dim_min" REAL,
   "mob_dim_max" REAL,
   "mob_diam" REAL,
   "mob_masse" REAL,
   "mob_nr" INTEGER,
   "mob_pr" INTEGER,
   "mob_etatcons" TEXT,
   "mob_note" TEXT,
   "mob_datesup" INTEGER,
   "mob_dateinf" INTEGER,
   "mob_dat_note" TEXT
   -- FOREIGN KEY("mob_fait") REFERENCES "t_fait"("f_numfait")
   -- FOREIGN KEY("mob_us") REFERENCES "t_us"("u_numus")
 );
SELECT
AddGeometryColumn ('t_mobilier','geometry',2154,'POINT','XY',0);

-- SEQUENCE : regroupement des US en séquences stratigraphiques (pas de géométrie)
DROP TABLE IF EXISTS t_seq;
CREATE TABLE t_seq(
   "seq_num" INTEGER PRIMARY KEY,
   "seq_titre" TEXT,
   "seq_dat" TEXT,
   "seq_crit_dat" TEXT,
   "seq_note" TEXT
);

-- PHASE : regroupement des séquences en phases chrono-stratigraphiques (pas de géométrie)
DROP TABLE IF EXISTS t_phase;
CREATE TABLE t_phase(
   "pha_num" INTEGER PRIMARY KEY,
   "pha_titre" TEXT NOT NULL,
   "pha_dat" TEXT,
   "pha_tpq" INTEGER,
   "pha_taq" INTEGER,
   "pha_note" TEXT
);

-- PERIODE : regroupement des phases en périodes chronologiques (pas de géométrie)
DROP TABLE IF EXISTS t_periode;
CREATE TABLE t_periode(
   "per_num" INTEGER PRIMARY KEY,
   "per_titre" TEXT UNIQUE,
   "per_dat" TEXT,
   "per_note" TEXT
);

-- LOG : les logs enregistrés/décrits sur le terrain qui récupère la géométrie par trigger de la table plog (6 couches)
DROP TABLE IF EXISTS t_log;
CREATE TABLE t_log(
   "id_log" INTEGER PRIMARY KEY,
   "numlog" INTEGER,
   "numtr" INTEGER,
   "numsd" INTEGER,
   "alti" REAL,
   "prof_log" REAL,
   "zmin_log" REAL,
   "objectif_log" TEXT,
   "note_log" TEXT
   -- FOREIGN KEY("numtr) REFERENCES t_tranchee("tr_num")
   -- FOREIGN KEY("numsd) REFERENCES t_sondage("sd_num")
);
SELECT
AddGeometryColumn ('t_log','geometry',2154,'POINT','XY',0);

-- AXE : les axes de relevé de plan et/ou coupe effectués sur le terrain qu'il peut être nécessaire d'enregistrer (en relation de n à n avec fait, us, sd, tr)
DROP TABLE IF EXISTS t_axe;
CREATE TABLE t_axe(
   "id_axe" INTEGER PRIMARY KEY,
   "a_numaxe" INTEGER,
   "a_note_axe" TEXT,
   "a_longaxe" REAL,
   "a_altiaxe" REAL
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
   "sd_num" INTEGER,
   "tr_num" INTEGER
   -- FOREIGN KEY("numaxe") REFERENCES t_axe("a_numaxe")
   -- FOREIGN KEY("tr_num") REFERENCES t_tranchee("tr_num")
   -- FOREIGN KEY("sd_num") REFERENCES t_sondage("sd_num")
   -- FOREIGN KEY("numus") REFERENCES "t_us"("u_numus"),
   -- FOREIGN KEY("numfait") REFERENCES "t_fait"("f_numfait")
);

-- gestion de la relation entre les US et les LOG
DROP TABLE IF EXISTS j_us_log;
CREATE TABLE j_us_log(
   "id_us_log" INTEGER PRIMARY KEY,
   "numus" INTEGER,
   "numlog" INTEGER,
   "prof_toit" REAL,
   "prof_base" REAL,
   "epais_uslog" REAL,
   "zmax_uslog" REAL,
   "zmin_uslog" REAL
   --FOREIGN KEY("numlog") REFERENCES "t_log"("numlog"),
   --FOREIGN KEY("numus") REFERENCES "t_us"("u_numus")
);

-- gestion de la relation, les US (relation stratigraphique inter-US)
DROP TABLE IF EXISTS j_rel_us;
CREATE TABLE j_rel_us(
   "jru_id" INTEGER PRIMARY KEY,
   "jru_us1" INTEGER,
   "jru_us2" INTEGER,
   "jru_typrel" text,
   "jru_incert" INTEGER
   -- FOREIGN KEY("jru_us1") REFERENCES t_us("u_numus"),
   -- FOREIGN KEY("jru_us2") REFERENCES t_us("u_numus")
);

-- gestion de la relation, les faits (relation stratigraphique inter-faits)
DROP TABLE IF EXISTS j_rel_fait;
CREATE TABLE j_rel_fait(
   "jrf_id" INTEGER PRIMARY KEY,
   "jrf_fait1" INTEGER,
   "jrf_fait2" INTEGER,
   "jrf_typrel" text,
   "jrf_incert" INTEGER
   -- FOREIGN KEY("jrf_fait1") REFERENCES t_fait("f_numfait"),
   -- FOREIGN KEY("jrf_fai2") REFERENCES t_fait("f_numfait")
);

-- gestion de la relation entre les sondages et les US et faits
DROP TABLE IF EXISTS j_rel_sondage;
CREATE TABLE j_rel_sondage(
   "jrs_id" INTEGER PRIMARY KEY,
   "jrs_numsd" INTEGER,
   "jrs_numus" INTEGER,
   "jrs_numfait" INTEGER
   -- FOREIGN KEY("jrs_numsd") REFERENCES "t_sondage"("sd_num"),
   -- FOREIGN KEY("jrs_numus") REFERENCES "t_us"("u_numus"),
   -- FOREIGN KEY("jrs_numfait") REFERENCES "t_fait"("f_numfait")
);

-- gestion de la relation entre les tranchées et les US et faits
DROP TABLE IF EXISTS j_rel_tranchee;
CREATE TABLE j_rel_tranchee(
   "jrt_id" INTEGER PRIMARY KEY,
   "jrt_numtr" INTEGER,
   "jrt_numus" INTEGER,
   "jrt_numfait" INTEGER
   -- FOREIGN KEY("jrt_numtr") REFERENCES "t_tranchee"("tr_num"),
   -- FOREIGN KEY("jrt_numus") REFERENCES "t_us"("u_numus"),
   -- FOREIGN KEY("jrt_numfait") REFERENCES "t_fait"("f_numfait")
);

--gestion de la relation entre les ensembles et les US et faits
DROP TABLE IF EXISTS j_rel_ens;
CREATE TABLE j_rel_ens(
   "jre_id" INTEGER PRIMARY KEY,
   "jre_numens" INTEGER,
   "jre_numus" INTEGER,
   "jre_numfait" INTEGER,
   "jre_typrel" TEXT,
   "jre_incert" INTEGER
   -- FOREIGN KEY("jre_numens") REFERENCES "t_ens"("numens"),
   -- FOREIGN KEY("jre_numfait") REFERENCES "t_fait"("f_numfait"),
   -- FOREIGN KEY("jre_numus") REFERENCES "us"("u_numus")
);

-- gestion de la relation entre les séquences et les phases
DROP TABLE IF EXISTS j_seq_phase;
CREATE TABLE j_seq_phase(
   "jsp_id" INTEGER PRIMARY KEY,
   "jsp_numseq" INTEGER NOT NULL,
   "jsp_numphase" INTEGER,
   "jsp_ordre_seq_phase" INTEGER
   --FOREIGN KEY("jsp_numseq") REFERENCES "t_seq"("seq_num"),
   --FOREIGN KEY("jsp_numphase") REFERENCES "t_phase"("pha_num")
);

-- gestion de la relation les phases et les périodes
DROP TABLE IF EXISTS j_phase_per;
CREATE TABLE j_phase_per(
   "jpp_id" INTEGER PRIMARY KEY,
   "jpp_numphase" INTEGER,
   "jpp_numper" INTEGER,
   "jpp_ordre" INTEGER
   --FOREIGN KEY("jpp_numper") REFERENCES "t_periode"("per_num"),
   --FOREIGN KEY("jpp_numphase") REFERENCES "t_phase"("pha_num")
);

-- gestion de la relation entre les minutes de terrain et les US, faits et isolats et les sondages et tranchées
DROP TABLE IF EXISTS j_rel_minute;
CREATE TABLE j_rel_minute(
   "jrm_id" INTEGER PRIMARY KEY,
   "jrm_numinute" INTEGER,
   "jrm_numsd" INTEGER,
   "jrm_numtr" INTEGER,
   "jrm_numfait" INTEGER,
   "jrm_numus" INTEGER,
   "jrm_numiso" INTEGER
   --FOREIGN KEY("jrm_numinute") REFERENCES "t_minute"("min_num"),
   --FOREIGN KEY("jrm_numsd") REFERENCES "t_sondage"("sd_num"),
   --FOREIGN KEY("jrm_numtr") REFERENCES "t_tranchee"("tr_num"),
   --FOREIGN KEY("jrm_numfait") REFERENCES "t_fait"("f_numfait"),
   --FOREIGN KEY("jrm_numus") REFERENCES "t_us"("u_numus"),
   --FOREIGN KEY("jrm_numiso") REFERENCES "t_mobilier"("mob_numiso"),
);

--gestion de la relation entre les photos et les US, faits et isolats et les sondages et tranchées
DROP TABLE IF EXISTS j_rel_photo;
CREATE TABLE j_rel_photo(
   "jrp_id" INTEGER PRIMARY KEY,
   "jrp_numphoto" INTEGER,
   "jrp_numsd" INTEGER,
   "jrp_numtr" INTEGER,
   "jrp_numfait" INTEGER,
   "jrp_numus" INTEGER,
   "jrp_numiso" INTEGER
   --FOREIGN KEY("jrp_numphoto") REFERENCES "t_photo"("ph_id"),
   --FOREIGN KEY("jrp_numsd") REFERENCES "t_sondage"("sd_num"),
   --FOREIGN KEY("jrp_numtr") REFERENCES "t_tranchee"("tr_num"),
   --FOREIGN KEY("jrp_numfait") REFERENCES "t_fait"("f_numfait"),
   --FOREIGN KEY("jrp_numus") REFERENCES "t_us"("u_numus"),
   --FOREIGN KEY("jrp_numiso") REFERENCES "t_mobilier"("mob_numiso")
);

/*
DROP TABLE IF EXISTS t_composante;
CREATE TABLE t_composante(
   "com_id" INTEGER PRIMARY KEY,
   "com_numouvert" INTEGER,
   "com_numplog" INTEGER,
   "com_numfait" INTEGER,
   "com_numus" INTEGER,
   "com_numiso" INTEGER,
   "com_typcompo" TEXT,
   "com_note" TEXT
   --FOREIGN KEY("com_numplog") REFERENCES "plog"("id_plog"),
   --FOREIGN KEY("com_numouvert") REFERENCES "t_sondage"("sd_num"),
   --FOREIGN KEY("com_numfait") REFERENCES "t_fait"("f_numfait"),
   --FOREIGN KEY("com_numus") REFERENCES "t_us"("u_numus"),
   --FOREIGN KEY("com_numiso") REFERENCES "t_mobilier"("mob_numiso") --> nécessite que chaque mob ait un numero iso. Peut être id_mob
);

DROP TABLE IF EXISTS t_matiere;
CREATE TABLE t_matiere(
   "mat_id" INTEGER PRIMARY KEY,
   "mat_id_compo" INTEGER,
   "matiere" TEXT
   --FOREIGN KEY("mat_id_compo") REFERENCES "composante"("com_id")
);

*/

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
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (59,NULL,'matiere','alios',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (60,NULL,'matiere','alliage cuivreux',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (61,NULL,'matiere','argent',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (62,NULL,'matiere','fer',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (63,NULL,'matiere','or',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (64,NULL,'matiere','étain',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (65,NULL,'matiere','ambre',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (66,NULL,'matiere','argent',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (67,NULL,'matiere','bois',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (68,NULL,'matiere','charbon de bois',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (69,NULL,'matiere','cheveux',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (70,NULL,'matiere','cire',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (71,NULL,'matiere','coprolithe',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (72,NULL,'matiere','coquille',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (73,NULL,'matiere','corail',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (74,NULL,'matiere','corne',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (75,NULL,'matiere','cuir',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (76,NULL,'matiere','écaille',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (77,NULL,'matiere','écorce',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (78,NULL,'matiere','enduit peint',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (79,NULL,'matiere','os animal',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (80,NULL,'matiere','fossile',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (81,NULL,'matiere','fourrure',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (82,NULL,'matiere','galalithe',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (83,NULL,'matiere','insecte',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (84,NULL,'matiere','ivoire',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (85,NULL,'matiere','jais',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (86,NULL,'matiere','lichen',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (87,NULL,'matiere','lignite',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (88,NULL,'matiere','métal indifférencié',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (89,NULL,'matiere','mortier',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (90,NULL,'matiere','nacre',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (91,NULL,'matiere','os humain',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (92,NULL,'matiere','papier',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (93,NULL,'matiere','parchemin',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (94,NULL,'matiere','pierre indifférencié',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (95,NULL,'matiere','peau',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (96,NULL,'matiere','perle fine',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (97,NULL,'matiere','pierre indifférenciée fine',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (98,NULL,'matiere','pisé',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (99,NULL,'matiere','plâtre',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (100,NULL,'matiere','plomb',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (101,NULL,'matiere','plomb ou étain',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (102,NULL,'matiere','scorie',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (103,NULL,'matiere','stuc',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (104,NULL,'matiere','terre crue',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (105,NULL,'matiere','terre cuite',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (106,NULL,'matiere','textile',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (107,NULL,'matiere','torchis',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (108,NULL,'matiere','vannerie',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (109,NULL,'matiere','végétal',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (110,NULL,'matiere','verre',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (111,NULL,'matiere','zinc',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (112,NULL,'matiere','indéterminée',NULL,NULL,NULL);
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
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (139,'t_us','type_us','couche physique',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (140,'t_us','type_us','négative',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (141,'t_us','type_us','altération',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (142,'t_us','valeur','clair',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (143,'t_us','valeur','moyen',NULL,NULL,NULL);
INSERT INTO "thesaurus_badass" ("id_thes","tabl_thes","field_thes","val_thes","def_thes","cat_thes","comment") VALUES (144,'t_us','valeur','foncé',NULL,NULL,NULL);

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
WHERE NEW.numpoly = f_numfait ; /*à chaque fois que la valeur du champ "num_fait" de la table t_fait est égale à la valeur du champ "numpoly" de la copie temporaire NEW de la table t_poly*/
END ; /*fin de l'action et fin du trigger*/

-- qui met à jour la table t_us après CREATION d'une entité dans poly
CREATE TRIGGER trgai_poly_maj_t_us
    AFTER INSERT
    ON poly
FOR EACH ROW
WHEN (NEW.typoly = 'us')
   BEGIN
   UPDATE t_us
   SET geometry = NEW.geometry
   WHERE NEW.numpoly = u_numus ;
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
WHERE NEW.numpoly = f_numfait ;
END ;

-- qui met à jour la table t_us après MODIFICATION d'une entité dans poly
CREATE TRIGGER trgau_poly_maj_t_us
   AFTER UPDATE
   ON poly
FOR EACH ROW
WHEN (NEW.typoly = 'us')
BEGIN
UPDATE t_us
SET geometry = NEW.geometry
WHERE NEW.numpoly = u_numus ;
END ;

-- AFTER DELETE
-- qui supprimer une entité de la table t_fait après la SUPPRESSION de l'entité équivalent dans poly
CREATE TRIGGER trgad_poly_maj_t_fait /*déclaration de création d'un nouveau trigger qui a pour nom...*/
   AFTER DELETE /*qui sera exécuté après la suppression d'une entité*/
   ON poly /*sur la table*/
FOR EACH ROW /*commande obligatoire : pour tous les enregistrement*/
WHEN (OLD.typoly = 'fait')/*cette condition permet de restreindre les enregistrements concernés aux seuls 'fait' ; OLD correspond à une copie temporaire des anciens éléments de la table t_poly effectuée lors de l'exécution du trigger*/
BEGIN /* debut de l'action déclenchée*/
DELETE FROM t_fait /*avec une suppression effectué dans la table t_fait*/
WHERE OLD.numpoly = f_numfait ; /*à chaque fois que la valeur du champ "num_fait" de la table t_fait est égale à la valeur du champ "numpoly" de la copie temporaire OLD de la table t_poly*/
END ; /*fin de l'action et fin du trigger*/

-- qui supprimer une entité de la table t_us après la SUPPRESSION de l'entité équivalent dans poly
CREATE TRIGGER trgad_poly_maj_t_us
   AFTER DELETE
   ON poly
FOR EACH ROW
WHEN (OLD.typoly = 'us')
BEGIN
DELETE FROM t_us
WHERE OLD.numpoly = u_numus ;
END ;

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
WHERE NEW.f_numfait = numpoly AND typoly = 'fait' ; /*pour les entités dont la valeur du champ "numpoly" de la table t_poly est égale à la valeur du champ "num_fait" de la copie temporaire NEW de la table t_fait et pour lesquels la valeur 'fait' est renseignée dans le champ "typoly"*/
END ; /*fin de l'action et fin du trigger*/

-- AFTER DELETE
CREATE TRIGGER trgad_t_fait_maj_poly /*déclaration de création d'un nouveau trigger qui a pour nom...*/
   AFTER DELETE /*qui sera exécuté après la suppression d'une entité*/
   ON t_fait /*sur la table*/
FOR EACH ROW /*commande obligatoire : pour tous les enregistrement*/
BEGIN /* debut de l'action déclenchée*/
DELETE FROM poly /*avec une suppression effectué dans la table t_poly*/
WHERE OLD.f_numfait = numpoly AND typoly = 'fait' ; /*des entités dont la valeur du champ "numpoly" de la table t_poly est égale à la valeur du champ "num_fait" de la copie temporaire NEW de la table t_fait et pour lesquels la valeur 'fait' est renseignée dans le champ "typoly"*/
END ; /*fin de l'action et fin du trigger*/

-- les triggers à mettre en place pour la table t_us (qui doivent mettre à jour la table poly)
-- AFTER UPDATE
CREATE TRIGGER trgau_t_us_maj_poly
   AFTER UPDATE
   ON t_us
FOR EACH ROW
BEGIN
UPDATE poly
SET geometry = NEW.geometry
WHERE NEW.u_numus = numpoly AND typoly = 'us' ;
END ;

-- AFTER DELETE
CREATE TRIGGER trgad_t_us_maj_poly
   AFTER DELETE
   ON t_us
FOR EACH ROW
BEGIN
DELETE FROM poly
WHERE OLD.u_numus = numpoly AND typoly = 'us' ;
END ;


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
WHERE NEW.numouvert = sd_num ;
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
   WHERE NEW.numouvert = tr_num ;
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
WHERE NEW.numouvert = sd_num ;
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
WHERE NEW.numouvert = tr_num ;
END ;

-- AFTER DELETE
-- qui supprimer une entité de la table t_sondage après la SUPPRESSION de l'entité équivalent dans ouverture
CREATE TRIGGER trgad_ouverture_maj_t_sondage
   AFTER DELETE
   ON ouverture
FOR EACH ROW
WHEN (OLD.typouvert = 'sondage')
BEGIN
DELETE FROM t_sondage
WHERE OLD.numouvert = sd_num ;
END ;

-- qui supprimer une entité de la table t_tranchee après la SUPPRESSION de l'entité équivalent dans ouverture
CREATE TRIGGER trgad_ouverture_maj_t_tranchee
   AFTER DELETE
   ON ouverture
FOR EACH ROW
WHEN (OLD.typouvert = 'tranchée')
BEGIN
DELETE FROM t_tranchee
WHERE OLD.numouvert = tr_num ;
END ;

-- les triggers à mettre en place pour la table t_sondage (qui doivent mettre à jour la table ouverture)
-- AFTER UPDATE
CREATE TRIGGER trgau_t_sondage_maj_ouverture
   AFTER UPDATE
   ON t_sondage
FOR EACH ROW
BEGIN
UPDATE ouverture
SET geometry = NEW.geometry
WHERE NEW.sd_num = numouvert AND typouvert = 'sondage' ;
END ;

-- AFTER DELETE
CREATE TRIGGER trgad_t_sondage_maj_ouverture
   AFTER DELETE
   ON t_sondage
FOR EACH ROW
BEGIN
DELETE FROM ouverture
WHERE OLD.sd_num = numouvert AND typouvert = 'sondage' ;
END ;

-- les triggers à mettre en place pour la table t_tranchee (qui doivent mettre à jour la table ouverture)
-- AFTER UPDATE
CREATE TRIGGER trgau_t_tranchee_maj_ouverture
   AFTER UPDATE
   ON t_tranchee
FOR EACH ROW
BEGIN
UPDATE ouverture
SET geometry = NEW.geometry
WHERE NEW.tr_num = numouvert AND typouvert = 'tranchée' ;
END ;

-- AFTER DELETE
CREATE TRIGGER trgad_t_tranchee_maj_ouverture
   AFTER DELETE
   ON t_tranchee
FOR EACH ROW
BEGIN
DELETE FROM ouverture
WHERE OLD.tr_num = numouvert AND typouvert = 'tranchée' ;
END ;

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
WHERE NEW.numaxe = a_numaxe ;
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
WHERE NEW.numaxe = a_numaxe ;
END ;

-- AFTER DELETE
-- qui supprimer une entité de la table t_axe après la SUPPRESSION de l'entité équivalente dans axe
CREATE TRIGGER trgad_axe_maj_t_axe
   AFTER DELETE
   ON axe
FOR EACH ROW
BEGIN
DELETE FROM t_axe
WHERE OLD.numaxe = a_numaxe ;
END ;

-- les triggers à mettre en place pour la table t_axe (qui doivent mettre à jour la table axe)
-- AFTER UPDATE
CREATE TRIGGER trgau_t_axe_maj_axe
   AFTER UPDATE
   ON t_axe
FOR EACH ROW
BEGIN
UPDATE axe
SET geometry = NEW.geometry
WHERE NEW.a_numaxe = numaxe ;
END ;

-- AFTER DELETE
CREATE TRIGGER trgad_t_axe_maj_axe
   AFTER DELETE
   ON t_axe
FOR EACH ROW
BEGIN
DELETE FROM axe
WHERE OLD.a_numaxe = numaxe ;
END ;


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
WHERE NEW.numpoint = mob_numpoint ;
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
WHERE NEW.numpoint = mob_numpoint ;
END ;

-- AFTER DELETE
-- qui supprimer une entité de la table t_mobilier après la SUPPRESSION de l'entité équivalente dans point
CREATE TRIGGER trgad_point_maj_t_mobilier
   AFTER DELETE
   ON point
FOR EACH ROW
BEGIN
DELETE FROM t_mobilier
WHERE OLD.numpoint = mob_numpoint ;
END ;

-- les triggers à mettre en place pour la table t_point (qui doivent mettre à jour la table point)
-- AFTER UPDATE
CREATE TRIGGER trgau_t_mobilier_maj_point
   AFTER UPDATE
   ON t_mobilier
FOR EACH ROW
BEGIN
UPDATE point
SET geometry = NEW.geometry
WHERE NEW.mob_numpoint = numpoint ;
END ;

-- AFTER DELETE
CREATE TRIGGER trgad_t_mobilier_maj_point
   AFTER DELETE
   ON t_mobilier
FOR EACH ROW
BEGIN
DELETE FROM point
WHERE OLD.mob_numpoint = numpoint ;
END ;

-- les triggers à mettre en place pour la table plog (qui doivent mettre à jour la tables t_log)

-- AFTER INSERT
-- qui met à jour la table t_log après CREATION d'une entité dans plog
CREATE TRIGGER trgai_plog_maj_t_log
    AFTER INSERT
    ON plog
FOR EACH ROW
BEGIN
UPDATE t_log
SET geometry = NEW.geometry
WHERE NEW.numplog = numlog ;
END ;

-- AFTER UPDATE
-- qui met à jour la table t_log après MODIFICATION d'une entité dans plog
CREATE TRIGGER trgau_plog_maj_t_log
   AFTER UPDATE
   ON plog
FOR EACH ROW
BEGIN
UPDATE t_log
SET geometry = NEW.geometry
WHERE NEW.numplog = numlog ;
END ;

-- AFTER DELETE
-- qui supprimer une entité de la table t_log après la SUPPRESSION de l'entité équivalente dans plog
CREATE TRIGGER trgad_plog_maj_t_log
   AFTER DELETE
   ON plog
FOR EACH ROW
BEGIN
DELETE FROM t_log
WHERE OLD.numplog = numlog ;
END ;

-- les triggers à mettre en place pour la table t_log (qui doivent mettre à jour la table plog)
-- AFTER UPDATE
CREATE TRIGGER trgau_t_log_maj_plog
   AFTER UPDATE
   ON t_log
FOR EACH ROW
BEGIN
UPDATE plog
SET geometry = NEW.geometry
WHERE NEW.numlog = numplog ;
END ;

-- AFTER DELETE
CREATE TRIGGER trgad_t_log_maj_plog
   AFTER DELETE
   ON t_log
FOR EACH ROW
BEGIN
DELETE FROM plog
WHERE OLD.numlog = numplog ;
END ;
