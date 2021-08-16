#!/bin/bash
# Import settings
scripts_dir=$(dirname "$0")
source $scripts_dir/settings_backup.ini

file_to_export=$1

################################
### EXPORT FILE OR DIRECTORY ###
################################

# Export backup archive to remote host
echo "Export de l'archive vers $distant_host..."
sshpass -p $distant_password scp -r -P $distant_port -o StrictHostKeyChecking=no $backups_path/$file_to_export $distant_user@$distant_host:$distant_storage_path

