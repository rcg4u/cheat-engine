#!/bin/sh
#
# shalla_update.sh, v 0.3.1 20080403
# done by kapivie at sil.at under FreeBSD
# without any warranty
# updated by Len Tucker to create and use diff
# files to reduce load and increase speed.
# Added Checks for required elements
# Added output info for status of script
# Modified by Chris Kronberg: included loop; added some more
# checks; reduced the diff files to the necessary content.
#
#--------------------------------------------------
# little script (for crond)
# to fetch and modify new list from shallalist.de
#--------------------------------------------------
#
# *check* paths and squidGuard-owner on your system
# try i.e. "which squid" to find out the path for squid
# try "ps aux | grep squid" to find out the owner for squidGuard
#     *needs wget*
#

squidGuardpath="/usr/local/bin/squidGuard"
squidpath="/usr/sbin/squid"
tarpath="/bin/tar"
chownpath="/bin/chown"

dbhome="/usr/local/squidGuard/db"     # like in squidGuard.conf
squidGuardowner="squid:root"

##########################################

workdir="/usr/local/squidGuard/tmp"
if [ ! -d $workdir ]; then
  mkdir -p $workdir
fi

if [ ! -f $tarpath ]
 then echo "Could not locate tar."
      exit 1
fi

if [ ! -f $chownpath ]
 then echo "Could not locate chown."
      exit 1
fi 

if [ ! -d  $dbhome ]
 then echo "Could not locate squid db directory."
      exit 1
fi

# check that everything is clean before we start.
if [ -f  $workdir/shallalist.tar.gz ]; then
   echo "Old blacklist file found in ${workdir}. Deleted!"
   rm $workdir/shallalist.tar.gz
fi

if [ -d $workdir/BL ]; then
   echo "Old blacklist directory found in ${workdir}. Deleted!"
   rm -rf $workdir/BL
fi

# copy actual shalla's blacklist
# thanks for the " || exit 1 " hint to Rich Wales
# (-b run in background does not work correctly) -o log to $wgetlog

echo "Retrieving shallalist.tar.gz"

$httpget $shallalist -a $wgetlogdir/shalla-wget.log -O $workdir/shallalist.tar.gz || { echo "Unable to download shallalist.tar.gz." && exit 1 ; }

echo "Unzippping shallalist.tar.gz"

$tarpath xzf $workdir/shallalist.tar.gz -C $workdir || { echo "Unable to extract $workdir/shallalist.tar.gz." && exit 1 ; }

# Create diff files for all categories
# Note: There is no reason to use all categories unless this is exactly
#       what you intend to block. Make sure that only the categories you
#       are going to block with squidGuard are listed below.

CATEGORIES="adv aggressive automobile/cars automobile/bikes automobile/planes automobile/boats chat dating downloads drugs dynamic finance/banking finance/insurance finance/other finance/moneylending finance/realestate forum gamble hacking hobby/cooking hobby/games hobby/pets hospitals imagehosting isp jobsearch models movies music news podcasts politcs porn recreation/humor recreation/sports recreation/travel recreation/wellness redirector religion ringtones science/astronomy science/chemistry searchengines sex/lingerie shopping socialnet spyware tracker updatesites violence warez weapons webmail webphone webradio webtv" 

echo "Creating diff files."
# The "cp" after the "diff" ensures that we keep up to date with our 
# domains and urls files.
for cat in $CATEGORIES
do

if [ -f $workdir/BL/${cat}/domains ] && [ -f $dbhome/${cat}/domains ]
  then
    diff -U 0 $dbhome/${cat}/domains $workdir/BL/${cat}/domains |grep -v "^---"|grep -v "^+++"|grep -v "^@@" > $dbhome/${cat}/domains.diff
    cp $workdir/BL/${cat}/domains $dbhome/${cat}/domains
fi

if [ -f $workdir/BL/${cat}/urls ] && [ -f $dbhome/${cat}/urls ]
  then
    diff -ur $dbhome/${cat}/urls $workdir/BL/${cat}/urls > $dbhome/${cat}/urls.diff
    cp $workdir/BL/${cat}/urls $dbhome/${cat}/urls
fi

done


echo "Setting file permisions."
$chownpath -R $squidGuardowner $dbhome
chmod 755 $dbhome
cd $dbhome
find . -type f -exec chmod 644 {} \;
find . -type d -exec chmod 755 {} \;

echo "Updating squid db files with diffs."
$squidGuardpath -u all

echo "Reconfiguring squid."
$squidpath -k reconfigure

echo "Clean up downloaded file and directories."
rm $workdir/shallalist.tar.gz
rm -rf $workdir/BL

exit 0
