#!/bin/bash
# Import settings
scripts_dir=$(dirname "$0")
source $scripts_dir/settings_backup.ini

maintenance_type=$1

#########################
### MAINTENANCE TASKS ###
#########################

if [ $maintenance_type = "Full" ];
then
  ##
  ## Full maintenance
  ## By default, Full maintenance is launched at the same time as full backups
  ## Vacuum full on all database tables + Reindex
  ##

  echo "Launching full maintenance"
  echo "=========================="
  echo "Enabling maintenance mode for GeoNature..."
  cd /etc/apache2/sites-available
  sudo a2ensite geonature_maintenance.conf
  sudo a2dissite geonature.conf
  sudo apachectl restart

  echo "Vacuum : cleaning all tables..."
  sudo psql -h localhost -U $pg_superuser -d $db_name -c "VACUUM FULL;"

  echo "Reindex database..."
  sudo psql -h localhost -U $pg_superuser -d $db_name -c "REINDEX DATABASE flaviabase;"

  echo "Reactivating GeoNature..."
  sudo a2dissite geonature_maintenance.conf
  sudo a2ensite geonature.conf
  sudo apachectl restart
  cd /home/$linux_user
else 
  ##
  ## Daily maintenance
  ## Only vaccum analyze on all database
  ##

  echo "Launching daily database maintenance..."
  echo "Vacuum : cleaning all tables..."
  sudo psql -h localhost -U $pg_superuser -d $db_name -c "VACUUM ANALYZE;"
fi

