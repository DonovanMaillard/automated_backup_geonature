#!/bin/bash
# Import settings
scripts_dir=$(dirname "$0")
source $scripts_dir/settings_restore.ini

# Vérifier que GeoNature, TaxHub et UsersHub sont bien installés et dans les mêmes versions que celle du dernier Full Backup
- si GeoNature n''est pas dans la bonne version, exit
- Si UsersHub n''est pas dans la bonne version, exit
- Si taxhub n''est pas dans la bonne version, exit

# Vérifier si le propriétaire de la BDD et son mot de passe sont bien les mêmes dans la nouvelle réinstallation.
- Si oui, poursuite
- Si non, NOTICE + Créer l''utilisateur qui correspond au backup

## DROP existing database and CREATE a new one
- Si la BDD exist, on supprime les connexions courantes et on la drop
- Si non, on la crée avec OWNER mon utilisateur

## Réimporter totalement la BDD du dernier FULL Backup
psql \i mon fichier

## Si un backup daily a été fourni, supprimer les schémas hors référentiels de la base restaurée, puis réimporter le fichier daily
## Attention, en l'état, le script ne sauvegarde les médias (occtax, monitoring, taxhub etc) que dans les full backup.
## TODO : sauver tous les médias du jour du backup. Engendrera un soucis malgré tout dans le cas des backups non exportés...

psql DROP SCHEMA xxx CASCADE;
psql \i mon daily

La base venant d''être restaurée, démontée puis restaurée -> launch DB Maintenance Full même si disabled pour les backups

## BDD restaurée
