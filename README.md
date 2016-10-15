# A collection of shell scripts

This is not a project, but more a collection of maybe
useful things I collected during the years.

    Some are from my blog: https://blog.techottis.ch/

I thought that gists canot really be linked together,
so this will become the blog repo and its own collection.

    For example:

	https://blog.techottis.ch/2013/01/19/a-small-script-gplot-csh-quick-plotting-with-gnuplot/

	https://blog.techottis.ch/2013/05/01/a-small-script-taritdate-sh-tars-directories-with-dates/
	    
Soon more docs here.

# Programs

## gplot.csh

## taritdate.sh

## backmeup.sh

 This script uses rsync as a "backup system". It is not definitely yet a full backup solution but
 it is indeed very handy.

 In principle it works much alike the Mac OS time machine.

You need first to define a backup directory (which can be on a network disk, any which shows as path on your
system. For example I have a samba mounted on my macbook). This is this line in the scriopt:

    DIRRSYNC="/Volumes/ExtDisk/MacBackUp"

The rest id preconfigured, but check the script which is really few lines.

Then

    backmeup.sh DirToBackUp

will create a directory '/Volumes/ExtDisk/MacBackUp/DirToBackUp' which is a copy of your original dir,
and eventually later a directory '/Volumes/ExtDisk/MacBackUp-BP/DirToBackUp/B-<DATE>' which contains deleted
and changed files old versions.

The script is in very beta but a starting point.

It creates also a file list for the '/Volumes/ExtDisk/MacBackUp-BP/DirToBackUp/B-<DATE>' directory.

The idea is that if you look for a file, you know already which file on your current system,
and you might need to look only on the old backups, like:

    grep myfile /Volumes/ExtDisk/MacBackUp-BP/DirToBackUp/*.filelist

The backup destination is hardcoded. My idea is to use the script in the future as a templates
and create scripts like: backmeup.dest01.sh, backmeup.dest02.sh and use them in a cron job
with only the requested backup directory as parameter.

This because we might need different options depending on the destination. One option is already
mentioned as comment in the script: '--modify-window=1'.
This is used when for example you are working with Samba, SMB, or Windows destinations as you
might endup on a file system which has only a 1 minute (+-1 implicit) time diference stored
for file dates.

Ahh, I did it because I read everywhere about using rsync for backups but I could not find
any example. This is a starting example, and I will use it. So I might update for bugs
soon.
