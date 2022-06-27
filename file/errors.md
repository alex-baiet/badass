# Tous les problèmes du plugin QGIS "BADASS"

## Problèmes chargement fichier orginal

./noisy_badass_lignes.shp
./temp.gpkg|layername=t_age_old
./temp.gpkg|layername=t_cont_sep_old
./temp.gpkg|layername=t_mesure_old
./temp.gpkg|layername=t_patho_old
./temp.gpkg|layername=t_sexe_old
./temp.gpkg|layername=t_squelette_old

Font "MS Shell Dlg 2" et "Arial Narrow" introuvable sur le système

## Problèmes chargement copie (avec Of The Dead)

./badass_otd_v2.sqlite|layername=erreur_saisie_strati
./badass_otd_v2.sqlite|layername=ExportRelations
./badass_otd_v2.sqlite|layername=ExportSynchros
./badass_otd_v2.sqlite|layername=ExportUS
./badass_otd_v2.sqlite|layername=j_rel_photogram
./badass_otd_v2.sqlite|layername=model_anthropo
./badass_otd_v2.sqlite|layername=vue_j_rel_us_inverse
./badass_otd_v2.sqlite|layername=vue_recap_fait_tranchee
./badass_otd_v2.sqlite|layername=vue_recap_minute
./badass_otd_v2.sqlite|layername=vue_recap_photo
./badass_otd_v2.sqlite|layername=vue_recap_relationus
./badass_otd_v2.sqlite|layername=vue_recap_relationus_deduite
./badass_otd_v2.sqlite|layername=vue_recap_us_fait
./noisy_badass_lignes.shp
./temp.gpkg|layername=t_age_old
./temp.gpkg|layername=t_cont_sep_old
./temp.gpkg|layername=t_mesure_old
./temp.gpkg|layername=t_patho_old
./temp.gpkg|layername=t_sexe_old
./temp.gpkg|layername=t_squelette_old
dbname='./badass_otd_v2.sqlite' table="mannequin" (geometry)
dbname='./badass_otd_v2.sqlite' table="t_cont_sep" (geometry)
dbname='./badass_otd_v2.sqlite' table="t_obs_sep"
dbname='./badass_otd_v2.sqlite' table="t_squelette" (geometry)

## Composants en plus/moins sur la copie

### Tables

- j_rel_photogram
- log
- mannequin
- model_anthropo
+ man_os
+ man_part_ana
+ man_squel
+ plog
+ t_amenag_sep
+ t_mob_sep
- t_obs_sep
+ t_obs_sep_prim
+ t_obs_sep_sec
+ t_part_anatomiq
- t_photogram
- t_prelevement
+ t_us_sep

### Views

- ExportRelation
- ExportSynchros
- ExportUS
- erreur_saisie_strati
- vue_j_rel_us_inverse
- vue_recap_fait_tranchee
- vue_recap_minute
- vue_recap_photo
- vue_recap_relationus
- vue_recap_relationus_deduite
- vue_recap_us_fait

### Triggers

- ggi_log_geometry
- ggi_mannequin_geometry
+ ggi_man_os_geometry
+ ggi_man_part_ana_geometry
+ ggi_man_squel_geometry
+ ggi_plog_geometry
+ ggi_t_amenag_sep_geometry
- ggi_t_const_sep_geometry
- ggi_t_photogram_geometry
- ggi_t_prelevement_geometry
+ ggi_t_part_anatomiq_geometry
- ggi_t_squelette_geometry

idem pour `ggu_*`, `tmd_*`, `tmi_*`, `tmu_*` 

- tgai_*
- tgau_*

- trgad_j_rel_us
+ trgad_*

... Et plus de modif pour les triggers
