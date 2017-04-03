#! /bin/sh
#
# SETUP
#TESTING: DIRRSYNC="${HOME}/tmp/rs/rsyncBackup"
DIRRSYNC="/Volumes/ExtDisk/MacBackUp"
DIRBACKUPS="${DIRRSYNC}-BP"
#mydate=`date +%Y%m%d-%H%M`   #FORMAT: 20130131-2226 / Windows SMB / Samba with --modify-window=1
mydate=`date +%Y%m%d-%H%M%S`   #FORMAT: 20130131-222618
OPTRSYNC="-av --delete --backup"
#
# Parsing the one option
if [ -z $1 ]; then
    echo "please give a dir name."
    exit 1;
fi;
#Remove trailing / it creates a project directory
TOBACKUP=`dirname $1`/`basename $1`
PRJDIR=`basename ${1}`
DIRBKUP="${DIRBACKUPS}/${PRJDIR}/B-${mydate}"
OPTBKUP=" --backup-dir=${DIRBKUP}"
PRGDIRBACKUPS="${HOME}/tmp/rs/rsyncBackup-BP/${1}/"
#rsync --dry-run ${OPTRSYNC} ${OPTBKUP} $1 ${DIRRSYNC}/${PRJDIR}
#echo "Running: " rsync ${OPTRSYNC} ${OPTBKUP} $1 ${DIRRSYNC}/${PRJDIR}
rsync ${OPTRSYNC} ${OPTBKUP} ${TOBACKUP} ${DIRRSYNC}/${PRJDIR}
#
#
# Create List Files
if [ -d ${DIRBACKUPS}/${PRJDIR} ]; then
  cd ${DIRBACKUPS}
  find ${PRJDIR}/B-${mydate} > ${PRJDIR}/B-${mydate}.filelist
fi;
#
# Update a local copy of the db for locate
gupdatedb -o ${DIRRSYNC}/.locate.db --localpaths="${DIRRSYNC}"
