#!/bin/bash
# Import settings
scripts_dir=$(dirname "$0")
source $scripts_dir/settings_backup.ini

#local_storage_duration=$1

###############################
### REMOVE TOO OLD ARCHIVES ###
###############################
if [ $local_storage_duration = "0" ];
  then 
  echo "Suppression de la copie locale du backup"
  sudo rm $backups_path/*.tar.gz
else
  echo "Suppression des copies locales de plus de $local_storage_duration jours"
  find $backups_path -name "*.tar.gz" -mtime +$local_storage_duration -exec rm -f {} \;
fi


###########################
### REMOVE TOO OLD LOGS ###
###########################
if [ $log_storage_duration = "0" ];
  then 
  echo "Suppression des logs"
  sudo rm $log_path/*.log
else
  echo "Suppression des fichiers de logs de plus de $log_storage_duration jours"
  find $log_path -name "*.log" -mtime +$log_storage_duration -exec rm -f {} \;
fi

