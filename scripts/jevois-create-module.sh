#!/bin/bash
usage="USAGE: jevois-create-module.sh <VendorName> <ModuleName>"

if [ "X$1" = "X" ]; then echo $usage; exit 1; fi
if [ "X$2" = "X" ]; then echo $usage; exit 2; fi

# project directory and name is the tolower of module name:
dir="${2,,}"

if [ -d ${dir} ]; then echo "Directory [${dir}] already exists -- ABORT"; exit 4; fi

   
read -p "Create module [$2] from vendor [$1] in new directory [${dir}]  (Y/n)? "
if [ "X$REPLY" != "Xn" ]; then
    echo "*** Cloning from samplemodule github..."
    mkdir -p ${dir}
    if [ ! -d ${dir} ]; then echo "Directory [${dir}] could not be created -- ABORT"; exit 5; fi
    cd ${dir}
    git clone https://github.com/jevois/samplemodule.git

    echo "*** Patching up and customizing..."
    
    /bin/mv samplemodule/* .
    /bin/rm -rf samplemodule

    sed -i "s/SampleVendor/$1/g" CMakeLists.txt

    /bin/mv src/Modules/SampleModule src/Modules/$2
    /bin/mv src/Modules/$2/SampleModule.C src/Modules/$2/${2}.C 

    sed -i "s/SampleModule/$2/g" src/Modules/$2/${2}.C
    sed -i "s/SampleModule/$2/g" src/Modules/$2/postinstall
    sed -i "s/samplemodule/${dir}/g" CMakeLists.txt
    sed -i "s/SampleModule/$2/g" CMakeLists.txt

    chmod a+x src/Modules/$2/postinstall

    cd ..
    
    echo "*** All done. The following files were created:"
    find ${dir} -print
fi
