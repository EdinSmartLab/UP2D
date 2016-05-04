#!/bin/bash

# what parameter file
params="cylinder/cylinder.ini"

happy=0
sad=0

# list of prefixes the test generates
prefixes=(mask p ux uy vor)
# list of possible times
times=(000020 000040 000050)

# run actual test
./UP2D ${params}

echo "============================"
echo "run done, analyzing data now"
echo "============================"

# loop over all HDF5 files an generate keyvalues using flusi
for p in ${prefixes[@]}
do
  for t in ${times[@]}
  do
    echo "--------------------------------------------------------------------"
    # *.h5 file coming out of the code
    file=${p}"_"${t}".h5"
    # will be transformed into this *.key file
    keyfile=${p}"_"${t}".key"
    # which we will compare to this *.ref file
    reffile=./cylinder/${p}"_"${t}".ref"

    if [ -f $file ]; then
        # get four characteristic values describing the field
	./UP2D -p --keyvalues ${file}

        # and compare them to the ones stored
        if [ -f $reffile ]; then
            ./UP2D -p --compare-keys $keyfile $reffile
            result=$?
            if [ $result == "0" ]; then
              echo -e ":) Happy, this looks okay! " $keyfile $reffile
              happy=$((happy+1))
            else
              echo -e ":[ Sad, this is failed! " $keyfile $reffile
              sad=$((sad+1))
            fi
        else
            sad=$((sad+1))
            echo -e ":[ Sad: Reference file not found"
        fi
    else
        sad=$((sad+1))
        echo -e ":[ Sad: output file not found"
    fi
    echo " "
    echo " "

  done
done


echo -e "\thappy tests: \t" $happy
echo -e "\tsad tests: \t" $sad

#-------------------------------------------------------------------------------
#                               RETURN
#-------------------------------------------------------------------------------
if [ $sad == 0 ]
then
  exit 0
else
  exit 999
fi
