# To do docs

Ce script permet d'automatiser la sauvegarde d'une instance GeoNature selon le
modèle suivant :
- Sauvegarde complète de toute la base de données et fichiers applicatifs
 personnalisés (configurations geonature, modules, apache, numéros de versions,
 répertoires custom, médias etc) le 1er de chaque mois
- Sauvegarde simplifiée de la base de données (exclu les référentiels) et
certains fichiers applicatifs (configurations geonature, modules, numéros de
versions) tous les autres jours du mois
Le script est conçu de manière à conserver sur la machine distante :
- Les sauvegardes quotidiennes durant environ un mois (chaque archive écrase celle du mois précédent)
- Les sauvegardes complètes durant environ 1 an (chaque sauvegarde mensuelle écrase la mensuelle de l'année précédente)
- Chaque 1er janvier une sauvegarde complète est conservée sans limite de durée

Fonctionnement :
- Paramétrer le backup via le fichier settings_backup.ini
- Le script 00_Environnement_backup sauvegarde les infos sur l'environnement de
l'instance pour faciliter la restauration en cas de besoin
- Le script 01_Daily_backup est joué quotidiennement pour sauvegarder les éléments les plus dynamiques de GeoNature (configurations, données dans les modules de saisie et la synthèse)
- Le script 02_Complete_backup est joué mensuellement le jour défini pour sauvegarder l'ensemble des éléments nécessaires à la restauration de l'instance en cas d'incident (ensemble des données avec référentiels, médias, configurations serveur, apache etc)
- Le script 03_Export_backup est joué si le paramètre export_backup est activé (true). Il permet d'exporter sur une machine distante l'archive de backup générée par l'un des deux scripts précédents. A défaut, les archives peuvent être conservées localement. Si ce paramètre est activé, les archives sont supprimées sur la machine locale chaque jour.

Prérequis :
Installer l'utilitaire SSH Pass
sudo apt-get install sshpass

Créer un superutilisateur Postgresql qui a les droits sur la bDD de GeoNature
sudo su postgres
psql
CREATE ROLE <MON_ROLEs WITH LOGIN SUPERUSER PASSWORD '<MON_PASS>';

Créer un fichier .pgpass sur le home de root
sudo su
cd
nano .pgpass 
#hostname:port:database:username:password
localhost:5432:geonature2db:mon_role:mon_pass

Vérouiller l'accès en lecture pour root uniquement
chmod 600 .pgpass

Plannification :
Ajouter une règle via crontab pour lancer automatiquement le script Launch_automated_backup.sh. Par exemple pour une sauvegarde quotidienne à 5h du matin : 
Sudo crontab -e 
14 * * * * /home/MON_USER/test.sh
