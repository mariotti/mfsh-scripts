#! /bin/sh
#
# F.Mariotti: taritdate.sh
#
# Simple help text
if [ -z $1 ]; then
echo "please give a dir name."
exit 1;
fi;
#
# Make sure we have only one argument
if ! [ -z $2 ]; then
echo "Sorry but we only accept ONE directory only."
exit 1;
fi;
#
#Check that it is a directory
mydirname=$1
if ! [ -d $mydirname ]; then
echo "At present you can only tar a directory."
exit 1;
fi;
#
#Define the date format
# mydate=`date +%d%b%Y` #01May2013
mydate=`date +%Y%m%d` #20130501
#
#Remove slash at end if present
thisdirname=`dirname $mydirname`/`basename $mydirname`
#
#Build first part of the tar name
tarprename=${thisdirname}.${mydate}.
#
#Start trying with a plain name
tarname=${thisdirname}.${mydate}.tar.gz
#
#If it exists add trailing decimals
if [ -f $tarname ]; then
i=0
while [ 1 ];
do
i=$(($i+1))
tarname=${tarprename}${i}.tar.gz
echo "WARNING: Tar file exists.. trying: $tarname"
if ! [ -f $tarname ]; then
break 1;
fi;
done
fi;
#
#Create the tar archive
tar -czvf $tarname $mydirname
#
