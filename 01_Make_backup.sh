#!/bin/bash
. /etc/os-release

# Import settings
scripts_dir=$(dirname "$0")
source $scripts_dir/settings_backup.ini

archive_type=$1
archive_name=$2

########################
### CREATE DIRECTORY ###
########################

# Create archive path if not exists
if [ -d "$backups_path" ]; 
then
  echo "Le répertoire de stockage local des sauvegardes existe déjà, poursuite du traitement..."
else
  echo "Création du répertoire de stockage local des sauvegardes"
  mkdir -p $backups_path
fi

# Remove archive directory if already exists
if [ -d "$backups_path/$archive_name" ]; 
then
  echo "Une archive $archive_name existe déjà, écrasement en cours..."
  rm -r $backups_path/$archive_name
fi

# Create backup directory
echo "Création de l'archive $archive_name"
mkdir $backups_path/$archive_name


###################
### ENVIRONMENT ###
###################

if [ $archive_type = "Full" ]; 
then # Full backup
  echo ""
  echo "Sauvegarde de l'environnement..."
  echo "--------------------------------"
  echo "Configurations apache..."
  mkdir -p $backups_path/$archive_name/environment/configurations_apache
  sudo cp /etc/apache2/sites-available/geonature.conf $backups_path/$archive_name/environment/configurations_apache
  sudo cp /etc/apache2/sites-available/geonature_maintenance.conf $backups_path/$archive_name/environment/configurations_apache
  sudo cp /etc/apache2/sites-available/taxhub.conf $backups_path/$archive_name/environment/configurations_apache
  sudo cp /etc/apache2/sites-available/usershub.conf $backups_path/$archive_name/environment/configurations_apache

  echo "Stockage des informations serveur dans environment_info.log..."
  echo "Informations sur les configurations serveur :" &> $backups_path/$archive_name/environment/environment_info.log
  echo "OS_NAME : $ID" &>> $backups_path/$archive_name/environment/environment_info.log
  echo "OS_VERSION : $VERSION_ID" &>> $backups_path/$archive_name/environment/environment_info.log

  echo "PostgreSQL"
  mkdir -p $backups_path/$archive_name/environment/postgresql
  echo "PGSQL_VERSION : $(sudo psql -V)" &>> $backups_path/$archive_name/environment/environment_info.log
  sudo cp /etc/postgresql/$pg_version/main/pg_hba.conf $backups_path/$archive_name/environment/postgresql
  sudo cp /etc/postgresql/$pg_version/main/postgresql.conf $backups_path/$archive_name/environment/postgresql
fi


################
### DATABASE ###
################

# Database backup
if [ $archive_type = "Full" ]; 
then # Full backup
  echo ""
  echo "Sauvegarde complète de la base de données $db_name..."
  pg_dump -h localhost -U $pg_superuser $db_name -f $backups_path/$archive_name/`date +%Y-%m-%d-%H:%M`-$db_name-full_dump.sql
else # Daily backup
  echo ""
  echo "Sauvegarde partielle de la base de données $db_name..."
  pg_dump -h localhost -U $pg_superuser $db_name -N ref_geo -N taxonomie -N ref_nomenclatures -N ref_habitats -f $backups_path/$archive_name/`date +%Y-%m-%d-%H:%M`-$db_name-daily_dump.sql
fi


####################
### APPLICATIONS ###
####################

cd /home/$linux_user

##
## Daily Backup
##

## GeoNature
echo ""
echo "Sauvegarde des fichiers applicatifs essentiels de GeoNature"
echo "-----------------------------------------------------------"
mkdir $backups_path/$archive_name/geonature/

echo "Configuration..."
mkdir $backups_path/$archive_name/geonature/config
cp geonature/config/settings.ini $backups_path/$archive_name/geonature/config
cp geonature/config/geonature_config.toml $backups_path/$archive_name/geonature/config

echo "Backend..."
mkdir $backups_path/$archive_name/geonature/backend
# static directory
mkdir $backups_path/$archive_name/geonature/backend/static
cp -r geonature/backend/static/mobile $backups_path/$archive_name/geonature/static
cp -r geonature/backend/static/exports $backups_path/$archive_name/geonature/static

echo "Logs et numéro de version..."
mkdir $backups_path/$archive_name/geonature/var
cp -r geonature/var/log $backups_path/$archive_name/geonature/var
cp geonature/VERSION $backups_path/$archive_name/geonature

## TaxHub
echo ""
echo "Sauvegarde des fichiers applicatifs essentiels de TaxHub"
echo "--------------------------------------------------------"
mkdir $backups_path/$archive_name/taxhub

