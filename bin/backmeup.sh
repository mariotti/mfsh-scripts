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
if [ -z $1 ]; then
    echo "please give a dir name."
    exit 1;
fi;
PRJDIR=`basename ${1}`
DIRBKPUP=" --backup-dir=${DIRBACKUPS}/${PRJDIR}/B-${mydate}"
PRGDIRBACKUPS="${HOME}/tmp/rs/rsyncBackup-BP/${1}/"
#rsync --dry-run ${OPTRSYNC} ${DIRBKPUP} $1 ${DIRRSYNC}/${PRJDIR}
echo "Running: " rsync ${OPTRSYNC} ${DIRBKPUP} $1 ${DIRRSYNC}/${PRJDIR}
rsync ${OPTRSYNC} ${DIRBKPUP} $1 ${DIRRSYNC}/${PRJDIR}
#
