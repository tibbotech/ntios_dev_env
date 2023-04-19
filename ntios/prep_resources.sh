#!/bin/bash

#this script takes a folder with resource files and creates a std::map  with the file name as the key and the array as the data. 
#this is useful for embedding resources into a binary.

#usage: prep_resources.sh <input folder> <output file>
#declare file array 

echo "-------------------------------STARTING RESOURCE GENERATION----------------------------"

OLDIFS=$IFS
IFS=$'\n'
files=( $(ls $1*) ) 
#prinf length of files 
numfiles=$(echo ${#files[@]})
 

#start the output file
echo "#include <map>" > $2
echo "#include <string>" >> $2
echo "#include <cstdint>" >> $2

echo "namespace ntios {" >> $2
echo "namespace romfile {" >> $2

id=0
#while id < numfiles 
while [ $id -lt $numfiles ]
do
    #get the file name
    filename=$(basename ${files[$id]})
    #if filename is equal to resources.cpp skip it
    if [ $filename == "resources.cpp" ]
    then
        id=$((id+1))
        continue
    fi

    #get the file data
    data=$(xxd -i ${files[$id]})
    #replace aaa with bbb
    data=$(echo $data | sed 's/   /\r\n/g')
     


    #trim data to only array data
    data=$(echo $data | cut -d'{' -f2 | cut -d'}' -f1)
    #write the array to the output file
    echo "const std::uint8_t resource_$id[] = {" >> $2
    echo "$data" >> $2
    echo "};" >> $2
    #get resource size using stat
    size=$(stat -c%s ${files[$id]})
    #write the size to the output file
    echo "const std::uint32_t resource_${id}_size = $size;" >> $2
    #increment the id
    id=$((id+1))
done

echo "std::map<const std::string, const std::uint8_t*> romfiles = {"  >> $2
id=0
while [ $id -lt $numfiles ]
do
    #get the file name
    filename=$(basename ${files[$id]})
    #if filename is equal to resources.cpp skip it
    if [ $filename == "resources.cpp" ]
    then
        id=$((id+1))
        continue
    fi

    #write the map entry to the output file
    echo  >> $2
    #if its the las file dont add a comma
    if [ $id -eq $((id-1)) ]
    then
        echo "{\"$filename\", resource_$id}" >> $2
    else
        echo "{\"$filename\", resource_$id}," >> $2
    fi
    #increment the id
    id=$((id+1))
    #echo new line 
    echo "" >> $2
done
echo "};" >> $2
echo 

echo "std::map<const std::string, const std::uint32_t> romfile_sizes = {"  >> $2
id=0
while [ $id -lt $numfiles ]
do
    #get the file name
    filename=$(basename ${files[$id]})
    #if filename is equal to resources.cpp skip it
    if [ $filename == "resources.cpp" ]
    then
        id=$((id+1))
        continue
    fi

    #write the map entry to the output file
    echo  >> $2
    #if its the las file dont add a comma
    if [ $id -eq $((id-1)) ]
    then
        echo "{\"$filename\", resource_$id"_size"}" >> $2
    else
        echo "{\"$filename\", resource_$id"_size"}," >> $2
    fi
    #increment the id
    id=$((id+1))
    #echo new line 
    echo "" >> $2
done

echo "};" >> $2
echo "} //namespace ntios" >> $2
echo "} //namespace romfile" >> $2

IFS=$OLDIFS
echo "-------------------------------ENDING RESOURCE GENERATION----------------------------"