echo "Logs et numéro de version..."
cp taxhub/VERSION $backups_path/$archive_name/taxhub
mkdir $backups_path/$archive_name/taxhub/var
cp -r taxhub/var/log $backups_path/$archive_name/taxhub/var

echo "Configuration..."
cp taxhub/settings.ini $backups_path/$archive_name/taxhub
cp taxhub/config.py $backups_path/$archive_name/taxhub
mkdir -p $backups_path/$archive_name/taxhub/static/app
cp taxhub/static/app/constant.js $backups_path/$archive_name/taxhub/static/app

## UsersHub
echo ""
echo "Sauvegarde des fichiers applicatifs de UsersHub"
echo "-----------------------------------------------"
mkdir $backups_path/$archive_name/usershub

echo "Logs et numéros de version..."
cp usershub/VERSION $backups_path/$archive_name/usershub
mkdir $backups_path/$archive_name/usershub/var
cp -r usershub/var/log $backups_path/$archive_name/usershub/var

echo "Configuration..."
mkdir $backups_path/$archive_name/usershub/config
cp usershub/config/config.py $backups_path/$archive_name/usershub/config
cp usershub/config/settings.ini $backups_path/$archive_name/usershub/config


##
## Complements for Full Backup 
##

if [ $archive_type = "Full" ];
then
  echo ""
  echo "Sauvegarde des données complémentaires pour la sauvegarde complète ..."
  echo "----------------------------------------------------------------------"

  ## GeoNature
  echo "GeoNature"
  echo "---------"
  echo "Frontend..."
  mkdir $backups_path/$archive_name/geonature/frontend

  # src directory
  mkdir $backups_path/$archive_name/geonature/frontend/src
  cp -r geonature/frontend/src/custom $backups_path/$archive_name/geonature/frontend/src
  cp -r geonature/frontend/src/external_assets $backups_path/$archive_name/geonature/frontend/src
  cp geonature/frontend/src/favicon.ico  $backups_path/$archive_name/geonature/frontend/src

  # assets directory
  mkdir $backups_path/$archive_name/geonature/frontend/assets
  cp geonature/frontend/src/assets/custom.css $backups_path/$archive_name/geonature/frontend/assets
  
  echo ""
  echo "Backend..."
  cp -r geonature/backend/static/medias $backups_path/$archive_name/geonature/static
  cp -r geonature/backend/static/shapefiles $backups_path/$archive_name/geonature/static
  cp -r geonature/backend/static/images $backups_path/$archive_name/geonature/static

  echo ""
  echo "External_modules..."
  cp -r geonature/external_modules $backups_path/$archive_name/geonature

  echo ""
  echo "Configurations des modules Contrib..."
  mkdir $backups_path/$archive_name/geonature/contrib

  # Occtax module
  echo "Occtax..."
  mkdir -p $backups_path/$archive_name/geonature/contrib/occtax/config
  cp geonature/contrib/occtax/config/conf_gn_module.toml $backups_path/$archive_name/geonature/contrib/occtax/config
  cp geonature/contrib/occtax/config/conf_schema_toml.py $backups_path/$archive_name/geonature/contrib/occtax/config
  # OccHab module
  echo "OccHab..."
  mkdir -p $backups_path/$archive_name/geonature/contrib/gn_module_occhab/config
  cp geonature/contrib/gn_module_occhab/config/conf_gn_module.toml $backups_path/$archive_name/geonature/contrib/gn_module_occhab/config
  cp geonature/contrib/gn_module_occhab/config/conf_schema_toml.py $backups_path/$archive_name/geonature/contrib/gn_module_occhab/config
  # validation module
  echo "Validation..."
  mkdir -p $backups_path/$archive_name/geonature/contrib/gn_module_validation/config
  cp geonature/contrib/gn_module_validation/config/conf_gn_module.toml $backups_path/$archive_name/geonature/contrib/gn_module_validation/config
  cp geonature/contrib/gn_module_validation/config/conf_schema_toml.py $backups_path/$archive_name/geonature/contrib/gn_module_validation/config

  ## gn_modules
  echo ""
  echo "Sauvegarde des modules externes..."
  mkdir $backups_path/$archive_name/gn_modules
  cp -r gn_module_* $backups_path/$archive_name/gn_modules

  ## TaxHub
  echo ""
  echo "TaxHub"
  echo "------"
  echo "Médias..."
  cp -r taxhub/static/medias $backups_path/$archive_name/taxhub/static

fi ## End of Full backup complements

###########################
### ARCHIVE COMPRESSION ###
###########################
# Compress backup directory into tar.gz archive
echo "Compression de la sauvegarde dans une archive tar.gz..."
tar zcvf $backups_path/$archive_name.tar.gz -C /home/$linux_user $backups_path/$archive_name

# Remove uncompressed directory
sudo rm -r $backups_path/$archive_name
