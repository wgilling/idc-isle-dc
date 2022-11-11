#!/bin/bash
# From: http://drupal.org/node/244924
path=${1%/}
user=${2}
group="www-data"
help="\nHelp: This script is used to fix permissions of a drupal installation\nyou need to provide the following arguments:\n\t 1) Path to your drupal installation\n\t 2) Username of the user that you want to give files/directories ownership\nNote: \"www-data\" (apache default) is assumed as the group the server is belonging to, if this is different you need to modify it manually by editing this script\n\nUsage: (sudo) bash ${0##*/} drupal_path user_name\n"

if [ -z "${path}" ] || [ ! -d "${path}/sites" ] || [ ! -f "${path}/core/modules/system/system.module" ]; then
echo "Please provide a valid drupal path"
echo -e $help
exit
fi

if [ -z "${user}" ] || [ "`id -un ${user} 2> /dev/null`" != "${user}" ]; then
echo "Please provide a valid user"
echo -e $help
exit
fi

cd $path

set -e
#CHMOD="echo /bin/chmod"
CHMOD="/bin/chmod -v"

echo -e "Fixing directory permissions beneath '$path'"
find . -type d \( \
            \( -path './sites/*' -a -name files       -a \! -perm 0770 -exec $CHMOD 0770 {} \; \) \
         -o \( -path './sites/*' -a -path '*/files/*' -a \! -perm 0770 -exec $CHMOD 0770 {} \; \) \
         -o \( \! -perm 0750 -exec $CHMOD 0750 {} \; \) \
       \) \
     #> /tmp/fix_permissions-dirs.log

echo -e "Fixing file permissions beneath '$path'"
find . -type f \( \
                \( -path './sites/' -a -path '*/files/*' -a \! -perm 0660 -exec $CHMOD 0660 {} \; \) \
             -o \( \! -perm 0640 -exec $CHMOD 0640 {} \; \)  \
           \) \
     #> /tmp/fix_permissions-files.log
 
exit 0

# This is now performed in the Docker COPY layer:
#echo -e "Changing ownership of all contents of \"${path}\" :\n user => \"${user}\" \t group => \"${group}\"\n"
#chown -R ${user}:${group} .

# Replaced by above finds:
#echo "Changing permissions of all directories inside \"${path}\" to \"750\"..."
#1 find . -type d -exec chmod u=rwx,g=rx,o= {} \;
#echo -e "Changing permissions of all files inside \"${path}\" to \"640\"...\n"
#2 find . -type f -exec chmod u=rw,g=r,o= {} \;
#
#cd $path/sites;
#
#echo "Changing permissions of \"files\" directories in \"${path}/sites\" to \"770\"..."
#3 find . -type d -name files -exec chmod ug=rwx,o= '{}' \;
#echo "Changing permissions of all files inside all \"files\" directories in \"${path}/sites\" to \"660\"..."
#4 find . -name files -type d -exec find '{}' -type f \; | while read FILE; do chmod ug=rw,o= "$FILE"; done
#echo "Changing permissions of all directories inside all \"files\" directories in \"${path}/sites\" to \"770\"..."
#5 find . -name files -type d -exec find '{}' -type d \; | while read DIR; do chmod ug=rwx,o= "$DIR"; done
