#!/bin/bash 
# create an array 
_Users=( `ls /Users | grep -v "Shared"`) 
echo ${_Users[@]} 
# remove PremierPro folder for TheUser 
for TheUser in ${_Users[@]} 
do
echo "Checking if directory /Users/$TheUser/Desktop/PremierPro exists"
if [ -d /Users/$TheUser/Desktop/PremierPro ] 
then
echo "Found PremierPro folder"
echo "Found, Removing /Users/$TheUser/Desktop/PremierPro"
bash -c "rm -r -f /Users/$TheUser/Desktop/PremierPro"
fi
done
# Check private profiles
_Users=( `ls /var/private | grep -v "Shared"`) 
echo ${_Users[@]} 
# remove PremierPro folder for TheUser 
for TheUser in ${_Users[@]} 
do
echo "Checking if directory /var/private/$TheUser/Desktop/PremierPro exists"
if [ -d /var/private/$TheUser/Desktop/PremierPro ] 
then
echo "Found PremierPro folder"
echo "Found, Removing /var/private/$TheUser/Desktop/PremierPro"
bash -c "rm -r -f /var/private/$TheUser/Desktop/PremierPro"
fi
done


exit 0;