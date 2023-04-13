#!/bin/bash 

#prepare the location of the tibbo-oobe deb file based on the version number 

#if there are no parameters use the default version number
if [ -z "$1" ]; then
    image_version="0_6_0"
else
    image_version=$1
fi

if [ -z "$2" ]; then
    version_number="0.6.0-1"
else 
    version_number=$2
fi

deb_file_name="tibbo-oobe_"$version_number"_all.deb"

if [ -z "$3" ]; then
    tibbo_oobe_location="https://tibbotech.github.io/ltpp3g2_ppa/u"$image_version"/"$deb_file_name""
else 
    tibbo_oobe_location="$3"$image_version"/"$deb_file_name""
fi


#get this files location
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd $DIR
#check if deb directory exists and if it exists delete it
if [ -d "deb" ]; then
    rm -rf deb
fi

mkdir deb

cd deb 

#use wget to get the files https://tibbotech.github.io/ltpp3g2_ppa/u0_6_0/tibbo-oobe_0.6.0-1_all.deb 
#and if it fails abort and print the error message
wget $tibbo_oobe_location || { echo "Unable to fetch the libraries" ; exit 1; }

ar -x $deb_file_name

tar -xvf data.tar.zst

cd .. 

#prepare the include files
if [ -d "inc" ]; then
    rm -rf inc
fi
mkdir inc 
cp -r deb/usr/include/ntios/* inc



#prepare the library files
if [ -d "libs" ]; then
    rm -rf libs
fi
mkdir libs
cp -r deb/usr/lib/arm-linux-gnueabihf/* libs

#remove the deb directory
rm -rf deb
