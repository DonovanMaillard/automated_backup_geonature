#!/bin/bash

# Get settings_backup.ini in the same folder than scripts
# Allow to launch automated backup from anywhere on server
scripts_dir=$(dirname "$0")
source $scripts_dir/settings_backup.ini


#######################
### PREPARE LOG DIR ###
#######################
if [ ! -d "$log_path" ]; 
then
  mkdir -p $log_path
fi

Log_file=$log_path/`date +%Y-%m-%d-%H:%M`-Automated_backup.log
echo "INFO : Les logs de la sauvegarde seront stockés dans le fichier $Log_file..."

# Create log file
echo "==========================" &> $Log_file
echo "Backup du `date +%Y-%m-%d-%H:%M`" &>> $Log_file
echo "==========================" &>> $Log_file

#######################
### PREPARE ARCHIVE ###
#######################


# Check configuration consistency
if [ $local_storage_duration = "0" ] && [ $export_backup = false ];
then
  echo "Attention, votre configuration indique que vous ne souhaitez pas stocker localement les sauvegardes ni les exporter... Arrêt de la sauvegarde" &>> $Log_file
  exit 1
fi


month=`date +%m`
day=`date +%d`

# Depending on date and user request, define backup type
if [ -n "$1" ]; # archive type defined by user
then 
  if [ "$1" = "Full" ];
    then archive_type="Full"
  elif [ "$1" = "Daily" ];
    then archive_type="Daily"
  else echo "Le type d'archive doit être 'Full' ou 'Daily'... arrêt du script" &>> $Log_file
  exit 1
  fi
else # archive type not defined by user
  if [ $day = $full_backup_day ];
    then archive_type="Full"
  else archive_type="Daily"
  fi
fi

# Depending on date and user request, define backup name
if [ -n "$2" ]; # archive name defined by user
then 
  archive_name=$2
else # archive name not defined by user
  if [ $archive_type = "Full" ];
    then archive_name="Full_backup_month_$month"
  else archive_name="Daily_backup_$day"
  fi
fi


echo "" &>> $Log_file
echo "Type d'archive : $archive_type" &>> $Log_file
echo "Nom de l'archive : $archive_name.tar.gz" &>> $Log_file
echo "" &>> $Log_file


###################
### BACKUP TASK ###
###################

# Launch backup tasks
echo "" &>> $Log_file
echo "=======================" &>> $Log_file
echo "LAUNCH : 01_Make_backup" &>> $Log_file
echo "=======================" &>> $Log_file
echo "" &>> $Log_file

$scripts_dir/01_Make_backup.sh $archive_type $archive_name &>> $Log_file


######################
### BACKUP STORAGE ###
######################
file_to_export=$archive_name.tar.gz

# Depending on settings, export backup archive
if [ $export_backup = true ]; 
then
  echo "" &>> $Log_file
  echo "=======================" &>> $Log_file
  echo "LAUNCH : 02_Export_file" &>> $Log_file
  echo "=======================" &>> $Log_file
  echo "" &>> $Log_file
  $scripts_dir/02_Export_file.sh $file_to_export &>> $Log_file
fi

# Depending on settings, remove local copy
echo "" &>> $Log_file
echo "========================================" &>> $Log_file
echo "LAUNCH : 03_Manage_local_backups_storage" &>> $Log_file
echo "========================================" &>> $Log_file
echo "" &>> $Log_file
$scripts_dir/03_Manage_local_backups_storage.sh $local_storage_duration &>> $Log_file


########################
### MAINTENANCE TASK ###
########################
maintenance_type=$archive_type

if [ $enable_db_maintenance = true ];
then
  echo "" &>> $Log_file
  echo "================================" &>> $Log_file
  echo "LAUNCH : 04_Database_Maintenance" &>> $Log_file
  echo "================================" &>> $Log_file
  echo "" &>> $Log_file
  $scripts_dir/04_Database_Maintenance.sh $maintenance_type &>> $Log_file
fi

# End of script
echo "" &>> $Log_file
echo "=================================" &>> $Log_file
echo "=== La sauvegarde est achevée ===" &>> $Log_file
echo "=================================" &>> $Log_file
